
*****HC, GD, 10/2018----------------------------------------
*****Lanceur du programme de pétrole
*****Ce lanceur lance pour chaque base, chaque année  un choc pour le ou les secteurs choisi et pour le ou les pays choisis
*****Attention, lors de chaque mise à jour des données, il faut changer les dates de début/fin dans 1_constr_bases.do (l 20, 53 , 230-235, 327-331)
*****Pour changer la taille du choc, changer la ligne 98 (ici choc de +100%)
*****IMPORTANT : le programme 2_choc_change doit avoir tourné car on ne fait pas retourner la matrice de Leontieff
*--------------------------------------------------------------------------------
*LIST ALL PROGRAMS AND RUN THEM
*--------------------------------------------------------------------------------


clear
set more off
*****Mettre global test =1 provoquera la sauvegarde de plein de matrices / vecteurs 
****Pas sûr que cela ne soit pas obligatoire finalement ?
global test = 1
*******Définition du directory

if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA"
if ("`c(hostname)'" == "widv270a") global dir  "D:\home\T822289\CommerceVA" 
if ("`c(hostname)'" == "FP1376CD") global dir  "T:\CommerceVA" 


if ("`c(username)'"=="guillaumedaudin") global dirgit "~/Répertoires Git/2023 JIMF Camatte Daudin Faubert Rifflart"
if ("`c(hostname)'" == "widv270a") global dirgit  "D:\home\T822289\CommerceVA\GIT\commerce_VA_inflation" 
if ("`c(hostname)'" == "FP1376CD") global dirgit  "T:\CommerceVA\GIT\commerce_va_inflation" 


capture log using "$dir/Temporaire/$S_DATE.log", replace
set matsize 7000
*set mem 700m if earlier version of stata (<stata 12)
set more off

cd "$dir"  

******Définition des Pays et des secteurs ********************
**On le lance pour mettre à jour les macros (en mémoire)
do "$dirgit/Definition_pays_secteur.do"   


**local nbr_sect=wordcount("$sector")	
do "$dirgit/choc_secteurs_pays.do"


foreach bdd in   /*WIOD*/ TIVA_REV4 {
	*Cela ne marche pas dans TIVA_REV4. Il semble y avoir un secteur dédoublé dans csv_TIVA_REV4 ? Je laisse tomber 
	**C’est reglé !
	
	if "`bdd'"=="WIOD" local year 2014
	if "`bdd'"=="TIVA_REV4" local year 2015

	Definition_pays_secteur `bdd'

	clear
	set more off


	vector_shock_secteurs_pays 1 `bdd' RUS
	shock_secteurs_pays `year' `bdd' RUS
	use "$dir/Results/Secteurs_pays/`bdd'_`year'_RUS_secteurs_pays.dta", clear
	rename S*t1 shock*1

	merge 1:1 _n using "$dir/Bases/csv_`bdd'"
	drop _merge
	drop p_shock
	order c s
	save "$dir/Results/Secteurs_pays/`bdd'_`year'_RUS_secteurs_pays", replace
}


blif

 ***La suite pour avoir les effets pétrole pour toutes les bases et toutes les années

*foreach bdd in   WIOD { 
foreach bdd in    WIOD TIVA TIVA_REV4 { 


	if "`bdd'"=="WIOD" local start_year 2000
	if "`bdd'"=="TIVA" local start_year 1995
	if "`bdd'"=="TIVA_REV4" local start_year 2005


	if "`bdd'"=="WIOD" local end_year 2014
	if "`bdd'"=="TIVA" local end_year 2011
	if "`bdd'"=="TIVA_REV4" local end_year 2015

	
	Definition_pays_secteur `bdd'

*   foreach i of numlist 2011 {
	foreach i of numlist `start_year' (1)`end_year'  {
		clear
		set more off
		
		vector_shock_secteurs_pays 1 `bdd' 
		shock_secteurs_pays `i' `bdd'
		use "$dir/Results/Secteurs_pays/`bdd'_`i'_secteurs_pays.dta", clear
		rename S*t1 shock*1

		merge 1:1 _n using "$dir/Bases/csv_`bdd'"
		drop _merge
		drop p_shock
		order c s
		save "$dir/Results/Secteurs_pays/`bdd'_`i'_secteurs_pays", replace	
    }

}





capture log close


