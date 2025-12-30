function pinmode(s, pin, mode)
  % pinmode(s, pin, mode)
  % mode can be: "input", "output", "pullup"

  if ischar(mode)
    mode = lower(mode);
    if strcmp(mode, "input")
      m = uint8(0);
    elseif strcmp(mode, "output")
      m = uint8(1);
    elseif strcmp(mode, "pullup")
      m = uint8(2);
    else
      error("pinmode: mode must be 'input', 'output', or 'pullup'");
    end
  else
    % Allow numeric mode 0/1/2
    m = uint8(mode);
  end

  pin = uint8(pin);
  write(s, uint8([hex2dec("04"), pin, m]), "uint8");
end

