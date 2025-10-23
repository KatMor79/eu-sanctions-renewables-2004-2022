/********************************************************************
  Replication for: EU Sanctions & Renewables (2004–2022)
  Author: Kattia Moreno
  Stata: 15+  |  Needs: estout, xtabond2  (auto-installed below)
*********************************************************************/

clear all
set more off
version 15

*-----------------------------
* 0) Create results folder
*-----------------------------
cap mkdir "results"

*-----------------------------
* 1) Find the Excel file
*   (tries common locations)
*-----------------------------
local cand1 "data/New Sanctions DataSet fixed.xlsx"
local cand2 "New Sanctions DataSet fixed.xlsx"
capture confirm file "`cand1'"
if (_rc==0) local DATAFILE "`cand1'"
else {
    capture confirm file "`cand2'"
    if (_rc==0) local DATAFILE "`cand2'"
    else {
        di as error ">>> Excel file not found. Place it as:"
        di as error "    data/New Sanctions DataSet fixed.xlsx"
        di as error " or New Sanctions DataSet fixed.xlsx (repo root)"
        exit 601
    }
}

*-----------------------------
* 2) Import Excel
*   (tries sheet 'Final', else first sheet)
*-----------------------------
capture noisily import excel using "`DATAFILE'", sheet("Final") firstrow case(lower) clear
if _rc {
    import excel using "`DATAFILE'", firstrow case(lower) clear
}

* Now vars are lower-case. Quick peek:
describe

*-----------------------------
* 3) Harmonize panel id vars
*-----------------------------
* year numeric?
capture confirm numeric variable year
if _rc {
    destring year, replace ignore(" ,.-")
}

* country numeric id? If string, encode.
capture confirm string variable country
if _rc==0 {
    encode country, gen(country_id)
    drop country
    rename country_id country
}

*-----------------------------
* 4) Ensure key variable names exist
*   (light-touch aliases in case of minor naming diffs)
*-----------------------------
* If your dataset used slightly different names, un-comment and adapt:
* cap rename share_renewables share_rewb
* cap rename reliance_gas     reliancegas
* cap rename reliance_oil     relianceoil
* cap rename gdp_pc_const     gdp
* cap rename energy_prod_pps  eng_pro_pps

* Check presence
local needed share_rewb sanctions reliancegas relianceoil gdp distance ht cl eas_blo sovi_un rus_infl eng_pro_pps
foreach v of local needed {
    capture confirm variable `v'
    if _rc {
        di as error ">>> Missing variable: `v'  (please align names or add a rename above)"
    }
}

*-----------------------------
* 5) Set panel
*-----------------------------
xtset country year

*-----------------------------
* 6) Install packages if needed
*-----------------------------
cap which esttab
if _rc ssc install estout, replace
cap which xtabond2
if _rc ssc install xtabond2, replace

*-----------------------------
* 7) Baseline: Random Effects
*-----------------------------
eststo clear
xtreg share_rewb sanctions relianceoil reliancegas gdp distance ///
      ht cl eas_blo sovi_un rus_infl eng_pro_pps i.year, ///
      re vce(cluster country)
eststo RE

*-----------------------------
* 8) Robustness: System GMM
*-----------------------------
preserve
drop if missing(share_rewb, sanctions, relianceoil, reliancegas, gdp, ///
                distance, ht, cl, eas_blo, sovi_un, rus_infl, eng_pro_pps)

* Note: collapse to keep instruments parsimonious; lags start at 2+
xtabond2 share_rewb L.share_rewb sanctions relianceoil reliancegas gdp ///
         distance ht cl eas_blo sovi_un rus_infl eng_pro_pps i.year, ///
         gmmstyle(L.share_rewb, collapse lag(2 .)) ///
         ivstyle(sanctions relianceoil reliancegas gdp distance ht cl ///
                 eas_blo sovi_un rus_infl eng_pro_pps i.year, equation(level)) ///
         twostep robust small system
eststo SYS_GMM
restore

*-----------------------------
* 9) Export results
*-----------------------------
cap which esttab
if _rc==0 {
    esttab RE SYS_GMM using "results/regression_results.rtf", replace ///
        se b(3) se(3) star(* 0.10 ** 0.05 *** 0.01) ///
        label title("Renewables Share: RE and System GMM") ///
        mtitles("Random Effects" "System GMM") ///
        stats(N r2_within r2_between r2_overall, ///
              labels("Obs." "R2 within" "R2 between" "R2 overall"))
}
else {
    log using "results/regression_results.log", replace text
    esttab RE SYS_GMM
    log close
}

di as result "Done. See /results/ for outputs."
