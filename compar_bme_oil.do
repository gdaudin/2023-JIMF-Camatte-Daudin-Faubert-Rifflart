
if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA"
if ("`c(hostname)'" == "widv270a") global dir  "D:\home\T822289\CommerceVA" 
if ("`c(hostname)'" == "FP1376CD") global dir  "T:\CommerceVA" 


if ("`c(username)'" == "guillaumedaudin") use "$dir/BME.dta", clear
if ("`c(hostname)'" == "widv270a") use  "D:\home\T822289\CommerceVA\Rédaction\Rédaction 2019\BME.dta" , clear
if ("`c(hostname)'" == "FP1376CD") use  "T:\CommerceVA\Rédaction\Rédaction 2019\BME.dta" , clear

drop if type == "ERT" | type == "CXD" 
drop clef_CXD



*On ajuste le choc à 10€ pour OE 1 
replace BME_1 = BME_1*(10/3) if type=="OE1" 
replace BME_3 = BME_3*(10/3) if type=="OE1" 
replace BME_4 = BME_4*(10/3) if type=="OE1" 

*On ajuste le choc à 10€ pour OE 2 
replace BME_1 = BME_1*(10/5.5) if type=="OE2" 
replace BME_3 = BME_3*(10/5.5) if type=="OE2" 
replace BME_4 = BME_4*(10/5.5) if type=="OE2" 

*On ajuste le choc à 10€ pour OE 3 
replace BME_1 = BME_1*(10/8.5) if type=="OE3"
replace BME_3 = BME_3*(10/8.5) if type=="OE3" 
replace BME_4 = BME_4*(10/8.5) if type=="OE3" 

*On ajuste le choc à 10€ pour 4  
replace BME_1 = BME_1*(10/11.5) if type=="OE4" 
replace BME_3 = BME_3*(10/11.5) if type=="OE4" 
replace BME_4 = BME_4*(10/11.5) if type=="OE4" 


capture program drop compar_bme
program compar_bme
args year source 

merge m:1 c using "$dir/Results/secteurs_pays/mean_chg_`source'_HC_`year'.dta"

*rename c pays

*on met le choc de change à 10€

if `year' == 2015 replace shock1 = shock1*100*(10/47.22)
if `year' == 2014 replace shock1 = shock1*100*(10/74.48)

local scale1 0.0 2.0 
local scale2 0.0 (0.25) 2.0

foreach type in OE1 OE2 OE3{
	foreach yrs of numlist 2018 2019 {

	if "`type'" == "OE1" local note "Niveau de départ du prix du pétrole de 30€ (BMEs) et 74€ (PIWIM)"
	if "`type'" == "OE2" local note "Niveau de départ du prix du pétrole de 55€ (BMEs) et 74€ (PIWIM)"
	if "`type'" == "OE3" local note "Niveau de départ du prix du pétrole de 85€ (BMEs) et 74€ (PIWIM)"
	/*regress BME pond_WIOD_HC if year == `yrs'*/
	/*twoway (scatter BME pond_WIOD_HC if year == `yrs', mlabel(c)) (lfit BME pond_WIOD_HC) if year == `yrs', name(BME_vs_WIOD_`yrs', replace)
	graph save "$dir/Graphiques/BME_vs_WIOD_`yrs'.gph",  replace
	*/
	
	correlate BME_1 shock1 if year == `yrs' & type == "`type'"
	local rho =r(rho)
	local rho : di %3.2f `rho'
	twoway (scatter BME_1 shock1 if year == `yrs' & type == "`type'", mlabel(c)) ///
		(lfit shock1 shock1, range(`scale1')) if year == `yrs', ///
		ytitle("impact en % BMEs `yrs' (1ere année)") yscale(range(`scale1')) ylabel(`scale2', grid) /// 
		xtitle("impact en % PIWIM `year' ,`source'") xscale(range(`scale1')) xlabel(`scale2', grid) legend(off) name(BME_1_vs_`yrs'_`type', replace) ///
		note("Corrélation: `rho'")
		 
	}
	graph combine  BME_1_vs_2018_`type' BME_1_vs_2019_`type', note("`note'") 
	graph save "$dir/Results/secteurs_pays/graphiques/BME_1_vs_`source'_`type'.gph",  replace 
	graph export "$dir/Results/secteurs_pays/graphiques/BME_1_vs_`source'_`type'.png",  replace 
}


*		(lfit BME_1 shock1 if year == `yrs' & type == "`type'", range(`scale1')) ///



format %14.2f shock1 BME_3
foreach type in OE1 OE2 OE3{ 
	foreach yrs of numlist 2018 2019 {

	
	
	if "`type'" == "OE1" {
		local scale1 0.0 2.0  
		local scale2 0.0 (0.25) 2.0  
		local note "Niveau de départ du prix du pétrole de 30€ (BMEs) et 74€ (PIWIM), hors Chypre" 
	}
	if "`type'" == "OE2" {
		local scale1 0.0 2.0 
		local scale2 0.0 (0.25) 2.0
		local note "Niveau de départ du prix du pétrole de 55€ (BMEs) et 74€ (PIWIM), hors Chypre" 
	}
	if "`type'" == "OE3" {
		local scale1 0.0 2.0 
		local scale2 0.0 (0.25) 2.0
		local note "Niveau de départ du prix du pétrole de 85€ (BMEs) et 74€ (PIWIM), hors Chypre" 
	}
	/*regress BME pond_WIOD_HC if year == `yrs'*/
	/*twoway (scatter BME pond_WIOD_HC if year == `yrs', mlabel(c)) (lfit BME pond_WIOD_HC) if year == `yrs', name(BME_vs_WIOD_`yrs', replace)
	graph save "$dir/Graphiques/BME_vs_WIOD_`yrs'.gph",  replace
	*/
	correlate BME_3 shock1 if year == `yrs' & type == "`type'"
	local rho =r(rho)
	local rho : di %3.2f `rho'
	twoway (scatter BME_3 shock1 if year == `yrs' & type == "`type'" & c != "CYP", mlabel(c)) ///
	(lfit shock1 shock1, range(`scale1')) if year == `yrs' & c != "CYP", ///
		ytitle("impact en % BMEs `yrs' (3e année)") yscale(range(`scale1')) ylabel(`scale2', grid) /// 
		xtitle("impact en % PIWIM `year', `source'") xscale(range(`scale1')) xlabel(`scale2', grid) legend(off) name(BME_3_vs_`yrs'_`type', replace)  ///
		note("Corrélation: `rho'")
		

* 	(lfit BME_3 shock1 if year == `yrs' & type == "`type'", range(`scale1')) ///

	}

	graph combine  BME_3_vs_2018_`type' BME_3_vs_2019_`type', note("`note'")
	graph save "$dir/Results/secteurs_pays/graphiques/BME_3_vs_`source'_`type'.gph",  replace 
	graph export "$dir/Results/secteurs_pays/graphiques/BME_3_vs_`source'`type'.png",  replace 
} 
end
compar_bme 2014 TIVA_REV4 
*compar_bme 2014 WIOD

*Note : changer la définition du choc d'oil et le niveau du pétrole selon l'année dans les légendes
