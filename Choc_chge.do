

*-------------------------------------------------------------------------------
*COMPUTING LEONTIEF INVERSE MATRIX  : matrix L1
*-------------------------------------------------------------------------------

set more off
*set matsize 7000
capture program drop compute_leontief
program compute_leontief
args yrs source
Definition_pays_secteur `source' 


*Create vector Y of output from troncated database
clear
use "$dir/Bases/`source'_`yrs'_OUT.dta", clear
mkmat $var_entree_sortie, matrix(Y)

*Create matrix Z of inter-industry inter-country trade (CI)
use "$dir/Bases/`source'_`yrs'_Z.dta"
mkmat $var_entree_sortie, matrix (Z)



*From vector Y create a diagonal matrix Yd which contains all elements of vector Y on the diagonal
matrix Yd=diag(Y)

*Take the inverse of Yd (with invsym instead of inv for more accurateness and to avoid errors)
matrix Yd1=invsym(Yd)

*Then multiply Yd1 by Z 
matrix A_`yrs'=Z*Yd1
*On obtient A la matrice des coefficients techniques

clear
svmat A_`yrs', names(col)
save "$dir/Bases/A_`source'_`yrs'.dta", replace



*Create identity matrix at the size we want. 
mat I=I($dim_matrice)

*I-A
matrix L=(I-A_`yrs')

*Leontief inverse
mata: l=st_matrix("L")
mata: li=pinv(l)
mata: st_matrix("LI",li)


matrix L1_`yrs'=LI

clear
svmat L1_`yrs', names(col)
save "$dir/Bases/`source'_L1_`yrs'.dta", replace


display "fin de compute_leontief" `yrs'

end

*-------------------------------------------------------------------------------
* On construit la matrice ZB avec des matrices B diagonales
*-------------------------------------------------------------------------------



set more off
*set matsize 7000
capture program drop compute_B_B2
program compute_B_B2
	args yrs groupeduchoc source matrix_obj
*ex : compute_leontief_B_B2 2005 ARG WIOD B


display "`groupeduchoc'"

use "$dir/Bases/A_`source'_`yrs'.dta", clear


merge 1:1 _n using "$dir/Bases/csv_`source'.dta"
drop _merge
rename c pays_choqué

***----  On construit la matrice B avec des 0 partout sauf pour les CI étrangères en provenance du pays choqué (cf. équation (3) du papier) ------*
***----  On construit la matrice B2 avec des 0 partout sauf pour les CI étrangères du pays choqué (équation (4) du papier) ------*

gen grchoc_ligne = 0

foreach p of local groupeduchoc {
	replace grchoc_ligne = 1 if pays_choqué == "`p'" 
	**Cas particuliers d'ensemble de pays
	if ("`p'"=="MEX")  {
		replace grchoc_ligne = 1 if  strpos("$mexique", pays_choqué)!=0
	}
	if ("`p'"=="CHN") {
		replace grchoc_ligne = 1 if  strpos("$china", pays_choqué)!=0
	}
	if ("`p'"=="EUR") {
		replace grchoc_ligne = 1 if strpos("$eurozone", pays_choqué)!=0
	}
	if ("`p'"=="EAS") {
		replace grchoc_ligne = 1 if strpos("$eastern", pays_choqué)!=0
		}	
}
 


gen pays_origine=""
gen grchoc2=0


foreach var of varlist $var_entree_sortie {
	if "`matrix_obj'" =="B" replace `var'=0 if grchoc_ligne==0
	
	
	if "`source'"=="TIVA" |"`source'"=="TIVA_REV4"  replace pays_origine = strupper(substr("`var'",1,strpos("`var'","_")-1))
	if "`source'"=="WIOD" replace pays_origine = strupper(substr("`var'",2,3))
	if "`source'"=="MRIO" replace pays_origine = strupper(substr("`var'",1,3))
	
	foreach p of local groupeduchoc {	
		replace grchoc2 = 1 if pays_origine == "`p'" 
	
		if ("`p'"=="MEX") {
			replace grchoc2 = 1 if  strpos("$mexique", pays_origine)!=0
		}
		if ("`p'"=="CHN") {
			replace grchoc2 = 1 if  strpos("$china", pays_origine)!=0
		} 
		if ("`p'"=="EUR") {
			replace grchoc2 = 1 if strpos("$eurozone", pays_origine)!=0
		}
		if ("`p'"=="EAS") {
		replace grchoc2 = 1 if strpos("$eastern", pays_origine)!=0
		}
	}
	replace `var'=0 if (grchoc_ligne==1  & grchoc2==1)
	if "`matrix_obj'" =="B2" replace `var'=0 if grchoc2==0
	replace grchoc2=0
}


*drop grchoc grchoc2
mkmat $var_entree_sortie, matrix (`matrix_obj')
order pays_choqué s
drop p_shock grchoc_ligne pays_origine grchoc2    /* p shock déjà crée dans csv_source (à zéro)) */
if $test==1 save "$dir/Bases/`source'_`matrix_obj'_`yrs'_`groupeduchoc'.dta", replace
***----  On construit la matrice B2 avec des 0 partout sauf pour les CI étrangères du pays choqué (équation (4) du papier) ------*
/*
use "$dir/Bases/A_`source'_`yrs'.dta", clear

merge 1:1 _n using "$dir/Bases/csv_`source'.dta"
drop _merge

gen grchoc_ligne = 0

foreach p of local groupeduchoc {
	replace grchoc_ligne = 1 if c == "`p'" 

	if ("`p'"=="MEX") {
		replace grchoc_ligne = 1 if strpos("$mexique", c)!=0

		}
	if ("`p'"=="CHN") {
		replace grchoc_ligne = 1 if strpos("$china", c)!=0

		}
	if ("`p'"=="EUR") {
		replace grchoc_ligne = 1 if strpos("$eurozone", c)!=0
	}
	if ("`p'"=="EAS") {
		replace grchoc_ligne = 1 if strpos("$eastern", c)!=0
	}
		
		
}
 

gen pays_origine=""
gen grchoc2=0


foreach var of varlist $var_entree_sortie {
if "`source'"=="TIVA" replace pays_origine = strupper(substr("`var'",1,strpos("`var'","_")-1))
if "`source'"=="WIOD" replace pays_origine = strupper(substr("`var'",2,3))
	
	foreach p of local groupeduchoc {
	
		replace grchoc2 = 1 if pays_origine == "`p'" 

		if ("`p'"=="MEX") {
			replace grchoc2 = 1 if strpos("$mexique", pays_origine)!=0

		}
		if ("`p'"=="CHN") {
			replace grchoc2 = 1 if strpos("$china", pays_origine)!=0
		}
		if ("`p'"=="EUR") {
		replace grchoc2 = 1 if strpos("$eurozone", pays_origine)!=0
		}
		if ("`p'"=="EAS") {
		replace grchoc2 = 1 if strpos("$eastern", pays_origine)!=0
		}
		

	}

	
		replace `var'=0 if grchoc2==0
	replace `var'=0 if (grchoc_ligne==1 & grchoc2==1)
replace grchoc2=0


}
*drop grchoc_ligne grchoc2 pays
mkmat $var_entree_sortie, matrix (B2)

display "fin de compute_B_B2`groupeduchoc'" `yrs'
order c s 

if $test==1 save "$dir/Bases/B2_`source'_`yrs'_`groupeduchoc'.dta", replace


*/

display "fin compute_B_B2" 
***on affiche les deux matrices de Leontief
end

   
*---------------------------------------------------------------------------------------------
*COMPUTING THE EFFECT OF A SHOCK ON EXCHANGE RATE IN ONE COUNTRY  : matrix C`cty'
*---------------------------------------------------------------------------------------------
capture program drop vector_shock_exch
program vector_shock_exch
		args shk groupeduchoc source
		***exepl : vector_shock_exch 1 ARG TIVA

*set matsize 7000
set more off

use "$dir/Bases/csv_`source'.dta", clear

* On construit le vecteur c$, avec le choc c$ pour le pays choqué, 0 sinon (cf. équation 3)

foreach p of local groupeduchoc {

	replace p_shock = `shk' if c == "`p'"
	
	
	if ("`p'"=="MEX") {
			replace p_shock = `shk' if strpos("$mexique", c)!=0
		}
	if ("`p'"=="CHN") {
			replace p_shock = `shk' if strpos("$china", c)!=0
		}	
		
	if ("`p'"=="EUR") {
		replace p_shock = `shk' if strpos("$eurozone", c)!=0
	}
	if ("`p'"=="EAS") {
		replace p_shock = `shk' if strpos("$eastern", c)!=0
	}	
}


*I extract vector p_shock from database with mkmat (Ci$)
mkmat p_shock, matrix(cidollart)
matrix cidollar=cidollart'  /* transposé*/
matrix list cidollar


* On construit le vecteur c tilde$, avec le choc -c pour les pays non choqués, 0 sinon (cf. équation 5)


generate p_shock2=-`shk'
foreach p of local groupeduchoc {

	replace p_shock2 = 0 if c == "`p'"
	
	if ("`p'"=="MEX") {
			replace p_shock2 = 0 if strpos("$mexique", c)!=0
	
	}
	if ("`p'"=="CHN") {
			replace p_shock2 = 0 if strpos("$china", c)!=0

	}	
	if ("`p'"=="EUR") {
		replace p_shock2 = 0 if strpos("$eurozone", c)!=0
	}
	if ("`p'"=="EAS") {
		replace p_shock2 = 0 if strpos("$eastern", c)!=0
	}
	
	
}
*I extract vector p_shock from database with mkmat (Ci tilde $)
mkmat p_shock2, matrix(ctildeidollart)
matrix ctildeidollar=ctildeidollart'
matrix list ctildeidollar

*Example: p_shock = 0.05 if (c = "ARG" & s == "C01T05")

matrix ci=ctildeidollar*(1/(1+`shk'))
matrix list ci
matrix cchapeauidollar=cidollar/(1+`shk')
matrix list cchapeauidollar

display "fin de vector_shock_exch"


end


capture program drop shock_exch
program shock_exch
	args yrs groupeduchoc source
	****expl : shock_exch 2005 ARG TIVA
	
	


use "$dir/Bases/`source'_L1_`yrs'.dta", clear
mkmat c1-c$dim_matrice, matrix (L1)


*Multiplying the transpose of vector shock `v'_shockt by L1 to get the impact of a shock on the output price vector 
*Il s'agit du choc en dollar (équation 6)
matrix Sdollar`groupeduchoc' = cidollar+(cidollar*B+ctildeidollar*B2)*L1


matrix Sdollar`groupeduchoc't=Sdollar`groupeduchoc''
svmat Sdollar`groupeduchoc't
keep Sdollar`groupeduchoc't1


if $test==1 save "$dir/Results/Devaluations/`source'_Sdollar_`yrs'_`groupeduchoc'_exch.dta", replace

matrix S`groupeduchoc' = ci+(cchapeauidollar*B+ci*B2)*L1
matrix S`groupeduchoc't=S`groupeduchoc''
svmat S`groupeduchoc't
keep S`groupeduchoc't1
if $test==1 save "$dir/Results/Devaluations/`source'_S_`yrs'_`groupeduchoc'_exch.dta", replace


display "fin de shock_exch"

end


