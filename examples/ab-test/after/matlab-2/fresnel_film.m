% TE reflection of an air / Si3N4 film / semi-infinite SiO2 stack.
% Model: isotropic, nonmagnetic, lossless media and coherent plane waves.
% Maxwell tangential-field continuity gives r_ij = (q_i-q_j)/(q_i+q_j),
% q_j = n_j*cos(theta_j), and r = (r01+r12*exp(2i*delta)) /
% (1+r01*r12*exp(2i*delta)), delta = 2*pi*q1*d/wavelength.
% Convention: exp(-i*omega*t), positive z into the substrate; r is evaluated
% at the air/film surface. The substrate has no rear reflecting interface.
% Input contains n only: extinction coefficient k is assumed to be zero.
clear; close all; clc;

%% Parameters
n0 = 1;                         % Air refractive index (dimensionless).
n2 = 1.45;                      % SiO2 refractive index (dimensionless).
d = 200;                        % Si3N4 film thickness (nm).
wavelength = 400:1:1100;         % Vacuum wavelength (nm).
theta = (0:0.1:89).';            % External incidence angle (deg).
index_file = 'SiN_index.csv';    % File beside this script: wavelength (nm), n.
tolerance = 1e-10;              % Absolute numerical consistency tolerance.
check_wavelength = [550, 900];   % Independent boundary-solve points (nm).
check_theta = [0, 60];          % Independent boundary-solve angles (deg).
color_count = 257;              % Odd count includes zero in the diverging map.
phase_lightness = 0.72;         % Constant Oklab lightness (dimensionless).
phase_chroma = 0.10;            % Constant Oklab chroma (dimensionless).

%% Read dispersion and state the extrapolation assumption
data = readmatrix(fullfile(fileparts(mfilename('fullpath')), index_file));
assert(size(data, 2) == 2 && size(data, 1) >= 2, ...
    'Expected at least two rows and exactly two numeric columns.');
assert(all(isfinite(data(:))) && isreal(data), ...
    'The dispersion table contains nonfinite or complex entries.');
assert(all(data(:, 1) > 0) && all(diff(data(:, 1)) > 0) && all(data(:, 2) > 0), ...
    'Wavelengths must be positive and strictly increasing, and n must be positive.');
assert(n0 > 0 && n2 > 0 && d >= 0 && all(wavelength > 0) && ...
    all(theta >= 0 & theta < 90), 'Invalid optical parameters.');
% Piecewise linear interpolation, with EXPLICIT endpoint-slope extrapolation.
% The supplied table ends at 1000 nm; its final slope is assumed to continue
% to 1100 nm. This is a modeling assumption, not measured dispersion data.
n1 = interp1(data(:, 1), data(:, 2), wavelength, 'linear', 'extrap');
outside = wavelength < data(1, 1) | wavelength > data(end, 1);
if any(outside)
    fprintf(['Dispersion data: %.1f--%.1f nm. Endpoint-slope linear ', ...
        'extrapolation used at %.1f--%.1f nm; n = %.7f--%.7f.\n'], ...
        data(1, 1), data(end, 1), min(wavelength(outside)), ...
        max(wavelength(outside)), min(n1(outside)), max(n1(outside)));
end
assert(all(isfinite(n1) & n1 > 0), 'Invalid interpolated/extrapolated n.');

%% Fresnel amplitudes on the angle-by-wavelength grid
% Conservation of tangential wavevector: n_j*sin(theta_j)=n0*sin(theta).
% All lengths are in nm, so delta is dimensionless without SI conversion.
q0 = n0 * cosd(theta);
q1 = sqrt(complex(n1.^2 - (n0 * sind(theta)).^2));
q2 = sqrt(complex(n2^2 - (n0 * sind(theta)).^2));
% .^, .*, and ./ act pointwise; implicit expansion forms the 2D grid.
% The principal square root gives positive real q for propagation and
% positive imaginary q for decay into a passive medium.
r01 = (q0 - q1) ./ (q0 + q1);
r12 = (q1 - q2) ./ (q1 + q2);
delta = 2 * pi * d * q1 ./ wavelength;
round_trip = exp(2i * delta);
denominator = 1 + r01 .* r12 .* round_trip;
r = (r01 + r12 .* round_trip) ./ denominator;
R = abs(r).^2;
assert(all(abs(r(:)) > 0), ...
    'An exact reflection zero occurs: its reflection phase is undefined.');
phase = angle(r);                % Principal phase (rad), in [-pi, pi].
r_bare = (q0 - q2) ./ (q0 + q2);
R_bare = abs(r_bare).^2;
DeltaR = R - R_bare;             % Absolute reflectance difference, not a ratio.
assert(all(isfinite(r(:))) && all(isfinite(DeltaR(:))), ...
    'Nonfinite reflection result: inspect optical parameters and denominator.');
assert(all(R(:) >= -tolerance & R(:) <= 1 + tolerance), ...
    'Reflectance outside physical bounds: min %.16g, max %.16g.', min(R(:)), max(R(:)));

%% Physical consistency checks at the full scan resolution
% Transmitted E amplitude at the film/substrate surface; q2/q0 converts
% squared amplitude into the transmitted-to-incident normal power ratio.
t01 = 2 * q0 ./ (q0 + q1);
t12 = 2 * q1 ./ (q1 + q2);
t = t01 .* t12 .* exp(1i * delta) ./ denominator;
T = real(q2) ./ q0 .* abs(t).^2;
energy_error = max(abs(R + T - 1), [], 'all');
assert(isfinite(energy_error) && energy_error < tolerance, ...
    'Energy balance failed: max |R+T-1| = %.16g.', energy_error);
% Setting d=0 must recover the bare air/SiO2 interface at every grid point.
r_zero = (r01 + r12) ./ (1 + r01 .* r12);
zero_error = max(abs(r_zero - r_bare), [], 'all');
assert(isfinite(zero_error) && zero_error < tolerance, ...
    'Zero-thickness limit failed: max amplitude error = %.16g.', zero_error);
R_normal = ((n0 - n2) / (n0 + n2))^2;
assert(abs(R_bare(1) - R_normal) < tolerance, ...
    'Bare normal-incidence Fresnel check failed.');
fprintf('Grid: %d angles x %d wavelengths; d = %.1f nm.\n', ...
    numel(theta), numel(wavelength), d);
fprintf('R range: %.9f--%.9f; DeltaR range: %.9f--%.9f.\n', ...
    min(R(:)), max(R(:)), min(DeltaR(:)), max(DeltaR(:)));
fprintf('Max |R+T-1|: %.3e; zero-thickness error: %.3e.\n', energy_error, zero_error);
fprintf('Bare normal-incidence reflectance: %.9f.\n', R_normal);
% Independently solve four tangential E/H boundary equations for unknowns
% [r, A_forward, B_backward, t] at two wavelength/angle pairs.
for point = 1:numel(check_wavelength)
    lam = check_wavelength(point);
    ang = check_theta(point);
    ni = interp1(data(:, 1), data(:, 2), lam, 'linear', 'extrap');
    qa = n0 * cosd(ang);
    qb = sqrt(complex(ni^2 - (n0 * sind(ang))^2));
    qc = sqrt(complex(n2^2 - (n0 * sind(ang))^2));
    p = exp(1i * 2 * pi * qb * d / lam);
    boundary = [1, -1, -1, 0; ...
        -qa, -qb, qb, 0; ...
        0, p, 1/p, -1; ...
        0, qb*p, -qb/p, -qc];
    fields = boundary \ [-1; -qa; 0; 0];
    [~, col] = min(abs(wavelength - lam));
    [~, row] = min(abs(theta - ang));
    assert(abs(wavelength(col)-lam) < tolerance && abs(theta(row)-ang) < tolerance, ...
        'The independent check points must be on the scan grid.');
    boundary_error = abs(fields(1) - r(row, col));
    assert(all(isfinite(fields)) && boundary_error < tolerance, ...
        'Boundary check failed at %.1f nm, %.1f deg: error %.16g.', lam, ang, boundary_error);
    fprintf('Boundary check: %.0f nm, %.0f deg, R = %.9f, amplitude error %.3e.\n', ...
        lam, ang, R(row, col), boundary_error);
end

%% Colormaps without additional toolboxes
% A closed circle of constant Oklab lightness/chroma provides a cyclic map.
% Oklab -> linear sRGB conversion uses the published Oklab definition.
% Source: https://bottosson.github.io/posts/oklab/ (inverse conversion).
% Low chroma keeps the entire circle inside the sRGB gamut; no clipping.
phi = linspace(0, 2*pi, color_count).';
Lab = [phase_lightness * ones(color_count, 1), ...
    phase_chroma*cos(phi), phase_chroma*sin(phi)];
lms = Lab * [1, 1, 1; 0.3963377774, -0.1055613458, -0.0894841775; ...
    0.2158037573, -0.0638541728, -1.2914855480];
rgb_linear = (lms.^3) * [4.0767416621, -1.2684380046, -0.0041960863; ...
    -3.3077115913, 2.6097574011, -0.7034186147; ...
    0.2309699292, -0.3413193965, 1.7076147010];
assert(all(rgb_linear(:) >= 0 & rgb_linear(:) <= 1), ...
    'The cyclic colormap is outside the sRGB gamut.');
cyclic_map = 12.92 * rgb_linear;
nonlinear = rgb_linear > 0.0031308;
cyclic_map(nonlinear) = 1.055 * rgb_linear(nonlinear).^(1/2.4) - 0.055;
diverging_map = interp1([0, 0.5, 1], ...
    [0.15, 0.35, 0.75; 1, 1, 1; 0.75, 0.15, 0.15], ...
    linspace(0, 1, color_count));

%% Display three maps
% Data columns follow wavelength and rows follow incidence angle.
figure('Name', 'TE reflectance', 'Color', 'w');
imagesc(wavelength, theta, R);
axis xy;
xlabel('Wavelength (nm)'); ylabel('Incidence angle (deg)');
title('TE reflectance R');
colormap(gca, parula(color_count)); clim([0, 1]);
cb = colorbar; cb.Label.String = 'R (dimensionless)';
mark_dispersion_range(data, wavelength);

figure('Name', 'TE reflection phase', 'Color', 'w');
imagesc(wavelength, theta, phase);
axis xy;
xlabel('Wavelength (nm)'); ylabel('Incidence angle (deg)');
title('TE reflection phase at the air/film surface');
colormap(gca, cyclic_map); clim([-pi, pi]);
cb = colorbar; cb.Label.String = 'arg(r) (rad)';
cb.Ticks = [-pi, -pi/2, 0, pi/2, pi];
cb.TickLabels = {'-\pi', '-\pi/2', '0', '\pi/2', '\pi'};
mark_dispersion_range(data, wavelength);

figure('Name', 'TE reflectance change', 'Color', 'w');
imagesc(wavelength, theta, DeltaR);
axis xy;
xlabel('Wavelength (nm)'); ylabel('Incidence angle (deg)');
title('TE reflectance change \DeltaR = R - R_{bare}');
colormap(gca, diverging_map);
span = max(abs(DeltaR(:)));
clim([-span, span]);
cb = colorbar; cb.Label.String = '\DeltaR (dimensionless)';
mark_dispersion_range(data, wavelength);
drawnow;

%% Local functions
function mark_dispersion_range(data, wavelength)
% Label where the assumed extrapolated dispersion enters each map.
if wavelength(end) > data(end, 1)
    xline(data(end, 1), '--k', 'Extrapolation to right', ...
        'LabelOrientation', 'aligned');
end
if wavelength(1) < data(1, 1)
    xline(data(1, 1), '--k', 'Extrapolation to left', ...
        'LabelOrientation', 'aligned');
end
end
