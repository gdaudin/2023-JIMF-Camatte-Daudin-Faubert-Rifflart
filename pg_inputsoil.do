* Obtention de la part des CI de pétrole dans la production (Y), dans les exportations (X) et dans la consommation des ménages (HC)
* Programme construit à partir de "pg_inputsimportes.do"

clear
set more off

if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA"
if ("`c(hostname)'" == "widv270a") global dir  "D:\home\T822289\CommerceVA" 
if ("`c(hostname)'" == "FP1376CD") global dir  "T:\CommerceVA" 

if ("`c(username)'"=="guillaumedaudin") global dirgit "~/Documents/Recherche/2017 BDF_Commerce VA/commerce_VA_inflation"
if ("`c(hostname)'" == "widv270a") global dirgit  "D:\home\T822289\CommerceVA\GIT\commerce_VA_inflation" 
if ("`c(hostname)'" == "FP1376CD") global dirgit  "T:\CommerceVA\GIT\commerce_VA_inflation" 


capture log close
log using "$dir/$S_DATE.log", replace
set matsize 7000



capture program drop oil_inputs_par_sect // fournit le % des ci importées/prod par pays*sect
program oil_inputs_par_sect
args yrs source

do "$dirgit/Definition_pays_secteur.do"   
Definition_pays_secteur `source'

if "`source'"=="WIOD" local oil B
if "`source'"=="TIVA" local oil C10T14MIN
if "`source'"=="TIVA_REV4" local oil 05T06

*Ouverture de la base contenant le vecteur ligne de production par pays et secteurs

use "$dir/Bases/`source'_ICIO_`yrs'.dta"
if "`source'"=="TIVA" {
	drop if v1 == "VA+TAXSUB" | v1 == "OUT"
	gen pays=upper(substr(v1,1,3))
	gen secteur = upper(substr(v1,5,.))
	order pays secteur
}

if "`source'"=="TIVA_REV4" {
	drop if v1 == "VALU" | strmatch(v1, "*TAXSUB") == 1 | v1 == "OUTPUT"
	generate pays = strupper(substr(v1,1,strpos(v1,"_")-1))
	generate secteur = strupper(substr(v1,strpos(v1,"_")+1,.))
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


keep pays secteur $var_entree_sortie



foreach var of varlist $var_entree_sortie {

	replace `var' = 0 if secteur !="`oil'"
}


*somme des CI pour chaque secteur de chaque pays
collapse (sum) $var_entree_sortie

display "after collapse"


*obtention de deux lignes, l'une de CI, l'autre de prod pour chaque secteur, issue de la base  `source'_`yrs'_OUT
append using "$dir/Bases/`source'_`yrs'_OUT.dta"

*transpositin en colonne, puis création d'un ratio de CI importées par secteur 
xpose, clear varname
rename v1 ci_oil
rename v2 prod
generate ratio_ci_oil_prod=ci_oil / prod




merge 1:1 _n using "$dir/Bases/csv_`source'.dta"
rename c pays
rename s sector
replace sector = upper(sector)
replace pays=upper(pays)
drop p_shock
drop _merge
 
*}
save "$dir/Bases/oil_inputs_par_sect_`yrs'_`source'.dta", replace
* enregistrement des ratio des CI de pétrole par secteur
end


**************************************


capture program drop oil_inputs // fournit le total des inputs oil pour chaque pays
program oil_inputs
args yrs source vector

do  "$dirgit/Definition_pays_secteur.do" `source'

*La part des CI oil est à présent calculée pour l'ensemble de l'économie, et non plus par secteurs

if "`vector'" == "Y" { 
	use "$dir/Bases/oil_inputs_par_sect_`yrs'_`source'.dta", clear
	replace pays = "CHN" if strpos("$china",pays)!=0
	replace pays = "MEX" if strpos("$mexique",pays)!=0
	
	collapse (sum) ci_oil prod, by(pays)
	generate ratio_ci_oil_Y = ci_oil/prod
	save "$dir/Bases/oil_inputs_Y_`yrs'_`source'.dta", replace
}



if "`vector'" == "HC"  { 

	
	if "`source'"=="TIVA" | "`source'"=="TIVA_REV4" {
		use  "$dir/Bases/oil_inputs_par_sect_`yrs'_`source'.dta", replace
		replace pays = "CHN" if pays=="CN1" | pays=="CN2" | pays=="CN3" | pays=="CN4" 
		replace pays = "MEX" if pays=="MX1" | pays=="MX2" | pays=="MX3"
		collapse (sum) ci_oil prod, by(pays sector)
		generate ratio_ci_oil_prod=ci_oil / prod
		save "$dir/Bases/oil_inputs_par_sect_modif.dta", replace
	}
	

	use "$dir/Bases/HC_`source'.dta", clear
	replace pays=upper(pays)
	if "`source'"=="TIVA" | "`source'"=="TIVA_REV4" {
		replace pays = "CHN" if pays=="CN1" | pays=="CN2" | pays=="CN3" | pays=="CN4" 
		replace pays = "MEX" if pays=="MX1" | pays=="MX2" | pays=="MX3"
		collapse (sum) conso, by(pays pays_conso year sector)
	}
	
	*HC se présente avec le pays d'origine du bien, puis les pays de consommation 
	*Manipulation de la base de données HC en vue d'ordonner la consommation du pays_conso pour tous les secteurs
	keep if upper(pays)==upper(pays_conso) 
	keep if year==`yrs'
	
	if "`source'"=="WIOD" replace pays=upper(pays)
	if "`source'"=="WIOD" replace sector=upper(sector)
	if "`source'"=="WIOD" merge 1:1 pays sector using  "$dir/Bases/oil_inputs_par_sect_`yrs'_`source'.dta"
	if "`source'"=="TIVA" | "`source'"=="TIVA_REV4" merge 1:1 pays sector using  "$dir/Bases/oil_inputs_par_sect_modif.dta" 
	if "`source'"=="TIVA" | "`source'"=="TIVA_REV4" erase  "$dir/Bases/oil_inputs_par_sect_modif.dta"
	drop _merge
		
	gen ci_oil_HC = ratio_ci_oil_prod * conso
	label var ci_oil_HC "Les CI oil dans la consommation de secteurs domestiques"
	
	
	
	generate ratio_ci_oil_HC = ci_oil_HC/conso
	label var ratio_ci_oil_HC "Part des CI oil dans la conso domestique"

	collapse (sum) ci_oil_HC conso ratio_ci_oil_HC, by(pays sector)

	
	save "$dir/Bases/oil_inputs_HC_par_secteur_`yrs'_`source'.dta", replace
	
	collapse (sum) ci_oil_HC conso, by(pays)
	
	generate ratio_ci_oil_HC = ci_oil_HC/conso
	label var ratio_ci_oil_HC "Part des CI oil dans la conso domestique"
	
	save "$dir/Bases/oil_inputs_HC_`yrs'_`source'.dta", replace
}


if "`vector'" == "X"  { 
	
	use "$dir/Bases/X_`source'.dta", clear
 
	keep if year==`yrs'
	
	replace sector=upper(sector)
	
	merge 1:1 pays sector using  "$dir/Bases/oil_inputs_par_sect_`yrs'_`source'.dta"
	

	drop _merge
	
	gen ci_oil_X = ratio_ci_oil_prod * X
	replace pays=upper(pays)
	
	if "`source'"=="TIVA" | "`source'"=="TIVA_REV4"{
		replace pays = "CHN" if pays=="CN1" | pays=="CN2" | pays=="CN3" | pays=="CN4" 
		replace pays = "MEX" if pays=="MX1" | pays=="MX2" | pays=="MX3"
		
	}
	
	collapse (sum) ci_oil_X X, by(pays)
	generate ratio_ci_oil_X = ci_oil_X/X
	save "$dir/Bases/oil_inputs_X_`yrs'_`source'.dta", replace
}

end

********************************************************************************************

//graphiques avec 
//   - impact choc euro / part des importations en provenance de pays hors zone euro
//   - impact chocs pays / 



**pOUR TEST


/*
oil_inputs_par_sect 2015 TIVA_REV4
oil_inputs 2015 TIVA_REV4 Y
oil_inputs 2015 TIVA_REV4 HC
oil_inputs 2015 TIVA_REV4 X

*/




*foreach source in WIOD {
foreach source in  TIVA  TIVA_REV4  WIOD   {



	if "`source'"=="WIOD" global start_year 2000	
	if "`source'"=="TIVA" global start_year 1995
	if "`source'"=="TIVA_REV4" global start_year 2005



	if "`source'"=="WIOD" global end_year 2014
	if "`source'"=="TIVA" global end_year 2011
	if "`source'"=="TIVA_REV4" global end_year 2015

*	foreach i of numlist 2010  {
	foreach i of numlist $start_year (1)$end_year  {
		
		oil_inputs_par_sect `i' `source'
		clear
	}



}

*/



*foreach source in  WIOD {
foreach source in  TIVA TIVA_REV4 WIOD {



	if "`source'"=="WIOD" global start_year 2000	
	if "`source'"=="TIVA" global start_year 1995
	if "`source'"=="TIVA_REV4" global start_year 2005



	if "`source'"=="WIOD" global end_year 2014
	if "`source'"=="TIVA" global end_year 2011
	if "`source'"=="TIVA_REV4" global end_year 2015


*	foreach i of numlist 2015  {
	foreach i of numlist $start_year (1) $end_year  {
		
		oil_inputs `i' `source' HC
		oil_inputs `i' `source' X
		
	
		clear
	}



}

