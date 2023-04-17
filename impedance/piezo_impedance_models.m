%% Piezo Impedance characterization and power efficiency calculation for different mediums 6/17
%% Script by Eric Yang

% Impedance Data from LCR meter
freq_arr = linspace(1e5, 2e6, 201);
data_prefix = [
  "airgapanchor2_air",
  "p5anchor4_air",
  "p3anchor_air",
%   "p3anchor_2_oil",
%   "airgapanchor2_oil",
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


%% Define Constants

epilson = 8.854e-12;        % F/m
relative_permittivity = 1300;
abs_permittivity = epilson*relative_permittivity;   % F/m

density = 7500;                % kg/m^3
velocity = 4100;               % m/s

l = 1.5e-3;            % m
w = 1.5e-3;             % m
thickness = 1.5e-3;         % m
area = l*w;           % m^2

f_oc_spec = velocity/(2*thickness);    % Hz

pressure_const = 26.8e8;       % V/m or N/C

Z_air = 400;
Z_water = 1.46e6;
Z_oil = 1.32e6;
Z_0 = density*velocity*area;
Z_1 = Z_oil*area;                % Rayls*m^2     change for air, water, oil
Z_2 = Z_oil*area;                % Rayls*m^2     change for air, water, oil

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

%% KLM Analysis

Z_klm = density.*velocity.*area;
C_klm = abs_permittivity.*area./thickness;
X_klm = (pressure_const.^2./(omega.^2.*Z_klm)).*sin(omega.*thickness./velocity);
ratio_klm = ((omega.*Z_klm)./(2.*pressure_const)).*csc((omega.*thickness)./(2*velocity));

Z_L1 = Z_klm.*(Z_1+1i.*Z_klm*tan((omega.*thickness)./(2.*velocity)))./(Z_klm+1i.*Z_1*tan((omega.*thickness)./(2.*velocity)));
Z_L2 = Z_klm.*(Z_2+1i.*Z_klm*tan((omega.*thickness)./(2.*velocity)))./(Z_klm+1i.*Z_2*tan((omega.*thickness)./(2.*velocity)));
Z_a = Z_L1.*Z_L2./(Z_L1+Z_L2);

Z_in = (1./(1i.*omega.*C_klm))+(1i.*X_klm)+(Z_a./(ratio_klm.^2));

%% Plots

figure;
grid on;
hold on;
set(gca, 'YScale', 'log')
loglog(f,abs(Z_T), 'DisplayName', '1D Model');
loglog(f,abs(Z_in), 'DisplayName', 'KLM Model');
for i=1:length(data_prefix)
  loglog(f,imp_mag(:,i), 'DisplayName', data_prefix(i));
end

title('Impedance Magnitude vs. Frequency in Air');
xlabel('Frequency (Hz)');
ylabel('Impedance Magnitude (ohms)');
legend('Interpreter', 'none');

hold off;

figure;
grid on;
hold on;

semilogx(f,imag(Z_T), 'DisplayName', '1D Model');
semilogx(f,imag(Z_in), 'DisplayName', 'KLM Model');
for i=1:length(data_prefix)
  semilogx(f,impdata(:,2*i), 'DisplayName', data_prefix(i));
end

title('Impedance Imaginary vs. Frequency in Air');
xlabel('Frequency (Hz)');
ylabel('Impedance Imaginary (ohms)');
legend('Interpreter', 'none');

hold off;
