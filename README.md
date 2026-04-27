# Mission Veridian: Gravity-Assist Trajectory Optimization (MATLAB Edition)
---

## 1. Executive Summary & Mission Objective
This repository contains a comprehensive orbital mechanics pipeline natively developed in MATLAB. Our primary mission objective is to successfully construct a theoretical patched-conic trajectory from an initial 500 km circular parking orbit around **Caelus** to intercept and achieve a kinematic rendezvous with **Glacia**.

To satisfy the demanding $1.5 \text{ km/s}$ continuous propellant boundary constraint over an 8-year terrestrial transit maximum, the algorithms analytically determine an overarching ballistic trajectory. This trajectory intercepts the inner gas giant planet, **Ventus**, executing an unpowered slingshot gravity-assist to slingshot the spacecraft effectively outward.

### Formal Generated Deliverables:
The code architecture natively drives the distinct outputs outlined within the course rubric:
1. **Formal Mission Report:** Generated at `report/mission_report.md`, detailing optimization variables.
2. **5-Day Stepwise State Matrix:** The simulation inherently constructs chronological $X, Y, Z$ trajectory coordinates directly bound to exact 5-day intervals natively pushed to `results/spacecraft_5day_coords.csv`.
3. **Dual Visualizations Engine:** The `animate_simulation.m` explicitly writes a unified `.mp4` file visualizing both the massive heliocentric solar intercept and an isolated micro-view tracking the Ventus-centric hyperbolic pass.

---

## 2. Advanced Operating Instructions

### Step 1: Getting the Project from GitHub over to MATLAB
To interact heavily with these models locally, you must first clone the repository bounds directly to your filesystem and establish your active MATLAB directory parameters.
1. Open your standard command line (or Git Bash/terminal).
2. Clone the directory natively:
   ```bash
   git clone https://github.com/[YourUsername]/Veridin-Matlab.git
   ```
3. Boot up your local installation of **MATLAB**.
4. In MATLAB, navigate your path visually using the `< Current Folder >` toolbar exactly into the cloned `Veridin-Matlab` directory. 
5. *(Optional)* For maximum safety, you may right-click the `src/` directory directly within MATLAB's file viewer and select **Add to Path > Selected Folders and Subfolders**.

The codebase is entirely segmented into independent execution blocks allowing isolated generation of the problem steps. Ensure your MATLAB environment's working directory is firmly locked into the `Veridin-Matlab` root folder containing `main.m` to avoid arbitrary pathing failures!

### Step 2: Executing the Trajectory Optimization Loop
The primary driver `main.m` is responsible for evaluating hundreds of thousands of independent geometric bounds.
```matlab
% In MATLAB Console:
main
```
**Detailed Sub-Operations:**
- `main.m` loads the Ephemeris boundaries and iterates systematically through three primary variables: `Caelus Departure Bounds (MJD 60000 -> 61095)`, `TOF Ventus Intercept`, and `TOF Glacia Intercept`.
- Valid interactions check localized thermal constraints (skipping anything traversing $< 0.4 \text{ AU}$ of the central star) and minimum altitude limits above Ventus ($h_{flyby} > 2000 \text{ km}$).
- Valid geometries push initial tracking variables into our Universal Variables equations (see `VERIDIAN_CODE_GUIDE.md`), returning precise physical fuel costs.
- Automatically isolates and logs the explicit minimal fuel scenario directly over to `data/optimal_trajectory.csv`.

### Step 3: Launch Window Mapping (Porkchop Plot Validation)
To scientifically validate our isolated launch bounds, we map continuous gradient boundaries globally.
```matlab
run('notebooks/porkchop.m');
```
**Detailed Sub-Operations:**
- Engages the local trajectory evaluating cores over continuous bounds iterating strictly Departure Times against Time of Flight combinations.
- Uses `contourf` building dense top-down topological valleys visually highlighting isolated launch windows minimizing $\Delta V_{total}$. 
- Extremely useful in defending optimization results directly in your final physics report.

### Step 4: Orbital Propagation & Tracker Log Generation
You must build your exact required evaluation matrices before animation.
```matlab
export_trajectory
```
**Detailed Sub-Operations:**
- Ingests the explicitly optimal $T_0$ outputs from Step A. Re-solves the boundary Lambert targets returning initial vector $V_1$.
- Generates continuous real-world integration boundaries $\ddot{\mathbf{r}} = -\mu \frac{\mathbf{r}}{r^3}$ binding firmly into MATLAB's implicit standard `ode45` relative to the Veridian Star's core mass.
- Forcefully sets strict bounds isolating integration snapshots identically to 5-day gaps extending across identical 8-year gaps. Maps directly into `results/spacecraft_5day_coords.csv`.

### Step 5: Veridian-Centric & Ventus-Centric Animation Compilation
Concludes your assignment requirements by actively drawing coordinate datasets out into an MP4 file.
```matlab
animate_simulation
```
**Detailed Sub-Operations:**
- Establishes a massive $1200\times600$ plotting field. 
- **Subplot 1:** Traces standard heliocentric orbits projecting the 5-day state matrix arrays sequentially behind the vessel frame by frame.
- **Subplot 2:** Tracks the highly nuanced unpowered flyby dynamically. Actively locks Ventus securely to coordinate `(0,0)`, parsing ship coordinates relative to Ventus position. Scales graphic limitations tightly to Ventus surface bounds capturing exact acceleration geometries!
- Wraps natively to hardware MP4 writers into `results/planetary_simulation.mp4`.

---

## 3. Physical Directory Architecture

```text
Veridin-Matlab/
├── src/                          # Deep Engine Solvers
│   ├── constants.m               # Centralized parameters definition (Masses, distances, bounds)
│   ├── delta_v.m                 # Patched-Conic vis-viva estimators and planetary bounds
│   ├── EphemerisSystem.m         # 1-Dimensional Cubic Spline array evaluators handling missing timeline constraints
│   ├── evaluate_trajectory.m     # Singular overarching physics chain feeding localized grid matrices
│   ├── gravity_assist.m          # Trigonometric delta evaluations isolating turn velocities
│   ├── lambert.m                 # Explicit boundary Root solver tracking Universal Anomaly values
│   └── search.m                  # Fast-failing grid iteration minimizing nested limits
│
├── notebooks/
│   └── porkchop.m                # Graphical 2D contour builders explicitly verifying results
│
├── main.m                        # Primary structural system evaluating overarching trajectory loops
├── export_trajectory.m           # Instantiates ode45 tracing initial vectors chronologically across exact 5-day intervals
├── animate_simulation.m          # Extracts data plotting Ventus-centric and Helio-centric dual panels organically into .mp4
│
├── data/                         # CSV target definitions mapping Ephemeris models
├── results/                      # Deliverables (5-day stepwise outputs and .mp4 visuals)
└── report/
    └── mission_report.md         # Final assignment document layout
```

For extremely detailed breakdowns mapping the pure numerical formulations, exact mathematical logic, tracking constraints, and explicit local code behaviors driving these functions natively through standard MATLAB blocks without explicit high-level Toolboxes, please see [VERIDIAN_CODE_GUIDE.md](./VERIDIAN_CODE_GUIDE.md).
