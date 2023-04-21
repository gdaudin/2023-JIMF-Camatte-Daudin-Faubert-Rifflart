clear
set more off
set matsize 7000

if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA"
else global dir "\\intra\partages\au_dcpm\DiagConj\Commun\CommerceVA"


*capture log close
*log using "$dir/$S_DATE.log", replace

*-------------------------------------------------------------------------------
* graphiques in-degree/out-degree Zone euro pour chaque année, chaque matrice
*-------------------------------------------------------------------------------
foreach source in WIOD  TIVA { 

if "`source'"=="WIOD" local start_year 2000
if "`source'"=="TIVA" local start_year 1995

if "`source'"=="WIOD" local end_year 2014
if "`source'"=="TIVA" local end_year 2011


local poids "X Yt HC"
foreach n of local poids{

	foreach i of numlist `start_year' (1)`end_year'  {

		graph twoway scatter indegree outdegree if (poids=="`n'" & shock_type=="p" & year==`i' & dum_GP==1), mlabel(pays) yscale(log) xscale(log) title("indegreee/outdegree price choc, `i'") subtitle("weighted : `n'") xtitle("outdegree") ytitle("indegree")  saving($dir\Graphiques\Devaluation/graphp_`source'_`i'_`n') 
		graph export $dir/Graphiques\Devaluation/graphp_`source'_`i'_`n'.pdf
		}
	}
				
/*local poids "X Yt HC"
foreach n of local poids{

	foreach i of numlist 1995 2000 2005  {

		graph twoway scatter indegree outdegree if (weight=="`n'" & shock_type=="w" & year==`i' & dum_GP==1), mlabel(pays) yscale(log) xscale(log) title("indegreee/outdegree wage choc, `i'") subtitle(" weighted : `n'") xtitle("outdegree") ytitle("indegree") saving($dir/Graphiques\Graphiques_2502/graphw_`i'_`n') 
		graph export $dir/Graphiques\Graphiques_2502/graphw_`i'_`n'.pdf
		
	}
}
}*/

*-------------------------------------------------------------------------------
* graphiques pin-degree/pout-degree Zone euro pour chaque année, chaque matrice
*-------------------------------------------------------------------------------


local poids "X Yt HC"
foreach n of local poids{

	foreach i of numlist `start_year' (1)`end_year' {

		graph twoway scatter pindegree poutdegree if (poids=="`n'" & shock_type=="p" & year==`i' & dum_GP==1), mlabel(pays) yscale(log) xscale(log) title("pindegreee/poutdegree price choc, `i'") subtitle("weighted : `n'") xtitle("poutdegree") ytitle("pindegree")  saving($dir\Graphiques\Devaluation/graphpp_`source'_`i'_`n') 
		graph export $dir/Graphiques\Devaluation/graphpp_`source'_`i'_`n'.pdf
		}
	}
				
/* local poids "X Yt"
foreach n of local poids{

	foreach i of numlist 1995 2000 2005 {

		graph twoway scatter pindegree poutdegree if (weight=="`n'" & shock_type=="w" & year==`i' & dum_GP==1), mlabel(pays) yscale(log) xscale(log) title("pindegreee/poutdegree wage choc, `i'") subtitle(" weighted : `n'") xtitle("poutdegree") ytitle("pindegree") saving($dir/Graphiques\Graphiques_2502/graphwp_`i'_`n') 
		graph export $dir/Graphiques\Graphiques_2502/graphwp_`i'_`n'.pdf
		
	}
}*/

*-------------------------------------------------------------------------------
* graphiques pin-degree_chap/pout-degree_chap Zone euro pour chaque année, chaque matrice
*-------------------------------------------------------------------------------


local poids "X Yt HC"
foreach n of local poids{

	foreach i of numlist `start_year' (1)`end_year' {

		graph twoway scatter pindegree_chap poutdegree_chap if (poids=="`n'" & shock_type=="p" & year==`i' & dum_GP==1), mlabel(pays) yscale(log) xscale(log) title("pindegreee_chap/poutdegree_chap price choc, `i'") subtitle("weighted : `n'") xtitle("poutdegree_chap") ytitle("pindegree_chap")  saving($dir\Graphiques\Devaluation/graphchap_`source'_`i'_`n') 
		graph export $dir/Graphiques\Devaluation/graphpchap_`source'_`i'_`n'.pdf
		}
	}
				
/* local poids "X Yt"
foreach n of local poids{

	foreach i of numlist 1995 2000 2005 {

		graph twoway scatter pindegree_chap poutdegree_chap if (weight=="`n'" & shock_type=="w" & year==`i' & dum_GP==1), mlabel(pays) yscale(log) xscale(log) title("pindegreee_chap/poutdegree_chap wage choc, `i'") subtitle(" weighted : `n'") xtitle("poutdegree_chap") ytitle("pindegree_chap") saving($dir/Graphiques\Graphiques_2502/graphwchap_`i'_`n') 
		graph export $dir/Graphiques\Graphiques_2502/graphwchap_`i'_`n'.pdf
		
	}
}*/



*-------------------------------------------------------------------------------
* graphiques in-degree/out-degree Zone euro pour 1995/2011, chaque matrice
*-------------------------------------------------------------------------------


tostring year, replace
separate indegree, by(year)

local poids "X Yt HC"
foreach n of local poids{

	egen mini=min(indegree) if (poids=="`n'" & shock_type=="p" & (year=="`start_year'" | year=="`end_year'"))
	egen maxi=max(indegree) if (poids=="`n'" & shock_type=="p" & (year=="`start_year'" | year=="`end_year'"))
	gen diagonale=outdegree if (outdegree<maxi & outdegree>mini)
		
	graph twoway (scatter indegree1 indegree7 outdegree,mlabel(pays pays) ) (line diagonale outdegree) if (poids=="`n'" & shock_type=="p" & (year=="`start_year'"|year=="`end_year'") & dum_GP==1),  yscale(log) xscale(log) title("indegreee/outdegree price shock, 1995/2011") subtitle("weighted : `n'") xtitle("outdegree") ytitle("indegree") saving($dir/Graphiques\Devaluation/graphp_`source'_`start_year'_`end_year'_`n') 
	graph export $dir/Graphiques\Devaluation/graphp_`source'_`start_year'_`end_year'_`n'.pdf
		
	drop mini
	drop maxi
	drop diagonale								
						}
						

*-------------------------------------------------------------------------------
* graphiques pin-degree/pout-degree Zone euro pour 1995/2011, chaque matrice
*-------------------------------------------------------------------------------

tostring year, replace
separate pindegree, by(year)

local poids "X Yt HC"

foreach n of local poids{

	egen mini=min(pindegree) if (poids=="`n'" & shock_type=="p" & (year=="`start_year'" | year=="`end_year'"))
	egen maxi=max(pindegree) if (poids=="`n'" & shock_type=="p" & (year=="`start_year'" | year=="`end_year'"))
	gen diagonale=poutdegree if (poutdegree<maxi & poutdegree>mini)
		
	graph twoway (scatter pindegree1 pindegree7 poutdegree,mlabel(pays pays) ) (line diagonale poutdegree) if (poids=="`n'" & shock_type=="p" & (year=="1995"|year=="2011") & dum_GP==1),  yscale(log) xscale(log) title("pindegreee/poutdegree price shock, 1995/2011") subtitle("weighted : `n'") xtitle("poutdegree") ytitle("pindegree") saving($dir/Graphiques\Devaluation/graphp2_`source'_`start_year'_`end_year'_`n') 
	graph export $dir/Graphiques\Devaluation/graphp2_`source'_`start_year'_`end_year'_`n'.pdf
		
	drop mini
	drop maxi
	drop diagonale								
						}
						
						
*-------------------------------------------------------------------------------
* graphiques in-degree/out-degree Zone euro pour 1995/2011, chaque matrice
*-------------------------------------------------------------------------------


tostring year, replace
separate pindegree_chap, by(year)

local poids "X Yt HC"
foreach n of local poids{

	egen mini=min(pindegree_chap) if (poids=="`n'" & shock_type=="p" & (year=="`start_year'" | year=="`end_year'"))
	egen maxi=max(pindegree_chap) if (poids=="`n'" & shock_type=="p" & (year=="`start_year'" | year=="`end_year'"))
	gen diagonale=poutdegree_chap if (poutdegree<maxi & poutdegree_chap>mini)
		
	graph twoway (scatter pindegree_chap1 pindegree_chap7 poutdegree_chap,mlabel(pays pays) ) (line diagonale poutdegree_chap) if (poids=="`n'" & shock_type=="p" & (year=="1995"|year=="2011") & dum_ZE==1),  yscale(log) xscale(log) title("pindegree_chap/poutdegree_chap price shock, 1995/2011") subtitle("weighted : `n'") xtitle("poutdegree_chap") ytitle("pindegree_chap") saving($dir/Graphiques\Devaluation/graphpZE_`source'_`start_year'_`end_year'_`n') 
	graph export $dir/Graphiques\Devaluation/graphpZE_`source'_`start_year'_`end_year'_`n'.pdf
		
	drop mini
	drop maxi
	drop diagonale								
						}
						
*-------------------------------------------------------------------------------
* graphiques in-degree/out-degree Grands Pays pour 1995/2011, chaque matrice
*-------------------------------------------------------------------------------


tostring year, replace
separate pindegree_chap, by(year)

local poids "X Yt HC"
foreach n of local poids{

	egen mini=min(pindegree_chap) if (poids=="`n'" & shock_type=="p" & (year=="`start_year'" | year=="`end_year'"))
	egen maxi=max(pindegree_chap) if (poids=="`n'" & shock_type=="p" & (year=="`start_year'" | year=="`end_year'"))
	gen diagonale=poutdegree_chap if (poutdegree<maxi & poutdegree_chap>mini)
		
	graph twoway (scatter pindegree_chap1 pindegree_chap7 poutdegree_chap,mlabel(pays pays) ) (line diagonale poutdegree_chap) if (poids=="`n'" & shock_type=="p" & (year=="1995"|year=="2011") & dum_GP==1),  yscale(log) xscale(log) title("pindegree_chap/poutdegree_chap price shock, 1995/2011") subtitle("weighted : `n'") xtitle("poutdegree_chap") ytitle("pindegree_chap") saving($dir/Graphiques\Devaluation/graphp_`source'_`start_year'_`end_year'_`n') 
	graph export $dir/Graphiques\Devaluation/graphp_`source'_`start_year'_`end_year'_`n'.pdf
		
	drop mini
	drop maxi
	drop diagonale								
						}
						

				
*-------------------------------------------------------------------------------
* graphiques in-degree par taille, avec une droite de régression
*-------------------------------------------------------------------------------

local poids "X Yt HC"
local deg "indegree outdegree poutdegree pindegree"

foreach d of local deg{
	foreach n of local poids{

		foreach i of numlist `start_year' (1)`end_year'  {
		
			reg `d' `n' if (poids=="`n'" & shock_type=="p" & year==`i' )
			predict `d'_chap_`n'_`i'
			graph twoway (scatter `d'  `n',mlabel(pays pays)) (line `d'_chap_`n'_`i' `n') if (poids=="`n'" & shock_type=="p" & year==`i' & dum_GP==1),  title("`d'/weight price choc, `i'") subtitle("weighted : `n'") xtitle("poids `n'") ytitle("`d'")  saving($dir/Graphiques\Devaluation/graphp_`source'_`d'_`i'_`n') 
			*yscale(log) xscale(log)   || lfit `d' `n'   & dum_UE==1
			graph export $dir/Graphiques\Devaluation/graphp_`source'_`d'_`i'_`n'.pdf
			}
		}
	}				

log close
}

