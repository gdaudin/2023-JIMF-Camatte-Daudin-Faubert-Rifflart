
*****HC, GD, 10/2018----------------------------------------
*****Lanceur du programme de change (attention, c'est très long)
*****Ce lanceur lance pour chaque base, chaque année et chaque pays le choc de change 
*****Attention, lors de chaque mise à jour des données, il faut changer les dates de début/fin dans 1_constr_bases.do (l 20, 53 , 230-235, 327-331)
*****Pour changer la taille du choc, changer la ligne 98 (ici choc de +100%)
*--------------------------------------------------------------------------------
*LIST ALL PROGRAMS AND RUN THEM
*--------------------------------------------------------------------------------


clear
set more off
*****Mettre global test =1 provoquera la sauvegarde de plein de matrices / vecteurs 
global test=1


*******Définition du directory
if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA"
if ("`c(hostname)'" == "widv270a") global dir  "D:\home\T822289\CommerceVA" 

if ("`c(username)'"=="guillaumedaudin") global dirgit "~/Répertoires Git/2023 JIMF Camatte Daudin Faubert Rifflart"
if ("`c(hostname)'" == "widv270a") global dirgit  "D:\home\T822289\CommerceVA\GIT\commerce_va_inflation" 



capture log using "$dir/Temporaire/$S_DATE.log", replace
set matsize 7000
*set mem 700m if earlier version of stata (<stata 12)
set more off

cd "$dir"

******Définition des Pays et des secteurs ********************
**On le lance pour mettre à jour les macros (en mémoire)
do "$dirgit/Definition_pays_secteur.do"   


**local nbr_sect=wordcount("$sector")	
do "$dirgit/choc_chge.do"
/*
***** POUR TEST (1 pays, 1 année, 1 source)***********
global test = 1 
Definition_pays_secteur TIVA
//compute_leontief 2005 TIVA
compute_B_B2 2005 ARG	TIVA B
compute_B_B2 2005 ARG	TIVA B2
vector_shock_exch 1 ARG TIVA
shock_exch 2005 ARG TIVA
blink
*compute_X 2011 TIVA
*compute_Yt 2011 TIVA
*compute_HC 2011 TIVA
/*
global ori_choc "EUR"

table_mean 2011 X 1 TIVA

blink 
**blink = erreur pour plantage

***** FIN  TEST***********

*/
*/
*foreach source in   WIOD { 
foreach source in   /* WIOD TIVA  TIVA_REV4*/ MRIO { 


	if "`source'"=="WIOD" local start_year 2000 /*2000*/
	if "`source'"=="TIVA" local start_year 1995
	if "`source'"=="TIVA_REV4" local start_year 2005

	if "`source'"=="WIOD" local end_year 2014
	if "`source'"=="TIVA" local end_year 2011
	if "`source'"=="TIVA_REV4" local end_year 2015
	
	
	if "`source'"=="MRIO" local year_list 2000 2007(1)2019
	if "`source'"=="WIOD" local year_list 2000(1)2014
	if "`source'"=="TIVA" local year_list 1995(1)2011
	if "`source'"=="TIVA_REV4" local year_list 2005(1)2015
	
	
	Definition_pays_secteur `source'

	
	if "`source'"=="TIVA" {
	*	global ori_choc "CHN"
		global ori_choc "EUR EAS"
		global ori_choc "$ori_choc ARG AUS AUT BEL BGR BRA BRN CAN CHE CHL CHN COL CRI CYP CZE DEU DNK ESP EST FIN"
		global ori_choc "$ori_choc FRA GBR GRC HKG HRV HUN IDN IND IRL ISL ISR ITA JPN KHM KOR LTU LUX LVA MAR MEX MLT MYS NLD NOR NZL PER "
		global ori_choc "$ori_choc PHL POL PRT ROU ROW RUS SAU SGP SVK SVN SWE THA TUN TUR TWN USA VNM ZAF"
	}

	if "`source'"=="TIVA_REV4" {
		global ori_choc "EUR EAS"
		global ori_choc "$ori_choc  ARG AUS AUT BEL BGR BRA BRN CAN CHE CHL"
		global ori_choc "$ori_choc  CHN   COL CRI CYP CZE DEU DNK ESP EST FIN"
		global ori_choc "$ori_choc  FRA GBR GRC HKG HRV HUN IDN IND IRL ISL ISR ITA JPN KAZ KHM KOR"
		global ori_choc "$ori_choc  LTU LUX LVA MAR MEX MLT    MYS NLD NOR NZL PER PHL POL PRT"
		global ori_choc "$ori_choc  ROU ROW RUS SAU SGP SVK SVN SWE THA TUN TUR TWN USA VNM ZAF"
	}
	
	if "`source'"=="WIOD" {
		global ori_choc "EUR EAS"
		global ori_choc "$ori_choc AUS AUT BEL BGR BRA     CAN CHE CHN                             CYP CZE DEU DNK ESP EST FIN " 
		global ori_choc "$ori_choc FRA GBR GRC     HRV HUN IDN IND IRL       ITA JPN     KOR LTU LUX LVA MEX              MLT     NLD NOR        POL PRT"
		global ori_choc "$ori_choc ROU ROW RUS       SVK SVN SWE       TUR TWN USA        "
	}
	
	
	if "`source'"=="MRIO" {
		global ori_choc "EUR EAS"
		global ori_choc "$ori_choc AUS AUT BAN BEL BGR BRA BRU BHU CAM  CAN" 
		global ori_choc "$ori_choc CYP CZE DEN EST FIJ FIN"
		global ori_choc "$ori_choc FRA GER GRC  HKG HRV HUN IND INO IRE ITA JPN KAZ KGZ KOR"
		global ori_choc "$ori_choc LAO LTU LUX LVA MAL MEX MLD           MLT  MON NEP NET NOR PAK PHI      POL POR"
		global ori_choc "$ori_choc PRC ROM ROW RUS SIN SPA   SRI     SVK SVN SWE SWI TAP THA      TUR UKG USA VIE"
	}

*   foreach i of numlist 2011 {
	foreach i of numlist `year_list'  {
		clear
		set more off
		compute_leontief `i' `source'
		local pour_gros_fichier 1
		foreach groupeduchoc of global ori_choc {
			compute_B_B2 `i' `groupeduchoc' `source' B
			compute_B_B2 `i' `groupeduchoc' `source' B2
			vector_shock_exch 1 `groupeduchoc' `source' 
			shock_exch `i' `groupeduchoc' `source'
			
			use "$dir/Results/Devaluations/`source'_S_`i'_`groupeduchoc'_exch.dta"
			rename S*t1 shock*1
			if `pour_gros_fichier'==0 {
				merge 1:1 _n using "$dir/Results/Devaluations/`source'_S_`i'_exch.dta"
				drop _merge
			}
			save "$dir/Results/Devaluations/`source'_S_`i'_exch.dta", replace
			
			use "$dir/Results/Devaluations/`source'_Sdollar_`i'_`groupeduchoc'_exch.dta"
			rename S*t1 shock*1
			if `pour_gros_fichier'==0 {
				merge 1:1 _n using "$dir/Results/Devaluations/`source'_Sdollar_`i'_exch.dta"
				drop _merge
			}
			save "$dir/Results/Devaluations/`source'_Sdollar_`i'_exch.dta", replace	
			
			local pour_gros_fichier=0
		}
	use "$dir/Results/Devaluations/`source'_Sdollar_`i'_exch.dta", clear	
	order *, alphabetic
	order shockdollarEUR1 shockdollarEAS1
	merge 1:1 _n using "$dir/Bases/csv_`source'"
	drop _merge
	drop p_shock
	order c s
	save "$dir/Results/Devaluations/`source'_Sdollar_`i'_exch.dta", replace	
	
	
	use "$dir/Results/Devaluations/`source'_S_`i'_exch.dta", clear	
	order *, alphabetic
	order shockEUR1 shockEAS1
	merge 1:1 _n using "$dir/Bases/csv_`source'"
	drop _merge
	drop p_shock
	order c s
	save "$dir/Results/Devaluations/`source'_S_`i'_exch.dta", replace	
    }

}





capture log close


