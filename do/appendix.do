// S1 Table
use "${git}/constructed/sp-data.dta" , clear

  fvset base 3 type
  putexcel set "${git}/outputs/s1-table.xlsx" , replace

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

// S1-3 Figures
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
      graphopts(ysize(5) ylab(,labsize(vsmall)) scale(.7) title("Case `case'") ///
        xlab(-2 "+2 SD" -1 "+1 SD" 0 "Zero" 1 "+1 SD" 2 "+2 SD") xscale(alt) xoverhang ///
        xtit(" {&larr} Public Dispensaries    Private non-MD Providers {&rarr}"))

      graph save "${git}/outputs/f-specialist-13-`case'.gph" , replace

    forest reg ///
      (correct checklist microbio re_1 re_3 re_4 dr_1 dr_4) ///
      (med_l_any_2 med_l_any_3 med_k_any_9) ///
      (g11 g1 g2 g4 g5 g6 g7 g8 g9 g10) ///
      (time_waiting p time) ///
      if case == `case' & type != 4 & type != 1 ///
    , cl(qutub_id) t(private) controls(i.sp_id) d b bh sort(global) ///
      graphopts(ysize(5) ylab(,labsize(vsmall)) scale(.7) title("Case `case'") ///
        xlab(-2 "+2 SD" -1 "+1 SD" 0 "Zero" 1 "+1 SD" 2 "+2 SD") xscale(alt) xoverhang ///
        xtit(" {&larr} Public Hospitals    Private non-MD Providers {&rarr}"))

      graph save "${git}/outputs/f-specialist-23-`case'.gph" , replace

    forest reg ///
      (correct checklist microbio re_1 re_3 re_4 dr_1 dr_4) ///
      (med_l_any_2 med_l_any_3 med_k_any_9) ///
      (g11 g1 g2 g4 g5 g6 g7 g8 g9 g10) ///
      (time_waiting p time) ///
      if case == `case' & type != 3 & type != 2 ///
    , cl(qutub_id) t(private) controls(i.sp_id) d b bh sort(global) ///
      graphopts(ysize(5) ylab(,labsize(vsmall)) scale(.7) title("Case `case'") ///
        xlab(-2 "+2 SD" -1 "+1 SD" 0 "Zero" 1 "+1 SD" 2 "+2 SD") xscale(alt) xoverhang ///
        xtit(" {&larr} Public Dispensaries    Private MBBS+MD Providers {&rarr}"))

      graph save "${git}/outputs/f-specialist-14-`case'.gph" , replace

    forest reg ///
      (correct checklist microbio re_1 re_3 re_4 dr_1 dr_4) ///
      (med_l_any_2 med_l_any_3 med_k_any_9) ///
      (g11 g1 g2 g4 g5 g6 g7 g8 g9 g10) ///
      (time_waiting p time) ///
      if case == `case' & type != 3 & type != 1 ///
    , cl(qutub_id) t(private) controls(i.sp_id) d b bh sort(global) ///
      graphopts(ysize(5) ylab(,labsize(vsmall)) scale(.7) title("Case `case'") ///
        xlab(-2 "+2 SD" -1 "+1 SD" 0 "Zero" 1 "+1 SD" 2 "+2 SD") xscale(alt) xoverhang ///
        xtit(" {&larr} Public Hospitals    Private MBBS+MD Providers {&rarr}"))

      graph save "${git}/outputs/f-specialist-24-`case'.gph" , replace
  }

  graph combine ///
    "${git}/outputs/f-specialist-1.gph" ///
    "${git}/outputs/f-specialist-2.gph" ///
  , ysize(5)

    graph export "${git}/outputs/s1_fig.tif" , replace
    graph export "${git}/outputs/s1_fig.eps" , replace

  graph combine ///
    "${git}/outputs/f-specialist-13-1.gph" ///
    "${git}/outputs/f-specialist-13-2.gph" ///
    "${git}/outputs/f-specialist-23-1.gph" ///
    "${git}/outputs/f-specialist-23-2.gph" ///
  , ysize(5) altshrink

    graph export "${git}/outputs/s2_fig.tif" , replace
    graph export "${git}/outputs/s2_fig.eps" , replace

  graph combine ///
    "${git}/outputs/f-specialist-14-1.gph" ///
    "${git}/outputs/f-specialist-14-2.gph" ///
    "${git}/outputs/f-specialist-24-1.gph" ///
    "${git}/outputs/f-specialist-24-2.gph" ///
  , ysize(5) altshrink
      
  graph export "${git}/outputs/s3_fig.tif" , replace
  graph export "${git}/outputs/s3_fig.eps" , replace
  
  // S4 Figure -------------------------------------------------------------------------------
  use "${git}/constructed/mcgm.dta" , clear
  
    betterbar mcgm_* ///
    , over(sampled) legend(on region(lc(none)) c(1) pos(4) ring(0) size(small) textfirst symxsize(small)) ///
      xtit("Monthly patients per dispensary {&rarr}") ///
      n ci barl xoverhang format(%9.1f) barcolor(red gs4)
  
    graph export "${git}/outputs/s4_fig.tif" , replace
    graph export "${git}/outputs/s4_fig.eps" , replace

// End
