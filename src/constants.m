function c = constants()
    % constants Returns a struct containing all physical and mission constants.
    
    % VERIDIAN SYSTEM CONSTANTS
    c.MU_STAR = 1.393e11;  % km^3/s^2 (Veridian)
    c.AU = 1.496e8;  % km

    % Planetary properties
    c.MU_CAELUS = 3.986e5;  % km^3/s^2
    c.R_CAELUS = 7200.0;  % km

    c.MU_VENTUS = 1.266e8;  % km^3/s^2
    c.R_VENTUS_CLOUD_TOP = 65000.0;  % km

    c.MU_GLACIA = 1.267e7;  % km^3/s^2
    c.R_GLACIA = 30000.0;  % km

    % MISSION PARAMETERS
    c.M_INITIAL = 2500.0;  % kg
    c.I_SP = 300.0;  % seconds
    c.G0 = 0.00980665;  % km/s^2

    c.MAX_DV_BUDGET = 1.5;  % km/s
    c.MAX_MISSION_DURATION = 2922.0;  % days
    c.THERMAL_CONSTRAINT_DIST = 0.4 * c.AU;  % km

    c.PARKING_ORBIT_ALT = 500.0;  % km
    c.VENTUS_MIN_FLYBY_ALT = 2000.0;  % km
    c.VENTUS_MAX_FLYBY_ALT = 20000.0;  % km
end
