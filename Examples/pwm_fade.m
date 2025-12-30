s = open_arduino_serial("/dev/ttyUSB0", 115200);

pinmode(s, 9, "output");

for u = 0:5:255
  analogwrite(s, 9, u);
  pause(0.03);
end
for u = 255:-5:0
  analogwrite(s, 9, u);
  pause(0.03);
end

clear s
