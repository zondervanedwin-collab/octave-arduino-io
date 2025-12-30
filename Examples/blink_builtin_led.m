s = open_arduino_serial("/dev/ttyUSB0", 115200);  % adjust port

pinmode(s, 13, "output");

for k = 1:10
  dwrite(s, 13, 1); pause(1);
  dwrite(s, 13, 0); pause(1);
end

