*ssc install estout, replace


if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA"
if ("`c(hostname)'" == "widv270a") global dir  "D:/home/T822289/CommerceVA" 
if ("`c(hostname)'" == "FP1376CD") global dir  "T:/CommerceVA" 

if ("`c(username)'"=="guillaumedaudin") global dirgit "~/Répertoires Git/2023 JIMF Camatte Daudin Faubert Rifflart"
if ("`c(hostname)'" == "widv270a") global dirgit  "D:\home\T822289\CommerceVA\GIT\commerce_va_inflation" 

global eurozone "AUT BEL CYP DEU ESP EST FIN FRA GRC IRL ITA LTU LUX LVA MLT NLD PRT SVK SVN"

import delimited "$dir/Bases_Sources/MRIO/Pays_MRIO_ISO3.csv", clear varnames(1)
expand 2 if strpos("$eurozone",iso3)!=0, gen(pourchoceuro)
replace pays_mrio = pays_mrio+"_EUR" if pourchoceuro==1
replace iso3 = iso3+"_EUR" if pourchoceuro==1
drop pourchoceuro
sort iso3
save "$dir/Bases_Sources/MRIO/Pays_MRIO_ISO3.dta", replace

import excel "$dir/Bases_Sources/Data_GDP_WEO.xlsx", /*
			*/sheet("WEO_Data (2)") firstrow clear

keep ISO y*
destring y*, replace force

drop if ISO==""
reshape long y, i(ISO) j(year)
rename ISO pays
rename y GDP
replace GDP=GDP*1000000000
drop if GDP==.

save "$dir/Bases_Sources/Doigt_mouillé.dta", replace


import excel "$dir/Bases_Sources/Banque_mondiale_conso_finale_menages_isblsm.xls", sheet("Data") cellrange(A4:AC268) firstrow clear
foreach v of varlist E-AC {
    local x : variable label `v'
	rename `v' y`x'
}

keep CountryCode y*
rename y* conso*
reshape long conso,i(CountryCode) j(year)
*replace conso=conso*1000000000
rename CountryCode pays
merge 1:1 year pays using "$dir/Bases_Sources/Doigt_mouillé.dta"
drop _merge
save "$dir/Bases_Sources/Doigt_mouillé.dta", replace



import excel "$dir/Bases_Sources/Eurostat_conso_intermédiaires.xls", sheet("Intermediate_consumption_") cellrange(A10:AB218) firstrow clear
rename A pays
drop B
foreach v of varlist C-AB {
    local x : variable label `v'
	rename `v' y`x'
}
drop if pays==""
rename y* conso_interm*
reshape long conso_interm,i(pays) j(year)
destring conso_interm, replace force
replace conso_interm=conso_interm*1000000
merge 1:1 year pays using "$dir/Bases_Sources/Doigt_mouillé.dta"
drop _merge
save "$dir/Bases_Sources/Doigt_mouillé.dta", replace


egen Y_tot_per_year=total(GDP), by(year)
gen weight=GDP/Y_tot_per_year
save "$dir/Bases_Sources/Doigt_mouillé.dta", replace

***Pour zone euro
expand 2 if strpos("$eurozone",pays)!=0, gen(pourchoceuro)
replace pays = pays+"_EUR" if pourchoceuro==1
drop pourchoceuro
save "$dir/Bases_Sources/Doigt_mouillé.dta", replace
****

*****Pour les données de commerce

merge 1:1 pays year using "$dir/Bases/BACI_BEC/BACI_SNAClasses_Y.dta"

**1995-1998 manque pour LUX. 2019 manque pour TWN (qui est approximé par "Autre Asie" dans BACI)
generate impt_tot = (vCapital+ vConsumption+ vIntermediate+ vNC)
generate impt_conso = vConsumption*1000
generate impt_interm = vIntermediate*1000
keep pays year impt*
merge 1:1 year pays using "$dir/Bases_Sources/Doigt_mouillé.dta"
assert _merge!=2
keep if _merge==3
drop _merge

save "$dir/Bases_Sources/Doigt_mouillé.dta", replace


/*
import excel "$dir/Bases_Sources/UN_comtrade_biens_de_conso_95_2018.xlsx", /*
	*/sheet("UN_comtrade_biens_de_conso") firstrow clear
keep Year ReporterISO TradeValueUS
collapse (sum) TradeValueUS, by (ReporterISO Year)
rename Year year
rename ReporterISO pays
rename TradeValueUS impt_conso
merge 1:1 year pays using "$dir/Bases_Sources/Doigt_mouillé.dta"
drop _merge

save "$dir/Bases_Sources/Doigt_mouillé.dta", replace


import excel "$dir/Bases_Sources/UN_comtrade_biens_intermediaires_95_2018.xlsx", /*
	*/sheet("Biens intermédiaires") firstrow clear

	
keep Year ReporterISO TradeValueUS
collapse (sum) TradeValueUS, by (ReporterISO Year)
rename Year year
rename ReporterISO pays
rename TradeValueUS impt_interm
merge 1:1 year pays using "$dir/Bases_Sources/Doigt_mouillé.dta"
drop _merge

save "$dir/Bases_Sources/Doigt_mouillé.dta", replace

/*
*Au 29 novembre 2019, il manque 2008 et plus dans total
import excel "$dir/Bases_Sources/UN_comtrade_total.xlsx", /*
	*/sheet("Total") firstrow clear
keep Year ReporterISO TradeValueUS
collapse (sum) TradeValueUS, by (ReporterISO Year)
rename Year year
rename ReporterISO pays
rename TradeValueUS impt_tot
merge 1:1 year pays using "$dir/Bases_Sources/Doigt_mouillé.dta", keep(3)
drop _merge
save "$dir/Bases_Sources/Doigt_mouillé.dta", replace
*/

drop if year==1995 | year==1996 | year==1997
*/

****On enlève les pays ZE -- monnaie notionnelle

drop if strpos("$eurozone",pays)!=0

save "$dir/Bases_Sources/Doigt_mouillé.dta", replace



*********************************************Régression en cross-section 

/*
capture program drop collecter_resultats_reg
program collecter_resultats_reg
args source y reg
	use "$dir/Bases_Sources/Doigt_mouillé.dta", clear
	if "`reg'"=="reg1" generate ratio_impt_conso=impt_conso/GDP
	if "`reg'"=="reg1" generate ratio_impt_interm = impt_interm/GDP
	
	if "`reg'"=="reg2" generate ratio_impt_conso=impt_conso/conso
	if "`reg'"=="reg2" generate ratio_impt_interm = impt_interm/conso_interm*(1-impt_conso/conso)
	
	gen E1_E2 = ratio_impt_conso + ratio_impt_interm
	merge 1:1 year pays using /*
		'*/ "$dir/Results/Devaluations/auto_chocs_HC_`source'_`y'.dta", keep(3)
	*drop if strmatch(pays,"*_EUR")==1
	
	replace pond_`source'_HC=-pond_`source'_HC
	reg pond_`source'_HC E1_E2
	
	predict x
	
	
	gen y=x
	gen z=pond_`source'_HC
	graph twoway (scatter x pond_`source'_HC, mlabel(pays)) (line x y) (line z pond_`source'_HC), /*
	*/ title (`reg'_`source'_`y') /*
	 */ name("resultats_`reg'_`source'_`y'", replace)
	graph export  "$dir/Results/resultats_doigt_mouillé_`reg'_`source'_`y'.png", replace
	


	
	keep year
	gen source="`source'"
	gen R2=e(r2)
	gen b_cst=_b[_cons]
	*gen b_conso=_b[ratio_impt_conso]
	*gen b_interm=_b[ratio_impt_interm]
	gen b_E1_E2=_b[E1_E2]
	gen se_cst=_se[_cons]
	*gen se_conso=_se[ratio_impt_conso]
	*gen se_interm=_se[ratio_impt_interm]
	gen se_E1_E2=_se[E1_E2]
	gen nbr_obs = e(N)
	keep if _n==1
	capture append using "$dir/Results/resultats_doigt_mouillé_`reg'.dta"
	save "$dir/Results/resultats_doigt_mouillé_`reg'.dta", replace
	
end



set graphics off

capture erase "$dir/Results/resultats_doigt_mouillé_reg1.dta"
capture erase "$dir/Results/resultats_doigt_mouillé_reg2.dta"

foreach y of num 1998(1)2011 {

	collecter_resultats_reg TIVA `y' reg1
	collecter_resultats_reg TIVA `y' reg2
}

foreach y of num 2000(1)2014 {
	collecter_resultats_reg WIOD `y' reg1
	collecter_resultats_reg WIOD `y' reg2
}


foreach y of num 2005(1)2015 {
	collecter_resultats_reg TIVA_REV4 `y' reg1
	collecter_resultats_reg TIVA_REV4 `y' reg2
}	

set graphics on



****************** Graphiques de coefficients

foreach reg in reg2 reg1 {

	use "$dir/Results/resultats_doigt_mouillé_`reg'.dta", clear
	
	gen high_E1_E2=b_E1_E2-1.96*se_E1_E2
	gen low_E1_E2=b_E1_E2+1.96*se_E1_E2
	graph twoway (rarea high_E1_E2 low_E1_E2 year if source=="TIVA", fcolor(%20) ) (connected b_E1_E2 year if source=="TIVA") /*
				*/ (rarea high_E1_E2 low_E1_E2 year if source=="TIVA_REV4" , fcolor(%20) ) (connected b_E1_E2 year if source=="TIVA_REV4")/*
				*/ (rarea high_E1_E2 low_E1_E2 year if source=="WIOD" , fcolor(%20)  ) (connected b_E1_E2 year if source=="WIOD"), /*
				*/ legend( order(1 3 5) label(1 TIVA) label(3 TIVA_REV4) label(5 WIOD) ) /*
				*/ title(beta)
	graph export "$dir/Results/`reg'_beta.png", replace
	
	/*if "`reg'"=="reg2"*/ label var b_E1_E2 "{&beta} (with 95% confidence intervals)"
	label var R2 "R2"
	
	
	
	
	graph twoway ///
		(line b_E1_E2 year if source=="WIOD", lcolor(black)) ///
		(line low_E1_E2 year  if source=="WIOD", lpattern(dash) lwidth(vthin) lcolor(black)) ///
		(line high_E1_E2 year  if source=="WIOD",lpattern(dash) lwidth(vthin) lcolor(black)) ///
		(connected R2 year  if source=="WIOD",  lcolor(turquoise) msize(small) mcolor(turquoise))   ///
		,/*yscale(range(1 (0.05) 1.15)) ylabel(1 (0.05) 1.15)*/ legend(order (1 4) rows(2) size(small)) ///
		scheme(s1mono) name(`reg'_beta_WIOD, replace)
	graph export "$dir/Results/`reg'_beta_WIOD.png", replace
	graph export "$dirgit/Rédaction/`reg'_beta_WIOD.png", replace
	

	
	/*
	gen high_interm=b_interm-1.96*se_interm
	gen low_interm=b_interm+1.96*se_interm
	graph twoway (rarea high_interm low_interm year if source=="TIVA", fcolor(%20) ) (connected b_interm year if source=="TIVA") /*
				*/ (rarea high_interm low_interm year if source=="TIVA_REV4" , fcolor(%20) ) (connected b_interm year if source=="TIVA_REV4") /*
				*/ (rarea high_interm low_interm year if source=="WIOD" , fcolor(%20)  ) (connected b_interm year if source=="WIOD"), /*
				*/ legend( order(1 3 5) label(1 TIVA) label(3 TIVA_REV4) label(5 WIOD) )  /*
				*/ title(gamma)
	graph export "$dir/Results/`reg'_gamma_`source'_`y'.png", replace
	*/
	
	
	
	gen high_cst=b_cst-1.96*se_cst
	gen low_cst=b_cst+1.96*se_cst
	graph twoway (rarea high_cst low_cst year if source=="TIVA", fcolor(%20) ) (connected b_cst year if source=="TIVA") /*
				*/ (rarea high_cst low_cst year if source=="TIVA_REV4" , fcolor(%20) ) (connected b_cst year if source=="TIVA_REV4") /*
				*/ (rarea high_cst low_cst year if source=="WIOD" , fcolor(%20)  ) (connected b_cst year if source=="WIOD"), /*
				*/ legend( order(1 3 5) label(1 TIVA) label(3 TIVA_REV4) label(5 WIOD) ) /*
				*/ title(alpha) scheme(s1mono) name(`reg'_alpha, replace)			
	graph export "$dir/Results/`reg'_alpha.png", replace

	
	label var b_cst "{&alpha} (with 95% confidence intervals)"
	
	graph twoway (line high_cst year if source=="WIOD" , lpattern(dash) lwidth(vthin) lcolor(black)  ) ///
				 (line low_cst year if source=="WIOD" , lpattern(dash) lwidth(vthin) lcolor(black)  ) ///
				 (line b_cst year if source=="WIOD", lpattern(solid) lcolor(black)), /*
				*/ legend( order(3)) /*
				*/ scheme(s1mono) name(`reg'_alpha_WIOD, replace)
	
	
	
	graph combine `reg'_beta_WIOD `reg'_alpha_WIOD, scheme(s1mono)
	
	graph export "$dir/Results/`reg'_WIOD.png", replace
	graph export "$dirgit/Rédaction/`reg'_WIOD.png", replace
	

		graph twoway (connected R2 year if source=="TIVA") /*
				*/   (connected R2 year if source=="TIVA_REV4") /*
				*/   (connected R2 year if source=="WIOD"), /*
				*/ legend( order(1 2 3) label(1 TIVA) label(2 TIVA_REV4) label(3 WIOD) ) /*
				*/ title(R2)
	graph export "$dir/Results/`reg'_R2.png", replace
	
	
}
*/
*******************************************
***************** Régressions en panel

use "$dir/Bases_Sources/Doigt_mouillé.dta", clear
	
foreach y of num 1998(1)2011 {
	merge 1:1 year pays using /*
		'*/ "$dir/Results/Devaluations/auto_chocs_HC_TIVA_`y'.dta", update
		drop _merge
	
}

foreach y of num 2000(1)2014 {
	merge 1:1 year pays using /*
		'*/ "$dir/Results/Devaluations/auto_chocs_HC_WIOD_`y'.dta", update
		drop _merge
	
}


foreach y of num 2005(1)2015 {
	merge 1:1 year pays using /*
		'*/ "$dir/Results/Devaluations/auto_chocs_HC_TIVA_REV4_`y'.dta",  update
		drop _merge
	
}

rename pays iso3

merge m:1 iso3 using "$dir/Bases_Sources/MRIO/Pays_MRIO_ISO3.dta", keep(3)
drop country note
drop _merge

rename pays_mrio pays


foreach y of numlist 2000 2007(1)2019 {
	merge 1:1 year pays using /*
		'*/ "$dir/Results/Devaluations/auto_chocs_HC_MRIO_`y'.dta",  update
		drop _merge
	
}

drop if iso3==""
drop pays
rename iso3 pays

	


encode pays, generate(pays_num)

tsset pays_num year
generate ratio_impt_conso=impt_conso/conso
generate ratio_impt_interm = impt_interm/conso_interm*(1-impt_conso/conso)

gen ratio_impt_conso_pond = ratio_impt_conso*weight
gen ratio_impt_interm_pond = ratio_impt_interm*weight

egen ratio_impt_conso_mean = total(ratio_impt_conso_pond), by(year)
egen ratio_impt_interm_mean = total(ratio_impt_interm_pond), by(year)

foreach source in WIOD TIVA TIVA_REV4 MRIO {
	replace pond_`source'_HC=-pond_`source'_HC
}


save "$dir/Bases_Sources/Doigt_mouillé_panel.dta", replace
foreach source in WIOD TIVA TIVA_REV4 MRIO {
	reg pond_`source'_HC ratio_impt_conso ratio_impt_interm ratio_impt_conso_mean ratio_impt_interm_mean i.pays_num
	predict x
	gen y=x
	gen z=pond_`source'_HC
	graph twoway (scatter x pond_`source'_HC, mlabel(pays)) (line x y) (line z pond_`source'_HC), /*
	*/ title (Reg2_`source'_panel) /*
	 */ name("resultats_panel_`source'", replace)
	graph export  "$dir/Results/resultats_doigt_mouillé_panel_`source'.png", replace
	drop x
	drop y
	drop z
}




*****************Pour les prédictions après Panel

use "$dir/Bases_Sources/Doigt_mouillé_panel.dta", clear

local WIOD_pred=2014
local TIVA_REV4_pred=2015
local TIVA_pred = 2011
local MRIO_pred = 2019

foreach reg in reg1 reg2 {

	if "`reg'"=="reg1" {
		replace ratio_impt_conso=impt_conso/GDP
		replace ratio_impt_interm = impt_interm/GDP
	}
	if "`reg'"=="reg2" {
		replace ratio_impt_conso=impt_conso/conso
		replace ratio_impt_interm = impt_interm/conso_interm*(1-impt_conso/conso)
	}
	
	foreach lag_pred of numlist/*1(1)8*/ 6 {
		foreach source in WIOD /*TIVA TIVA_REV4 MRIO*/ {
			foreach trend in no yes {
				local `source'_out = ``source'_pred'-`lag_pred'+1
				
				if "`trend'"=="no" reg pond_`source'_HC ratio_impt_conso ratio_impt_interm i.pays_num ratio_impt_conso_mean ratio_impt_interm_mean if year <``source'_out'
				if "`trend'"=="yes" reg pond_`source'_HC ratio_impt_conso ratio_impt_interm i.pays_num year ratio_impt_conso_mean ratio_impt_interm_mean if year <``source'_out'
				predict x if year== ``source'_pred'
				gen y=x
				gen z=pond_`source'_HC
				corr x pond_`source'_HC
				local correlation = r(rho)
				local correlation : display %4.3f `correlation'
				
				gen error = abs(x-pond_`source'_HC)/ pond_`source'_HC
				summarize error
				local mean_error= r(mean)
				local mean_error : display %4.3f `mean_error'
				summarize error, detail
				local median_error= r(p50)
				local median_error : display %4.3f `median_error'
				
				label var pond_`source'_HC "Elasticity from `source'"
				label var x "Predicted elasticity"
				tab pays if x!=. & pond_`source'_HC !=.
				local N=r(N)
				
				
				capture drop n 
				gen n=_n
				sort x
				capture drop pays_label 
				gen pays_label = "" /*pays if n/20==int(n/20) | pays=="USA" | pays=="FRA_EUR" & pays!="GBR" & pays!= "GRC_EUR" /*| pays=="FRA"  ///
						| pays=="ITA" | pays=="GBR" | pays=="DEU" | pays=="JPN" | pays=="CHN" */ */
				graph twoway (scatter x pond_`source'_HC if (x!=. & pond_`source'_HC !=.) , mlabel(pays_label) mlabposition(4) mlabangle(-45)  ) /*
				*/ (lfit x pond_`source'_HC if x!=. & pond_`source'_HC !=., lpattern(dash) ) /*
				*/ (line x y if x!=. & pond_`source'_HC !=.) (line y y if x!=. & pond_`source'_HC !=.), legend(off) /*
				*//* title (`source'_`reg'_pred_`lag_pred'y trend: `trend') *//*
				 */ name("`source'_pred_`lag_pred'y", replace) ytitle("Predicted elasticity")/*
				 */ xtitle("HCE deflator elasticity in 2014 (WIOD)") /*
				 */ note("N: `N' Correlation: `correlation' Mean error: `mean_error' p.c.  Median error: `median_error' p.c.") /*
				 */ scheme(s1color) /*
				 */ yscale(range(0.05 (0.05) 0.2)) ylabel(0.05 (0.05) 0.2)/*
				 */ xscale(range(0.05 (0.05) 0.2)) xlabel(0.05 (0.05) 0.2)
				
				graph export  "$dir/Results/resultats_`reg'_doigt_mouillé_`source'_pred_`lag_pred'y_trend_`trend'.png", replace
				if "`source'"=="WIOD" & "`trend'"=="no" & `lag_pred'==6 {
					graph export  "$dirgit/Rédaction/resultats_`reg'_doigt_mouille_`source'_pred_`lag_pred'y_trend_`trend'.png", replace
		
				}
				drop x
				drop y
				drop z
				drop error
			}
		}
	}

}



***** pour les graphiques de prédiction (en reg1 -- sans eurostat) ni trend

*local sanslachine wochinaindia

*il faut juste enlever la ligne pour faire sans la Chine

use "$dir/Bases_Sources/Doigt_mouillé_panel.dta", clear

if "`sanslachine'"=="wochina" drop if pays=="CHN"
if "`sanslachine'"=="wochinaindia" drop if pays=="CHN"
if "`sanslachine'"=="wochinaindia" drop if pays=="IND"

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

/*
label var ratio_impt_conso "Share of imp. cons. goods over GDP (i,t)"
label var ratio_impt_interm "Share of imp. inter. goods over GDP (i,t)"
label var ratio_impt_conso_mean "Mean sample share of imp. consx goods over GDP (t)"
label var ratio_impt_interm_mean "Mean sample share of imp. inter. goods over GDP (t)"
*/

label var ratio_impt_conso "\$ \beta_{1} \$"
label var ratio_impt_interm "\$ \beta_{2} \$"
label var ratio_impt_conso_mean "\$ \beta_{3} \$"
label var ratio_impt_interm_mean "\$ \beta_{4} \$"

est clear
global controls ratio_impt_conso ratio_impt_interm ratio_impt_conso_mean ratio_impt_interm_mean
foreach source in WIOD TIVA TIVA_REV4 MRIO {
	*reg pond_`source'_HC ratio_impt_conso ratio_impt_interm i.pays_num
	eststo `source' : reg pond_`source'_HC ratio_impt_conso ratio_impt_interm ratio_impt_conso_mean ratio_impt_interm_mean i.pays_num, vce(cluster pays_num)
	tab pays_num if e(sample)==1
	local nbrc=r(r)
	tab year if e(sample)==1
	local nbry=r(r)
	test ratio_impt_conso ratio_impt_interm ratio_impt_conso_mean ratio_impt_interm_mean
	local test r(p)
	local test : di %10.2f `test'
	estadd local pF_test=`test'
	estadd local nbrcountry  "`nbrc'"
	estadd local nbryear  "`nbry'"
	estadd local FE "Yes"
	predict x_`source' /*if year >= 2010  & pond_`source'_HC ==. */
}


esttab WIOD TIVA TIVA_REV4 using "$dirgit/Rédaction/reg17.tex", replace b(2) se(2) label star(* 0.10 ** 0.05 *** 0.01) ///
    booktabs ///
	keep($controls) mtitle("WIOD" "TIVA" "TIVA REV4") ///
	scalars("FE Country fixed effects" "nbrcountry Number of countries" "nbryear Number of years" ///
	"r2_a Adj. R-square" "pF_test p-value joint significance test (excluding fixed effects)" ) ///
	substitute(\_ _) nonotes 
	
	*	stats(r2_a, label ("Adj. R-square")) ///



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
		(line WIOD_elast_annual_pond_pred year, lcolor(blue) lpattern(dash)) ///
		(line TIVA_elast_annual_pond year, lcolor(red)) ///
		(line TIVA_elast_annual_pond_pred year, lcolor(red) lpattern(dash)) ///
		(line TIVA_REV4_elast_annual_pond year, lcolor(green)) ///
		(line TIVA_REV4_elast_annual_pond_pred year, lcolor(green) lpattern(dash)) ///
		(connected MRIO_elast_annual_pond year, lcolor(black) lstyle(solid) msize(medium) mfcolor(black*100)) ///
		/*(line MRIO_elast_annual_pond_pred year, lcolor(black) lpattern(dash))*/, ///
		legend(label(2 "predicted WIOD") label(1 "WIOD ") ///
		label(4 "predicted TIVA rev3") label(3 "TIVA rev3")  /// 
		label(6 "predicted TIVA rev4") label(5 "TIVA rev4")  /// 
		/*label(8 "predicted MRIO rev4")*/ label(7 "MRIO rev4"))  /// 
		ytitle("elasticity (absolute value)" "output weighted", margin(medium)) ///
		note("The average CPI elasticity has been computed from each of countries" ///
		"in a common 42 countries sample" ///
		"assuming all 2020 Eurozone countries already in the Eurozone from 1995" ///
		"and aggregated using an output weighted mean") ///
		scheme(s1mono)


graph export  "$dirgit/Rédaction/predictions_reg1_doigt_mouille_trend_no`sanslachine'.png", replace

