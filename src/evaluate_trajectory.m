function res = evaluate_trajectory(ephemeris, t_depart, tof_1, tof_2, direction, c)
    res = [];
    
    t_flyby = t_depart + tof_1;
    t_arrive = t_flyby + tof_2;
    
    [r_caelus, v_caelus] = ephemeris.get_state('Caelus', t_depart);
    [r_ventus, v_ventus] = ephemeris.get_state('Ventus', t_flyby);
    [r_glacia, v_glacia] = ephemeris.get_state('Glacia', t_arrive);
    
    if norm(r_caelus) < c.THERMAL_CONSTRAINT_DIST || norm(r_ventus) < c.THERMAL_CONSTRAINT_DIST
        return;
    end
    
    tof_1_sec = tof_1 * 86400.0;
    tof_2_sec = tof_2 * 86400.0;
    
    [v1_depart, v1_arrive] = lambert(r_caelus, r_ventus, tof_1_sec, c.MU_STAR, direction);
    if any(isnan(v1_depart))
        return;
    end
    
    [v2_depart, v2_arrive] = lambert(r_ventus, r_glacia, tof_2_sec, c.MU_STAR, direction);
    if any(isnan(v2_depart))
        return;
    end
    
    v_inf_depart = norm(v1_depart - v_caelus);
    [dv_depart, ~, ~] = delta_v(v_inf_depart, c.R_CAELUS + c.PARKING_ORBIT_ALT, c.MU_CAELUS, 1, 1, 1);
    
    [~, ~, dv_flyby, rp, ~] = gravity_assist(v1_arrive, v2_depart, v_ventus, c.MU_VENTUS);
    
    if rp < (c.R_VENTUS_CLOUD_TOP + c.VENTUS_MIN_FLYBY_ALT)
        return;
    end
    
    v_inf_arrive = norm(v2_arrive - v_glacia);
    dv_arrive = v_inf_arrive;
    
    total_dv = dv_depart + dv_flyby + dv_arrive;
    
    res.total_dv = total_dv;
    res.dv_depart = dv_depart;
    res.dv_flyby = dv_flyby;
    res.dv_arrive = dv_arrive;
    res.rp_ventus = rp;
    res.v_inf_arrive = v_inf_arrive;
end
