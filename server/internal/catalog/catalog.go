// Package catalog validates editable CSV content and persists it in SQLite.
package catalog

import (
	"bufio"
	"context"
	"database/sql"
	_ "embed"
	"encoding/csv"
	"errors"
	"fmt"
	"io"
	"strconv"
	"strings"

	_ "modernc.org/sqlite"
)

type Question struct {
	ID             string `json:"id"`
	CategoryID     string `json:"category_id"`
	CategoryName   string `json:"category_name"`
	RoundNumber    int    `json:"round_number"`
	RoundTitle     string `json:"round_title"`
	Position       int    `json:"position"`
	Text           string `json:"text"`
	CorrectAnswer  bool   `json:"correct_answer"`
	Explanation    string `json:"explanation"`
	Status         string `json:"status"`
	Source         string `json:"source"`
	ContentVersion string `json:"content_version"`
}

var distribution = map[string][]int{
	"children": {7, 7, 7}, "students": {9, 9, 9}, "teachers": {9, 8, 8, 8},
	"parents": {10, 10, 10, 9}, "media": {8, 8, 8, 8},
}

var columns = []string{"category_id", "category_name", "round_number", "round_title", "position", "question_id", "question", "answer", "explanation", "status", "source", "content_version"}

func ParseCSV(r io.Reader) ([]Question, error) {
	input := bufio.NewReader(r)
	if prefix, _ := input.Peek(3); string(prefix) == "\ufeff" {
		input.Discard(3)
	}
	reader := csv.NewReader(input)
	names, err := reader.Read()
	if err != nil {
		return nil, fmt.Errorf("CSV header: %w", err)
	}
	names[0] = strings.TrimPrefix(names[0], "\ufeff")
	if len(names) != len(columns) {
		return nil, errors.New("unexpected CSV columns")
	}
	for i, name := range names {
		if name != columns[i] {
			return nil, fmt.Errorf("column %d: expected %s", i+1, columns[i])
		}
	}
	var questions []Question
	for line := 2; ; line++ {
		row, err := reader.Read()
		if err == io.EOF {
			break
		}
		if err != nil {
			return nil, fmt.Errorf("line %d: %w", line, err)
		}
		round, err := strconv.Atoi(row[2])
		if err != nil {
			return nil, fmt.Errorf("line %d: invalid round", line)
		}
		position, err := strconv.Atoi(row[4])
		if err != nil {
			return nil, fmt.Errorf("line %d: invalid position", line)
		}
		var answer bool
		switch row[7] {
		case "Так":
			answer = true
		case "Ні":
			answer = false
		default:
			return nil, fmt.Errorf("line %d: answer must be Так or Ні", line)
		}
		questions = append(questions, Question{ID: row[5], CategoryID: row[0], CategoryName: row[1], RoundNumber: round, RoundTitle: row[3], Position: position, Text: row[6], CorrectAnswer: answer, Explanation: row[8], Status: row[9], Source: row[10], ContentVersion: row[11]})
	}
	if err := validate(questions, false); err != nil {
		return nil, err
	}
	return questions, nil
}

func validate(questions []Question, production bool) error {
	if len(questions) == 0 {
		return errors.New("empty content")
	}
	ids := map[string]bool{}
	positions := map[string]bool{}
	counts := map[string]int{}
	categoryNames := map[string]string{}
	roundNames := map[string]string{}
	version := questions[0].ContentVersion
	for _, q := range questions {
		for _, value := range []string{q.ID, q.CategoryID, q.CategoryName, q.RoundTitle, q.Text, q.Explanation, q.Source, q.ContentVersion} {
			if strings.TrimSpace(value) == "" {
				return errors.New("required field is empty")
			}
		}
		limits, ok := distribution[q.CategoryID]
		if !ok || q.RoundNumber < 1 || q.RoundNumber > len(limits) {
			return fmt.Errorf("invalid category/round for %s", q.ID)
		}
		if q.Position < 1 || q.Position > limits[q.RoundNumber-1] {
			return fmt.Errorf("invalid position for %s", q.ID)
		}
		if q.Status != "draft" && q.Status != "approved" {
			return fmt.Errorf("invalid status for %s", q.ID)
		}
		if production && q.Status != "approved" {
			return fmt.Errorf("unreviewed question %s: production import refused", q.ID)
		}
		if q.ContentVersion != version {
			return errors.New("mixed content versions")
		}
		if ids[q.ID] {
			return fmt.Errorf("duplicate question ID %s", q.ID)
		}
		ids[q.ID] = true
		roundKey := fmt.Sprintf("%s/%d", q.CategoryID, q.RoundNumber)
		positionKey := fmt.Sprintf("%s/%d", roundKey, q.Position)
		if positions[positionKey] {
			return fmt.Errorf("duplicate position %s", positionKey)
		}
		positions[positionKey] = true
		if old, ok := categoryNames[q.CategoryID]; ok && old != q.CategoryName {
			return errors.New("conflicting category names")
		}
		if old, ok := roundNames[roundKey]; ok && old != q.RoundTitle {
			return errors.New("conflicting round names")
		}
		categoryNames[q.CategoryID] = q.CategoryName
		roundNames[roundKey] = q.RoundTitle
		counts[roundKey]++
	}
	if production {
		for category, rounds := range distribution {
			for round, want := range rounds {
				key := fmt.Sprintf("%s/%d", category, round+1)
				if counts[key] != want {
					return fmt.Errorf("%s: expected %d questions, got %d", key, want, counts[key])
				}
			}
		}
	}
	return nil
}

type Store struct{ db *sql.DB }

//go:embed schema.sql
var schema string

func Open(path string) (*Store, error) {
	db, err := sql.Open("sqlite", path)
	if err != nil {
		return nil, err
	}
	db.SetMaxOpenConns(1)
	fail := func(err error) (*Store, error) { db.Close(); return nil, err }
	if _, err = db.Exec("PRAGMA foreign_keys=ON; PRAGMA busy_timeout=5000;"); err != nil {
		return fail(err)
	}
	var version int
	if err = db.QueryRow("PRAGMA user_version").Scan(&version); err != nil {
		return fail(err)
	}
	if version > 1 {
		return fail(fmt.Errorf("unsupported database schema version %d", version))
	}
	if version == 0 {
		tx, err := db.Begin()
		if err != nil {
			return fail(err)
		}
		if _, err = tx.Exec(schema); err != nil {
			tx.Rollback()
			return fail(err)
		}
		if err = tx.Commit(); err != nil {
			return fail(err)
		}
	}
	return &Store{db: db}, nil
}

func (s *Store) Close() error { return s.db.Close() }

// Replace is atomic: a rejected or failed import never deletes the previous set.
func (s *Store) Replace(ctx context.Context, questions []Question, production bool) error {
	if err := validate(questions, production); err != nil {
		return err
	}
	tx, err := s.db.BeginTx(ctx, nil)
	if err != nil {
		return err
	}
	defer tx.Rollback()
	if _, err = tx.ExecContext(ctx, "DELETE FROM questions; DELETE FROM rounds; DELETE FROM categories; DELETE FROM content_meta;"); err != nil {
		return err
	}
	mode := "draft"
	if production {
		mode = "production"
	}
	if _, err = tx.ExecContext(ctx, "INSERT INTO content_meta(id,version,mode) VALUES(1,?,?)", questions[0].ContentVersion, mode); err != nil {
		return err
	}
	for _, q := range questions {
		if _, err = tx.ExecContext(ctx, "INSERT OR IGNORE INTO categories(id,name) VALUES(?,?)", q.CategoryID, q.CategoryName); err != nil {
			return err
		}
		if _, err = tx.ExecContext(ctx, "INSERT OR IGNORE INTO rounds(category_id,number,title) VALUES(?,?,?)", q.CategoryID, q.RoundNumber, q.RoundTitle); err != nil {
			return err
		}
		if _, err = tx.ExecContext(ctx, `INSERT INTO questions(id,category_id,round_number,position,text,correct_answer,explanation,status,source,content_version) VALUES(?,?,?,?,?,?,?,?,?,?)`, q.ID, q.CategoryID, q.RoundNumber, q.Position, q.Text, q.CorrectAnswer, q.Explanation, q.Status, q.Source, q.ContentVersion); err != nil {
			return err
		}
	}
	return tx.Commit()
}

func (s *Store) Metadata(ctx context.Context) (version, mode string, err error) {
	err = s.db.QueryRowContext(ctx, "SELECT version,mode FROM content_meta WHERE id=1").Scan(&version, &mode)
	return
}

func (s *Store) Questions(ctx context.Context) ([]Question, error) {
	return queryQuestions(ctx, s.db)
}

type queryer interface {
	QueryContext(context.Context, string, ...any) (*sql.Rows, error)
}

func queryQuestions(ctx context.Context, db queryer) ([]Question, error) {
	rows, err := db.QueryContext(ctx, `SELECT q.id,q.category_id,c.name,q.round_number,r.title,q.position,q.text,q.correct_answer,q.explanation,q.status,q.source,q.content_version FROM questions q JOIN categories c ON c.id=q.category_id JOIN rounds r ON r.category_id=q.category_id AND r.number=q.round_number ORDER BY CASE q.category_id WHEN 'children' THEN 1 WHEN 'students' THEN 2 WHEN 'teachers' THEN 3 WHEN 'parents' THEN 4 ELSE 5 END,q.round_number,q.position`)
	if err != nil {
		return nil, err
	}
	defer rows.Close()
	result := []Question{}
	for rows.Next() {
		var q Question
		if err = rows.Scan(&q.ID, &q.CategoryID, &q.CategoryName, &q.RoundNumber, &q.RoundTitle, &q.Position, &q.Text, &q.CorrectAnswer, &q.Explanation, &q.Status, &q.Source, &q.ContentVersion); err != nil {
			return nil, err
		}
		result = append(result, q)
	}
	return result, rows.Err()
}

// Snapshot keeps metadata and questions from the same database revision.
func (s *Store) Snapshot(ctx context.Context) (version, mode string, questions []Question, err error) {
	tx, err := s.db.BeginTx(ctx, &sql.TxOptions{ReadOnly: true})
	if err != nil {
		return
	}
	defer tx.Rollback()
	if err = tx.QueryRowContext(ctx, "SELECT version,mode FROM content_meta WHERE id=1").Scan(&version, &mode); err != nil {
		return
	}
	questions, err = queryQuestions(ctx, tx)
	return
}
