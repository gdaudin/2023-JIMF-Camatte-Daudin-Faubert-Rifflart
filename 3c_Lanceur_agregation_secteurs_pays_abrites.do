************************************
*On agrège les vecteurs de chocs en un scalaire pour les prix d'exports, de conso et de production
*Ligne 49 : source
*Ligne 82 : années
*Ligne 86 : Total ou composantes
*Long...


*****Lanceur du programme de choc par pays 

clear  
set more off

if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA"
if ("`c(hostname)'" == "widv270a") global dir  "D:\home\T822289\CommerceVA" 
if ("`c(hostname)'" == "FP1376CD") global dir  "T:\CommerceVA" 


if ("`c(username)'"=="guillaumedaudin") global dirgit "~/Documents/Recherche/2017 BDF_Commerce VA/commerce_VA_inflation"
if ("`c(hostname)'" == "widv270a") global dirgit  "D:\home\T822289\CommerceVA\GIT\commerce_VA_inflation" 
if ("`c(hostname)'" == "FP1376CD") global dirgit  "T:\CommerceVA\GIT\commerce_va_inflation" 



capture log  using "$dir/Temporaire/$S_DATE.log", replace
*log using "$dir/$S_DATE.log", replace
set matsize 7000
*set mem 700m if earlier version of stata (<stata 12)
set more off
cd "$dir" 

do "$dirgit/Definition_pays_secteur.do"  
do "$dirgit/Aggregation_effets_des_chocs_secteurs_pays_abrites.do"   


*--------------------------------------------------------------------------------
*LIST ALL PROGRAMS AND RUN THEM - agregation effet choc
*--------------------------------------------------------------------------------
clear
set more off

*Pour obtenir les chocs sur l'ensemble des secteurs
/*
Definition_pays_secteur TIVA_REV4 

foreach s in $sector {
			foreach origine in impt dom {
				local liste `liste' HC_`s'_`origine'
		}
}

local HC_fait 0
local i 2014
   foreach j in  `liste' HC   {	

    if strpos("`j'","HC")!=0 & `HC_fait'==0 {
				compute_HC_vect `i' TIVA_REV4
				local HC_fait 1
	}
			if strpos("`j'","HC")==0 compute_`j'_vect `i' TIVA_REV4 
			table_mean `i' `j' 1 TIVA_REV4 

}

  */
  
* Pour étude habituelle

foreach source in   TIVA { 
*foreach source in  WIOD  TIVA_REV4 { /*TIVA*/

	Definition_pays_secteur `source'
	*if "`source'"=="WIOD" local start_year 2000
	if "`source'"=="TIVA" local start_year 1996
	*if "`source'"=="TIVA_REV4" local start_year 2005


	*if "`source'"=="WIOD" local end_year 2014
	if "`source'"=="TIVA" local end_year 2011
	*if "`source'"=="TIVA_REV4" local end_year 2015

	
	// Fabrication des fichiers d'effets moyens des chocs

		*  foreach i of numlist 2011 {
	foreach i of numlist `start_year' (1)`end_year'  {
		
		

******Cette boucle demande de calculer l'effet du choc sur l'ensemble des secteurs. Elle allonge considérablement le travail
******A priori, il faut l'exclure, sauf en cas de recherche particulière.
/*
		foreach s in $sector {
			foreach origine in impt dom {
				local liste `liste' HC_`s'_`origine'
			}
		}
*/		
	local HC_fait 0
    	foreach j in  `liste'  X /*HC Y HC_neig_dom HC_alimentaire_dom HC_energie_dom HC_services_dom HC_dom /// 
					HC_neig_impt HC_alimentaire_impt HC_energie_impt HC_services_impt HC_impt */ {	
		foreach id_shock in OBS CONTRF {
					
    	    if strpos("`j'","HC")!=0 & `HC_fait'==0 {
				compute_HC_vect `i' `source'
				local HC_fait 1
			}
			if strpos("`j'","HC")==0 compute_`j'_vect `i' `source'
			table_mean `i' `j' `id_shock' `source' 

			}

		}

	}
}
*secteurs HC : alimentaire neig services energie

*on va le mettre dans weight.

*HC_alimentaire HC_neig HC_services HC_energie

local nbr_sect=wordcount("$sector")	
capture log close

