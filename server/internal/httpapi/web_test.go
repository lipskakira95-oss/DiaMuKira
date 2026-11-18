package httpapi

import (
	"net/http"
	"net/http/httptest"
	"os"
	"path/filepath"
	"testing"
)

func TestCORS(t *testing.T) {
	api := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) { w.Write([]byte("api")) })
	handler := WithCORS(api, "http://localhost:5173")
	for _, tc := range []struct {
		origin, method string
		status         int
	}{{"http://localhost:5173", "GET", 200}, {"http://localhost:5173", "OPTIONS", 204}, {"https://untrusted.example", "GET", 403}, {"", "GET", 200}} {
		request := httptest.NewRequest(tc.method, "/api/v1/content", nil)
		request.Header.Set("Origin", tc.origin)
		response := httptest.NewRecorder()
		handler.ServeHTTP(response, request)
		if response.Code != tc.status {
			t.Fatalf("%s %s: %d", tc.method, tc.origin, response.Code)
		}
		if tc.origin == "http://localhost:5173" && response.Header().Get("Access-Control-Allow-Origin") != tc.origin {
			t.Fatal("missing allowed origin")
		}
		if tc.origin == "https://untrusted.example" && response.Header().Get("Access-Control-Allow-Origin") != "" {
			t.Fatal("untrusted origin allowed")
		}
	}
}

func TestWebFallbackDoesNotSwallowAPIOrMissingAssets(t *testing.T) {
	root := t.TempDir()
	os.WriteFile(filepath.Join(root, "index.html"), []byte("quiz-shell"), 0600)
	api := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(404)
		w.Write([]byte(`{"error":"not found"}`))
	})
	handler := WithWeb(api, root)
	for _, tc := range []struct {
		path   string
		status int
		body   string
	}{{"/categories/children", 200, "quiz-shell"}, {"/api/unknown", 404, `{"error":"not found"}`}, {"/missing.js", 404, ""}} {
		rec := httptest.NewRecorder()
		handler.ServeHTTP(rec, httptest.NewRequest("GET", tc.path, nil))
		if rec.Code != tc.status {
			t.Fatalf("%s: %d", tc.path, rec.Code)
		}
		if tc.body != "" && rec.Body.String() != tc.body {
			t.Fatalf("%s body %s", tc.path, rec.Body.String())
		}
	}
}

func TestWebEnablesPersistentSQLiteIsolationHeaders(t *testing.T) {
	root := t.TempDir()
	os.WriteFile(filepath.Join(root, "index.html"), []byte("quiz-shell"), 0600)
	handler := WithWeb(http.NotFoundHandler(), root)
	recorder := httptest.NewRecorder()
	handler.ServeHTTP(recorder, httptest.NewRequest("GET", "/", nil))

	if got := recorder.Header().Get("Cross-Origin-Opener-Policy"); got != "same-origin" {
		t.Fatalf("Cross-Origin-Opener-Policy = %q", got)
	}
	if got := recorder.Header().Get("Cross-Origin-Embedder-Policy"); got != "require-corp" {
		t.Fatalf("Cross-Origin-Embedder-Policy = %q", got)
	}
}
