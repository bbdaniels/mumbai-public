// Master file for Mumbai Public Sector analysis

// Set global directory locations
global rawdata "/Users/bbdaniels/Dropbox/Research/Qutub/Restricted/MUMBAI ANALYSIS/constructed"
global directory "/Users/bbdaniels/GitHub/mumbai/mumbai-public"

// Part 1: Load datafiles into Git location
hashdata "${rawdata}/SP1_4_Wave2.dta" ///
   using "${directory}/data/sp-private.dta" , replace

hashdata "${rawdata}/SP1_4_Public.dta" ///
   using "${directory}/data/sp-public.dta" , replace

// Part 2: Build constructed data from raw data


// Part 3: Analysis


// Have a lovely day!
