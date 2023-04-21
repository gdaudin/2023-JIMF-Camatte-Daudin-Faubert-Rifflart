


*-------------------------------------------------------------------------------
* SAVE DATABASE FOR EACH YEAR
*-------------------------------------------------------------------------------
capture program drop save_data
program save_data
args yrs source   
*ex: save_data 2011 TIVA


clear

if "`source'"=="TIVA" {

	*Loop to save data for each year
	set more off

	insheet using "$dir/Bases_Sources/TIVA/ICIO2016_`yrs'.csv", clear
	*I sort the ICIO: 
	local useful = _N-2 /*on exclut les 2 dernières lignes du tri ligne suivante */
	sort v1 aus_c01t05agr-disc in 1/`useful' /*observations (tout sauf les 2 de useful*/
	order aus_c01t05agr-cn4_c95pvh, alphabetic after (v1) /*variables V1 = 1ere colonne nom vide non triée*/
	order hfce_aus-disc, alphabetic after (zaf_c95pvh)
	save "$dir/Bases/TIVA_ICIO_`yrs'.dta", replace

/*
	*Same with the database for wages
	clear
	set more off
	local tab "WAGE OUT"
	foreach n of local tab{
		foreach i of numlist 1995 2000 2005 {
		clear
		import excel "$dir/Bases/ICIO/WAGE_`i'.xlsx", sheet("`n'") firstrow
		keep A-VNM
		drop if A == ""
		save "$dir/Bases/`n'_`i'.dta", replace
		}

	}

	*/	
}

if "`source'"=="TIVA_REV4" {

	*Loop to save data for each year
	set more off

	insheet using "$dir/Bases_Sources/TIVA_REV4/ICIO2018_`yrs'.csv", clear case
	*I sort the ICIO: 
	local useful = _N-2 /*on exclut les 2 dernières lignes du tri ligne suivante */
	sort v1 AUS_01T03-TOTAL in 1/`useful' /*observations (tout sauf les 2 de useful*/
	order AUS_01T03-CN2_97T98, alphabetic after (v1) /*variables V1 = 1ere colonne nom vide non triée*/
	order AUS_HFCE-TOTAL, alphabetic after (ZAF_97T98)
	save "$dir/Bases/TIVA_REV4_ICIO_`yrs'.dta", replace

}




if "`source'"=="WIOD" {	 
	*Loop to save data for each year
	set more off

	use "$dir/Bases_Sources/`source'/WIOT`yrs'_October16_ROW.dta", clear
	foreach j of numlist 1 (1) 9 {
		rename ????`j' ????0`j'
	}
	order vAUS01-vROW61, alphabetic after (TOT)
	sort Country RNr
	save "$dir/Bases/WIOD_ICIO_`yrs'.dta", replace


	/*
	*Same with the database for wages
	clear
	set more off
	local tab "WAGE OUT"
	foreach n of local tab{
		foreach i of numlist 1995 2000 2005 {
		clear
		import excel "$dir/Bases/ICIO/WAGE_`i'.xlsx", sheet("`n'") firstrow
		keep A-VNM
		drop if A == ""
		save "$dir/Bases/`n'_`i'.dta", replace
		}
	}
	
	*/

}

if "`source'"=="MRIO" {	 
	*À faire...
	**Les fichiers excels sont trop importants pour les importer directement. Donc d’abord transformation en 
	**csv à la main (libre office ? -- non, cela dépasse le nombre de colonnes)
	**Donc à partir de l’excel. Mais il faut créer une ligne du genre =CONCATENER(E6;"_";E7)
	**Puis s’assurer que le format des chiffres montrent toutes les décimales, et met - pour les termes négatifs
	**avant de sauver en csv
	
	*Loop to save data for each year
	set more off

	import delimited "$dir/Bases_Sources/MRIO/ADB-MRIO-`yrs'.csv", delimiter(";") /*
		*/ varnames(8) asdouble encoding(UTF-8) rowrange(8:2221) colrange(3:2525) /*
		*/ clear case(upper) parselocal(fr)

		
	rename V2523 TOT
	rename V1 pays
	rename V2 secteur
	replace secteur=substr(secteur,1,1)+"0"+substr(secteur,2,1) if strlen(secteur)==2
	replace pays="ZZZ" if pays==""
	replace pays=upper(pays)
	replace secteur=upper(secteur)
		
	foreach j of numlist 1 (1) 9 {
		rename ???_C`j' ???_C0`j'
	}
		

		
	order AUS_C01-ROW_C35, alphabetic
	order pays secteur
	sort pays secteur
	destring AUS_C01-ROW_F5, replace dpcomma
	save "$dir/Bases/`source'_ICIO_`yrs'.dta", replace


	/*
	*Same with the database for wages
	clear
	set more off
	local tab "WAGE OUT"
	foreach n of local tab{
		foreach i of numlist 1995 2000 2005 {
		clear
		import excel "$dir/Bases/ICIO/WAGE_`i'.xlsx", sheet("`n'") firstrow
		keep A-VNM
		drop if A == ""
		save "$dir/Bases/`n'_`i'.dta", replace
		}
	}
	
	*/



}


end

*-------------------------------------------------------------------------------
*TRIMMING THE DATABASE ICIO
*-------------------------------------------------------------------------------
capture program drop prepare_database
program prepare_database
	args yrs source


if "`source'"=="TIVA" {	
		
	*From the ICIO database I keep only the output vector
	use "$dir/Bases/TIVA_ICIO_`yrs'.dta"
	keep if v1 == "OUT"
	drop v1
	drop dirp_arg-nps_zaf
	save "$dir/Bases/TIVA_`yrs'_OUT.dta", replace
	
	*From the ICIO database I keep only the table for inter-industry inter-country trade (matrice de CI mondiale)
	use "$dir/Bases/TIVA_ICIO_`yrs'.dta", clear
	drop dirp_arg-nps_zaf
	drop if v1 == "VA+TAXSUB" | v1 == "OUT"
	gen pays=upper(substr(v1,1,3))
	gen secteur = upper(substr(v1,5,.))
	order pays secteur
	drop v1
	save "$dir/Bases/TIVA_`yrs'_Z.dta", replace
	   
	
}


if "`source'"=="TIVA_REV4" {	
		
	*From the ICIO database I keep only the output vector
	use "$dir/Bases/TIVA_REV4_ICIO_`yrs'.dta"
	keep if v1 == "OUTPUT"
	drop v1
	drop ARG_GFCF-ZAF_P33
	save "$dir/Bases/TIVA_REV4_`yrs'_OUT.dta", replace
	
	*From the ICIO database I keep only the table for inter-industry inter-country trade (matrice de CI mondiale)
	use "$dir/Bases/TIVA_REV4_ICIO_`yrs'.dta", clear
	drop ARG_GFCF-ZAF_P33
	drop if v1 == "VALU" | strmatch(v1, "*TAXSUB") == 1 | v1 == "OUTPUT"
	gen pays=upper(substr(v1,1,3))
	gen secteur = upper(substr(v1,5,.))
	order pays secteur
	drop v1
	save "$dir/Bases/TIVA_REV4_`yrs'_Z.dta", replace
	   	
}

if "`source'"=="WIOD" {	

*Output vector
	use "$dir/Bases/WIOD_ICIO_`yrs'.dta"
	keep if IndustryCode == "GO"
	drop IndustryCode-TOT
	drop *57 *58 *59 *60 *61
	save "$dir/Bases/WIOD_`yrs'_OUT.dta", replace
	
	* Only the I/O table itself
	clear
	use "$dir/Bases/WIOD_ICIO_`yrs'.dta"
	drop if RNr >=65  /* on enlève les totaux */
	rename Country pays
	rename IndustryCode secteur
	order pays secteur
	sort pays secteur
	drop IndustryDescription-TOT
	drop *57 *58 *59 *60 *61
	save "$dir/Bases/WIOD_`yrs'_Z.dta", replace
	

}

if "`source'"=="MRIO" {	

*Output vector
	use "$dir/Bases/`source'_ICIO_`yrs'.dta"
	keep if secteur == "R69"
	drop pays secteur *_F* TOT
	save "$dir/Bases/`source'_`yrs'_OUT.dta", replace
	
	* Only the I/O table itself
	clear
	use "$dir/Bases/`source'_ICIO_`yrs'.dta"
	drop if strpos(secteur,"C")==0
	order pays secteur
	sort pays secteur
	drop pays secteur *_F* TOT
	save "$dir/Bases/`source'_`yrs'_Z.dta", replace
	

}

end


*----------------------------------------------------------------------------------
*BUILDING A DATABASE WITH VECTORS OF COUNTRIES AND SECTORS AND VECTOR CONTAINING 0
*On met les coefficients à zéro pour remplir après
*----------------------------------------------------------------------------------
capture program drop database_csv
program database_csv
args source /* Tiva ou WIOD */
*Exemple : database_csv TIVA

clear
Definition_pays_secteur `source'

				
local nbr_sect=wordcount("$sector")	
local nbr_ctry=wordcount("$country")
local nbr_lig= `nbr_ctry'*`nbr_sect'

				
				
generate c = ""
local num_pays 0
foreach i of global country {
	foreach j of numlist 1/`nbr_sect' {
		local new = _N + 1
		set obs `new'
		local ligne = `j' + `nbr_sect'*`num_pays'
		replace c = "`i'" in `ligne'
	}
	local num_pays = `num_pays'+1
}



generate s =""
local num_sector 0
foreach i of global sector {
	forvalues j = 1(`nbr_sect')`nbr_lig' {
		local ligne = `j' + 1*`num_sector'
		replace s = "`i'" in `ligne'
	}
	local num_sector = `num_sector'+1
}

gen v1=0


rename v1 p_shock

save "$dir/Bases/csv_`source'.dta", replace

collapse (sum) p_shock, by(c)

save "$dir/Bases/pays_en_ligne_`source'.dta", replace

clear
end




***************************************************************************************************
* 1- Création des tables Y de production : on crée le vecteur 1*67 des productions totales de chaque pays
***************************************************************************************************

capture program drop compute_y
program compute_y
args source yrs

/*Y vecteur de production*/ 
clear
use "$dir/Bases/`source'_`yrs'_OUT.dta"
*drop arg_consabr-disc
rename * prod*
generate year = `yrs'
reshape long prod, i(year) j(pays_sect) string


if "`source'"=="TIVA" | "`source'"=="TIVA_REV4" generate pays = strupper(substr(pays_sect,1,strpos(pays_sect,"_")-1))
if "`source'"=="WIOD" generate pays = substr(pays_sect,2,3)

collapse (sum) prod, by(pays year)

end 

*Pour TIVA, la production agrégée CHN est nulle, celle de CN1 CN2 CN3 CN4 ne l'est pas
capture program drop append_y
program append_y
args source

if "`source'"=="TIVA" local yr_list 1995(1)2011
if "`source'"=="TIVA_REV4" local yr_list 2005(1)2015
if "`source'"=="WIOD" local yr_list 2000(1)2014

if "`source'"=="TIVA" local first_yr 1995
if "`source'"=="TIVA_REV4" local first_yr 2005
if "`source'"=="WIOD" local first_yr 2000

foreach y of numlist `yr_list' { 
	compute_y `source' `y'
	if `y'!=`first_yr' {
		append using "$dir/Bases/`source'_prod.dta"
				}
	save "$dir/Bases/`source'_prod.dta", replace
	}
sort year , stable
end

***************************************************************************************************
* 2- Création des tables X d'exportations : on crée le vecteur 1*67 des productions totales de chaque pays
***************************************************************************************************

*Creation of the vector of export X
capture program drop compute_X
program compute_X
	args source yrs

use "$dir/Bases/`source'_ICIO_`yrs'.dta", clear

if "`source'"=="TIVA" {
	global country2 "arg aus aut bel bgr bra brn can che chl"
	global country2 "$country2  chn cn1 cn2 cn3 cn4 col cri cyp cze deu dnk esp est fin"
	global country2 "$country2  fra gbr grc hkg hrv hun idn ind irl isl isr ita jpn khm kor"
	global country2 "$country2  ltu lux lva mar mex mlt mx1 mx2 mx3 mys nld nor nzl per phl pol prt"
	global country2 "$country2  rou row rus sau sgp svk svn swe tha tun tur twn usa vnm zaf"	
}


if "`source'"=="TIVA_REV4" {
	global country2 "arg aus aut bel bgr bra brn can che chl"
	global country2 "$country2  chn cn1 cn2 col cri cyp cze deu dnk esp est fin"
	global country2 "$country2  fra gbr grc hkg hrv hun idn ind irl isl isr ita jpn kaz khm kor"
	global country2 "$country2  ltu lux lva mar mex mlt mx1 mx2 mys nld nor nzl per phl pol prt"
	global country2 "$country2  rou row rus sau sgp svk svn swe tha tun tur twn usa vnm zaf"	
}
							
if "`source'"=="WIOD" {
	global country2 "aus aut bel bgr bra can che" 
	global country2 "$country2 chn cyp cze deu dnk esp est fin"
	global country2 "$country2 fra gbr grc hrv hum idn ind irl   ita jpn kor"
	global country2 "$country2 ltu lux lva mex mlt nld nor pol prt"
	global country2 "$country2 rou row rus svk svn swe tur twn usa"
	
}



do GIT/commerce_va_inflation/Definition_pays_secteur.do   
Definition_pays_secteur `source' 

global country2 lower("$country")
	
generate pays = strlower(substr(v1,1,strpos(v1,"_")-1))
drop if pays==""

if "`source'"=="TIVA"  egen utilisations = rowtotal(arg_c01t05agr-nps_zaf)
***Pour les exports


gen utilisations_dom = .

foreach j of global country2 {
	local i = "`j'"
	if  ("`j'"=="cn1" | "`j'"=="cn2" |"`j'"=="cn3" |"`j'"=="cn4" ) {
		local i = "cn" 
	}
	if  ("`j'"=="mx1" | "`j'"=="mx2" | "`j'"=="mx3" ) {
			local i = "mx"
	}
	egen blouk = rowtotal(*`i'*)
	display "`i'" "`j'"
	replace utilisations_dom = blouk if pays=="`j'"
	codebook utilisations_dom if pays=="`j'"
	drop blouk


	
	*** cn = cn1 + cn2 + cn3 + cn4
	*** mx = mx1 + mx2 + mx3
}

if "`source'"=="TIVA_REV4"  egen utilisations = rowtotal(arg_01T03-zaf97T98)
***Pour les exports


gen utilisations_dom = .

foreach j of global country2 {
	local i = "`j'"
	if  ("`j'"=="cn1" | "`j'"=="cn2" ) {
		local i = "cn" 
	}
	if  ("`j'"=="mx1" | "`j'"=="mx2" ) {
			local i = "mx"
	}
	egen blouk = rowtotal(*`i'*)
	display "`i'" "`j'"
	replace utilisations_dom = blouk if pays=="`j'"
	codebook utilisations_dom if pays=="`j'"
	drop blouk


	
	*** cn = cn1 + cn2 
	*** mx = mx1 + mx2 
}

generate X = utilisations - utilisations_dom
	
replace pays = strupper(pays)
generate year = `yrs'
keep year pays X
collapse (sum) X, by(pays year)

end


capture program drop append_X
program append_X
args source
*We create a .dta that includes all vectors of export of all years



if "`source'"=="TIVA" local yr_list 1995(1)2011
if "`source'"=="TIVA_REV4" local yr_list 2005(1)2015
if "`source'"=="WIOD" local yr_list 2000(1)2014

if "`source'"=="TIVA" local first_yr 1995
if "`source'"=="TIVA_REV4" local first_yr 2005
if "`source'"=="WIOD" local first_yr 2000

foreach y of numlist `yr_list' { 
	compute_X `source' `y'
	if `y'!=`first_yr' {
	append using "$dir/Bases/exports_`source'.dta" 
	}
	save "$dir/Bases/exports_`source'.dta", replace
}	


sort year , stable
save "$dir/Bases/exports_`source'.dta", replace
 

end



