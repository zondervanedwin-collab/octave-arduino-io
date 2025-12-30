% ---- Open connection ----
s = open_arduino_serial("/dev/ttyUSB0", 115200);

% ---- Configuration ----
PWM_PIN = 9;        % LED
POT_APIN = 0;       % A0
Kp = 0.25;          % proportional gain
Ts = 0.02;          % sampling time [s]

pinmode(s, PWM_PIN, "output");

disp("Running proportional control loop (Ctrl+C to stop)");

% ---- Control loop ----
while true

  % Read reference (potentiometer)
  r = aread(s, POT_APIN);        % 0..1023

  % Scale reference to PWM range
  r_pwm = 255 * r / 1023;

  % For now: assume y = 0 (no feedback sensor)
  y = 0;

  % Proportional control law
  u = Kp * (r_pwm - y);

  % Saturation (important!)
  u = max(0, min(255, u));

  % Apply control action
  analogwrite(s, PWM_PIN, u);

  pause(Ts);

end
