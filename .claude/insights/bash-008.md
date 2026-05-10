# EPOCHREALTIME built-in beats date command for performance

Bash 5.0+ provides `$EPOCHREALTIME`, a built-in variable that reads the current Unix epoch time without fork overhead. Benchmarks show ~337x faster performance than `date +%s.%N` (1000 reads: 0.003s vs 1.012s) because `date` requires fork+exec for every invocation.

Precision comparison:
- `date +%s.%N` → 9 decimal places (nanoseconds): `1773966926.502062051`
- `$EPOCHREALTIME` → 6 decimal places (microseconds): `1773966926.501042`

Both use the same Unix epoch base and are interchangeable as arguments. When display precision is limited (e.g., 3 decimal places for milliseconds), the extra nanosecond precision from `date` provides no practical benefit. Use `$EPOCHREALTIME` for elapsed time calculations and performance-sensitive contexts.

---
*/ai/scripts/DateTime/elapsed_time | session 78cf6d0a | 2026-03-20*
<!-- hash: bf960439239d611a51a8a1d003745cd6 -->
<!-- general: true -->
