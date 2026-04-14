# Mission Veridian: Gravity-Assist Trajectory Optimization Report

**Team Members:** [Your Names Here]

## Objective
The goal is to design an optimal trajectory from an initial 500 km parking orbit around Caelus to a rendezvous with Glacia, utilzing an unpowered gravity assist around Ventus to minimize total $\Delta V$. The spacecraft must complete this mission within 8 Earth years, keeping fuel expenditure strictly below 1.5 km/s.

## Strategy to Find Optimum Trajectory
Due to the vastness of the parameter space, finding the global optimum requires a structured grid-search approach analyzing distinct launch windows and Time-of-Flight (TOF) variables across combinations:
1. **Departure Bounds**: We iterate over plausible launch dates ranging symmetrically around favorable oppositions (MJD 60000 - 61095).
2. **Transfer Legs (Lambert's Problem)**: For every departure date and combination of Caelus $\rightarrow$ Ventus TOF and Ventus $\rightarrow$ Glacia TOF, the corresponding spatial position vectors are queried via our continuous analytical ephemeris interpolator.
3. **Universal Variables Solver**: To circumvent singularities and handle any orbital conic sections transparently, the Universal Variable formulation of Lambert’s problem is utilized to derive velocities analytically.
4. **Patched-Conic Match & Constraints**: 
   - A departure burn $\Delta V_{dep}$ is evaluated at the periapsis of an escape hyperbola relative to Caelus.
   - The two transfer legs overlap at Ventus, forming the incoming and outgoing asymptotes of a flyby. We determine the resulting turning angle and enforce a periapsis lower bound (> `2000 km` altitude) to confirm a safe, unpowered pass without atmospheric collision.
   - Any mathematical velocity mismatch across the Ventus asymptote is penalized as a powered flyby addition ($\Delta V_{flyby}$).
   - Final rendezvous functionality at Glacia demands a deep braking $\Delta V_{arr} = V_{\infty_{arrive}}$.
5. **Optimization Rule**: Evaluate all parametrically valid sets falling inside thermal constraints, isolating the single configuration that minimizes $\Delta V_{total} = \Delta V_{dep} + \Delta V_{flyby} + \Delta V_{arr}$.

## MATLAB Implementation Details
The codebase was constructed purely using standard base MATLAB numerical functions to highlight fundamental programmatic mechanics:
- **`EphemerisSystem.m`**: Converts discrete tabular 5-day state vectors into continuous curves via `spline(...)` 1D piece-wise interpolation for fluid vector querying.
- **`lambert.m`**: Calculates Stumpff functions parametrically and precisely isolates the root of the generalized Time-of-Flight equation using `fzero`.
- **`search.m`**: Integrates nested loop filtering, strategically short-circuiting poor candidates prior to heavy computation.
- **`export_trajectory.m`**: Handles orbital propagation organically by integrating standard 2-Body states via MATLAB's built-in `ode45` relative to the initial conditions sourced from the optimalLambert legs. Records chronological X, Y, Z states faithfully at exactly 5-day offsets.
- **`animate_simulation.m`**: Compiles dual-viewport analytics—simultaneously projecting the zoomed-out heliocentric system while tracking relative hyperbola motion inside a Ventus-centric observation sphere, mapping frames faithfully to `.mp4`.
