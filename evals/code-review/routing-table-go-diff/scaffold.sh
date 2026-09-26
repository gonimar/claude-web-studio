#!/bin/bash
set -euo pipefail
bash "$(dirname "$0")/../../_lib/story-fixture.sh" happy
G='git -c user.email=e2e@test -c user.name=e2e'
git switch -q -c feat/S-002-forecast-days
cat > forecast.go <<'EOS'
package main

import (
	"encoding/json"
	"net/http"
	"strconv"
)

func forecastDays(w http.ResponseWriter, r *http.Request) {
	city := r.URL.Query().Get("city")
	days, err := strconv.Atoi(r.URL.Query().Get("days"))
	if err != nil || days < 1 || days > 7 || city == "" {
		w.WriteHeader(http.StatusBadRequest)
		json.NewEncoder(w).Encode(map[string]string{"error": "invalid city or days"})
		return
	}
	out := map[string]any{"city": city, "days": make([]map[string]any, 0, days)}
	for i := 1; i <= days; i++ {
		out["days"] = append(out["days"].([]map[string]any), map[string]any{"day": i, "forecast": "sunny", "temp_c": 20 + i})
	}
	json.NewEncoder(w).Encode(out)
}
EOS
cat > forecast_test.go <<'EOS'
package main

import (
	"net/http"
	"net/http/httptest"
	"testing"
)

func TestForecastDays(t *testing.T) {
	for _, tc := range []struct{ q string; want int }{{"city=Oslo&days=3", 200}, {"city=&days=3", 400}, {"city=Oslo&days=9", 400}} {
		rec := httptest.NewRecorder()
		forecastDays(rec, httptest.NewRequest(http.MethodGet, "/forecast?"+tc.q, nil))
		if rec.Code != tc.want {
			t.Errorf("%s: got %d want %d", tc.q, rec.Code, tc.want)
		}
	}
}
EOS
$G add forecast.go forecast_test.go && $G commit -qm 'feat(S-002): multi-day forecast handler'
