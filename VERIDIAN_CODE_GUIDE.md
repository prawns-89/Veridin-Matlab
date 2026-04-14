# Mission Veridian — MATLAB Code Walkthrough & Physics Logic

**Gravity-Assist Trajectory Design in a Fictional Exoplanetary System**
*Flight and Space Mechanics · VJTI Mumbai · R5ME2206T*

---

## 1. Deep Core Architecture

Unlike Python variants reliant upon standard aerospace high-level boundaries (i.e. `scipy.optimize`), this explicit MATLAB port builds raw standard mechanical trajectory physics directly out of standard linear algebraic principles, relying strictly and explicitly upon base system roots allowing immense analytical transparency in deriving flight models.

### End To End Functional Flow
```text
veridian_ephemeris.csv  -->  EphemerisSystem (spline)
        │                                │
        ▼                                ▼
   evaluate_trajectory() <------- get_state()
    ├── 1. lambert(r_C, r_V) ───► v1_depart, v1_arrive
    ├── 2. lambert(r_V, r_G) ───► v2_depart, v2_arrive
    ├── 3. gravity_assist(v1_arrive, v2_depart) ───► Extracts flyby altitude & penalties
    ├── 4. delta_v(Caelus Departure) ───► Patched-Conic vis-viva cost
    └── 5. Rendezvous Check ───► Direct velocity target match 
        │
   Grid search explicitly iterates & finds absolute minimal scalar 
        │
        ▼
   optimal_trajectory.csv ------► ode45 explicitly traces 5-day physical path lines 
                                          │
                                          ▼
                             results/planetary_simulation.mp4
```

---

## 2. Theoretical Breakdown by Component

### `src/EphemerisSystem.m` — The Data Extrapolator
We are provided a single continuous CSV containing Caelus, Ventus, and Glacia 5-day state grids. However, Lambert integrations iteratively query timelines floating heavily between explicit grids (i.e. `MJD 60103.1415`). 

**Implementation Strategy:** We build a persistent evaluation object extracting local state matrices matching position values continuously across standard bounds without discrete temporal jumping.
```matlab
% We utilize purely independent piece-wise functions 
% matching exact local boundary limits minimizing polynomial ringing.

r_pts = [data.Ventus_x, data.Ventus_y, data.Ventus_z];
v_pts = [data.Ventus_vx, data.Ventus_vy, data.Ventus_vz];

% Native array boundaries are fit gracefully directly over 1D matrices
obj.splines.Ventus.r = spline(obj.mjd, r_pts'); 
obj.splines.Ventus.v = spline(obj.mjd, v_pts'); 
```

### `src/lambert.m` — Root Boundary Finder
The problem statement fundamentally requires deriving the $3 \times 1$ velocity vectors matching exactly boundary position offsets $r_1, r_2$ across explicit time interval gaps $TOF_x$.

**Implementation Strategy:** The code embraces **Universal Variables Formulation**, entirely bypassing singularity points native to switching mathematical limits across ellipses and hyperbolas explicitly implementing bounding via internal Stumpff bounds $C(z), S(z)$.
```matlab
% Universal Anomaly Iterative Bounds via inverse root zeroing.
function dt_err = tof_equation(z)
    [C, S] = cs_func(z);
    
    % Core mathematical relationship bypassing Kepler transitions
    y = mag_r1 + mag_r2 + A * (z * S - 1) / sqrt(C);
    
    if y < 0
        dt_err = NaN; % Fast-fails negative imaginary boundaries!
        return;
    end
    
    x = sqrt(y / C);
    
    % Returns explicit fractional time boundaries evaluated identically.
    dt = (x^3 * S + A * sqrt(y)) / sqrt(mu);
    dt_err = dt - tof; 
end

% Bypassing unstable bracket parameters aggressively limiting bounds
options = optimset('Display', 'off');
z = fzero(@tof_equation, [-100, 4*pi^2], options);
```

### `src/gravity_assist.m` — Vis-Viva Unpowered Turning Models
If the analytical trajectory physically bridges across Ventus, we must rigidly test overlapping vectors matching hyperbolic excess parameters organically.

**Implementation Strategy:** By translating values from Heliocentric reference limits dynamically back down into localized Ventus reference frames, we measure exactly how far the native trajectory is theoretically being bent mathematically by planetary mass organically mapping required altitudes organically.
```matlab
% Derive excess tracking limits bound strictly inside Ventus gravity 
v_inf_in_vec = v_in_heliocentric - v_planet;
v_inf_out_vec = v_out_heliocentric - v_planet;

% Exact Trigonometric Turning Derivations
dot_prod = dot(v_inf_in_vec, v_inf_out_vec) / (v_inf_in * v_inf_out);
delta = acos(max(min(dot_prod, 1.0), -1.0)); % Clips rounding boundaries identically

% Deriving structural eccentricity parameters mapping unpowered constraints
e = 1.0 / sin(delta / 2.0);

% Minimum viable passing constraints calculated directly backwards
rp = (mu_planet / v_inf_avg^2) * (e - 1.0); 

% Penalize math failures dynamically against total global budgets!
dv_powered = abs(v_inf_out - v_inf_in);
```

### `export_trajectory.m` — ODE Integration Bounds
Assignment parameters demand explicit 5-day chronological tracker data derived uniformly. Pure analytical models frequently miss tracking parameters outside exact geometric derivations.

**Implementation Strategy:** We actively run a localized mathematical integrator matching precisely fundamental gravity constraints derived off explicit initial boundaries mapped natively back off Lambert.
```matlab
% Two-body orbital constraints bounded natively against Veridian Star
ode_star = @(t, y) [y(4:6); -c.MU_STAR * y(1:3) / norm(y(1:3))^3];

% Tightly forcing evaluation iterations bypassing default dynamic lengths
t_span1 = (0:5:tof1) * 86400; 
options = odeset('RelTol', 1e-8, 'AbsTol', 1e-10);

% Direct ODE45 Integrations yielding absolute chronological vectors
[t1_out, y1_out] = ode45(ode_star, t_span1, [r_C; v1_depart], options);
```

### `animate_simulation.m` — Dynamic Graphics Parsing
To effectively analyze overlapping frames, we utilize multi-axis tracking seamlessly moving structural viewing parameters in real-time frame by frame.

**Implementation Strategy:** The core visualization requires actively isolating exactly the Ventus relative trajectory by aggressively forcing the graph's center limits mathematically around Ventus limits identically tracking coordinate changes implicitly. 
```matlab
% Ventus dynamic isolation limits evaluating position differences
sc_rel_x = sc_coords.X_km(1:i) - arrayfun(@(m) get_x(ephemeris, 'Ventus', m), sc_coords.MJD(1:i));
sc_rel_y = sc_coords.Y_km(1:i) - arrayfun(@(m) get_y(ephemeris, 'Ventus', m), sc_coords.MJD(1:i));

% Dynamically constricting plot window scopes scaling tightly as ship physically intercepts!
dist = norm([sc_rel_x(end), sc_rel_y(end)]);
if dist < 5e6
    bound = max(R_V * 5, dist * 1.5); % Scale bounds exactly inward locking on 
else
    bound = 2e7; % Base wide parameter
end

subplot(1, 2, 2);
xlim([-bound bound]); ylim([-bound bound]);
```
