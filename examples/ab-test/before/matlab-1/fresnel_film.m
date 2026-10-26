%% TE reflection: air / dispersive Si3N4 film / semi-infinite SiO2
% Run this script in MATLAB R2019a or later; no toolboxes are required.
% Assumptions: planar, isotropic, nonmagnetic, lossless media; coherent film;
% semi-infinite substrate (no reflection from its back surface).
% Time convention: exp(-1i*omega*t), forward wave exp(+1i*kz*z).
% r is the electric-field reflection coefficient at the air/film surface.
% All lengths below are in nm. Rows = incidence angles; columns = wavelengths.

script_dir = fileparts(mfilename('fullpath'));
lambda_nm = 400:1:1100;
theta_deg = (0:0.1:89).';
n_air = 1;
n_substrate = 1.45;
thickness_nm = 200;

%% Read and validate refractive-index measurements
input_file = fullfile(script_dir, 'SiN_index.csv');
index_data = readmatrix(input_file);
assert(size(index_data, 2) >= 2, 'CSV must contain wavelength_nm and n.');
index_data = index_data(:, 1:2);
assert(size(index_data, 1) >= 2 && all(isfinite(index_data(:))), ...
    'CSV must contain at least two finite numeric data rows.');
index_data = sortrows(index_data, 1);
assert(all(diff(index_data(:, 1)) > 0), 'CSV wavelengths must be unique.');
assert(all(index_data(:) > 0), 'Wavelengths and refractive indices must be positive.');

% Linear interpolation inside the data range. Outside it, continue the
% nearest endpoint segment linearly. This is an explicit numerical assumption,
% not a measured or independently validated dispersion model.
n_film = interp1(index_data(:, 1), index_data(:, 2), lambda_nm, 'linear', 'extrap');
extrapolated = lambda_nm < index_data(1, 1) | lambda_nm > index_data(end, 1);
assert(all(n_film > 0), 'Extrapolation produced a nonphysical refractive index.');
if any(extrapolated)
    warning('fresnel_film:ExtrapolatedIndex', ...
        ['Index data span %.0f-%.0f nm. %d scan points use linear endpoint ' ...
         'extrapolation; these predictions need additional index data.'], ...
        index_data(1, 1), index_data(end, 1), nnz(extrapolated));
end

%% Fresnel amplitudes and coherent round-trip propagation
% q_j = n_j*cos(theta_j) = kz_j/k0 is the TE optical admittance.
% Snell's law fixes n_j*sin(theta_j) = n_air*sin(theta_air).
q0 = n_air*cosd(theta_deg);
parallel_index = n_air*sind(theta_deg);
q1 = sqrt(complex(n_film.^2 - parallel_index.^2));
q2 = sqrt(complex(n_substrate^2 - parallel_index.^2));
r01 = (q0 - q1)./(q0 + q1);
r12 = (q1 - q2)./(q1 + q2);
delta = 2*pi*thickness_nm*q1./lambda_nm;
round_trip = exp(2i*delta);
r = (r01 + r12.*round_trip)./(1 + r01.*r12.*round_trip);
R = abs(r).^2;
phase_r = angle(r);                    % Wrapped phase in [-pi, pi], radians
phase_r(abs(r) < 1e-12) = NaN;          % Phase is undefined at zero amplitude
r_bare = (q0 - q2)./(q0 + q2);
R_bare = repmat(abs(r_bare).^2, 1, numel(lambda_nm));
delta_R = R - R_bare;                  % Absolute reflectance difference

%% Physical consistency checks (no clipping of computed reflectance)
t01 = 2*q0./(q0 + q1);
t12 = 2*q1./(q1 + q2);
t = t01.*t12.*exp(1i*delta)./(1 + r01.*r12.*round_trip);
T = real(q2)./real(q0).*abs(t).^2;
energy_error = max(abs(R(:) + T(:) - 1));
r_zero_thickness = (r01 + r12)./(1 + r01.*r12);
zero_thickness_error = max(abs(r_zero_thickness - r_bare), [], 'all');
normal_bare_expected = ((n_air - n_substrate)/(n_air + n_substrate))^2;
assert(all(isfinite(R(:))) && all(isfinite(r(:))), 'Nonfinite Fresnel result.');
assert(all(R(:) >= 0 & R(:) <= 1 + 1e-12), 'Reflectance outside [0,1].');
assert(energy_error < 1e-10, 'Lossless energy conservation failed.');
assert(zero_thickness_error < 1e-10, 'Zero-thickness limit failed.');
assert(abs(R_bare(1, 1) - normal_bare_expected) < 1e-12, ...
    'Normal-incidence bare-interface check failed.');

%% Three two-dimensional maps; PNGs are saved beside this script
% Phase uses a cyclic color map; Delta R uses a zero-centered diverging map.
blue_white_red = [linspace(0,1,128).', linspace(0.25,1,128).', ones(128,1); ...
    ones(128,1), linspace(1,0.2,128).', linspace(1,0,128).'];
maps = {R, phase_r, delta_R};
map_titles = {'TE reflectance R', 'TE reflection phase arg(r)', ...
    'TE reflectance change: \DeltaR = R - R_{bare}'};
bar_labels = {'Reflectance', 'Phase (rad)', 'Absolute reflectance difference'};
file_stems = {'fresnel_R', 'fresnel_phase', 'fresnel_deltaR'};
dr_limit = max(abs(delta_R(:)));
if dr_limit == 0
    dr_limit = eps;
end
color_limits = {[0,1], [-pi,pi], [-dr_limit,dr_limit]};
color_maps = {parula(256), hsv(256), blue_white_red};
figures = gobjects(1,3);
for map_idx = 1:3
    figures(map_idx) = figure('Color', 'w', 'Name', file_stems{map_idx}, ...
        'Position', [100 + 30*map_idx, 100 + 30*map_idx, 1000, 620]);
    ax = axes(figures(map_idx));
    imagesc(ax, lambda_nm, theta_deg, maps{map_idx});
    set(ax, 'YDir', 'normal', 'FontSize', 12, 'Layer', 'top');
    xlim(ax, [lambda_nm(1), lambda_nm(end)]);
    ylim(ax, [theta_deg(1), theta_deg(end)]);
    xlabel(ax, 'Wavelength (nm)');
    ylabel(ax, 'Incidence angle (deg)');
    title(ax, {map_titles{map_idx}, 'Air / Si_3N_4 (200 nm) / SiO_2 (n = 1.45)'});
    colormap(ax, color_maps{map_idx});
    caxis(ax, color_limits{map_idx});
    cb = colorbar(ax);
    cb.Label.String = bar_labels{map_idx};
    if map_idx == 2
        cb.Ticks = [-pi, -pi/2, 0, pi/2, pi];
        cb.TickLabels = {'-pi', '-pi/2', '0', 'pi/2', 'pi'};
    end
    if lambda_nm(end) > index_data(end,1)
        xline(ax, index_data(end,1), '--k', 'Extrapolated n to right', ...
            'LabelOrientation', 'aligned', 'LineWidth', 1.2);
    end
    if lambda_nm(1) < index_data(1,1)
        xline(ax, index_data(1,1), '--k', 'Extrapolated n to left', ...
            'LabelOrientation', 'aligned', 'LineWidth', 1.2);
    end
    print(figures(map_idx), fullfile(script_dir, [file_stems{map_idx}, '.png']), ...
        '-dpng', '-r180');
end

save(fullfile(script_dir, 'fresnel_film_results.mat'), ...
    'lambda_nm', 'theta_deg', 'n_film', 'index_data', 'extrapolated', ...
    'n_air', 'n_substrate', 'thickness_nm', 'r', 'R', 'phase_r', ...
    'r_bare', 'R_bare', 'delta_R', 'T', 'energy_error', 'zero_thickness_error');
fprintf('Grid: %d angles x %d wavelengths.\n', numel(theta_deg), numel(lambda_nm));
fprintf('n_film at 1100 nm: %.6f (extrapolated if outside CSV range).\n', n_film(end));
fprintf('max |R+T-1| = %.3e; zero-thickness amplitude error = %.3e.\n', ...
    energy_error, zero_thickness_error);
fprintf('Bare normal-incidence R = %.8f.\n', R_bare(1,1));
fprintf('R range: [%.8f, %.8f]; Delta R range: [%.8f, %.8f].\n', ...
    min(R(:)), max(R(:)), min(delta_R(:)), max(delta_R(:)));
fprintf('Saved three PNG maps and fresnel_film_results.mat in %s\n', script_dir);
