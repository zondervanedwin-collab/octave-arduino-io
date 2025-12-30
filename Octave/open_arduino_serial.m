function s = open_arduino_serial(port, baudrate)
  % Open Arduino serialport connection for the OctavePinIO firmware.
  %
  % Example:
  %   s = open_arduino_serial("/dev/ttyUSB0", 115200);

  pkg load instrument-control

  if nargin < 2
    baudrate = 115200;
  end

  s = serialport(port, baudrate);

  % Arduino Uno resets when the port opens -> wait for reboot
  pause(2);

  % Flush any pending bytes
  if (s.NumBytesAvailable > 0)
    read(s, s.NumBytesAvailable, "uint8");
  end
end
