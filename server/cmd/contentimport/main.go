package main

import (
	"context"
	"flag"
	"fmt"
	"github.com/lipskakira95-oss/DiaMuKira/server/internal/catalog"
	"log"
	"os"
	"path/filepath"
)

func main() {
	csvPath := flag.String("csv", "../content/questions.uk.csv", "CSV source")
	dbPath := flag.String("db", "../.local/data/quiz.sqlite", "SQLite file")
	production := flag.Bool("production", false, "require reviewed full production content")
	flag.Parse()
	if err := run(*csvPath, *dbPath, *production); err != nil {
		log.Fatal(err)
	}
}
func run(csvPath, dbPath string, production bool) error {
	f, err := os.Open(csvPath)
	if err != nil {
		return err
	}
	defer f.Close()
	questions, err := catalog.ParseCSV(f)
	if err != nil {
		return err
	}
	if err = os.MkdirAll(filepath.Dir(dbPath), 0755); err != nil {
		return err
	}
	store, err := catalog.Open(dbPath)
	if err != nil {
		return err
	}
	defer store.Close()
	if err = store.Replace(context.Background(), questions, production); err != nil {
		return err
	}
	fmt.Printf("Imported %d questions into %s (production=%t)\n", len(questions), dbPath, production)
	return nil
}
