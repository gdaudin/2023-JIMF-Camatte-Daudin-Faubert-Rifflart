clear  
set more off
if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA"
if ("`c(username)'"=="n818881") global dir "\\intra\partages\au_dcpm\DiagConj\Commun\CommerceVA"

*capture log close
*log using "$dir/$S_DATE.log", replace



if ("`c(username)'"=="guillaumedaudin") do  "~/Documents/Recherche/2017 BDF_Commerce VA/commerce_VA_inflation/Definition_pays_secteur.do" `source'
if ("`c(username)'"=="n818881") do  "X:\Agents\LALLIARD\commerce_VA_inflation\Definition_pays_secteur.do" `source'
if ("`c(username)'"=="FAUBERT VIOLAINE") do "H:\My Documents\OFCE_CommerceVA-develop\OFCE_CommerceVA-develop\Definition_pays_secteur.do" `source'

use "$dir/Results/Étude rapport D+I et Bouclage Mondial/Elast_par_pays_2014_WIOD_HC.dta", clear

replace E1HC=-E1HC/20*100
replace E2HC=-E2HC/20*100
replace E3HC=-E3HC/20*100
replace E1HC_E2HC=-E1HC_E2HC/20*100
replace pond_WIOD_HC=-pond_WIOD_HC/20*100

gen E4HC= pond_WIOD_HC-E1HC-E2HC-E3HC

*****graph 1

preserve

replace c="" /*if c!="FRA_EUR" & c!="DEU_EUR" & c!="LUX_EUR" & c!="FRA" & c!="DEU" & c!="LUX" ///
					& c!="CAN" & c!="JPN" & c!="USA" & c!="CHN" */

graph twoway (scatter pond_WIOD_HC E1HC_E2HC, mlabel(c) mlabsize(medium)) ///
	(lfit pond_WIOD_HC E1HC_E2HC) ///
	(lfit pond_WIOD_HC pond_WIOD_HC,lwidth(vthin) color(black)) , ///
	xtitle("E1HC + E2HC") ytitle("Elasticities (%)") ///
	yscale(range(-1.5 0.0)) xscale(range(-1.5 0.0)) xlabel(-1.5 (0.2) 0.0) ylabel(-1.5 (0.2) 0.0) ///
	legend(off)		

graph export "$dir/Results/Étude rapport D+I et Bouclage Mondial/graph1_prez.pdf", replace
	
restore




****graph 2

preserve

keep if strpos("ESP_EUR ITA_EUR FRA_EUR DEU_EUR NLD_EUR",c)!=0
replace c="ESP" if c=="ESP_EUR"
replace c="ITA" if c=="ITA_EUR"
replace c="FRA" if c=="FRA_EUR"
replace c="DEU" if c=="DEU_EUR"
replace c="NLD" if c=="NLD_EUR"
graph bar E1HC E2HC E3HC E4HC, over(c, sort(pond_WIOD_HC) descending) stack scheme(s2mono) /*
	*/ legend(cols(1) size(small) label(1 "E1 direct effect (imported final consumption)") /*
	*/ label(2 "E2 indirect effect (imported interm. consumption through domestic final consumption)") /*
	*/ label(3 "E3 domestic intermediate consumption through imported final consumption") /*
	*/ label(4 "E4 rest of world retroaction effects"))
	
graph export "$dir/Results/Étude rapport D+I et Bouclage Mondial/graph2_prez.pdf", replace
restore


*****graph3

replace c="" /*if (c!="FRA" & c!="DEU" & c!="LUX"	& c!="CAN" & c!="JPN" & c!="USA" & c!="CHN" )*/
					
gen open = -E1HC

graph twoway (qfit E1HC open) ///
	(qfit E2HC open) ///
	(qfit E3HC open) ///
	(qfit E4HC open) ///
	(scatter pond_WIOD_HC open, mlabel(c) mlabsize(medium)), ///
	xtitle("-E1HC") ytitle("Contribution of Elasticities (%)") ///
	legend(cols(1) size(small) label(1 "E1 direct effect (imported final consumption)") /*
	*/ label(2 "E2 indirect effect (imported interm. consumption through domestic final consumption)") /*
	*/ label(3 "E3 domestic intermediate consumption through imported final consumption") /*
	*/ label(4 "E4 rest of world retroaction effects") /*
	*/ label(5 "Total elasticities"))
	
	
graph export "$dir/Results/Étude rapport D+I et Bouclage Mondial/graph3_prez.pdf", replace
	
	
	/*
	yscale(range(-1.5 0.0)) xscale(range(-1.5 0.0)) xlabel(-1.5 (0.2) 0.0) ylabel(-1.5 (0.2) 0.0) ///
	legend(off)	
