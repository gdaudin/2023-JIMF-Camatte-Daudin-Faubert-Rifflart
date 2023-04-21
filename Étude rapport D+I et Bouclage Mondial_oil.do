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

capture program drop etude
program etude
args year source type

**Exemple : etude 2011 WIOD HC
**Exemple : etude 2011 WIOD par_sect
	


use "$dir/Results/Secteurs_pays/mean_chg_`source'_`type'_`year'.dta", clear


*replace c =c+"_EUR" if source_shock=="EUR" 



capture gen pays=upper(c)
replace pays=upper(pays)
if "`type'"=="par_sect" rename s sector
if "`type'"=="par_sect" replace sector=upper(sector)


if "`type'"=="HC" | "`type'" =="HC_note" {
	merge 1:1 pays using "$dir/Bases/oil_inputs_HC_`year'_`source'.dta"
	
	drop _merge
	
	replace pays =upper(pays)	
	merge 1:1 pays using "$dir/Bases/contenu_oilHC_`source'_`year'.dta"
	drop if _merge ==1
	drop _merge year
}


***Pas modifié du programme de change
/*
if "`type'"=="par_sect" {
	merge 1:1 pays sector using "$dir/Bases/imp_inputs_par_sect_`year'_`source'_hze_not.dta"
	drop _merge
	replace pays =pays+"_AUTO"
	replace pays = substr(pays,1,3) if strmatch(pays,"*_EUR_AUTO")==1
	
	merge 1:1 pays sector using "$dir/Bases/imp_inputs_par_sect_`year'_`source'_hze_yes.dta", update
	drop _merge
	replace pays = pays+"_EUR" if strlen(pays)==3
	replace pays =substr(pays,1,3) if strmatch(pays,"*_AUTO")==1
	
	rename ratio_ci_impt_prod ratio_ci_impt_`type'
	
	*Faire le merge avec l'équivalent de contenu_impHC ???*
	
}
*/

if "`type'"=="HC" | "`type'" =="HC_note" {
	gen E1HC = contenu_oilHC
	gen E2HC = ratio_ci_oil_HC
}

gen E1HC_E2HC=E1HC + E2HC
label var shock1 "Élasticité des prix (`type') à un choc de pétrole"

save "$dir/Results/Secteurs_pays/Étude rapport D+I et Bouclage Mondial/Elast_par_paysoil_`year'_`source'_`type'.dta", replace
	

if "`type'"=="HC" & ((`year'==2014 & "`source'"=="WIOD") | (`year'==2015 & "`source'"=="TIVA_REV4") | ("`source'"=="TIVA"  & `year'==2011)) {


*	replace pond_`source'_`type'=-pond_`source'_`type'
	replace pays="" if c!="FRA" & c!="DEU" & c!="LUX" ///
					& c!="CAN" & c!="JPN" & c!="USA" & c!="CHN" & shock1<=0.1
	
	graph twoway (scatter shock1 E1HC_E2HC, mlabel(pays) mlabsize(medium)) ///
			(lfit shock1 E1HC_E2HC) ///
			(lfit shock1 shock1,lwidth(vthin) color(black)) , ///
			/*title("Comparing direct and modelled effects")*/ ///
			xtitle("E1HC + E2HC") ytitle("`source' Elasticities `year'") ///
			yscale(range(0.0 0.15)) xscale(range(0.0 0.15)) xlabel (0.0(0.05) 0.15) ylabel(0.0(0.05) 0.15) ///
			legend(off) ///
			scheme(s1mono)
	*dans le cas HC, xtitle pourrait se finir par «importées dans la conso dom + part conso importée»	
	
						
	graph export "$dir/Results/Secteurs_pays/Étude rapport D+I et Bouclage Mondial/graph7oil_`year'_`source'_`type'.pdf", replace
	graph export "$dirgit/Paper and Online Appendix/graph7_oil_`year'_`source'_`type'.pdf", replace
	
*	graph close

}




***Pas modifié du programme de change
/*

if "`type'"=="HC_note" & ((`year'==2014 & "`source'"=="WIOD") | (`year'==2015 & "`source'"=="TIVA_REV4")) {
	capture generate c=upper(pays)
	keep if strpos(c,"_EUR")!=0
	replace c=subinstr(c,"_EUR"e,"",.)
	*if "`source'"=="WIOD" replace pond_`source'_HC=-pond_`source'_HC/10*100
	replace pond_`source'_HC=pond_`source'_HC/10*100
	replace E1HC_E2HC = -E1HC_E2HC/10*100
	gen sample = 0
	replace sample=1 if c=="FRA" | c=="DEU" | c=="NLD" | c=="ESP" | c=="ITA"
	replace c="" if c!="FRA" & c!="DEU" & c!="NLD"  & c!="IRL"
	graph twoway  ///
			(scatter pond_`source'_HC E1HC_E2HC if sample==0, mlabel(c) mlabsize(medium) mlabcolor(sky) mcolor(sky)) ///
			(scatter pond_`source'_HC E1HC_E2HC if sample==1, mlabel(c) mlabsize(medium) mcolor(black) mlabcolor(black) ) ///
			(lfit pond_`source'_HC E1HC_E2HC) ///
			(lfit pond_`source'_HC pond_`source'_HC,lwidth(vthin) color(black)) ///
			(lfit E1HC_E2HC E1HC_E2HC,lwidth(vthin) color(black)) , ///
			xtitle("Impact D+I, en %", /*size(vsmall) */) ///
			ytitle("Impact PIWIM, en %") ///
			yscale(range(-2  -0.5)) xscale(range(-2  -0.5)) xlabel(-2 (0.5) -0.25,format(%9.2fc)) ylabel(-2  (0.5) -0.25,format(%9.2fc)) ///
			legend(off) ///
			note("PIWIM (`source', `year')")
	*dans le cas HC, xtitle pourrait se finir par «importées dans la conso dom + part conso importée»			
	

	
	*graph export "$dirgit/Rédaction_note/Rapport_D+I_bouclé_pour_note_`source'_`year'.png", replace
	
	graph close
	
}
*/

if "`type'" == "HC" {

	foreach reg in reg_ns reg_sep  {

		if "`reg'"=="reg_sep" reg shock1 E1HC E2HC
		if "`reg'"=="reg_ns" reg shock1 E1HC_E2HC
		
		preserve
		gen year=`year'
		gen source="`source'"
		gen R2_`reg'=e(r2)
		gen reg="`reg'"
	*	matrix COEF = e(b)
	*	matrix VARCOVAR=e(V)
		if "`reg'"=="reg_ns" {
			
			gen b_ns=_b[E1HC_E2HC]
			gen se_ns=_se[E1HC_E2HC]
			gen b_cst_reg_ns=_b[_cons]
			gen se_cst_reg_ns=_se[_cons]
		}
		if "`reg'"=="reg_sep" {
			
			gen b_E1HC=_b[E1HC]
			gen b_E2HC=_b[E2HC]
			
			gen se_cst=_se[_cons]
			gen se_E1HC=_se[E1HC]
			gen se_E2HC=_se[E2HC]
			
			gen b_cst_reg_sep=_b[_cons]
			gen se_cst_reg_sep =_se[_cons] 
		}
	
/*
predict predict
valuesof pays if abs(ln(predict/pond_`source'_`type')) > 0.35
gen predict_hors_0_0_35 = "`r(values)'"
valuesof pays if choc_dplusi_`type'>= pond_`source'_`type'
gen D_I_trop_grand = "`r(values)'"
corr pond_`source'_`type' choc_dplusi_`type'	
gen corr = r(rho)
*/

		
		keep if _n==1
		keep year source R2_`reg'-se_cst_`reg'
		save "$dir/Results/Secteurs_pays/Étude rapport D+I et Bouclage Mondial/resultsoil_`year'_`source'_`type'_`reg'.dta", replace 
		if "`reg'"=="reg_sep" {
			merge 1:1 year source using ///
			"$dir/Results/Secteurs_pays/Étude rapport D+I et Bouclage Mondial/resultsoil_`year'_`source'_`type'_reg_ns.dta"
			assert _merge==3
			drop _merge
			save "$dir/Results/Secteurs_pays/Étude rapport D+I et Bouclage Mondial/resultsoil_`year'_`source'_`type'.dta", replace 
		
			if `year'!=$start_year {
				append using "$dir/Results/Secteurs_pays/Étude rapport D+I et Bouclage Mondial/resultsoil_`source'_`type'.dta"
			}

			save "$dir/Results/Secteurs_pays/Étude rapport D+I et Bouclage Mondial/resultsoil_`source'_`type'.dta", replace
		}
		restore

	
	}

}
*/


end 


****************************************************************************

*etude 2015 TIVA_REV4 HC

*foreach source in  WIOD {
foreach source in  TIVA WIOD    TIVA_REV4     {



	if "`source'"=="WIOD" global start_year 2000	
	if "`source'"=="TIVA" global start_year 1995
	if "`source'"=="TIVA_REV4" global start_year 2005



	if "`source'"=="WIOD" global end_year 2014
	if "`source'"=="TIVA" global end_year 2011
	if "`source'"=="TIVA_REV4" global end_year 2015
	
	
   capture erase "$dir/Results/Secteurs_pays/Étude rapport D+I et Bouclage Mondial/resultsoil_`source'_`type'.dta" 
	foreach type in  HC  /*HC_note par_sect*/ {
		capture erase "$dir/Results/Secteurs_pays/Étude rapport D+I et Bouclage Mondial/resultsoil_`source'_`type'.dta"

*		foreach i of numlist 2014  {
		foreach i of numlist $start_year (1) $end_year  {
			etude `i' `source' `type'		
		}
	
	clear
	}

}


/*
foreach source in  WIOD  {
	use "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_`source'_HC.dta", clear
	foreach var in ns cst_reg_ns E1HC E2HC E3HC cst_reg_sep {
		gen borne_inf_`var'= b_`var'-1.96*se_`var'
		gen borne_sup_`var' =b_`var'+1.96*se_`var'
	}
	label var b_ns "b_E1HC_E2HC"
	
	graph twoway ///
		(line b_ns year, lcolor(black) ) (line borne_inf_ns year, lpattern(dash) lwidth(vthin) lcolor(black)) (line borne_sup_ns year,lpattern(dash) lwidth(vthin) lcolor(black) ) ///
		(line b_E1HC year,  lcolor(turquoise)) (line borne_inf_E1HC year, lpattern(dash) lwidth(vthin) lcolor(turquoise)) (line borne_sup_E1HC year,lpattern(dash) lwidth(vthin) lcolor(turquoise) ) ///
		(line b_E2HC year, lcolor(red)) (line borne_inf_E2HC year, lpattern(dash) lwidth(vthin) lcolor(red)) (line borne_sup_E2HC year,lpattern(dash) lwidth(vthin) lcolor(red) ) /// 
		(line b_E3HC year,  lcolor(sienna)) (line borne_inf_E3HC year, lpattern(dash) lwidth(vthin) lcolor(sienna)) (line borne_sup_E3HC year,lpattern(dash) lwidth(vthin) lcolor(sienna) )   ///
		(connected R2_reg_sep year,  lcolor(black) msize(small) mcolor(black)) (connected R2_reg_ns year,  lcolor(turquoise) msize(small) mcolor(turquoise))   ///
		,/*yscale(range(1 (0.05) 1.15)) ylabel(1 (0.05) 1.15)*/ legend(order (1 4 7 10 13 14))

	graph export "$dir/Results/Étude rapport D+I et Bouclage Mondial/coef_E_`source'_HC.pdf", replace
	
	label var b_cst_reg_ns "Constant_equation 1"
	label var b_cst_reg_sep "Constant_equation 2"
		graph twoway ///
		(line b_cst_reg_ns year, lcolor(black) ) (line borne_inf_cst_reg_ns year, lpattern(dash) lwidth(vthin) lcolor(black)) (line borne_sup_cst_reg_ns year,lpattern(dash) lwidth(vthin) lcolor(black) )    ///
		(connected b_cst_reg_sep year,  lcolor(black) msize(small) mcolor(black)) (connected borne_inf_cst_reg_sep year, lpattern(dash) lwidth(vthin) lcolor(black) msize(small) mcolor(black)) (connected borne_sup_cst_reg_sep year,lpattern(dash) lwidth(vthin) lcolor(black) msize(small) mcolor(black) )   /// 
		,/*yscale(range(1 (0.05) 1.15)) ylabel(1 (0.05) 1.15)*/ legend(order (1 4 7 10 13 16))

	graph export "$dir/Results/Étude rapport D+I et Bouclage Mondial/coef_cst_`source'_HC.pdf", replace
}
*/



foreach source in  TIVA WIOD TIVA_REV4 {
	use "$dir/Results/Secteurs_pays/Étude rapport D+I et Bouclage Mondial/resultsoil_`source'_HC.dta", clear
	foreach var in ns cst_reg_ns {
		gen borne_inf_`var'= b_`var'-1.96*se_`var'
		gen borne_sup_`var' =b_`var'+1.96*se_`var'
	}
	label var b_ns "Coefficient of E1HC+E2HC (with 95% confidence intervals)"
	label var R2_reg_ns "R2"
	
	graph twoway ///
		(line b_ns year, lcolor(black) ) (line borne_inf_ns year, lpattern(dash) lwidth(vthin) lcolor(black)) (line borne_sup_ns year,lpattern(dash) lwidth(vthin) lcolor(black) ) ///
		(connected R2_reg_ns year,  lcolor(turquoise) msize(small) mcolor(turquoise))   ///
		,/*yscale(range(1 (0.05) 1.15)) ylabel(1 (0.05) 1.15)*/ legend(order (1 4) rows(2))

	graph export "$dir/Results/Secteurs_pays/Étude rapport D+I et Bouclage Mondial/coefoil_E_`source'_HC.pdf", replace
	
	label var b_cst_reg_ns "Constant (with 95% confidence intervals)"
		graph twoway ///
		(line b_cst_reg_ns year, lcolor(black) ) (line borne_inf_cst_reg_ns year, lpattern(dash) lwidth(vthin) lcolor(black)) (line borne_sup_cst_reg_ns year,lpattern(dash) lwidth(vthin) lcolor(black) )    ///
		,/*yscale(range(1 (0.05) 1.15)) ylabel(1 (0.05) 1.15)*/ legend(order (1))

	graph export "$dir/Results/Secteurs_pays/Étude rapport D+I et Bouclage Mondial/coefoil_cst_`source'_HC.pdf", replace
}

foreach source in  TIVA_REV4  /*WIOD TIVA */ {

	if "`source'"=="WIOD" global start_year 2014	
	if "`source'"=="TIVA" global start_year 1995
	if "`source'"=="TIVA_REV4" global start_year 2015



	if "`source'"=="WIOD" global end_year 2014
	if "`source'"=="TIVA" global end_year 2011
	if "`source'"=="TIVA_REV4" global end_year 2015
	
	foreach i of numlist 2014  {
	graph drop _all
*	foreach i of numlist $start_year (1) $end_year  {
			use "$dir/Results/Secteurs_pays/Étude rapport D+I et Bouclage Mondial/Elast_par_paysoil_`i'_`source'_HC.dta", clear 
			gen E4HC = shock1 - E1HC - E2HC
			gen blouf = 0
			gen mylabel= c if strpos("FRA DEU DEU_EUR ITA ITA_EUR GBR CHN USA CAN JPN ",c)!=0
			foreach var in E1HC E2HC E4HC {
				gen share_`var'=`var'/shock1
				twoway histogram share_`var', start(-0.2) width(0.1) freq name(`var') || ///
					scatter blouf share_`var' if mylabel!="", /// 
					xscale(range(-0.1 (0.1) 1)) xlabel(-0.1 (0.1) 1) ///
					mlabel(mylabel) mlabposition(12)  mlabangle(vertical)  mlabgap(huge) mlabsize(vsmall) msymbol(pipe) ///
					legend(off) /*scheme(s1color)*/
			}
		graph combine 	E1HC E2HC E4HC, name(hist_components_`source'_`i') scheme(s1mono)
		graph export "$dir/Results/Secteurs_pays/Étude rapport D+I et Bouclage Mondial/hist_componentsoil_`source'_`i'.png", replace
			
		}
		
}

graph display hist_components_TIVA_REV4_2014
graph export "$dir/commerce_VA_inflation/Rédaction/hist_componentsoil_TIVA_REV4_2014.png", replace


