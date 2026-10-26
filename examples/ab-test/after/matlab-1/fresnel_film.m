% TE reflection from air / Si3N4 film / semi-infinite SiO2.
% Model: planar, isotropic, nonmagnetic, lossless media; coherent film.
% Equations follow tangential E/H continuity and the multiple-reflection
% geometric series: r = (r01 + r12*exp(2i*delta))/(1 + r01*r12*exp(2i*delta)).
% Convention: exp(-i*omega*t), forward exp(+i*kz*z); r is referenced to
% the air/film surface. All lengths in the optical phase are in nm.
clear; close all; clc;

%% Parameters
n0 = 1.0;                   % Air refractive index (dimensionless)
n2 = 1.45;                  % Substrate refractive index (dimensionless)
d = 200;                    % Film thickness (nm)
wavelength_min = 400;       % Minimum vacuum wavelength (nm)
wavelength_max = 1100;      % Maximum vacuum wavelength (nm)
wavelength_step = 1;        % Wavelength increment (nm)
theta_min = 0;              % Minimum incidence angle in air (deg)
theta_max = 89;             % Maximum incidence angle in air (deg)
theta_step = 0.1;           % Incidence-angle increment (deg)
index_file = 'SiN_index.csv'; % Columns: vacuum wavelength (nm), real n
tolerance = 1e-10;          % Absolute tolerance for dimensionless checks
color_count = 257;          % Number of colors, including cyclic endpoints

%% Load dispersion and construct the scan
data = readmatrix(fullfile(fileparts(mfilename('fullpath')), index_file));
assert(size(data, 2) == 2 && size(data, 1) >= 2, ...
    'Index data must contain two numeric columns and at least two rows.');
assert(isreal(data) && all(isfinite(data(:))), ...
    'Index data contain complex or NaN/Inf values.');
assert(all(data(:, 1) > 0) && all(diff(data(:, 1)) > 0), ...
    'Measured wavelengths must be positive and strictly increasing.');
assert(all(data(:, 2) > 0), 'All measured refractive indices must be positive.');
assert(n0 > 0 && n2 > 0 && d >= 0 && wavelength_min > 0 && ...
    wavelength_max > wavelength_min && wavelength_step > 0 && ...
    theta_min >= 0 && theta_max < 90 && theta_max > theta_min && theta_step > 0, ...
    'Invalid optical parameters or scan bounds.');

wavelength = wavelength_min:wavelength_step:wavelength_max;
theta = (theta_min:theta_step:theta_max).';
% Explicit modeling choice: linear interpolation within the supplied data;
% outside it, extend the nearest two-point slope. This is an assumption,
% not a measured or validated dispersion model for the missing interval.
outside = wavelength < data(1, 1) | wavelength > data(end, 1);
if any(outside)
    warning('fresnel_film:DispersionExtrapolation', ...
        ['Data cover %.1f--%.1f nm. Linear endpoint extrapolation is used ' ...
         'at %d scan wavelengths outside this range (%.1f--%.1f nm).'], ...
        data(1, 1), data(end, 1), nnz(outside), ...
        min(wavelength(outside)), max(wavelength(outside)));
end
n1 = interp1(data(:, 1), data(:, 2), wavelength, 'linear', 'extrap');
assert(all(isfinite(n1)) && all(n1 > 0), ...
    'Interpolated/extrapolated n is invalid; minimum n = %.8g.', min(n1));

%% Fresnel amplitudes and coherent film interference
% qj = nj*cos(theta_j) = kz_j/k0 is the TE optical admittance apart from
% a common vacuum factor. Snell's law fixes nj*sin(theta_j)=n0*sin(theta).
% Rows are incidence angles, columns are wavelengths. Element-wise powers,
% products and divisions evaluate each angle/wavelength point independently.
q0 = n0 * cosd(theta);
q1 = sqrt(n1.^2 - (n0 * sind(theta)).^2);
q2 = sqrt(n2^2 - (n0 * sind(theta)).^2);
assert(isreal(q1) && isreal(q2) && all(q1(:) > 0) && all(q2(:) > 0), ...
    'This lossless propagating-wave scan requires positive real q1 and q2.');
r01 = (q0 - q1) ./ (q0 + q1);
r12 = (q1 - q2) ./ (q1 + q2);
delta = 2*pi*d * q1 ./ wavelength; % Single-pass film phase (rad)
round_trip = exp(2i * delta);
denominator = 1 + r01 .* r12 .* round_trip;
r = (r01 + r12 .* round_trip) ./ denominator;
R = abs(r).^2;
phase = angle(r);                   % Wrapped phase in [-pi, pi] (rad)
assert(all(abs(r(:)) > 0), ...
    'An exactly zero reflection amplitude has undefined phase.');
r_bare = (q0 - q2) ./ (q0 + q2);
R_bare = abs(r_bare).^2;            % Wavelength independent for fixed n2
delta_R = R - R_bare;              % Absolute reflectance difference
assert(all(isfinite(r(:))) && all(isfinite(delta_R(:))), ...
    'Nonfinite reflection result; inspect optical parameters and denominator.');

%% Physical consistency checks over the full scan
% For electric-field transmission amplitude t, transmitted power is
% T = (q2/q0)*|t|^2. Losslessness requires R + T = 1.
t01 = 2*q0 ./ (q0 + q1);
t12 = 2*q1 ./ (q1 + q2);
t = t01 .* t12 .* exp(1i * delta) ./ denominator;
T = (q2 ./ q0) .* abs(t).^2;
energy_error = max(abs(R + T - 1), [], 'all');
assert(isfinite(energy_error) && energy_error < tolerance, ...
    'Energy conservation failed: max |R+T-1| = %.8g.', energy_error);
assert(min(R(:)) >= 0 && max(R(:)) <= 1 + tolerance, ...
    'Unphysical reflectance range: [%.8g, %.8g].', min(R(:)), max(R(:)));
% At d=0, the two interfaces must reduce to the bare air/SiO2 interface
% for every wavelength and incidence angle, independent of film index.
r_zero = (r01 + r12) ./ (1 + r01 .* r12);
zero_thickness_error = max(abs(r_zero - r_bare), [], 'all');
assert(isfinite(zero_thickness_error) && zero_thickness_error < tolerance, ...
    'Zero-thickness limit failed: max |r(0)-r_bare| = %.8g.', zero_thickness_error);
fprintf('Grid: %d angles x %d wavelengths; film thickness = %.1f nm.\n', ...
    numel(theta), numel(wavelength), d);
fprintf('R range: [%.8f, %.8f]; Delta R range: [%.8f, %.8f].\n', ...
    min(R(:)), max(R(:)), min(delta_R(:)), max(delta_R(:)));
fprintf('Max |R+T-1| = %.3g; max |r(d=0)-r_bare| = %.3g.\n', ...
    energy_error, zero_thickness_error);

%% Colormaps
% Viridis anchor colors give a sequential, increasing-lightness intensity map.
sequential_anchors = [0.267 0.005 0.329; 0.283 0.141 0.458; ...
    0.254 0.265 0.530; 0.207 0.372 0.553; 0.164 0.471 0.558; ...
    0.128 0.567 0.551; 0.135 0.659 0.518; 0.267 0.749 0.441; ...
    0.478 0.821 0.318; 0.741 0.873 0.150; 0.993 0.906 0.144];
sequential_map = interp1(linspace(0, 1, size(sequential_anchors, 1)), ...
    sequential_anchors, linspace(0, 1, color_count));
% Toolbox-free cyclic RGB path: fixed Rec.709 linear luminance, orthogonal
% chromatic directions, and identical endpoints for -pi and +pi. This is
% cyclic but is not claimed to be perceptually uniform like a calibrated map.
phi = linspace(0, 2*pi, color_count).';
cyclic_map = 0.5 + 0.28 * (cos(phi)*[1, -0.2126/0.7152, 0] + ...
    sin(phi)*[0, -0.0722/0.7152, 1]);
cyclic_map = 1.055 * cyclic_map.^(1/2.4) - 0.055; % Linear RGB to sRGB
diverging_map = interp1([0, 0.5, 1], ...
    [0.15 0.30 0.75; 1 1 1; 0.75 0.15 0.15], linspace(0, 1, color_count));

%% Reflectance map
figure('Name', 'TE reflectance', 'Color', 'w');
imagesc(wavelength, theta, R);
axis xy;
xlabel('Wavelength (nm)');
ylabel('Incidence angle (deg)');
title('TE reflectance R');
colormap(gca, sequential_map);
clim([0, 1]);
cb = colorbar;
cb.Label.String = 'R (dimensionless)';

%% Reflection phase map
figure('Name', 'TE reflection phase', 'Color', 'w');
imagesc(wavelength, theta, phase);
axis xy;
xlabel('Wavelength (nm)');
ylabel('Incidence angle (deg)');
title('TE reflection phase at the air/film surface');
colormap(gca, cyclic_map);
clim([-pi, pi]);
cb = colorbar;
cb.Ticks = [-pi, -pi/2, 0, pi/2, pi];
cb.TickLabels = {'-\pi', '-\pi/2', '0', '\pi/2', '\pi'};
cb.Label.String = 'arg(r) (rad)';

%% Reflectance-change map
figure('Name', 'TE reflectance change', 'Color', 'w');
imagesc(wavelength, theta, delta_R);
axis xy;
xlabel('Wavelength (nm)');
ylabel('Incidence angle (deg)');
title('\DeltaR = R - R_{bare}');
colormap(gca, diverging_map);
% Equal limits keep zero at white even if the data are predominantly positive.
clim([-1, 1] * max(abs(delta_R(:))));
cb = colorbar;
cb.Label.String = '\DeltaR (dimensionless)';
drawnow;
