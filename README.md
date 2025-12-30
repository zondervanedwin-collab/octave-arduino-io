# octave-arduino-io

**A minimal, transparent Octave ↔ Arduino I/O interface based on serial communication.**

`octave-arduino-io` provides a clean and robust way to control **Arduino digital and analog I/O directly from GNU Octave**, without relying on the fragile and board-limited Octave `arduino()` package.

> **Octave handles logic and control.**  
> **Arduino handles hardware.**  
> **Communication is explicit and transparent.**

---

## Motivation

In control and numerical methods education, the boundary between **algorithms** and **hardware** should be visible and understandable.

Existing Arduino–Octave integrations often:
- rely on hidden firmware,
- obscure the communication layer,
- or break easily across boards and operating systems.

This project was created to provide:
- a **minimal and inspectable** hardware interface,
- explicit serial communication,
- and a teaching-friendly structure that mirrors real industrial control systems.

---

## Architecture overview

```
Octave (PC)            Arduino (microcontroller)
------------------------------------------------
Control logic     -->  Serial commands
Timing            -->  Hardware I/O
Data processing   <--  Sensor values
```

- Octave performs **logic, control, and computation**
- Arduino performs **direct hardware access**
- Communication is **explicit, binary, and transparent**

---

## Features

- Digital output (`digitalWrite`)
- Digital input (`digitalRead`)
- Analog input (`analogRead`)
- PWM output (`analogWrite`)
- Explicit `pinMode`
- Binary serial protocol (fast and reliable)
- Single serial connection per board
- Robust across unplug / replug / restart
- Depends only on `instrument-control` (Octave)

---

## Supported hardware

Tested and working on:

- Arduino Uno (including CH340 clones)
- Arduino MKR WiFi 1010

Likely compatible with:

- Any Arduino-compatible board exposing USB serial

---

## Repository structure

```
octave-arduino-io/
├── firmware/
│   └── octave_arduino_io.ino
├── octave/
│   ├── arduino_init.m
│   ├── open_arduino_serial.m
│   ├── dwrite.m
│   ├── dread.m
│   ├── aread.m
│   ├── pinmode.m
│   ├── analogwrite.m
│   ├── writeDigitalPin.m   (optional alias)
│   └── readDigitalPin.m    (optional alias)
├── examples/
│   ├── blink_builtin_led.m
│   ├── pwm_fade.m
│   └── pot_to_pwm.m
└── README.md
```

---

## Installation

### 1. Arduino side

1. Open the Arduino IDE  
2. Load the firmware:

   ```
   firmware/octave_arduino_io.ino
   ```

3. Select the correct board and port  
4. Upload the sketch  

⚠️ Close the Arduino Serial Monitor after uploading.

The firmware is stored in flash and **persists across power cycles and reboots**.

---

### 2. Octave side

Ensure the required package is installed:

```octave
pkg install -forge instrument-control   % once
pkg load instrument-control
```

Add the `octave/` directory to your Octave path, or work from that directory.

---

## Automatic initialization (recommended)

To make the interface robust across:
- unplugging / replugging,
- Octave restarts,
- system reboots,

the package provides an automatic initialization routine.

### Initialization function

`arduino_init.m`:

- scans available serial ports,
- selects a USB/ACM device (typical for Arduino),
- opens the serial connection,
- waits for the Arduino reset,
- flushes startup bytes.

No hard-coded `/dev/ttyUSB0` or `/dev/ttyACM0` is required.

---

### Usage

```octave
s = arduino_init();
```

The default baud rate is **115200**, matching the firmware.

---

### Conceptual behavior of `arduino_init`

```
1. Detect available serial ports
2. Select an Arduino-like port (ttyUSB / ttyACM)
3. Open the serial connection
4. Wait for Arduino reset
5. Flush any startup data
```

The behavior is explicit and predictable — no hidden heuristics.

---

### Manual port selection (optional)

For debugging or advanced use:

```octave
serialportlist
s = open_arduino_serial("/dev/ttyUSB1", 115200);
```

---

## Built-in LED (Arduino Uno)

On the **Arduino Uno**, the built-in LED is connected to **digital pin 13**.

```octave
LED_BUILTIN = 13;

s = arduino_init();
pinmode(s, LED_BUILTIN, "output");

for k = 1:10
  dwrite(s, LED_BUILTIN, 1); pause(1);
  dwrite(s, LED_BUILTIN, 0); pause(1);
end

clear s
```

---

## Digital I/O

### Digital write

```octave
pinmode(s, 12, "output");
dwrite(s, 12, 1);   % HIGH
dwrite(s, 12, 0);   % LOW
```

Aliases for readability:

```octave
writeDigitalPin(s, 12, 1);
readDigitalPin(s, 12);
```

---

### Digital read

```octave
v = dread(s, 7);          % returns 0 or 1
v = readDigitalPin(s, 7);
```

---

## Analog input

Analog inputs are addressed numerically:

| Octave call | Arduino pin |
|------------|-------------|
| `aread(s,0)` | A0 |
| `aread(s,1)` | A1 |
| `aread(s,2)` | A2 |
| `aread(s,3)` | A3 |
| `aread(s,4)` | A4 |
| `aread(s,5)` | A5 |

Example:

```octave
x = aread(s, 0);    % 0..1023 from A0
```

---

## PWM output

PWM is available on Arduino Uno pins:

**3, 5, 6, 9, 10, 11**

```octave
pinmode(s, 9, "output");
analogwrite(s, 9, 128);   % ~50% duty cycle
```

---

## Example: potentiometer → LED brightness

```octave
s = arduino_init();

pinmode(s, 9, "output");

while true
  x = aread(s, 0);              % A0
  u = round(255 * x / 1023);    % scale to PWM range
  analogwrite(s, 9, u);
  pause(0.02);
end
```

---

## Closing the connection

```octave
clear s
```

This cleanly closes the serial connection.

---

## MATLAB compatibility

The Arduino firmware and communication protocol are **independent of Octave**.

Because the interface uses plain serial communication, the same firmware can be used from **MATLAB** with minimal changes to the host-side code (`serialport`, `write`, `read`).

---

## Design philosophy

- No hidden magic
- No automatic reflashing
- No board-specific hacks
- Clear separation of concerns
- Everything inspectable and explainable

This makes `octave-arduino-io` particularly suitable for:

- control engineering education
- numerical methods labs
- hardware-in-the-loop experiments
- student projects and prototyping

---

## License

Open for educational and research use.  
Feel free to adapt and extend.

---

## Acknowledgements

Developed through iterative debugging, teaching needs, and a strong preference for  
**clarity over convenience**.
