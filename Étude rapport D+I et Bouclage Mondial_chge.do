*net install grc1leg2




clear  
set more off
if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA"
if ("`c(hostname)'" == "widv270a") global dir  "D:\home\T822289\CommerceVA" 
if ("`c(hostname)'" == "FP1376CD") global dir  "T:\CommerceVA" 


if ("`c(username)'"=="guillaumedaudin") global dirgit "~/Répertoires Git/2023 JIMF Camatte Daudin Faubert Rifflart"
if ("`c(hostname)'" == "widv270a") global dirgit  "D:\home\T822289\CommerceVA\GIT\commerce_VA_inflation" 
if ("`c(hostname)'" == "FP1376CD") global dirgit  "T:\CommerceVA\GIT\commerce_va_inflation" 

*capture log close
*log using "$dir/$S_DATE.log", replace


do  "$dirgit/Definition_pays_secteur.do" `source'

global eurozone "AUT BEL CYP DEU ESP EST FIN FRA GRC IRL ITA LTU LUX LVA MLT NLD PRT SVK SVN"



	


capture program drop etude
program etude
args year source type

**Exemple : etude 2011 WIOD HC
**Exemple : etude 2011 WIOD par_sect
	


use "$dir/Results/Devaluations/auto_chocs_`type'_`source'_`year'.dta", clear

*replace c =c+"_EUR" if source_shock=="EUR" 



capture gen pays=upper(c)
replace pays=upper(pays)
if "`type'"=="par_sect" rename s sector
if "`type'"=="par_sect" replace sector=upper(sector)


if "`type'"=="HC" | "`type'" =="HC_note" {
	merge 1:1 pays using "$dir/Bases/imp_inputs_HC_`year'_`source'_hze_not.dta"
	
	drop _merge
	
	replace pays =upper(pays) 
	merge 1:1 pays using "$dir/Bases/contenu_dom_HC_impt_`year'_`source'_hze_not.dta"
	
	drop _merge
	replace pays =upper(pays)

	replace pays =pays+"_AUTO"
	replace pays = substr(pays,1,3) if strmatch(pays,"*_EUR_AUTO")==1
	
	merge 1:1 pays using "$dir/Bases/imp_inputs_HC_`year'_`source'_hze_yes.dta", update
	drop _merge
	
	replace pays =upper(pays) 
	merge 1:1 pays using "$dir/Bases/contenu_dom_HC_impt_`year'_`source'_hze_yes.dta", update 
	
	*replace pays =lower(pays) 
	drop _merge
	replace pays = pays+"_EUR" if strlen(pays)==3
	replace pays =substr(pays,1,3) if strmatch(pays,"*_AUTO")==1
	
	merge 1:1 pays using "$dir/Bases/contenu_impHC_`source'_`year'.dta"
	drop if _merge ==1
	drop _merge year
	*replace ratio_ci_impt_HC = ratio_ci_impt_HC*(1-contenu_impHC) + contenu_impHC - contenu_dom_HC_etranger
	

}



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


*drop if c=="CHN"
*hze_not : on considère les autres pays de la ZE comme étrangers (contraire de hze_yes)

*effet direct repondéré par le choc: le choc correspond à une appréciation de 100% 
*=>on double l'impact pour comparer le ratio de CI importées (comptable) à l'effet direct choqué
if "`type'"=="HC" | "`type'" =="HC_note" {
	gen E1HC = contenu_impHC/2
	gen E2HC = (ratio_ci_impt_HC)*(1-contenu_impHC)/2
	gen E3HC = - contenu_dom_HC_etranger
}

gen E1HC_E2HC=E1HC + E2HC
label var pond_`source'_`type' "Élasticité des prix (`type') en monnaie nationale à un choc de la monnaie nationale

save "$dir/Results/Étude rapport D+I et Bouclage Mondial/Elast_par_pays_`year'_`source'_`type'.dta", replace
	
*****Graphique comparant l'élasticité avec E1HC + E2HC
if "`type'"=="HC" & ((`year'==2014 & "`source'"=="WIOD") | (`year'==2015 & "`source'"=="TIVA_REV4") | ("`source'"=="TIVA"  & `year'==2011)) {


	replace pond_`source'_`type'=-pond_`source'_`type'
	
/*	replace pays="" if c!="FRA_EUR" & c!="DEU_EUR" & c!="LUX_EUR" & c!="FRA" & c!="DEU" & c!="LUX" ///
					& c!="CAN" & c!="JPN" & c!="USA" & c!="CHN" */
					
	gen sample=1
	Definition_pays_secteur `source'
	replace sample=0 if strpos("$eurozone",pays)!=0
	/*Vieux graphique
	graph twoway (scatter pond_`source'_`type' E1HC_E2HC, mlabel(pays) mlabsize(medium)) ///
			(lfit pond_`source'_`type' E1HC_E2HC) ///
			(lfit pond_`source'_`type' pond_`source'_`type',lwidth(vthin) color(black)) , ///
			/*title("Comparing direct and modelled effects")*/ ///
			xtitle("E1HC + E2HC") ytitle("`source' Elasticities `year'") ///
			yscale(range(0.0 0.3)) xscale(range(0.0 0.3)) xlabel (0.0(0.05) 0.3) ylabel(0.0(0.05) 0.3) ///
			legend(off) ///
			scheme(s1mono)
	*dans le cas HC, xtitle pourrait se finir par «importées dans la conso dom + part conso importée»	
	
						
	graph export "$dir/Results/Étude rapport D+I et Bouclage Mondial/Comp_s_E1HCE2HC_`year'_`source'_`type'.png", replace
	graph export "$dirgit/Paper and Online Appendix/Comp_s_E1HCE2HC_`year'_`source'_`type'.png", replace
*/
	
*****new graph

	local range=0.22
	if "`source'"=="TIVA" local range=0.3
	graph twoway (scatter pond_`source'_`type' E1HC_E2HC if sample==1, /*mlabel(pays)*/ mlabsize(medium)) ///
			(lfit pond_`source'_`type' E1HC_E2HC if sample==1) ///
			(lfit E1HC_E2HC E1HC_E2HC if E1HC_E2HC<=`range',lwidth(vthin) color(black)) , ///
			/*title("Comparing direct and modelled effects")*/ ///
			xtitle("E1.HC + E2.HC : Direct effect through imported consumption goods" "and effect on domestic consumption goods through imported inputs") ytitle("`source' Elasticities `year'") ///
			yscale(range(0.0 `range')) xscale(range(0.0 `range')) xlabel (0.0(0.05) `range') ylabel(0.0(0.05) `range') ///
			legend(off) ///
			note("The 45° line serves as a comparison to the regression line") ///
			scheme(s1mono)
	*dans le cas HC, xtitle pourrait se finir par «importées dans la conso dom + part conso importée»
						
	graph export "$dir/Results/Étude rapport D+I et Bouclage Mondial/Comp_s_E1HCE2HC_`year'_`source'_`type'.png", replace
	graph export "$dirgit/Paper and Online Appendix/Comp_s_E1HCE2HC_`year'_`source'_`type'.png", replace
	
	
	drop sample
	graph close
	
	replace pond_`source'_`type'=-pond_`source'_`type'
}



*****Graphique comparant l'élasticité avec E1HC
if "`type'"=="HC" & ((`year'==2014 & "`source'"=="WIOD") | (`year'==2015 & "`source'"=="TIVA_REV4") | ("`source'"=="TIVA"  & `year'==2011)) {


	replace pond_`source'_`type'=-pond_`source'_`type'

/*VIEUX GRAPH	
	graph twoway (scatter pond_`source'_`type' E1HC, mlabel(pays) mlabsize(medium)) ///
			(lfit pond_`source'_`type' E1HC) ///
			(lfit pond_`source'_`type' pond_`source'_`type',lwidth(vthin) color(black)) , ///
			/*title("Comparing direct and modelled effects")*/ ///
			xtitle("Share of imported goods and services in household consumption") ytitle("`source' Elasticities `year'") ///
			yscale(range(0.0 0.3)) xscale(range(0.0 0.3)) xlabel (0.0(0.05) 0.3) ylabel(0.0(0.05) 0.3) ///
			legend(off) ///
			scheme(s1mono)
	*dans le cas HC, xtitle pourrait se finir par «importées dans la conso dom + part conso importée»	
	
						
	graph export "$dir/Results/Étude rapport D+I et Bouclage Mondial/Comp_s_E1HC_`year'_`source'_`type'.png", replace
	graph export "$dirgit/Paper and Online Appendix/Comp_s_E1HC_`year'_`source'_`type'.png", replace
	
*/

	gen sample=1
	Definition_pays_secteur `source'
	replace sample=0 if strpos("$eurozone",pays)!=0
	

	/*replace pays="" /*if c!="FRA_EUR" & c!="DEU_EUR" & c!="LUX_EUR" & c!="FRA" & c!="DEU" & c!="LUX" ///
					& c!="CAN" & c!="JPN" & c!="USA" & c!="CHN" */
					*/
	
	graph twoway (scatter pond_`source'_`type' E1HC if sample==1, /*mlabel(pays)*/ mlabsize(medium)) ///
			(lfit pond_`source'_`type' E1HC if sample==1) ///
			(lfit E1HC E1HC if E1HC <=0.3,lwidth(vthin) color(black)) , ///
			/*title("Comparing direct and modelled effects")*/ ///
			xtitle("Share of imported goods and services in household consumption") ytitle("`source' Elasticities `year'") ///
			yscale(range(0.0 0.22)) xscale(range(0.0 0.22)) xlabel (0.0(0.05) 0.22) ylabel(0.0(0.05) 0.22) ///
			legend(off) ///
			scheme(s1mono) ///
			note("The 45° line serves as a comparison to the regression line")
	*dans le cas HC, xtitle pourrait se finir par «importées dans la conso dom + part conso importée»	
	
						
	graph export "$dir/Results/Étude rapport D+I et Bouclage Mondial/Comp_s_E1HC_`year'_`source'_`type'.png", replace
	graph export "$dirgit/Paper and Online Appendix/Comp_s_E1HC_`year'_`source'_`type'.png", replace

	drop sample
	graph close
	
	
	replace pond_`source'_`type'=-pond_`source'_`type'
}






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
	drop sample
}


if "`type'" == "HC" {

	replace pond_`source'_`type'=-pond_`source'_`type'
	foreach reg in reg_ns reg_sep  {
		
		capture drop sample
		gen sample=1
		Definition_pays_secteur `source'
		replace sample=0 if strpos("$eurozone",pays)!=0

		if "`reg'"=="reg_sep" reg pond_`source'_HC E1HC E2HC E3HC if sample==1
		if "`reg'"=="reg_ns" reg pond_`source'_HC E1HC_E2HC if sample ==1
		
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
			gen b_E3HC=_b[E3HC]
			gen se_cst=_se[_cons]
			gen se_E1HC=_se[E1HC]
			gen se_E2HC=_se[E2HC]
			gen se_E3HC=_se[E3HC]
			gen b_cst_reg_sep=_b[_cons]
			gen se_cst_reg_sep =_se[_cons] 
		}
		drop sample
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
		save "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_`year'_`source'_`type'_`reg'.dta", replace 
		if "`reg'"=="reg_sep" {
			merge 1:1 year source using ///
			"$dir/Results/Étude rapport D+I et Bouclage Mondial/results_`year'_`source'_`type'_reg_ns.dta"
			assert _merge==3
			drop _merge
			save "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_`year'_`source'_`type'.dta", replace 
		
			if `year'!=$start_year {
				append using "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_`source'_`type'.dta"
			}

			save "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_`source'_`type'.dta", replace
		}
		restore

	
	}

}
*/


end 


****************************************************************************

*foreach source in  WIOD {
foreach source in   TIVA WIOD TIVA_REV4     {



	if "`source'"=="WIOD" global start_year 2000	
	if "`source'"=="TIVA" global start_year 1995
	if "`source'"=="TIVA_REV4" global start_year 2005



	if "`source'"=="WIOD" global end_year 2014
	if "`source'"=="TIVA" global end_year 2011
	if "`source'"=="TIVA_REV4" global end_year 2015
	
	
   capture erase "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_`source'_`type'.dta" 
	foreach type in  HC  /*HC_note par_sect*/ {
		capture erase "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_`source'_`type'.dta"

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



foreach source in WIOD TIVA TIVA_REV4 {
	use "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_`source'_HC.dta", clear
	foreach var in ns cst_reg_ns {
		gen borne_inf_`var'= b_`var'-1.96*se_`var'
		gen borne_sup_`var' =b_`var'+1.96*se_`var'
	}
	label var b_ns "{&beta} (with 95% confidence intervals)"
	label var R2_reg_ns "R2"
	
	graph twoway ///
		(line b_ns year, lcolor(black) ) (line borne_inf_ns year, lpattern(dash) lwidth(vthin) lcolor(black)) ///
		(line borne_sup_ns year, lpattern(dash) lwidth(vthin) lcolor(black) ) ///
		(connected R2_reg_ns year,  lcolor(turquoise) msize(small) mcolor(turquoise))   ///
		,/*yscale(range(1 (0.05) 1.15)) ylabel(1 (0.05) 1.15)*/ legend(order (1 4) rows(2)) ///
		scheme(s1color) name(coef_E_`source'_HC, replace)

*	graph export "$dir/Results/Étude rapport D+I et Bouclage Mondial/coef_E_`source'_HC.png", replace
*	graph export "$dirgit/Rédaction/coef_E_`source'_HC.png", replace
	
	
	label var b_cst_reg_ns "{&alpha} (with 95% confidence intervals)"
		graph twoway ///
		(line b_cst_reg_ns year, lcolor(black) ) (line borne_inf_cst_reg_ns year, lpattern(dash) lwidth(vthin) lcolor(black)) (line borne_sup_cst_reg_ns year,lpattern(dash) lwidth(vthin) lcolor(black) )    ///
		,/*yscale(range(1 (0.05) 1.15)) ylabel(1 (0.05) 1.15)*/ legend(order (1)) ///
		scheme(s1color) name(coef_cst_`source'_HC, replace)

*	graph export "$dir/Results/Étude rapport D+I et Bouclage Mondial/coef_cst_`source'_HC.png", replace
*	graph export "$dirgit/Rédaction/coef_cst_`source'_HC.png", replace
	
	graph combine  coef_cst_`source'_HC coef_E_`source'_HC, scheme(s1mono)
	graph export "$dir/Results/Étude rapport D+I et Bouclage Mondial/coef_`source'_HC.png", replace
	graph export "$dirgit/Rédaction/coef_`source'_HC.png", replace
	
	

}

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
			gen mylabel= pays if strpos("FRA DEU DEU_EUR ITA ITA_EUR GBR CHN USA CAN JPN ",pays)!=0
			
	/*OLD GRAPH
			foreach var in E1HC E2HC E3HC E4HC {
				gen share_`var'=`var'/pond_WIOD_HC
				twoway histogram share_`var', start(-0.2) width(0.1) freq name(`var') || ///
					scatter blouf share_`var' if mylabel!="", /// 
					xscale(range(-0.1 (0.1) 0.8)) xlabel(-0.1 (0.1) 0.8) ///
					mlabel(mylabel) mlabposition(12)  mlabangle(vertical)  mlabgap(huge) mlabsize(vsmall) msymbol(pipe) ///
					legend(order (1) label (1 "Number of countries in each bin") ) ///
					scheme(s1mono)
			}
		grc1leg2 	E1HC E2HC E3HC E4HC, name(hist_components_`source'_`i') scheme(s1mono) legendfrom(E1HC)
		graph export "$dir/Results/Étude rapport D+I et Bouclage Mondial/hist_components_`source'_`i'.png", replace
	*/
			
******* New graph
			
	sort E1HC
	gen E1_order = _n
	labmask E1_order,values(pays)
	
	gen sample=1
	Definition_pays_secteur `source'
	replace sample=0 if strpos("$eurozone",pays)!=0
	
	graph dot (asis) E1HC E2HC E3HC E4HC if sample==1,  over(E1_order, ///
		label(labsize(tiny))) ///
		marker(1, ms(O) mfcolor(gs1) mlcolor(gs1) msize(tiny) ) ///
		marker(2, ms(+) mfcolor(gs5) mlcolor(gs5) msize(small) ) ///
		marker(3, ms(O) mfcolor(gs9) mlcolor(gs9) msize(tiny) ) ///
		marker(4, ms(O) mfcolor(gs13) mlcolor(gs13) msize(small)) ///
		xsize(9)  ysize(7) ///
		name(distr_components_`source'_`i', replace) ///
		legend(position(3) cols(1)  size(vsmall) label(1 "E1.HC: Direct effect" "through imported" "consumption goods") ///
		label(2 "E2.HC: Effect on domestic" "consumption goods" "through imported inputs") ///
		label(3 "E3.HC: Effect on imported" "consumption goods" "through domestic inputs") ///
		label(4 "E4.HC: Residual")) ///
		scheme(s1mono)
		
		graph export "$dir/Results/Étude rapport D+I et Bouclage Mondial/distribution_components_`source'_`i'.png", replace	
		if "`source'"=="WIOD" & `i'==2014 graph export "$dirgit/Rédaction/distribution_components_`source'_`i'.png", replace	
		
		gen share_IO_mech = (E4HC+E3HC+E2HC)/pond_`source'_HC
		gen share_IOT     = (E4HC+E3HC)/pond_`source'_HC
		format share* %9.2f
		gsort - share_IO_mech
		list pays share_*
		
		gen share_IO_order = _n
		labmask share_IO_order,values(pays)
		
		graph dot (asis) share_IO_mech share_IOT if sample==1,  over(share_IO_order, ///
			label(labsize(tiny))) ///
			marker(1, ms(O) mfcolor(gs1) mlcolor(gs1) msize(tiny) ) ///
			marker(2, ms(O) mfcolor(gs13) mlcolor(gs13) msize(small) ) ///
			xsize(9)  ysize(7) ///
			name(share_components_`source'_`i', replace) ///
			legend(position(3) cols(1)  size(vsmall) label(1 "Share of total effect" "going through" "Input-Output mechanisms" "(E2.HC+E3.HC+E4.HC)/Total") ///
			label(2 "Share of total effect" "requiring WIOT" "for computation" "(E3.HC+E4.HC)/Total")) ///
			scheme(s1mono)
		
		graph export "$dir/Results/Étude rapport D+I et Bouclage Mondial/share_components_`source'_`i'.png", replace	
		if "`source'"=="WIOD" & `i'==2014 graph export "$dirgit/Rédaction/share_components_`source'_`i'.png", replace	
		drop sample
				
		}
	
	
	
}

*graph export "$dir/commerce_VA_inflation/Rédaction/hist_components_WIOD_2014.png", replace




