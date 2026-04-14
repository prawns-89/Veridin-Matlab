% main.m
% Mission Veridian: Gravity-Assist Trajectory Optimization
addpath('src');

fprintf('Mission Veridian: Gravity-Assist Trajectory Optimization\n');

c = constants();

try
    ephemeris = EphemerisSystem('data/veridian_ephemeris.csv');
catch ME
    fprintf('Failed to load ephemeris: %s\n', ME.message);
    return;
end

t_depart_grid = 60000:10:61095;
tof1_grid = 200:10:800;
tof2_grid = 200:10:800;

total_combinations = length(t_depart_grid) * length(tof1_grid) * length(tof2_grid);
fprintf('Running exact specification grid search over %d combinations...\n', total_combinations);

best_solution = search(ephemeris, t_depart_grid, tof1_grid, tof2_grid);

if isempty(best_solution)
    fprintf('No valid trajectories found within standard unpowered constraint.\n');
    t = table({'No trajectory found'}, 'VariableNames', {'status'});
    writetable(t, 'data/optimal_trajectory.csv');
    return;
end

res = best_solution.results;
fprintf('\nOptimal Trajectory Found:\n');
fprintf('Departure Date (MJD): %.1f\n', best_solution.t_depart);
fprintf('TOF 1: %.1f days\n', best_solution.tof_1);
fprintf('TOF 2: %.1f days\n', best_solution.tof_2);
fprintf('Total DV: %.3f km/s\n', res.total_dv);
fprintf('  Departure DV: %.3f km/s\n', res.dv_depart);
fprintf('  DSM / Powered DV: %.3f km/s\n', res.dv_flyby);
fprintf('  Arrival DV: %.3f km/s\n', res.dv_arrive);
fprintf('Ventus Flyby Periapsis: %.1f km\n', res.rp_ventus);

T = table(best_solution.t_depart, best_solution.tof_1, ...
    res.rp_ventus - c.R_VENTUS_CLOUD_TOP, best_solution.tof_2, res.total_dv, ...
    'VariableNames', {'departure_mjd', 'tof_ventus', 'altitude', 'tof_glacia', 'deltaV_total'});
writetable(T, 'data/optimal_trajectory.csv');
fprintf('Saved optimal trajectory properties to data/optimal_trajectory.csv\n');
