import time

def elapsed_time(start_time, end_time=None):
  """
  start = time.perf_counter()
  time.sleep(3661.123)  # 1 hour, 1 minute, 1.123 seconds
  print(elapsed_time(start))  # Output: "01h 01m 01.123s"
  """

  # Use current time if end_time not provided
  if end_time is None:
    end_time = time.perf_counter()
  
  # Calculate total seconds
  elapsed = end_time - start_time
  
  # Initialize empty list for time components
  parts = []
  
  # Calculate days
  days = int(elapsed // 86400)
  if days:
    parts.append(f"{days}d")
    elapsed %= 86400
  
  # Calculate hours
  hours = int(elapsed // 3600)
  if hours or days:  # Show hours if we have days
    parts.append(f"{hours:02}h")
    elapsed %= 3600
  
  # Calculate minutes
  minutes = int(elapsed // 60)
  if minutes or hours or days:  # Show minutes if we have hours/days
    parts.append(f"{minutes:02}m")
    elapsed %= 60
  
  # Always show seconds
  parts.append(f"{elapsed:06.3f}s")
  
  return " ".join(parts)

#fin
