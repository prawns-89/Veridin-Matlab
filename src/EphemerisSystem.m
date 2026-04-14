classdef EphemerisSystem
    % EphemerisSystem Loads orbital data and provides cubic spline interpolation
    
    properties
        mjd
        splines
    end
    
    methods
        function obj = EphemerisSystem(filepath)
            data = readtable(filepath);
            obj.mjd = data.MJD;
            
            bodies = {'Caelus', 'Ventus', 'Glacia', 'Aether'};
            obj.splines = struct();
            
            for i = 1:length(bodies)
                b = bodies{i};
                x_col = [b '_x'];
                if ismember(x_col, data.Properties.VariableNames)
                    r_pts = [data.(x_col), data.([b '_y']), data.([b '_z'])];
                    v_pts = [data.([b '_vx']), data.([b '_vy']), data.([b '_vz'])];
                    
                    obj.splines.(b).r = spline(obj.mjd, r_pts');
                    obj.splines.(b).v = spline(obj.mjd, v_pts');
                end
            end
        end
        
        function [r, v] = get_state(obj, body_name, t_mjd)
            if ~isfield(obj.splines, body_name)
                error('Body %s not found in ephemeris.', body_name);
            end
            r = ppval(obj.splines.(body_name).r, t_mjd)';
            v = ppval(obj.splines.(body_name).v, t_mjd)';
        end
        
        function [t_min, t_max] = get_min_max_dates(obj)
            t_min = obj.mjd(1);
            t_max = obj.mjd(end);
        end
    end
end
