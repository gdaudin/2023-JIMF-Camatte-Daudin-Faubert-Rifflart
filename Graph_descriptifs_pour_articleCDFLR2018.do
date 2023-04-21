clear  
set more off
if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA"
if ("`c(username)'"=="n818881") global dir "\\intra\partages\au_dcpm\DiagConj\Commun\CommerceVA"
else global dir "H:\My Documents\OFCE_CommerceVA-develop\OFCE_CommerceVA-develop"

*capture log close
*log using "$dir/$S_DATE.log", replace



if ("`c(username)'"=="guillaumedaudin") do  "~/Documents/Recherche/2017 BDF_Commerce VA/commerce_VA_inflation/Definition_pays_secteur.do" `source'
if ("`c(username)'"=="n818881") do  "X:\Agents\LALLIARD\commerce_VA_inflation\Definition_pays_secteur.do" `source'
if ("`c(username)'"=="FAUBERT VIOLAINE") do "H:\My Documents\OFCE_CommerceVA-develop\OFCE_CommerceVA-develop\Definition_pays_secteur.do" `source'


*set scheme economist


************************************************************
*GRAPHIQUE RESULTATS DES REGRESSIONS  pond_hc=b*ratio_ci_impt_HC+constante
*use "$dir/Results/Étude rapport D+I et Bouclage Mondial/results.dta", clear

************graphiques pour WIOD
use "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_WIOD_HC.dta", clear
*set scheme economist
graph bar (asis) R2 ,  title("R2, WIOD") over(year, sort(year) label(angle(vertical) labsize(small))) 
graph export "$dir/Results/Étude rapport D+I et Bouclage Mondial/Graph_R2_Wiod.png", replace

*coefficient de correlation entre le vecteur Elasticité des prix de consommation à une dévaluation et le vecteur Parts des CI importées dans la conso dom + part conso importée de tous les pays pour une année donnée
graph bar (asis) corr ,  title("Coefficient de corrélation, WIOD") over(year, sort(year) label(angle(vertical) labsize(small))) 
graph export "$dir/Results/Étude rapport D+I et Bouclage Mondial/Graph_corr_Wiod.png", replace


*coeff beta de la régression pond_wiod_hc=b*ratio_ci_impt_HC+constante
graph bar (asis) b ,  title("Coefficient de correlation de la régression, WIOD") over(year, sort(year) label(angle(vertical) labsize(small))) 
graph export "$dir/Results/Étude rapport D+I et Bouclage Mondial/Graph_beta_Wiod.png", replace

*constante de la régression
graph bar (asis) cst ,  title("Constante de la régression, WIOD") over(year, sort(year) label(angle(vertical) labsize(small))) 
graph export "$dir/Results/Étude rapport D+I et Bouclage Mondial/Graph_cst_Wiod.png", replace

*************graphiques pour TIVA
use "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_TIVA_HC.dta", clear
drop if source=="WIOD"

graph bar (asis)  R2,  title("R2, TIVA") over(year, sort(year) label(angle(vertical) labsize(small))) 
graph export "$dir/Results/Étude rapport D+I et Bouclage Mondial/Graph_R2_tiva.png", replace

graph bar (asis) corr ,  title("Coefficient de correlation, TIVA") over(year, sort(year) label(angle(vertical) labsize(small))) 
graph export "$dir/Results/Étude rapport D+I et Bouclage Mondial/Graph_corr_tiva.png", replace

graph bar (asis) b ,  title("Coefficient de correlation de la régression, TIVA") over(year, sort(year) label(angle(vertical) labsize(small))) 
graph export "$dir/Results/Étude rapport D+I et Bouclage Mondial/Graph_beta_tiva.png", replace

graph bar (asis) cst ,  title("Constante de la régression, TIVA") over(year, sort(year) label(angle(vertical) labsize(small))) 
graph export "$dir/Results/Étude rapport D+I et Bouclage Mondial/Graph_cst_Tiva.png", replace


************************************************************
*ratio CI importées + biens de conso importés sur HH consumption

foreach source in  WIOD TIVA{
use "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_2000_`source'_HC.dta", clear
keep pays  ratio_ci_impt_HC
rename ratio_ci_impt_HC ratio_ci_impt_HC_2000
save "$dir/Results/Étude rapport D+I et Bouclage Mondial/Pour_graph_ratioimp_`source'.dta", replace

use "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_2011_`source'_HC.dta", clear
rename ratio_ci_impt_HC ratio_ci_impt_HC_2011
capture drop _merge 
merge 1:1 pays using "$dir/Results/Étude rapport D+I et Bouclage Mondial/Pour_graph_ratioimp_`source'.dta"
drop _merge 

label var ratio_ci_impt_HC_2000 "2000"

label var ratio_ci_impt_HC_2011 "2011"

replace pays = upper(pays)
graph bar (asis) ratio_ci_impt_HC_2000 ratio_ci_impt_HC_2011, over(pays, sort(ratio_ci_impt_HC_2000)  label(angle(vertical) labsize(vsmall))) 
*title("Imported intermediate inputs and consumer goods to consumption") 
graph export "$dir/Results/Étude rapport D+I et Bouclage Mondial/Graph_ratioimp_`source'.png", replace
}


*WIOD 2014
use "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_2014_WIOD_HC.dta", clear
replace pays = upper(pays)
graph bar (asis) ratio_ci_impt_Hpays,  over(pays, sort(ratio_ci_impt_Hpays)  label(angle(vertical) labsize(vsmall))) 
graph export "$dir/Results/Étude rapport D+I et Bouclage Mondial/Graph_ratioimp_wiod_2014.png", replace
*title("Imported intermediate inputs and consumer goods to consumption")


*Evolution temporelle du ratio CI importées + biens de conso importés sur HH consumption en ze

foreach year of num 2000(1)2014 {

	use "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_`year'_WIOD_HC.dta", clear
	keep pays  ratio_ci_impt_HC year
	replace pays=upper(pays)
	rename ratio_ci_impt_HC ratio_ci_impt_HC_`year'
	save "$dir/Results/Étude rapport D+I et Bouclage Mondial/Pour_graph_ratioimp_WIOD_`year'_2014.dta", replace
}


use "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_2014_WIOD_HC.dta", clear
rename ratio_ci_impt_HC ratio_ci_impt_HC_2014
replace pays=upper(pays)
*keep if strpos("$eurozone",upper(pays))!=0 | strpos(pays,"_eur")!=0
capture drop _merge 

foreach year of num 2000(1)2014 {

	merge 1:1 pays using "$dir/Results/Étude rapport D+I et Bouclage Mondial/Pour_graph_ratioimp_WIOD_`year'_2014.dta"
	drop _merge 
	label var ratio_ci_impt_HC_`year' "`year'"
}


replace pays = upper(pays)
preserve
keep if strpos("$eurozone",upper(pays))!=0 | strpos(pays,"_eur")!=0
label var ratio_ci_impt_HC_2014 "2014"
graph bar (asis) ratio_ci_impt_HC_2000 ratio_ci_impt_HC_2007 ratio_ci_impt_HC_2014, over(pays, sort(year)  label(angle(vertical) labsize(vsmall))) 
*title("Imported intermediate inputs and consumer goods to consumption") 
graph export "$dir/Results/Étude rapport D+I et Bouclage Mondial/Graph_ratioimp_WIOD_2000_2014_ze.png", replace
restore


drop if strpos("$eurozone",upper(pays))!=0 | strpos(pays,"_eur")!=0
label var ratio_ci_impt_HC_2014 "2014"
graph bar (asis) ratio_ci_impt_HC_2000 ratio_ci_impt_HC_2007 ratio_ci_impt_HC_2014, over(pays, sort(year)  label(angle(vertical) labsize(vsmall))) 
*title("Imported intermediate inputs and consumer goods to consumption") 
graph export "$dir/Results/Étude rapport D+I et Bouclage Mondial/Graph_ratioimp_WIOD_2000_2014.png", replace


***********************Comparaison de l'effet expliqué par ratio_ci_impt_HC sur le total

*calcul du ratio direct/total, on sait que ce ratio est exceptionnellement >1 en Irlande en 2011 avec TiVA
/*
foreach source in   WIOD  TIVA {
	if "`source'"=="WIOD" local start_year 2000
	if "`source'"=="TIVA" local start_year 1995
	if "`source'"=="WIOD" local end_year 2014
	if "`source'"=="TIVA" local end_year 2011

	foreach i of numlist `start_year' (1)`end_year'  {
	use "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_`i'_`source'_HC.dta", clear	
 gen ratio_direct_total=ratio_ci_impt_HC/pond_`source'_HC
 save "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_`i'_`source'_HC.dta", replace		
	}
}
*/

use "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_2014_WIOD_HC.dta", clear
*keep if strpos("$eurozone",pays)!=0
drop if c=="ROW"
gen ratio_direct_total=choc_dplusi_HC/pond_WIOD_HC
replace pays = upper(pays)
graph bar (asis) ratio_direct_total, over(pays, sort(ratio_direct_total)  label(angle(vertical) labsize(vsmall))) 
*title("Imported intermediate inputs and consumer goods to consumption") 
graph export "$dir/Results/Étude rapport D+I et Bouclage Mondial/Graph_ratiodir_WIOD_2014.png", replace



*traduction en anglais du graph pente de la courbe




