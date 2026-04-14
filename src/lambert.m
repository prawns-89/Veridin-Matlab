function [v1, v2] = lambert(r1, r2, tof, mu, direction)
    % lambert Universal Variables method for solving Lambert's problem.
    if nargin < 5
        direction = 'prograde';
    end
    
    mag_r1 = norm(r1);
    mag_r2 = norm(r2);
    
    cross_r1_r2 = cross(r1, r2);
    cos_dnu = dot(r1, r2) / (mag_r1 * mag_r2);
    cos_dnu = max(min(cos_dnu, 1.0), -1.0);
    dnu = acos(cos_dnu);
    
    if strcmp(direction, 'prograde')
        if cross_r1_r2(3) < 0
            dnu = 2*pi - dnu;
        end
    elseif strcmp(direction, 'retrograde')
        if cross_r1_r2(3) >= 0
            dnu = 2*pi - dnu;
        end
    else
        error('Direction must be prograde or retrograde');
    end

    A = sin(dnu) * sqrt(mag_r1 * mag_r2 / (1 - cos(dnu)));
    if A == 0
        error('Cannot compute a Lambert transfer with exactly 180 degrees.');
    end
    
    function [C, S] = cs_func(z)
        if z > 0
            sqz = sqrt(z);
            C = (1 - cos(sqz)) / z;
            S = (sqz - sin(sqz)) / (sqz^3);
        elseif z < 0
            sqz = sqrt(-z);
            C = (cosh(sqz) - 1) / (-z);
            S = (sinh(sqz) - sqz) / (sqz^3);
        else
            C = 1/2.0;
            S = 1/6.0;
        end
    end

    function dt_err = tof_equation(z)
        [C, S] = cs_func(z);
        y = mag_r1 + mag_r2 + A * (z * S - 1) / sqrt(C);
        if y < 0
            dt_err = NaN;
            return;
        end
        x = sqrt(y / C);
        dt = (x^3 * S + A * sqrt(y)) / sqrt(mu);
        dt_err = dt - tof;
    end
    
    options = optimset('Display', 'off');
    try
        z = fzero(@tof_equation, [-100, 4*pi^2], options);
    catch
        try
            z = fzero(@tof_equation, 1.0, options);
        catch
            v1 = [NaN NaN NaN];
            v2 = [NaN NaN NaN];
            return;
        end
    end
    
    [C, S] = cs_func(z);
    y = mag_r1 + mag_r2 + A * (z * S - 1) / sqrt(C);
    
    f = 1 - y / mag_r1;
    g = A * sqrt(y / mu);
    g_dot = 1 - y / mag_r2;
    
    v1 = (r2 - f * r1) / g;
    v2 = (g_dot * r2 - r1) / g;
end
