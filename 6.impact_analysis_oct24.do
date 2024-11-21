/*
This code analyses the impact of the WG program using endline and baseline data, and exports (.tex format) to overleaf
Updated: oct 1, 2024
*/
*******************************************************************
** CODE FOR TABLES FOR DSWD PRESENTATION: ONLY LATE
*******************************************************************

/*
SPECIFICATIONS:

LATE(twfe): 
ivregdhfe outcome (Dit_registered = Dit), absorb(i.INTNO i.endline) cluster(clustervar)

LATE(endline):
ivreghdfe outcome (registered = treatment) if endline == 1, absorb(i.pair_rank) cluster(clustervar)

With:
- endline = 0 in baseline, 1 in endline
- treatment = 1 if assigned to treatment group, 0 is assigned to control group (time-constant variable)
- registered = 1 if effectively treated, 0 if not effectively treated (time-constant variable)
- Dit = treatment * endline
- Dit_registered = registered * endline
*/


/* ****TESTS ****
ivreghdfe total2_food_1mo_php (registered_walang_gutom=treatment) if endline == 1, absorb(i.pair_rank) cluster(clustervar)

ivreghdfe total2_food_1mo_php (Dit_registered= Dit), absorb(i.INTNO i.endline) cluster(clustervar)
*/

clear all
set more off
set maxvar 10000


* set paths
if c(username) == "juliagirard"{
	global dir = "/Users/juliagirard/Dropbox/ADB Philippines Food Stamp IE data shared"
	global diroverleaf = "/Users/juliagirard/Dropbox/Applications/Overleaf/Philippines Food Stamps IE/figures"
	}
global dirwork = "$dir/work"
global diroutput = "$dir/output"


* program : appendmodels
{
capt prog drop appendmodels
*! version 1.0.0  14aug2007  Ben Jann
program appendmodels, eclass
    // using first equation of model
    version 8
    syntax namelist
    tempname b V tmp
    foreach name of local namelist {
        qui est restore `name'
        mat `tmp' = e(b)
        local eq1: coleq `tmp'
        gettoken eq1 : eq1
        mat `tmp' = `tmp'[1,"`eq1':"]
        local cons = colnumb(`tmp',"_cons")
        if `cons'<. & `cons'>1 {
            mat `tmp' = `tmp'[1,1..`cons'-1]
        }
        mat `b' = nullmat(`b') , `tmp'
        mat `tmp' = e(V)
        mat `tmp' = `tmp'["`eq1':","`eq1':"]
        if `cons'<. & `cons'>1 {
            mat `tmp' = `tmp'[1..`cons'-1,1..`cons'-1]
        }
        capt confirm matrix `V'
        if _rc {
            mat `V' = `tmp'
        }
        else {
            mat `V' = ///
            ( `V' , J(rowsof(`V'),colsof(`tmp'),0) ) \ ///
            ( J(rowsof(`tmp'),colsof(`V'),0) , `tmp' )
        }
    }
    local names: colfullnames `b'
    mat coln `V' = `names'
    mat rown `V' = `names'
    eret post `b' `V'
    eret local cmd "whatever"
end
}


* open cleaned panel dataset
use "$dir/panel data/panel_household_data.dta", clear

/* done in Odabayar's gone directly now
* keep balanced panel only
gen endline = (round == 2)
drop if INTNO == .
drop if treatment ==.
bysort INTNO: gen temp = _N
tab temp // 1 for 1 obs
drop if temp == 1
drop temp
*/

* declare panel 
xtset INTNO endline // balanced
sort INTNO endline
order INTNO endline

* choose clustering variable (for se)
qui drop clustervar
gen clustervar = final_cluster

/* idem
* Dit var for twfe and late/iv
gen Dit = endline * treatment
gen Dit_registered = endline * registered_walang_gutom

* household size, above/below median at baseline
gen temp = 1 if hhsize <= 6 & endline == 0
replace temp = 0 if hhsize > 6 & endline == 0
bysort INTNO: egen smaller_hhsize = max(temp)
drop temp
tab smaller_hhsize if endline == 0
/*
smaller_hhs |
        ize |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |      2,606       52.74       52.74
          1 |      2,335       47.26      100.00
------------+-----------------------------------
      Total |      4,941      100.00
*/
*/
gen larger_hhsize = (smaller_hhsize == 0)

* var identifying household whose size vary by more than 3 individuals
gen temp = hhsize if endline == 0
bysort INTNO: egen hhsize_baseline = max(temp)
drop temp
gen temp = hhsize if endline == 1
bysort INTNO: egen hhsize_endline = max(temp)
drop temp
gen hhsize_little_change = 1 if abs(hhsize_endline-hhsize_baseline) <= 3

/* idem
* baseline nutrition knowledge (above/below median baseline level)
su quiz_share_correct if endline == 0, d
gen temp = 1 if quiz_share_correct >= 0.5294118 & endline == 0
replace temp = 0 if quiz_share_correct < 0.5294118 & endline == 0
bysort INTNO: egen higher_quiz_baseline = max(temp)
drop temp
*/
gen temp = 1 if quiz_share_correct >= 0.6470588 & endline == 0
replace temp = 0 if quiz_share_correct < 0.6470588 & endline == 0
bysort INTNO: egen higherQ75_quiz_baseline = max(temp)
drop temp

* aggregating some food exp vars
gen spend_other = spend_9 + spend_10 + spend_11


* aggregating non-food expenditures, and shortening labels
/*
gen expenses_vicegoods_php = expenses_12 + expenses_14 + expenses_15 
lab var expenses_vicegoods_php "Alcohol, gambling, tobacco"

gen expenses_rent_utilities_php = expenses_3 + expenses_4 + expenses_5 + expenses_16
lab var expenses_rent_utilities_php "Rent, utilities, durables"

gen expenses_entertainment_php = expenses_9 + expenses_11
lab var expenses_entertainment_php "Entertainment, info, com."

gen expenses_gifts_events_php = expenses_8 + expenses_7
lab var expenses_gifts_events_php "Gifts, transfers, events"
*/
lab var expenses_1 "Schooling"
lab var expenses_2 "Healthcare"
lab var expenses_6 "Transport"
lab var expenses_10 "Personal hygiene products"
lab var expenses_13 "Clothing and toys"
lab var tot_non_food_expenses "Total"
lab var tot_non_food_expenses_ln "Total, log"
lab var tot_non_food_expenses_pc "Total, per capita"
lab var tot_non_food_expenses_pc_ln "Total, per capita, log"


* label and rename the fcs vars (if too long throws an error)
label var fcs_score_hh_avg "FCS: household average"

label var fcs_score_adult_a "FCS: adults"
label var fcs_score_adult_m "FCS: adult males"
label var fcs_score_adult_f "FCS: adult females "

label var fcs_score_child_3_17_a "FCS: child 3-17"
label var fcs_score_child_3_17_m "FCS: child 3-17 males"
label var fcs_score_child_3_17_f "FCS: child 3-17 females"

label var fcs_score_child_3_11_a "FCS: child 3-11"
label var fcs_score_child_3_11_m "FCS: child 3-11 males"
label var fcs_score_child_3_11_f "FCS: child 3-11 females"

label var fcs_score_child_12_17_a "FCS: child 12-17"
label var fcs_score_child_12_17_m "FCS: child 12-17 males"
label var fcs_score_child_12_17_f "FCS: child 12-17 females"

* shorten labels
lab var total2_food_1mo_php "Total"
lab var total2_food_1mo_php_ln "Total, log"
lab var total2_food_1mo_php_pc "Total, per cap."
lab var total2_food_1mo_php_ln_pc "Total, per cap., log"

* var for baseline and endline 4P status (already done now in data)
lab var health_subsidy_8 "Self-declared Status (survey)"

gen temp = 1 if health_subsidy_8 == 1 & endline == 0
replace temp = 0 if health_subsidy_8 == 0 & endline == 0
bysort INTNO: egen temp_baseline_4p = max(temp)
drop temp

gen temp = 1 if health_subsidy_8 == 1 & endline == 1
replace temp = 0 if health_subsidy_8 == 0 & endline == 1
bysort INTNO: egen temp_endline_4p = max(temp)
drop temp

* var for official 4P status
merge m:1 INTNO using "/Users/juliagirard/Dropbox/AFD/wg_philippines/data_list_4Ps/WG Pilot Household List IDs.dta"
drop if _merge == 2 // those in baseline not in endline, already dropped from the master
drop _merge
gen actual_4P_31aug24 = (REMARKS == "Matched")
lab var actual_4P_31aug24 "Official Status (31aug24)"

* var for food enterprise at baseline
gen temp = enterprise_food if endline == 0
bysort INTNO: egen enterprise_food_baseline = max(temp)
drop temp

* meal planner gender at baseline/endline
replace meal_planner_gender = 0 if meal_planner_gender == 2 // never missing
gen temp = meal_planner_gender if endline == 0
bysort INTNO: egen meal_planner_gender_baseline = max(temp)
drop temp

* any hunger baseline
gen temp = any_hunger_3mo if endline == 0
bysort INTNO: egen any_hunger_3mo_baseline = max(temp)
drop temp

* tondo / non tondo
gen tondo = (mun == 138060)

* by km to fixed vendor
su km_to_fixed_vendor if endline ==0, d // median is 1.68 kilometers
//hist km_to_fixed_vendor if endline ==0 // ranges from almost 0 to above 28 kms, many values around 0-2km
gen km_to_fixed_vendor_cat = "<= 1.5 km" if km_to_fixed_vendor <= 1.5
replace km_to_fixed_vendor_cat = "> 1.5 km and <= 5 km" if km_to_fixed_vendor > 1.5 & km_to_fixed_vendor <= 5
replace km_to_fixed_vendor_cat = "> 5 km" if km_to_fixed_vendor > 5

* own food production at baseline // var never missing
gen temp = (endline == 0 & (enterprise_crop_farming == 1 | enterprise_livestock == 1 |enterprise_fish == 1))
bysort INTNO: egen enterprise_ownfood_baseline = max(temp)
drop temp


* label food and nonfood exp
label var tot_non_food_expenses "Tot. non-food exp."
label var total2_food_1mo_php "Tot. food acquisition"

* indicator var for days since redemption, in tondo
gen over12d_since_redemption = (days_since_redemption >= 12)

* export dataset for use in R (GenericML test)
saveold "$dirwork/panel_household_data_R.dta", version(12) replace


*
merge 1:1 INTNO endline using "$dirwork/shock_negative_endline.dta", keep(1 3) nogen


ivreghdfe negative_strat_clim_12mo (registered = treatment) if endline == 1, absorb(i.pair_rank) cluster(clustervar) // 0.031, pvalue 0.121, N = 2341
su negative_strat_clim_12mo if endline == 1 & treatment == 0 // control mean at endline = 0.24
ivreghdfe negative_strat_clim_12mo (registered = treatment) if endline == 1 & tondo == 1, absorb(i.pair_rank) cluster(clustervar) // 0.045, pvalue 0.054, N = 1774
ivreghdfe negative_strat_clim_12mo (registered = treatment) if endline == 1 & tondo == 0, absorb(i.pair_rank) cluster(clustervar) // -0.015, pvalue > 65%, N = 567

ivreghdfe negative_strat_clim_6mo (registered = treatment) if endline == 1, absorb(i.pair_rank) cluster(clustervar) // 0.033, pvalue 0.126, N = 2146
su negative_strat_clim_6mo if endline == 1 & treatment == 0 // control mean at endline = 0.23
ivreghdfe negative_strat_clim_6mo (registered = treatment) if endline == 1 & tondo == 1, absorb(i.pair_rank) cluster(clustervar) // similar
ivreghdfe negative_strat_clim_6mo (registered = treatment) if endline == 1 & tondo == 0, absorb(i.pair_rank) cluster(clustervar) // smaller, not sign, small sample

ivreghdfe negative_strat_6mo (registered = treatment) if endline == 1, absorb(i.pair_rank) cluster(clustervar) // 0.016 , pvalue 0.425, N = 2557
su negative_strat_6mo if endline == 1 & treatment == 0 // control mean at endline = 0.26
ivreghdfe negative_strat_6mo (registered = treatment) if endline == 1 & tondo == 1, absorb(i.pair_rank) cluster(clustervar) // 0.039, pval = 0.086, N = 1900
ivreghdfe negative_strat_6mo (registered = treatment) if endline == 1 & tondo == 0, absorb(i.pair_rank) cluster(clustervar) // -0.055, pval = 0.215, N = 657


ivreghdfe negative_impact_6mo (registered = treatment) if endline == 1, absorb(i.pair_rank) cluster(clustervar) // -0.016, pvalue 0.283, N = 2557
su negative_impact_6mo if endline == 1 & treatment == 0 // control mean at endline = 0.85
ivreghdfe negative_impact_6mo (registered = treatment) if endline == 1 & tondo == 1, absorb(i.pair_rank) cluster(clustervar)
ivreghdfe negative_impact_6mo (registered = treatment) if endline == 1 & tondo == 0, absorb(i.pair_rank) cluster(clustervar)

ivreghdfe negative_impact_clim_6mo (registered = treatment) if endline == 1, absorb(i.pair_rank) cluster(clustervar) // -0.028, pvalue 0.105, N = 2146
su negative_impact_clim_6mo if endline == 1 & treatment == 0 // control mean at endline = 0.84
ivreghdfe negative_impact_clim_6mo (registered = treatment) if endline == 1 & tondo == 1, absorb(i.pair_rank) cluster(clustervar) // -0.037, pvalue = 0.065, N = 1757 (control mean at endline ==0.83)
ivreghdfe negative_impact_clim_6mo (registered = treatment) if endline == 1 & tondo == 0, absorb(i.pair_rank) cluster(clustervar) // 0.014, pvalue > 60%, N = 389


ivreghdfe negative_impact_strat_6mo (registered = treatment) if endline == 1, absorb(i.pair_rank) cluster(clustervar) // 0.031, pvalue 0.205, N = 2163
su negative_impact_strat_6mo if endline == 1 & treatment == 0 // 0.28
ivreghdfe negative_impact_strat_6mo (registered = treatment) if endline == 1 & tondo == 1, absorb(i.pair_rank) cluster(clustervar) // 0.049, pvalue 0.075, N = 1583
ivreghdfe negative_impact_strat_6mo (registered = treatment) if endline == 1 & tondo == 0, absorb(i.pair_rank) cluster(clustervar) // negative, not sign., N = 580

