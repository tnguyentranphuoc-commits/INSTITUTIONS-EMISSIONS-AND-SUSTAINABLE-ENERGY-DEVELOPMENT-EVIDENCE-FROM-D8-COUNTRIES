# INSTITUTIONS, EMISSIONS, AND SUSTAINABLE ENERGY DEVELOPMENT: EVIDENCE FROM D8 COUNTRIES
🛠️ **Tech Stack**: Stata (panel data, PCA, FGLS, PCSE)

---

## (i). Overview

This project investigates how **economic growth, environmental pressures, and institutional quality** jointly shape **Sustainable Energy Development (SED)** in **D8 countries** over the period **2008–2022**.

To capture the multidimensional nature of energy transition, the study constructs a **Sustainable Energy Development Index (SEDI)** using **Principal Component Analysis (PCA)**, integrating renewable energy capacity, generation, consumption, and energy-adjusted savings.

The analysis goes beyond linear growth–energy relationships by explicitly examining the **moderating roles of institutional quality**, focusing on:
- **Regulatory Quality (RQ)**
- **Political Stability (PS)**

This framework allows the study to distinguish between **growth-led energy transition**, **pollution-driven pressures**, and **institutional conditioning effects**.

---

## (ii). Data Description

- **Sample**: D8 countries  
- **Period**: Annual panel, **2008–2022**
- **Sources**: World Bank, international energy databases

### Key Variables
- **SEDI** – Sustainable Energy Development Index (PCA-based)
- **GDP per capita** – economic growth
- **Energy Intensity (EI)** – energy efficiency proxy
- **CO₂ emissions** and **GHG emissions** – environmental pressure
- **Natural Resource Rents (RN)** – resource dependence
- **Institutional variables**:
  - Regulatory Quality (RQ)
  - Political Stability (PS)

---

## (iii). Methodology

### 🔍 Index Construction
- **PCA** used to construct SEDI from multiple renewable energy indicators
- Eigenvalues and variance explained validate index reliability

### 📈 Econometric Strategy
A progressive panel estimation framework is employed:
- **OLS, Fixed Effects (FE), Random Effects (RE)** as baselines
- Model selection via **F-test, Breusch–Pagan LM, Hausman test**
- **FGLS** to address heteroskedasticity and serial correlation
- **PCSE** to ensure robustness under cross-sectional dependence

### 🧩 Extended Specifications
- Interaction terms:
  - GDP × Institutional Quality
  - Emissions × Institutional Quality
- Designed to test whether institutions **amplify or constrain** sustainable energy outcomes

---

## (iv). Modeling Pipeline

```text
STEP 1: Data cleaning and descriptive analysis
→ STEP 2: PCA construction of Sustainable Energy Development Index (SEDI)
→ STEP 3: Baseline OLS / FE / RE estimation
→ STEP 4: Model selection and diagnostic testing
→ STEP 5: FGLS estimation (efficiency-focused)
→ STEP 6: PCSE estimation (robust inference)
→ STEP 7: Institutional interaction models
→ STEP 8: Synthesis of growth–environment–institution mechanisms
```
(v). Main Findings (Summary)

- Economic growth supports sustainable energy development, but only under strong regulatory quality.
- Energy intensity and natural resource dependence hinder the energy transition, reinforcing fossil-fuel lock-in.
- CO₂ and GHG emissions act as pressure-induced drivers, encouraging energy transition when institutions are effective.
- Political stability may unintentionally slow energy transition by preserving existing energy structures.
- Institutional quality is a key conditioning factor, not a passive background variable.

---

(vi). Economic Relevance

- Demonstrates that energy transition is not growth-automatic, but institution-dependent.
- Highlights the need to align environmental pressure with regulatory capacity.

Provides insights for:
- Energy policy design in emerging economies
- Institutional reform for sustainable development
- Long-term energy and climate strategy

---

(vii). Repository Contents

- `/Stata_Script.do` – Full econometric workflow (PCA → OLS/FE/RE → FGLS → PCSE → interactions)
- `/Dataset.dta` – Country-level panel dataset
- `/Methods and Results.pdf` – Detailed methodology and empirical discussion
- `/README.md` – Project documentation

---

(viii). Keywords

Sustainable energy development · Institutions · Economic growth · Emissions · PCA · FGLS · PCSE · D8 countries

---

(ix). Citation

Toan N.T.P. (2025)  
*THE DETERMINANTS OF SUSTAINABLE ENERGY DEVELOPMENT: ECONOMIC GROWTH, GOVERNANCE, AND ENVIRONMENTAL TRADE-OFFS IN D8 COUNTRIES.*  
College of Economics, Law and Government – CELG 2024, University of Economics Ho Chi Minh City (UEH)

---

(x). License

📜 MIT License

---

(xi). Acknowledgements

This research was conducted under the **CELG Awards 2024** framework.  
Special thanks to the CELG academic committee for methodological guidance and research support.
