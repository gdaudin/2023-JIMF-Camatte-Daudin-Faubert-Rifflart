*Pour le calcul des consommations intermédiaires domestique dans la HC importée

clear
set more off
if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA"
else global dir "\\intra\partages\au_dcpm\DiagConj\Commun\CommerceVA"



capture log close
log using "$dir/$S_DATE.log", replace
set matsize 7000



capture program drop contenu_dom_HC_impt // fournit le % des ci dom dans la HC impt
program  contenu_dom_HC_impt
args yrs source hze pays_int
*Année, source, hze_not ou hze_yes pour pays membres de la ZE et pays hors ZE, pays_int celui auquel on s'intéresse

* exemple  

*Ouverture de la base contenant le vecteur ligne de production par pays et secteurs

use "$dir/Bases/`source'_ICIO_`yrs'.dta"
if "`source'"=="TIVA" {
	drop if v1 == "VA+TAXSUB" | v1 == "OUT"
	gen pays=lower(substr(v1,1,3))
	gen secteur = lower(substr(v1,5,.))
	order pays secteur
}


* on conserve uniquement les CI, en éliminants les emplois finals
if "`source'"=="WIOD" {
	 
	drop *57 *58 *59 *60 *61
	rename Country pays
	rename IndustryCode secteur
	order pays secteur
	sort pays secteur
	drop if pays=="TOT"
	* on supprime les lignes total intermediate conso à GO de la base wiod_icio
}


keep pays $var_entree_sortie




** Ici, on fait Y.Btilde



foreach var of varlist $var_entree_sortie {
*	On cherche à enlever les auto-consommations intermédiaires
	if "`source'" == "TIVA" local pays_colonne = substr("`var'",1,3)
	if "`source'" == "WIOD" local pays_colonne = substr("`var'",2,3)
	
	replace `var' = 0 if pays=="`pays_colonne'"	
	if strpos(lower("$china"),lower("`pays_colonne'"))!=0  {
			foreach i of global china {	
			replace `var' = 0 if lower(pays) == lower("`i'")
		}
	}
	if strpos(lower("$mexique"),lower("`pays_colonne'"))!=0 {
			foreach i of global mexique {	
			replace `var' = 0 if lower(pays) == lower("`i'")
		}
	}
		

	*** Puis on enlève les CI qui ne viennent pas du pays d'intérêt
	
	replace `var' = 0 if lower(pays)!=lower("`pays_int'") 
		
	display "`hze' -- `pays_colonne'" 
	
}




*somme des CI pour chaque secteur de chaque pays
collapse (sum) $var_entree_sortie

display "after collapse"


*obtention de deux lignes, l'une de CI, l'autre de prod pour chaque secteur, issue de la base  `source'_`yrs'_OUT
append using "$dir/Bases/`source'_`yrs'_OUT.dta"

*transpositin en colonne, puis création d'un ratio de CI importées par secteur 
xpose, clear varname
rename v1 ci_dom
rename v2 prod_etranger
generate ratio_ci_dom_prod_etranger=ci_dom / prod_etranger




/*
if "`source'"=="TIVA" {
	generate pays = strlower(substr(_varname,1,3))
	generate sector = strlower(substr(_varname,strpos(_varname,"_")+1,.))
}


*renomme les pays et secteur à partir de la base csv_WIOD
if "`source'"=="WIOD" {
*/


merge 1:1 _n using "$dir/Bases/csv_`source'.dta"
rename c pays
rename s sector
replace sector = lower(sector)
replace pays=upper(pays)
drop p_shock
drop _merge




generate pays_conso = lower("`pays_int'")
generate year= `yrs'
if "`source'"=="TIVA" replace pays =lower(pays)


merge 1:1 pays sector year pays_conso using "$dir/Bases/HC_`source'.dta", keep (1 3)

assert _merge==3
drop _merge


gen contenu_dom_HC_etranger=conso*ratio_ci_dom_prod_etranger
collapse (sum) contenu_dom_HC_etranger conso, by(pays_conso year)
replace contenu_dom_HC_etranger = contenu_dom_HC_etranger/conso
rename pays_conso pays
replace pays =upper(pays)

capture append using "$dir/Bases/contenu_dom_HC_impt_`yrs'_`source'_`hze'.dta"
sort pays

save "$dir/Bases/contenu_dom_HC_impt_`yrs'_`source'_`hze'.dta", replace
* enregistrement des ratio de CI dom par secteur par pays d'interet









end





**pOUR TEST








foreach source in TIVA {
*foreach source in   WIOD  TIVA {



	if "`source'"=="WIOD" local start_year 2000
	if "`source'"=="TIVA" local start_year 1995


	if "`source'"=="WIOD" local end_year 2014
	if "`source'"=="TIVA" local end_year 2011
	
	
	if ("`c(username)'"=="guillaumedaudin") do  "~/Documents/Recherche/2017 BDF_Commerce VA/commerce_VA_inflation/Definition_pays_secteur.do" `source'
	if ("`c(username)'"=="w817186") do "X:\Agents\FAUBERT\commerce_VA_inflation\Definition_pays_secteur.do" `source'
	if ("`c(username)'"=="n818881") do  "X:\Agents\LALLIARD\commerce_VA_inflation\Definition_pays_secteur.do" `source'

	



*	foreach i of numlist 2010  {
	foreach i of numlist `start_year' (1)`end_year'  {
		capture erase "$dir/Bases/contenu_dom_HC_impt_`yrs'_`source'_hze_non.dta.dta"
		capture erase "$dir/Bases/contenu_dom_HC_impt_`yrs'_`source'_hze_yes.dta.dta"
		foreach pays of global country_hc {
			contenu_dom_HC_impt `i' `source' hze_not `pays'
			contenu_dom_HC_impt `i' `source' hze_yes `pays'
		}
	}
}
