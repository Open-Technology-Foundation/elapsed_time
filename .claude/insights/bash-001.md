# Bash arithmetic patterns for microsecond timers

Three key patterns for efficient timer implementation:

1. **Scientific notation formatting**: `printf '%.3fs' "${remaining_us}e-6"` converts integer microseconds to formatted seconds without `bc`. Example: `123000e-6` becomes `0.123s` with 3-decimal precision.

2. **Nameref for zero-fork returns**: `local -n _result=$1` creates a nameref that writes directly into the caller's variable, avoiding subshell execution (`$()`) and eliminating `fork()` calls per conversion.

3. **Base-10 prefix**: Use `10#` to force base-10 interpretation of all numbers, preventing Bash from treating zero-padded values like `007` as octal, which causes errors with digits 8-9.

---
*/ai/scripts/DateTime/elapsed_time | session 9b9c6219 | 2026-03-20*
<!-- hash: 9e7d5fbd5b7189182149095aed2bf4dc -->
<!-- general: true -->
