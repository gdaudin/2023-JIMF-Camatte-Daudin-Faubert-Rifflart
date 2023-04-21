

***************************************************************************************************
*Création des tables  de Y
*La ligne 60 lance le programme au dessus 
***************************************************************************************************

capture program drop compute_Y
program compute_Y
	args source yrs

	
use "$dir/Bases/`source'_ICIO_`yrs'.dta", clear




if "`source'"=="MRIO" {
	egen utilisations = rowtotal(AUS_C01-ROW_F5)
	replace pays =upper(pays)
	rename secteur sector
	drop if pays=="ZZZ"
}


if "`source'"=="WIOD" {
	egen utilisations = rowtotal(vAUS01-vUSA61)
	gen pays =upper(Country)
	rename IndustryCode sector
	drop if pays=="TOT"
}

if "`source'"=="TIVA" {
	drop if v1=="VA+TAXSUB" | v1=="OUT"
	gen Country = substr("v1",1,3)
	egen utilisations = rowtotal(arg_c01t05agr-nps_zaf)
		generate pays = strupper(substr(v1,1,3))
	generate sector = strupper(substr(v1,strpos(v1,"_")+1,strlen(v1)-3-strpos(v1,"_")))
}

if "`source'"=="TIVA_REV4" {
	drop if v1 == "VALU" | strmatch(v1, "*TAXSUB") == 1 | v1 == "OUTPUT"
	egen utilisations = rowtotal(ARG_01T03-ZAF_P33)
	gen Country = substr("v1",1,3)
 	generate pays = strupper(substr(v1,1,3))
	generate sector = strupper(substr(v1,strpos(v1,"_")+1,strlen(v1)-3-strpos(v1,"_")))
}



generate Y = utilisations 
	
generate year = `yrs'

keep pays sector  year Y

display "fin compute_Y"	
	
end


capture program drop append_Y
program append_Y
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

foreach year of numlist `yr_list' { 
 	compute_Y `source' `year'
	if `year'!=`first_yr' {
	append using "$dir/Bases/Y_`source'.dta" 
	}
	save "$dir/Bases/Y_`source'.dta", replace
}	
sort year , stable
save "$dir/Bases/Y_`source'.dta", replace
 
end







