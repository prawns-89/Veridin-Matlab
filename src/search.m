function best_params = search(ephemeris, depart_range, tof1_range, tof2_range)
    % search Grid search over departure dates and times of flight.
    
    best_dv = inf;
    best_params = [];
    c = constants();
    
    for t_dep = depart_range
        for tof1 = tof1_range
            for tof2 = tof2_range
                if tof1 + tof2 > c.MAX_MISSION_DURATION
                    continue;
                end
                
                res = evaluate_trajectory(ephemeris, t_dep, tof1, tof2, 'prograde', c);
                
                if ~isempty(res) && res.total_dv < best_dv
                    best_dv = res.total_dv;
                    best_params.t_depart = t_dep;
                    best_params.tof_1 = tof1;
                    best_params.tof_2 = tof2;
                    best_params.results = res;
                end
            end
        end
    end
end


