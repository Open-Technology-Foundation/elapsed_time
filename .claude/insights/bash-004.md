# BCS1212 Makefile standards and best practices

BCS1212 key requirements for Makefiles:

- The `all` target must point to `help`, never to `install` — a bare `make` should never modify the system
- Use `install(1)` instead of `cp` + `chmod` for file installation
- The `check` target verifies installation but should skip execution when `DESTDIR` is set (needed for package building)
- Use the `?=` operator for path variables to allow users to override them from the command line without editing the Makefile (e.g., `make install PREFIX=/opt`)
- This enables flexible deployment across different environments and supports proper package building workflows

---
*/ai/scripts/DateTime/elapsed_time | session 9b9c6219 | 2026-03-20*
<!-- hash: fd2f3234c9f825d09592960fcf5db1d6 -->
<!-- general: true -->
