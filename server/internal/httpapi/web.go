package httpapi

import (
	"net/http"
	"path"
	"path/filepath"
	"strings"
)

// WithCORS enables only the explicitly configured development origin.
func WithCORS(next http.Handler, allowedOrigin string) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		origin := r.Header.Get("Origin")
		if origin != "" {
			w.Header().Add("Vary", "Origin")
			if allowedOrigin == "" || origin != allowedOrigin {
				w.Header().Set("Content-Type", "application/json")
				reply(w, 403, map[string]string{"error": "origin not allowed"})
				return
			}
			w.Header().Set("Access-Control-Allow-Origin", origin)
			w.Header().Set("Access-Control-Expose-Headers", "ETag")
			if r.Method == http.MethodOptions {
				w.Header().Set("Access-Control-Allow-Methods", "GET")
				w.Header().Set("Access-Control-Allow-Headers", "If-None-Match")
				w.WriteHeader(http.StatusNoContent)
				return
			}
		}
		next.ServeHTTP(w, r)
	})
}

// WithWeb serves a compiled Flutter app alongside the API on one origin.
func WithWeb(api http.Handler, root string) http.Handler {
	files := http.FileServer(http.Dir(root))
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if strings.HasPrefix(r.URL.Path, "/api/") || r.URL.Path == "/health" {
			api.ServeHTTP(w, r)
			return
		}
		if r.Method != http.MethodGet && r.Method != http.MethodHead {
			http.Error(w, "method not allowed", 405)
			return
		}
		file, err := http.Dir(root).Open(r.URL.Path)
		if err == nil {
			info, statErr := file.Stat()
			file.Close()
			if statErr == nil && !info.IsDir() {
				files.ServeHTTP(w, r)
				return
			}
		}
		if path.Ext(r.URL.Path) != "" {
			http.NotFound(w, r)
			return
		}
		http.ServeFile(w, r, filepath.Join(root, "index.html"))
	})
}
