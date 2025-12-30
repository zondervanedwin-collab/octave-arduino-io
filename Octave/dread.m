function v = dread(s, pin)
  % Digital read: returns 0 or 1
  % Firmware uses INPUT_PULLUP by default.

  pin = uint8(pin);
  write(s, uint8([hex2dec("02"), pin]), "uint8");

  % Wait until reply is available (2 bytes)
  t0 = tic();
  while (s.NumBytesAvailable < 2
         && toc(t0) < 1.0)
    pause(0.005);
  end

  data = read(s, 2, "uint8");  % [0x02, value]
  v = double(data(2));
end

