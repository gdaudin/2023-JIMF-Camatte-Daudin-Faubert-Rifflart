*Calcul du contenu en importations de la consommation des ménages (HC)

clear
*set trace on

if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA"
if ("`c(hostname)'" == "widv270a") global dir  "D:\home\T822289\CommerceVA" 
if ("`c(hostname)'" == "FP1376CD") global dir  "T:\CommerceVA" 

if ("`c(username)'"=="guillaumedaudin") global dirgit "~/Documents/Recherche/2017 BDF_Commerce VA/commerce_VA_inflation"
if ("`c(hostname)'" == "widv270a") global dirgit  "D:\home\T822289\CommerceVA\GIT\commerce_va_inflation" 
if ("`c(hostname)'" == "FP1376CD") global dirgit  "T:\CommerceVA\GIT\commerce_va_inflation" 


if ("`c(username)'" == "guillaumedaudin") use "$dir/BME.dta", clear
if ("`c(hostname)'" == "widv270a") use  "D:\home\T822289\CommerceVA\Rédaction\Rédaction 2019\BME.dta" , clear
if ("`c(hostname)'" == "FP1376CD") use  "T:\CommerceVA\Rédaction\Rédaction 2019\BME.dta" , clear

capture log using "$dir/$S_DATE.log", replace
set more off

capture program drop contenu_oil_HC
program contenu_oil_HC
args source



do "$dirgit/Definition_pays_secteur.do"   
Definition_pays_secteur `source'

*HC_`source' contient la consommation des ménages (HC) du pays consommateur (pays_conso) 
*en provenance du pays producteur (pays) pour un sector donné pour toutes les années
* lorsque pays=pays_conso, pays_conso consomme un bien produit sur le marché domestique
use "$dir/Bases/HC_`source'.dta", clear

* Si la consommation est d'origine domestique (pays=pays_conso), imp=0 
* avec pays_conso le pays consommateur et pays le pays producteur du bien

if "`source'"=="WIOD" local oil B
if "`source'"=="TIVA" local oil C10T14
if "`source'"=="TIVA_REV4" local oil 05T06
			
	
gen oil="yes" if sector=="`oil'"
replace oil="no" if sector !="`oil'"
	

	

*conso0= conso sans oil, conso1= conso oil
collapse (sum) conso, by(oil year pays_conso)

tab oil


reshape wide conso, i(pays_conso year) j(oil) string

gen contenu_oilHC=(consoyes)/(consoyes+consono)


rename pays_conso pays
replace pays = upper(pays)
label var contenu_oilHC "Part des consommations de pétrole importées"

if "`source'"=="WIOD" local start_year 2000
if "`source'"=="TIVA" local start_year 1995
if "`source'"=="TIVA_REV4" local start_year 2005

if "`source'"=="WIOD" local end_year 2014
if "`source'"=="TIVA" local end_year 2011
if "`source'"=="TIVA_REV4" local end_year 2015

foreach i of numlist `start_year' (1)`end_year'  {
	preserve
	keep if year==`i'
	save "$dir/Bases/contenu_oilHC_`source'_`i'.dta", replace
	export excel using "$dir/Bases/contenu_oilHC_`source'_`i'.xls", firstrow(variables) replace
	restore
}


end

contenu_oil_HC TIVA
contenu_oil_HC WIOD
contenu_oil_HC TIVA_REV4

