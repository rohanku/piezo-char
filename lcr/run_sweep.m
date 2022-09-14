% Make sure to clear any previous lcrSweeps so that they disconnect from
% the device, allowing new connections to be made (this can be done using
% the clear command).

% Connect to the LCR meter. All Keysight equipment use port 5025.
lcr = LCRMeter();
lcr = lcr.tcpinit("localhost", 12345); % Connect via TCP over the network.
% lcr = lcr.serialinit("/dev/usb-serial10293123", 9600); % Connect via a serial port like USB.

% Run the LCR sweep with the given frequencies.
frequencies = linspace(1e5, 2e6, 201);
lcrSweep = LCRSweep(lcr, [1, 2], 2);
lcrSweep = lcrSweep.run();

% Plot data and write results to the given output files.
lcrSweep.processdata("piezo_measurements/9_8_2022/p3anchor_air");

% Disconnect from LCR meter.
clear lcrSweep lcr