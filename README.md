# elapsed_time

Utility functions for formatting elapsed time durations in a human-readable format. Available in both Python and Bash.

## Features

- Format time durations with intelligent unit display
- Automatically shows/hides days, hours, minutes based on duration
- Always displays seconds with millisecond precision
- Zero dependencies in both implementations
- Can be imported as a module or used directly

## Usage

### Python

```python
import time
from elapsed_time import elapsed_time

# Start timing
start = time.perf_counter()

# Do something...
time.sleep(1.5)  # Simulate work

# Print elapsed time
print(elapsed_time(start))  # Output: "01.500s"

# Or with explicit start/end times
print(elapsed_time(0, 3661.123))  # Output: "01h 01m 01.123s"
```

### Bash

```bash
# directly from command line
elapsed_time 0 3661.123  # Output: "01h 01m 01.123s"

# OR import the function
source elapsed_time.sh

# Start timing
start=$(date +%s.%N)

# Do something...
sleep 1.5  # Simulate work

# Print elapsed time
elapsed_time "$start"  # Output: "01.500s"

```

## Installation

Copy the files to your project directory or add this repository to your path.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.

