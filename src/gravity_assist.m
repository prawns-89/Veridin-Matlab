function [v_inf_in, v_inf_out, dv_powered, rp, delta] = gravity_assist(v_in_heliocentric, v_out_heliocentric, v_planet, mu_planet)
    % gravity_assist Computes parameters for an unpowered gravity assist.
    
    v_inf_in_vec = v_in_heliocentric - v_planet;
    v_inf_out_vec = v_out_heliocentric - v_planet;
    
    v_inf_in = norm(v_inf_in_vec);
    v_inf_out = norm(v_inf_out_vec);
    
    dv_powered = abs(v_inf_out - v_inf_in);
    
    v_inf_avg = (v_inf_in + v_inf_out) / 2.0;
    
    dot_prod = dot(v_inf_in_vec, v_inf_out_vec) / (v_inf_in * v_inf_out);
    dot_prod = max(min(dot_prod, 1.0), -1.0); % clip between -1 and 1
    delta = acos(dot_prod);
    
    e = 1.0 / sin(delta / 2.0);
    rp = (mu_planet / v_inf_avg^2) * (e - 1.0);
end
