// Figure 1 -------------------------------------------------------------------------------
use "${git}/constructed/mcgm.dta" , clear

  betterbar mcgm_* ///
  , over(sampled) legend(on region(lc(none)) c(1) pos(4) ring(0) size(small) textfirst symxsize(small)) ///
    xtit("Monthly patients per dispensary {&rarr}") ///
    n ci barl xoverhang format(%9.1f) barcolor(red gs4)

  graph export "${git}/outputs/fig1.eps" , replace
  
// Figure 2 ----------------------------------------------------
use "${git}/constructed/sp-data.dta" , clear

  forv case = 1/2 {
    betterbarci ///
      re_5 re_4 re_3 re_1 microbio correct ///
    if case == `case' ///
    , v over(public) barlab pct n xoverhang scale(0.7) title("Case `case'") ///
      barcolor(gs6 gs12) ///
      legend(on region(lc(none)) region(lc(none)) r(1) ring(1) size(small) symxsize(small) symysize(small)) ///
      ysize(6) ylab(${pct}) nodraw saving("${git}/outputs/f-testing-`case'.gph" , replace) 
  }

  grc1leg ///
    "${git}/outputs/f-testing-1.gph" ///
    "${git}/outputs/f-testing-2.gph" ///
  , c(1) pos(12) imargin(0 0 0 0)
    graph draw, xsize(5)
  
    graph export "${git}/outputs/fig2.eps" , replace
    
// Figure 3 ---------------------------------------------------
use "${git}/constructed/sp-data.dta" , clear

  foreach var of varlist ///
    correct microbio  ///
    re_1 re_4 ///
    time_waiting checklist ///
    med_l_any_3 time  ///
    med_l_any_2 p {
      if inlist("`var'","correct","checklist","re_1","re_4","microbio","med_l_any_2","med_l_any_3") {
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

    graph export "${git}/outputs/fig3.eps" , replace

// Figure 4 ----------------------------------------------------
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

    graph export "${git}/outputs/fig4.eps" , replace

// Figure 5 -------------------------------------------------------------
use "${git}/constructed/sp-data.dta" , clear

replace g11 = g11/10
  lab var g11 "SP Subjective Rating (10/10 = 100%)"

betterbar g11 g1 g2 g3 g4 g5 g6 g7 g8 g9 g10  ///
  , over(type) n pct barl ci xoverhang xlab(${pct}) scale(.7) ///
    legend(on region(lc(none)) symxsize(small) symysize(small) ///
      pos(12) c(1) size(small)) ysize(6) ylab(,labsize(small))

    graph export "${git}/outputs/fig5.eps" , replace

// Figure 6 and 7 ---------------------------------------
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
    xtit(" {&larr} Public Hospitals   Private Sector {&rarr}"))

  graph export "${git}/outputs/fig6.eps" , replace

forest reg ///
  (correct checklist microbio re_1 re_3 re_4 dr_1 dr_4) ///
  (med_l_any_1 med_l_any_2 med_l_any_3 med_k_any_9) ///
  (g11 g1 g2 g3 g4 g5 g6 g7 g8 g9 g10) ///
  (time_waiting p time) ///
  if type != 2 ///
, cl(qutub_id) t(private) controls(i.case i.sp_id) d b bh sort(global) ///
  graphopts(ysize(5) ylab(,labsize(vsmall)) scale(.7) ///
    xlab(-2 "+2 SD" -1 "+1 SD" 0 "Zero" 1 "+1 SD" 2 "+2 SD") xscale(alt) xoverhang ///
    xtit(" {&larr} Public Dispensaries   Private Sector {&rarr}"))

  graph export "${git}/outputs/fig7.eps" , replace
  
// End of dofile
