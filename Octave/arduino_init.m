function s = arduino_init(baudrate)
%ARDUINO_INIT  Initialize connection to Arduino for octave-arduino-io
%
%   s = arduino_init()
%   s = arduino_init(baudrate)
%
% Finds a likely Arduino serial port (ttyUSB/ttyACM), opens it,
% waits for reset, and flushes startup bytes.
%
% Compatible with older Octave versions (no contains()).

  pkg load instrument-control

  if nargin < 1
    baudrate = 115200;
  end

  % 1) Find candidate serial ports
  ports = serialportlist;
  if isempty(ports)
    error("arduino_init: no serial ports found");
  end

  % Helper: "contains" replacement using strfind
  function tf = has_substr(s, pat)
    tf = !isempty(strfind(s, pat));
  end

  % 2) Prefer USB/ACM ports (typical for Arduino on Linux)
  idx = [];
  for k = 1:numel(ports)
    if has_substr(ports{k}, "ttyUSB") || has_substr(ports{k}, "ttyACM")
      idx = k;
      break;
    end
  end

  if isempty(idx)
    error("arduino_init: no Arduino-like serial port found (ttyUSB/ttyACM)");
  end

  port = ports{idx};
  fprintf("Connecting to Arduino on %s\n", port);

  % 3) Open serial connection
  s = serialport(port, baudrate);

  % Arduino resets when port opens
  pause(2);

  % 4) Flush startup bytes
  if (s.NumBytesAvailable > 0)
    read(s, s.NumBytesAvailable, "uint8");
  end
end
