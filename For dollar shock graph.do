


ssc install labutil

clear  
set more off
if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA"

if ("`c(username)'"=="guillaumedaudin") global dir_git "~/Répertoires GIT/OFCE_CommerceVA"


use "$dir/Results/Devaluations/mean_chg_WIOD_HC_2014_Sdollar.dta"

keep c shockUSA1
replace shockUSA1=-(1-shockUSA1)/2 if c=="USA"

sort shockUSA1
gen elast_order = _n
labmask elast_order,values(c)

graph dot (asis) shockUSA1,  over(elast_order, ///
	label(labsize(tiny))) marker(1, ms(O) mfcolor(gs1) mlcolor(black) msize(tiny)) ///
	legend(off) title("Elasticites of HCE" "to a USD appreciation") ///
	scheme(s1mono) xsize(6)  ysize(7)
	
	
	
*	note("WIOD, 2014", size(small))

graph export "$dir_git/Rédaction/WIOD_HC_elasticities_dollar_appreciation.png", replace


*	note("In national currency Each country is assumed to have its own currency (maybe hypothetical)" "except for countries suffixed by *_EUR: the shock is then on the Euro.", size(vsmall)) ///
