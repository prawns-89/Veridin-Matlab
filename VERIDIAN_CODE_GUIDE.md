# Mission Veridian — MATLAB Code Walkthrough

**Gravity-Assist Trajectory Design in a Fictional Exoplanetary System**
*Flight and Space Mechanics · VJTI Mumbai · R5ME2206T*

---

## Table of Contents

1. [What the Codebase Does](#1-what-the-codebase-does)
2. [Repository Layout](#2-repository-layout)
3. [How to Run It](#3-how-to-run-it)
4. [Module-by-Module Breakdown](#4-module-by-module-breakdown)
5. [Entry-Point Scripts](#5-entry-point-scripts)
6. [Data Flow — End to End](#6-data-flow--end-to-end)
7. [Key Equations & Differences from Python](#7-key-equations--differences-from-python)

---

## 1. What the Codebase Does

The spacecraft evaluates parking orbits dynamically. Starting from a **500 km circular parking orbit** around **Caelus**, our spacecraft must successfully rendezvous with **Glacia** within exactly 8 Earth terrestrial years (2922 Days). To stay within the firm $1.5 \text{ km/s}$ continuous propellant budget (`MAX_DV_BUDGET`), an unpowered slingshot gravity-assist must be cleanly performed inside **Ventus's** gravitational well.

This codebase natively sweeps hundreds of thousands of spatial combinations evaluating the exact departure times and split `Time-of-Flight` transit durations natively in MATLAB.

---

## 2. Repository Layout

```text
Veridin-Matlab/
├── src/                          # Core physics math library
│   ├── constants.m               # Physical constants limits definition
│   ├── delta_v.m                 # Vis-Viva calculation solvers
│   ├── EphemerisSystem.m         # Cubic Spline analytical planetary interpolator
│   ├── evaluate_trajectory.m     # Modular system combining solvers into a single pass
│   ├── gravity_assist.m          # Trigonometric flyby unpowered parameter mapping 
│   ├── lambert.m                 # Root solver converting positions to V1/V2
│   └── search.m                  # Grid iteration nested bounding logic
│
├── notebooks/
│   └── porkchop.m                # Detailed plotting script dynamically mapping Delta-V
│
├── main.m                        # Primary Entry File - Extracts optimal properties globally
├── export_trajectory.m           # Propagates Lambert boundaries explicitly into 5-day intervals
├── animate_simulation.m          # Draws Helo/Ventus centric representations over 2 subplots
│
├── data/                         # CSV definitions and Optimal Search results 
├── results/                      # 5-day stepwise outputs and .mp4 visuals
└── report/
    └── mission_report.md         # Formatted formal rubric write-ups
```

---

## 3. How to Run It

Inside your MATLAB command window, simply navigate to this directory and sequentially execute:
1. `main`: Finds the global minimum required for the launch and saves it to `data`.
2. `export_trajectory`: Translates the initial $V_\infty$ departure vectors into simulated `ode45` chronological snapshots.
3. `animate_simulation`: Renders the array results neatly into `.mp4` format for viewing bounds.
4. `run('notebooks/porkchop.m')`: Visually evaluates the search range mapping Delta-V as a contour valley.

---

## 4. Module-by-Module Breakdown

### `src/EphemerisSystem.m`
Loads the CSV using `readtable` and fits a piecewise polynomial independently for every spatial parameter utilizing `spline()`. This fundamentally avoids jumps caused by 5-day structural gaps when querying times at arbitrary fractions.

### `src/lambert.m`
Takes boundaries $r_1, r_2$, travel time constraint, and $\mu$. We implemented the Universal Variable anomaly using Stumpff functions heavily to avoid classical ellipse/hyperbola boundaries breaking. Roots evaluate beautifully off standard `fzero`.

### `src/gravity_assist.m`
Subtracts Ventus velocity identically across the input arrays. We analytically derive the implicit tracking turn-angle $\delta$:
$$ \delta = \arccos\left(\frac{V_{\infty, in} \cdot V_{\infty, out}}{|V_{\infty, in}| \times |V_{\infty, out}|}\right) $$
Derives required periapsis passes to enforce standard unpowered constraints. 

### `src/delta_v.m`
Calculates classical patched-conic escape boundaries evaluated at exactly $500 \text{ km}$ above the planetary body using $V_{park} = \sqrt{\frac{\mu}{R}}$.

---

## 5. Entry-Point Scripts

### `main.m`
Runs a robust 3D structural iteration analyzing `~409,000` variants directly via `search.m`.
Output limits are converted out and verified.

### `export_trajectory.m` (Native ODE45 Implementation)
Crucially requested by assignment rubric item 5. We hook natively into `ode45`. We apply our Star's gravity explicitly over a continuous integration scale, taking the $V_1$ velocities output by our `lambert` equation and generating a strictly bounded array logging `X,Y,Z` exactly every 5-days.

### `animate_simulation.m`
Creates dynamic plots plotting directly into `VideoWriter`.
*   **Heliocentric Scale:** Plots Caelus, Ventus, Glacia static orbits.
*   **Ventus-centric Scale:** A secondary dynamic axis natively bound that re-centers explicitly to Ventus $r(t) = 0$. Provides beautiful deep visualization tracking the unpowered turn!

---

## 6. Data Flow — End to End

```text
veridian_ephemeris.csv
        │
        ▼
   EphemerisSystem (spline)
        │
        ▼
   evaluate_trajectory()
    ├── 1. get_state(Caelus, Ventus, Glacia)
    ├── 2. lambert(r_C, r_V) → v1_depart, v1_arrive
    ├── 3. lambert(r_V, r_G) → v2_depart, v2_arrive
    ├── 4. gravity_assist(v1_arrive, v2_depart) → Extracts needed altitude
    ├── 5. delta_v(Caelus Departure)
    └── 6. Rendezvous penalty → v_inf_arrive
        │
        ▼ 
   Grid search finds minimum total
        │
        ▼
   optimal_trajectory.csv  ----►  ode45 explicitly traces 5-day paths
```

---

## 7. Key Equations & Differences from Python

Because `SciPy` is entirely locked away, this MATLAB port translates everything organically using basic linear algebra boundaries.
*   **Root Seeking:** Python uses `scipy.optimize.root_scalar` taking custom bracketing. MATLAB gracefully captures these boundaries analytically bypassing edge exceptions using `optimset` configurations bound to `fzero`.
*   **Data Serialization:** Directly managed using the extremely simple structured output of MATLAB's `table()` structures. `writetable` ensures exact tabular column matches for the required formatting.

---
*Created for VJTI Mumbai, Semester IV AY 2025-26*
