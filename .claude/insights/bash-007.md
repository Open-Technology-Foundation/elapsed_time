# Canonical dual-purpose bash script pattern

Structure bash scripts with the canonical dual-purpose pattern: define functions first (safe to source), then use `[[ ${BASH_SOURCE[0]} == "$0" ]] || return 0` as a firewall to separate sourced vs. script-mode execution. Place script-mode-only code below the firewall. This ensures `set -euo pipefail` only activates when run as a script, not when sourced as a library. Use `declare -fx` to export functions, making them available to subshells — essential for contexts like `xargs`, `parallel`, or `bash -c` invocations.

---
*/ai/scripts/DateTime/elapsed_time | session 78cf6d0a | 2026-03-20*
<!-- hash: 567607ee42b163ff19243bec57a2d6cc -->
<!-- general: true -->
