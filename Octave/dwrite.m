function dwrite(s, pin, value)
  % Digital write: set pin HIGH/LOW
  %
  % dwrite(s, 12, 1);  % HIGH
  % dwrite(s, 12, 0);  % LOW

  pin = uint8(pin);
  value = uint8(value != 0);

  write(s, uint8([hex2dec("01"), pin, value]), "uint8");
end

