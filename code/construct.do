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

  // Recode case
  replace case = 2 if case == 4


  // Cleanup
  order * , seq
  order qutub_id case public group, first

  // Documentation for final data -- currently set to reset since will make lots of changes
  hashdata using "${directory}/constructed/sp-data.dta" , replace reset
    use "${directory}/constructed/sp-data.dta" , clear
  iecodebook export using "${directory}/data/sp-metadata.xlsx" , replace

// End of dofile
