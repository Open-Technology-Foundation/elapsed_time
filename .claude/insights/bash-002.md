# Bash performance: namerefs eliminate fork overhead

Each `$()` subshell triggers a `fork()` — an OS-level process creation. Using `local -n` namerefs instead lets you write directly into the caller's variable, eliminating subprocess overhead. For example, replacing 7 `bc` calls with nameref patterns reduces fork count from 14 (7 for `$()` + 7 for `bc`) to zero. Additionally, Bash's `printf` understands C-style scientific notation, so you can perform all arithmetic in integers and convert to decimal only at display time using patterns like `"${remaining_us}e-6"` with `printf '%.3fs'`. This keeps math operations fast and separates integer computation from decimal formatting.

---
*/ai/scripts/DateTime/elapsed_time | session 9b9c6219 | 2026-03-20*
<!-- hash: 4193bcaec8458688381d94f2ac6f4b12 -->
<!-- general: true -->
