clear  
set more off
if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA"
else global dir "\\intra\partages\au_dcpm\DiagConj\Commun\CommerceVA"


*capture log close
*log using "$dir/$S_DATE.log", replace


if ("`c(username)'"=="guillaumedaudin") do  "~/Documents/Recherche/2017 BDF_Commerce VA/commerce_VA_inflation/Definition_pays_secteur.do" `source'
if ("`c(username)'"=="w817186") do "X:\Agents\FAUBERT\commerce_VA_inflation\Definition_pays_secteur.do" `source'
if ("`c(username)'"=="n818881") do  "X:\Agents\LALLIARD\commerce_VA_inflation\Definition_pays_secteur.do" `source'

*création d'une base de données avec toutes les années en vue de la réalisation du pannel	
capture erase "$dir/Results/Étude rapport D+I et Bouclage Mondial/base_regressions_pays.dta"
foreach i in 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 {
use "$dir/Results/Étude rapport D+I et Bouclage Mondial/results_`i'_WIOD.dta", clear 
keep c year pays ratio_ci_impt_HC pond_WIOD_HC
capture append using "$dir/Results/Étude rapport D+I et Bouclage Mondial/base_regressions_pays.dta"
sort c year
save "$dir/Results/Étude rapport D+I et Bouclage Mondial/base_regressions_pays.dta", replace
}


encode pays, gen(payspanel)
* déclaration des pays comme entité géographique et des années pour configure les données en pannel
xtset payspanel year
xtreg pond_WIOD_HC ratio_ci_impt_HC	 if strpos("$eurozone",c)==0, fe   // Fixed-effects
estimates store fixed
xtreg pond_WIOD_HC ratio_ci_impt_HC if strpos("$eurozone",c)==0, re  // Random-effects 
estimates store random
// Hausman Test
hausman fixed random















