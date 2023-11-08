import argparse
import io
import json
import serial

parser = argparse.ArgumentParser(
    prog="python profiler.py",
    description="Create Perfetto tracings from data over serial",
)

parser.add_argument("serial_port")
parser.add_argument("trace_out")

args = parser.parse_args()

events = []
last_start = 0

try:
    with serial.Serial(args.serial_port, 115200, timeout=0.5) as ser:
        while True:
            line = ser.readline()
            # Check if tracing line
            if line.startswith(b"\x05"):
                parts = line.split(b"\x00")
                try:
                    # Crude manual parsing
                    task = parts[0][1:].decode("utf-8")
                    start = int(parts[1][1:])
                    dur = int(parts[2][1:-2])

                    # Clear on resets (100ms window)
                    if last_start > (start + 100_000):
                        events.clear()
                    last_start = start

                    events.append(
                        {
                            "name": task,
                            "ts": start,
                            "dur": dur,
                            "ph": "X",
                            "pid": "RavensRover",
                            "tid": task,
                        }
                    )
                except:
                    # Ignore the few corrupt readings on reset
                    pass
            else:
                print(line)
except KeyboardInterrupt:
    with open(args.trace_out, "w") as out:
        out.write(
            json.dumps(
                {
                    "traceEvents": events,
                    "displayTimeUnit": "ms",
                    "otherData": {"program": "RavensRover"},
                }
            )
        )
