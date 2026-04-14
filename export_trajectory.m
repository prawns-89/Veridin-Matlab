% export_trajectory.m
% Extracts and propagates the optimal trajectory to generate 5-day coordinates

addpath('src');
c = constants();
ephemeris = EphemerisSystem('data/veridian_ephemeris.csv');

if ~isfile('data/optimal_trajectory.csv')
    error('optimal_trajectory.csv not found. Please run main.m first.');
end

opts = readtable('data/optimal_trajectory.csv');
t_depart = opts.departure_mjd(1);
tof1 = opts.tof_ventus(1);
tof2 = opts.tof_glacia(1);

t_flyby = t_depart + tof1;

[r_C, ~] = ephemeris.get_state('Caelus', t_depart);
[r_V, ~] = ephemeris.get_state('Ventus', t_flyby);
[r_G, ~] = ephemeris.get_state('Glacia', t_flyby + tof2);

tof1_sec = tof1 * 86400;
tof2_sec = tof2 * 86400;

[v1_depart, ~] = lambert(r_C, r_V, tof1_sec, c.MU_STAR, 'prograde');
[v2_depart, ~] = lambert(r_V, r_G, tof2_sec, c.MU_STAR, 'prograde');

ode_star = @(t, y) [y(4:6); -c.MU_STAR * y(1:3) / norm(y(1:3))^3];
options = odeset('RelTol', 1e-8, 'AbsTol', 1e-10);

t_span1 = (0:5:tof1) * 86400; % Every 5 days in seconds
if t_span1(end) ~= tof1_sec
    t_span1 = [t_span1, tof1_sec];
end
[~, y1] = ode45(ode_star, t_span1, [r_C; v1_depart], options);

t_span2 = (0:5:tof2) * 86400;
if t_span2(end) ~= tof2_sec
    t_span2 = [t_span2, tof2_sec];
end
[~, y2] = ode45(ode_star, t_span2, [r_V; v2_depart], options);

% Stitch together
time_mjd = [t_depart + t_span1/86400, t_flyby + t_span2(2:end)/86400]';
x = [y1(:,1); y2(2:end,1)];
y = [y1(:,2); y2(2:end,2)];
z = [y1(:,3); y2(2:end,3)];

T_out = table(time_mjd, x, y, z, 'VariableNames', {'MJD', 'X_km', 'Y_km', 'Z_km'});
if ~exist('results', 'dir')
    mkdir('results');
end
writetable(T_out, 'results/spacecraft_5day_coords.csv');
fprintf('Exported 5-day stepwise trajectory to results/spacecraft_5day_coords.csv\n');
