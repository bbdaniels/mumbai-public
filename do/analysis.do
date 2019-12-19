// Code for data analysis

// Randomization -------------------------------------------------------------------------------
use "${directory}/constructed/mcgm.dta" , clear

  gen C2 = mcgm_opd/10
    lab var C2 "Average OPD (x10)"

  lab def sampled 0 "Not Sampled" 1 "Sampled for SPs"
    lab val sampled sampled

  betterbar C2 mcgm_sputum mcgm_sputum_pct mcgm_sputum_pos mcgm_cbnaat ///
    mcgm_cbnaat_mtb mcgm_cbnaat_rif mcgm_cxr mcgm_cxr_pos ///
  , over(sampled) legend(on c(1) pos(6) ring(1)) ///
    n ci barl xoverhang format(%9.1f)

  graph export "${directory}/outputs/f-randomization-1.eps" , replace

  forest reg (C2 mcgm_sputum_pct mcgm_sputum_pos mcgm_cbnaat ///
    mcgm_cbnaat_mtb mcgm_cbnaat_rif mcgm_cxr mcgm_cxr_pos) ///
  , t(sampled) d graphopts(xtit("Difference in dispensaries receiving SPs"))

  graph export "${directory}/outputs/f-randomization-2.eps" , replace


// Time trends -------------------------------------------------------------------------------
use "${directory}/constructed/mcgm-ts.dta" , clear

  gen C2 = C/10
    lab var C2 "Average Monthly OPD (x10)"

  betterbar C2 D I J Q ///
  , over(month) legend(on c(1) pos(5) ring(0)) ///
    n ci barl xoverhang format(%9.1f) ///
    barcolor(eltblue emidblue edkblue)

  graph export "${directory}/outputs/f-timeseries.eps" , replace

// Summary statistics --------------------------------------------------------------------------
use "${directory}/constructed/sp-data.dta" , clear

  // Process measures
  local experience = "correct g11 time_waiting p time checklist_n"
  // Quality measures
  local quality = "ce_2 dr_1 dr_4 re_1 re_3 re_4 med_l_any_1 med_l_any_2 med_l_any_3 med_k_any_9"
  // Satisfaction
  local satisfaction = "g1 g2 g3 g4 g5 g6 g7 g8 g9 g10"
  // Shortcut
  local pq = "`experience' `quality' `satisfaction'"

sumstats ///
  (`pq') ///
  using "${directory}/outputs/sp-summary.xlsx" ///
  , stats(mean sd p25 med p75) replace

// Quality differences -------------------------------------------------------------------------
use "${directory}/constructed/sp-data.dta" , clear

forv case = 1/2 {
betterbar ///
  ce_2 dr_1 dr_4 re_1 re_3 re_4 med_l_any_1 med_l_any_2 med_l_any_3 med_k_any_9 ///
  if case == `case' , over(type) n xoverhang ///
  legend(on c(1) ring(1) pos(6)) xlab(${pct}) pct barl ylab(,labsize(small)) ysize(5)

  graph export "${directory}/outputs/f-quality-`case'.eps" , replace
}

// Price and convenience -----------------------------------------------------------------------
use "${directory}/constructed/sp-data.dta" , clear

gen c = correct*100
  lab var c "Quality (0-100)"

local x = 0
foreach var of varlist c g11 time_waiting p time checklist_n  {
local ++x
betterbarci `var' ///
  , over(type) yscale(off) ylab(,labsize(small)) v n ///
    barl format(%9.1f) legend(on r(1) pos(6) ring(1) size(small) symxsize(small))

    graph save "${directory}/temp/convenience-`x'.gph" , replace
}

  grc1leg ///
    "${directory}/temp/convenience-1.gph" ///
    "${directory}/temp/convenience-2.gph" ///
    "${directory}/temp/convenience-3.gph" ///
    "${directory}/temp/convenience-4.gph" ///
    "${directory}/temp/convenience-5.gph" ///
    "${directory}/temp/convenience-6.gph" ///
    , c(2)

    graph save "${directory}/temp/convenience.gph" , replace
    graph combine "${directory}/temp/convenience.gph" , ysize(5)

    graph export "${directory}/outputs/f-convenience.eps" , replace

// SP Satisfaction -----------------------------------------------------------------------------
use "${directory}/constructed/sp-data.dta" , clear

betterbar g1 g2 g3 g4 g5 g6 g7 g8 g9 g10  ///
  , over(type) n pct barl ci xoverhang xlab(${pct}) ///
    legend(on c(1) size(small)) ysize(5) ylab(,labsize(small))

    graph export "${directory}/outputs/f-satisfaction.eps" , replace


// Big comparison ------------------------------------------------------------------------------
use "${directory}/constructed/sp-data.dta" , clear

gen private = 1-public
  lab var private "Private Sector"

forest reg ///
  (ce_2 dr_1 dr_4 re_1 re_3 re_4) ///
  (med_l_any_1 med_l_any_2 med_l_any_3 med_k_any_9) ///
  (correct g11 time_waiting p time checklist_n) ///
  (g1 g2 g3 g4 g5 g6 g7 g8 g9 g10) ///
  if type > 1 ///
, cl(qutub_id) t(private) controls(i.case i.sp_id) d b bh sort(global) ///
  graphopts(ysize(5) ylab(,labsize(vsmall)) ///
    xlab(-2 "2 SD" -1 "1 SD" 0 " " 1 "1 SD" 2 "2 SD") xscale(alt) xoverhang ///
    xtit(" {&larr} Favors Public   Favors Private {&rarr}",size(small)))

  graph export "${directory}/outputs/f-comparison.eps" , replace

// End of dofile
