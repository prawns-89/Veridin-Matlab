# Mission Veridian: Gravity-Assist Trajectory Pipeline

**Course:** Flight and Space Mechanics (R5ME2206T)  
**Institute:** VJTI Mumbai — Second-Year Aerospace Engineering MDM, Semester IV (2025-26)  
**Team Members:** [Your Names Here]

---

## Logistical Overview & Deliverables
This repository contains the complete mathematical pipeline evaluated entirely in MATLAB to demonstrate the optimal trajectory from a Caelus parking orbit, undergoing an unpowered gravity assist around Ventus, and targeting a rendezvous with Glacia.

### Generated Architecture:
1. **Report:** Located inside `report/mission_report.md`
2. **Raw Coordinates:** Exported natively at precise 5-day stepwise frames (`results/spacecraft_5day_coords.csv`)
3. **Animations:** Dual subplot `.mp4` tracking the overall Heliocentric maneuvers *and* tracking Ventus tightly dead-centered on the hyperbolic pass (`results/planetary_simulation.mp4`).

---

## Detailed Implementation & Core Mechanics

The codebase avoids reliance on simplified toolboxes to transparently show numerical orbital mechanics. Below is the structural logic applied across our scripts.

### 1. Ephemeris Processing (`src/EphemerisSystem.m`)
We are provided a single continuous CSV containing Caelus, Ventus, and Glacia 5-day state grids. Simple indexing causes rounding errors for Lambert bounding intervals. 

**Implementation:** We initialize an object to fit piecewise polynomials via strict 1D cubic interpolation (`spline()`), guaranteeing microsecond querying without temporal jumps.
```matlab
% Example Code Implementation (Interpolation)
r_pts = [data.Ventus_x, data.Ventus_y, data.Ventus_z];
obj.splines.Ventus.r = spline(obj.mjd, r_pts'); % Fit positional points

% Function Access Example
[r, v] = get_state(ephemeris, 'Ventus', 60800.5) % Query explicit decimal bound
```

### 2. Lambert's Problem Solver (`src/lambert.m`)
The core of our mathematical modeling connects bounds $r_1, r_2$ using the **Universal Variable Formulation**.

**Implementation:** Stumpff functions are processed natively to allow uniform bounds across standard elliptical/hyperbolic transfers explicitly overcoming 180° plane degeneracies. We isolate the true anomaly $z$ root functionally via bounds inside MATLAB's natively robust `fzero`.
```matlab
% Universal Anomaly Iterative Bounds via fzero
function dt_err = tof_equation(z)
    [C, S] = cs_func(z); % Stumpff evaluation
    y = mag_r1 + mag_r2 + A * (z * S - 1) / sqrt(C);
    x = sqrt(y / C);
    dt_err = ((x^3 * S + A * sqrt(y)) / sqrt(mu)) - tof; 
end

z = fzero(@tof_equation, [-100, 4*pi^2], optimset('Display', 'off'));
```

### 3. Patched-Conic Constraints & Flyby Math
The search logic mandates unpowered bounds and thermal clearances. The physical values natively interact via basic Vis-Viva equations in `src/delta_v.m` and turning geometries in `src/gravity_assist.m`.

**Implementation:** We evaluate overlapping Lambert velocities locally against the planetary velocities (hyperbolic excess velocities $v_\infty$).
```matlab
% Unpowered Turning Angle Bounds (gravity_assist.m)
v_inf_in_vec = v_in_heliocentric - v_planet;
v_inf_out_vec = v_out_heliocentric - v_planet;

dot_prod = dot(v_inf_in_vec, v_inf_out_vec) / (v_inf_in * v_inf_out);
delta = acos(max(min(dot_prod, 1.0), -1.0)); % Deriving delta turn

e = 1.0 / sin(delta / 2.0);
rp = (mu_planet / v_inf_avg^2) * (e - 1.0); % Required flyby pass altitude
```

---

## Operating Instructions

Run these files sequentially internally in your MATLAB environment (Verify you are actively sitting inside the `Veridin-Matlab` directory).

### Step 1: Iterate Optimization Matrix
```matlab
main
```
**What this does:**
We build ranges for Caelus Departure (`60000 - 61095`), Target Caelus$\rightarrow$Ventus TOF, and Ventus$\rightarrow$Glacia TOF exactly specified from ranges `200` to `800`.
- We loop strictly over valid permutations, discarding sets breaching 0.4 AU proximity thresholds locally prior to initiating costly Stumpff function roots.
- Valid intercept combinations return bounded penalty scalars evaluated for fuel. The global minimal set determines our single target parameters.
- Outputs dynamically to: `data/optimal_trajectory.csv`.

### Step 2: Formulate Chronological XYZ Set Trackers
```matlab
export_trajectory
```
**What this does:**
From the explicit initial launch parameter results found in Step 1, we pull out the initial $v_1$ values and pass these state vectors to `ode45`.
- Evaluates the core two-body acceleration strictly: $\ddot{\mathbf{r}} = -\mu \frac{\mathbf{r}}{r^3}$
- The solver is forcefully bounded to snapshot output every exact 5-day cycle: `t_span = (0:5:tof1) * 86400;`
- Logs all vectors contiguously to `results/spacecraft_5day_coords.csv`.
```matlab
ode_star = @(t, y) [y(4:6); -c.MU_STAR * y(1:3) / norm(y(1:3))^3];
[~, y1] = ode45(ode_star, (0:5:tof1)*86400, [r_C; v1_depart], options);
```

### Step 3: Graphical Export Verification
```matlab
animate_simulation
```
**What this does:**
Translates our coordinates seamlessly into an exportable standard `results/planetary_simulation.mp4`.
- **View 1 (Veridian View):** Projects massive heliocentric dimensions evaluating overlapping global intercept trajectories globally.
- **View 2 (Ventus Flyby Focus):** Re-maps our spacecraft trajectories strictly relative to Ventus ($Position_{Ship} - Position_{Ventus}$). Dynamically scales bounding $X,Y$ boxes so the ship maintains framing optimally as it physically accelerates and whips hyperbolically around the planet!

```matlab
% Dynamic Scaling Code Example in Animation Builder
sc_rel_x = sc_coords.X_km(1:i) - get_x(ephemeris, 'Ventus', sc_coords.MJD(1:i));

dist = norm([sc_rel_x(end), sc_rel_y(end)]);
if dist < 5e6
    bound = max(R_VENTUS * 5, dist * 1.5); % Dynamically shrink view to Ventus surface!
else 
    bound = 2e7;
end
```
