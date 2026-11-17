package catalog

import (
	"context"
	"os"
	"path/filepath"
	"strings"
	"testing"
)

const header = "category_id,category_name,round_number,round_title,position,question_id,question,answer,explanation,status,source,content_version\n"

func csvRow(id, answer, status string) string {
	return "children,Діти 5–12 років,1,Повага,1," + id + ",Чи варто слухати інших?," + answer + ",Кожен має право висловитися.," + status + ",author_draft,draft-1\n"
}

func TestParseCSV(t *testing.T) {
	t.Run("BOM before quoted CSV header", func(t *testing.T) {
		quoted := strings.Replace(header, "category_id,", "\"category_id\",", 1)
		if _, err := ParseCSV(strings.NewReader("\ufeff" + quoted + csvRow("q1", "Так", "draft"))); err != nil {
			t.Fatal(err)
		}
	})
	t.Run("UTF8 BOM and Ukrainian answer", func(t *testing.T) {
		rows, err := ParseCSV(strings.NewReader("\ufeff" + header + csvRow("q1", "Так", "draft")))
		if err != nil || len(rows) != 1 || !rows[0].CorrectAnswer {
			t.Fatalf("rows=%v err=%v", rows, err)
		}
	})
	for _, tc := range []struct{ name, body string }{
		{"invalid boolean", header + csvRow("q1", "можливо", "draft")},
		{"missing answer", header + csvRow("q1", "", "draft")},
		{"duplicate ID", header + csvRow("q1", "Так", "draft") + csvRow("q1", "Ні", "draft")},
		{"unknown category", header + strings.Replace(csvRow("q1", "Так", "draft"), "children,", "unknown,", 1)},
		{"invalid round", header + strings.Replace(csvRow("q1", "Так", "draft"), ",1,Повага", ",9,Повага", 1)},
		{"unknown review status", header + csvRow("q1", "Так", "pending")},
	} {
		t.Run(tc.name, func(t *testing.T) {
			if _, err := ParseCSV(strings.NewReader(tc.body)); err == nil {
				t.Fatal("expected validation error")
			}
		})
	}
}

func TestSQLiteImportAndReopen(t *testing.T) {
	ctx := context.Background()
	path := filepath.Join(t.TempDir(), "quiz.sqlite")
	store, err := Open(path)
	if err != nil {
		t.Fatal(err)
	}
	rows, err := ParseCSV(strings.NewReader(header + csvRow("q1", "Так", "draft")))
	if err != nil {
		t.Fatal(err)
	}
	if err = store.Replace(ctx, rows, false); err != nil {
		t.Fatal(err)
	}
	if err = store.Close(); err != nil {
		t.Fatal(err)
	}
	store, err = Open(path)
	if err != nil {
		t.Fatal(err)
	}
	defer store.Close()
	got, err := store.Questions(ctx)
	if err != nil || len(got) != 1 || got[0].ID != "q1" {
		t.Fatalf("got=%v err=%v", got, err)
	}
	if err = store.Replace(ctx, rows, true); err == nil {
		t.Fatal("draft must not enter production")
	}
	got, err = store.Questions(ctx)
	if err != nil || len(got) != 1 {
		t.Fatal("rejected import changed database")
	}
	duplicate := append(append([]Question{}, rows...), rows[0])
	if err = store.Replace(ctx, duplicate, false); err == nil {
		t.Fatal("duplicate import must fail")
	}
	got, err = store.Questions(ctx)
	if err != nil || len(got) != 1 {
		t.Fatal("failed transaction lost old data")
	}
}

func TestProjectCSVDistribution(t *testing.T) {
	f, err := os.Open("../../../content/questions.uk.csv")
	if err != nil {
		t.Fatal(err)
	}
	defer f.Close()
	rows, err := ParseCSV(f)
	if err != nil {
		t.Fatal(err)
	}
	if len(rows) != 152 {
		t.Fatalf("want 152, got %d", len(rows))
	}
	expected := map[string][]int{"children": {7, 7, 7}, "students": {9, 9, 9}, "teachers": {9, 8, 8, 8}, "parents": {10, 10, 10, 9}, "media": {8, 8, 8, 8}}
	for category, rounds := range expected {
		for index, want := range rounds {
			count := 0
			for _, q := range rows {
				if q.CategoryID == category && q.RoundNumber == index+1 {
					count++
				}
			}
			if count != want {
				t.Fatalf("%s round %d: want %d got %d", category, index+1, want, count)
			}
		}
	}
	store, err := Open(filepath.Join(t.TempDir(), "full.sqlite"))
	if err != nil {
		t.Fatal(err)
	}
	defer store.Close()
	if err = store.Replace(context.Background(), rows, false); err != nil {
		t.Fatal(err)
	}
	got, err := store.Questions(context.Background())
	if err != nil || len(got) != 152 {
		t.Fatalf("rows %d err %v", len(got), err)
	}
	if err = store.Replace(context.Background(), rows, true); err == nil {
		t.Fatal("unreviewed project content accepted for production")
	}
	// Simulate editorial approval only inside this test, never in the source CSV.
	for i := range rows {
		rows[i].Status = "approved"
	}
	if err = store.Replace(context.Background(), rows, true); err != nil {
		t.Fatal(err)
	}
	_, mode, err := store.Metadata(context.Background())
	if err != nil || mode != "production" {
		t.Fatalf("mode=%s err=%v", mode, err)
	}
}

func TestSQLFailureRollsBackReplacement(t *testing.T) {
	ctx := context.Background()
	store, err := Open(filepath.Join(t.TempDir(), "rollback.sqlite"))
	if err != nil {
		t.Fatal(err)
	}
	defer store.Close()
	rows, err := ParseCSV(strings.NewReader(header + csvRow("original", "Так", "draft")))
	if err != nil {
		t.Fatal(err)
	}
	if err = store.Replace(ctx, rows, false); err != nil {
		t.Fatal(err)
	}
	_, err = store.db.Exec(`CREATE TRIGGER reject_import BEFORE INSERT ON questions WHEN NEW.id='rejected' BEGIN SELECT RAISE(ABORT, 'simulated failure'); END`)
	if err != nil {
		t.Fatal(err)
	}
	rows[0].ID = "rejected"
	if err = store.Replace(ctx, rows, false); err == nil {
		t.Fatal("expected SQL failure")
	}
	got, err := store.Questions(ctx)
	if err != nil || len(got) != 1 || got[0].ID != "original" {
		t.Fatalf("rollback lost old data: %v %v", got, err)
	}
}

func TestRejectFutureDatabaseSchema(t *testing.T) {
	path := filepath.Join(t.TempDir(), "future.sqlite")
	store, err := Open(path)
	if err != nil {
		t.Fatal(err)
	}
	if _, err = store.db.Exec("PRAGMA user_version=99"); err != nil {
		t.Fatal(err)
	}
	store.Close()
	if unexpected, err := Open(path); err == nil {
		unexpected.Close()
		t.Fatal("accepted unsupported schema")
	}
}
