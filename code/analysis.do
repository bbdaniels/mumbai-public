// Code for data analysis


  // Top level breakdown
  betterbarci correct if public == 1, over(cp_4a) by(case) ///
    legend(on c(1) ring(0) pos(1)) v ylab(${pct})

  // Case by case
  betterbarci re_1 re_3 re_4 med_k_any_9 ///
    med_l_any_1 med_l_any_2 med_l_any_3  ///
  if public == 1 & case == 1 ///
  , over(cp_4a) yscale(noline) ///
    xlab(${pct}) legend(on c(1) region(lc(none) fc(none))) title("Case 1")

    graph save "${directory}/outputs/c1.gph" , replace

  betterbarci re_1 re_3 re_4 med_k_any_9 ///
    med_l_any_1 med_l_any_2 med_l_any_3  ///
  if public == 1 & case == 4 ///
  , over(cp_4a)  yscale(noline) ///
    xlab(${pct}) legend(on c(1) region(lc(none) fc(none))) title("Case 4")

    graph save "${directory}/outputs/c4.gph" , replace

  graph combine ///
    "${directory}/outputs/c1.gph" ///
    "${directory}/outputs/c4.gph"

    graph export "${directory}/outputs/basics.eps" , replace



  // Groupwise comparison
  betterbarci correct, over(group) by(case) ///
    legend(on c(1) ring(0) pos(1)) v ylab(${pct})



// End of dofile
