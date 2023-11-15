import argparse
import mido
import serial
import serial.tools.list_ports
import time

parser = argparse.ArgumentParser(
    prog="python play.py",
    description="Transmit the notes of a mid file!",
)

parser.add_argument("midi")
parser.add_argument("--port", required=False, default=None)
parser.add_argument("--channel", required=False, default=None)

args = parser.parse_args()

# Auto select serial port
if args.port is None:
    args.port = serial.tools.list_ports.comports()[-1].device

wanted_channel = int(args.channel) if args.channel is not None else None

WAIT_TIME = 1 / 200

with serial.Serial(args.port, 115200, timeout=2) as ser:
    try:
        mid = mido.MidiFile(args.midi)
        channel = None
        last_note = 0
        for msg in mid.play():
            t = time.monotonic()

            if msg.type == "note_off" and msg.channel == channel:
                channel = None
                ser.write(b"\02\00\00\00\00\00\00")
                ser.flush()
                time.sleep(WAIT_TIME)
            elif (
                msg.type == "note_on"
                and (wanted_channel is None or msg.channel == wanted_channel)
                and msg.velocity != 0
            ):
                # Convert midi freq
                a = 440
                freq = int((a / 32) * (2 ** ((msg.note - 9) / 12)))

                volume = 10 + msg.velocity * 3
                ser.write(
                    b"\02"
                    + freq.to_bytes(2, "little")
                    + volume.to_bytes(2, "little")
                    + b"\00\00"
                )
                ser.flush()
                channel = msg.channel
                last_note = t
                time.sleep(WAIT_TIME)

            print(msg)

    except KeyboardInterrupt:
        # Stop tone
        time.sleep(WAIT_TIME * 2)
        ser.write(b"\02\00\00\00\00\00\00")
        ser.flush()
