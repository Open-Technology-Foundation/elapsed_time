# Dual-purpose Bash scripts with sourcing firewalls

The pattern `[[ ${BASH_SOURCE[0]} == "$0" ]] || return 0` creates a clean firewall between sourceable code and script-only code. Code above this line executes safely when sourced (in the caller's context), while code below only runs when the script is executed directly. This distinction is critical for reusable Bash libraries because function scope runs in the caller's context when sourced, making this idiom essential for managing side effects and initialization logic.

---
*/ai/scripts/DateTime/elapsed_time | session 78cf6d0a | 2026-03-20*
<!-- hash: f3d603e9aea3ac9a3767cfcd3868c801 -->
<!-- general: true -->
