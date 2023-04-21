clear  
set more off
if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA"
	else global dir "\\intra\partages\au_dcpm\DiagConj\Commun\CommerceVA"

if ("`c(username)'"=="guillaumedaudin") global dirgit "~/Documents/Recherche/2017 BDF_Commerce VA/commerce_VA_inflation"
	else global dirgit "X:\Agents\LALLIARD"

*capture log close
*log using "$dir/$S_DATE.log", replace


if ("`c(username)'"=="guillaumedaudin") do  "~/Documents/Recherche/2017 BDF_Commerce VA/commerce_VA_inflation/Definition_pays_secteur.do" `source'
if ("`c(username)'"=="w817186") do "X:\Agents\FAUBERT\commerce_VA_inflation\Definition_pays_secteur.do" `source'
if ("`c(username)'"=="n818881") do  "X:\Agents\LALLIARD\commerce_VA_inflation\Definition_pays_secteur.do" `source'
	
 use "$dir/Results/Étude rapport D+I et Bouclage Mondial/Elast_par_pays_2014_WIOD_HC.dta"
 
gen E4HC = pond_WIOD_HC - E1HC - E2HC - E3HC
 
correlate pond_WIOD_HC E1HC E2HC E3HC, covariance
correlate E1HC E2HC E3HC E4HC, covariance
correlate E1HC E2HC E3HC E4HC

cd "$dir/Results/Étude rapport D+I et Bouclage Mondial"
corrtex E1HC E2HC E3HC E4HC, key(table:corretable1) file("corrtable_1.tex") replace digits(2) title("Cross-correlation of $\overline{s}_{i}^{i,HC}$'s components (WIOD 2014)")

gen E1HC_and_E2HC=E1HC + E2HC
gen E3HC_and_E4HC=E3HC + E4HC

corrtex E1HC_and_E2HC E3HC_and_E4HC, key(table:corretable2) file("corrtable_2.tex") replace digits(2) title("Cross-correlation of $\overline{s}_{i}^{i,HC}$'s components (2)")

