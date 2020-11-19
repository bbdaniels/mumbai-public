// Master file for Mumbai Public Sector analysis

// Set global path locations
  global box "/Users/bbdaniels/Box/Qutub/MUMBAI/constructed"
  global git "/Users/bbdaniels/GitHub/mumbai-public"

  sysdir set PLUS "${git}/ado/"
  sysdir set PERSONAL "${git}/"

  net from "http://www.stata.com/users/vwiggins"
    net install grc1leg , replace

  net from "https://github.com/bbdaniels/stata/raw/master/"
    net install sumstats , replace
    net install betterbar , replace
    net install forest , replace

  set scheme uncluttered , perm
  graph set eps fontface "Helvetica"

// Globals

  // Options for -twoway- graphs
  global tw_opts ///
  	title(, justification(left) color(black) span pos(11)) ///
  	graphregion(color(white) lc(white) lw(med)) bgcolor(white) ///
  	ylab(,angle(0) nogrid) xtit(,placement(left) justification(left)) ///
  	yscale(noline) xscale(noline) legend(region(lc(none) fc(none)))

  // Options for -graph- graphs
  global graph_opts ///
  	title(, justification(left) color(black) span pos(11)) ///
  	graphregion(color(white) lc(white) lw(med)) bgcolor(white) ///
  	ylab(,angle(0) nogrid) ytit(,placement(left) justification(left))  ///
  	yscale(noline) legend(region(lc(none) fc(none)))

  // Options for histograms
  global hist_opts ///
  	ylab(, angle(0) axis(2)) yscale(off alt axis(2)) ///
  	ytit(, axis(2)) ytit(, axis(1))  yscale(alt)

  // Useful stuff

  global pct `" 0 "0%" .25 "25%" .5 "50%" .75 "75%" 1 "100%" "'
  global numbering `""(1)" "(2)" "(3)" "(4)" "(5)" "(6)" "(7)" "(8)" "(9)" "(10)""'
  global bar lc(white) lw(thin) la(center) fi(100) // ← Remove la(center) for Stata < 15

-
// Part 1: Load datafiles into Git location

  // Hashdata command to import data from remote repository
  qui run "${git}/ado/hashdata/hashdata.ado"

  hashdata "${box}/sp-wave-2.dta" ///
     using "${git}/data/sp-private.dta" , replace

  hashdata "${box}/sp-mcgm.dta" ///
     using "${git}/data/sp-public.dta" , replace

  hashdata "${box}/mcgm.dta" ///
    using "${git}/data/mcgm.dta" , replace

  hashdata "${box}/mcgm-ts.dta" ///
    using "${git}/data/mcgm-ts.dta" , replace

// Part 2: Build constructed data from raw data

  do "${git}/do/construct.do"

// Part 3: Analysis

  do "${git}/do/analysis.do"

// Have a lovely day!