// Code for data analysis

// Summary statistics --------------------------------------------------------------------------
use "${directory}/constructed/sp-data.dta" , clear

  // Process measures
  local process = "p checklist_n time_waiting time ce_2 dr_1 g11"
  // Quality measures
  local quality = "correct ce_2 dr_1 dr_4 re_1 re_3 re_4 med_l_any_1 med_l_any_2 med_l_any_3 med_k_any_9"
  // Satisfaction
  local satisfaction = "g1 g2 g3 g4 g5 g6 g7 g8 g9 g10"
  // Shortcut
  local pq = "`process' `quality' `satisfaction'"

sumstats ///
  (`pq' if type == 1) ///
  (`pq' if type == 2) ///
  (`pq' if type == 3) ///
  using "${directory}/outputs/sp-summary.xlsx" ///
  , stats(mean) replace

// Quality differences -------------------------------------------------------------------------
use "${directory}/constructed/sp-data.dta" , clear

forv case = 1/2 {
betterbar ///
  correct ce_2 dr_1 dr_4 re_1 re_3 re_4 med_l_any_1 med_l_any_2 med_l_any_3 med_k_any_9 ///
  if case == `case' , over(type) title("Case `case'" , justification(left) color(black) span pos(11)) ///
  legend(on c(1) ring(1) pos(6)) xlab(${pct}) pct barl ylab(,labsize(small))

  graph save "${directory}/temp/quality-`case'.gph" , replace
}

  grc1leg ///
    "${directory}/temp/quality-1.gph" ///
    "${directory}/temp/quality-2.gph" ///
    , c(1)

    graph save "${directory}/temp/quality.gph" , replace
    graph combine "${directory}/temp/quality.gph" , ysize(9)

  graph export "${directory}/outputs/quality.eps" , replace

// Price and convenience -----------------------------------------------------------------------
use "${directory}/constructed/sp-data.dta" , clear

gen c = correct*100
  lab var c "Quality (0-100)"

local x = 0
foreach var of varlist time_waiting g11 c time checklist_n p  {
local ++x
betterbarci `var' ///
  , over(type) ylab(,labsize(small)) v ///
    barl format(%9.1f) legend(on r(1) pos(6) ring(1) size(small)) yscale(off)

    graph save "${directory}/temp/convenience-`x'.gph" , replace
}

  grc1leg ///
    "${directory}/temp/convenience-1.gph" ///
    "${directory}/temp/convenience-2.gph" ///
    "${directory}/temp/convenience-3.gph" ///
    "${directory}/temp/convenience-4.gph" ///
    "${directory}/temp/convenience-5.gph" ///
    "${directory}/temp/convenience-6.gph" ///
    , r(2)

    graph export "${directory}/outputs/convenience.eps" , replace

// SP Satisfaction -----------------------------------------------------------------------------
use "${directory}/constructed/sp-data.dta" , clear

betterbar g1 g2 g3 g4 g5 g6 g7 g8 g9 g10  ///
  , over(type) pct barl ci xoverhang xlab(${pct}) ///
    legend(on c(1) size(small)) ysize(7) ylab(,labsize(small))

    graph export "${directory}/outputs/satisfaction.eps" , replace


// Big comparison ------------------------------------------------------------------------------
use "${directory}/constructed/sp-data.dta" , clear

gen private = 1-public
  lab var private "Private Sector"

forest reg ///
  (p checklist_n time_waiting time ce_2 dr_1 g11) ///
  (correct dr_4 re_1 re_3 re_4) ///
  (med_l_any_1 med_l_any_2 med_l_any_3 med_k_any_9) ///
  (g1 g2 g3 g4 g5 g6 g7 g8 g9 g10) ///
  if type > 1 ///
, t(private) d b bh ///
  graphopts(ysize(8) ylab(,labsize(vsmall)) ///
    xlab(-2 "2 SD" -1 "1 SD" 0 " " 1 "1 SD" 2 "2 SD") xscale(alt) xoverhang ///
    xtit(" {&larr} Favors Public   Favors Private {&rarr}",size(small)))

  graph export "${directory}/outputs/comparison.eps" , replace

// Cost of things ------------------------------------------------------------------------------

use "${directory}/constructed/sp-data.dta" if public == 0, clear

local x = 0
foreach var of varlist time_waiting g11 correct time checklist_n  {
  local label : var label `var'

  local ++x
  tw (lowess `var' p , lc(black) lw(thick) ) ///
    , ytit(" ") title("`label'", justification(left) color(black) span pos(11))
  graph save "${directory}/temp/cost-`x'.gph" , replace
}

  graph combine ///
    "${directory}/temp/cost-1.gph" ///
    "${directory}/temp/cost-2.gph" ///
    "${directory}/temp/cost-3.gph" ///
    "${directory}/temp/cost-4.gph" ///
    "${directory}/temp/cost-5.gph" ///
    , c(1) ysize(8) imargin(10 10 0 0)

    graph export "${directory}/outputs/costs.eps" , replace

// Cost of time --------------------------------------------------------------------------------

use "${directory}/constructed/sp-data.dta" if public == 1, clear

local x = 0
foreach var of varlist time_waiting g11 correct checklist_n  {
  local label : var label `var'

  local ++x
  tw (lowess `var' time , lc(black) lw(thick) ) ///
    , ytit(" ") title("`label'", justification(left) color(black) span pos(11))
  graph save "${directory}/temp/time-`x'.gph" , replace
}

  graph combine ///
    "${directory}/temp/time-1.gph" ///
    "${directory}/temp/time-2.gph" ///
    "${directory}/temp/time-3.gph" ///
    "${directory}/temp/time-4.gph" ///
    , c(1) ysize(8) imargin(10 10 0 0)

    graph save "${directory}/outputs/time-public.gph" , replace

use "${directory}/constructed/sp-data.dta" if public == 0, clear

local x = 0
foreach var of varlist time_waiting g11 correct checklist_n  {
  local label : var label `var'

  local ++x
  tw (lowess `var' time , lc(black) lw(thick) ) ///
    , ytit(" ") title("`label'", justification(left) color(black) span pos(11))
  graph save "${directory}/temp/time-`x'.gph" , replace
}

  graph combine ///
    "${directory}/temp/time-1.gph" ///
    "${directory}/temp/time-2.gph" ///
    "${directory}/temp/time-3.gph" ///
    "${directory}/temp/time-4.gph" ///
    , c(1) ysize(8) imargin(10 10 0 0)

    graph save "${directory}/outputs/time-private.gph" , replace

  graph combine ///
    "${directory}/outputs/time-public.gph" ///
    "${directory}/outputs/time-private.gph" ///
  , r(1) ycom


// End of dofile
