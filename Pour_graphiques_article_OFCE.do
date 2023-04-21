clear  
set more off
if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA"
else global dir "\\intra\partages\au_dcpm\DiagConj\Commun\CommerceVA"


*capture log close
*log using "$dir/$S_DATE.log", replace

capture program drop  pour_graphiques_article_OFCE
program pour_graphiques_article_OFCE
args source 

if ("`c(username)'"=="guillaumedaudin") do  "~/Documents/Recherche/2017 BDF_Commerce VA/commerce_VA_inflation/Definition_pays_secteur.do" `source'
if ("`c(username)'"=="w817186") do "X:\Agents\FAUBERT\commerce_VA_inflation\Definition_pays_secteur.do" `source'
if ("`c(username)'"=="n818881") do  "X:\Agents\LALLIARD\commerce_VA_inflation\Definition_pays_secteur.do" `source'
	


*--------------------------
*-----------------Pour graphiques
*--------------------------


*GRAPHIQUE 1: elasticité des prix de production et d'exportation en monnaie locale à une appréciation de la monnaie locale
*tiva

set more off

use "$dir/Results/Devaluations/mean_chg_TIVA_X_2011.dta", clear

foreach var of varlist shockEUR1-shockZAF1 {
	local pays = substr("`var'",6,3)
	replace `var' = 0 if strmatch(c,"*`pays'*")==0
}

egen pond_TIVA_X = rowtotal(shockEUR1-shockZAF1)
replace pond_TIVA_X = (pond_TIVA_X - 1)/2

keep c pond_TIVA_X

save "$dir/Results/Devaluations/Pour_Graph_1_TIVA.dta", replace


use "$dir/Results/Devaluations/mean_chg_TIVA_Yt_2011.dta", clear

foreach var of varlist shockEUR1-shockZAF1 {
	local pays = substr("`var'",6,3)
	replace `var' = 0 if strmatch(c,"*`pays'*")==0
}

egen pond_TIVA_Y = rowtotal(shockEUR1-shockZAF1)

keep c pond_TIVA_Y

merge 1:1 c using "$dir/Bases/Pays_FR.dta",keep(3)
drop _merge



merge 1:1 c using "$dir/Results/Devaluations/Pour_Graph_1_TIVA.dta"

drop _merge 

replace pond_TIVA_Y = (pond_TIVA_Y - 1)/2 

label var pond_TIVA_Y "Prix de production"

label var pond_TIVA_X "Prix d'exportation"

save "$dir/Results/Devaluations/Pour_Graph_1_TIVA_old.dta", replace
export delimited "$dir/Results/Devaluations/Pour_Graph_1_TIVA_old.csv", replace


graph bar (asis) pond_TIVA_X pond_TIVA_Y , over(c, sort(pond_TIVA_X) label(angle(vertical) labsize(small))) 

graph export "$dir/Results/Devaluations/Graph_1_TIVA_old.png", replace

drop if strpos("$eurozone",c)==0


graph bar (asis) pond_TIVA_X pond_TIVA_Y , yscale(range(-0.5 0.0))  ylabel(-0.5 (0.1) 0.0)  title("Elasticité à une appréciation de la monnaie locale, 2011") over(c_full_FR, sort(c_full_FR) label(angle(vertical) labsize(small)))


graph export "$dir/Results/Devaluations/Graph_1_TIVA.png", replace
save "$dir/Results/Devaluations/Pour_Graph_1_TIVA.dta", replace
export delimited "$dir/Results/Devaluations/Pour_Graph_1_TIVA.csv", replace
export excel "$dir/Results/Devaluations/Pour_Graph_1_TIVA.xlsx", firstrow(variable)replace


*GRAPHIQUE 1: elasticité des prix de production et d'exportation en monnaie locale à une appréciation de la monnaie locale
*WIOD


use "$dir/Results/Devaluations/mean_chg_WIOD_X_2011.dta", clear

foreach var of varlist shockEUR1-shockUSA1 {
	local pays = substr("`var'",6,3)
	replace `var' = 0 if strmatch(c,"*`pays'*")==0
}

egen pond_WIOD_X = rowtotal(shockEUR1-shockUSA1)
replace pond_WIOD_X = (pond_WIOD_X - 1)/2

keep c pond_WIOD_X

save "$dir/Results/Devaluations/Pour_Graph_1_WIOD.dta", replace


use "$dir/Results/Devaluations/mean_chg_WIOD_Yt_2011.dta", clear

foreach var of varlist shockEUR1-shockUSA1 {
	local pays = substr("`var'",6,3)
	replace `var' = 0 if strmatch(c,"*`pays'*")==0
}

egen pond_WIOD_Y = rowtotal(shockEUR1-shockUSA1)

keep c pond_WIOD_Y

merge 1:1 c using "$dir/Bases/Pays_FR.dta",keep(3)
drop _merge


merge 1:1 c using "$dir/Results/Devaluations/Pour_Graph_1_WIOD.dta"

drop _merge 

replace pond_WIOD_Y = (pond_WIOD_Y - 1)/2 

label var pond_WIOD_Y "Prix de production"

label var pond_WIOD_X "Prix d'exportation"

save "$dir/Results/Devaluations/Pour_Graph_1_WIOD_old.dta", replace
export delimited "$dir/Results/Devaluations/Pour_Graph_1_WIOD_old.csv", replace

graph bar (asis) pond_WIOD_X pond_WIOD_Y , yscale(range(-0.5 0.0))  ylabel(-0.5 (0.1) 0.0) title("Elasticité à une appréciation de la monnaie locale, 2011") over(c, sort(pond_WIOD_X) label(angle(vertical) labsize(small))) 

graph export "$dir/Results/Devaluations/Graph_1_WIOD_old.png", replace

drop if strpos("$eurozone",c)==0

graph bar (asis) pond_WIOD_X pond_WIOD_Y , over(c_full_FR, sort(c_full_FR) label(angle(vertical) labsize(small)))


graph export "$dir/Results/Devaluations/Graph_1_WIOD.png", replace
save "$dir/Results/Devaluations/Pour_Graph_1_WIOD.dta", replace
export delimited "$dir/Results/Devaluations/Pour_Graph_1_WIOD.csv", replace
export excel "$dir/Results/Devaluations/Pour_Graph_1_WIOD.xlsx", firstrow(variable)replace


*Graphique 2 : elasticité des prix d'exportation en monnaie locale à une appréciation de la monnaie locale
*TIVA

use "$dir/Results/Devaluations/mean_chg_TIVA_X_2000.dta", clear

foreach var of varlist shockEUR1-shockZAF1 {
	local pays = substr("`var'",6,3)
	replace `var' = 0 if strmatch(c,"*`pays'*")==0
}

egen pond_TIVA_X_2000 = rowtotal(shockEUR1-shockZAF1)
replace pond_TIVA_X_2000 = (pond_TIVA_X_2000 - 1)/2

keep c pond_TIVA_X_2000

merge 1:1 c using "$dir/Results/Devaluations/Pour_Graph_1_TIVA_old.dta"
drop _merge

rename pond_TIVA_X pond_TIVA_X_2011

drop pond_TIVA_Y


label var pond_TIVA_X_2000 "Prix d'exportation, 2000"

label var pond_TIVA_X_2011 "Prix d'exportation, 2011"

save "$dir/Results/Devaluations/Pour_Graph_2_TIVA_old.dta", replace
export delimited "$dir/Results/Devaluations/Pour_Graph_2_TIVA_old.csv", replace


graph bar (asis) pond_TIVA_X_2000 pond_TIVA_X_2011 , yscale(range(-0.5 0.0))  ylabel(-0.5 (0.1) 0.0) title("Elasticité à une appréciation de la monnaie locale")  over(c, sort(c_full_FR) label(angle(vertical) labsize(small))) 

graph export "$dir/Results/Devaluations/Graph_2_TIVA_old.png", replace

drop if strpos("$eurozone",c)==0

merge 1:1 c using "$dir/Bases/Pays_FR.dta",keep(3)
drop _merge

label var pond_TIVA_X_2000 "2000"

label var pond_TIVA_X_2011 "2011"

graph bar (asis) pond_TIVA_X_2011 pond_TIVA_X_2000  , yscale(range(-0.5 0.0))  ylabel(-0.5 (0.1) 0.0) title("Elasticité à une appréciation de la monnaie locale") over(c_full_FR, sort(c_full_FR) label(angle(vertical) labsize(small))) 

graph export "$dir/Results/Devaluations/Graph_2_TIVA.png", replace
save "$dir/Results/Devaluations/Pour_Graph_2_TIVA.dta", replace
export delimited "$dir/Results/Devaluations/Pour_Graph_2_TIVA.csv", replace
export excel "$dir/Results/Devaluations/Pour_Graph_2_TIVA.xlsx", firstrow(variable)replace



*Graphique 2 : elasticité des prix d'exportation en monnaie locale à une appréciation de la monnaie locale
*WIOD

use "$dir/Results/Devaluations/mean_chg_WIOD_X_2000.dta", clear

foreach var of varlist shockEUR1-shockUSA1 {
	local pays = substr("`var'",6,3)
	replace `var' = 0 if strmatch(c,"*`pays'*")==0
}

egen pond_WIOD_X_2000 = rowtotal(shockEUR1-shockUSA1)
replace pond_WIOD_X_2000 = (pond_WIOD_X_2000 - 1)/2

keep c pond_WIOD_X_2000

merge 1:1 c using "$dir/Results/Devaluations/Pour_Graph_1_WIOD_old.dta"
drop _merge



rename pond_WIOD_X pond_WIOD_X_2011


drop pond_WIOD_Y


label var pond_WIOD_X_2000 "Prix d'exportation, 2000"

label var pond_WIOD_X_2011 "Prix d'exportation, 2011"

save "$dir/Results/Devaluations/Pour_Graph_2_WIOD_old.dta", replace
export delimited "$dir/Results/Devaluations/Pour_Graph_2_WIOD_old.csv", replace


graph bar (asis) pond_WIOD_X_2000 pond_WIOD_X_2011 ,  yscale(range(-0.5 0.0))  ylabel(-0.5 (0.1) 0.0) title("Elasticité à une appréciation de la monnaie locale")  over(c, sort(c_full_FR) label(angle(vertical) labsize(small))) 

graph export "$dir/Results/Devaluations/Graph_2_WIOD_old.png", replace

drop if strpos("$eurozone",c)==0

*merge 1:1 c using "$dir/Bases/Pays_FR.dta",keep(3)
*drop _merge

label var pond_WIOD_X_2000 "2000"

label var pond_WIOD_X_2011 "2011"

graph bar (asis) pond_WIOD_X_2011 pond_WIOD_X_2000  ,  yscale(range(-0.5 0.0))  ylabel(-0.5 (0.1) 0.0) title("Elasticité à une appréciation de la monnaie locale") over(c_full_FR, sort(c_full_FR)  label(angle(vertical) labsize(small))) 


graph export "$dir/Results/Devaluations/Graph_2_WIOD.png", replace
save "$dir/Results/Devaluations/Pour_Graph_2_WIOD.dta", replace
export delimited "$dir/Results/Devaluations/Pour_Graph_2_WIOD.csv", replace
export excel "$dir/Results/Devaluations/Pour_Graph_2_WIOD.xlsx", firstrow(variable)replace



**Graphique 3: élasticité des prix de prod et d'exportations en euros à une appréciation de l'euro
foreach source in TIVA WIOD {

use "$dir/Results/Devaluations/mean_chg_`source'_X_2011.dta", clear

keep c shockEUR1
drop if strpos("$eurozone",c)==0
rename shockEUR1 pond_`source'_X
replace pond_`source'_X = (pond_`source'_X - 1)/2

save "$dir/Results/Devaluations/Pour_Graph_3_`source'.dta", replace

use "$dir/Results/Devaluations/mean_chg_`source'_Yt_2011.dta", clear

keep c shockEUR1
drop if strpos("$eurozone",c)==0

rename shockEUR1 pond_`source'_Yt
replace pond_`source'_Yt = (pond_`source'_Yt - 1)/2

merge 1:1 c using "$dir/Results/Devaluations/Pour_Graph_3_`source'.dta"
drop _merge

merge 1:1 c using "$dir/Bases/Pays_FR.dta",keep(3)
drop _merge

label var pond_`source'_Yt "Prix de production"

label var pond_`source'_X "Prix d'exportation"

save "$dir/Results/Devaluations/Pour_Graph_3_`source'.dta", replace
export delimited "$dir/Results/Devaluations/Pour_Graph_3_`source'.csv", replace
export excel "$dir/Results/Devaluations/Pour_Graph_3_`source'.xlsx", firstrow(variable)replace

graph bar (asis) pond_`source'_X pond_`source'_Yt , yscale(range(-0.5 0.0))  ylabel(-0.5 (0.1) 0.0) title("Elasticité à une appréciation de l'euro, 2011")  over(c_full_FR, sort(c_full_FR) label(angle(vertical) )) 
graph export "$dir/Results/Devaluations/Graph_3_`source'.png", replace
}

**Graphique 4 : élasticité des prix en monnaie locale des pays hors ze à une appréciation de l'euro

foreach source in TIVA WIOD {
use "$dir/Results/Devaluations/mean_chg_`source'_X_2011.dta", clear

keep c shockEUR1
drop if strpos("$eurozone",c)!=0
rename shockEUR1 pond_`source'_X


save "$dir/Results/Devaluations/Pour_Graph_4_`source'.dta", replace

use "$dir/Results/Devaluations/mean_chg_`source'_Yt_2011.dta", clear

keep c shockEUR1
drop if strpos("$eurozone",c)!=0
rename shockEUR1 pond_`source'_Yt

merge 1:1 c using "$dir/Bases/Pays_FR.dta",keep(3)
drop _merge


merge 1:1 c using "$dir/Results/Devaluations/Pour_Graph_4_`source'.dta"
drop _merge

label var pond_`source'_Yt "Prix de production"

label var pond_`source'_X "Prix d'exportation"

save "$dir/Results/Devaluations/Pour_Graph_4_`source'.dta", replace
export delimited "$dir/Results/Devaluations/Pour_Graph_4_`source'.csv", replace
export excel "$dir/Results/Devaluations/Pour_Graph_4_`source'.xlsx", firstrow(variable)replace

graph bar (asis) pond_`source'_X pond_`source'_Yt , yscale(range(0.0 0.8))  ylabel(0.0 (0.1) 0.8) title("Elasticité à une appréciation de l'euro, 2011")over(c_full_FR, sort(c_full_FR)  label(angle(vertical) labsize(vsmall))) 

graph export "$dir/Results/Devaluations/Graph_4_`source'.png", replace

}



*GRAPHIQUE 5
*TIVA
/*
use "$dir/Results/Choc de prod/mean_TIVA_p_X_2011.dta", clear

merge 1:1 _n using "$dir/Bases/pays_en_ligne.dta
drop _merge

foreach var of varlist shockARG1-shockZAF1 {
	local pays = substr("`var'",6,3)
	replace `var' = 0 if strmatch(c,"*`pays'*")==0
}

egen pond_TIVA_X = rowtotal(shockARG1-shockZAF1)
replace pond_TIVA_X = (pond_TIVA_X - 1)


keep c pond_TIVA_X

save "$dir/Results/Choc de prod/Pour_Graph_5_TIVA.dta", replace


use "$dir/Results/Choc de prod/mean_TIVA_p_Yt_2011.dta", clear
merge 1:1 _n using "$dir/Bases/pays_en_ligne.dta
drop _merge


foreach var of varlist shockARG1-shockZAF1 {
	local pays = substr("`var'",6,3)
	replace `var' = 0 if strmatch(c,"*`pays'*")==0
}

egen pond_TIVA_Y = rowtotal(shockARG1-shockZAF1)

keep c pond_TIVA_Y

merge 1:1 c using "$dir/Results/Choc de prod/Pour_Graph_5_TIVA.dta"
drop _merge

merge 1:1 c using "$dir/Bases/Pays_FR.dta",keep(3)
drop _merge 

replace pond_TIVA_Y = (pond_TIVA_Y - 1)

label var pond_TIVA_Y "Prix de production"

label var pond_TIVA_X "Prix d'exportation"

save "$dir/Results/Choc de prod/Pour_Graph_5_TIVA_old.dta", replace
export delimited "$dir/Results/Choc de prod/Pour_Graph_5_TIVA_old.csv", replace
export excel "$dir/Results/Choc de prod/Pour_Graph_5_TIVA_old.xslx", firstrow(variable)replace
graph export "$dir/Results/Choc de prod/Graph_5_TIVA_old.png", replace



graph bar (asis) pond_TIVA_X pond_TIVA_Y , over(c_full_FR, sort(pond_TIVA_X) descending label(angle(vertical) labsize(tiny))) 


drop if strpos("$eurozone",c)==0

graph bar (asis) pond_TIVA_X pond_TIVA_Y , over(c_full_FR, sort(pond_TIVA_X) descending label(angle(vertical) labsize(small))) 

save "$dir/Results/Choc de prod/Pour_Graph_5_TIVA.dta", replace
export delimited "$dir/Results/Choc de prod/Pour_Graph_5_TIVA.csv", replace
export excel "$dir/Results/Choc de prod/Pour_Graph_5_TIVA.xslx", firstrow(variable)replace
graph export "$dir/Results/Choc de prod/Graph_5_TIVA.png", replace




*GRAPHIQUE 5
*WIOD

use "$dir/Results/Choc de prod/mean_WIOD_p_X_2011.dta", clear

merge 1:1 _n using "$dir/Bases/pays_en_ligne.dta
drop _merge

foreach var of varlist shockARG1-shockUSA1 {
	local pays = substr("`var'",6,3)
	replace `var' = 0 if strmatch(c,"*`pays'*")==0
}

egen pond_WIOD_X = rowtotal(shockARG1-shockUSA1)
replace pond_WIOD_X = (pond_WIOD_X - 1)


keep c pond_WIOD_X

save "$dir/Results/Choc de prod/Pour_Graph_5_WIOD.dta", replace


use "$dir/Results/Choc de prod/mean_WIOD_p_Yt_2011.dta", clear
merge 1:1 _n using "$dir/Bases/pays_en_ligne.dta
drop _merge


foreach var of varlist shockARG1-shockUSA1 {
	local pays = substr("`var'",6,3)
	replace `var' = 0 if strmatch(c,"*`pays'*")==0
}

egen pond_WIOD_Y = rowtotal(shockARG1-shockUSA1)

keep c pond_WIOD_Y

merge 1:1 c using "$dir/Results/Choc de prod/Pour_Graph_5_WIOD.dta"
drop _merge

merge 1:1 c using "$dir/Bases/Pays_FR.dta",keep(3)
drop _merge 

replace pond_WIOD_Y = (pond_WIOD_Y - 1)

label var pond_WIOD_Y "Prix de production"

label var pond_WIOD_X "Prix d'exportation"

save "$dir/Results/Choc de prod/Pour_Graph_5_WIOD_old.dta", replace
export delimited "$dir/Results/Choc de prod/Pour_Graph_5_WIOD_old.csv", replace
export excel "$dir/Results/Choc de prod/Pour_Graph_5_WIOD_old.xslx", firstrow(variable)replace
graph export "$dir/Results/Choc de prod/Graph_5_TIVA_old.png", replace



graph bar (asis) pond_WIOD_X pond_WIOD_Y , over(c_full_FR, sort(pond_WIOD_X) descending label(angle(vertical) labsize(tiny))) 


drop if strpos("$eurozone",c)==0

graph bar (asis) pond_WIOD_X pond_WIOD_Y , over(c_full_FR, sort(pond_WIOD_X) descending label(angle(vertical) labsize(small))) 

save "$dir/Results/Choc de prod/Pour_Graph_5_TIVA.dta", replace
export delimited "$dir/Results/Choc de prod/Pour_Graph_5_TIVA.csv", replace
export excel "$dir/Results/Choc de prod/Pour_Graph_5_TIVA.xslx", firstrow(variable)replace
graph export "$dir/Results/Choc de prod/Graph_5_TIVA.png", replace

*/



***************************************
*Pour tableaux
**********************




**Tableau 0


local i =1 

foreach source in WIOD TIVA {

	foreach pond in X Yt {

		foreach orig in USA EUR CHN JPN GBR RUS  EAS {
			use "$dir/Results/Devaluations/mean_chg_`source'_`pond'_2011.dta", clear
			format shock* %3.2f
			keep c shock`orig'1
			gsort - shock`orig'1
		
			drop if strmatch(c,"*`orig'*")==1
			if "`orig'"=="EUR" drop if strpos("$eurozone",c)!=0
			if "`orig'"=="EAS" drop if strpos("$eastern",c)!=0

		
		
			keep if _n<=10
		
			if "`orig'"=="USA" local column A
			if "`orig'"=="EUR" local column C
			if "`orig'"=="CHN" local column E
			if "`orig'"=="JPN" local column G
			if "`orig'"=="GBR" local column I
			if "`orig'"=="RUS" local column K
			if "`orig'"=="EAS" local column M
		
			export excel "$dir/Results/Devaluations/Tableau_1_old_`source'_`pond'.xlsx", firstrow(variables) cell(`column'1) sheetmodify

		}
	}
}
***Tableau 1
**Elasticité des prix d'exportations en euros à une appréciation de l'euro 

foreach year in 1995 1996 1997 1998 1999 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 {
		use "$dir/Results/Devaluations/mean_chg_TIVA_X_`year'.dta", clear
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
		
		
		export excel "$dir/Results/Devaluations/Tableau_1_TIVA.xlsx", firstrow(variables) cell(`column'1) sheetmodify

}
	
	

foreach year in 2000 2001 2002 2003 2004 2005 2006 2007 2008 2009 2010 2011 2012 2013 2014 {
		use "$dir/Results/Devaluations/mean_chg_WIOD_X_`year'.dta", clear
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
		
		
		export excel "$dir/Results/Devaluations/Tableau_1_WIOD.xlsx", firstrow(variables) cell(`column'1) sheetmodify

}
	

***Tableau 2
**Elasticité des prix de production en euros des membres de la ZE à une appréciation des pays origin


local orig USA CHN JPN GBR EAS RUS AUS BRA CHE CAN DNK IDN IND KOR MEX NOR SWE TUR 

foreach source in WIOD TIVA {
	use "$dir/Results/Devaluations/mean_chg_`source'_Yt_2011.dta", clear
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


	export excel "$dir/Results/Devaluations/Tableau_2_`source'.xlsx", firstrow(variables) sheetmodify

}
	
	
***Tableau 3
*** Elasticité des prix d'exportations en euros de la ZE à une appréciation de la monnaie des pays origin

local orig USA CHN JPN GBR EAS RUS AUS BRA CHE CAN DNK IDN IND KOR MEX NOR SWE TUR 

foreach source in WIOD TIVA {
	use "$dir/Results/Devaluations/mean_chg_`source'_X_2011.dta", clear
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

	export excel "$dir/Results/Devaluations/Tableau_3_`source'.xlsx", firstrow(variables) sheetmodify
}
	

***Tableau 4
*** Elasticité des prix d'exportations en euro de la ZE à une appréciation d'une monnaie des PECO hors ZE 

foreach source in WIOD TIVA {
	foreach year in  2000 2005 2009 2010 2011 {
		use "$dir/Results/Devaluations/mean_chg_`source'_X_`year'.dta", clear
		keep if strpos("$eurozone",c)!=0
		
		if `year'==2000 local column A
		if `year'==2005 local column C
		if `year'==2009 local column D
		if `year'==2010 local column E
		if `year'==2011 local column F

			
		merge 1:1 c using "$dir/Bases/Pays_FR.dta",keep(3)
		drop _merge 
		
		keep c_full_FR shockEAS1
		order c_full_FR
		if `year'!=2000 drop c_full_FR
		rename shockEAS1 _`year'
		
		
		
		export excel "$dir/Results/Devaluations/Tableau_4_`source'.xlsx", firstrow(variables) cell(`column'1) sheetmodify
	}
}





***Tableau 5
*** Elasticité des prix de production de la ZE à un choc de productivité négatif domestique
/*	
use "$dir/Results/Choc de prod/mean_p_X_2011.dta", clear


foreach euro of global eurozone {
		local tokeep `tokeep' + shock`euro'
}

merge 1:1 _n using "$dir/Bases/pays_en_ligne.dta
drop _merge
order c

keep if strpos("$eurozone",c)!=0


local tokeep c 
foreach euro of global eurozone {
		rename shock`euro'1 `euro'
		local tokeep `tokeep' `euro'
		replace `euro'=`euro'-1 if c=="`euro'"
}

keep `tokeep'

*egen Zone_euro =rowtotal(AUT-SVN)

*foreach euro in BEL DEU ESP FRA ITA LUX NLD {
*		replace `euro'=. if c=="`euro'"
*}


*gen Europe_Est = (SVK + SVN + EST + LTU + LVA)
drop SVK SVN EST LTU LVA
*gen Europe_Sud = (CYP + GRC + MLT + PRT)
drop CYP  GRC  MLT  PRT
*gen AUT_IRL_FIN = (AUT + IRL + FIN)
drop AUT IRL FIN

drop BEL




*rename BEL Belgique
rename DEU Allemagne
rename ESP Espagne
rename FRA France
rename ITA Italie
*rename LUX Luxembourg
rename NLD Pays_Bas

drop LUX

merge 1:1 c using "$dir/Bases/Pays_FR.dta",keep(3)
drop _merge 
drop c
order c_full_FR Allemagne  *

export excel "$dir/Results/Choc de prod/Tableau_5.xlsx", firstrow(variables) replace



***Tableau 6
***Elasticité des prix d'exportations de la ZE à un choc de productivité des pays dans les pays cités

use "$dir/Results/Choc de prod/mean_p_X_2011.dta", clear


foreach euro of global eurozone {
		local tokeep `tokeep' + shock`euro'
}

merge 1:1 _n using "$dir/Bases/pays_en_ligne.dta
drop _merge
order c
keep if strpos("$eurozone",c)!=0

foreach east of global eastern {
		rename shock`east'1 `east'
}

egen Pecos_hors_ZE= rowtotal($eastern)



foreach east of global eastern_ZE {
		rename shock`east'1 `east'
}

egen Pecos_ZE= rowtotal($eastern_ZE)


local tokeep c Pecos_hors_ZE Pecos_ZE
foreach pays in USA CHN JPN GBR RUS SAU {
		rename shock`pays'1 `pays'
		local tokeep `tokeep' `pays'
}


keep `tokeep'


rename GBR Royaume_Uni
rename USA États_Unis
rename JPN Japon
rename CHN Chine
rename RUS Russie
rename SAU Arabie_Saoudite

merge 1:1 c using "$dir/Bases/Pays_FR.dta",keep(3)
drop _merge 
drop c
order c_full_FR Pecos_hors_ZE Pecos_ZE

order c_full_FR Pecos_hors_ZE  Pecos_ZE  Royaume_Uni  États_Unis Japon Chine 

export excel "$dir/Results/Choc de prod/Tableau_6.xlsx", firstrow(variables) replace

*/


**------------------ Pour graphiques de la fin



/*

*** Graphique 6
***  Elasticité des prix de production des pays de la ZE à un choc sur la monnaie nationale fictive et part des inputs importés dans la produvtion

foreach source in TIVA WIOD {
use "$dir/Bases/imp_inputs_2011.dta" , clear //,keep(3)

gen c=upper(pays)
drop pays

merge 1:1 c using "$dir/Results/Devaluations/Pour_Graph_1_`source'.dta"

drop _merge pond_`source'_X 

//replace pond_Y = (pond_Y - 1)/2 

label var pond_`source'_Y "Prix de production"

label var input_prod "Parts des inputs importés dans la production"

drop if strpos("$eurozone",c)==0

save "$dir/Results/Devaluations/Pour_Graph_imp_deval_`source'.dta", replace
*drop if c_full_FR=="Luxembourg"
graph twoway (scatter pond_`source'_Y input_prod, mlabel(c_full_FR)) (lfit pond_Y input_prod)  , ///
			xtitle("Parts des inputs importés dans la production") ytitle("Elasticité des prix de production en monnaie nationale", size(small)) ///
			yscale(range(0 -.35) reverse) xscale(range(0 .45)) xlabel (0(0.05) .45) ylabel(0 (0.05) -.35)
			
			
graph export "$dir/Results/Devaluations/Graph_6_`source'.png", replace 
export excel "$dir/Results/Devaluations/Pour_Graph_6_`source'.xlsx", firstrow(variable)replace
 /*
graph twoway (scatter pond_Y input_prod, mlabel(c_full_FR)) (lfit pond_Y input_prod)  ,    xtitle("Parts des inputs importés dans la production") ytitle("Prix de production")
graph export "$dir/Results/Devaluations/Graph_1_imp.png", replace   */

}

*** Graphique 7
***Elasticité des prix de production des pays de la ZE à un choc de change de l'euro et part des inputs importés des pays hors ZE dans la production

use "$dir/Bases/imp_inputs_hze_2011.dta", clear  //,keep(3)
//drop _merge

gen c=upper(pays)
drop pays

merge 1:1 c using "$dir/Results/Devaluations/Pour_Graph_3.dta"

drop _merge pond_X

//replace pond_Y = (pond_Y - 1)/2 

label var pond_Y "Prix de production"

label var input_prod "Parts des inputs importés en provenance de pays hors zone euro dans la production"

drop if strpos("$eurozone",c)==0

save "$dir/Results/Devaluations/Pour_Graph_imp_deval.dta", replace
//export delimited "$dir/Results/Devaluations/Pour_Graph_1_old.csv", replace

//graph twoway (scatter pond_Y input_prod, mlabel(c_full_FR)) (lfit pond_Y input_prod)  , ///
	//		xtitle("Parts des inputs importés dans la production") ytitle("Elasticité des prix de production en euro") ///
		//	yscale(range(0 -.2) reverse) xscale(range(0 .3)) xlabel (0(0.05) .3) ylabel(0 (0.05) -.2)
			

graph twoway (scatter pond_Y input_prod, mlabel(c_full_FR)) (lfit pond_Y input_prod)  , ///
			xtitle("Parts des inputs importés en provenance de pays hors zone euro dans la production") ytitle("Elasticité des prix de production en euro") ///
			yscale(range(0 -.2) reverse) xscale(range(0 .2)) xlabel (0(0.05) .2) ylabel(0 (0.05) -.2)

			
			graph export "$dir/Results/Devaluations/Graph_7.png", replace
export excel "$dir/Results/Devaluations/Pour_Graph_7.xlsx", firstrow(variable)replace




*** Graphique 8
***Elasticité des prix de production des pays de la ZE à un choc de productivité et part des inputs importés des pays hors ZE dans la production

use "$dir/Bases/loc_inputs_2011.dta", clear  //,keep(3)
//drop _merge

gen c=upper(pays)
drop pays

merge 1:1 c using "$dir/Results/Choc de prod/Pour_Graph_5.dta"

drop _merge pond_X

//replace pond_Y = (pond_Y - 1)/2 

label var pond_Y "Prix de production"

label var loc_inputs "Parts des inputs produits lacalement dans la production"

drop if strpos("$eurozone",c)==0

save "$dir/Results/Devaluations/Pour_Graph_8.dta", replace
//export delimited "$dir/Results/Devaluations/Pour_Graph_1_old.csv", replace

//graph twoway (scatter pond_Y input_prod, mlabel(c_full_FR)) (lfit pond_Y input_prod)  , ///
	//		xtitle("Parts des inputs importés dans la production") ytitle("Elasticité des prix de production en euro") ///
		//	yscale(range(0 -.2) reverse) xscale(range(0 .3)) xlabel (0(0.05) .3) ylabel(0 (0.05) -.2)
			


graph twoway (scatter pond_Y loc_inputs, mlabel(c_full_FR)) (lfit pond_Y loc_inputs)  , ///
			xtitle("Parts des inputs produits localement dans la production") ytitle("Elasticité des prix de production en euro") ///
			yscale(range(0 1)) xscale(range(0 .5)) xlabel (0(0.1) .5) ylabel(0 (0.1) 1)

			
			graph export "$dir/Results/Choc de prod/Graph_8.png", replace
export excel "$dir/Results/Choc de prod/Pour_Graph_8.xlsx", firstrow(variable)replace


*** Graphique 9 

use "$dir/Bases/imp_inputsX_2011.dta", clear  //,keep(3)
//drop _merge

gen c=upper(pays)
drop pays

merge 1:1 c using "$dir/Results/Devaluations/Pour_Graph_1.dta"

drop _merge pond_Y

//replace pond_Y = (pond_Y - 1)/2 

label var pond_X "Prix d'exportation"

label var imp_inputs "Parts des inputs importés dans les exportations"

drop if strpos("$eurozone",c)==0

save "$dir/Results/Devaluations/Pour_Graph_9.dta", replace
//export delimited "$dir/Results/Devaluations/Pour_Graph_1_old.csv", replace

//graph twoway (scatter pond_Y input_prod, mlabel(c_full_FR)) (lfit pond_Y input_prod)  , ///
	//		xtitle("Parts des inputs importés dans la production") ytitle("Elasticité des prix de production en euro") ///
		//	yscale(range(0 -.2) reverse) xscale(range(0 .3)) xlabel (0(0.05) .3) ylabel(0 (0.05) -.2)
			


graph twoway (scatter pond_X imp_inputs, mlabel(c_full_FR)) (lfit pond_X imp_inputs)  , ///
			xtitle("Parts des inputs importés en provenance de pays hors zone euro dans les exportations") ytitle("Elasticité des prix d'exportation en euro") ///
			yscale(range(0 -.3) reverse) xscale(range(0.4 .8)) xlabel (0.4(0.1) .8) ylabel(0 (0.05) -.3)


			
			graph export "$dir/Results/Devaluations/Graph_9.png", replace
export excel "$dir/Results/Devaluations/Pour_Graph_9.xlsx", firstrow(variable)replace

*/
end
pour_graphiques_article_OFCE TIVA 
pour_graphiques_article_OFCE WIOD 
