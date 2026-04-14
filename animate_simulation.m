% animate_simulation.m
% Generates dual-view animation (Veridian-centered and Ventus-centered)

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
t_arrive = t_flyby + tof2;

if ~isfile('results/spacecraft_5day_coords.csv')
    export_trajectory;
end

sc_coords = readtable('results/spacecraft_5day_coords.csv');

% Create Figure
fig = figure('Name', 'Mission Veridian Simulation', 'Position', [100 100 1200 600], 'Color', 'w');

% --- Left Subplot: Heliocentric View ---
subplot(1, 2, 1);
hold on; grid on; axis equal;
title('Heliocentric Trajectory (Veridian Center)');
xlabel('X (km)'); ylabel('Y (km)');

[mjd_min, mjd_max] = ephemeris.get_min_max_dates();
t_orbit = linspace(mjd_min, mjd_max, 500);
r_C_orbit = zeros(3, length(t_orbit));
r_V_orbit = zeros(3, length(t_orbit));
r_G_orbit = zeros(3, length(t_orbit));
for i = 1:length(t_orbit)
    [r_C_orbit(:,i), ~] = ephemeris.get_state('Caelus', t_orbit(i));
    [r_V_orbit(:,i), ~] = ephemeris.get_state('Ventus', t_orbit(i));
    [r_G_orbit(:,i), ~] = ephemeris.get_state('Glacia', t_orbit(i));
end

plot(r_C_orbit(1,:), r_C_orbit(2,:), 'b--', 'LineWidth', 0.5);
plot(r_V_orbit(1,:), r_V_orbit(2,:), 'r--', 'LineWidth', 0.5);
plot(r_G_orbit(1,:), r_G_orbit(2,:), 'k--', 'LineWidth', 0.5);
plot(0, 0, 'y*', 'MarkerSize', 15, 'LineWidth', 2); % Star

p_C = plot(r_C_orbit(1,1), r_C_orbit(2,1), 'bo', 'MarkerSize', 8, 'MarkerFaceColor', 'b');
p_V = plot(r_V_orbit(1,1), r_V_orbit(2,1), 'ro', 'MarkerSize', 10, 'MarkerFaceColor', 'r');
p_G = plot(r_G_orbit(1,1), r_G_orbit(2,1), 'ko', 'MarkerSize', 6, 'MarkerFaceColor', 'k');

sc_tail = plot(sc_coords.X_km(1), sc_coords.Y_km(1), 'g-', 'LineWidth', 1.5);
p_sc = plot(sc_coords.X_km(1), sc_coords.Y_km(1), 'g.', 'MarkerSize', 15);

% --- Right Subplot: Ventus-centric Flyby ---
subplot(1, 2, 2);
hold on; grid on; axis equal;
title('Ventus-Centric Flyby');
xlabel('Delta X (km)'); ylabel('Delta Y (km)');

% Draw Ventus as a circle
R_V = c.R_VENTUS_CLOUD_TOP;
rectangle('Position', [-R_V, -R_V, 2*R_V, 2*R_V], 'Curvature', [1 1], 'FaceColor', [1 0.6 0.2], 'EdgeColor', 'r');

sc_fb_tail = plot(0, 0, 'g-', 'LineWidth', 1.5);
p_sc_fb = plot(0, 0, 'g.', 'MarkerSize', 15);

% Video Writer Setup
v = VideoWriter('results/planetary_simulation.mp4', 'MPEG-4');
v.FrameRate = 15;
open(v);

% Animation Loop
for i = 1:height(sc_coords)
    t = sc_coords.MJD(i);
    
    [r_C, ~] = ephemeris.get_state('Caelus', t);
    [r_V, ~] = ephemeris.get_state('Ventus', t);
    [r_G, ~] = ephemeris.get_state('Glacia', t);
    
    set(p_C, 'XData', r_C(1), 'YData', r_C(2));
    set(p_V, 'XData', r_V(1), 'YData', r_V(2));
    set(p_G, 'XData', r_G(1), 'YData', r_G(2));
    
    set(p_sc, 'XData', sc_coords.X_km(i), 'YData', sc_coords.Y_km(i));
    set(sc_tail, 'XData', sc_coords.X_km(1:i), 'YData', sc_coords.Y_km(1:i));
    
    % Update Ventus view (relative coords)
    [r_V_current, ~] = ephemeris.get_state('Ventus', sc_coords.MJD(i));
    sc_rel_x = sc_coords.X_km(1:i) - arrayfun(@(m) get_x(ephemeris, 'Ventus', m), sc_coords.MJD(1:i));
    sc_rel_y = sc_coords.Y_km(1:i) - arrayfun(@(m) get_y(ephemeris, 'Ventus', m), sc_coords.MJD(1:i));
    
    set(p_sc_fb, 'XData', sc_rel_x(end), 'YData', sc_rel_y(end));
    set(sc_fb_tail, 'XData', sc_rel_x, 'YData', sc_rel_y);
    
    % Dynamic bounds based on distance to Ventus
    dist = norm([sc_rel_x(end), sc_rel_y(end)]);
    if dist < 5e6
        bound = max(R_V * 5, dist * 1.5);
    else
        bound = 2e7;
    end
    subplot(1, 2, 2);
    xlim([-bound bound]); ylim([-bound bound]);
    
    frame = getframe(fig);
    writeVideo(v, frame);
end

close(v);
fprintf('Animation saved to results/planetary_simulation.mp4\n');

function x = get_x(eph, body, t)
    [r, ~] = eph.get_state(body, t);
    x = r(1);
end
function y = get_y(eph, body, t)
    [r, ~] = eph.get_state(body, t);
    y = r(2);
end
