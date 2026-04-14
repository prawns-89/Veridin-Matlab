function [dv_dep, dv_arr, dv_ren] = delta_v(v_inf_mag_dep, r_park_dep, mu_dep, v_inf_mag_arr, r_park_arr, mu_arr)
    % delta_v Calculates arrival, departure and rendezvous delta-Vs.
    
    % Departure
    v_park_dep = sqrt(mu_dep / r_park_dep);
    v_periapsis_dep = sqrt(v_inf_mag_dep^2 + 2 * mu_dep / r_park_dep);
    dv_dep = v_periapsis_dep - v_park_dep;
    
    % Arrival Capture (if needed)
    v_park_arr = sqrt(mu_arr / r_park_arr);
    v_periapsis_arr = sqrt(v_inf_mag_arr^2 + 2 * mu_arr / r_park_arr);
    dv_arr = v_periapsis_arr - v_park_arr;
    
    % Rendezvous
    dv_ren = v_inf_mag_arr;
end
