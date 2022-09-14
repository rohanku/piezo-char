classdef LCRSweep
  % LCRSweep Encapsutes logic for running a frequency sweep using an LCR machine.

  properties
    lcr % Connected LCRMeter object
    frequencies % List of frequencies to sweep across
    waitTime % Amount of time to wait for frequency sweep to finish
    rawData % Raw data collected from LCR meter
  end

  methods
    function lcrSweep = LCRSweep(lcr, frequencies, waitTime)
      % Creates an LCRSweep across given frequencies using a connected LCRMeter.
      % Can optionally take in the amount of time to wait for the frequency sweep to finish.

      if nargin < 3
        waitTime = 25;
      end
      lcrSweep.lcr = lcr;
      lcrSweep.frequencies = frequencies;
      lcrSweep.waitTime = waitTime;
    end

    function setup(lcrSweep)
      % Send necessary confugration commands to LCRMeter.

      lcr = lcrSweep.lcr;

      % Basic settings
      % Set impedance range to auto.
      lcr.cmd(":function:impedance:range:auto on");
      % Set impedance type to Z-theta.
      lcr.cmd(":function:impedance:range:auto on");
      % Set list mode to sequential.
      lcr.cmd(":list:mode seq");

      % Trigger setup
      % Change to "ready/waiting for trigger" state.
      lcr.cmd(":initiate:continuous on");
      % Set trigger to computer control.
      lcr.cmd(":trigger:source bus");
      % Set display to list sweep page
      %   (NOT meas setup list sweep page).
      lcr.cmd(":display:page list");
    end

    function lcrSweep = run(lcrSweep)
      % Run sweep and collect raw data.

      disp("Running setup")
      lcrSweep.setup();

      lcr = lcrSweep.lcr;

      % Specify frequencies and start sweep.
      disp("Starting frequency sweep");
      lcr.listfreq(lcrSweep.frequencies);
      lcr.cmd(":trigger:immediate");

      % Wait for sweep to complete.
      disp("Waiting for frequency sweep to complete");
      pause(lcrSweep.waitTime)

      % Collect data.
      disp("Collecting raw data from LCR meter");
      lcrSweep.rawData = lcr.fetchdata(length(lcrSweep.frequencies))
      disp("Finished collecting raw data from LCR meter");
    end

    function [mag, phase] = get_freq_mag_phase(lcrSweep, char_arr)
        % Parse raw data into magnitude and phase data for given frequencies.

        one_sweep_cell_arr = strsplit(char_arr, ',');
        vec = cellfun(@str2num, one_sweep_cell_arr);
        num_mat = reshape(vec, 4, length(lcrSweep.frequencies))';
        mag = num_mat(:, 1)';
        phase = num_mat(:, 2)';
    end

    function processdata(lcrSweep, outputPrefix)
      % Process data and generate relevant plots and output files.

      rawData = lcrSweep.rawData

      % Recover magnitude and phase data from raw data.
      [mag, phase] = lcrSweep.get_freq_mag_phase(rawData{1,1});
      real = mag.*cosd(phase);
      imag = mag.*sind(phase);

      % Plot impedance magnitude.
      figure('position', [0 0 8 5])
      loglog(lcrSweep.frequencies, mag, 'b', 'linewidth', 2);
      grid on;
      xlabel('frequency (Hz)');
      ylabel('Impedance Magnitude ($\Omega$)');

      % Plot impedance phase.
      figure('position', [10 0 8 5])
      semilogx(lcrSweep.frequencies, phase, 'r', 'linewidth', 2);
      grid on;
      xlabel('frequency (Hz)');
      ylabel('Impedance Phase ($\circ$)');

      % Plot real impedance.
      figure('position', [0 10 8 5])
      semilogx(lcrSweep.frequencies,real,'r','linewidth',2);
      grid on;
      xlabel('frequency (Hz)');
      ylabel('Real part ($\Omega$)');

      % Plot imaginary impedance.
      figure('position', [10 10 8 5])
      semilogx(lcrSweep.frequencies,imag,'r','linewidth',2);
      grid on;
      xlabel('frequency (Hz)');
      ylabel('Imaginary part ($\Omega$)');

      % Write phase and magnitude data to CSV files.
      csvwrite(strcat(outputPrefix, '_phase_', datestr(clock, 'mm-dd-yy_HH:MM:SS'), '.csv'), phase')
      csvwrite(strcat(outputPrefix, '_magnitude_', datestr(clock, 'mm-dd-yy_HH:MM:SS'), '.csv'), mag')
    end
  end
end
