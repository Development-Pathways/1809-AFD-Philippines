

/*rename regions*/

rename i ilocos
rename ii cagayan
rename ii centralLuzon
rename iv calabarzon
rename v bicol
rename vi westernvisayas
rename vii centralvisayas
rename viii easternvisayas
rename ix zamboanga
rename x northernmindanao
rename xi davao
rename xii soccsksargen
rename xiii caraga

encode disastersubtype, generate(disastersubtype2)

gen one=1
/*tables of disasters*/

local regions "ilocos cagayan centralLuzon calabarzon bicol westernvisayas centralvisayas easternvisayas zamboanga northernmindanao davao soccsksargen caraga mimaropa ncr car barmm"


foreach x of local regions {
preserve
keep if `x'==1&startyear>=2010
collapse (sum) number_of_events=one totalaffected, by(disastersubtype2) 
gen region="`x'"
save "/Users/marikangasniemi/Documents/`x'.dta"
restore
}

save "/Users/marikangasniemi/Documents/Philippines_disastersnew.dta"

local regions2 "cagayan centralLuzon calabarzon bicol westernvisayas centralvisayas easternvisayas zamboanga northernmindanao davao soccsksargen caraga mimaropa ncr car barmm"

use "/Users/marikangasniemi/Documents/ilocos.dta"

foreach x of local regions2 {
append using "/Users/marikangasniemi/Documents/`x'.dta"
}

save "/Users/marikangasniemi/Documents/all_regions.dta"

keep disastersubtype2 number_of_events region
reshape wide number_of_events, i(region) j(disastersubtype2)
/*
Disaster Subtype |      Freq.     Percent        Cum.
-----------------+-----------------------------------
   Coastal flood |          6        2.00        2.00
         Drought |          4        1.33        3.33
     Flash flood |         31       10.33       13.67
 Flood (General) |         22        7.33       21.00
  Riverine flood |         47       15.67       36.67
  Severe weather |          1        0.33       37.00
 Storm (General) |         10        3.33       40.33
     Storm surge |          1        0.33       40.67
         Tornado |          2        0.67       41.33
Tropical cyclone |        176       58.67      100.00
-----------------+-----------------------------------
           Total |        300      100.00

*/

keep disastersubtype2 totalaffected region
reshape wide totalaffected, i(region) j(disastersubtype2)

