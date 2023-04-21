

if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA"
if ("`c(hostname)'" == "widv270a") global dir  "D:/home/T822289/CommerceVA" 
if ("`c(hostname)'" == "FP1376CD") global dir  "T:/CommerceVA" 

if ("`c(username)'"=="guillaumedaudin") global dirgit "~/Répertoires Git/2023 JIMF Camatte Daudin Faubert Rifflart"
if ("`c(hostname)'" == "widv270a") global dirgit  "D:\home\T822289\CommerceVA\GIT\commerce_va_inflation" 


use "$dir/Bases_Sources/Doigt_mouillé_panel.dta", clear


keep pond_MRIO_HC pays year
reshape wide pond_MRIO_HC, i(pays) j(year)
generate pays_labelblif=pays
replace pays_labelblif="" if ln(pond_MRIO_HC2018/pond_MRIO_HC2017) <=0.2 & ln(pond_MRIO_HC2018/pond_MRIO_HC2017) >=-0.2
generate pays_labelblouf=pays
replace pays_labelblouf="" if ln(pond_MRIO_HC2016/pond_MRIO_HC2017) <=0.2 & ln(pond_MRIO_HC2016/pond_MRIO_HC2017) >=-0.2

twoway (scatter pond_MRIO_HC2017 pond_MRIO_HC2018, mlabel(pays_labelblif)) (lfit pond_MRIO_HC2017 pond_MRIO_HC2017), ////
	ytitle("2017") xtitle("2018") name(blif,replace) legend(off) scheme(s1mono) ///
	ylabel(0.05 (0.05) 0.3) yscale(range(0.05 0.3)) xlabel(0.05 (0.05) 0.3) xscale(range(0.05 0.3))
	
	
twoway (scatter pond_MRIO_HC2016 pond_MRIO_HC2017 , mlabel(pays_labelblouf)) (lfit pond_MRIO_HC2016 pond_MRIO_HC2016), ////
	ytitle("2016") xtitle("2017") name(blouf,replace) legend(off) scheme(s1mono)  ///
	ylabel(0.05 (0.05) 0.3) yscale(range(0.05 0.3)) xlabel(0.05 (0.05) 0.3) xscale(range(0.05 0.3))
	
	
graph combine blif blouf, note("Comparing elasticites 2017/2018 and 2016/2017" ///
	"Label if the difference is larger than 0.2 log points") scheme(s1mono)


graph export  "$dirgit/Rédaction/pays_en_soucis_2018_MRIO.png", replace



use "/Users/guillaumedaudin/Documents/Recherche/2017 BDF_Commerce VA/Bases/HC_MRIO.dta", clear

tab year
reshape wide conso, i(pays sector pays_conso) j(year)

*br pays sector pays_conso conso2017 conso2018

generate diff2018ratio = conso2018/conso2017
summarize diff2018ratio

gsort -  diff2018ratio

generate  diff2018 = (conso2018-conso2017)
summarize diff2018
gsort -   diff2018

generate diff2017ratio = conso2017/conso2016
generate  diff2017 = (conso2018-conso2017)



*J’ai continué à vérifier ce qui se passait en 2018 et 2019 pour la Chine dans MRIO.  La consommation de C32 (éducation) augmente de 43% entre 2017 et 2018, celle de transport baisse de 43%… Bref, il y a des soucis dans les données MRIO, du côté du vecteur de consommation chinois en 2018 et 2019. Je crois qu’il faudrait le préciser dans le papier.


graph twoway (scatter conso2016 conso2017) (lfit conso2016 conso2017)
graph twoway (scatter conso2017 conso2018) (lfit conso2017 conso2018)
reg conso2016 conso2017 [aweight=conso2017] 
reg conso2017 conso2018 [aweight=conso2017]

reg conso2016 conso2017 [aweight=conso2017] if pays_conso=="PRC" & pays=="PRC"
reg conso2017 conso2018 [aweight=conso2017] if pays_conso=="PRC" & pays=="PRC"

corr conso2016 conso2017 conso2018 conso2019 [aweight=conso2017] if pays_conso=="PRC" & pays=="PRC"

*La rupture est assez nette ? On pourrait faire une recherche systématique, mais on laisse tomber : nous ne sommes pas là pour faire le contrôle qualité de MRIO...


*twoway (hist diff2018, color(red%30)) (hist diff2017, color(green%30))
*twoway (hist diff2018ratio, color(red%30)) (hist diff2017ratio, color(green%30))

gen ln_diff2018=ln(diff2018)
gen ln_diff2017=ln(diff2017)

gen ln_diff2018ratio=ln(diff2018ratio)
gen ln_diff2017ratio=ln(diff2018ratio)

twoway (hist ln_diff2018, color(red%30) ) (hist ln_diff2017, color(green%30) )
twoway (hist ln_diff2018ratio, color(red%30) ) (hist ln_diff2017ratio, color(green%30) )

twoway (hist ln_diff2018ratio if ln_diff2018ratio >= 1 | ln_diff2018ratio <= -1, color(red%30) ) (hist ln_diff2017ratio if ln_diff2017ratio >= 1 | ln_diff2017ratio <= -1, color(green%30) )


blif
keep if pays_conso=="PRC"
br pays sector pays_conso conso2017 conso2018 diff2018  diff2018ratio


************

use "$dir/Bases_Sources/Doigt_mouillé_panel.dta", clear


keep pond_WIOD_HC pays year
reshape wide pond_WIOD_HC, i(pays) j(year)
generate pays_labelblif=pays
replace pays_labelblif="" if ln(pond_WIOD_HC2014/pond_WIOD_HC2013) <=0.2 & ln(pond_WIOD_HC2014/pond_WIOD_HC2013) >=-0.2
generate pays_labelblouf=pays
replace pays_labelblouf="" if ln(pond_WIOD_HC2013/pond_WIOD_HC2012) <=0.2 & ln(pond_WIOD_HC2013/pond_WIOD_HC2012) >=-0.2


twoway (scatter pond_WIOD_HC2014 pond_WIOD_HC2013, mlabel(pays_labelblif)) (lfit pond_WIOD_HC2013 pond_WIOD_HC2013), ////
	ytitle("2014") xtitle("2013") name(blif,replace) legend(off) scheme(s1mono)
twoway (scatter pond_WIOD_HC2013 pond_WIOD_HC2012 , mlabel(pays_labelblouf)) (lfit pond_WIOD_HC2013 pond_WIOD_HC2013), ////
	ytitle("2013") xtitle("2012") name(blouf,replace) legend(off) ///
	scheme(s1mono)
	
	
	
graph combine blif blouf, note("Comparing elasticites 2013/2014 and 2012/2013" ///
	"Label if the difference is larger than 0.2 log points") scheme(s1mono)

graph export  "$dirgit/Rédaction/pays_en_soucis_Comp_WIOD.png", replace





