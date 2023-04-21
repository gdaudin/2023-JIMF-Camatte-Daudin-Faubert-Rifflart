clear
*set trace on

capture program drop Definition_pays_secteur
program Definition_pays_secteur

args source
*Pour argument dans le programme


*Definition_pays_secteur TIVA 

if "`source'"=="TIVA" {
global country "ARG AUS AUT BEL BGR BRA BRN CAN CHE CHL"
	global country "$country  CHN CN1 CN2 CN3 CN4 COL CRI CYP CZE DEU DNK ESP EST FIN"
	global country "$country  FRA GBR GRC HKG HRV HUN IDN IND IRL ISL ISR ITA JPN KHM KOR"
	global country "$country  LTU LUX LVA MAR MEX MLT MX1 MX2 MX3 MYS NLD NOR NZL PER PHL POL PRT"
	global country "$country  ROU ROW RUS SAU SGP SVK SVN SWE THA TUN TUR TWN USA VNM ZAF"
	
global country_hc "ARG AUS AUT BEL BGR BRA BRN CAN CHE CHL"
	global country_hc "$country_hc  CHN          COL CRI CYP CZE DEU DNK ESP EST FIN"
	global country_hc "$country_hc  FRA GBR GRC HKG HRV HUN IDN IND IRL ISL ISR ITA JPN KHM KOR"
	global country_hc "$country_hc  LTU LUX LVA MAR MEX MLT      MYS NLD NOR NZL PER PHL POL PRT"
	global country_hc "$country_hc  ROU ROW RUS SAU SGP SVK SVN SWE THA TUN TUR TWN USA VNM ZAF"
	
	
global sector "C01T05 C10T14 C15T16 C17T19 C20 C21T22"
	global sector "$sector C23 C24 C25 C26 C27 C28 C29 C30T33X C31 C34 C35 C36T37 C40T41 C45"
	global sector "$sector C50T52 C55 C60T63 C64 C65T67 C70 C71 C72 C73T74 C75 C80 C85 C90T93 C95"
	
	global noneuro "ARG AUS BGR BRA BRN CAN CHE CHL CHN COL CRI CZE DNK GBR HKG HRV HUN IDN IND ISL ISR JPN KHM KOR MEX MX1 MX2 MX3 MYS NOR NZL PER PHL POL ROU ROW RUS SAU SGP SWE THA TUN TUR TWN USA VNM ZAF"
	global china "CHN CN1 CN2 CN3 CN4" /* 5 Chine dans la source --> choquer ce groupe pour choc Chine"*/
	global mexique "MEX MX1 MX2 MX3" /* 4 Mexique dans la source --> choquer ce groupe pour choc Mexique (y.c Maquiladoas)"*/
	
	global var_entree_sortie  arg_c01t05agr-zaf_c95pvh
	global eurozone "AUT BEL CYP DEU ESP EST FIN FRA GRC IRL ITA LTU LUX LVA MLT NLD PRT SVK SVN"
	global eastern "BGR CZE HRV HUN POL ROU"
	
}

	
	if "`source'"=="TIVA_REV4" {
global country "ARG AUS AUT BEL BGR BRA BRN CAN CHE CHL"
	global country "$country  CHN CN1 CN2 COL CRI CYP CZE DEU DNK ESP EST FIN"
	global country "$country  FRA GBR GRC HKG HRV HUN IDN IND IRL ISL ISR ITA JPN KAZ KHM KOR"
	global country "$country  LTU LUX LVA MAR MEX MLT MX1 MX2 MYS NLD NOR NZL PER PHL POL PRT"
	global country "$country  ROU ROW RUS SAU SGP SVK SVN SWE THA TUN TUR TWN USA VNM ZAF"
	
global country_hc "ARG AUS AUT BEL BGR BRA BRN CAN CHE CHL"
	global country_hc "$country_hc  CHN   COL CRI CYP CZE DEU DNK ESP EST FIN"
	global country_hc "$country_hc  FRA GBR GRC HKG HRV HUN IDN IND IRL ISL ISR ITA JPN KAZ KHM KOR"
	global country_hc "$country_hc  LTU LUX LVA MAR MEX MLT    MYS NLD NOR NZL PER PHL POL PRT"
	global country_hc "$country_hc  ROU ROW RUS SAU SGP SVK SVN SWE THA TUN TUR TWN USA VNM ZAF"

	global sector "01T03 05T06 07T08 09"
	global sector "$sector 10T12 13T15 16 17T18 19 20T21 22 23 24 25 26 27 28 29 30 31T33 35T39 41T43 "
	global sector "$sector 45T47 49T53 55T56 58T60 61 62T63 64T66 68 69T82 84 85 86T88 90T96 97T98"
	
	global noneuro "ARG AUS BGR BRA BRN CAN CHE CHL CHN COL CRI CZE DNK GBR HKG HRV HUN IDN IND ISL ISR JPN KAZ KHM KOR MEX MX1 MX2 MYS NOR NZL PER PHL POL ROU ROW RUS SAU SGP SWE THA TUN TUR TWN USA VNM ZAF"
	global china "CHN CN1 CN2" /* 3 Chine dans la source --> choquer ce groupe pour choc Chine"*/
	global mexique "MEX MX1 MX2" /* 3 Mexique dans la source --> choquer ce groupe pour choc Mexique (y.c Maquiladoas)"*/
	
	global var_entree_sortie ARG_01T03-ZAF_97T98
	
	global eurozone "AUT BEL CYP DEU ESP EST FIN FRA GRC IRL ITA LTU LUX LVA MLT NLD PRT SVK SVN"
	global eastern "BGR CZE HRV HUN POL ROU"
	
}
	
if "`source'"=="WIOD" {
	global country "   AUS AUT BEL BGR BRA     CAN CHE" 
	global country "$country CHN                             CYP CZE DEU DNK ESP EST FIN"
	global country "$country FRA GBR GRC     HRV HUN IDN IND IRL        ITA JPN     KOR"
	global country "$country LTU LUX LVA MEX              MLT     NLD NOR        POL PRT"
	global country "$country ROU ROW RUS       SVK SVN SWE       TUR TWN USA        "
	
	global country_hc $country
	
	global sector "A01 A02 A03 B C10-C12 C13-C15 C16 C17 C18 C19 C20 C21 C22"
	global sector "$sector C23 C24 C25 C26 C27 C28 C29 C30 C31_C32 C33 D35 E36 E37-E39"
	global sector "$sector F G45 G46 G47 H49 H50 H51 H52 H53 I J58 J59_J60"
	global sector "$sector J61 J62_J63 K64 K65 K66 L68 M69_M70 M71 M72 M73"
	global sector "$sector M74_M75 N O84 P85 Q R_S T U"
	
	
	global noneuro "BGR BRA CAN CHE CHN CZE DNK  GBR HRV HUN IDN IND  JPN KOR MEX NOR  POL ROU ROW RUS SWE TUR TWN USA"    
	global china "CHN"
	global mexique "MEX"
	
	global var_entree_sortie vAUS01-vUSA56
	global eurozone "AUT BEL CYP DEU ESP EST FIN FRA GRC IRL ITA LTU LUX LVA MLT NLD PRT SVK SVN"
	global eastern "BGR CZE HRV HUN POL ROU"
}


if "`source'"=="MRIO" {
	global country "   AUS AUT BAN BEL BGR BHU BRA BRU CAM  CAN" 
	global country "$country CYP CZE DEN EST FIJ FIN"
	global country "$country FRA GER GRC  HKG HRV HUN IND INO IRE ITA JPN KAZ KGZ KOR"
	global country "$country LAO LTU LUX LVA MAL MEX MLD           MLT  MON NEP NET NOR PAK PHI      POL POR"
	global country "$country PRC ROM ROW RUS SIN SPA  SRI      SVK SVN SWE SWI TAP THA      TUR UKG USA VIE"
	
	global country_hc $country
	
	global sector "C01 C02 C03 C04 C05 C06 C07 C08 C09 C10 C11 C12 C13 C14 C15"
	global sector "$sector C16 C17 C18 C19 C20 C21 C22 C23 C24"
	global sector "$sector C25 C26 C27 C28 C29 C30 C31 C32 C33 C34 C35"
	
	global noneuro "AUT BEL BGR BHU BRA BRU CAM CAN CZE DEN HKG HRV HUN IND INO JPN KAZ KGZ KOR LAO MAL MEX MLD MON NEP NET NOR PAK PHI POL PRC ROM ROW RUS SIN SRI SWI TAP THA TUR UKG USA VIE"    
	global china "PRC"
	global mexique "MEX"
	
	global var_entree_sortie AUS_C01-VIE_C35
	global eurozone "AUT BEL CYP GER SPA EST FIN FRA GRC IRE ITA LTU LUX LVA MLT NET POR SVK SVN"
	global eastern "BGR CZE HRV HUN POL ROM"
}

global nbr_pays = wordcount("$country")
global nbr_secteurs = wordcount("$sector")
global dim_matrice = $nbr_pays*$nbr_secteurs

end
