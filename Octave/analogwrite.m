function analogwrite(s, pin, duty)
  % PWM write: duty 0..255
  % Works on Uno PWM pins: 3,5,6,9,10,11

  pin = uint8(pin);
  duty = round(duty);
  duty = max(0, min(255, duty));
  duty = uint8(duty);

  write(s, uint8([hex2dec("05"), pin, duty]), "uint8");
end

