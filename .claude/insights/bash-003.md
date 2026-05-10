# Bash Inner Functions Provide API Encapsulation Not Scoping

Bash inner functions aren't truly scoped — `_to_us()` is redefined in the global function table each time `elapsed_time()` runs, but it's not exported (`declare -fx`), so it won't appear in subshells or other scripts that source the file. The key benefit here is API surface: sourcing the file exposes exactly one function name. This provides logical encapsulation and a clean public interface, even though the inner function technically exists in the global namespace.

---
*/ai/scripts/DateTime/elapsed_time | session 9b9c6219 | 2026-03-20*
<!-- hash: 78c90c9ea2a4942e75035ad7b12d1829 -->
<!-- general: true -->
