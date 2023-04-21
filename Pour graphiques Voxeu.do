


*gr0034.pkg
*from:  http://www.stata-journal.com/software/sj8-2/

*search labutil




clear  
set more off
if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA"
else global dir "\\intra\partages\au_dcpm\DiagConj\Commun\CommerceVA"

if ("`c(username)'"=="guillaumedaudin") global dirgit "~/Répertoires Git/2023 JIMF Camatte Daudin Faubert Rifflart"

*capture log close
*log using "$dir/$S_DATE.log", replace


do  "$dirgit/Definition_pays_secteur.do" `source'
global eurozone "AUT BEL CYP DEU ESP EST FIN FRA GRC IRL ITA LTU LUX LVA MLT NLD PRT SVK SVN"


*******Pour graphique de sensibilité aux chocs de change
use "$dir/Bases_Sources/Doigt_mouillé_panel.dta", clear


*drop if strpos(pays,"_EUR")!=0
replace ratio_impt_conso=impt_conso/GDP
replace ratio_impt_interm = impt_interm/GDP
drop if ratio_impt_conso==.
drop if ratio_impt_interm==.






foreach source in WIOD /*TIVA TIVA_REV4 MRIO*/ {
	*reg pond_`source'_HC ratio_impt_conso ratio_impt_interm i.pays_num
	reg pond_`source'_HC ratio_impt_conso ratio_impt_interm ratio_impt_conso_mean ratio_impt_interm_mean i.pays_num
	predict x_`source' /*if year >= 2010  & pond_`source'_HC ==. */
}

keep if year==2019
replace pays=substr(pays,1,3)
drop if pays=="ROW"
graph hbar x_WIOD, over(pays, sort(1) label(labsize(tiny))) scheme(s1color) ytitle("")




*Elasticity of the consumer prices" "to a shock in domestic currency, WIOD, 2019") note("Each country is assumed to have is own currency" "Except for countries suffixed by _EUR: the shock is then on the Euro")

graph export "$dirgit/Article VoxEU/Elasticity change WIOD 2019.pdf", replace



*******Pour graphique de sensibilité aux prix des hydrocarbure
**Voir https://www.statalist.org/forums/forum/general-stata-discussion/general/1481727-graph-bar-with-multiple-yvars-with-different-scales

use "$dir/Results/secteurs_pays/mean_chg_TIVA_REV4_HC_2015_RUS.dta", clear
rename shock1 RUS
merge 1:1 c using "$dir/Results/secteurs_pays/mean_chg_TIVA_REV4_HC_2015.dta"
drop _merge
gen ratio = RUS/shock1
sort ratio
drop if c=="RUS"
drop if c=="ROW"


replace c=substr(c,1,3)

/*
sort ratio

gen sorted_ctry1=(2*_n)-1+(_n-1)
gen sorted_ctry2=sorted_ctry1+1
labmask sorted_ctry2, values(c)

twoway line shock1 sorted_ctry1, yaxis(1) ///
	ytitle("Elasticity to a shock on" "mined energy products prices", axis(1)) || ///
	bar ratio sorted_ctry2, yaxis(2) /// 
	ytitle("Share attributable to Russian" "mined energy product prices", axis(2)) ///
	xlabel(2(3)188, valuelabel angle(90) notick labsize(tiny)) ///
	|| bar RUS sorted_ctry1,yaxis(1) ///
	legend(order(1 "Total elasticity" 2 "Elasticity to Russia" 3 "Share attributable to Russia") size(*0.9)) ///
	xtitle("") ///
	scheme(s1color)
*/	


gen shock_reste=shock1-RUS


local sample "BRA IND USD CAN IRL CHE CHN LUX MLT NOR ZPN GBR ESP PRT FRA DNK"
local sample "`sample' TUR KAZ AUT BEL CYP SWE GRC DEU SVN NLD ROU HRV ITA FIN POL"
local sample "`sample' EST CZE LVA HUN SVK BGR LTU USA JPN"
gen sample=1 if strpos("`sample'",c)!=0


graph hbar  RUS shock_rest if sample==1, stack over(c, sort(1) label(labsize(vsmall))) scheme(s1color) legend(order(2 "Elasticity to a shock on" "mined energy products prices" 1 "Elasticity to a shock on" "Russian mined energy products prices") rows(2) size(small) ) name(energy1, replace)

graph hbar  ratio if sample==1, stack over(c, sort(1) label(labsize(vsmall))) ///
		scheme(s1color) ///
		ytitle("Share attributable to Russia") ///
		name(energy2, replace)
		
	*	legend(order(1 "Elasticity to a shock on Russian mined energy products prices")) ///

*keep if strpos(c,")

graph combine energy1 energy2, scheme(s1color)






graph export "$dirgit/Article VoxEU/Elasticity hydrocarbon TIVA_REV4 2015.pdf", replace



********Pour graphique de la distribution des shares

foreach source in  WIOD /*TIVA TIVA_REV4 */{

	if "`source'"=="WIOD" global start_year 2014	
	if "`source'"=="TIVA" global start_year 1995
	if "`source'"=="TIVA_REV4" global start_year 2015



	if "`source'"=="WIOD" global end_year 2014
	if "`source'"=="TIVA" global end_year 2011
	if "`source'"=="TIVA_REV4" global end_year 2015
	
	foreach i of numlist 2014  {
		graph drop _all
*	foreach i of numlist $start_year (1) $end_year  {
		use "$dir/Results/Étude rapport D+I et Bouclage Mondial/Elast_par_pays_`i'_`source'_HC.dta", clear 
		replace pond_WIOD_HC=-pond_WIOD_HC
		gen E4HC = pond_WIOD_HC - E1HC - E2HC - E3HC
		gen blouf = 0
		drop if (strpos("$eurozone",pays)!=0 & strpos("_EUR",pays)!=4)
		replace pays=substr(pays,1,3)
			

	sort E1HC
	gen E1_order = _n
	
	labmask E1_order,values(pays)
	
	Definition_pays_secteur `source'
	
	gen GVC=E3HC+E4HC
	
	drop if pays=="ROW"
	
	graph hbar (asis) E1HC E2HC GVC,  stack over(E1_order, ///
		label(labsize(tiny))) ///
		marker(1, ms(O) mfcolor(gs1) mlcolor(gs1) msize(tiny) ) ///
		marker(2, ms(+) mfcolor(gs5) mlcolor(gs5) msize(small) ) ///
		marker(3, ms(O) mfcolor(gs9) mlcolor(gs9) msize(tiny) ) ///
		xsize(9)  ysize(7) ///
		name(distr_components_`source'_`i', replace) ///
		legend(position(3) cols(1)  size(vsmall) label(1 "Direct effect" "through imported" "consumption goods") ///
		label(2 "Effect on domestic" "consumption goods" "through imported inputs") ///
		label(3 "Effect through Global value chains")) ///
		scheme(s1color)
		
	graph export "$dirgit/Article VoxEU/distribution_components_`source'_`i'.pdf", replace	
		
			
		}	
}


***Pour graphique évolution




use "$dir/Bases_Sources/Doigt_mouillé_panel.dta", clear



*drop if strpos(pays,"_EUR")!=0
replace ratio_impt_conso=impt_conso/GDP
replace ratio_impt_interm = impt_interm/GDP
drop if ratio_impt_conso==.
drop if ratio_impt_interm==.



drop Y_tot_per_year weight ratio_impt_conso_pond ratio_impt_interm_pond ratio_impt_conso_mean ratio_impt_interm_mean

egen Y_tot_per_year=total(GDP), by(year)
gen weight=GDP/Y_tot_per_year



gen ratio_impt_conso_pond = ratio_impt_conso*weight
gen ratio_impt_interm_pond = ratio_impt_interm*weight

egen ratio_impt_conso_mean = total(ratio_impt_conso_pond), by(year)
egen ratio_impt_interm_mean = total(ratio_impt_interm_pond), by(year)




foreach source in WIOD TIVA TIVA_REV4 MRIO {
	*reg pond_`source'_HC ratio_impt_conso ratio_impt_interm i.pays_num
	reg pond_`source'_HC ratio_impt_conso ratio_impt_interm ratio_impt_conso_mean ratio_impt_interm_mean i.pays_num
	predict x_`source' /*if year >= 2010  & pond_`source'_HC ==. */
}


	
global common_sample "   AUS AUT_EUR BEL_EUR BGR BRA CAN CHE" 
global common_sample "$common_sample CHN CYP_EUR CZE DEU_EUR DNK ESP_EUR EST_EUR FIN_EUR"
global common_sample "$common_sample FRA_EUR GBR GRC_EUR    HRV HUN IDN IND IRL_EUR        ITA_EUR JPN     KOR"
global common_sample "$common_sample LTU_EUR LUX_EUR LVA_EUR MEX              MLT_EUR     NLD_EUR NOR        POL PRT_EUR"
global common_sample "$common_sample ROU RUS       SVK_EUR SVN_EUR SWE       TUR TWN USA        "

keep if strpos("$common_sample",pays)!=0

drop Y_tot_per_year weight
egen Y_tot_per_year=total(GDP), by(year)
gen weight=GDP/Y_tot_per_year


foreach source in WIOD TIVA TIVA_REV4 MRIO {	
	gen elast_pond=pond_`source'_HC*weight
	gen elast_pond_pred=x_`source'*weight
	egen `source'_elast_annual_pond=total(elast_pond), by(year)
	egen `source'_elast_annual_pond_pred=total(elast_pond_pred), by(year)
	drop elast_pond elast_pond_pred
	replace `source'_elast_annual_pond=. if `source'_elast_annual_pond==0 
	replace `source'_elast_annual_pond_pred=. if `source'_elast_annual_pond_pred==0 
}




drop pays
sort year
bys year: keep if _n==1
keep year WIOD_elast_annual_pond-MRIO_elast_annual_pond_pred


twoway 	(line WIOD_elast_annual_pond year, lcolor(blue)) ///
		(line WIOD_elast_annual_pond_pred year, lcolor(red) lpattern(dash)) ///
		(line TIVA_REV4_elast_annual_pond year, lcolor(green)) ///
		/*(line MRIO_elast_annual_pond_pred year, lcolor(black) lpattern(dash))*/, ///
		legend(label(2 "extrapolation from WIOD") label(1 "WIOD") ///
		 label(3 "TIVA rev4"))  /// 
		ytitle("elasticity (output weighted)", margin(medium)) ///
		note("The average CPI elasticity has been computed from each of countries" ///
		"in a common 43 countries sample, assuming all" ///
		"2020 Eurozone countries already in the Eurozone from 1995." ///
		"The extrapolation relies on GDP and trade data") ///
		scheme(s1color)


graph export  "$dirgit/Article VoxEU/doigt_mouille.pdf", replace
