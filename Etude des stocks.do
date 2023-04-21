*****Mettre global test =1 provoquera la sauvegarde de plein de matrices / vecteurs à vérifier

clear  
set more off
if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA"
else global dir "\\intra\partages\au_dcpm\DiagConj\Commun\CommerceVA"




capture log close
*log using "$dir/$S_DATE.log", replace
set matsize 7000
*set mem 700m if earlier version of stata (<stata 12)
set more off
global test 0
*Mettre test=1 pour sauver les tableaux un par un et test=0 pour ne pas encombrer le DD.


if ("`c(username)'"=="guillaumedaudin") do  "~/Documents/Recherche/2017 BDF_Commerce VA/commerce_VA_inflation/Definition_pays_secteur.do" `source' 
if ("`c(username)'"=="w817186") do "X:\Agents\FAUBERT\commerce_VA_inflation\Definition_pays_secteur.do" `source' 
if ("`c(username)'"=="n818881") do  "X:\Agents\LALLIARD\commerce_VA_inflation\Definition_pays_secteur.do" `source' 



local source TIVA
local yrs 2011

use "$dir/Bases/`source'_ICIO_`yrs'.dta"

gen inv_share = .

egen tot_use = rowtotal(arg_c01t05agr-nps_zaf)
gen pays = substr(v1,1,3)

foreach pays of global country {
	local lpays = lower("`pays'")
	
	capture replace inv_share= inv_`lpays'/tot_use if pays=="`pays'"
}
	
bys pays : gen pour_moy_pond1  = tot_use*inv_share
bys pays : egen pays_tot_use   = total(tot_use)
bys pays : egen pour_moy_pond2 = total(pour_moy_pond1)
gen pays_inv_share=pour_moy_pond2/pays_tot_use

tab pays if abs(inv_share) > 1 & inv_share!=.
