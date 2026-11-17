package httpapi

import (
	"crypto/sha256"
	"encoding/json"
	"fmt"
	"github.com/lipskakira95-oss/DiaMuKira/server/internal/catalog"
	"net/http"
)

func New(store *catalog.Store, production bool) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json; charset=utf-8")
		w.Header().Set("X-Content-Type-Options", "nosniff")
		known := r.URL.Path == "/health" || r.URL.Path == "/api/v1/content" || r.URL.Path == "/api/v1/content/version"
		if !known {
			reply(w, 404, map[string]string{"error": "not found"})
			return
		}
		if r.Method != "GET" {
			w.Header().Set("Allow", "GET")
			reply(w, 405, map[string]string{"error": "method not allowed"})
			return
		}
		if r.URL.Path == "/health" {
			reply(w, 200, map[string]string{"status": "ok"})
			return
		}
		version, mode, questions, err := store.Snapshot(r.Context())
		if err != nil {
			reply(w, 503, map[string]string{"error": "content unavailable"})
			return
		}
		if production && mode != "production" {
			reply(w, 503, map[string]string{"error": "content is not approved for production"})
			return
		}
		var result any
		if r.URL.Path == "/api/v1/content/version" {
			result = map[string]any{"schema_version": 1, "content_version": version, "mode": mode}
		} else {
			result = map[string]any{"schema_version": 1, "content_version": version, "mode": mode, "questions": questions}
		}
		body, err := json.Marshal(result)
		if err != nil {
			reply(w, 500, map[string]string{"error": "encoding failed"})
			return
		}
		etag := fmt.Sprintf("\"%x\"", sha256.Sum256(body))
		w.Header().Set("ETag", etag)
		w.Header().Set("Cache-Control", "no-cache")
		if r.Header.Get("If-None-Match") == etag {
			w.WriteHeader(304)
			return
		}
		w.WriteHeader(200)
		w.Write(body)
	})
}
func reply(w http.ResponseWriter, status int, value any) {
	w.WriteHeader(status)
	json.NewEncoder(w).Encode(value)
}
