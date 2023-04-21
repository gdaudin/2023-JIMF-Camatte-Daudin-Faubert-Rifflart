
if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA"
if ("`c(hostname)'" == "widv270a") global dir  "D:\home\T822289\CommerceVA" 
if ("`c(hostname)'" == "FP1376CD") global dir  "T:\CommerceVA" 


if ("`c(username)'" == "guillaumedaudin") use "$dir/BME.dta", clear
if ("`c(hostname)'" == "widv270a") use  "D:\home\T822289\CommerceVA\Rédaction\Rédaction 2019\BME.dta" , clear
if ("`c(hostname)'" == "FP1376CD") use  "T:\CommerceVA\Rédaction\Rédaction 2019\BME.dta" , clear

generate pays = upper(c)+"_EUR" if type == "ERT"
replace pays = upper(c) if type == "CXD"

replace BME_1=-BME_1*10 if type == "CXD" 
replace BME_3=-BME_3*10 if type == "CXD" 

//replace BME_1=-BME_1*10/clef_CXD if type == "CXD"  //si on veut BME au format Semap (vu de la BCN et non de la ZE)
//replace BME_3=-BME_3*10/clef_CXD if type == "CXD"  //si on veut BME au format Semap (vu de la BCN et non de la ZE)

replace BME_1=BME_1 if type == "ERT" 
replace BME_3=BME_3 if type == "ERT" 

replace BME_1=. if type == "CXD" & c=="FIN" & year==2018
replace BME_3=. if type == "CXD" & c=="FIN" & year==2018

capture program drop compar_bme
program compar_bme
args year source type

merge m:1 pays using "$dir/Results/Devaluations/auto_chocs_HC_`source'_`year'.dta"
replace pond_`source'_HC = pond_`source'_HC*10 

 format %14.2f pond_`source'_HC BME_1 /*nombre décimales*/
drop _merge
drop if BME_1== .


replace pond_`source'_HC = pond_`source'_HC 

if "`type'" == "CXD" local note choc prix des compétiteurs -10% (CXD) 
if "`type'" == "ERT" local note choc de change 10% (ERT)

if "`type'" == "CXD" local scale1 -3.0 0 
if "`type'" == "ERT" local scale1  -3.0 0 

if "`type'" == "CXD" local scale2 -3.5(0.5)0 
if "`type'" == "ERT" local scale2 -3.5(0.5)0


foreach yrs of numlist 2018 2019 {
	/*regress BME pond_WIOD_HC if year == `yrs'*/
	/*twoway (scatter BME pond_WIOD_HC if year == `yrs', mlabel(c)) (lfit BME pond_WIOD_HC) if year == `yrs', name(BME_vs_WIOD_`yrs', replace)
	graph save "$dir/Graphiques/BME_vs_WIOD_`yrs'.gph",  replace
	*/
	correlate BME_1 pond_`source'_HC if year == `yrs' & type == "`type'"
	local rho =r(rho)
	local rho : di %3.2f `rho'
	twoway (scatter BME_1 pond_`source'_HC if year == `yrs' & type == "`type'", mlabel(c)) ///
		(lfit pond_`source'_HC pond_`source'_HC, range(`scale1')) if year == `yrs', ///
		ytitle("impact en % BMEs `yrs' (1ere année)") yscale(range(`scale1')) ylabel(`scale2', grid) /// 
		xtitle("impact en % PIWIM `year' ,`source'") xscale(range(`scale1')) xlabel(`scale2', grid) legend(off) name(BME_1_vs_`yrs', replace) ///
		note("`note'" "Corrélation: `rho'") 
}


*		(lfit BME_1 pond_`source'_HC if year == `yrs' & type == "`type'", range(`scale1')) ///
graph combine  BME_1_vs_2018 BME_1_vs_2019
graph save "$dir/Results/BME_1_vs_`source'_`type'.gph",  replace 
graph export "$dir/Results/BME_1_vs_`source'_`type'.png",  replace 


format %14.2f pond_`source'_HC BME_3
foreach yrs of numlist 2018 2019 {
	/*regress BME pond_WIOD_HC if year == `yrs'*/
	/*twoway (scatter BME pond_WIOD_HC if year == `yrs', mlabel(c)) (lfit BME pond_WIOD_HC) if year == `yrs', name(BME_vs_WIOD_`yrs', replace)
	graph save "$dir/Graphiques/BME_vs_WIOD_`yrs'.gph",  replace
	*/
	correlate BME_3 pond_`source'_HC if year == `yrs' & type == "`type'"
	local rho =r(rho)
	local rho : di %3.2f `rho'
	twoway (scatter BME_3 pond_`source'_HC if year == `yrs' & type == "`type'", mlabel(c)) ///
	(lfit pond_`source'_HC pond_`source'_HC, range(`scale1')) if year == `yrs', ///
		ytitle("impact en % BMEs `yrs' (3e année)") yscale(range(`scale1')) ylabel(`scale2', grid) /// 
		xtitle("impact en % PIWIM `year', `source'") xscale(range(`scale1')) xlabel(`scale2', grid) legend(off) name(BME_3_vs_`yrs', replace) ///
		note("`note'" "Corrélation: `rho'") 

* 	(lfit BME_3 pond_`source'_HC if year == `yrs' & type == "`type'", range(`scale1')) ///

}

graph combine  BME_3_vs_2018 BME_3_vs_2019 
graph save "$dir/Results/BME_3_vs_`source'_`type'.gph",  replace 
graph export "$dir/Results/BME_3_vs_`source'`type'.png",  replace 

end
compar_bme 2015 TIVA_REV4 ERT 
compar_bme 2014 WIOD ERT
*compar_bme 2015 TIVA_REV4 CXD
*compar_bme 2014 WIOD CXD
