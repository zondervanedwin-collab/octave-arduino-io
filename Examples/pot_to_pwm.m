s = open_arduino_serial("/dev/ttyUSB0", 115200);

pinmode(s, 9, "output");

for k = 1:400
  x = aread(s, 0);                  % 0..1023
  u = round(255 * x / 1023);        % scale to 0..255
  analogwrite(s, 9, u);
  pause(0.02);
end

clear s
