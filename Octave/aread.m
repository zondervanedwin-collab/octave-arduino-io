function v = aread(s, apin)
  % Analog read: apin 0..5 corresponds to A0..A5 on Uno
  % Returns 0..1023

  apin = uint8(apin);
  write(s, uint8([hex2dec("03"), apin]), "uint8");

  % Wait until reply is available (3 bytes)
  t0 = tic();
  while (s.NumBytesAvailable < 3
         && toc(t0) < 1.0)
    pause(0.005);
  end

  data = read(s, 3, "uint8");   % [0x03, lo, hi]
  v = double(data(2)) + 256*double(data(3));
end

