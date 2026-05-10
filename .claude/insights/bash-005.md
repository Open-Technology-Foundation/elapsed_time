# Avoid set -euo pipefail in Sourced Function Bodies

When a script is sourced (intended for dual-purpose use as both executable and library), never place `set -euo pipefail` inside function bodies. This permanently modifies the caller's shell environment with strict mode semantics. The caller may not expect `set -e` to activate, causing unexpected failures in their subsequent code. Instead, apply strict mode only at the top level of executable scripts, or use subshells `(set -euo pipefail; ...)` to isolate the effect. For sourced libraries, let the caller control shell options.

---
*/ai/scripts/DateTime/elapsed_time | session 78cf6d0a | 2026-03-20*
<!-- hash: 0978fb1721c1c81868e077c8099b7c9f -->
<!-- general: true -->
