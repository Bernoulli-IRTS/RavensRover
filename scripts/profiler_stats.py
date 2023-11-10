import argparse
import collections
import json
import pandas as pd
import numpy as np

parser = argparse.ArgumentParser(
    prog="python profiler_stats.py",
    description="Get stats from Perfetto tracings",
)

parser.add_argument("trace")
parser.add_argument("--csv", help="save as csv instead of printing", default=None)

args = parser.parse_args()


class Task:
    def __init__(self) -> None:
        self.starts = []
        self.durs = []

    def add_event(self, event):
        assert event["ph"] == "X"

        self.starts.append(event["ts"] / 1000)
        self.durs.append(event["dur"] / 1000)


tasks = collections.defaultdict(Task)

# Open trace file
with open(args.trace, "r") as f:
    data = json.load(f)

    # Add all event to tasks
    for event in data["traceEvents"]:
        tasks[event["name"]].add_event(event)

    columns = [
        "Mean compute time",
        "Best compute time",
        "Worst compute time",
        "Compute time jitter (diff)",
        "Mean period",
        "Shortest period",
        "Longest period",
        "Period jitter (diff)",
    ]
    table = []
    index = []

    # Generate statistics for every task
    for name, task in tasks.items():
        index.append(name)
        periods = np.diff(task.starts)

        table.append(
            [
                np.mean(task.durs),  # Mean compute time
                np.min(task.durs),  # Best compute time
                np.max(task.durs),  # Worst compute time
                np.max(task.durs) - np.min(task.durs),  # Compute time jitter
                np.mean(periods),  # Mean period
                np.min(periods),  # Shortest period
                np.max(periods),  # Longest period
                np.max(periods) - np.min(periods),  # Period jitter
            ]
        )

    # Create dataframe with data
    df = pd.DataFrame(table, columns=columns, index=index).round(2)

    # Allow to export to CSV
    if args.csv is not None:
        df.to_csv(args.csv)
    else:
        print(df)
