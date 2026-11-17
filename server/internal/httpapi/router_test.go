package httpapi

import (
	"context"
	"encoding/json"
	"github.com/lipskakira95-oss/DiaMuKira/server/internal/catalog"
	"net/http"
	"net/http/httptest"
	"path/filepath"
	"testing"
)

func TestRoutes(t *testing.T) {
	store, err := catalog.Open(filepath.Join(t.TempDir(), "test.sqlite"))
	if err != nil {
		t.Fatal(err)
	}
	defer store.Close()
	rows := []catalog.Question{{ID: "q1", CategoryID: "children", CategoryName: "Діти", RoundNumber: 1, RoundTitle: "Повага", Position: 1, Text: "Чи варто слухати?", CorrectAnswer: true, Explanation: "Повага важлива.", Status: "draft", Source: "author_draft", ContentVersion: "draft-1"}}
	if err = store.Replace(context.Background(), rows, false); err != nil {
		t.Fatal(err)
	}
	handler := New(store, false)
	for _, tc := range []struct {
		method, path string
		code         int
	}{{"GET", "/health", 200}, {"GET", "/api/v1/content", 200}, {"GET", "/api/v1/content/version", 200}, {"POST", "/api/v1/content", 405}, {"GET", "/api/unknown", 404}} {
		rec := httptest.NewRecorder()
		handler.ServeHTTP(rec, httptest.NewRequest(tc.method, tc.path, nil))
		if rec.Code != tc.code {
			t.Fatalf("%s %s got %d", tc.method, tc.path, rec.Code)
		}
		var body map[string]any
		if err = json.Unmarshal(rec.Body.Bytes(), &body); err != nil {
			t.Fatal(err)
		}
	}
	production := httptest.NewRecorder()
	New(store, true).ServeHTTP(production, httptest.NewRequest("GET", "/api/v1/content", nil))
	if production.Code != http.StatusServiceUnavailable {
		t.Fatal("production served draft data")
	}
	first := httptest.NewRecorder()
	handler.ServeHTTP(first, httptest.NewRequest("GET", "/api/v1/content", nil))
	etag := first.Header().Get("ETag")
	if etag == "" {
		t.Fatal("missing ETag")
	}
	req := httptest.NewRequest("GET", "/api/v1/content", nil)
	req.Header.Set("If-None-Match", etag)
	cached := httptest.NewRecorder()
	handler.ServeHTTP(cached, req)
	if cached.Code != 304 || cached.Body.Len() != 0 {
		t.Fatal("conditional GET failed")
	}
}
