*Pour faire le lien H1992 vers SNA Classes en passant pas Baci


clear  
set more off
if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA"
if ("`c(hostname)'" == "widv270a") global dir  "D:/home/T822289/CommerceVA" 
if ("`c(hostname)'" == "FP1376CD") global dir  "T:/CommerceVA" 

if ("`c(username)'"=="guillaumedaudin") global dirgit "~/Répertoires Git/2023 JIMF Camatte Daudin Faubert Rifflart"
if ("`c(hostname)'" == "widv270a") global dirgit  "D:\home\T822289\CommerceVA\GIT\commerce_va_inflation" 


**Pour mettre les classifications SNAClasses
import delimited "$dir/Bases_Sources/BACI_BEC/BACI_SNAClasses.csv", stringcols(1) clear
save "$dir/Bases/BACI_BEC/BEC_SNAClasses.dta", replace

import delimited "$dir/Bases_Sources/BACI_BEC/Concordance_H0_to_BE/JobID-1_Concordance_H0_to_BE.CSV", stringcols(1 3) clear 
rename becproductcode bec
rename hs198892productcode k
save "$dir/Bases/BACI_BEC/HS199892_BEC.dta", replace
merge m:1 bec using "$dir/Bases/BACI_BEC/BEC_SNAClasses.dta"
drop _merge
save "$dir/Bases/BACI_BEC/HS199892_SNAClasses.dta", replace

***
capture mkdir "$dir/Bases_Sources/BACI_BEC/BACI_HS92_V202102"
cd "$dir/Bases_Sources/BACI_BEC/BACI_HS92_V202102"
unzipfile "$dir/Bases_Sources/BACI_BEC/BACI_HS92_V202102.zip", replace

foreach year of numlist 1995(1)2019 {
	import delimited "$dir/Bases_Sources/BACI_BEC/BACI_HS92_V202102/BACI_HS92_Y`year'_V202102.csv", stringcols(2 3 4) clear 
	rename t year
	rename i exporter
	rename j importer
	merge m:1 k using  "$dir/Bases/BACI_BEC/HS199892_SNAClasses.dta", keep (1 3)
	assert _merge==3
	collapse (sum) v, by(exporter importer year snaclasse)
	save "$dir/Bases/BACI_BEC/BACI_SNAClasses_Y`year'.dta", replace
	erase "$dir/Bases_Sources/BACI_BEC/BACI_HS92_V202102/BACI_HS92_Y`year'_V202102.csv"
}
	
	
***Changer les codes pays
import delimited "$dir/Bases_Sources/BACI_BEC/country_codes_V202102", stringcols(1) clear
save "$dir/Bases/BACI_BEC/Country_BACI_WIOD.dta", replace

foreach year of numlist 1995(1)2019 {
	use "$dir/Bases/BACI_BEC/Country_BACI_WIOD.dta", clear
	rename country_code exporter
	merge 1:m exporter using "$dir/Bases/BACI_BEC/BACI_SNAClasses_Y`year'.dta", keep(2 3)
	assert _merge==3
	drop exporter country_name* iso_2* _merge
	rename iso_3digit_alpha exporter
	save "$dir/Bases/BACI_BEC/BACI_SNAClasses_Y`year'.dta", replace
	
	use "$dir/Bases/BACI_BEC/Country_BACI_WIOD.dta", clear
	rename country_code importer
	merge 1:m importer using "$dir/Bases/BACI_BEC/BACI_SNAClasses_Y`year'.dta", keep(2 3)
	assert _merge==3
	drop importer country_name* iso_2* _merge
	rename iso_3digit_alpha importer
	save "$dir/Bases/BACI_BEC/BACI_SNAClasses_Y`year'.dta", replace	
}	


****Mettre les bases ensemble
use "$dir/Bases/BACI_BEC/BACI_SNAClasses_Y1995.dta"

foreach year of numlist 1996(1)2019 {
	append using "$dir/Bases/BACI_BEC/BACI_SNAClasses_Y`year'.dta"
}
save "$dir/Bases/BACI_BEC/BACI_SNAClasses_Y.dta", replace

foreach year of numlist 1995(1)2019 {
	erase "$dir/Bases/BACI_BEC/BACI_SNAClasses_Y`year'.dta"
}
******
use "$dir/Bases/BACI_BEC/BACI_SNAClasses_Y.dta", clear
global eurozone "AUT BEL CYP DEU ESP EST FIN FRA GRC IRL ITA LTU LUX LVA MLT NLD PRT SVK SVN"

expand 2 if strpos("$eurozone",importer)!=0, gen(pourchoceuro)
replace importer = importer+"_EUR" if pourchoceuro==1
drop pourchoceuro
replace v=0 if strpos(importer,"_EUR")!=0 & strpos("$eurozone",exporter)!=0
sort importer exporter

collapse (sum) v, by(year importer snaclasse)
reshape wide v, i(year importer) j(snaclasse) string

rename importer pays

save "$dir/Bases/BACI_BEC/BACI_SNAClasses_Y.dta", replace


