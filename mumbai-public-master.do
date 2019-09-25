// Master file for Mumbai Public Sector analysis

// Set global directory locations
global rawdata "/Users/bbdaniels/Dropbox/Research/Qutub/Restricted/MUMBAI ANALYSIS/constructed"
global directory "/Users/bbdaniels/GitHub/mumbai/mumbai-public"

// Part 1: Load datafiles into Git location

  // Hashdata command (in development)
  qui run "${directory}/hashdata/hashdata.ado"

  hashdata "${rawdata}/SP1_4_Wave2.dta" ///
     using "${directory}/data/sp-private.dta" , replace

  hashdata "${rawdata}/SP1_4_MCGM.dta" ///
     using "${directory}/data/sp-public.dta" , replace

// Part 2: Build constructed data from raw data

  use "${directory}/data/sp-private.dta" if case == 1 | case == 4, clear
    drop sp2* sp3* sp7*
    tostring form, replace
  qui append using "${directory}/data/sp-public.dta" , force gen(public)
    lab var public "Public Provider"
    label def public 0 "Private" 1 "Public"
    lab val public public

  order * , seq
  order qutub_id case public, first

  iecodebook export using "${directory}/data/sp-metadata.xlsx" , replace

  save "${directory}/constructed/sp-data.dta" , replace

  // Tracker for final data changes -- currently set to reset since will make lots of changes
  hashdata "${directory}/constructed/sp-data.dta" ///
     using "${directory}/constructed/sp-data.dta" , replace reset

// Part 3: Analysis


// Have a lovely day!
