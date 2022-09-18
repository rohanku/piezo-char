%% Piezo Impedance characterization and power efficiency calculation for different mediums 6/17
%% Script by Eric Yang
clc; clear; close all

% Impedance Data from LCR meter
n_freq_pts = 201;
freq_arr = linspace(1e5, 2e6, n_freq_pts);
board_type = [" flex"];
board_name = ["smallflex1"];
medium = ["air","water","oil"];
fit_data = ["real","imag"];
initial = 1;
final = 100;

% Harvested Voltage data
% dir_data = '../Measurement/piezo/jun17/';
% freq_oil = xlsread(strcat(dir_data,'Test and Measurement.xlsx'), '6_14 oil measurement', 'M2:M41');
% vharvest_oil = xlsread(strcat(dir_data,'Test and Measurement.xlsx'), '6_14 oil measurement', 'R2:R41');
% 
% freq_water = xlsread(strcat(dir_data,'Test and Measurement.xlsx'), 'water tests focused transducer', 'Q2:Q19');
% vharvest_water = xlsread(strcat(dir_data,'Test and Measurement.xlsx'), 'water tests focused transducer', 'X2:X19');
% vharvest_water = vharvest_water/1000*7/17;%Vpp, water measurements were done with Vpp=17 V instead of 7 volts


dir_data = '';
for i=1:length(medium)
    imp_mag(:,i) = dlmread(strcat(dir_data,'smallflex1_',medium(i),'_magnitude.csv'),',',0,0);
    imp_phase(:,i) = dlmread(strcat(dir_data,'smallflex1_',medium(i),'_phase.csv'),',',0,0);
    impdata(:,2*i-1) = imp_mag(:,i).*cosd(imp_phase(:,i)); % real part
    impdata(:,2*i) = imp_mag(:,i).*sind(imp_phase(:,i)); % imaginary part
    admitance = 1./imp_mag(:,i);
    cp(i) = (admitance(final)-admitance(initial))/(freq_arr(final)-freq_arr(initial))/2/pi*1e12 % parallel capacitor value
end


for i=1:length(medium)
    figure(1)
    hold on
    subplot(2,1,1)
    loglog(freq_arr,imp_mag(:,i),'linewidth',2,'DisplayName',strcat(medium(i),' mag')); grid on;
    xlabel('frequency (Hz)'); ylabel('Impedance Magnitude (\Omega)');
    title(strcat('Impedace characterization for piezo in air, oil water'));
    legend()
    set(gca,'FontSize',20)
    hold on
    subplot(2,1,2)
    %yyaxis right
    figure(2)
    subplot(2,1,1)
    semilogx(freq_arr,impdata(:,2*i-1),'linewidth',2,'DisplayName',strcat(medium(i),' real')); grid on;
    hold on;
    xlabel('frequency (Hz)'); ylabel('Impedance Real (\Omega)');
    figure(2)
    subplot(2,1,2)
    hold on;
    semilogx(freq_arr,impdata(:,2*i),'linewidth',2,'DisplayName',strcat(medium(i),' imag')); grid on;
    xlabel('frequency (Hz)'); ylabel('Impedance Imaginary (\Omega)');
    %ylim([-2500 5000]);
    legend()
    set(gca,'FontSize',20)
    grid on
end

%% Define Constants

epilson = 8.854*10^-12;        % F/m
relative_permittivity = 1300;
abs_permittivity = epilson*relative_permittivity;   % F/m

density = 7500;                % kg/m^3
velocity = 4100;               % m/s

length = 1.5*10^-3;            % m
width = 1.5*10^-3;             % m
thickness = 1.5*10^-3;         % m
area = length*width;           % m^2

f_oc_spec = velocity/(2*thickness);    % Hz

pressure_const = 26.8e8;       % V/m or N/C

Z_0 = density*velocity*area;
Z_1 = 1.46e6*area;                % Rayls*m^2     change for air, water, oil
Z_2 = 1.46e6*area;                % Rayls*m^2     change for air, water, oil

f = linspace(1e5, 2e6, 201);   % Hz
omega = 2*pi*f;                % rad/s


%% 1D Analysis

C_0 = abs_permittivity.*area./thickness;
C_1 = 8.*thickness.*(C_0.*pressure_const).^2./(area.*density.*(pi.*velocity).^2-8.*C_0.*pressure_const.^2.*thickness);
L_1 = area.*density.*thickness./(8.*(C_0.*pressure_const).^2);
R_1 = Z_2./((2.*C_0.*pressure_const).^2);

Z_L = 1./(1i*omega.*C_0);
Z_R = 1i*omega*L_1 + R_1 + 1./(1i*omega.*C_1);
Z_T = Z_L.*Z_R./(Z_L+Z_R);

figure
grid on
hold on

set(gca, 'YScale', 'log')
plot(f,abs(Z_T))
plot(f,imag(Z_T))

title('Impedance vs. Frequency (1D Model)')
xlabel('Frequency (Hz)')
ylabel('Impedance (ohms)')
legend('abs(Z_T)','imag(Z_T)')

hold off

%% KLM Analysis

Z_klm = density.*velocity.*area;
C_klm = abs_permittivity.*area./thickness;
X_klm = (pressure_const.^2./(omega.^2.*Z_klm)).*sin(omega.*thickness./velocity);
ratio_klm = ((omega.*Z_klm)./(2.*pressure_const)).*csc((omega.*thickness)./(2*velocity));

Z_L1 = Z_klm.*(Z_1+1i.*Z_klm*tan((omega.*thickness)./(2.*velocity)))./(Z_klm+1i.*Z_1*tan((omega.*thickness)./(2.*velocity)));
Z_L2 = Z_klm.*(Z_2+1i.*Z_klm*tan((omega.*thickness)./(2.*velocity)))./(Z_klm+1i.*Z_2*tan((omega.*thickness)./(2.*velocity)));
Z_a = Z_L1.*Z_L2./(Z_L1+Z_L2);

Z_in = (1./(1i.*omega.*C_klm))+(1i.*X_klm)+(Z_a./(ratio_klm.^2));

figure
grid on
hold on

set(gca, 'YScale', 'log')
plot(f,abs(Z_in))
plot(f,imag(Z_in))

title('Impedance vs. Frequency (KLM Model)')
xlabel('Frequency (Hz)')
ylabel('Impedance (ohms)')
legend('abs(Z_{in})','imag(Z_{in})')

hold off

%% Plots

figure
grid on
hold on

set(gca, 'YScale', 'log')
loglog(f,abs(Z_T))
loglog(f,abs(Z_in))
loglog(f,imp_mag(:,2))     % change for air, water, oil

title('Impedance Magnitude vs. Frequency in Air')
xlabel('Frequency (Hz)')
ylabel('Impedance Magnitude (ohms)')
legend('1D Model','KLM Model','Measured Data')

hold off

figure
grid on
hold on

% set(gca, 'YScale', 'log')
semilogx(f,imag(Z_T))
semilogx(f,imag(Z_in))
semilogx(f,impdata(:,2*2))     % change for air, water, oil

title('Impedance Imaginary vs. Frequency in Air')
xlabel('Frequency (Hz)')
ylabel('Impedance Imaginary (ohms)')
legend('1D Model','KLM Model','Measured Data')

hold off
    
