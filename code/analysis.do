// Code for data analysis


// Top level breakdown -------------------------------------------------------------------------
use "${directory}/constructed/sp-data.dta" , clear
betterbarci correct if public == 1, over(cp_4a) by(case) ///
  legend(on c(1) ring(0) pos(1)) v ylab(${pct})

  graph export "${directory}/outputs/correct-public.eps" , replace

// Correctness ---------------------------------------------------------------------------------
use "${directory}/constructed/sp-data.dta" , clear
// keep if cp_4a > 2
graph bar dr_4 re_1 re_3 re_4 re_5 if case == 1 ///
  , over(cp_4a) xsize(10) ylab(${pct}) title("Case 1") ///
  legend(on order(1 "Referral" 2 "CXR" 3 "AFB" 4 "GX" 5 "DST"))

  graph export "${directory}/outputs/correct-1.eps" , replace

graph bar dr_4 re_1 re_3 re_4 re_5 if case == 4 ///
  , over(cp_4a) xsize(10) ylab(${pct}) title("Case 4") ///
  legend(on order(1 "Referral" 2 "CXR" 3 "AFB" 4 "GX" 5 "DST"))

  graph export "${directory}/outputs/correct-4.eps" , replace



// Case by case --------------------------------------------------------------------------------
use "${directory}/constructed/sp-data.dta" , clear
lab var dr_4 "Referral"

betterbarci re_1 re_3 re_4 re_5 dr_4 med_k_any_9 ///
  med_l_any_1 med_l_any_2 med_l_any_3  ///
if public == 1 & case == 1 ///
, over(cp_4a) yscale(noline) ///
  xlab(${pct}) legend(on c(1) region(lc(none) fc(none))) title("Case 1")

  graph save "${directory}/outputs/c1.gph" , replace

betterbarci re_1 re_3 re_4 re_5 dr_4 med_k_any_9 ///
  med_l_any_1 med_l_any_2 med_l_any_3  ///
if public == 1 & case == 4 ///
, over(cp_4a)  yscale(noline) ///
  xlab(${pct}) legend(on c(1) region(lc(none) fc(none))) title("Case 4")

  graph save "${directory}/outputs/c4.gph" , replace

graph combine ///
  "${directory}/outputs/c1.gph" ///
  "${directory}/outputs/c4.gph"

  graph export "${directory}/outputs/basics.eps" , replace



// Groupwise comparison ------------------------------------------------------------------------
use "${directory}/constructed/sp-data.dta" , clear
betterbarci correct, over(group) by(case) ///
  legend(on c(1) ring(0) pos(1)) v ylab(${pct})

// Split -------------------------------------------------------------------------
use "${directory}/constructed/sp-data.dta" , clear

  betterbarci correct , over(cp_4a) by(case) ///
    legend(on c(1) ring(0) pos(1)) v ylab(${pct})

  graph export "${directory}/outputs/correct-publicprivate.eps" , replace


   betterbarci g11 , over(cp_4a) by(case) ///
     legend(on c(1) ring(1) pos(6))

  recode g6 g7 g8 g9 g10 (3=2)(2=1)(1=0)

  betterbarci g6 g7 g8 g9 g10, over(cp_4a) ///
    legend(on c(1) ring(1) pos(6)) xlab(0 "No" 1 "Somewhat" 2 "Yes")

  betterbarci g13 g14 g15 if public == 1, over(cp_4a) ///
    legend(on c(1) ring(1) pos(6))

// End of dofile
