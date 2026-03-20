# Bash Audit Report: elapsed_time.sh

**Date**: 2026-03-20
**Auditor**: Leet (Claude Opus 4.6)
**Standard**: BCS (Bash Coding Standard) — strict mode
**Script**: `elapsed_time.sh` (64 lines, 1 function)

---

## Executive Summary

| Metric | Value |
|--------|-------|
| **Overall Health Score** | **4/10** |
| **ShellCheck** | PASS (0 warnings) |
| **BCS Violations** | 20 |
| **Critical Issues** | 3 |
| **High Issues** | 5 |
| **Medium Issues** | 8 |
| **Low Issues** | 4 |

The script is functionally correct and ShellCheck-clean, but has **serious architectural flaws** in its dual-purpose structure. The most dangerous issue is `set -euo pipefail` inside the function body, which permanently alters the calling shell's error handling when sourced. The argument parsing is fragile and non-standard.

---

## Tool Results

### ShellCheck
```
shellcheck -x elapsed_time.sh
# Result: PASS — 0 warnings, 0 errors
```

### BCS Check
```
bcscheck elapsed_time.sh
# Result: 20 VIOLATIONS (strict mode)
```

---

## Findings by Severity

### Critical (3)

#### C1. `set -euo pipefail` inside function body pollutes sourcing shell
- **Location**: `elapsed_time.sh:9`
- **BCS Code**: BCS0101, BCS0106
- **Description**: When sourced, calling `elapsed_time()` permanently enables `set -euo pipefail` in the caller's shell. This is the most dangerous pattern in dual-purpose scripts — the caller may not expect strict mode to suddenly activate, causing mysterious failures in unrelated code.
- **Impact**: Silent corruption of calling shell's error handling behavior
- **Recommendation**: Move strict mode to script-mode section only:
```bash
elapsed_time() {
  # NO set -euo pipefail here
  local -- end_time
  end_time=${2:-$(date +%s.%N)}
  # ...
}
declare -fx elapsed_time

[[ ${BASH_SOURCE[0]} == "$0" ]] || return 0

# --- Script mode only below ---
set -euo pipefail
shopt -s inherit_errexit
```

#### C2. Dual-purpose structure is inverted
- **Location**: `elapsed_time.sh:44`
- **BCS Code**: BCS0106
- **Description**: The source guard uses `if [[ ... == "$0" ]]; then` at the bottom, wrapping the invocation in a block. BCS requires the canonical `|| return 0` early-exit pattern, which cleanly separates sourced vs executed paths.
- **Impact**: Structural confusion; strict mode pollution (see C1)
- **Recommendation**: Use `[[ ${BASH_SOURCE[0]} == "$0" ]] || return 0` after function definitions, then place all script-mode logic below it without nesting.

#### C3. Arithmetic false exits under `set -e`
- **Location**: `elapsed_time.sh:45, 57`
- **BCS Code**: BCS0606
- **Description**: `(($#==0))` evaluates to false (exit code 1) when arguments are provided, which under `set -e` would terminate the script. Similarly `(($#)) && exit 0` fails when `$#==0`. The current code survives only because the `||` and `&&` chains mask the exit code — but this is fragile and breaks if restructured.
- **Impact**: Script termination on valid input if code is refactored
- **Recommendation**: Use `||:` guard or restructure with explicit `if`:
```bash
if (($# == 0)) || [[ ${1-} == '-h' || ${1-} == '--help' ]]; then
  # show help
fi
```

---

### High (5)

#### H1. Missing `shopt -s inherit_errexit`
- **Location**: (absent)
- **BCS Code**: BCS0101
- **Description**: `inherit_errexit` is mandatory per BCS. Without it, command substitutions inside the function do not inherit `set -e`, meaning `bc` failures inside `$(...)` are silently ignored.
- **Impact**: `bc` errors (e.g., from invalid input) silently produce empty/wrong values
- **Recommendation**: Add `shopt -s inherit_errexit` after `set -euo pipefail` in script-mode section.

#### H2. No script metadata
- **Location**: (absent)
- **BCS Code**: BCS0103
- **Description**: Missing `VERSION`, `SCRIPT_NAME`, `SCRIPT_DIR`, `SCRIPT_PATH` declarations.
- **Impact**: No version introspection; `--version` cannot be implemented; `basename` used instead of `$SCRIPT_NAME`
- **Recommendation**:
```bash
declare -r VERSION='1.0.0'
declare -r SCRIPT_NAME="${0##*/}"
```

#### H3. No PATH hardening
- **Location**: (absent)
- **BCS Code**: BCS1002
- **Description**: Script uses external commands (`bc`, `date`, `cat`, `basename`) without locking PATH.
- **Impact**: PATH injection risk — a malicious `bc` or `date` in PATH could be executed
- **Recommendation**: Add `declare -rx PATH='/usr/bin:/bin'` in script-mode section.

#### H4. Combined declare + command substitution masks exit code
- **Location**: `elapsed_time.sh:11`
- **BCS Code**: BCS0201, SC2155
- **Description**: `local -- end_time=${2:-"$(date +%s.%N)"}` — if `date` fails, the exit code is masked by `local`'s success.
- **Impact**: Silent failure if `date` command fails
- **Recommendation**: Split declaration and assignment:
```bash
local -- end_time
end_time=${2:-$(date +%s.%N)}
```

#### H5. Function not exported for sourcing use
- **Location**: `elapsed_time.sh:41`
- **BCS Code**: BCS0404
- **Description**: `elapsed_time` is not exported with `declare -fx`. When sourced, child subshells won't inherit the function.
- **Impact**: Function unavailable in subshells after sourcing
- **Recommendation**: Add `declare -fx elapsed_time` after the closing `}`.

---

### Medium (8)

#### M1–M4. printf format strings use double quotes
- **Locations**: `elapsed_time.sh:20, 27, 34, 39`
- **BCS Code**: BCS0305
- **Description**: Format strings like `"%dd "`, `"%02dh "`, `"%02dm "`, `"%.3fs"` should use single quotes since they contain no variable expansions. Double quotes mislead readers into expecting expansion.
- **Recommendation**: `printf '%dd ' "$days"`, `printf '%02dh ' "$hours"`, etc.

#### M5. Non-standard argument parsing
- **Location**: `elapsed_time.sh:45–59`
- **BCS Code**: BCS0801
- **Description**: Uses a fragile `(($#==0)) || [[ ... ]] && { ... }` chain instead of the standard `while (($#)); do case $1 in ... esac; shift; done` pattern.
- **Impact**: Cannot be extended with new options; hard to read; fragile under `set -e`
- **Recommendation**: Replace with canonical while-case loop:
```bash
while (($#)); do
  case $1 in
    -h|--help)    show_help; exit 0 ;;
    -V|--version) echo "$SCRIPT_NAME $VERSION"; exit 0 ;;
    --)           shift; break ;;
    -*)           die 22 "Invalid option ${1@Q}" ;;
    *)            break ;;
  esac
  shift
done
```

#### M6. Missing `--version` / `-V` option
- **Location**: (absent)
- **BCS Code**: BCS0806
- **Description**: No version output option. BCS requires `-V`/`--version` support.
- **Recommendation**: Add to argument parsing (see M5).

#### M7. Bare `echo` for newline amid printf output
- **Location**: `elapsed_time.sh:40`
- **BCS Code**: BCS1205
- **Description**: Mixing `printf` and bare `echo` for output. `echo` is less portable and inconsistent with the surrounding `printf` calls.
- **Recommendation**: `printf '\n'`

#### M8. Unquoted heredoc delimiter
- **Location**: `elapsed_time.sh:46`
- **BCS Code**: BCS0304
- **Description**: `<<-EOT` without quoting the delimiter. The body uses manual `\$` escapes to prevent expansion, but quoting the delimiter (`<<-'EOT'`) is the standard approach that eliminates the need for escapes.
- **Recommendation**: `<<-'EOT'` and remove `\` escapes from body.

---

### Low (4)

#### L1. `$(basename -- "$0")` forks external process
- **Location**: `elapsed_time.sh:47`
- **BCS Code**: BCS1205
- **Description**: Spawning `basename` when `${0##*/}` (or `$SCRIPT_NAME`) achieves the same result with a bash builtin.
- **Recommendation**: Use `${0##*/}` or declare `SCRIPT_NAME` in metadata.

#### L2. Integer variables declared as strings
- **Location**: `elapsed_time.sh:14`
- **BCS Code**: BCS0201
- **Description**: `days`, `hours`, `minutes` are initialized as `'0'` (quoted strings) with `local --` instead of `local -i`.
- **Recommendation**: `local -i days=0 hours=0 minutes=0`

#### L3. No `die()` error handler
- **Location**: (absent)
- **BCS Code**: BCS1211
- **Description**: No `die()` function for fatal error handling. Currently, invalid input just produces `bc` errors with no user-friendly message.
- **Recommendation**: Add minimal `die()`:
```bash
die() { local -- code=$1; shift; printf '%s: %s\n' "$SCRIPT_NAME" "$*" >&2; exit "$code"; }
```

#### L4. No input validation on start_time/end_time
- **Location**: `elapsed_time.sh:11`
- **BCS Code**: BCS1005
- **Description**: Arguments are passed directly to `bc` without validation. Non-numeric input produces cryptic `bc` errors rather than a helpful message.
- **Recommendation**: Validate numeric input before arithmetic:
```bash
[[ $start_time =~ ^[0-9]+\.?[0-9]*$ ]] || die 22 "Invalid start time ${start_time@Q}"
```

---

## Recommended Rewrite Structure

```bash
#!/bin/bash
# elapsed_time: Format time duration as human-readable string

# --- Function (safe to source) ---

elapsed_time() {
  local -- end_time start_time
  start_time="${1:-0}"
  end_time=${2:-$(date +%s.%N)}

  local -i days=0 hours=0 minutes=0
  local -- elapsed
  elapsed=$(printf '%s - %s\n' "$end_time" "$start_time" | bc --mathlib)

  days=$(printf '%s / 86400\n' "$elapsed" | bc)
  if ((days > 0)); then
    printf '%dd ' "$days"
    elapsed=$(printf '%s - (86400 * %s)\n' "$elapsed" "$days" | bc)
  fi

  hours=$(printf '%s / 3600\n' "$elapsed" | bc)
  if ((hours > 0 || days > 0)); then
    printf '%02dh ' "$hours"
    elapsed=$(printf '%s - (3600 * %s)\n' "$elapsed" "$hours" | bc)
  fi

  minutes=$(printf '%s / 60\n' "$elapsed" | bc)
  if ((minutes > 0 || hours > 0 || days > 0)); then
    printf '%02dm ' "$minutes"
    elapsed=$(printf '%s - (60 * %s)\n' "$elapsed" "$minutes" | bc)
  fi

  printf '%.3fs\n' "$elapsed"
}
declare -fx elapsed_time

[[ ${BASH_SOURCE[0]} == "$0" ]] || return 0

# --- Script mode only ---
set -euo pipefail
shopt -s inherit_errexit

declare -r VERSION='1.0.0'
declare -r SCRIPT_NAME="${0##*/}"

die() { local -- code=$1; shift; printf '%s: %s\n' "$SCRIPT_NAME" "$*" >&2; exit "$code"; }

show_help() {
  cat <<-'EOT'
usage: elapsed_time start_time [end_time]

Examples:
  start=$(date +%s.%N)   # capture start time
  # do something...
  elapsed_time "$start"  # automatic end time

  # explicit start/end times:
  elapsed_time 0 3661.123  # Output: "01h 01m 01.123s"
EOT
}

while (($#)); do
  case $1 in
    -h|--help)    show_help; exit 0 ;;
    -V|--version) echo "$SCRIPT_NAME $VERSION"; exit 0 ;;
    --)           shift; break ;;
    -*)           die 22 "Invalid option ${1@Q}" ;;
    *)            break ;;
  esac
  shift
done

(($#)) || { show_help >&2; exit 1; }

elapsed_time "$@"

#fin
```

---

## Quick Wins

1. **Move `set -euo pipefail` out of function** — eliminates the most dangerous bug
2. **Add `declare -fx elapsed_time`** — one line, enables subshell inheritance
3. **Single-quote printf formats** — find/replace, no logic change
4. **Replace `echo` with `printf '\n'`** — one character change

## Long-term Recommendations

1. **Restructure as canonical dual-purpose script** — eliminates 5 violations at once
2. **Replace `bc` with pure bash arithmetic** — removes external dependency, improves performance (though loses sub-second precision without `bc`)
3. **Add input validation** — protects against cryptic `bc` errors
4. **Implement standard argument parsing** — enables future extensibility

---

*Report generated by BCS audit methodology. ShellCheck v0.10+ and bcscheck used for automated analysis.*

#fin
