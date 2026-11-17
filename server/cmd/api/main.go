package main

import (
	"context"
	"flag"
	"github.com/lipskakira95-oss/DiaMuKira/server/internal/catalog"
	"github.com/lipskakira95-oss/DiaMuKira/server/internal/httpapi"
	"log"
	"net/http"
	"time"
)

func main() {
	dbPath := flag.String("db", "../.local/data/quiz.sqlite", "existing SQLite catalog")
	addr := flag.String("addr", "127.0.0.1:8080", "HTTP listen address")
	allowDraft := flag.Bool("allow-draft", false, "allow unreviewed content for local development")
	flag.Parse()
	store, err := catalog.Open(*dbPath)
	if err != nil {
		log.Fatal(err)
	}
	defer store.Close()
	_, mode, err := store.Metadata(context.Background())
	if err != nil {
		log.Fatal("Import content before starting API: ", err)
	}
	if !*allowDraft && mode != "production" {
		log.Fatal("Production refuses draft content; local development requires -allow-draft")
	}
	server := &http.Server{Addr: *addr, Handler: httpapi.New(store, !*allowDraft), ReadHeaderTimeout: 5 * time.Second, ReadTimeout: 15 * time.Second, WriteTimeout: 15 * time.Second, IdleTimeout: 60 * time.Second}
	log.Printf("Quiz API listening on %s (allow-draft=%t)", *addr, *allowDraft)
	log.Fatal(server.ListenAndServe())
}
