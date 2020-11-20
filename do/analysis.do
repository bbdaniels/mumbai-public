// Code for data analysis

// Sampling balance -------------------------------------------------------------------------------
use "${git}/constructed/mcgm.dta" , clear

  betterbar mcgm_* ///
  , over(sampled) legend(on region(lc(none)) c(1) pos(4) ring(0) size(small) textfirst symxsize(small)) ///
    xtit("Monthly patients per dispensary {&rarr}") ///
    n ci barl xoverhang format(%9.1f) barcolor(red gs4)
      
  graph export "${git}/outputs/f-balance.eps" , replace

// Time trends -------------------------------------------------------------------------------
use "${git}/constructed/mcgm-ts.dta" , clear

  gen C2 = C/10
    lab var C2 "Average Monthly OPD (x10)"

  betterbar C2 D I J Q ///
  , over(month) legend(on region(lc(none)) c(1) pos(5) ring(0)) ///
    n ci barl xoverhang format(%9.1f) ///
    barcolor(eltblue emidblue edkblue)

  graph export "${git}/outputs/f-timeseries.eps" , replace

// Summary statistics --------------------------------------------------------------------------
use "${git}/constructed/sp-data.dta" , clear

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
  using "${git}/outputs/sp-summary.xlsx" ///
  , stats(mean sd p25 med p75) replace

// Quality differences -------------------------------------------------------------------------
use "${git}/constructed/sp-data.dta" , clear

forv case = 1/2 {
betterbarci ///
  ce_2 dr_1 dr_4 re_1 re_3 re_4 med_l_any_1 med_l_any_2 med_l_any_3 med_k_any_9 ///
  if case == `case' , over(type) n xoverhang ///
  legend(on region(lc(none)) c(1) ring(1) pos(6)) xlab(${pct}) pct barl ylab(,labsize(small)) ysize(6)

  graph export "${git}/outputs/f-quality-`case'.eps" , replace
}

// Price and convenience -----------------------------------------------------------------------
use "${git}/constructed/sp-data.dta" , clear

  local x = 0
  local pct "pct"
  foreach var of varlist ///
    correct med_l_any_2 med_l_any_3 ///
    time_waiting p time  {
      local ++x
      
      betterbarci `var' ///
        , over(type) yscale(off) ylab(,labsize(small)) v n `pct' ///
          barl  nodraw saving("${git}/temp/convenience-`var'.gph" , replace) ///
          legend(on region(lc(none)) region(lc(none)) r(1) ring(1) size(small) symxsize(small) symysize(small))

        local graphs `"`graphs' "${git}/temp/convenience-`var'.gph" "'  
        
      if `x' == 3 local pct "format(%9.1f)"  
    }

  grc1leg `graphs' , c(2) pos(12) 
    graph draw, ysize(5)

    graph export "${git}/outputs/f-convenience.eps" , replace

// SP Satisfaction -------------------------------------------------------------
use "${git}/constructed/sp-data.dta" , clear

replace g11 = g11/10
  lab var g11 "SP Subjective Rating (10/10 = 100%)"

betterbar g11 g1 g2 g3 g4 g5 g6 g7 g8 g9 g10  ///
  , over(type) n pct barl ci xoverhang xlab(${pct}) scale(.7) ///
    legend(on region(lc(none)) symxsize(small) symysize(small) ///
      pos(12) c(1) size(small)) ysize(6) ylab(,labsize(small))

    graph export "${git}/outputs/f-satisfaction.eps" , replace


// Overall regression comparison figures ---------------------------------------
use "${git}/constructed/sp-data.dta" , clear

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
    xtit(" {&larr} Favors Public Hospitals   Favors Private Sector {&rarr}",size(vsmall)))

  graph export "${git}/outputs/f-comparison-1.eps" , replace
  
forest reg ///
  (ce_2 dr_1 dr_4 re_1 re_3 re_4) ///
  (med_l_any_1 med_l_any_2 med_l_any_3 med_k_any_9) ///
  (correct g11 time_waiting p time checklist_n) ///
  (g1 g2 g3 g4 g5 g6 g7 g8 g9 g10) ///
  if type != 2 ///
, cl(qutub_id) t(private) controls(i.case i.sp_id) d b bh sort(global) ///
  graphopts(ysize(5) ylab(,labsize(vsmall)) ///
    xlab(-2 "2 SD" -1 "1 SD" 0 " " 1 "1 SD" 2 "2 SD") xscale(alt) xoverhang ///
    xtit(" {&larr} Favors Public Dispensaries   Favors Private Sector {&rarr}",size(vsmall)))

  graph export "${git}/outputs/f-comparison-2.eps" , replace

// End of dofile
