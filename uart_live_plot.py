import sys
from collections import deque

import matplotlib.pyplot as plt
import serial

PORT = "/dev/cu.usbserial-20250303171"
BAUD = 115200
MAX_POINTS = 200

def main():
    try:
        ser = serial.Serial(PORT, BAUD, timeout=1)
    except Exception as e:
        print(f"Failed to open serial port {PORT}")
        print(e)
        sys.exit(1)

    print(f"Opened {PORT} @ {BAUD} baud")
    print("Press Ctrl+C or close the plot window to stop.")

    xs = deque(maxlen=MAX_POINTS)
    ys = deque(maxlen=MAX_POINTS)
    sample_idx = 0
    running = True

    plt.ion()
    fig, ax = plt.subplots()
    line, = ax.plot([], [])
    ax.set_title("Live UART Sine Wave")
    ax.set_xlabel("Sample")
    ax.set_ylabel("Value")
    ax.set_ylim(0, 4095)
    ax.grid(True)
    plt.show(block=False)

    def on_close(event):
        nonlocal running
        running = False

    fig.canvas.mpl_connect("close_event", on_close)

    try:
        while running:
            if not plt.fignum_exists(fig.number):
                break

            raw = ser.readline().decode("utf-8", errors="ignore").strip()
            if not raw:
                plt.pause(0.01)
                continue

            print("RAW:", raw)

            if len(raw) != 3:
                continue

            try:
                value = int(raw, 16)
            except ValueError:
                continue

            if value > 0xFFF:
                continue

            xs.append(sample_idx)
            ys.append(value)
            sample_idx += 1

            line.set_xdata(xs)
            line.set_ydata(ys)

            if len(xs) >= 2:
                ax.set_xlim(xs[0], xs[-1])
            elif len(xs) == 1:
                ax.set_xlim(xs[0], xs[0] + 1)

            fig.canvas.draw()
            fig.canvas.flush_events()
            plt.pause(0.01)

    except KeyboardInterrupt:
        print("\nStopped by user.")
    finally:
        ser.close()
        plt.close("all")
        print("Serial port closed.")

if __name__ == "__main__":
    main()