
***************************************************************************************************
*Création des tables  de consommation finale des ménages (HFCE) : on crée le vecteur 1*67 des hfce de chaque pays

***************************************************************************************************
*Creation of the vector of households final consumption H
capture program drop compute_HC
program compute_HC
	args source yrs

use "$dir/Bases/`source'_ICIO_`yrs'.dta", clear


if "`source'"=="TIVA" {
*v1: pays_secteur

	keep v1 hfce*
	drop if v1=="OUT" | v1=="VA+TAXSUB"
	reshape long hfce_, i(v1) j(pays_conso) string
	replace pays_conso=strupper(pays_conso)
	generate pays = strupper(substr(v1,1,strpos(v1,"_")-1))
	generate sector = strupper(substr(v1,strpos(v1,"_")+1,strlen(v1)-3-strpos(v1,"_")))
	rename hfce_ conso
	generate year = `yrs'
}


if "`source'"=="TIVA_REV4" {
	drop if v1 == "VALU" | strmatch(v1, "*TAXSUB") == 1 | v1 == "OUTPUT"
	 rename *_HFCE HFCE_*
	 keep v1 HFCE*
	reshape long HFCE_, i(v1) j(pays_conso) string
	replace pays_conso=strupper(pays_conso)
	generate pays = strupper(substr(v1,1,strpos(v1,"_")-1))
	generate sector = strupper(substr(v1,strpos(v1,"_")+1,.))
	rename HFCE_ conso
	generate year = `yrs'
}


if "`source'"=="WIOD" {
use "$dir/Bases/`source'_ICIO_`yrs'.dta", clear


keep IndustryCode Country Year v*57
reshape long v, i(Country IndustryCode Year) j(pays_conso) string
rename  Country pays
rename  IndustryCode sector 
replace sector = strupper(sector)
replace pays_conso=strupper(substr(pays_conso,1,3))
 
drop if pays=="TOT"

rename v conso		
rename Year year	
sort year pays sector pays_conso
replace pays = strupper(pays)
}

if "`source'"=="MRIO" {
use "$dir/Bases/`source'_ICIO_`yrs'.dta", clear


keep pays secteur *F1
rename *F1 v*
reshape long v, i(pays secteur) j(pays_conso) string
rename  secteur sector 
replace sector = strupper(sector)
replace pays_conso=strupper(substr(pays_conso,1,3))
 
drop if pays=="TOT"
drop if pays=="ZZZ"
generate year = `yrs'
rename v conso			
sort year pays sector pays_conso
replace pays = strupper(pays)

}





*keep year pays HC
*collapse (sum) HC, by(pays year)
end

capture program drop append_HC
program append_HC
args source
*We create a .dta that includes all vectors of HFCE of all years
if "`source'"=="TIVA" local yr_list 1995(1)2011
if "`source'"=="TIVA_REV4" local yr_list 2005(1)2015
if "`source'"=="WIOD" local yr_list 2000(1)2014
if "`source'"=="MRIO" local yr_list 2000 2007(1)2019


if "`source'"=="TIVA" local first_yr 1995
if "`source'"=="TIVA_REV4" local first_yr 2005
if "`source'"=="WIOD" local first_yr 2000
if "`source'"=="MRIO" local first_yr 2000

foreach y of numlist `yr_list' { 
	compute_HC `source' `y'
	if `y'!=`first_yr' {
	append using "$dir/Bases/HC_`source'.dta" 
	}
	save "$dir/Bases/HC_`source'.dta", replace
}	
sort year , stable
save "$dir/Bases/HC_`source'.dta", replace
 
end



