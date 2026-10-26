%% TE reflection: air / dispersive Si3N4 film / semi-infinite SiO2
% Run this script in MATLAB. No additional toolboxes are required.
% Assumptions: isotropic, nonmagnetic, lossless media; coherent film;
% vacuum wavelength in nm; incidence angle measured from the surface normal.
% Convention: E(z,t) ~ exp(i*kz*z-i*omega*t), z points into the sample.
% r = reflected/incident tangential electric field at the TOP film surface.
% Phase is the wrapped principal value in [-pi,pi], in radians.
% The input ends at 1000 nm. Beyond the data, use linear extrapolation
% from the nearest two endpoint samples; this is an assumption, not data.
% Outputs beside this script: three PNG figures and fresnel_film_results.mat.

script_dir = fileparts(mfilename('fullpath'));
data_file = fullfile(script_dir, 'SiN_index.csv');
data = readmatrix(data_file);
assert(size(data,2) >= 2, 'CSV must contain wavelength_nm and n columns.');
data = data(:,1:2);
assert(size(data,1) >= 2 && all(isfinite(data(:))), ...
    'CSV must contain at least two finite numeric rows.');
data = sortrows(data,1);
assert(all(diff(data(:,1)) > 0), 'Wavelengths must be unique.');
assert(all(data(:) > 0), 'Wavelengths and refractive indices must be positive.');

lambda_nm = 400:1:1100;                 % columns
theta_deg = (0:0.1:89).';               % rows
n_air = 1;
n_substrate = 1.45;
thickness_nm = 200;
% Linear interpolation within the data; endpoint-linear extrapolation outside.
n_film = interp1(data(:,1), data(:,2), lambda_nm, 'linear', 'extrap');
extrapolated = lambda_nm < data(1,1) | lambda_nm > data(end,1);
if any(extrapolated)
    warning('fresnel_film:ExtrapolatedIndex', ...
        ['Index data cover %.0f-%.0f nm; %d wavelength samples use ' ...
         'endpoint-linear extrapolation (n at 1100 nm = %.6f).'], ...
        data(1,1), data(end,1), nnz(extrapolated), n_film(end));
end
assert(all(isfinite(n_film) & n_film > 0), 'Invalid interpolated index.');

%% Fresnel amplitudes and coherent multiple reflections
% Conserved tangential wavevector: kx/k0 = n_air*sin(theta).
% TE optical admittance q_j = n_j*cos(theta_j) = kz_j/k0.
% Positive square root gives forward propagation or decay into the sample.
q0 = n_air*cosd(theta_deg);
kx_over_k0 = n_air*sind(theta_deg);
q1 = sqrt(complex(n_film.^2 - kx_over_k0.^2));
q2 = sqrt(complex(n_substrate^2 - kx_over_k0.^2));
r01 = (q0-q1)./(q0+q1);
r12 = (q1-q2)./(q1+q2);
delta = 2*pi*thickness_nm*q1./lambda_nm; % one-way film phase
round_trip = exp(2i*delta);
denominator = 1 + r01.*r12.*round_trip;
r = (r01 + r12.*round_trip)./denominator;
R = abs(r).^2;
phase_r_rad = angle(r);
phase_r_rad(abs(r) < 1e-12) = NaN;       % phase undefined at a reflection zero
r_bare = (q0-q2)./(q0+q2);
R_bare = repmat(abs(r_bare).^2, 1, numel(lambda_nm));
DeltaR = R - R_bare;                    % absolute change, not percent change

%% Physical and numerical checks (fail loudly if a check is violated)
% Transmission power must include the TE admittance/flux ratio.
t = (2*q0./(q0+q1)).*(2*q1./(q1+q2)).*exp(1i*delta)./denominator;
T = real(q2)./real(q0).*abs(t).^2;
checks.energy_error = max(abs(R+T-1), [], 'all');
r_zero_thickness = (r01+r12)./(1+r01.*r12);
checks.zero_thickness_error = max(abs(r_zero_thickness-r_bare), [], 'all');
checks.normal_bare_error = abs(R_bare(1,1) - ...
    ((n_air-n_substrate)/(n_air+n_substrate))^2);
assert(all(isfinite(R(:))) && all(R(:) >= 0 & R(:) <= 1+1e-12), ...
    'Reflectance is nonfinite or outside the passive range.');
assert(checks.energy_error < 1e-10, 'Lossless energy conservation failed.');
assert(checks.zero_thickness_error < 1e-10, 'Zero-thickness limit failed.');
assert(checks.normal_bare_error < 1e-12, 'Normal-incidence bare limit failed.');

% Independently solve E and H continuity for [r; forward; backward; t]
% at representative wavelengths and angles to verify the phase/sign convention.
checks.boundary_solution_error = 0;
for ia = [1, 451, numel(theta_deg)]
    for il = [1, 351, numel(lambda_nm)]
        a = q0(ia); b = q1(ia,il); c = q2(ia);
        p = exp(1i*delta(ia,il));
        boundary_matrix = [1, -1, -1, 0; ...
            -a, -b, b, 0; ...
            0, p, 1/p, -1; ...
            0, b*p, -b/p, -c];
        amplitudes = boundary_matrix \ [-1; -a; 0; 0];
        checks.boundary_solution_error = max(checks.boundary_solution_error, ...
            abs(amplitudes(1)-r(ia,il)));
    end
end
assert(checks.boundary_solution_error < 1e-10, ...
    'Independent boundary-condition solution failed.');

%% Three maps: wavelength horizontal, incidence angle vertical
% Dashed vertical lines mark data endpoints within the scanned interval.
maps = {R, phase_r_rad, DeltaR};
map_titles = {'TE reflectance R', 'TE reflection phase arg(r)', ...
    'TE reflectance change \DeltaR = R - R_{bare}'};
color_labels = {'R', 'arg(r) (rad)', '\DeltaR (absolute)'};
output_names = {'fresnel_R.png', 'fresnel_phase.png', 'fresnel_DeltaR.png'};
dr_limit = max(abs(DeltaR(:)));
if dr_limit == 0, dr_limit = 1; end
limits = {[0,1], [-pi,pi], [-dr_limit,dr_limit]};
% Blue-white-red diverging map, centered at DeltaR = 0.
diverging = interp1([0,0.5,1], [0.12,0.30,0.72; 1,1,1; 0.75,0.10,0.12], ...
    linspace(0,1,257));
for imap = 1:3
    fig = figure('Color','w', 'Name',output_names{imap}, ...
        'Position',[100+30*imap,100+30*imap,1000,650]);
    ax = axes(fig);
    imagesc(ax,lambda_nm,theta_deg,maps{imap},'AlphaData',~isnan(maps{imap}));
    ax.Toolbar.Visible = 'off';
    set(ax,'YDir','normal','FontSize',12,'Layer','top');
    xlabel(ax,'Vacuum wavelength (nm)');
    ylabel(ax,'Incidence angle (deg)');
    xlim(ax,[lambda_nm(1),lambda_nm(end)]);
    ylim(ax,[theta_deg(1),theta_deg(end)]);
    clim(ax,limits{imap});
    if imap == 1
        colormap(ax,parula(256));
    elseif imap == 2
        colormap(ax,hsv(256));             % cyclic map for wrapped phase
    else
        colormap(ax,diverging);
    end
    cb = colorbar(ax);
    cb.Label.String = color_labels{imap};
    if imap == 2
        cb.Ticks = [-pi,-pi/2,0,pi/2,pi];
        cb.TickLabels = {'-\pi','-\pi/2','0','\pi/2','\pi'};
        cb.TickLabelInterpreter = 'tex';
    end
    title(ax,{map_titles{imap}, ...
        'Air / Si_3N_4 (200 nm) / SiO_2 (n = 1.45)'});
    if any(extrapolated)
        for edge_nm = [data(1,1),data(end,1)]
            if edge_nm > lambda_nm(1) && edge_nm < lambda_nm(end)
                xline(ax,edge_nm,'k--','LineWidth',1.2);
            end
        end
        if lambda_nm(end) > data(end,1)
            text(ax,(data(end,1)+lambda_nm(end))/2,85,'n extrap.', ...
                'HorizontalAlignment','center','FontSize',10, ...
                'BackgroundColor','white','Margin',3);
        end
    end
    exportgraphics(fig,fullfile(script_dir,output_names{imap}),'Resolution',200);
end

assumptions = struct('index_interpolation','linear', ...
    'index_extrapolation','linear from two nearest endpoint samples', ...
    'time_convention','exp(-i*omega*t)', ...
    'phase_reference','air/film interface', ...
    'phase_units','radian; principal value [-pi,pi]', ...
    'media','isotropic, nonmagnetic, lossless; semi-infinite substrate');
save(fullfile(script_dir,'fresnel_film_results.mat'), ...
    'lambda_nm','theta_deg','n_film','n_air','n_substrate','thickness_nm', ...
    'r','R','phase_r_rad','r_bare','R_bare','DeltaR','T', ...
    'data','extrapolated','assumptions','checks');
fprintf('Grid: %d angles x %d wavelengths.\n',numel(theta_deg),numel(lambda_nm));
fprintf('R range: [%.8g, %.8g]; DeltaR range: [%.8g, %.8g].\n', ...
    min(R(:)),max(R(:)),min(DeltaR(:)),max(DeltaR(:)));
fprintf('Bare normal-incidence R: %.10f.\n',R_bare(1,1));
fprintf('Max errors: energy %.3g; zero thickness %.3g; boundary solve %.3g.\n', ...
    checks.energy_error,checks.zero_thickness_error,checks.boundary_solution_error);
fprintf('Saved three PNG figures and fresnel_film_results.mat in %s\n',script_dir);
