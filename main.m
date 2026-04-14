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

t_depart_grid_coarse = 60000:15:61095;
tof1_grid_coarse = 200:15:800;
tof2_grid_coarse = 200:15:800;

fprintf('--- PASS 1: Coarse Grid Search ---\n');
fprintf('Evaluating broad geometric combinations at 15-day intervals...\n');
best_solution = search(ephemeris, t_depart_grid_coarse, tof1_grid_coarse, tof2_grid_coarse);

if ~isempty(best_solution)
    fprintf('Pass 1 Optimal Found (DV: %.2f km/s) at MJD %.1f | TOF1: %.1f | TOF2: %.1f\n', ...
        best_solution.results.total_dv, best_solution.t_depart, best_solution.tof_1, best_solution.tof_2);
    fprintf('\n--- PASS 2: Fine Grid Search ---\n');
    fprintf('Evaluating localized optimum at intense 1-day intervals ±15 days...\n');
    
    t_depart_grid_fine = (best_solution.t_depart - 15) : 1 : (best_solution.t_depart + 15);
    tof1_grid_fine = (best_solution.tof_1 - 15) : 1 : (best_solution.tof_1 + 15);
    tof2_grid_fine = (best_solution.tof_2 - 15) : 1 : (best_solution.tof_2 + 15);
    
    best_solution_fine = search(ephemeris, t_depart_grid_fine, tof1_grid_fine, tof2_grid_fine);
    if ~isempty(best_solution_fine) && (best_solution_fine.results.total_dv < best_solution.results.total_dv)
        best_solution = best_solution_fine;
    end
end

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
