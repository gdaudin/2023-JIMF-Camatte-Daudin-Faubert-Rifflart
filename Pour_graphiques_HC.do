clear  
set more off
if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA"
else global dir "\\intra\partages\au_dcpm\DiagConj\Commun\CommerceVA"


*capture log close
*log using "$dir/$S_DATE.log", replace

capture program drop graphiques
program graphiques
args source 
	
if ("`c(username)'"=="guillaumedaudin") do  "~/Documents/Recherche/2017 BDF_Commerce VA/commerce_VA_inflation/Definition_pays_secteur.do" `source'
if ("`c(username)'"=="w817186") do "X:\Agents\FAUBERT\commerce_VA_inflation\Definition_pays_secteur.do" `source'
if ("`c(username)'"=="n818881") do  "X:\Agents\LALLIARD\commerce_VA_inflation\Definition_pays_secteur.do" `source'
	



*--------------------------
*-----------------Pour graphiques HC
*--------------------------
*Graphique 1: élasticité des prix de production,  d'exportations et de consommation à une appréciation de la monnaie locale
*TIVA
*Impact sur ZE

use "$dir/Results/Devaluations/mean_chg_TIVA_X_2011.dta", clear

foreach var of varlist shockEUR1-shockZAF1 {
	local pays = substr("`var'",6,3)
	replace `var' = 0 if strmatch(c,"*`pays'*")==0
}

egen pond_TIVA_X = rowtotal(shockEUR1-shockZAF1)
replace pond_TIVA_X = (pond_TIVA_X - 1)/2

keep c pond_TIVA_X

save "$dir/Results/Devaluations/Pour_HC_Graph_1_TIVA_old.dta", replace


use "$dir/Results/Devaluations/mean_chg_TIVA_HC_2011.dta", clear

foreach var of varlist shockEUR1-shockZAF1 {
	local pays = substr("`var'",6,3)
	replace `var' = 0 if strmatch(c,"*`pays'*")==0
}

egen pond_TIVA_HC = rowtotal(shockEUR1-shockZAF1)
replace pond_TIVA_HC = (pond_TIVA_HC - 1)/2

keep c pond_TIVA_HC

merge 1:1 c using "$dir/Results/Devaluations/Pour_HC_Graph_1_TIVA_old.dta"
drop _merge

save "$dir/Results/Devaluations/Pour_HC_Graph_1_TIVA_old2.dta", replace


use "$dir/Results/Devaluations/mean_chg_TIVA_Yt_2011.dta", clear

foreach var of varlist shockEUR1-shockZAF1 {
	local pays = substr("`var'",6,3)
	replace `var' = 0 if strmatch(c,"*`pays'*")==0
}

egen pond_TIVA_Y = rowtotal(shockEUR1-shockZAF1)

keep c pond_TIVA_Y

merge 1:1 c using "$dir/Bases/Pays_FR.dta",keep(3)
drop _merge



merge 1:1 c using "$dir/Results/Devaluations/Pour_HC_Graph_1_TIVA_old2.dta"

drop _merge 

replace pond_TIVA_Y = (pond_TIVA_Y - 1)/2 

label var pond_TIVA_Y "Prix de production"
label var pond_TIVA_X "Prix d'exportation"
label var pond_TIVA_HC "Prix de consommation"

save "$dir/Results/Devaluations/Pour_HC_Graph_1_TIVA_old3.dta", replace
export delimited "$dir/Results/Devaluations/Pour_HC_Graph_1_TIVA_old3.csv", replace

graph bar (asis) pond_TIVA_X pond_TIVA_Y  pond_TIVA_HC, title("Elasticité à une appréciation de la monnaie locale") over(c, sort(c_full_FR) label(angle(vertical) labsize(small)) ) 

graph export "$dir/Results/Devaluations/HC_Graph_1_TIVA_old3.png", replace

drop if strpos("$eurozone",c)==0


graph bar (asis) pond_TIVA_X pond_TIVA_Y pond_TIVA_HC, title("Elasticité à une appréciation de la monnaie locale") over(c_full_FR, sort(c_full_FR) label(angle(vertical) labsize(small)))

graph export "$dir/Results/Devaluations/HC_Graph_1_TIVA.png", replace
save "$dir/Results/Devaluations/Pour_HC_Graph_1_TIVA.dta", replace
export delimited "$dir/Results/Devaluations/Pour_HC_Graph_1_TIVA.csv", replace
export excel "$dir/Results/Devaluations/Pour_HC_Graph_1_TIVA.xlsx", firstrow(variable)replace




*Graph 1 WIOD : impact sur ZE

use "$dir/Results/Devaluations/mean_chg_WIOD_X_2011.dta", clear

foreach var of varlist shockEUR1-shockUSA1 {
	local pays = substr("`var'",6,3)
	replace `var' = 0 if strmatch(c,"*`pays'*")==0
}

egen pond_WIOD_X = rowtotal(shockEUR1-shockUSA1)
replace pond_WIOD_X = (pond_WIOD_X - 1)/2

keep c pond_WIOD_X

save "$dir/Results/Devaluations/Pour_HC_Graph_1_WIOD_old.dta", replace


use "$dir/Results/Devaluations/mean_chg_WIOD_HC_2011.dta", clear

foreach var of varlist shockEUR1-shockUSA1 {
	local pays = substr("`var'",6,3)
	replace `var' = 0 if strmatch(c,"*`pays'*")==0
}

egen pond_WIOD_HC = rowtotal(shockEUR1-shockUSA1)
replace pond_WIOD_HC = (pond_WIOD_HC - 1)/2

keep c pond_WIOD_HC

merge 1:1 c using "$dir/Results/Devaluations/Pour_HC_Graph_1_WIOD_old.dta"
drop _merge

save "$dir/Results/Devaluations/Pour_HC_Graph_1_WIOD_old2.dta", replace


use "$dir/Results/Devaluations/mean_chg_WIOD_Yt_2011.dta", clear

foreach var of varlist shockEUR1-shockUSA1 {
	local pays = substr("`var'",6,3)
	replace `var' = 0 if strmatch(c,"*`pays'*")==0
}

egen pond_WIOD_Y = rowtotal(shockEUR1-shockUSA1)

keep c pond_WIOD_Y

merge 1:1 c using "$dir/Bases/Pays_FR.dta",keep(3)
drop _merge



merge 1:1 c using "$dir/Results/Devaluations/Pour_HC_Graph_1_WIOD_old2.dta"

drop _merge 

replace pond_WIOD_Y = (pond_WIOD_Y - 1)/2 

label var pond_WIOD_Y "Prix de production"
label var pond_WIOD_X "Prix d'exportation"
label var pond_WIOD_HC "Prix de consommation"

save "$dir/Results/Devaluations/Pour_HC_Graph_1_WIOD_old3.dta", replace
export delimited "$dir/Results/Devaluations/Pour_HC_Graph_1_WIOD_old3.csv", replace

graph bar (asis) pond_WIOD_X pond_WIOD_Y  pond_WIOD_HC, title("Elasticité à une appréciation de la monnaie locale") over(c, sort(c) label(angle(vertical) labsize(small))) 

graph export "$dir/Results/Devaluations/HC_Graph_1_WIOD_old3.png", replace

drop if strpos("$eurozone",c)==0


graph bar (asis) pond_WIOD_X pond_WIOD_Y pond_WIOD_HC, title("Elasticité à une appréciation de la monnaie locale") over(c_full_FR, sort(c_full_FR)  label(angle(vertical) labsize(small)))

graph export "$dir/Results/Devaluations/HC_Graph_1_WIOD.png", replace
save "$dir/Results/Devaluations/Pour_HC_Graph_1_WIOD.dta", replace
export delimited "$dir/Results/Devaluations/Pour_HC_Graph_1_WIOD.csv", replace
export excel "$dir/Results/Devaluations/Pour_HC_Graph_1_WIOD.xlsx", firstrow(variable)replace


*Graphique 1: élasticité des prix de production,  d'exportations et de consommation à une appréciation de la monnaie locale
*TIVA
*Impact HORS ZE

use "$dir/Results/Devaluations/mean_chg_TIVA_X_2011.dta", clear

foreach var of varlist shockEUR1-shockZAF1 {
	local pays = substr("`var'",6,3)
	replace `var' = 0 if strmatch(c,"*`pays'*")==0
}

egen pond_TIVA_X = rowtotal(shockEUR1-shockZAF1)
replace pond_TIVA_X = (pond_TIVA_X - 1)/2

keep c pond_TIVA_X

save "$dir/Results/Devaluations/Pour_HC_Graph_1_TIVA_oldHZE.dta", replace


use "$dir/Results/Devaluations/mean_chg_TIVA_HC_2011.dta", clear

foreach var of varlist shockEUR1-shockZAF1 {
	local pays = substr("`var'",6,3)
	replace `var' = 0 if strmatch(c,"*`pays'*")==0
}

egen pond_TIVA_HC = rowtotal(shockEUR1-shockZAF1)
replace pond_TIVA_HC = (pond_TIVA_HC - 1)/2

keep c pond_TIVA_HC

merge 1:1 c using "$dir/Results/Devaluations/Pour_HC_Graph_1_TIVA_oldHZE.dta"
drop _merge

save "$dir/Results/Devaluations/Pour_HC_Graph_1_TIVA_old2HZE.dta", replace


use "$dir/Results/Devaluations/mean_chg_TIVA_Yt_2011.dta", clear

foreach var of varlist shockEUR1-shockZAF1 {
	local pays = substr("`var'",6,3)
	replace `var' = 0 if strmatch(c,"*`pays'*")==0
}

egen pond_TIVA_Y = rowtotal(shockEUR1-shockZAF1)

keep c pond_TIVA_Y

merge 1:1 c using "$dir/Bases/Pays_FR.dta",keep(3)
drop _merge



merge 1:1 c using "$dir/Results/Devaluations/Pour_HC_Graph_1_TIVA_old2HZE.dta"

drop _merge 

replace pond_TIVA_Y = (pond_TIVA_Y - 1)/2 

label var pond_TIVA_Y "Prix de production"
label var pond_TIVA_X "Prix d'exportation"
label var pond_TIVA_HC "Prix de consommation"

save "$dir/Results/Devaluations/Pour_HC_Graph_1_TIVA_old3HZE.dta", replace
export delimited "$dir/Results/Devaluations/Pour_HC_Graph_1_TIVA_old3HZE.csv", replace

graph bar (asis) pond_TIVA_X pond_TIVA_Y  pond_TIVA_HC, title("Elasticité à une appréciation de la monnaie locale") over(c, sort(c_full_FR) label(angle(vertical) labsize(small)) ) 

graph export "$dir/Results/Devaluations/HC_Graph_1_TIVA_old3HZE.png", replace

drop if strpos("$eurozone",c)!=0


graph bar (asis) pond_TIVA_X pond_TIVA_Y pond_TIVA_HC, title("Elasticité à une appréciation de la monnaie locale") over(c_full_FR, sort(c_full_FR)  label(angle(vertical) labsize(small)))

graph export "$dir/Results/Devaluations/HC_Graph_1_TIVAHZE.png", replace
save "$dir/Results/Devaluations/Pour_HC_Graph_1_TIVAHZE.dta", replace
export delimited "$dir/Results/Devaluations/Pour_HC_Graph_1_TIVAHZE.csv", replace
export excel "$dir/Results/Devaluations/Pour_HC_Graph_1_TIVAHZE.xlsx", firstrow(variable)replace




*Graph 1 WIOD : impact HORS ZE

use "$dir/Results/Devaluations/mean_chg_WIOD_X_2011.dta", clear

foreach var of varlist shockEUR1-shockUSA1 {
	local pays = substr("`var'",6,3)
	replace `var' = 0 if strmatch(c,"*`pays'*")==0
}

egen pond_WIOD_X = rowtotal(shockEUR1-shockUSA1)
replace pond_WIOD_X = (pond_WIOD_X - 1)/2

keep c pond_WIOD_X

save "$dir/Results/Devaluations/Pour_HC_Graph_1_WIOD_oldHZE.dta", replace


use "$dir/Results/Devaluations/mean_chg_WIOD_HC_2011.dta", clear

foreach var of varlist shockEUR1-shockUSA1 {
	local pays = substr("`var'",6,3)
	replace `var' = 0 if strmatch(c,"*`pays'*")==0
}

egen pond_WIOD_HC = rowtotal(shockEUR1-shockUSA1)
replace pond_WIOD_HC = (pond_WIOD_HC - 1)/2

keep c pond_WIOD_HC

merge 1:1 c using "$dir/Results/Devaluations/Pour_HC_Graph_1_WIOD_oldHZE.dta"
drop _merge

save "$dir/Results/Devaluations/Pour_HC_Graph_1_WIOD_old2HZE.dta", replace


use "$dir/Results/Devaluations/mean_chg_WIOD_Yt_2011.dta", clear

foreach var of varlist shockEUR1-shockUSA1 {
	local pays = substr("`var'",6,3)
	replace `var' = 0 if strmatch(c,"*`pays'*")==0
}

egen pond_WIOD_Y = rowtotal(shockEUR1-shockUSA1)

keep c pond_WIOD_Y

merge 1:1 c using "$dir/Bases/Pays_FR.dta",keep(3)
drop _merge



merge 1:1 c using "$dir/Results/Devaluations/Pour_HC_Graph_1_WIOD_old2HZE.dta"

drop _merge 

replace pond_WIOD_Y = (pond_WIOD_Y - 1)/2 

label var pond_WIOD_Y "Prix de production"
label var pond_WIOD_X "Prix d'exportation"
label var pond_WIOD_HC "Prix de consommation"

save "$dir/Results/Devaluations/Pour_HC_Graph_1_WIOD_old3HZE.dta", replace
export delimited "$dir/Results/Devaluations/Pour_HC_Graph_1_WIOD_old3HZE.csv", replace

graph bar (asis) pond_WIOD_X pond_WIOD_Y  pond_WIOD_HC, title("Elasticité à une appréciation de la monnaie locale") over(c, sort(c) label(angle(vertical) labsize(small))) 

graph export "$dir/Results/Devaluations/HC_Graph_1_WIOD_old3.png", replace

drop if strpos("$eurozone",c)!=0


graph bar (asis) pond_WIOD_X pond_WIOD_Y pond_WIOD_HC, title("Elasticité à une appréciation de la monnaie locale") over(c_full_FR, sort(c_full_FR)  label(angle(vertical) labsize(small)))

graph export "$dir/Results/Devaluations/HC_Graph_1_WIODHZE.png", replace
save "$dir/Results/Devaluations/Pour_HC_Graph_1_WIODHZE.dta", replace
export delimited "$dir/Results/Devaluations/Pour_HC_Graph_1_WIODHZE.csv", replace
export excel "$dir/Results/Devaluations/Pour_HC_Graph_1_WIODHZE.xlsx", firstrow(variable)replace


*GRAPHIQUE HC 2 TIVA: comparaison évolution dans le temps en devise nationale
* Correspond au Graphique 2 du working paper OFCE

use "$dir/Results/Devaluations/mean_chg_TIVA_HC_2000.dta", clear

foreach var of varlist shockEUR1-shockZAF1 {
	local pays = substr("`var'",6,3)
	replace `var' = 0 if strmatch(c,"*`pays'*")==0
}

egen pond_TIVA_HC_2000 = rowtotal(shockEUR1-shockZAF1)
replace pond_TIVA_HC_2000 = (pond_TIVA_HC_2000 - 1)/2

keep c pond_TIVA_HC_2000
merge 1:1 c using "$dir/Bases/Pays_FR.dta",keep(3)
drop _merge
save "$dir/Results/Devaluations/Pour_TIVA_HC_Graph_2_old.dta", replace

use "$dir/Results/Devaluations/mean_chg_TIVA_HC_2011.dta", clear

foreach var of varlist shockEUR1-shockZAF1 {
	local pays = substr("`var'",6,3)
	replace `var' = 0 if strmatch(c,"*`pays'*")==0
}

egen pond_TIVA_HC_2011 = rowtotal(shockEUR1-shockZAF1)
replace pond_TIVA_HC_2011 = (pond_TIVA_HC_2011 - 1)/2

keep c pond_TIVA_HC_2011

merge 1:1 c using "$dir/Results/Devaluations/Pour_TIVA_HC_Graph_2_old.dta"
drop _merge


label var pond_TIVA_HC_2000 "Prix de consommation, 2000 "
label var pond_TIVA_HC_2011 "Prix de consommation, 2011 "

save "$dir/Results/Devaluations/Pour_TIVA_HC_Graph_2.dta", replace
export delimited "$dir/Results/Devaluations/Pour_TIVA_HC_Graph_2.csv", replace


graph bar (asis) pond_TIVA_HC_2000 pond_TIVA_HC_2011 , title("Elasticité à une appréciation de la monnaie locale") over(c_full_FR, sort(c_full_FR)  label(angle(vertical) labsize(small))) 

graph export "$dir/Results/Devaluations/Pour_TIVA_HC_Graph_2.png", replace

drop if strpos("$eurozone",c)==0


graph export "$dir/Results/Devaluations/HC_Graph_2_TIVA.png", replace
save "$dir/Results/Devaluations/Pour_HC_Graph_2_TIVA.dta", replace
export delimited "$dir/Results/Devaluations/Pour_HC_Graph_2_TIVA.csv", replace
export excel "$dir/Results/Devaluations/Pour_HC_Graph_2_TIVA.xlsx", firstrow(variable)replace


*GRAPHIQUE HC 2 WIOD: comparaison évolution dans le temps en devise nationale


use "$dir/Results/Devaluations/mean_chg_WIOD_HC_2000.dta", clear

foreach var of varlist shockEUR1-shockUSA1 {
	local pays = substr("`var'",6,3)
	replace `var' = 0 if strmatch(c,"*`pays'*")==0
}

egen pond_WIOD_HC_2000 = rowtotal(shockEUR1-shockUSA1)
replace pond_WIOD_HC_2000 = (pond_WIOD_HC_2000 - 1)/2

keep c pond_WIOD_HC_2000
save "$dir/Results/Devaluations/Pour_WIOD_HC_Graph_2_old.dta", replace

use "$dir/Results/Devaluations/mean_chg_WIOD_HC_2011.dta", clear

foreach var of varlist shockEUR1-shockUSA1 {
	local pays = substr("`var'",6,3)
	replace `var' = 0 if strmatch(c,"*`pays'*")==0
}

egen pond_WIOD_HC_2011 = rowtotal(shockEUR1-shockUSA1)
replace pond_WIOD_HC_2011 = (pond_WIOD_HC_2011 - 1)/2

keep c pond_WIOD_HC_2011

merge 1:1 c using "$dir/Results/Devaluations/Pour_WIOD_HC_Graph_2_old.dta"
drop _merge


label var pond_WIOD_HC_2000 "Prix de consommation, 2000 "
label var pond_WIOD_HC_2011 "Prix de consommation, 2011 "

save "$dir/Results/Devaluations/Pour_WIOD_HC_Graph_2.dta", replace
export delimited "$dir/Results/Devaluations/Pour_WIOD_HC_Graph_2.csv", replace


graph bar (asis) pond_WIOD_HC_2000 pond_WIOD_HC_2011 , title("Elasticité à une appréciation de la monnaie locale") over(c, sort(c_full_FR) label(angle(vertical) labsize(small))) 

graph export "$dir/Results/Devaluations/Pour_WIOD_HC_Graph_2.png", replace

drop if strpos("$eurozone",c)==0

graph export "$dir/Results/Devaluations/HC_Graph_2_WIOD.png", replace
save "$dir/Results/Devaluations/Pour_HC_Graph_2_WIOD.dta", replace
export delimited "$dir/Results/Devaluations/Pour_HC_Graph_2_WIOD.csv", replace
export excel "$dir/Results/Devaluations/Pour_HC_Graph_2_WIOD.xlsx", firstrow(variable)replace



**Graphique 3 WP OFCE: élasticité des prix de prod, d'exportations et de consommation en euros des pays ZE à une appréciation de l'euro


foreach source in WIOD TIVA {
	local i 1
	foreach weight in X Yt HC {

		use "$dir/Results/Devaluations/mean_chg_`source'_`weight'_2011.dta", clear

		keep c shockEUR1
		drop if strpos("$eurozone",c)==0
		rename shockEUR1 pond_`source'_`weight'
		replace pond_`source'_`weight' = (pond_`source'_`weight' - 1)/2
		keep c pond_`source'_`weight'

		if `i' !=1 {
			merge 1:1 c using "$dir/Results/Devaluations/Pour_HC_Graph_3_`source'_old.dta
			drop _merge
		}
		save "$dir/Results/Devaluations/Pour_HC_Graph_3_`source'_old.dta", replace
		local i=`i'+1
	}


	label var pond_`source'_Yt "`source'_Prix de production"
	label var pond_`source'_X "`source'_Prix d'exportation"
	label var pond_`source'_HC "`source'_Prix de consommation"
	
	merge 1:1 c using "$dir/Bases/Pays_FR.dta",keep(3)
	drop _merge
	
	
	save "$dir/Results/Devaluations/Pour_HC_Graph_3_`source'.dta", replace
	export delimited "$dir/Results/Devaluations/Pour_HC_Graph_3_`source'.csv", replace
	export excel "$dir/Results/Devaluations/Pour_HC_Graph_3_`source'.xlsx", firstrow(variable)replace
	
	graph bar (asis) pond_`source'_X pond_`source'_Yt pond_`source'_HC,  yscale(range(-0.5 0.0))  ylabel(-0.5 (0.1) 0.0) title("Elasticité à une appréciation de l'euro") over(c_full_FR, sort(c_full_FR) label(angle(vertical) )) 
	graph export "$dir/Results/Devaluations/HC_Graph_3_`source'.png" , replace
}

use "$dir/Results/Devaluations/Pour_HC_Graph_3_WIOD_old.dta", clear
merge 1:1 c using "$dir/Results/Devaluations/Pour_HC_Graph_3_TIVA_old.dta"


foreach weight in X Yt HC {
	twoway  (scatter pond_WIOD_`weight' pond_TIVA_`weight', mlabel(c)) ///
			(line pond_TIVA_HC pond_TIVA_HC, sort) (line pond_WIOD_HC pond_WIOD_HC, sort), ///
			yscale(range(-0.5 0.0)) xscale(range(-0.5 0.0))  ///
			ylabel(-0.5(0.25)0.0) xlabel(-0.5(0.25)0.0)  ///
			title("`weight' elasticity to euro appreciation") ytitle("WIOD") xtitle("TIVA") ///
			legend(off) ///
			name(comp_3_`weight', replace) ///
			nodraw

}

graph combine comp_3_X comp_3_Yt comp_3_HC 
graph export "$dir/Results/Devaluations/HC_Graph_3.png" , replace






**Graphique 4 du working paper : élasticité des prix en monnaie locale des pays hors ZE à une appréciation de l'euro
*comparaison des effets prix d'exportations, de production et de consommation: comme dans le WP

foreach source in TIVA WIOD {
use "$dir/Results/Devaluations/mean_chg_`source'_X_2011.dta", clear

keep c shockEUR1
drop if strpos("$eurozone",c)!=0
rename shockEUR1 pond_`source'_X
save "$dir/Results/Devaluations/Pour_HC_Graph_4_`source'_old.dta", replace

use "$dir/Results/Devaluations/mean_chg_`source'_Yt_2011.dta", clear
keep c shockEUR1
drop if strpos("$eurozone",c)!=0
rename shockEUR1 pond_`source'_Yt
merge 1:1 c using "$dir/Results/Devaluations/Pour_HC_Graph_4_`source'_old.dta"
drop _merge
save "$dir/Results/Devaluations/Pour_HC_Graph_4_`source'_old2.dta", replace

use "$dir/Results/Devaluations/mean_chg_`source'_HC_2011.dta", clear
keep c shockEUR1
drop if strpos("$eurozone",c)!=0
rename shockEUR1 pond_`source'_HC

merge 1:1 c using "$dir/Results/Devaluations/Pour_HC_Graph_4_`source'_old2.dta"
drop _merge

merge 1:1 c using "$dir/Bases/Pays_FR.dta",keep(3)
drop _merge

label var pond_`source'_Yt "Prix de production"

label var pond_`source'_X "Prix d'exportation"

label var pond_`source'_HC "Prix de consommation"

save "$dir/Results/Devaluations/Pour_HC_Graph_4_`source'.dta", replace
export delimited "$dir/Results/Devaluations/Pour_HC_Graph_4_`source'.csv", replace
export excel "$dir/Results/Devaluations/Pour_HC_Graph_4_`source'.xlsx", firstrow(variable)replace

graph bar (asis) pond_`source'_X pond_`source'_Yt pond_`source'_HC,  title("Elasticité en monnaie locale à une appréciation de l'EURO") over(c_full_FR, sort(c_full_FR) label(angle(vertical) labsize(vsmall))) 

graph export "$dir/Results/Devaluations/HC_Graph_4_`source'.png", replace

}


*comparaison des effets dans le temps : 4 temp
* des pays hors zone euro à une appréciation dudit euro

foreach source in TIVA WIOD {

use "$dir/Results/Devaluations/mean_chg_`source'_HC_2000.dta", clear
keep c shockEUR1
drop if strpos("$eurozone",c)!=0
rename shockEUR1 pond_HC_2000
save "$dir/Results/Devaluations/Pour_HC_`source'_Graph_4temp_old.dta", replace
merge 1:1 c using "$dir/Bases/Pays_FR.dta",keep(3)
drop _merge
save "$dir/Results/Devaluations/Pour_HC_`source'_Graph_4temp_old.dta", replace

use "$dir/Results/Devaluations/mean_chg_`source'_HC_2011.dta", clear
keep c shockEUR1
drop if strpos("$eurozone",c)!=0
rename shockEUR1 pond_HC_2011
merge 1:1 c using "$dir/Results/Devaluations/Pour_HC_`source'_Graph_4temp_old.dta"
drop _merge

label var pond_HC_2000 "Prix de consommation, 2000"
label var pond_HC_2011 "Prix de consommation, 2011"

save "$dir/Results/Devaluations/Pour_HC_`source'_Graph_4temp.dta", replace
export delimited "$dir/Results/Devaluations/Pour_HC_`source'_Graph_4temp.csv", replace
export excel "$dir/Results/Devaluations/Pour_HC_`source'_Graph_4temp.xlsx", firstrow(variable)replace

graph bar (asis) pond_HC_2000  pond_HC_2011 ,  yscale(range(0.0 0.3))  ylabel(0.0 (0.05) 0.3) title("Elasticité prix conso. à une appréciation de l'euro") over(c_full_FR, sort(c_full_FR)  label(angle(vertical) labsize(vsmall))) 
graph export "$dir/Results/Devaluations/HC_Graph_4temp_`source'.png", replace
}

**Graphique 4tempb  : élasticité des prix 
* des pays zone euro à une appréciation de la livre

foreach source in TIVA WIOD {
use "$dir/Results/Devaluations/mean_chg_`source'_HC_2000.dta", clear
keep c shockGBR1
keep if strpos("$eurozone",c)!=0
rename shockGBR1 pond_HC_2000
save "$dir/Results/Devaluations/Pour_HC_`source'_Graph_4tempb_old.dta", replace
merge 1:1 c using "$dir/Bases/Pays_FR.dta",keep(3)
drop _merge
save "$dir/Results/Devaluations/Pour_HC_`source'_Graph_4tempb_old.dta", replace

use "$dir/Results/Devaluations/mean_chg_`source'_HC_2011.dta", clear
keep c shockGBR1
keep if strpos("$eurozone",c)!=0
rename shockGBR1 pond_HC_2011
merge 1:1 c using "$dir/Results/Devaluations/Pour_HC_`source'_Graph_4tempb_old.dta"
drop _merge

label var pond_HC_2000 "Prix de consommation, 2000"
label var pond_HC_2011 "Prix de consommation, 2011"

save "$dir/Results/Devaluations/Pour_HC_`source'_Graph_4tempb.dta", replace
export delimited "$dir/Results/Devaluations/Pour_HC_`source'_Graph_4tempb.csv", replace
export excel "$dir/Results/Devaluations/Pour_HC_`source'_Graph_4tempb.xlsx", firstrow(variable)replace

graph bar (asis) pond_HC_2000  pond_HC_2011 ,   yscale(range(0.0 0.12))  ylabel(0.0 (0.02) 0.12)title("Elasticité prix conso. ZE à un choc UK")over(c_full_FR, sort(c_full_FR)  label(angle(vertical) labsize(vsmall))) 
graph export "$dir/Results/Devaluations/HC_`source'_Graph_4tempb.png", replace
}

**Graphique 4bb : élasticité des prix 
* de tous les pays à une appréciation de la livre

foreach source in TIVA WIOD {
use "$dir/Results/Devaluations/mean_chg_`source'_HC_2000.dta", clear
keep c shockGBR1
drop if strmatch(c,"GBR")==1
rename shockGBR1 pond_HC_2000
save "$dir/Results/Devaluations/Pour_HC_`source'_Graph_4tempbb_old.dta", replace
merge 1:1 c using "$dir/Bases/Pays_FR.dta",keep(3)
drop _merge
save "$dir/Results/Devaluations/Pour_HC_`source'_Graph_4tempbb_old.dta", replace

use "$dir/Results/Devaluations/mean_chg_`source'_HC_2011.dta", clear
keep c shockGBR1
drop if strmatch(c,"GBR")==1
rename shockGBR1 pond_HC_2011
merge 1:1 c using "$dir/Results/Devaluations/Pour_HC_`source'_Graph_4tempbb_old.dta"
drop _merge

label var pond_HC_2000 "Prix de consommation, 2000"
label var pond_HC_2011 "Prix de consommation, 2011"

save "$dir/Results/Devaluations/Pour_HC_`source'_Graph_4tempbb.dta", replace
export delimited "$dir/Results/Devaluations/Pour_HC_`source'_Graph_4tempbb.csv", replace
export excel "$dir/Results/Devaluations/Pour_HC_`source'_Graph_4tempbb.xlsx", firstrow(variable)replace

graph bar (asis) pond_HC_2000  pond_HC_2011 , title("Elasticité prix conso. à un choc UK") over(c_full_FR, sort(c_full_FR)  label(angle(vertical) labsize(vsmall))) 
graph export "$dir/Results/Devaluations/HC_Graph_4tempbb_`source'.png", replace
}

**Graphique 4c : élasticité des prix 
* des pays zone euro à une appréciation USD

foreach source in TIVA WIOD {

use "$dir/Results/Devaluations/mean_chg_`source'_HC_2000.dta", clear
keep c shockUSA1
keep if strpos("$eurozone",c)!=0
rename shockUSA1 pond_HC_2000
save "$dir/Results/Devaluations/Pour_HC_`source'_Graph_4tempc_old.dta", replace
merge 1:1 c using "$dir/Bases/Pays_FR.dta",keep(3)
drop _merge
save "$dir/Results/Devaluations/Pour_HC_`source'_Graph_4tempc_old.dta", replace

use "$dir/Results/Devaluations/mean_chg_`source'_HC_2011.dta", clear
keep c shockUSA1
keep if strpos("$eurozone",c)!=0
rename shockUSA1 pond_HC_2011
merge 1:1 c using "$dir/Results/Devaluations/Pour_HC_`source'_Graph_4tempc_old.dta"
drop _merge

label var pond_HC_2000 "Prix de consommation, 2000"
label var pond_HC_2011 "Prix de consommation, 2011"

save "$dir/Results/Devaluations/Pour_HC_Graph_4tempc_`source'.dta", replace
export delimited "$dir/Results/Devaluations/Pour_HC_Graph_4tempc_`source'.csv", replace
export excel "$dir/Results/Devaluations/Pour_HC_Graph_4tempc_`source'.xlsx", firstrow(variable)replace

graph bar (asis) pond_HC_2000  pond_HC_2011 ,  yscale(range(0.0 0.12))  ylabel(0.0 (0.02) 0.12) title("Elasticité prix conso. ZE à un choc USD") over(c_full_FR, sort(c_full_FR)  label(angle(vertical) labsize(vsmall))) 
graph export "$dir/Results/Devaluations/HC_Graph_4tempc_`source'.png", replace
}

**Graphique 4cb : élasticité des prix 
* des pays zone euro à une appréciation USD

foreach source in TIVA WIOD {

use "$dir/Results/Devaluations/mean_chg_`source'_HC_2000.dta", clear
keep c shockUSA1
drop if strmatch(c,"USA")==1
rename shockUSA1 pond_HC_2000
save "$dir/Results/Devaluations/Pour_HC_Graph_4tempb_old_`source'.dta", replace
merge 1:1 c using "$dir/Bases/Pays_FR.dta",keep(3)
drop _merge
save "$dir/Results/Devaluations/Pour_HC_Graph_4tempcb_old_`source'.dta", replace

use "$dir/Results/Devaluations/mean_chg_`source'_HC_2011.dta", clear
keep c shockUSA1
drop if strmatch(c,"USA")==1
rename shockUSA1 pond_HC_2011
merge 1:1 c using "$dir/Results/Devaluations/Pour_HC_Graph_4tempcb_old_`source'.dta"
drop _merge

label var pond_HC_2000 "Prix de consommation, 2000"
label var pond_HC_2011 "Prix de consommation, 2011"

save "$dir/Results/Devaluations/Pour_HC_Graph_4tempc_`source'.dta", replace
export delimited "$dir/Results/Devaluations/Pour_HC_Graph_4tempcb_`source'.csv", replace
export excel "$dir/Results/Devaluations/Pour_HC_Graph_4tempcb_`source'.xlsx", firstrow(variable)replace

graph bar (asis) pond_HC_2000  pond_HC_2011 , title("Elasticité prix conso. à un choc USD") over(c_full_FR, sort(c_full_FR)  label(angle(vertical) labsize(vsmall))) 
graph export "$dir/Results/Devaluations/HC_Graph_4tempcb_`source'.png", replace
}

*GRAPHIQUE 7 WP: élasticité des prix de consommation des pays de la ze 
*à un choc sur l'euro et part des importations dans la conso
foreach source in TIVA WIOD {
use "$dir/Results/Devaluations/contenu_impHC_`source'_2011.dta", clear  

gen c=upper(pays)
drop pays

merge 1:1 c using "$dir/Bases/Pays_FR.dta",keep(3)
drop _merge 
label var contenu_impHC "Parts des importations dans la consommation"

keep if strpos("$eurozone",c)!=0
save "$dir/Results/Devaluations/Pour_HC_Graph_imp_deval_`source'.dta", replace
	

use "$dir/Results/Devaluations/mean_chg_`source'_HC_2011.dta", clear	
keep c shockEUR1
keep if strpos("$eurozone",c)!=0
rename shockEUR1 pond_HC
merge 1:1 c using "$dir/Results/Devaluations/Pour_HC_Graph_imp_deval_`source'.dta"
drop _merge
	
graph twoway (scatter pond_HC contenu_impHC, mlabel(c)) (lfit pond_HC contenu_impHC)  , ///
			title("Elasticité des prix de consommation ZE à un choc Euro") ///
			xtitle("Parts des importations dans la consommation") ytitle("Elasticité prix de conso. en euro") ///
			yscale(range(0.6 0.9)) xscale(range(0.1 0.6)) xlabel (0.1(0.1) 0.6) ylabel(0.6 (0.1) 0.9)
		
graph export "$dir/Results/Devaluations/HC_Graph_7_`source'.png", replace
export excel "$dir/Results/Devaluations/Pour_HC_`Graph_7_source'.xlsx", firstrow(variable)replace
}

*GRAPHIQUE 7b WP: élasticité des prix de consommation ZE
*à un choc sur la livre et part des importations dans la conso
foreach source in TIVA WIOD {
use "$dir/Results/Devaluations/contenu_impHC_`source'_2011.dta", clear  
gen c=upper(pays)
drop pays

merge 1:1 c using "$dir/Bases/Pays_FR.dta",keep(3)
drop _merge 
label var contenu_impHC "Parts des importations dans la consommation"

keep if strpos("$eurozone",c)!=0
save "$dir/Results/Devaluations/Pour_HC_Graph_imp_devalb_`source'.dta", replace
	

use "$dir/Results/Devaluations/mean_chg_`source'_HC_2011.dta", clear	
keep c shockGBR1
*drop if strmatch(c,"GBR")==1
keep if strpos("$eurozone",c)!=0
rename shockGBR1 pond_HC
merge 1:1 c using "$dir/Results/Devaluations/Pour_HC_Graph_imp_devalb_`source'.dta"
drop _merge
	
graph twoway (scatter pond_HC contenu_impHC, mlabel(c)) (lfit pond_HC contenu_impHC)  , ///
			xtitle("Parts des importations dans la consommation") ytitle("Elasticité prix de conso.") ///
			yscale(range(0.0 0.12)) xscale(range(0.0 0.6)) xlabel (0.0(0.1) 0.6) ylabel(0.0 (0.01) 0.12) ///
			title("Elasticité des prix de consommation ZE à un choc UK", span)
		
graph export "$dir/Results/Devaluations/HC_Graph_7b_`source'.png", replace
export excel "$dir/Results/Devaluations/Pour_HC_`source'_Graph_7b_`source'.xlsx", firstrow(variable)replace
}

*GRAPHIQUE 7c WP: élasticité des prix de consommation ZE
*à un choc usd et part des importations dans la conso
foreach source in TIVA WIOD {
use "$dir/Results/Devaluations/contenu_impHC_`source'_2011.dta", clear  

gen c=upper(pays)
drop pays

merge 1:1 c using "$dir/Bases/Pays_FR.dta",keep(3)
drop _merge 
label var contenu_impHC "Parts des importations dans la consommation"

keep if strpos("$eurozone",c)!=0
save "$dir/Results/Devaluations/Pour_HC_Graph_imp_devalc_`source'.dta", replace
	

use "$dir/Results/Devaluations/mean_chg_`source'_HC_2011.dta", clear	
keep c shockUSA1
*drop if strmatch(c,"GBR")==1
keep if strpos("$eurozone",c)!=0
rename shockUSA1 pond_HC
merge 1:1 c using "$dir/Results/Devaluations/Pour_HC_Graph_imp_devalc_`source'.dta"
drop _merge
	
graph twoway (scatter pond_HC contenu_impHC, mlabel(c)) (lfit pond_HC contenu_impHC)  , ///
			title("Elasticité des prix de consommation ZE à un choc USD") ///
			xtitle("Parts des importations dans la consommation") ytitle("Elasticité prix de conso.") ///
			yscale(range(0.0 0.1)) xscale(range(0.0 0.6)) xlabel (0.0(0.1) 0.6) ylabel(0.0 (0.02) 0.1)
		
graph export "$dir/Results/Devaluations/HC_Graph_7c_`source'.png", replace
export excel "$dir/Results/Devaluations/Pour_HC_Graph_7c8_`source'.xlsx", firstrow(variable)replace
}


*GRAPHIQUE 8: élasticité des prix de consommation des pays de la ze 
*à un choc sur l'euro et part des CI importées hors ZE dans la conso

foreach source in TIVA  WIOD {
foreach hze in hze_yes hze_not {
use "$dir/Bases/imp_inputs_HC_2011_`source'_`hze'.dta", clear  
gen c=upper(pays)
drop pays

merge 1:1 c using "$dir/Bases/Pays_FR.dta",keep(3)

drop _merge 
label var ratio_ci_impt_HC "Parts des CI importées depuis les pays hors ZE dans la consommation"

keep if strpos("$eurozone",c)!=0
save "$dir/Results/Devaluations/Pour_HC_Graph8_`source'_`hze'.dta", replace


use "$dir/Results/Devaluations/mean_chg_`source'_HC_2011.dta", clear	
keep c shockEUR1

keep if strpos("$eurozone",c)!=0
rename shockEUR1 pond_HC
merge 1:1 c using "$dir/Results/Devaluations/Pour_HC_Graph8_`source'_`hze'.dta"
drop _merge
		
graph twoway (scatter pond_HC ratio_ci_impt_HC, mlabel(c_full_FR)) (lfit pond_HC ratio_ci_impt_HC)  , ///
			title("Elasticité des prix de consommation ZE à un choc Euro") ///
			xtitle("Parts des CI importées depuis les pays `hze' dans la consommation") ytitle("Elasticité prix de conso. en euro") ///
			yscale(range(0.6 0.9)) xscale(range(0.0 0.2)) xlabel (0.0(0.02) 0.2) ylabel(0.6 (0.1) 0.9)
		
graph export "$dir/Results/Devaluations/HC_Graph_8_`source'_`hze'.png", replace
export excel "$dir/Results/Devaluations/Pour_HC_`Graph_8_source'_`hze'.xlsx", firstrow(variable)replace
}
}






*--------------------------TABLEAUX

local i =1 

**Tableau 1 WP: élasticité du CPI à une appréciation de l'euro 2011 en devise nationale

foreach year in 1995 1996 1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 {
	use "$dir/Results/Devaluations/mean_chg_TIVA_HC_`year'.dta", clear
	keep if strpos("$eurozone",c)!=0
	
	merge 1:1 c using "$dir/Bases/Pays_FR.dta",keep(3)
	drop _merge 
	
	if `year'==1995 local column A
	if `year'==1996 local column C
	if `year'==1997 local column D
	if `year'==1998 local column E
	if `year'==1999 local column F
	if `year'==2000 local column G
	if `year'==2001 local column H
	if `year'==2002 local column I
	if `year'==2003 local column J
	if `year'==2004 local column K
	if `year'==2005 local column L
	if `year'==2006 local column M
	if `year'==2007 local column N
	if `year'==2008 local column O
	if `year'==2009 local column P
	if `year'==2010 local column Q
	if `year'==2011 local column R
		
	keep c_full_FR shockEUR1
	order c_full_FR
	if `year'!=1995 drop c_full_FR 
	rename shockEUR1 _`year'
	replace _`year' = (_`year' - 1)/2	
	export excel "$dir/Results/Devaluations/TIVA_Tableau_1.xlsx", firstrow(variables) cell(`column'1) sheetmodify
}
	
foreach year in 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 {
	use "$dir/Results/Devaluations/mean_chg_WIOD_HC_`year'.dta", clear
	keep if strpos("$eurozone",c)!=0
	
	merge 1:1 c using "$dir/Bases/Pays_FR.dta",keep(3)
	drop _merge 
	if `year'==2000 local column A
	if `year'==2001 local column C
	if `year'==2002 local column D
	if `year'==2003 local column E
	if `year'==2004 local column F
	if `year'==2005 local column G
	if `year'==2006 local column H
	if `year'==2007 local column I
	if `year'==2008 local column J
	if `year'==2009 local column K
	if `year'==2010 local column L
	if `year'==2011 local column M
	if `year'==2012 local column N
	if `year'==2013 local column O
	if `year'==2014 local column P
	keep c_full_FR shockEUR1
	order c_full_FR
	if `year'!=2000 drop c_full_FR 
	rename shockEUR1 _`year'
	replace _`year' = (_`year' - 1)/2	
	export excel "$dir/Results/Devaluations/WIOD_Tableau_1.xlsx", firstrow(variables) cell(`column'1) sheetmodify
}
	

	
	***Tableau 3 WP: élasticité à une appréciation d'une monnaie d'un des pays origin

/*
*local orig USA CHN JPN GBR EAS RUS 
foreach source in  WIOD TIVA { 
foreach year in  2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 {
use "$dir/Results/Devaluations/mean_chg_`source'_HC_`year'.dta", clear
drop if strpos("$eurozone",c)==0

merge 1:1 c using "$dir/Bases/Pays_FR.dta",keep(3)
drop _merge    

keep c_full_FR  shockUSA1 shockCHN1 shockJPN1 shockGBR1 shockEAS1 shockRUS1 
order c_full_FR shockGBR1 shockUSA1 shockJPN1 shockEAS1 shockCHN1 shockRUS1  
rename shockGBR1 Royaume_Uni
rename shockUSA1 États_Unis
rename shockJPN1 Japon
rename shockEAS1 Pecos_hors_ZE
rename shockCHN1 Chine
rename shockRUS1 Russie

export excel "$dir/Results/Devaluations/`source'_HC_Tab2_`year'.xlsx", firstrow(variables) sheetmodify
}
}
*/

	*** élasticité à une appréciation d'une monnaie d'un des pays origin
*local orig USA CHN JPN GBR EAS RUS AUS BRA CHE CAN DNK IDN IND KOR MEX NOR SWE TUR 
foreach source in  WIOD TIVA { 
foreach year in  2000  2011 {
use "$dir/Results/Devaluations/mean_chg_`source'_HC_`year'.dta", clear
drop if strpos("$eurozone",c)==0

merge 1:1 c using "$dir/Bases/Pays_FR.dta",keep(3)
drop _merge    

keep c_full_FR  shockUSA1 shockCHN1 shockJPN1 shockGBR1 shockEAS1 shockRUS1  shockAUS1 shockBRA1 shockCHE1 shockCAN1 shockDNK1 shockIDN1 shockIND1 shockKOR1 shockMEX1 shockNOR1 shockSWE1 shockTUR1
order c_full_FR shockGBR1 shockUSA1 shockJPN1 shockEAS1 shockCHN1 shockRUS1  shockAUS1 shockBRA1 shockCHE1 shockCAN1 shockDNK1 shockIDN1 shockIND1 shockKOR1 shockMEX1 shockNOR1 shockSWE1 shockTUR1
rename shockGBR1 Royaume_Uni
rename shockUSA1 États_Unis
rename shockJPN1 Japon
rename shockEAS1 Pecos_hors_ZE
rename shockCHN1 Chine
rename shockRUS1 Russie
rename shockAUS1 Australie
rename shockBRA1 Brésil
rename shockCHE1 Suisse
rename shockCAN1 Canada
rename shockDNK1 Danemark
rename shockIDN1 Indonésie
rename shockIND1 Inde
rename shockKOR1 Corée
rename shockMEX1 Mexique
rename shockNOR1 Norvège
rename shockSWE1 Suède
rename shockTUR1 Turquie
export excel "$dir/Results/Devaluations/`source'_HC_Tabl2long_`year'.xlsx", firstrow(variables) sheetmodify
}
}


***élasticité des membres ZE à une appréciation d'une monnaie d'un des pays origin
* Comparaison de TIVA et WIOD
foreach  orig in  USA CHN JPN GBR EAS RUS AUS BRA CHE CAN DNK IDN IND KOR MEX NOR SWE TUR {
foreach year in   2011  {
use "$dir/Results/Devaluations/mean_chg_TIVA_HC_`year'.dta", clear
drop if strpos("$eurozone",c)==0
merge 1:1 c using "$dir/Bases/Pays_FR.dta",keep(3)
drop _merge    

keep c c_full_FR  shock`orig'1 
rename shock`orig'1 shock`orig'1_TIVA_`year'
save "$dir/Results/Devaluations/Compa_Tabl2longZE_TIVA_`year'_`orig'_old.dta", replace


use "$dir/Results/Devaluations/mean_chg_WIOD_HC_`year'.dta", clear
drop if strpos("$eurozone",c)==0

merge 1:1 c using "$dir/Bases/Pays_FR.dta",keep(3)
drop _merge    
rename shock`orig'1 shock`orig'1_WIOD_`year'
merge 1:1 c using "$dir/Results/Devaluations/Compa_Tabl2longZE_TIVA_`year'_`orig'_old.dta"
drop _merge	


keep c_full_FR  shock`orig'1*
order c_full_FR shock`orig'1_WIOD* shock`orig'1_TIVA*
export excel "$dir/Results/Devaluations/Compa_Tabl2longZE_`year'_`orig'.xlsx", firstrow(variables)   replace
}
}

***élasticité des membres ZE et des autres pays à une appréciation d'une monnaie d'un des pays origin
* Comparaison de TIVA et WIOD
foreach  orig in  USA CHN JPN GBR EAS RUS AUS BRA CHE CAN DNK IDN IND KOR MEX NOR SWE TUR {
foreach year in   2011  {
use "$dir/Results/Devaluations/mean_chg_TIVA_HC_`year'.dta", clear
*drop if strpos("$eurozone",c)==0
merge 1:1 c using "$dir/Bases/Pays_FR.dta",keep(3)
drop _merge    

keep c c_full_FR  shock`orig'1 
rename shock`orig'1 shock`orig'1_TIVA_`year'
save "$dir/Results/Devaluations/Compa_Tabl2long_TIVA_`year'_`orig'_old.dta", replace


use "$dir/Results/Devaluations/mean_chg_WIOD_HC_`year'.dta", clear
*drop if strpos("$eurozone",c)==0

merge 1:1 c using "$dir/Bases/Pays_FR.dta",keep(3)
drop _merge    
rename shock`orig'1 shock`orig'1_WIOD_`year'
merge 1:1 c using "$dir/Results/Devaluations/Compa_Tabl2long_TIVA_`year'_`orig'_old.dta"
drop _merge	


keep c c_full_FR  shock`orig'1*
order c c_full_FR shock`orig'1_WIOD* shock`orig'1_TIVA*
export excel "$dir/Results/Devaluations/Compa_Tabl2long_`year'_`orig'.xlsx", firstrow(variables)   replace
save "$dir/Results/Devaluations/Compa_Tabl2long_`year'_`orig'.dta", replace
}
}

***Tableau 4 WP: récupère la colonne shockEAS1 pour les pays de la ZE 

foreach year in  2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 {
	use "$dir/Results/Devaluations/mean_chg_WIOD_HC_`year'.dta", clear
	keep if strpos("$eurozone",c)!=0
	
	if `year'==2000 local column A
	if `year'==2001 local column C
	if `year'==2002 local column D
	if `year'==2003 local column E
	if `year'==2004 local column F
	if `year'==2005 local column G
	if `year'==2006 local column H
	if `year'==2007 local column I
	if `year'==2008 local column J
	if `year'==2009 local column K
	if `year'==2010 local column L
	if `year'==2011 local column M
	if `year'==2012 local column N
	if `year'==2013 local column O
	if `year'==2014 local column P
	
	* importation des noms de pays entiers 
	merge 1:1 c using "$dir/Bases/Pays_FR.dta",keep(3)
	drop _merge 
	
	keep c_full_FR shockEAS1
	order c_full_FR
	if `year'!=2000 drop c_full_FR
	rename shockEAS1 _`year'
	export excel "$dir/Results/Devaluations/WIOD_Tableau_4.xlsx", firstrow(variables) cell(`column'1) sheetmodify
}
	
	
foreach year in 1995 1996 1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011  {
	use "$dir/Results/Devaluations/mean_chg_TIVA_HC_`year'.dta", clear
	keep if strpos("$eurozone",c)!=0
	
	if `year'==1995 local column A
	if `year'==1996 local column C
	if `year'==1997 local column D
	if `year'==1998 local column E
	if `year'==1999 local column F
	if `year'==2000 local column G
	if `year'==2001 local column H
	if `year'==2002 local column I
	if `year'==2003 local column J
	if `year'==2004 local column K
	if `year'==2005 local column L
	if `year'==2006 local column M
	if `year'==2007 local column N
	if `year'==2008 local column O
	if `year'==2009 local column P
	if `year'==2010 local column Q
	if `year'==2011 local column R

	
	* importation des noms de pays entiers 
	merge 1:1 c using "$dir/Bases/Pays_FR.dta",keep(3)
	drop _merge 
	
	keep c_full_FR shockEAS1
	order c_full_FR
	if `year'!=1995 drop c_full_FR
	rename shockEAS1 _`year'
	export excel "$dir/Results/Devaluations/TIVA_Tableau_4.xlsx", firstrow(variables) cell(`column'1) sheetmodify
	
}


**Graphique 9 de comparaison des impacts sur HC obtenus avec TIVA et WIOD

foreach  orig in  USA  {
foreach year in   2011  {
use "$dir/Results/Devaluations/Compa_Tabl2long_`year'_`orig'.dta", clear

label var shock`orig'1_WIOD_`year' "WIOD"
label var shock`orig'1_TIVA_`year' "TIVA"

local countryorig "`orig'"
*drop if strpos("$countryorig",c)==`countryorig'

graph bar (asis) shock`orig'1_WIOD_`year' shock`orig'1_TIVA_`year'   , title("Elasticité prix conso. à un choc `orig'") over(c_full_FR, sort(c_full_FR)  label(angle(vertical) labsize(vsmall))) 
graph export "$dir/Results/Devaluations/HC_Graph_9_`orig'.png", replace
}
}





end
graphiques `source' 

