


*gr0034.pkg
*from:  http://www.stata-journal.com/software/sj8-2/




clear  
set more off
if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA"
else global dir "\\intra\partages\au_dcpm\DiagConj\Commun\CommerceVA"

if ("`c(username)'"=="guillaumedaudin") global dirgit "~/Répertoires Git/2023 JIMF Camatte Daudin Faubert Rifflart"

*capture log close
*log using "$dir/$S_DATE.log", replace


do  "$dirgit/Definition_pays_secteur.do" `source'

	

	
********Figure 1 (Comparing consumer price elasticity to an exchange rate appreciation for WIOD and TIVA, 2011)	
	
local year 2011
	
use "$dir/Results/Devaluations/auto_chocs_HC_WIOD_`year'.dta", clear
merge 1:1 pays using  "$dir/Results/Devaluations/auto_chocs_HC_TIVA_`year'.dta"
drop if pays =="ROW"

insobs 1
local N_last_obs=_N
replace pond_TIVA_HC=0 in `N_last_obs'

replace pond_WIOD_HC= -pond_WIOD_HC
replace pond_TIVA_HC= -pond_TIVA_HC

regress pond_WIOD_HC pond_TIVA_HC
predict predict
gen error=abs(predict-pond_WIOD_HC)/pond_WIOD_HC
gen mylabel= pays if strpos("HUN IRL_EUR CZE TWN SVK_EUR",pays)!=0 /*error >.25 | pond_WIOD_HC>=0.22 | pays=="FRA"*/

gen sample=1
Definition_pays_secteur TIVA
replace sample=0 if strpos("$eurozone",pays)!=0

graph twoway (scatter pond_WIOD_HC pond_TIVA_HC if sample==1, mlabel(mylabel)) ///
			(lfit pond_WIOD_HC pond_TIVA_HC if sample==1, clpattern(dash)) ///
			(lfit pond_TIVA_HC pond_TIVA_HC if pond_TIVA_HC <=0.3), ///
			yscale(range(0 0.3)) xscale(range(0 0.3)) ylabel(0 (0.05) 0.3) xlabel(0 (0.05) 0.3) ///
			ytitle("WIOD elasticites `year' (absolute value)") xtitle("TIVA_REV3 elasticites `year' (absolute value)") ///
			legend(order (2 3)  label(2 "Linear fit") label(3 "45° line") ) scheme(s1mono)
			
graph export "$dirgit/Rédaction/Comparaison_WIOD_TIVA_`year'.png", replace

drop sample
	
********Figure 1bis (Comparing consumer price elasticity to an exchange rate appreciation for WIOD and TIVA_REV4, 2014)	
	
local year 2014
	
use "$dir/Results/Devaluations/auto_chocs_HC_WIOD_`year'.dta", clear
merge 1:1 pays using  "$dir/Results/Devaluations/auto_chocs_HC_TIVA_REV4_`year'.dta"
drop if pays =="ROW"

insobs 1
local N_last_obs=_N
replace pond_TIVA_REV4_HC=0 in `N_last_obs'

replace pond_WIOD_HC= -pond_WIOD_HC
replace pond_TIVA_REV4_HC= -pond_TIVA_REV4_HC



regress pond_WIOD_HC pond_TIVA_REV4_HC
predict predict
gen error=abs(predict-pond_WIOD_HC)/pond_WIOD_HC
gen mylabel= pays if strpos("HUN IRL_EUR BGR TWN POL",pays)!=0/*if /*error >.25 |*/ pond_WIOD_HC>=0.22 | pays=="FRA*/

gen sample=1
Definition_pays_secteur TIVA
replace sample=0 if strpos("$eurozone",pays)!=0

graph twoway (scatter pond_WIOD_HC pond_TIVA_REV4_HC if sample==1, mlabel(mylabel)) ///
            (lfit pond_WIOD_HC pond_TIVA_REV4_HC if sample==1 , clpattern(dash)) ///
			(lfit pond_WIOD_HC pond_WIOD_HC if pond_WIOD_HC <=0.3), ///
			yscale(range(0 0.3)) xscale(range(0 0.3)) ylabel(0 (0.05) 0.3) xlabel(0 (0.05) 0.3) ///
			ytitle("WIOD elasticites `year' (absolute value)") xtitle("TIVA_REV4 elasticites `year' (absolute value)") ///
			legend(order (2 3)  label(2 "Linear fit") label(3 "45° line") ) scheme(s1mono)
			
graph export "$dirgit/Rédaction/Comparaison_WIOD_TIVA_REV4_`year'.png", replace

drop sample

replace pond_WIOD_HC= -pond_WIOD_HC/10
replace pond_TIVA_REV4_HC= -pond_TIVA_REV4_HC/10
keep if strpos(pays,"_EUR")!=0
replace pays=subinstr(pays,"_EUR"e,"",.)
gen sample=0
replace sample=1 if pays=="FRA" | pays=="DEU" | pays=="NLD" | pays=="ESP" | pays=="ITA"
replace pays="" if pays!="FRA" & pays!="DEU" & pays!="NLD"  & pays!="IRL"

graph twoway /// 
		(scatter pond_WIOD_HC pond_TIVA_REV4_HC if sample==0, mlabel(pays) mlabsize(medium) mlabcolor(sky) mcolor(sky)) ///
		(scatter pond_WIOD_HC pond_TIVA_REV4_HC if sample==1, mlabel(pays) mlabsize(medium) mcolor(black) mlabcolor(black) ) ///
		(lfit pond_WIOD_HC pond_TIVA_REV4_HC, clpattern(dash)) ///
		(lfit pond_WIOD_HC pond_WIOD_HC), ///
		yscale(range(-0.02 -0.005)) xscale(range(-0.02 -0.005)) ylabel(-0.02 (0.005) -0.00) yscale(range(-0.02 (0.005) -0.00)) ///
		ytitle("Impact PIWIM (WIOD), en %") xtitle("Impact PIWIM (TIVA_REV4), en %") ///
		legend(order (3 4)  label(3 "Régression linéaire") label(4 "ligne à 45°") ) scheme(s1mono)
			
graph export "$dirgit/Rédaction_note/Comparaison_WIOD_TIVA_REV4_`year'.png", replace



********Figure 1ter (Comparing consumer price elasticity to an exchange rate appreciation for TIVA and TIVA_REV4, 2011)	
	
local year 2011
	
use "$dir/Results/Devaluations/auto_chocs_HC_TIVA_REV4_`year'.dta", clear
merge 1:1 pays using  "$dir/Results/Devaluations/auto_chocs_HC_TIVA_`year'.dta"
drop if pays =="ROW"

insobs 1
local N_last_obs=_N
replace pond_TIVA_HC=0 in `N_last_obs'

replace pond_TIVA_REV4_HC= -pond_TIVA_REV4_HC
replace pond_TIVA_HC= -pond_TIVA_HC

regress pond_TIVA_REV4_HC pond_TIVA_HC
predict predict
gen error=abs(predict-pond_TIVA_REV4_HC)/pond_TIVA_REV4_HC
gen mylabel= pays if /*error >.25 |pond_TIVA_HC>=0.2 | pays=="FRA_EUR"*/ strpos("CZE BGR MAR ISL BRN HUN",pays)!=0

gen sample=1
Definition_pays_secteur TIVA
replace sample=0 if strpos("$eurozone",pays)!=0

graph twoway (scatter pond_TIVA_REV4_HC pond_TIVA_HC if sample==1, mlabel(mylabel)) ///
			 (lfit pond_TIVA_REV4_HC pond_TIVA_HC if sample==1, clpattern(dash)) ///
			 (lfit pond_TIVA_HC pond_TIVA_HC if pond_TIVA_HC<=0.3), ///
			 yscale(range(0 0.3)) xscale(range(0 0.3)) ylabel(0 (0.05) 0.3) xlabel(0 (0.05) 0.3) ///
			 ytitle("TIVA_REV4 elasticites `year' (absolute value)") xtitle("TIVA_REV3 elasticites `year' (absolute value)") ///
			legend(order (2 3)  label(2 "Linear fit") label(3 "45° line") ) scheme(s1mono)
			
graph export "$dirgit/Rédaction/Comparaison_TIVA_REV4_TIVA_`year'.png", replace

drop sample




********Figure 1quart (Comparing consumer price elasticity to an exchange rate appreciation for WIOD and TIVA_REV4, 2011)	
	
local year 2011
	
use "$dir/Results/Devaluations/auto_chocs_HC_WIOD_`year'.dta", clear
merge 1:1 pays using  "$dir/Results/Devaluations/auto_chocs_HC_TIVA_REV4_`year'.dta"
drop if pays =="ROW"

insobs 1
local N_last_obs=_N
replace pond_TIVA_REV4_HC=0 in `N_last_obs'

replace pond_WIOD_HC= -pond_WIOD_HC
replace pond_TIVA_REV4_HC= -pond_TIVA_REV4_HC



regress pond_WIOD_HC pond_TIVA_REV4_HC
predict predict
gen error=abs(predict-pond_WIOD_HC)/pond_WIOD_HC
gen mylabel= pays  if strpos("HUN IRL_EUR CZE TWN SVK_EUR BGR ",pays)!=0 /*if /*error >.25 |*/ pond_WIOD_HC>=0.22 | pays=="FRA"*/

gen sample=1
Definition_pays_secteur TIVA_REV4
replace sample=0 if strpos("$eurozone",pays)!=0

graph twoway (scatter pond_WIOD_HC pond_TIVA_REV4_HC  if sample==1, mlabel(mylabel)) ///
            (lfit pond_WIOD_HC pond_TIVA_REV4_HC if sample==1 , clpattern(dash)) ///
			(lfit pond_TIVA_REV4_HC pond_TIVA_REV4_HC if pond_TIVA_REV4_HC <=0.3), ///
			yscale(range(0 0.3)) xscale(range(0 0.3)) ylabel(0 (0.05) 0.3) xlabel(0 (0.05) 0.3) ///
			ytitle("WIOD elasticites `year' (absolute value)") xtitle("TIVA_REV4 elasticites `year' (absolute value)") ///
			legend(order (2 3)  label(2 "Linear fit") label(3 "45° line") ) scheme(s1mono)
			
graph export "$dirgit/Rédaction/Comparaison_WIOD_TIVA_REV4_`year'.png", replace

drop sample

*************Figure 2 (presenting results)

use "$dir/Bases/Y_WIOD.dta", clear
collapse (sum) Y, by(pays year)

keep if year==2014


merge 1:1 pays using "$dir/Results/Devaluations/auto_chocs_HC_WIOD_2014.dta"

gen blouf = 0
gen mylabel= pays if strpos("FRA DEU DEU_EUR ITA ITA_EUR GBR CHN USA CAN JPN ",pays)!=0

replace pond_WIOD_HC = -pond_WIOD_HC


******VIEUX GRAPHIQUE
/*
twoway histogram pond_WIOD_HC, width(0.05) frequency xscale(range(0.04 0.36)) || ///
	scatter blouf pond_WIOD_HC if mylabel!="", /// 
	mlabel(mylabel) mlabposition(12)  mlabangle(vertical)  mlabgap(huge) mlabsize(vsmall) msymbol(pipe) ///
	legend(off) ytitle("Number of countries in each bin") xtitle("WIOD elasticites 2014 (absolute value)") ///
	note("* designate the effect of a shock on the (maybe hypothetical) local currency" ///
	"*_EUR designate the effet of an shock on the Euro" ///
	"FRA_EUR is in the same position as JPN") ///
	 scheme(s1mono)
graph export "$dirgit/Rédaction/WIOD_HC_elasticities.png", replace
*/

****Autre version de WIOD_HC_elasticities.png ?

sort pond_WIOD_HC
gen elast_order = _n
labmask elast_order,values(pays)

/* Ça, c’est le graphique avec les monnaies hypothétiques
graph dot (asis) pond_WIOD_HC,  over(elast_order, ///
	label(labsize(tiny))) marker(1, ms(O) mfcolor(gs1) mlcolor(black) msize(tiny)) ///
	legend(off) title("WIOD elasticites 2014 (absolute value)") ///
	note("Each country is assumed to have its own currency (maybe hypothetical)" "except for countries suffixed by _EUR: the shock is then on the Euro.", size(vsmall)) ///
	scheme(s1mono) xsize(6)  ysize(7)

graph export "$dirgit/Rédaction/WIOD_HC_elasticities.png", replace
*/

gen sample=1
Definition_pays_secteur WIOD
replace sample=0 if strpos("$eurozone",pays)!=0
graph dot (asis) pond_WIOD_HC if sample==1,  over(elast_order, ///
	label(labsize(tiny))) marker(1, ms(O) mfcolor(gs1) mlcolor(black) msize(tiny)) ///
	legend(off) title("WIOD elasticites 2014 (absolute value)") ///
	note("Each country is assumed to have its own currency" "except for countries suffixed by _EUR: the shock is then on the Euro.", size(vsmall)) ///
	scheme(s1mono) xsize(6)  ysize(7)

graph export "$dirgit/Rédaction/WIOD_HC_elasticities.png", replace
export delimited using "$dirgit/2023 March For correlation computation WIOD_HC_elasticities.csv", replace

drop sample





********
replace Y=round(Y,.)

twoway histogram pond_WIOD_HC [fweight=Y],  width(0.05) fraction xscale(range(0.04 0.36)) || ///
	scatter blouf pond_WIOD_HC if mylabel!="", /// 
	mlabel(mylabel) mlabposition(12)  mlabangle(vertical)  mlabgap(huge) mlabsize(vsmall) msymbol(pipe) ///
	legend(off) ytitle("Share of world output in each bin") xtitle("WIOD elasticites 2014 (absolute value)") ///
	note("* designate the effect of a shock on the (maybe hypothetical) local currency" ///
	"*_EUR designate the effet of an shock on the Euro" ///
	"FRA_EUR is in the same position as JPN") ///
	 scheme(s1mono)
	



*************Figure 3 (relation with share of imported consumer goods)


use "$dir/Bases/Y_WIOD.dta", clear
collapse (sum) Y, by(pays year)
*rename pays c
keep if year==2014


merge 1:1 pays using "$dir/Results/Étude rapport D+I et Bouclage Mondial/Elast_par_pays_2014_WIOD_HC.dta"
rename pays c

gen mylabel1= c if strpos("FRA ITA ITA_EUR CHN CAN JPN",c)!=0
gen mylabel2= c if c=="FRA_EUR" | c=="USA" | c=="GBR" | c=="DEU_EUR" | c=="DEU"

insobs 1
local N_last_obs=_N
replace pond_WIOD_HC=0 in `N_last_obs'
gen pour_45 = pond_WIOD_HC if pond_WIOD_HC <=0.2

twoway scatter pond_WIOD_HC E1HC  if mylabel1=="" & mylabel2=="" , msize(small) || ///
	   scatter pond_WIOD_HC E1HC  if mylabel1!="", mlabel(mylabel1) mlabangle(vertical) mlabgap(huge) ///
	mlabcolor(green)  mcolor(green) mlabposition(12) mlabsize(small)|| ///
	scatter pond_WIOD_HC E1HC  if mylabel2!="", mlabel(mylabel2) mlabangle(vertical) mlabgap(huge) ///
	mlabposition(6) mlabsize(small) mlabcolor(green)  mcolor(green) || ///
	lfit pond_WIOD_HC E1HC,  ///
	legend(off) xtitle("Share of imported goods and services in household consumption") ///
	ytitle("WIOD elasticites 2014 (absolute value)") ///
	note("* designate the effect of a shock on the (maybe hypothetical) local currency" ///
	"*_EUR designate the effet of an shock on the Euro") ///
	 scheme(s1mono)
	
graph export "$dirgit/Rédaction/WIOD_HC_E1HC.png", replace

/*

twoway scatter pond_WIOD_HC E1HC  if mylabel1=="" & mylabel2=="" [w=Y], msize(small) msymbol(circle_hollow) || ///
	   scatter pond_WIOD_HC E1HC  if mylabel1!="" [w=Y], mlabel(mylabel1) mlabangle(vertical) mlabgap(huge)  ///
	msymbol(circle_hollow) mlabcolor(green)  mcolor(green) mlabposition(12) mlabsize(small)|| ///
	scatter pond_WIOD_HC E1HC  if mylabel2!="" [w=Y], mlabel(mylabel2) mlabangle(vertical) mlabgap(huge) ///
	msymbol(circle_hollow) mlabposition(6) mlabsize(small) mlabcolor(green)  mcolor(green) || ///
	lfit pond_WIOD_HC E1HC,  ///
	legend(off) xtitle("Share of imported goods and services in household consumption") ///
	ytitle("WIOD elasticites 2014 (absolute value)") ///
	note("* designate the effect of a shock on the (maybe hypothetical) local currency" ///
	"*_EUR designate the effet of an shock on the Euro")
	
	
twoway scatter pond_WIOD_HC E1HC   [w=Y], msize(small) msymbol(circle_hollow)
*/

*************Figure 4 (évolutions dans le temps)

	
global common_sample "   AUS AUT_EUR BEL_EUR BGR BRA CAN CHE" 
global common_sample "$common_sample CHN CYP_EUR CZE DEU_EUR DNK ESP_EUR EST_EUR FIN_EUR"
global common_sample "$common_sample FRA_EUR GBR GRC_EUR    HRV HUN IDN IND IRL_EUR        ITA_EUR JPN     KOR"
global common_sample "$common_sample LTU_EUR LUX_EUR LVA_EUR MEX              MLT_EUR     NLD_EUR NOR        POL PRT_EUR"
global common_sample "$common_sample ROU RUS       SVK_EUR SVN_EUR SWE       TUR TWN USA        "



foreach source in TIVA WIOD TIVA_REV4 MRIO {

	if "`source'"=="WIOD" local start_year 2000 /*2000*/
	if "`source'"=="TIVA" local start_year 1995
	if "`source'"=="TIVA_REV4" local start_year 2005

	if "`source'"=="WIOD" local end_year 2014
	if "`source'"=="TIVA" local end_year 2011
	if "`source'"=="TIVA_REV4" local end_year 2015
	
	
	if "`source'"=="MRIO" local year_list 2000 2007(1)2019
	if "`source'"=="WIOD" local year_list 2000(1)2014
	if "`source'"=="TIVA" local year_list 1995(1)2011
	if "`source'"=="TIVA_REV4" local year_list 2005(1)2015

	use "$dir/Bases/Y_`source'.dta", clear
	
	Definition_pays_secteur `source'
	replace pays=pays+"_EUR" if strpos("$eurozone",pays)!=0 
	
	rename Y Y_`source'
	replace pays="CHN" if pays=="CN1" | pays=="CN2" | pays=="CN3" | pays=="CN4"
	replace pays="MEX" if pays=="MX1" | pays=="MX2" | pays=="MX3"
	


	collapse (sum) Y_`source', by(pays year)
	*rename pays c

	foreach year of numlist `year_list'  {
		merge 1:1 year pays  using "$dir/Results/Devaluations/auto_chocs_HC_`source'_`year'.dta", update
		drop _merge
		drop if strpos("$eurozone",pays)!=0
	}
	
	if "`source'"=="MRIO" {
		replace pays=subinstr(pays,"DEN","DNK",.)
		replace pays=subinstr(pays,"GER","DEU",.)
		replace pays=subinstr(pays,"INO","IDN",.)
		replace pays=subinstr(pays,"IRE","IRL",.)
		replace pays=subinstr(pays,"NET","NLD",.)
		replace pays=subinstr(pays,"POR","PRT",.)
		replace pays=subinstr(pays,"PRC","CHN",.)
		replace pays=subinstr(pays,"ROM","ROU",.)
		replace pays=subinstr(pays,"SWI","CHE",.)
		replace pays=subinstr(pays,"SPA","ESP",.)
		replace pays=subinstr(pays,"TAP","TWN",.)
		replace pays=subinstr(pays,"UKG","GBR",.)
		*il en manque... Mais ce sont ceux du sample
	}
	
	keep if strpos("$common_sample",pays)!=0

	replace pond_`source'=-pond_`source'
	egen Y_tot_per_year=total(Y_`source'), by(year)
	gen weight=Y_`source'/Y_tot_per_year
	gen elast_pond=pond_`source'_HC*weight
	

	egen `source'_elast_annual_pond=total(elast_pond), by(year)
	egen `source'_elast_annual=mean(pond_`source'_HC), by(year)
	
	drop Y_tot_per_year weight elast_pond
	

	save temp_`source'.dta, replace
}

use temp_WIOD.dta, clear
merge 1:1 year pays using temp_TIVA.dta
drop _merge
merge 1:1 year pays using temp_TIVA_REV4.dta
drop _merge
merge 1:1 year pays using temp_MRIO.dta



keep if pays=="FRA_EUR"
drop pays
sort year

bys year: keep if _n==1


/*

twoway 	(line WIOD_elast_annual year, lcolor(blue) lpattern(dash)) ///
		(line WIOD_elast_annual_pond year, lcolor(blue)) ///
		(line TIVA_elast_annual year, lcolor(red) lpattern(dash)) ///
		(line TIVA_elast_annual_pond year, lcolor(red)) ///
		(line TIVA_REV4_elast_annual year, lcolor(green) lpattern(dash)) ///
		(line TIVA_REV4_elast_annual_pond year, lcolor(green)), ///
		legend(label(1 "WIOD") label(2 "WIOD, output weighted") ///
		label(3 "TIVA rev3") label(4 "TIVA rev3, output weighted")  /// 
		label(5 "TIVA rev4") label(6 "TIVA rev4, output weighted"))  /// 
		ytitle("elasticity (absolute value)", ) ///
		note("The average HCE deflator elasticity has been computed from each of countries" ///
		"in a common 43 countries sample" ///
		"assuming all 2020 Eurozone countries already in the Eurozone from 1995" ///
		"and aggregated using either an arithmetic mean or an output weighted mean") ///
		scheme(s1mono)

*/

twoway 	(line WIOD_elast_annual year, lcolor(blue) lpattern(dash)) ///
		(line WIOD_elast_annual_pond year, lcolor(blue)) ///
		(line TIVA_elast_annual year, lcolor(red) lpattern(dash)) ///
		(line TIVA_elast_annual_pond year, lcolor(red)) ///
		(line TIVA_REV4_elast_annual year, lcolor(green) lpattern(dash)) ///
		(line TIVA_REV4_elast_annual_pond year, lcolor(green)) ///
		(connected MRIO_elast_annual year, lcolor(black) lstyle(solid) msize(small)) ///
		(connected MRIO_elast_annual_pond year, lcolor(black) lstyle(solid) msize(small)), ///
		legend(label(1 "WIOD") label(2 "WIOD, output weighted") ///
		label(3 "TIVA rev3") label(4 "TIVA rev3, output weighted")  /// 
		label(5 "TIVA rev4") label(6 "TIVA rev4, output weighted")  /// 
		label(7 "MRIO") label(8 "MRIO, output weighted"))  /// 
		ytitle("elasticity (absolute value)", ) ///
		note("The average HCE deflator elasticity has been computed from each of countries" ///
		"in a common 43 countries sample" ///
		"assuming all 2020 Eurozone countries already in the Eurozone from 1995" ///
		"and aggregated using either an arithmetic mean or an output weighted mean") ///
		scheme(s1mono)



		

graph export "$dirgit/Rédaction/PIWIM_LONGITUDINAL.png", replace

/*
erase temp_TIVA_REV4.dta		
erase temp_TIVA.dta
erase temp_WIOD.dta
erase temp_MRIO.dta
