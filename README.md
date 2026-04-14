# Mission Veridian: Gravity-Assist Trajectory (MATLAB Version)

**Course:** Flight and Space Mechanics (R5ME2206T)  
**Institute:** VJTI Mumbai — Second-Year Aerospace Engineering MDM, Semester IV (2025-26)

---

## Overview

This repository implements the full mathematical gravity-assist trajectory pipeline design for the Veridian system in MATLAB. The module calculates patched conics to navigate our theoretical spacecraft from a circular Caelus parking orbit, performing a gravity-assist flyby on Ventus, before matching relative velocities with Glacia (`M_INITIAL=2500kg`, `max_dv=1.5 km/s`).

---

## Operating Instructions

### 1. Requirements

Ensure you have MATLAB installed, along with any necessary toolboxes (e.g., Optimization Toolbox, Mapping Toolbox) depending on the plotting and optimization needs.
Simply add the current directory and `src/` to your MATLAB path.

### 2. Search & Simulation (`main.m`)

To initiate the nested parameter search loops iterating through thousands of variations of Departure Times (*MJD 60000 - 61095*) and Times-of-Flight (*200 - 800 Days*) bounded by physical limits (`Ventus Flyby > 2000 km altitude`, etc.):

Run in the MATLAB Command Window:
```matlab
main
```
*Outputs optimal constraints to: `data/optimal_trajectory.csv`*

### 3. Visual Simulation (`animate_simulation.m`)

To generate a full topological animation of the Caelus $\rightarrow$ Ventus $\rightarrow$ Glacia ephemeris parameters mapping standard orbital mechanic alignments directly from data points:

Run in the MATLAB Command Window:
```matlab
animate_simulation
```
*Outputs compiled GIF file `results/planetary_simulation.gif`.*

### 4. Notebooks / Live Scripts (Visualisations & Verification)

Open the MATLAB Live Scripts (`.mlx` files) inside the `notebooks/` folder:

- **`01_verification.mlx`**: Demonstrates precision testing of our Universal Variables `Lambert` formulation solver against analytical baseline equations.
- **`02_porkchop.mlx`**: Parses grid search parameters into standard $\Delta V$ contour visualizations for the initial window search.
- **`03_optimal_trajectory.mlx`**: Extracts the generated Caelus $\rightarrow$ Ventus $\rightarrow$ Glacia path for heliocentric comparisons.

### 5. Mathematical Methodology & Report

The methodological descriptions, equations, interpretation, and structural breakdown of the analysis has been compiled inside `report/` (and original in `VERIDIAN_CODE_GUIDE.md`). Use any standard markdown-to-pdf converter to render it as a continuous PDF if required.
