

***************************************************************************************************
*Création des tables  de X

***************************************************************************************************

capture program drop compute_X
program compute_X
	args source yrs

	
use "$dir/Bases/`source'_ICIO_`yrs'.dta", clear



if "`source'"=="WIOD" {
egen utilisations = rowtotal(vAUS01-vUSA61)
gen utilisations_dom = .
drop if Country=="TOT"

	foreach j of global country {
		local i = "`j'"
		egen blouk = rowtotal(*`i'*)
		display "`i'" "`j'"
		replace utilisations_dom = blouk if Country=="`j'"
*		codebook utilisations_dom if Country=="`j'"
		drop blouk
		
	}

}


if "`source'"=="MRIO" {
	
	if `yrs'==2014 destring ROW_F5, replace dpcomma
	egen utilisations = rowtotal(AUS_C01-ROW_F5)
	gen utilisations_dom = .
	drop if pays=="ZZZ"
	
	
	foreach j of global country {
		local i = "`j'"
		egen blouk = rowtotal(*`i'*)
		display "`i'" "`j'"
		replace utilisations_dom = blouk if pays=="`j'"
*		codebook utilisations_dom if Country=="`j'"
		drop blouk
		
	}
	rename pays Country

}

if "`source'"=="TIVA" {
drop if v1=="VA+TAXSUB" | v1=="OUT"
egen utilisations = rowtotal(arg_c01t05agr-nps_zaf)
gen utilisations_dom = .
* liste de countrys

gen Country = substr("v1",1,3)
 
	foreach j of global country {
		local i = lower("`j'")
		if  ("`j'"=="cn1" | "`j'"=="cn2" |"`j'"=="cn3"|"`j'"=="cn4" ) local i = "chn" 

		if  ("`j'"=="mx1" | "`j'"=="mx2"| "`j'"=="mx3") local i = "mex"
		
		egen blouk = rowtotal(*`i'*)
		display "`i'" "`j'"
		replace utilisations_dom = blouk if strpos(v1,"`j'")!=0
*		codebook utilisations_dom if 	strpos(v1,"`j'")!=0
		drop blouk
	}

}

if "`source'"=="TIVA_REV4" {
	drop if v1 == "VALU" | strmatch(v1, "*TAXSUB") == 1 | v1 == "OUTPUT"
	egen utilisations = rowtotal(ARG_01T03-ZAF_P33)
	gen utilisations_dom = .
	* liste de countrys

gen Country = substr("v1",1,3)
 
	foreach j of global country {
		local i = upper("`j'")
		if  ("`j'"=="CN1" | "`j'"=="CN2") local i = "CHN" 

		if  ("`j'"=="MX1" | "`j'"=="MX2") local i = "MEX"
		
		egen blouk = rowtotal(*`i'*)
		display "`i'" "`j'"
		replace utilisations_dom = blouk if strpos(v1,"`j'")!=0
*		codebook utilisations_dom if 	strpos(v1,"`j'")!=0
		drop blouk
	}

}

generate X = utilisations - utilisations_dom
	
replace Country = strupper(Country)
generate year = `yrs'



if "`source'"=="TIVA" {
	generate pays = strupper(substr(v1,1,3))
	generate sector = strupper(substr(v1,strpos(v1,"_")+1,strlen(v1)-3-strpos(v1,"_")))
}


if "`source'"=="TIVA_REV4" {
	generate pays = strupper(substr(v1,1,3))
	generate sector = strupper(substr(v1,strpos(v1,"_")+1,.))
}

if "`source'"=="WIOD" {
	generate pays =upper(Country)
	rename IndustryCode sector
}

if "`source'"=="MRIO" {
	generate pays =upper(Country)
	rename secteur sector
}

keep pays sector  year X

display "fin compute_X"	
	
end




capture program drop append_X
program append_X
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
	compute_X `source' `y'
	if `y'!=`first_yr' {
	append using "$dir/Bases/X_`source'.dta" 
	}
	save "$dir/Bases/X_`source'.dta", replace
}	
sort year , stable
save "$dir/Bases/X_`source'.dta", replace
 
end







