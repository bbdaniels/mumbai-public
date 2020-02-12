// Data construction for public sector analysis

  // Set up private sector data with same cases
  use "${directory}/data/sp-private.dta" if case == 1 | case == 4, clear
    drop sp2* sp3* sp7* // Drop data from other cases
    tostring form, replace

  // Load publis sector data
  qui append using "${directory}/data/sp-public.dta" , force gen(public)
    lab var public "Public Provider"
    label def public 0 "Private" 1 "Public"
    lab val public public

  // Create comparison groups
  egen group = group(provider_ppia_wave2 public)
    lab var group "Analysis Group"
    lab def group 1 "Non-PPIA" 2 "Public" 3 "PPIA"
    lab val group group

  label def cp_4a 4 "Private" 5 "Private PPIA" , modify
    replace cp_4a = 4 if ppia_facility_2 == 0
    replace cp_4a = 5 if ppia_facility_2 == 1

  recode cp_4a (1=1 "Public Dispensary")(2/3 = 2 "Public Hospital")(4/5 = 3 "Private Hospital") ///
    , gen(type)

    lab var type "Facility Type"

    drop cp_4a

  // Recoding quality
  foreach var in g1 g2 g3 g4 g5  {
    replace `var' = 1 if `var' > 1 & !missing(`var')
  }
  foreach var in g6 g7 g8 g9 g10  {
    recode `var' (1/2=0)(3/max=1)
    lab val `var' yesno
  }

  // Re-generating mixed measures
  replace case = 2 if case == 4

  drop checklist_n
    egen checklist_n = rsum(sp1_h_? sp1_h_?? sp4_h_? sp4_h_??)
    lab var checklist_n "Number of Questions"

  drop correct
    gen correct = ///
    ( ((dr_4  == 1 | re_1 == 1 | re_3 == 1 | re_4 == 1 | re_5 == 1) 		& case == 1) ///
    | ((dr_4  == 1 |                         re_4 == 1 | re_5 == 1) 		& case == 2) ///
    )
			label var correct "Correct Case Management"
			label val correct yesno

  // Recode SP ID
  drop sp_id
  egen sp_id = group(sp_name)

  // Variable labelling
  lab var dr_4 "Referred Away"
  lab var re_4 "Xpert MTB/RIF"
  lab var p "Amount Paid (INR)"

  lab var g1 "Provider Used Cell Phone"
  lab var g2 "Other People Were In Room"
  lab var g3 "Provider Had A TV On"
  lab var g4 "SP Liked The Provider"
  lab var g5 "SP Would Go To This Provider"
  lab var g6 "Provider Created A Private Environment"
  lab var g7 "Provider Seemed Knowledgeable About Illness"
  lab var g8 "Provider Addressed Worries Seriously"
  lab var g9 "Provider Explained SP Condition"
  lab var g10 "Provider Explained SP Treatment Plan"

  lab var g11 "SP Subjective Rating (1-10)"

  // Cleanup
  order * , seq
  order qutub_id case public group, first

  // Documentation for final data -- currently set to reset since will make lots of changes
  iecodebook export using "${directory}/constructed/sp-data.dta" ///
    , replace text copy trim("${directory}/do/analysis.do")
    use "${directory}/constructed/sp-data.dta" , clear

// End of dofile
