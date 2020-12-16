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
  keep if public == 1

  sumstats ///
    (correct checklist microbio re_1 re_3 re_4 dr_1 dr_4) ///
    (med_l_any_1 med_l_any_2 med_l_any_3 med_k_any_9) ///
    (g11 g1 g2 g3 g4 g5 g6 g7 g8 g9 g10) ///
    (time_waiting p time) ///
  using "${git}/outputs/t-summary.xlsx" ///
  , stats(mean sd N) replace
  
// Big regression table
use "${git}/constructed/sp-data.dta" , clear

  fvset base 3 type
  putexcel set "${git}/outputs/t-regression.xlsx" , replace
    
  local i = 1
  cap mat drop results
  qui foreach var of varlist ///
    correct checklist microbio re_1 re_3 re_4 dr_1 dr_4 ///
    med_l_any_1 med_l_any_2 med_l_any_3 med_k_any_9 ///
    g11 g1 g2 g3 g4 g5 g6 g7 g8 g9 g10 ///
    time_waiting p time {
      local label : var lab `var'
      
      local ++i
      putexcel A`i' = "`label': Public Dispensaries"
      local ++i
      putexcel A`i' = "`label': Public Hospitals"
      
      reg `var' i..type i.case i.sp_id , cl(qutub_id)
      mat temp = r(table)[1..6,1..2]
      mat temp = temp'
      mat results = nullmat(results) ///
        \ temp
  }
  
  putexcel B1 = matrix(results) , nformat(0.000) colnames
  putexcel save
  
// Questions and exams
use "${git}/constructed/sp-data.dta" , clear

  putexcel set "${git}/outputs/t-checklist.xlsx" , replace
  
  local i = 1
  cap mat drop results
  qui foreach var of varlist ///
    ce_1 ce_2 ce_2a ce_3 ce_4 ce_5 ce_6 ce_7 ///
    sp1_h_1 sp1_h_2 sp1_h_3 sp1_h_4 sp1_h_5 sp1_h_6 sp1_h_7 ///
    sp1_h_8 sp1_h_9 sp1_h_10 sp1_h_11 sp1_h_12 sp1_h_13 sp1_h_14 ///
    sp1_h_15 sp1_h_16 sp1_h_17 sp1_h_18 sp1_h_19 sp1_h_20 ///
    sp4_h_1 sp4_h_2 sp4_h_3 sp4_h_4 sp4_h_5 sp4_h_6 sp4_h_7 sp4_h_8 ///
    sp4_h_9 sp4_h_10 sp4_h_11 sp4_h_12 sp4_h_13 sp4_h_14 sp4_h_15 sp4_h_16 ///
    sp4_h_17 sp4_h_18 sp4_h_19 sp4_h_20 sp4_h_21 sp4_h_22 sp4_h_23 sp4_h_24 ///
    sp4_h_25 sp4_h_26 sp4_h_27 sp4_h_28 sp4_h_29 sp4_h_30 {

        local label : var lab `var'

        local ++i
        putexcel A`i' = "`label'"
          mean `var', over(type)
          putexcel B`i' = matrix(e(b)) , nformat(0.000)

    }
    
  putexcel save
  
// High-level pooled results ---------------------------------------------------
use "${git}/constructed/sp-data.dta" , clear

  foreach var of varlist ///
    correct checklist ///
    microbio time_waiting ///
    med_l_any_3 time  ///
    med_l_any_2 p {
      if inlist("`var'","correct","checklist","microbio","med_l_any_2","med_l_any_3") {
        local pct "pct" 
      }
      else local pct "format(%9.1f)" 
      
      betterbarci `var' ///
        , over(type) yscale(off) ylab(,labsize(small)) v n `pct' ///
          barl nodraw saving("${git}/temp/convenience-`var'.gph" , replace) ///
          legend(on region(lc(none)) region(lc(none)) r(1) ///
            ring(1) size(vsmall) symxsize(small) symysize(small))

        local graphs `"`graphs' "${git}/temp/convenience-`var'.gph" "'      
    }

  grc1leg `graphs' , c(2) pos(12) 
    graph draw, ysize(6)

    graph export "${git}/outputs/f-summary.eps" , replace

// Quality outcomes by case ----------------------------------------------------
use "${git}/constructed/sp-data.dta" , clear

  forv case = 1/2 {
    betterbarci ///
      correct microbio re_1 re_3 re_4 dr_1 ///
      dr_4 med_k_any_9 med_l_any_2 med_l_any_3 ///
    if case == `case' ///
    , over(type) barlab pct n xoverhang scale(0.7) title("Case `case'") ///
      legend(on region(lc(none)) region(lc(none)) r(1) ring(1) size(small) symxsize(small) symysize(small)) ///
      ysize(6) xlab(${pct}) nodraw saving("${git}/outputs/f-quality-`case'.gph" , replace) 
  }

  grc1leg ///
    "${git}/outputs/f-quality-1.gph" ///
    "${git}/outputs/f-quality-2.gph" ///
  , r(1) pos(12) imargin(0 0 0 0)
    graph draw, ysize(5)
  
    graph export "${git}/outputs/f-quality.eps" , replace

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
  (correct checklist microbio re_1 re_3 re_4 dr_1 dr_4) ///
  (med_l_any_1 med_l_any_2 med_l_any_3 med_k_any_9) ///
  (g11 g1 g2 g3 g4 g5 g6 g7 g8 g9 g10) ///
  (time_waiting p time) ///
  if type > 1 ///
, cl(qutub_id) t(private) controls(i.case i.sp_id) d b bh sort(global) ///
  graphopts(ysize(5) ylab(,labsize(vsmall)) scale(.7) ///
    xlab(-2 "+2 SD" -1 "+1 SD" 0 "Zero" 1 "+1 SD" 2 "+2 SD") xscale(alt) xoverhang ///
    xtit(" {&larr} Favors Public Hospitals   Favors Private Sector {&rarr}"))

  graph export "${git}/outputs/f-comparison-1.eps" , replace
  
forest reg ///
  (correct checklist microbio re_1 re_3 re_4 dr_1 dr_4) ///
  (med_l_any_1 med_l_any_2 med_l_any_3 med_k_any_9) ///
  (g11 g1 g2 g3 g4 g5 g6 g7 g8 g9 g10) ///
  (time_waiting p time) ///
  if type != 2 ///
, cl(qutub_id) t(private) controls(i.case i.sp_id) d b bh sort(global) ///
  graphopts(ysize(5) ylab(,labsize(vsmall)) scale(.7) ///
    xlab(-2 "+2 SD" -1 "+1 SD" 0 "Zero" 1 "+1 SD" 2 "+2 SD") xscale(alt) xoverhang ///
    xtit(" {&larr} Favors Public Dispensaries   Favors Private Sector {&rarr}"))

  graph export "${git}/outputs/f-comparison-2.eps" , replace

// Appendix materials: Private specialist provider comparison
use "${git}/constructed/sp-data.dta" , clear 
  
  gen private = 1-public
  replace type = 4 if specialist == 1
    lab def type 4 "MBBS+MD" , add

  forv case = 1/2 {
    betterbarci ///
      correct microbio re_1 re_3 re_4 dr_1 ///
      dr_4 med_k_any_9 med_l_any_2 med_l_any_3 ///
    if case == `case' ///
    , over(type) barlab pct n xoverhang scale(0.7) title("Case `case'") ///
      legend(on region(lc(none)) region(lc(none)) c(1) ring(1) size(small) symxsize(small) symysize(small)) ///
      ysize(6) xlab(${pct}) nodraw saving("${git}/outputs/f-specialist-`case'.gph" , replace) 
      
    forest reg ///
      (correct checklist microbio re_1 re_3 re_4 dr_1 dr_4) ///
      (med_l_any_2 med_l_any_3 med_k_any_9) ///
      (g11 g1 g2 g4 g5 g6 g7 g8 g9 g10) ///
      (time_waiting p time) ///
      if case == `case' & type != 4 & type != 2 ///
    , cl(qutub_id) t(private) controls(i.sp_id) d b bh sort(global) ///
      graphopts(ysize(5) ylab(,labsize(vsmall)) scale(.7) ///
        xlab(-2 "+2 SD" -1 "+1 SD" 0 "Zero" 1 "+1 SD" 2 "+2 SD") xscale(alt) xoverhang ///
        xtit(" {&larr} Favors Public Dispensaries    Favors Private non-MD Providers {&rarr}"))
        
      graph save "${git}/outputs/f-specialist-13-`case'.gph" , replace
      
    forest reg ///
      (correct checklist microbio re_1 re_3 re_4 dr_1 dr_4) ///
      (med_l_any_2 med_l_any_3 med_k_any_9) ///
      (g11 g1 g2 g4 g5 g6 g7 g8 g9 g10) ///
      (time_waiting p time) ///
      if case == `case' & type != 4 & type != 1 ///
    , cl(qutub_id) t(private) controls(i.sp_id) d b bh sort(global) ///
      graphopts(ysize(5) ylab(,labsize(vsmall)) scale(.7) ///
        xlab(-2 "+2 SD" -1 "+1 SD" 0 "Zero" 1 "+1 SD" 2 "+2 SD") xscale(alt) xoverhang ///
        xtit(" {&larr} Favors Public Hospitals    Favors Private non-MD Providers {&rarr}"))
        
      graph save "${git}/outputs/f-specialist-23-`case'.gph" , replace
      
    forest reg ///
      (correct checklist microbio re_1 re_3 re_4 dr_1 dr_4) ///
      (med_l_any_2 med_l_any_3 med_k_any_9) ///
      (g11 g1 g2 g4 g5 g6 g7 g8 g9 g10) ///
      (time_waiting p time) ///
      if case == `case' & type != 3 & type != 2 ///
    , cl(qutub_id) t(private) controls(i.sp_id) d b bh sort(global) ///
      graphopts(ysize(5) ylab(,labsize(vsmall)) scale(.7) ///
        xlab(-2 "+2 SD" -1 "+1 SD" 0 "Zero" 1 "+1 SD" 2 "+2 SD") xscale(alt) xoverhang ///
        xtit(" {&larr} Favors Public Dispensaries    Favors Private MBBS+MD Providers {&rarr}"))
        
      graph save "${git}/outputs/f-specialist-14-`case'.gph" , replace
      
    forest reg ///
      (correct checklist microbio re_1 re_3 re_4 dr_1 dr_4) ///
      (med_l_any_2 med_l_any_3 med_k_any_9) ///
      (g11 g1 g2 g4 g5 g6 g7 g8 g9 g10) ///
      (time_waiting p time) ///
      if case == `case' & type != 3 & type != 1 ///
    , cl(qutub_id) t(private) controls(i.sp_id) d b bh sort(global) ///
      graphopts(ysize(5) ylab(,labsize(vsmall)) scale(.7) ///
        xlab(-2 "+2 SD" -1 "+1 SD" 0 "Zero" 1 "+1 SD" 2 "+2 SD") xscale(alt) xoverhang ///
        xtit(" {&larr} Favors Public Hospitals    Favors Private MBBS+MD Providers {&rarr}"))
        
      graph save "${git}/outputs/f-specialist-24-`case'.gph" , replace
  }


      
      graph combine ///
        "${git}/outputs/f-specialist-1.gph" ///
        "${git}/outputs/f-specialist-reg-1.gph" ///
        "${git}/outputs/f-specialist-2.gph" ///
        "${git}/outputs/f-specialist-reg-2.gph" ///
      , ysize(8) altshrink



// End of dofile
