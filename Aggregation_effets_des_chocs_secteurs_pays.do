

*----------------------------------------------------------------------------------
*CREATION OF A VECTOR CONTAINING (Y,X ou HC) MEAN EFFECTS OF A SHOCK FOR EACH COUNTRY
*----------------------------------------------------------------------------------
*Creation of the vector Y is required before table_adjst : matrix Yt
capture program drop compute_Y_vect
program compute_Y_vect
args yrs bdd
clear

use "$dir/Bases/Y_`bdd'.dta", clear
keep if year == `yrs'

mkmat Y, matrix(Y)

display "fin compute_Y_vect"
end

*Creation of the vector of export X : matrix X
* 2017-10-17 redondant avec le programme 1!!!
capture program drop compute_X_vect
program compute_X_vect
	args yrs bdd
	
use "$dir/Bases/X_`bdd'.dta", clear
keep if year == `yrs'

*keep year Country X
mkmat X, matrix(X)
display "fin compute_X_vect"

end


*Creation of the vector of value-added VA : matrices Y, X, VA
/*
capture program drop compute_VA
program compute_VA
	args yrs
clear
use "$dir/Bases/`bdd'_ICIO_`yrs'.dta", clear
keep if v1 == "VA.TAXSUB"
drop v1
mkmat $var_entree_sortie, matrix(VA)
matrix VAt = VA'
end
*/
capture program drop compute_HC_vect
program  compute_HC_vect
	args yrs bdd 
	
	use "$dir/Bases/HC_`bdd'.dta", clear
	keep if year == `yrs'
	foreach pays_conso of global country_hc {
		replace pays_conso=strupper(pays_conso)
		preserve
		keep if pays_conso==strupper("`pays_conso'")
		mkmat conso, matrix(HC_`pays_conso')
		restore
	}
	
end
*===============================================================

capture program drop compute_mean    // matrix shock`cty'
program compute_mean
	args yrs wgt bdd csource
	*Example compute_mean 2014 HC WIOD all
	*Example compute_mean 2014 HC WIOD RUS
clear
*set matsize 7000
set more off
clear

if "`csource'"=="all" local csourcefile
if "`csource'"!="all" local csourcefile = "`csource'"

if "`csource'"=="all" use "$dir/Results/Secteurs_pays/`bdd'_`yrs'_secteurs_pays.dta"
else use "$dir/Results/Secteurs_pays/`bdd'_`yrs'_`csource'_secteurs_pays.dta"
mkmat shock1, matrix(shock)

use "$dir/Bases/csv_`bdd'.dta", clear

*I decide whether I use the production or export or value-added vector as weight modifying the argument "wgt" : Yt or X or VAt
*Compute the vector of mean effects :




if ("`wgt'" == "Y")  {
*	matrix Y = Y'
	svmat Y 
	*on fait du vecteur une variable

}
if ("`wgt'" == "X")  {
	svmat X
}


if ("`wgt'" == "X") | ("`wgt'" == "Y") {

	svmat shock
	generate Bt = shock1* `wgt' /*on a défini un vecteur que l'on transforme en variable et que l'on multiplie par les poids */
	gen pays_interet=c
	replace pays_interet="CHN" if pays_interet=="CN1" | pays_interet=="CN2" | pays_interet=="CN3" | pays_interet=="CN4"
	replace pays_interet="MEX" if pays_interet=="MX1" | pays_interet=="MX2" | pays_interet=="MX3"
	bys pays_interet : egen tot_`wgt' = total(`wgt')
	generate sector_shock = Bt/tot_`wgt'
	bys pays_interet : egen shock = total(sector_shock)
		
	bys pays_interet : keep if _n==1
	mkmat shock
*   pourquoi pas  mkmat shock`groupeduchoc'_`pays_conso' ???

	
}



local blink 0
svmat shock, name(shock_par_sect)	



if strpos("`wgt'","HC")!=0  {
	foreach pays_conso of global country_hc {
        svmat HC_`pays_conso', name(HC_`pays_conso')
        generate Bt_`pays_conso' = shock_par_sect1* HC_`pays_conso'
        egen tot_HC_`pays_conso' = total(HC_`pays_conso')
        generate sector_shock_`pays_conso' = Bt_`pays_conso'/tot_HC_`pays_conso'
		foreach sector in alimentaire neig energie services {
		
			if strpos("`wgt'","`sector'")!=0	replace sector_shock_`pays_conso'= 0 if agregat_secteur!="`sector'"
		}
		foreach sector in $sector {
			if strpos("`wgt'","`sector'")!=0	replace sector_shock_`pays_conso'= 0 if s!="`sector'"
		}
		if strpos("`wgt'","imp")!=0 replace  sector_shock_`pays_conso'= 0 if upper("`pays_conso'")==c
		if strpos("`wgt'","dom")!=0 replace  sector_shock_`pays_conso'= 0 if upper("`pays_conso'")!=c
        egen shock_`pays_conso' = total(sector_shock_`pays_conso')
    *	keep if _n==1
        mkmat shock_`pays_conso'

        if `blink'== 0 matrix shock = shock_`pays_conso'[1,1]
        if `blink'!= 0 matrix shock = shock \ shock_`pays_conso'[1,1]
        matrix drop shock_`pays_conso'
        local blink=`blink'+1	
        drop Bt* tot* sector_shock* HC*  
    }
}


set more off
display "fin de compute_mean `yrs' `wgt' `bdd' `csource'"


*Vector shock`cty' contains the mean effects of a shock on exchange rate (coming from the country `cty') on overall prices for each country

end


*----------------------------------------------------------------------------------------------------
*CREATION OF THE TABLE CONTAINING THE MEAN EFFECT FROM EACH COUNTRY TO ALL COUNTRIES
*----------------------------------------------------------------------------------------------------
capture program drop table_mean
program table_mean 
	args yrs wgt shk  bdd csource
*yrs = years, wgt = Yt (output) or X (export) or VAt (value-added) or HC (household consumption)
clear
*set matsize 7000
* set trace on
set more off


compute_mean `yrs' `wgt' `bdd' `csource' 




use "$dir/Bases/pays_en_ligne_`bdd'.dta", clear
drop if c=="MX1" | c=="MX2" |  c=="MX3" |  c=="CN1"  |  c=="CN2"  |  c=="CN3"  |  c=="CN4" 
set more off


svmat shock

if "`csource'"=="all" {
		save "$dir/Results/secteurs_pays/mean_chg_`bdd'_`wgt'_`yrs'.dta", replace
		export excel using "$dir/Results/secteurs_pays/mean_chg_`bdd'_`wgt'_`yrs'.xls", firstrow(variables) replace
}
else {
	save "$dir/Results/secteurs_pays/mean_chg_`bdd'_`wgt'_`yrs'_`csource'.dta", replace
	export excel using "$dir/Results/secteurs_pays/mean_chg_`bdd'_`wgt'_`yrs'_`csource'.xls", firstrow(variables) replace
	
}



* set trace off
set more on

end



