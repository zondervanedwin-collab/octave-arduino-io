// OctavePinIO.ino
// ------------------------------------------------------------
// Minimal binary protocol to control/read Arduino pins from Octave.
//
// Baudrate: 115200
//
// Commands sent from Octave to Arduino:
//
// 0x01 DWRITE:   [0x01, pin, value]            value = 0/1
// 0x02 DREAD:    [0x02, pin]                   -> reply [0x02, value]
// 0x03 AREAD:    [0x03, apin]                  -> reply [0x03, lo, hi]  (0..1023)
// 0x04 PINMODE:  [0x04, pin, mode]             mode: 0=INPUT, 1=OUTPUT, 2=INPUT_PULLUP
// 0x05 AWRITE:   [0x05, pin, duty]             duty: 0..255 (PWM pins only)
//
// Notes for Arduino Uno:
// - Digital pins: 0..13   (avoid 0/1 if you use USB serial actively)
// - Analog inputs: apin 0..5 correspond to A0..A5
// - PWM pins: 3, 5, 6, 9, 10, 11
// ------------------------------------------------------------

static void waitBytes(size_t n) {
  while (Serial.available() < (int)n) { /* wait */ }
}

void setup() {
  Serial.begin(115200);
}

void loop() {
  if (Serial.available() < 1) return;
  uint8_t cmd = (uint8_t)Serial.read();

  // -------------------- DWRITE --------------------
  if (cmd == 0x01) {
    waitBytes(2);
    uint8_t pin = (uint8_t)Serial.read();
    uint8_t val = (uint8_t)Serial.read();
    pinMode(pin, OUTPUT);
    digitalWrite(pin, val ? HIGH : LOW);
  }

  // -------------------- DREAD ---------------------
  else if (cmd == 0x02) {
    waitBytes(1);
    uint8_t pin = (uint8_t)Serial.read();
    // Default: INPUT_PULLUP is often safer for floating inputs.
    // If you prefer plain INPUT, change the next line.
    pinMode(pin, INPUT_PULLUP);
    uint8_t v = digitalRead(pin) ? 1 : 0;
    Serial.write((uint8_t)0x02);
    Serial.write(v);
  }

  // -------------------- AREAD ---------------------
  else if (cmd == 0x03) {
    waitBytes(1);
    uint8_t apin = (uint8_t)Serial.read(); // 0..5
    uint16_t v = analogRead((uint8_t)(A0 + apin));
    Serial.write((uint8_t)0x03);
    Serial.write((uint8_t)(v & 0xFF));         // lo byte
    Serial.write((uint8_t)((v >> 8) & 0xFF));  // hi byte
  }

  // -------------------- PINMODE -------------------
  else if (cmd == 0x04) {
    waitBytes(2);
    uint8_t pin  = (uint8_t)Serial.read();
    uint8_t mode = (uint8_t)Serial.read(); // 0,1,2
    if (mode == 0) pinMode(pin, INPUT);
    else if (mode == 1) pinMode(pin, OUTPUT);
    else if (mode == 2) pinMode(pin, INPUT_PULLUP);
  }

  // -------------------- AWRITE (PWM) --------------
  else if (cmd == 0x05) {
    waitBytes(2);
    uint8_t pin  = (uint8_t)Serial.read();
    uint8_t duty = (uint8_t)Serial.read(); // 0..255
    pinMode(pin, OUTPUT);
    analogWrite(pin, duty);
  }

  // Unknown cmd -> ignore (or you could flush / reply error)
}
