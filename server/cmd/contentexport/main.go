// contentexport generates Flutter's bundled fallback from the SQLite catalog.
package main

import (
	"context"
	"encoding/json"
	"flag"
	"github.com/lipskakira95-oss/DiaMuKira/server/internal/catalog"
	"log"
	"os"
	"path/filepath"
)

func main() {
	dbPath := flag.String("db", "../.local/data/quiz.sqlite", "SQLite catalog")
	output := flag.String("out", "../apps/quiz/assets/content/questions.json", "generated bundled content")
	flag.Parse()
	store, err := catalog.Open(*dbPath)
	if err != nil {
		log.Fatal(err)
	}
	defer store.Close()
	version, mode, questions, err := store.Snapshot(context.Background())
	if err != nil {
		log.Fatal(err)
	}
	data, err := json.MarshalIndent(map[string]any{"schema_version": 1, "content_version": version, "mode": mode, "questions": questions}, "", "  ")
	if err != nil {
		log.Fatal(err)
	}
	if err = os.MkdirAll(filepath.Dir(*output), 0755); err != nil {
		log.Fatal(err)
	}
	if err = os.WriteFile(*output, append(data, '\n'), 0644); err != nil {
		log.Fatal(err)
	}
	log.Printf("Exported %d %s questions to %s", len(questions), mode, *output)
}
