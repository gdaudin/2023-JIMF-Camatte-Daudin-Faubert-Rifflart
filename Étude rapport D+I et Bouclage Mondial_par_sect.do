* à partir des outputs de Etude D+I bouclage mondial, on effectue des régressions secteur par secteur  a
clear  
set more off
global dir "H:\My Documents\OFCE_CommerceVA-develop\OFCE_CommerceVA-develop" 
 if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA" 
if ("`c(username)'"=="n818881") global dir "\\intra\partages\au_dcpm\DiagConj\Commun\CommerceVA" 


*capture log close
*log using "$dir/$S_DATE.log", replace

 *regression secteur par secteur
foreach source in   WIOD { 

	*if ("`c(username)'"=="guillaumedaudin") do  "~/Documents/Recherche/2017 BDF_Commerce VA/commerce_VA_inflation/Definition_pays_secteur.do" `source'
	*if ("`c(username)'"=="VIOLAINE")
	do "$dir\Definition_pays_secteur.do" `source'
	*if ("`c(username)'"=="n818881") do  "X:\Agents\LALLIARD\commerce_VA_inflation\Definition_pays_secteur.do" `source'

	if "`source'"=="WIOD" local start_year 2014
	*if "`source'"=="TIVA" local start_year 1995


	if "`source'"=="WIOD" local end_year 2014
	*if "`source'"=="TIVA" local end_year 2011
	

	global sec  = strlower("$sector")

		foreach i in $sec {
		

		


 *foreach year in 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 {
			foreach year of numlist `start_year' (1)`end_year'  {
	use "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_`year'_`source'_par_sect.dta", clear
   *effet direct repondéré par le choc: le choc correspond à une appréciation de 100% 
*=>on double l'impact pour comparer le ratio de CI importées (comptable, sans doubler) à l'effet direct choqué (effet d'un doublement des prix de CI)
			*gen choc_dplusi_par_sect=ratio_ci_impt_par_sect/2
*use "C:/Users/Violaine/Documents/CommerceVA/Results/BouclageMondial/stata13/results_2014_WIOD_par_sect.dta", clear
			replace pays = strupper(pays)
			*drop if sector=="t"
			
			keep if pays=="AUS" |pays=="AUT_EUR" |pays=="BEL_EUR" |pays=="BGR" |pays=="BRA" |pays=="CAN" |pays=="CHE" |pays=="CHN" |pays=="CYP_EUR" |pays=="CZE " |pays=="DEU_EUR" |pays=="DNK" |pays=="ESP_EUR" |pays=="EST_EUR" |pays=="FIN_EUR" |pays=="FRA_EUR" |pays=="GBR" |pays=="GRC_EUR" |pays=="HRV" |pays=="HUN" |pays=="IDN" |pays=="IND" |pays=="IRL_EUR" |pays=="ITA_EUR" |pays=="JPN" |pays=="KOR" |pays=="LTU_EUR" |pays=="LUX_EUR" |pays=="LVA_EUR " |pays=="MEX" |pays=="MLT_EUR" |pays=="NLD_EUR" |pays=="NOR" |pays=="POL" |pays=="PRT_EUR" |pays=="ROU" |pays=="RUS" |pays=="SVK_EUR" |pays=="SVN_EUR" |pays=="SWE" |pays=="TUR" |pays=="TWN" |pays=="USA"
		
			keep pays sector  ratio_ci_impt_par_sect  pond_WIOD_par_sect choc_dplusi_par_sect agregat_secteur 
			
			keep if sector=="`i'"
			*if c=="`country_eur'" 
			

			reg pond_WIOD_par_sect choc_dplusi_par_sect   
			gen R2=e(r2)

			matrix COEF = e(b)
			gen cst=COEF[1,2]
			gen b=COEF[1,1]
			gen year=`year'
			gen source="`source'"
			predict predict
			*valuesof pays if abs(ln(predict/pond_WIOD_par_sect)) > 0.35
			gen predict_hors_0_0_35 = "`r(values)'"
			*valuesof pays if choc_dplusi_par_sect >= pond_WIOD_par_sect
			gen D_I_trop_grand = "`r(values)'"
			corr pond_WIOD_par_sect choc_dplusi_par_sect
			gen corr = r(rho)

			save "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_`year'_`source'_`i'.dta", replace 
			keep if pays=="AUS" |pays=="AUT_EUR" |pays=="BEL_EUR" |pays=="BGR" |pays=="BRA" |pays=="CAN" |pays=="CHE" |pays=="CHN" |pays=="CYP_EUR" |pays=="CZE " |pays=="DEU_EUR" |pays=="DNK" |pays=="ESP_EUR" |pays=="EST_EUR" |pays=="FIN_EUR" |pays=="FRA_EUR" |pays=="GBR" |pays=="GRC_EUR" |pays=="HRV" |pays=="HUN" |pays=="IDN" |pays=="IND" |pays=="IRL_EUR" |pays=="ITA_EUR" |pays=="JPN" |pays=="KOR" |pays=="LTU_EUR" |pays=="LUX_EUR" |pays=="LVA_EUR " |pays=="MEX" |pays=="MLT_EUR" |pays=="NLD_EUR" |pays=="NOR" |pays=="POL" |pays=="PRT_EUR" |pays=="ROU" |pays=="RUS" |pays=="SVK_EUR" |pays=="SVN_EUR" |pays=="SWE" |pays=="TUR" |pays=="TWN" |pays=="USA"
			
			*save "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_`year'_`source'_reg_sec.dta" , replace
			*capture append using "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_`year'_`source'_reg_sec.dta"
			*keep if pays=="AUS" |pays=="AUT_EUR" |pays=="BEL_EUR" |pays=="BGR" |pays=="BRA" |pays=="CAN" |pays=="CHE" |pays=="CHN" |pays=="CYP_EUR" |pays=="CZE " |pays=="DEU_EUR" |pays=="DNK" |pays=="ESP_EUR" |pays=="EST_EUR" |pays=="FIN_EUR" |pays=="FRA_EUR" |pays=="GBR" |pays=="GRC_EUR" |pays=="HRV" |pays=="HUN" |pays=="IDN" |pays=="IND" |pays=="IRL_EUR" |pays=="ITA_EUR" |pays=="JPN" |pays=="KOR" |pays=="LTU_EUR" |pays=="LUX_EUR" |pays=="LVA_EUR " |pays=="MEX" |pays=="MLT_EUR" |pays=="NLD_EUR" |pays=="NOR" |pays=="POL" |pays=="PRT_EUR" |pays=="ROU" |pays=="RUS" |pays=="SVK_EUR" |pays=="SVN_EUR" |pays=="SWE" |pays=="TUR" |pays=="TWN" |pays=="USA"
		
			*save "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_`year'_`source'_reg_sec.dta" , replace
			
				
	}			
}
}

foreach source in WIOD  { 
 *création d'une base de données avec le résultat des régressions sur tous les secteurs  
		if "`source'"=="WIOD" local start_year 2014
		if "`source'"=="TIVA" local start_year 1995


		if "`source'"=="WIOD" local end_year 2014
		if "`source'"=="TIVA" local end_year 2011
	
 
		foreach year of numlist `start_year' (1)`end_year'  {
			capture erase "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_`year'_`source'_reg_sec_all.dta"
			foreach i in  $sec {
			drop if sector=="t"
			use "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_`year'_`source'_`i'.dta", clear
			keep pays b sector  ratio_ci_impt_par_sect  pond_`source'_par_sect R2 cst year source agregat_secteur
			keep if pays=="AUS" |pays=="AUT_EUR" |pays=="BEL_EUR" |pays=="BGR" |pays=="BRA" |pays=="CAN" |pays=="CHE" |pays=="CHN" |pays=="CYP_EUR" |pays=="CZE " |pays=="DEU_EUR" |pays=="DNK" |pays=="ESP_EUR" |pays=="EST_EUR" |pays=="FIN_EUR" |pays=="FRA_EUR" |pays=="GBR" |pays=="GRC_EUR" |pays=="HRV" |pays=="HUN" |pays=="IDN" |pays=="IND" |pays=="IRL_EUR" |pays=="ITA_EUR" |pays=="JPN" |pays=="KOR" |pays=="LTU_EUR" |pays=="LUX_EUR" |pays=="LVA_EUR " |pays=="MEX" |pays=="MLT_EUR" |pays=="NLD_EUR" |pays=="NOR" |pays=="POL" |pays=="PRT_EUR" |pays=="ROU" |pays=="RUS" |pays=="SVK_EUR" |pays=="SVN_EUR" |pays=="SWE" |pays=="TUR" |pays=="TWN" |pays=="USA"
		
			capture append using "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_`year'_`source'_reg_sec_all.dta"
			sort  b sector
		*keep if pays=="AUS" |pays=="AUT_EUR" |pays=="BEL_EUR" |pays=="BGR" |pays=="BRA" |pays=="CAN" |pays=="CHE" |pays=="CHN" |pays=="CYP_EUR" |pays=="CZE " |pays=="DEU_EUR" |pays=="DNK" |pays=="ESP_EUR" |pays=="EST_EUR" |pays=="FIN_EUR" |pays=="FRA_EUR" |pays=="GBR" |pays=="GRC_EUR" |pays=="HRV" |pays=="HUN" |pays=="IDN" |pays=="IND" |pays=="IRL_EUR" |pays=="ITA_EUR" |pays=="JPN" |pays=="KOR" |pays=="LTU_EUR" |pays=="LUX_EUR" |pays=="LVA_EUR " |pays=="MEX" |pays=="MLT_EUR" |pays=="NLD_EUR" |pays=="NOR" |pays=="POL" |pays=="PRT_EUR" |pays=="ROU" |pays=="RUS" |pays=="SVK_EUR" |pays=="SVN_EUR" |pays=="SWE" |pays=="TUR" |pays=="TWN" |pays=="USA"
		
			save "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_`year'_`source'_reg_sec_all.dta", replace
 }
   }
   } 
 
 **Graphiques
  

************************************************************
*GRAPHIQUE RESULTATS DES REGRESSIONS  SECTORIELLES pond_hc=b*ratio_ci_impt_HC+constante

************graphiques pour WIOD

use "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_2014_WIOD_reg_sec_all.dta", clear

*set scheme economist

keep if pays=="AUS" |pays=="AUT_EUR" |pays=="BEL_EUR" |pays=="BGR" |pays=="BRA" |pays=="CAN" |pays=="CHE" |pays=="CHN" |pays=="CYP_EUR" |pays=="CZE " |pays=="DEU_EUR" |pays=="DNK" |pays=="ESP_EUR" |pays=="EST_EUR" |pays=="FIN_EUR" |pays=="FRA_EUR" |pays=="GBR" |pays=="GRC_EUR" |pays=="HRV" |pays=="HUN" |pays=="IDN" |pays=="IND" |pays=="IRL_EUR" |pays=="ITA_EUR" |pays=="JPN" |pays=="KOR" |pays=="LTU_EUR" |pays=="LUX_EUR" |pays=="LVA_EUR " |pays=="MEX" |pays=="MLT_EUR" |pays=="NLD_EUR" |pays=="NOR" |pays=="POL" |pays=="PRT_EUR" |pays=="ROU" |pays=="RUS" |pays=="SVK_EUR" |pays=="SVN_EUR" |pays=="SWE" |pays=="TUR" |pays=="TWN" |pays=="USA"
keep if pays=="DEU_EUR"		
drop if agregat_secteur=="services"
graph bar (asis) R2 ,  title("R2-Sectoral regressions, WIOD 2014") over(sector, sort(R2) label(angle(vertical) labsize(small))) 
graph export "$dir/Results/Étude rapport D+I et Bouclage Mondial/Graph_R2_2014_WIOD_reg_sec.png", replace


use "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_2014_WIOD_reg_sec_all.dta", clear


keep if pays=="AUS" |pays=="AUT_EUR" |pays=="BEL_EUR" |pays=="BGR" |pays=="BRA" |pays=="CAN" |pays=="CHE" |pays=="CHN" |pays=="CYP_EUR" |pays=="CZE " |pays=="DEU_EUR" |pays=="DNK" |pays=="ESP_EUR" |pays=="EST_EUR" |pays=="FIN_EUR" |pays=="FRA_EUR" |pays=="GBR" |pays=="GRC_EUR" |pays=="HRV" |pays=="HUN" |pays=="IDN" |pays=="IND" |pays=="IRL_EUR" |pays=="ITA_EUR" |pays=="JPN" |pays=="KOR" |pays=="LTU_EUR" |pays=="LUX_EUR" |pays=="LVA_EUR " |pays=="MEX" |pays=="MLT_EUR" |pays=="NLD_EUR" |pays=="NOR" |pays=="POL" |pays=="PRT_EUR" |pays=="ROU" |pays=="RUS" |pays=="SVK_EUR" |pays=="SVN_EUR" |pays=="SWE" |pays=="TUR" |pays=="TWN" |pays=="USA"
keep if pays=="DEU_EUR"		
drop if agregat_secteur=="services"
graph bar (asis) cst ,  title("Intercept-Sectoral regressions sectorielles, WIOD 2014") over(sector, sort(cst) label(angle(vertical) labsize(small))) 
graph export "$dir/Results/Étude rapport D+I et Bouclage Mondial/Graph_cst_2014_WIOD_reg_sec.png", replace

use "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_2014_WIOD_reg_sec_all.dta", clear



keep if pays=="AUS" |pays=="AUT_EUR" |pays=="BEL_EUR" |pays=="BGR" |pays=="BRA" |pays=="CAN" |pays=="CHE" |pays=="CHN" |pays=="CYP_EUR" |pays=="CZE " |pays=="DEU_EUR" |pays=="DNK" |pays=="ESP_EUR" |pays=="EST_EUR" |pays=="FIN_EUR" |pays=="FRA_EUR" |pays=="GBR" |pays=="GRC_EUR" |pays=="HRV" |pays=="HUN" |pays=="IDN" |pays=="IND" |pays=="IRL_EUR" |pays=="ITA_EUR" |pays=="JPN" |pays=="KOR" |pays=="LTU_EUR" |pays=="LUX_EUR" |pays=="LVA_EUR " |pays=="MEX" |pays=="MLT_EUR" |pays=="NLD_EUR" |pays=="NOR" |pays=="POL" |pays=="PRT_EUR" |pays=="ROU" |pays=="RUS" |pays=="SVK_EUR" |pays=="SVN_EUR" |pays=="SWE" |pays=="TUR" |pays=="TWN" |pays=="USA"
keep if pays=="DEU_EUR"		
drop if agregat_secteur=="services"
graph bar (asis) b,  title("Beta-Sectoral regressions, WIOD 2014") over(sector, sort(b) label(angle(vertical) labsize(small))) 
graph export "$dir/Results/Étude rapport D+I et Bouclage Mondial/Graph_beta_2014_WIOD_reg_sec.png", replace

 

