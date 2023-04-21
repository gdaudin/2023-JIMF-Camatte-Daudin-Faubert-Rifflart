***---------------------Description du lanceur----------------------
***HC, GD, 10/2018
***Ce programme sert  1)à créer les bases TIVA et WIOD et à les mettre au bon format (à faire tourner lors des MAJ des bases) [programme constr_bases] et 2)à nommer les pays/secteurs [definition_pays_secteurs]
***Ce lanceur prend 10 mn pour faire tourner les programmes****
***---------------------Fin de la description du lanceur------------

clear

if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA"
if ("`c(hostname)'" == "widv270a") global dir  "D:\home\T822289\CommerceVA" 

if ("`c(username)'"=="guillaumedaudin") global dirgit "~/Répertoires Git/2023 JIMF Camatte Daudin Faubert Rifflart"
if ("`c(hostname)'" == "widv270a") global dirgit  "D:\home\T822289\CommerceVA\GIT\commerce_va_inflation" 

capture log using "$dir/Temporaire/$S_DATE.log", replace
set matsize 7000
*set mem 700m if earlier version of stata (<stata 12)
set more off

cd "$dir"

******************** Construction des bases TIVA et WIOD ****************

do "$dirgit/1_constr_bases.do"

******Définition des Pays et des secteurs ********************

do "$dirgit/Definition_pays_secteur.do" 

******************** Lancement des programmes ****************

foreach i of numlist 2000 2007(1)2019 {
	clear
	save_data `i' MRIO
	prepare_database `i' MRIO
}


/*
foreach i of numlist 1995(1)2011 {
	clear
	save_data `i' TIVA
	prepare_database `i' TIVA
}


foreach i of numlist 2000(1)2014 {
	clear
	save_data `i' WIOD
	prepare_database `i' WIOD
}



foreach i of numlist 2005(1)2015 {
	clear
	save_data `i' TIVA_REV4
	prepare_database `i' TIVA_REV4
}


database_csv TIVA
database_csv TIVA_REV4
database_csv WIOD
*/
database_csv MRIO


******************** Identifie composantes pour IPC ****************
do "$dirgit/Definition_composante_HC.do"
********************************************************************

set more off


log close


