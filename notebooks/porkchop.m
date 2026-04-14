% porkchop.m
% Generates a Porkchop Plot (Contour map of Delta-V)
% Save this in `notebooks/porkchop.m` or run it from the root directory.

addpath('../src'); % Need to use src/ if run from /notebooks, so let's guarantee paths works:
addpath(fullfile(fileparts(pwd), 'src'));
try
    c = constants();
    ephemeris = EphemerisSystem('../data/veridian_ephemeris.csv');
catch
    addpath('src');
    c = constants();
    ephemeris = EphemerisSystem('data/veridian_ephemeris.csv');
end

departure_dates = 60000:5:61100;
tof1_range = 200:10:800;

[X, Y] = meshgrid(departure_dates, tof1_range);
Z = zeros(size(X));

% We use the optimal TOF2 found in optimal_trajectory.csv if available.
tof_2_opt = 420; % Default fallback
if isfile('data/optimal_trajectory.csv')
    opts = readtable('data/optimal_trajectory.csv');
    tof_2_opt = opts.tof_glacia(1);
elseif isfile('../data/optimal_trajectory.csv')
    opts = readtable('../data/optimal_trajectory.csv');
    tof_2_opt = opts.tof_glacia(1);
end

fprintf('Generating Porkchop plot for fixed TOF2 = %.1f days...\n', tof_2_opt);

for i = 1:size(X, 1)
    for j = 1:size(X, 2)
        t_dep = X(i,j);
        tof1 = Y(i,j);
        
        if tof1 + tof_2_opt > c.MAX_MISSION_DURATION
            Z(i,j) = NaN;
            continue;
        end
        
        res = evaluate_trajectory(ephemeris, t_dep, tof1, tof_2_opt, 'prograde', c);
        if ~isempty(res)
            Z(i,j) = res.total_dv;
        else
            Z(i,j) = NaN;
        end
    end
end

figure('Name', 'Porkchop Plot');
contourf(X, Y, Z, 50, 'LineColor', 'none');
colormap parula;
colorbar;
xlabel('Departure Date (MJD)');
ylabel('Time of Flight to Ventus (Days)');
title(sprintf('Porkchop Plot: Total Delta-V (Fixed TOF2 = %.1f d)', tof_2_opt));
