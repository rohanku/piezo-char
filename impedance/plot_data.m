%% Piezo impedance data visualization
%% Script by Eric Yang

% Impedance Data from LCR meter
freq_arr = linspace(1e5, 2e6, 201);
data_prefix = [
  "airgapanchor2_air",
  "airgapanchor2_oil",
  "p3anchor_air",
  "p3anchor_2_oil",
  "p5anchor4_air",
];
initial = 1;
final = 100;

dir_data = 'data/';
for i=1:length(data_prefix)
    imp_mag(:,i) = dlmread(strcat(dir_data, data_prefix(i), '_magnitude.csv'),',',0,0);
    imp_phase(:,i) = dlmread(strcat(dir_data, data_prefix(i), '_phase.csv'),',',0,0);
    impdata(:,2*i-1) = imp_mag(:,i).*cosd(imp_phase(:,i)); % real part
    impdata(:,2*i) = imp_mag(:,i).*sind(imp_phase(:,i)); % imaginary part
    admitance = 1./imp_mag(:,i);
    cp(i) = (admitance(final)-admitance(initial))/(freq_arr(final)-freq_arr(initial))/2/pi*1e12; % parallel capacitor value
end


for i=1:length(data_prefix)
    figure;

    subplot(4,1,1);
    loglog(freq_arr,imp_mag(:,i),'linewidth',2);
    grid on;
    title(strcat('Impedance magnitude for ', data_prefix(i)), 'Interpreter', 'none');
    xlabel('frequency (Hz)'); ylabel('Impedance Magnitude (\Omega)');
    legend();

    subplot(4,1,2);
    semilogx(freq_arr,imp_phase(:,i),'linewidth',2);
    grid on;
    title(strcat('Impedance phase for ', data_prefix(i)), 'Interpreter', 'none');
    xlabel('frequency (Hz)'); ylabel('phase (degrees)');
    legend();

    subplot(4,1,3);
    semilogx(freq_arr,impdata(:,2*i-1),'linewidth',2);
    grid on;
    title(strcat('Real impedance for ', data_prefix(i)), 'Interpreter', 'none');
    xlabel('frequency (Hz)'); ylabel('Impedance Real (\Omega)');

    subplot(4,1,4);
    semilogx(freq_arr,impdata(:,2*i),'linewidth',2);
    grid on;
    title(strcat('Imaginary impedance for', ' ', data_prefix(i)), 'Interpreter', 'none');
    xlabel('frequency (Hz)'); ylabel('Impedance Imaginary (\Omega)');
    legend()
end

figure;
for i=1:length(data_prefix)
    subplot(3,1,1);
    hold on;
    loglog(freq_arr,imp_mag(:,i),'linewidth',2,'DisplayName',strcat(data_prefix(i),' mag')); grid on;
    xlabel('frequency (Hz)'); ylabel('Impedance Magnitude (\Omega)');
    title(strcat('Impedance characterization of piezos'));
    legend('Interpreter', 'none')

    subplot(3,1,2);
    hold on;
    semilogx(freq_arr,impdata(:,2*i-1),'linewidth',2,'DisplayName',strcat(data_prefix(i),' real')); grid on;
    xlabel('frequency (Hz)'); ylabel('Impedance Real (\Omega)');

    subplot(3,1,3);
    hold on;
    semilogx(freq_arr,impdata(:,2*i),'linewidth',2,'DisplayName',strcat(data_prefix(i),' imag')); grid on;
    xlabel('frequency (Hz)'); ylabel('Impedance Imaginary (\Omega)');
    legend('Interpreter', 'none');
    grid on;
end
