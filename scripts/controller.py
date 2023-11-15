import argparse
import ctypes
from sdl2 import *
import serial
import serial.tools.list_ports
import time

parser = argparse.ArgumentParser(
    prog="python controller.py",
    description="Send controls to the RavensRover Radio transmitter over UART",
)

parser.add_argument("--port", required=False, default=None)

args = parser.parse_args()

if args.port is None:
    args.port = serial.tools.list_ports.comports()[-1].device

# Init SDL for joystick input
SDL_Init(SDL_INIT_VIDEO | SDL_INIT_JOYSTICK)

with serial.Serial(args.port, 115200, timeout=2) as ser:
    try:
        device = None
        axises = {}

        def convert_axis(axis, double_neg=False):
            # Convert axis
            axis = axis / 32768
            # Some of these axises seems to be half when negative for some reason...
            if double_neg and axis < 0:
                axis *= 2

            # Impl deadzone
            if axis > 0.3 or axis < -0.3:
                return (axis * 0.7) + 0.3
            else:
                return 0

        while True:
            event = SDL_Event()
            while SDL_PollEvent(ctypes.byref(event)) != 0:
                if event.type == SDL_JOYDEVICEADDED:
                    device = SDL_JoystickOpen(event.jdevice.which)
                elif event.type == SDL_JOYAXISMOTION:
                    axises[event.jaxis.axis] = event.jaxis.value

            forward = 0
            right = 0
            rotation = 0

            if device is not None:
                right_trigger = SDL_JoystickGetAxis(device, 5)
                left_trigger = SDL_JoystickGetAxis(device, 4)
                left_joystick_x = SDL_JoystickGetAxis(device, 0)
                right_joystick_x = SDL_JoystickGetAxis(device, 2)
                forward = min(
                    max(int((right_trigger - left_trigger) * 4095), -4095), 4095
                )
                right = min(
                    max(
                        int(convert_axis(right_joystick_x, double_neg=True) * 4095),
                        -4095,
                    ),
                    4095,
                )
                rotation = min(
                    max(
                        int(convert_axis(left_joystick_x, double_neg=True) * 4095),
                        -4095,
                    ),
                    4095,
                )

            ser.write(
                b"\01"
                + forward.to_bytes(2, "little", signed=True)
                + right.to_bytes(2, "little", signed=True)
                + rotation.to_bytes(2, "little", signed=True)
            )
            ser.flush()

            time.sleep(1 / 30)
    except KeyboardInterrupt:
        # Stop move
        ser.write(b"\01\00\00\00\00\00\00")
        ser.flush()
