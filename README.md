# EU-Sanctions Renewables 2004–2022

This repository contains the dataset and replication materials for  
*“Sanctions as Catalysts? The EU’s Renewable Energy Shift in Response to Russian Energy Dependence.”*

## Contents
- `data/New Sanctions DataSet fixed.xlsx` (sheet: `Final`)
- `code/replication.do`
- `results/` (created when running the do-file)
- `LICENSE_DATA.txt` (CC BY 4.0)
- `LICENSE_CODE.txt` (MIT)

## Variables (sheet `Final`)
- `country` — EU member (numeric id 1–28)
- `year` — 2004–2022
- `share_rewb` — Share of renewables in gross final energy consumption (%)
- `sanctions` — 1 for 2014–2022, 0 for 2004–2013 (European Council record)
- `reliancegas`, `relianceoil` — Reliance on Russian gas/oil
- `gdp` — GDP (growth/index as in dataset)
- `distance` — Distance measure used in controls
- `ht`, `cl`, `eas_blo`, `sovi_un`, `rus_infl` — Historical/geo dummies
- `eng_pro_pps` — Energy productivity (PPS)

## Sources
- European Council (2014–2022). *EU restrictive measures against Russia over Ukraine.* Council of the EU.
- Eurostat & World Bank for energy and macro controls (see paper/codebook).
- IEA for the Ratio of Russian Gas imports used to measure Reliance on Russian imports of Natural Gas. The same for oil 

## How to run
Open Stata in the `code/` folder and run:
```stata
do replication.do
