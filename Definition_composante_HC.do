

clear  
set more off
if ("`c(username)'"=="guillaumedaudin") global dir "~/Documents/Recherche/2017 BDF_Commerce VA"
if ("`c(hostname)'" == "widv270a") global dir  "D:\home\T822289\CommerceVA" 

*capture log close
*log using "$dir/$S_DATE.log", replace

***********WIOD*************
use "$dir/Bases/csv_WIOD.dta", clear
replace c=upper(c)
replace s=upper(s)
capture generate agregat_secteur="na" 
replace agregat_secteur="alimentaire" if s=="A01" || s=="A03"

*NEIG: bien manuf hors energie
replace agregat_secteur="neig" if s=="A02" || s=="C10-C12"|| s=="C13-C15" ||s=="C16" || s=="C17" ||s=="C18"|| s=="C20"|| s=="C21"|| s=="C22"|| s=="C23"||s=="C24"||s=="C25"||s=="C26"||s=="C27"|| s=="C28"||s=="C29" || s=="C30" || s=="C31_C32"|| s=="C33"||s=="F"

replace agregat_secteur="services" if s=="E36" || s=="E37-39" || s=="H49" || s=="H50" || s=="H51" || s=="H52" || s=="H53" || s=="I"|| s=="J58"|| s=="J59_J60" || s=="J61" || s=="J62_J63" || s=="K64" || s=="K65" || s=="K66" ||  s=="E36" || s=="E37-E39" || s=="L68" || s=="M69_M70"|| s=="M71" || s=="M72" || s=="M73" || s=="M74_M75" || s=="N" || s=="O84" || s=="P85" ||  s=="Q" ||  s=="R_S" ||  s=="G45" ||  s=="G46" ||  s=="G47" || s=="T" || s=="U"

replace agregat_secteur="energie" if s=="D35"  || s=="C19" || s=="B"
 save "$dir/Bases/csv_WIOD.dta", replace

  
 ***********TIVA 2016*************
use "$dir/Bases/csv_TIVA.dta", clear
replace c=upper(c)
replace s=upper(s)

capture generate agregat_secteur="na" 
replace agregat_secteur="alimentaire" if s=="C01T05" || s=="C15T16"

*NEIG: bien manuf hors energie (y.c. construction)
replace agregat_secteur="neig" if s=="C17T19" || s=="C20"|| s=="C21T22" || s=="C24" ||s=="C25"|| s=="C26"|| s=="C27"|| s=="C28"|| s=="C29"||s=="C30T33X"||s=="C31"||s=="C34"||s=="C35"|| s=="C36T37"||s=="C45" 

replace agregat_secteur="services" if s=="C50T52" || s=="C55" || s=="C60T63" || s=="C64" || s=="C65T67" || s=="C70" || s=="C71" || s=="C72"|| s=="C73T74"|| s=="C75" || s=="C80" || s=="C85" || s=="C90T93" || s=="C95" 

replace agregat_secteur="energie" if s=="C10T14"  || s=="C40T41" || s=="C23"
 save "$dir/Bases/csv_TIVA.dta", replace

 
 
  ***********TIVA REV4 2018*************
use "$dir/Bases/csv_TIVA_REV4.dta", clear
replace c=upper(c)
replace s=upper(s)

capture generate agregat_secteur="na" 
replace agregat_secteur="alimentaire" if s=="01T03" || s=="10T12"

*NEIG: bien manuf hors energie (y.c. construction)
replace agregat_secteur="neig" if s=="13T15" || s=="16" ||s=="17T18"|| s=="20T21"|| s=="22"|| s=="23"|| s=="24"||s=="25"||s=="26"|| s=="27"||s=="28" ||s=="29" ||s=="30" ||s=="31T33" ||s=="41T43" 

replace agregat_secteur="services" if s=="45T47" || s=="49T53" ||s=="55T56"|| s=="58T60"|| s=="61"|| s=="62T63"|| s=="64T66"||s=="68"||s=="69T82"|| s=="84"||s=="85"||s=="86T88"||s=="90T96"|| s=="97T98"

replace agregat_secteur="energie" if s=="05T06"  || s=="07T08"  || s=="09"  || s=="19T23" || s=="19"  || s=="35T39"
 save "$dir/Bases/csv_TIVA_REV4.dta", replace

***********TIVA REV4 2018*************
use "$dir/Bases/csv_MRIO.dta", clear

replace c=upper(c)
replace s=upper(s)

capture generate agregat_secteur="na" 
replace agregat_secteur="alimentaire" if s=="C1" || s=="C3"
*NEIG: bien manuf hors energie (y.c. construction)
replace agregat_secteur="neig" if s=="C4" || s=="C5" ||s=="C6"|| s=="C7"|| s=="C9"|| s=="C10"|| s=="C11"||s=="C12"||s=="C13"|| s=="C14"||s=="C15" ||s=="C16" ||s=="C18"

replace agregat_secteur="services" if s=="C19" || s=="C20" ||s=="C21"|| s=="C22"|| s=="C23"|| s=="C24"|| s=="C25"||s=="C26"||s=="C27"|| s=="C28"||s=="C29"||s=="C30"||s=="C31"|| s=="C32" || s=="C33"|| s=="C34"|| s=="C35"

replace agregat_secteur="energie" if s=="C2"  || s=="C8"  || s=="C17"
 save "$dir/Bases/csv_MRIO.dta", replace
