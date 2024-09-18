*load panel

use "/Users/silvianastasi/Downloads/ADB Philippines Food Stamp IE data shared/panel data/panel_household_data.dta", clear

tab round

drop if missing(INTNO)
* balanced panel
drop if INTNO==2563 // missing endline

bysort INTNO: egen mun = max(MUN)
label values mun labels1


graph box total_food_1mo_php_pc , over(MUN)
graph box total2_food_1mo_php_pc , over(MUN)


bysort round: su health_subsidy_* other_subsidy_*

 