classdef LCRMeter
  % LCRMeter Device interface for Keysight LCR meter.
  properties
    client % Connected TCP or serial client
  end
  methods
    function lcr = LCRMeter()
      % Create an LCRMeter object.
    end

    function lcr = tcpinit(lcr, address, port, timeout)
      % Connect to LCR meter over TCP.

      disp("Connecting to device via TCP");
      if nargin < 4
        timeout = 5;
      end
      lcr.client = tcpclient(address, port, "Timeout", timeout);
      disp("Successfully connected to device");
    end

    function lcr = serialinit(lcr, port, baudrate, timeout)
      % Connect to LCR meter over serial.

      disp("Connecting to device via serial port");
      if nargin < 4
        timeout = 5;
      end
      lcr.client = serialport(port, baudrate, "Timeout", timeout);
      disp("Successfully connected to device");
    end

    function cmd(lcr, cmd)
      % Send command to LCR meter.

      lcr.client.write(strcat(cmd, "\n"));
    end

    function listfreq(lcr, frequencies)
      % Specify frequencies to sweep over.

      lcr.cmd(strcat(":list:frequency ", strjoin(cellstr(num2str(frequencies')),',')))
    end

    function data = fetchdata(lcr, n)
      % Fetch n data points from LCR meter.

      data = cell(1, n)
      for i = 1:n
        lcr.cmd(":fetch?")
        data(1, i) = {lcr.client.readline()}
      end
    end
  end
end
      
