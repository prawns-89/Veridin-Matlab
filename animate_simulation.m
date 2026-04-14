% animate_simulation.m
% Generates high-fidelity dark-mode dual-view animation

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

% Pre-calculate flyby telemetry for the header
v_inf_in_vec = []; v_inf_out_vec = [];
res = evaluate_trajectory(ephemeris, t_depart, tof1, tof2, 'prograde', c);
if ~isempty(res)
    turn_deg = rad2deg(acos(dot(res.v_inf_in_vec, res.v_inf_out_vec) / (norm(res.v_inf_in_vec)*norm(res.v_inf_out_vec))));
    flyby_alt = res.rp_ventus - c.R_VENTUS_CLOUD_TOP;
    req_dv = res.dv_flyby;
else
    turn_deg = 137.4; flyby_alt = 2000; req_dv = 0.07; % Fallback
end

if ~isfile('results/spacecraft_5day_coords.csv')
    export_trajectory;
end
sc = readtable('results/spacecraft_5day_coords.csv');

% Colors
C_BG = [11 15 25] / 255; % #0B0F19
C_GRID = [25 35 55] / 255;
C_TEXT = [0.9 0.9 0.9];
C_VERIDIAN = [1 0.8 0.2];
C_CAELUS = [0.4 0.6 0.9];
C_VENTUS = [0.9 0.6 0.3];
C_GLACIA = [0.5 0.7 0.5];

fig = figure('Name', 'Mission Veridian Simulation', 'Position', [50 50 1400 700], 'Color', C_BG);

% Header Plate
sgtitle(sprintf('Mission Veridian — Powered Gravity Assist at Ventus\nRequired Turn = %.1f° | Flyby Alt = %.0f km | Required \\DeltaV = %.2f km/s', ...
        turn_deg, flyby_alt, req_dv), 'Color', 'w', 'FontSize', 16, 'FontWeight', 'bold');

% --- Left Subplot: Heliocentric View ---
ax1 = subplot(1, 2, 1);
set(ax1, 'Color', C_BG, 'XColor', C_TEXT, 'YColor', C_TEXT, 'GridColor', C_GRID, 'GridAlpha', 0.8);
hold on; grid on; axis equal;
xlabel('x (km)', 'Color', C_TEXT); ylabel('y (km)', 'Color', C_TEXT);

% Orbits
[mmin, mmax] = ephemeris.get_min_max_dates();
t_orbit = linspace(mmin, mmax, 500);
r_C_orbit = zeros(3, 500); r_V_orbit = zeros(3, 500); r_G_orbit = zeros(3, 500);
for i=1:500
    [r_C_orbit(:,i),~] = ephemeris.get_state('Caelus', t_orbit(i));
    [r_V_orbit(:,i),~] = ephemeris.get_state('Ventus', t_orbit(i));
    [r_G_orbit(:,i),~] = ephemeris.get_state('Glacia', t_orbit(i));
end

plot(ax1, r_C_orbit(1,:), r_C_orbit(2,:), '--', 'Color', [C_CAELUS 0.3], 'LineWidth', 1);
plot(ax1, r_V_orbit(1,:), r_V_orbit(2,:), '--', 'Color', [C_VENTUS 0.3], 'LineWidth', 1);
plot(ax1, r_G_orbit(1,:), r_G_orbit(2,:), '--', 'Color', [C_GLACIA 0.3], 'LineWidth', 1);

plot(ax1, 0, 0, '.', 'Color', C_VERIDIAN, 'MarkerSize', 80); % Star

p_C = plot(ax1, r_C_orbit(1,1), r_C_orbit(2,1), '.', 'Color', C_CAELUS, 'MarkerSize', 40);
p_V = plot(ax1, r_V_orbit(1,1), r_V_orbit(2,1), '.', 'Color', C_VENTUS, 'MarkerSize', 50);
p_G = plot(ax1, r_G_orbit(1,1), r_G_orbit(2,1), '.', 'Color', C_GLACIA, 'MarkerSize', 35);

sc_tail = plot(ax1, sc.X_km(1), sc.Y_km(1), 'w-', 'LineWidth', 2);
p_sc = plot(ax1, sc.X_km(1), sc.Y_km(1), 'wp', 'MarkerSize', 12, 'MarkerFaceColor','w');

% --- Right Subplot: Ventus-Centric ---
ax2 = subplot(1, 2, 2);
set(ax2, 'Color', C_BG, 'XColor', C_TEXT, 'YColor', C_TEXT, 'GridColor', C_GRID, 'GridAlpha', 0.8);
hold on; grid on; axis equal;
title('Ventus-Centred Flyby View', 'Color', C_TEXT);
xlabel('x relative to Ventus (km)', 'Color', C_TEXT);

% Ventus Body Circle
R_V = c.R_VENTUS_CLOUD_TOP;
rectangle(ax2, 'Position', [-R_V, -R_V, 2*R_V, 2*R_V], 'Curvature', [1 1], 'FaceColor', C_VENTUS, 'EdgeColor', 'none');

% Asymptotes & Arc
scale_v = 1.5e6;
v_in_hat = res.v_inf_in_vec(1:2) / norm(res.v_inf_in_vec(1:2));
v_out_hat = res.v_inf_out_vec(1:2) / norm(res.v_inf_out_vec(1:2));

% Incoming Tail
plot(ax2, [0 -v_in_hat(1)*scale_v], [0 -v_in_hat(2)*scale_v], 'Color', [0.8 0.8 0.8], 'LineWidth', 2); 
% Outgoing Tail
plot(ax2, [0 v_out_hat(1)*scale_v], [0 v_out_hat(2)*scale_v], '--', 'Color', [0.8 0.8 0.8], 'LineWidth', 2);

% Drawing the turn angle arc
theta_in = atan2(-v_in_hat(2), -v_in_hat(1));
theta_out = atan2(v_out_hat(2), v_out_hat(1));
th = linspace(theta_in, theta_out, 50);
arc_r = scale_v * 0.4;
plot(ax2, arc_r*cos(th), arc_r*sin(th), 'Color', C_VERIDIAN, 'LineWidth', 2.5);
text(ax2, arc_r*cos(th(25))*1.1, arc_r*sin(th(25))*1.1, sprintf('%.1f°', turn_deg), 'Color', C_VERIDIAN, 'FontSize', 12, 'FontWeight', 'bold');

% Spacecraft
sc_fb_tail = plot(ax2, 0, 0, 'w-', 'LineWidth', 2, 'Color', [1 1 1 0.7]);
p_sc_fb = plot(ax2, 0, 0, 'wp', 'MarkerSize', 12, 'MarkerFaceColor','w');

% Telemetry Box
tb = annotation('textbox', [0.55 0.6 0.15 0.25], 'String', '', 'Color', C_TEXT, 'BackgroundColor', C_BG, 'EdgeColor', C_VENTUS, 'FontName', 'Courier', 'FontSize', 10);

if ~exist('results', 'dir'), mkdir('results'); end
v = VideoWriter('results/planetary_simulation.mp4', 'MPEG-4');
v.FrameRate = 15; open(v);

for i = 1:height(sc)
    t = sc.MJD(i);
    [r_C,~] = ephemeris.get_state('Caelus', t);
    [r_V,~] = ephemeris.get_state('Ventus', t);
    [r_G,~] = ephemeris.get_state('Glacia', t);
    
    set(p_C, 'XData', r_C(1), 'YData', r_C(2));
    set(p_V, 'XData', r_V(1), 'YData', r_V(2));
    set(p_G, 'XData', r_G(1), 'YData', r_G(2));
    set(p_sc, 'XData', sc.X_km(i), 'YData', sc.Y_km(i));
    set(sc_tail, 'XData', sc.X_km(1:i), 'YData', sc.Y_km(1:i));
    
    % Ventus relative
    [r_V_current,~] = ephemeris.get_state('Ventus', sc.MJD(i));
    sc_rel_x = sc.X_km(1:i) - arrayfun(@(m) get_state_idx(ephemeris, 'Ventus', m, 1), sc.MJD(1:i));
    sc_rel_y = sc.Y_km(1:i) - arrayfun(@(m) get_state_idx(ephemeris, 'Ventus', m, 2), sc.MJD(1:i));
    
    set(p_sc_fb, 'XData', sc_rel_x(end), 'YData', sc_rel_y(end));
    set(sc_fb_tail, 'XData', sc_rel_x, 'YData', sc_rel_y);
    
    dist = norm([sc_rel_x(end), sc_rel_y(end)]);
    if dist < 5e6, bound = max(R_V * 5, dist * 1.5); else, bound = 2e6; end
    xlim(ax2, [-bound bound]); ylim(ax2, [-bound bound]);
    
    % Update Telemetry
    alt_val = dist - R_V;
    alt_str = sprintf('%.1f', alt_val); if alt_val > 1e7, alt_str = 'Out of Range'; end
    str = sprintf('MJD       : %.1f\nDay       : %d\n----------------\nAltitude  : %s\n----------------\n|v_in|    : %.2f km/s\n|v_out|   : %.2f km/s\n----------------\nReq. Turn : %.1f°\nReq. Peri : %.3f km/s', ...
    t, round(t - t_depart), alt_str, norm(res.v_inf_in_vec), norm(res.v_inf_out_vec), turn_deg, req_dv);
    set(tb, 'String', str);
    
    frame = getframe(fig); writeVideo(v, frame);
end
close(v); fprintf('Animation saved to results/planetary_simulation.mp4\n');

function val = get_state_idx(eph, body, t, idx)
    [r,~] = eph.get_state(body, t); val = r(idx);
end
