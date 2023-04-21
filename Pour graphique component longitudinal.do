

clear  
set more off
if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA"
if ("`c(hostname)'" == "widv270a") global dir  "D:\home\T822289\CommerceVA" 
if ("`c(hostname)'" == "FP1376CD") global dir  "T:\CommerceVA" 


if ("`c(username)'"=="guillaumedaudin") global dirgit "~/Documents/Recherche/2017 BDF_Commerce VA/commerce_VA_inflation"
if ("`c(hostname)'" == "widv270a") global dirgit  "D:\home\T822289\CommerceVA\GIT\commerce_VA_inflation" 
if ("`c(hostname)'" == "FP1376CD") global dirgit  "T:\CommerceVA\GIT\commerce_va_inflation" 

*capture log close
*log using "$dir/$S_DATE.log", replace


do  "$dirgit/Definition_pays_secteur.do" `source'

global eurozone "AUT BEL CYP DEU ESP EST FIN FRA GRC IRL ITA LTU LUX LVA MLT NLD PRT SVK SVN"



***Pour graphique longitudinal des parts de chaque mécanisme
global common_sample "   AUS AUT BEL BGR BRA CAN CHE" 
global common_sample "$common_sample CHN CYP CZE DEU DNK ESP EST FIN"
global common_sample "$common_sample FRA GBR GRC     HRV HUN IDN IND IRL        ITA JPN     KOR"
global common_sample "$common_sample LTU LUX LVA MEX              MLT     NLD NOR        POL PRT"
global common_sample "$common_sample ROU RUS       SVK SVN SWE       TUR TWN USA        "

foreach source in  WIOD TIVA TIVA_REV4 {
	
	use "$dir/Bases/Y_`source'.dta", clear
	rename Y Y_`source'
	replace pays="CHN" if pays=="CN1" | pays=="CN2" | pays=="CN3" | pays=="CN4"
	replace pays="MEX" if pays=="MX1" | pays=="MX2" | pays=="MX3"
	keep if strpos("$common_sample",pays)!=0


	collapse (sum) Y_`source', by(pays year)
	*rename pays c
	
	if "`source'"=="WIOD" local start_year 2000	
	if "`source'"=="TIVA" local start_year 1995
	if "`source'"=="TIVA_REV4" local start_year 2005

	if "`source'"=="WIOD" local end_year 2014
	if "`source'"=="TIVA" local end_year 2011
	if "`source'"=="TIVA_REV4" local end_year 2015
	
	
	foreach year of numlist `start_year' (1) `end_year'  {
		preserve
		use "$dir/Results/Étude rapport D+I et Bouclage Mondial/Elast_par_pays_`year'_`source'_HC.dta", clear
		capture gen year=`year'
		save "$dir/Results/Étude rapport D+I et Bouclage Mondial/Elast_par_pays_`year'_`source'_HC.dta", replace
		restore
		
		merge 1:1 year pays  using "$dir/Results/Étude rapport D+I et Bouclage Mondial/Elast_par_pays_`year'_`source'_HC.dta", update
		drop _merge
	}
	
	replace pond_`source'_HC=-pond_`source'_HC
	gen E4HC = pond_`source'_HC - E1HC - E2HC - E3HC
	
	gen share_IO_mech = (E4HC+E3HC+E2HC)/pond_`source'_HC
	gen share_IOT     = (E4HC+E3HC)/pond_`source'_HC
	format share* %9.2f
		
	egen Y_tot_per_year=total(Y_`source'), by(year)
	gen weight=Y_`source'/Y_tot_per_year
	
	foreach var of varlist share_IO_mech share_IOT pond_`source'_HC {
		gen `var'_pond=`var'*weight
		egen `source'_`var'_pond	=	total(`var'_pond), by(year)
		egen `source'_`var'		    =	mean(`var'), by(year)
	}

	
	drop Y_tot_per_year weight share_IOT share_IO_mech E1HC E2HC E3HC E4HC 
	
	
	save temp_`source'.dta, replace	
}


use temp_WIOD.dta, clear
merge 1:1 year pays using temp_TIVA.dta
drop _merge
merge 1:1 year pays using temp_TIVA_REV4.dta



keep if pays=="FRA"
drop pays
sort year

bys year: keep if _n==1


twoway 	(line WIOD_share_IO_mech year, lcolor(blue) lpattern(dash)) ///
		(line WIOD_share_IO_mech_pond year, lcolor(blue)) ///
		(line TIVA_share_IO_mech year, lcolor(red) lpattern(dash)) ///
		(line TIVA_share_IO_mech_pond year, lcolor(red)) ///
		(line TIVA_REV4_share_IO_mech year, lcolor(green) lpattern(dash)) ///
		(line TIVA_REV4_share_IO_mech_pond year, lcolor(green)), ///
		legend(label(1 "WIOD") label(2 "WIOD, output weighted") ///
		label(3 "TIVA rev3") label(4 "TIVA rev3, output weighted")  /// 
		label(5 "TIVA rev4") label(6 "TIVA rev4, output weighted"))  /// 
		ytitle("Share of total effect going through" "Input-Output mechanisms" "((E2HC+E3HC+E4HC)/Total", ) ///
		note("The average share has been computed from each of countries" ///
		"in a common 43 countries sample (assuming no Eurozone)" ///
		"and aggregated using either an arithmetic mean or an output weighted mean") ///
		scheme(s1mono)
		
		
graph export "$dir/Results/Components en longitudinal/Share_going_through_IO.png", replace
		
twoway 	(line WIOD_share_IOT year, lcolor(blue) lpattern(dash)) ///
		(line WIOD_share_IOT_pond year, lcolor(blue)) ///
		(line TIVA_share_IOT year, lcolor(red) lpattern(dash)) ///
		(line TIVA_share_IOT_pond year, lcolor(red)) ///
		(line TIVA_REV4_share_IOT year, lcolor(green) lpattern(dash)) ///
		(line TIVA_REV4_share_IOT_pond year, lcolor(green)), ///
		legend(label(1 "WIOD") label(2 "WIOD, output weighted") ///
		label(3 "TIVA rev3") label(4 "TIVA rev3, output weighted")  /// 
		label(5 "TIVA rev4") label(6 "TIVA rev4, output weighted"))  /// 
		ytitle("Share of total effect requiring WIOT" "for computation" "((E3HC+E4HC)/Total", ) ///
		note("The average share has been computed from each of countries" ///
		"in a common 43 countries sample (assuming no Eurozone)" ///
		"and aggregated using either an arithmetic mean or an output weighted mean") ///
		scheme(s1mono)

		
graph export "$dir/Results/Components en longitudinal/Share_going_through_IOT.png", replace
		

twoway 	(line WIOD_share_IO_mech_pond year, lcolor(blue) ) ///
		(line WIOD_share_IOT_pond year, lcolor(blue) lpattern(dash) yaxis(2)) ///
		(line TIVA_share_IO_mech_pond year, lcolor(red) ) ///
		(line TIVA_share_IOT_pond year, lcolor(red) lpattern(dash) yaxis(2)) ///
		(line TIVA_REV4_share_IO_mech_pond year, lcolor(green) ) ///
		(line TIVA_REV4_share_IOT_pond year, lcolor(green) lpattern(dash) yaxis(2)), ///
		legend(label(1 "WIOD, share of total effect going through Input-Output mechanisms") ///
		label(4 "WIOD, share of total effect requiring WIOT (right axis)") ///
		label(2 "TIVA rev3, share of total effect going through Input-Output mechanisms") ///
		label(5 "TIVA rev3, share of total effect requiring WIOT (right axis)")  /// 
		label(3 "TIVA rev4, share of total effect going through Input-Output mechanisms") ///
		label(6 "TIVA rev4, share of total effect requiring WIOT (right axis)") row(6) size(small)) ///
		ytitle("Output-weighted mean") ///
		note("The average share has been computed from each of countries" ///
		"in a common 43 countries sample (assuming no Eurozone)" ///
		"and aggregated using an output weighted mean") ///
		scheme(s1mono)

		
graph export "$dir/Results/Components en longitudinal/Share_GDP-weighted.png", replace
graph export "$dir/commerce_VA_inflation/Rédaction/Share_GDP-weighted.png", replace
		





