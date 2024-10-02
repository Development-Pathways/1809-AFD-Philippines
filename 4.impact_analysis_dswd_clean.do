/*
This code analyses the impact of the WG program using endline and baseline data, and exports (.tex format) to overleaf
Updated: sept. 5 2024
*/
*******************************************************************
** CODE FOR TABLES FOR DSWD PRESENTATION: ONLY LATE
*******************************************************************

/*
SPECIFICATIONS:

LATE(twfe): 
ivregdhfe outcome (Dit_registered = Dit), absorb(i.INTNO i.endline) cluster(clustervar)

LATE(endline):
ivreghdfe outcome (registered = treatment), absorb(i.pair_rank) cluster(clustervar)

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


* aggregating non-food expenditures, and shortening labels
gen expenses_vicegoods_php = expenses_12 + expenses_14 + expenses_15 
lab var expenses_vicegoods_php "Alcohol, gambles, tobacco"

gen expenses_rent_utilities_php = expenses_3 + expenses_4 + expenses_5 + expenses_16
lab var expenses_rent_utilities_php "Rent, utilities, durables"

gen expenses_entertainment_php = expenses_9 + expenses_11
lab var expenses_entertainment_php "Entertainment, info, com."

gen expenses_gifts_events_php = expenses_8 + expenses_7
lab var expenses_gifts_events_php "Gifts, transfers, events"

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
gen tondo = (MUN == 138060)

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

* export dataset for use in R (GenericML test)
saveold "$dirwork/panel_household_data_R.dta", version(12) replace

******************************************************************
* check self declared 4Ps against actual status
******************************************************************
merge 1:1 INTNO endline using "$dirwork/household_members_panel.dta"
drop if _merge ==2
drop _merge
/*
br INTNO endline health_subsidy_8 HOUSEHOLD_IDINTERVIEWED-H urban
codebook INTNO if actual_4P_31aug24 == 1 // 1624
corr actual_4P_31aug24 health_subsidy_8 if endline == 1
corr actual_4P_31aug24 health_subsidy_8 if endline == 0

tab actual_4P_31aug24 health_subsidy_8 if endline == 1
tab actual_4P_31aug24 health_subsidy_8 if endline == 0

bysort treatment: tab actual_4P_31aug24 health_subsidy_8 if endline == 1
bysort treatment: tab actual_4P_31aug24 health_subsidy_8 if endline == 0

bysort MUN: tab actual_4P_31aug24 health_subsidy_8 if endline == 1

su hhsize if always_4p == 1 & endline == 1 // 7.213348  (sd 2.452589  )
su hhsize if actual_4P_31aug24 == 1 & endline == 1 // 6.336414   (sd 2.281961)

su hh_income_1_mo if always_4p == 1 & endline == 1 // 19643.78 (sd 183332) N = 2735
su hh_income_1_mo if actual_4P_31aug24 == 1 & endline == 1 // 16960.46 (sd 16687.46) N = 1533
su hh_income_1_mo_pc if always_4p == 1 & endline == 1 // 2782.948 (sd 2424.903 )
su hh_income_1_mo_pc if actual_4P_31aug24 == 1 & endline == 1 // 2769.241 (sd 2710.891)

su enroll_2025 if always_4p == 1 & endline == 1 // .9335405  (sd .1657804)
su enroll_2025 if actual_4P_31aug24 == 1 & endline == 1 // .9478675 (sd .1575728 )

su went_school_may if always_4p == 1 & endline == 1 // .8717491  (sd .2508847 )
su went_school_may if actual_4P_31aug24 == 1 & endline == 1 // .8613612  (sd .2814623)

su child_count_4_17 if always_4p == 1 & endline == 1 // 3.320795 (sd 1.471056)
su child_count_4_17 if actual_4P_31aug24 == 1 & endline == 1 // 3.012315 (sd 1.452843)

su child_count_4_17_meal if always_4p == 1 & endline == 1 // 3.259049 (sd 1.484615)
su child_count_4_17_meal if actual_4P_31aug24 == 1 & endline == 1 // 2.970443 (sd 1.465685)

gen presence_child_4_17 = (child_count_4_17 > 0)
su presence_child_4_17 if always_4p == 1 & endline == 1 // .9829666 (sd .1294186)
su presence_child_4_17 if actual_4P_31aug24 == 1 & endline == 1 // .9618227 (sd .1916832)

su meal_planner_respond if always_4p == 1 & endline == 1 //
su meal_planner_respond if actual_4P_31aug24 == 1 & endline == 1 //

su meal_planner_age if always_4p == 1 & endline == 1 //
su meal_planner_age if actual_4P_31aug24 == 1 & endline == 1 //

replace meal_planner_gender = 0 if meal_planner_gender == 2
su meal_planner_gender if always_4p == 1 & endline == 1 //
su meal_planner_gender if actual_4P_31aug24 == 1 & endline == 1 //

su age_hh_head if always_4p == 1 & endline == 0 //
su age_hh_head if actual_4P_31aug24 == 1 & endline == 0 //

su gender_hh_head if always_4p == 1 & endline == 0 //
su gender_hh_head if actual_4P_31aug24 == 1 & endline == 0 //

su nb_child_0_5 if always_4p == 1 & endline == 0 //
su nb_child_0_5 if actual_4P_31aug24 == 1 & endline == 0 //

su nb_child_5_12 if always_4p == 1 & endline == 0 //
su nb_child_5_12 if actual_4P_31aug24 == 1 & endline == 0 //

su nb_child_12_17 if always_4p == 1 & endline == 0 //
su nb_child_12_17 if actual_4P_31aug24 == 1 & endline == 0 //

su nb_child_0_5 if always_4p == 1 & endline == 1 //
su nb_child_0_5 if actual_4P_31aug24 == 1 & endline == 1 //

su nb_child_12_17 if always_4p == 1 & endline == 1 //
su nb_child_12_17 if actual_4P_31aug24 == 1 & endline == 1 //
*/

{
local vars hhsize hh_income_1_mo hh_income_1_mo_pc meal_planner_responded_panel meal_planner_age meal_planner_gender age_hh_head gender_hh_head nb_child_0_4 nb_child_5_11 nb_child_12_17 enroll_2025_5_11 enroll_2025_12_17
local file_name "charac_4ps"
	local coef_list A B C D
	* summarize
	eststo clear
	eststo A: quietly estpost summarize `vars' if endline == 1 & always_4p == 1
	eststo B: quietly estpost summarize `vars' if endline == 1 & never_4p == 1
	eststo C: quietly estpost summarize `vars' if endline == 1 & actual_4P_31aug24 == 1
	eststo D: quietly estpost summarize `vars' if endline == 1 & actual_4P_31aug24 == 0
	* export table
	esttab `coef_list' using "$diroverleaf/`file_name'.tex", ///
	cells("mean(pattern(1 1 1 1) fmt(2))" "sd(pattern(1 1 1 1) fmt(2))") ///
	label replace mtitle("Always 4Ps" "Never 4Ps" "Official 4Ps" "Official not-4Ps") ///
	starlevels(* 0.1 ** 0.05 *** 0.01) ///
	notes
}

{
local vars hhsize hh_income_1_mo hh_income_1_mo_pc meal_planner_age age_hh_head gender_hh_head nb_child_0_4 nb_child_5_11 nb_child_12_17
local file_name "charac_mealplannergender"
	local coef_list A B
	* summarize
	eststo clear
	eststo A: quietly estpost summarize `vars' if endline == 0 & meal_planner_gender_baseline == 1
	eststo B: quietly estpost summarize `vars' if endline == 0 & meal_planner_gender_baseline == 0
	* export table
	esttab `coef_list' using "$diroverleaf/`file_name'.tex", ///
	cells("mean(pattern(1 1) fmt(2))" "sd(pattern(1 1) fmt(2))") ///
	label replace mtitle("Male mealplanner" "Female mealplanner") ///
	starlevels(* 0.1 ** 0.05 *** 0.01) ///
	notes
}

***********************************************************************************************
** EXPLORE OVERLAP BTW GROUPS (small/large hhh, 4P, better/worse nutri. knowledge, rural/urban)
***********************************************************************************************
/*
* 4Ps at baseline X rural/urban
bysort urban: su baseline_4p if endline ==0 // 71.5% for urban households, 70.8% for rural households
ttest baseline_4p if endline ==0, by(urban)
pwcorr baseline_4p urban if endline ==0, star(0.1)

* 4Ps X household size
ttest hhsize_baseline if endline ==0, by(baseline_4p) // sign. diff -0.62 members (4P hh are bigger), pval = 0
ttest smaller_hhsize if endline ==0, by(baseline_4p) // sign. diff, 4P are more likely to be in the larger household group (by 11 pp)

* 4Ps and baseline nutrition knowledge
ttest quiz_share_correct if endline ==0, by(baseline_4p) // 
ttest higher_quiz_baseline if endline ==0, by(baseline_4p) // 
tab higher_quiz_baseline baseline_4p if endline ==0

* household size and urban/rural
ttest hhsize_baseline if endline ==0, by(urban) // -0.134, pval 8.49%
ttest smaller_hhsize if endline ==0, by(urban) // <1%, pval 76%

* household size and nutrition knowledge
reg quiz_share_correct hhsize_baseline if endline ==0 // + 0.5pp*** (small in magnitude no?)
reg higher_quiz_baseline smaller_hhsize if endline ==0 // -4.8 pp***

* nutrition knowledge and urban/rural 
ttest quiz_share_correct if endline ==0, by(urban)
ttest higher_quiz_baseline if endline ==0, by(urban)

*
ttest quiz_share_correct if endline ==0, by(tondo) // much higher
ttest higher_quiz_baseline if endline ==0, by(tondo)

*/


***************************************************************
** SUBJECTIVE WELL-BEING (endline only)
***************************************************************
{
local vars cantril_ladder self_poverty
local file_name "subjwellbeing_late"
	local coef_list meanc meant csivpooled csivurban csivrural
	* MEANS POOLED
	eststo clear
	eststo meanc: quietly estpost summarize `vars' if treatment == 0 & endline == 1
	eststo meant: quietly estpost summarize `vars' if treatment == 1 & endline == 1
	* CS IV POOLED
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename registered_walang_gutom `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'=treatment) if endline == 1, absorb(i.pair_rank) cluster(clustervar)
		rename `x' registered_walang_gutom
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo csivpooled: appendmodels `reg_list'
	qui count if endline == 0 
	estadd scalar num_obs= `r(N)': csivpooled
	* CS IV URBAN
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename registered_walang_gutom `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'=treatment) if endline == 1 & urban ==1, absorb(i.pair_rank) cluster(clustervar)
		rename `x' registered_walang_gutom
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo csivurban: appendmodels `reg_list'
	qui count if endline == 0 & urban == 1
	estadd scalar num_obs= `r(N)': csivurban
	* CS IV RURAL
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename registered_walang_gutom `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'=treatment) if endline == 1 & urban ==0, absorb(i.pair_rank) cluster(clustervar)
		rename `x' registered_walang_gutom
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo csivrural: appendmodels `reg_list'
	qui count if endline == 0 & urban == 0
	estadd scalar num_obs= `r(N)': csivrural
	* export table
	esttab `coef_list' using "$diroverleaf/`file_name'.tex", ///
	cells("mean(pattern(1 1 0 0 0) fmt(2)) b(star pattern(0 0 1 1 1) fmt(2)) se(pattern(0 0 1 1 1) fmt(2))") ///
	label replace mtitle("Control" "Treatment" "LATE(pooled)" "LATE(urban)" "LATE(rural)") ///
	s(num_obs, fmt(0 ) labels("Nb households" )) ///
	starlevels(* 0.1 ** 0.05 *** 0.01) ///
	notes
}

***************************************************************
** HHSIZE and NB of EATERS (panel)
***************************************************************
{
local vars hhsize total_eats_in_hh
local file_name "hhsize_eaters_late"

	local coef_list MA MB pooled A B
	* MEANS POOLED BASELINE
	eststo clear
	eststo MA: quietly estpost summarize `vars' if endline == 0 & tondo == 1
	eststo MB: quietly estpost summarize `vars' if endline == 0 & tondo == 0
	* panel iv POOLED
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit), absorb(i.INTNO i.endline) cluster(clustervar)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo pooled: appendmodels `reg_list' 
	qui count if endline == 0 
	estadd scalar num_obs= `r(N)': pooled
	* A
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if tondo == 1, absorb(i.INTNO i.endline) cluster(clustervar)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo A: appendmodels `reg_list'
	qui count if endline == 0 & tondo == 1
	estadd scalar num_obs= `r(N)': A
	* B
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if tondo == 0, absorb(i.INTNO i.endline) cluster(clustervar)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo B: appendmodels `reg_list'
	qui count if endline == 0 & tondo == 0
	estadd scalar num_obs= `r(N)': B
	* export table
	esttab `coef_list' using "$diroverleaf/`file_name'.tex", ///
	cells("mean(pattern(1 1 0 0 0) fmt(2)) b(star pattern(0 0 1 1 1) fmt(2)) se(pattern(0 0 1 1 1) fmt(2))") ///
	label replace mtitle("Tondo (baseline)" "Non-Tondo (baseline)" "LATE(pooled)" "LATE(Tondo)" "LATE(Non-Tondo)") ///
	s(num_obs, fmt(0 ) labels("Nb households" )) ///
	starlevels(* 0.1 ** 0.05 *** 0.01) ///
	notes
}


***************************************************************
** FOOD SECURITY and NUTRITION (panel & endline)
***************************************************************
* base, urban/rural, tondo/non tondo
{
local vars any_hunger_3mo hunger_frequent fies_raw fies_fao fcs_score_hh_avg fcs_score_adult_a fcs_score_adult_f fcs_score_adult_m fcs_score_child_3_17_a fcs_score_child_3_17_m fcs_score_child_3_17_f fcs_score_child_3_11_a fcs_score_child_3_11_m fcs_score_child_3_11_f fcs_score_child_12_17_a fcs_score_child_12_17_m fcs_score_child_12_17_f
local file_name "foodsecurity_late"

	local coef_list meanc meant pooled A B C D
	* MEANS POOLED
	eststo clear
	eststo meanc: quietly estpost summarize `vars' if treatment == 0 & endline == 1
	eststo meant: quietly estpost summarize `vars' if treatment == 1 & endline == 1
	* POOLED
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		if inlist("`x'","any_hunger_3mo","hunger_frequent","fies_raw","fies_fao"){
			rename Dit_registered `x'
			eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) , absorb(i.INTNO i.endline) cluster(clustervar)
			rename `x' Dit_registered
			}
			else{
				rename registered_walang_gutom `x'
				eststo reg_`counter': ivreghdfe old_`x' (`x' = treatment) if endline == 1,absorb(i.pair_rank) cluster(clustervar)
				rename `x' registered_walang_gutom
				}
	
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo pooled: appendmodels `reg_list'
	qui count if endline == 0 
	estadd scalar num_obs= `r(N)': pooled
	* URBAN
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		if inlist("`x'","any_hunger_3mo","hunger_frequent","fies_raw","fies_fao"){
			rename Dit_registered `x'
			eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if urban ==1, absorb(i.INTNO i.endline) cluster(clustervar)
			rename `x' Dit_registered
			}
			else{
				rename registered_walang_gutom `x'
				eststo reg_`counter': ivreghdfe old_`x' (`x' = treatment) if endline == 1 & urban ==1,absorb(i.pair_rank) cluster(clustervar)
				rename `x' registered_walang_gutom
				}
	
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo A: appendmodels `reg_list'
	qui count if endline == 0 & urban == 1
	estadd scalar num_obs= `r(N)': A
	* RURAL
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		if inlist("`x'","any_hunger_3mo","hunger_frequent","fies_raw","fies_fao"){
			rename Dit_registered `x'
			eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if urban ==0, absorb(i.INTNO i.endline) cluster(clustervar)
			rename `x' Dit_registered
			}
			else{
				rename registered_walang_gutom `x'
				eststo reg_`counter': ivreghdfe old_`x' (`x' = treatment) if endline == 1 & urban ==0, absorb(i.pair_rank) cluster(clustervar)
				rename `x' registered_walang_gutom
				}
	
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo B: appendmodels `reg_list' 
	qui count if endline == 0 & urban == 0
	estadd scalar num_obs= `r(N)': B
	* TONDO
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		if inlist("`x'","any_hunger_3mo","hunger_frequent","fies_raw","fies_fao"){
			rename Dit_registered `x'
			eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if tondo ==1, absorb(i.INTNO i.endline) cluster(clustervar)
			rename `x' Dit_registered
			}
			else{
				rename registered_walang_gutom `x'
				eststo reg_`counter': ivreghdfe old_`x' (`x' = treatment) if endline == 1 & tondo ==1, absorb(i.pair_rank) cluster(clustervar)
				rename `x' registered_walang_gutom
				}
	
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo C: appendmodels `reg_list' 
	qui count if endline == 0 & tondo == 1
	estadd scalar num_obs= `r(N)': C
		* NOT TONDO
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		if inlist("`x'","any_hunger_3mo","hunger_frequent","fies_raw","fies_fao"){
			rename Dit_registered `x'
			eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if tondo ==0, absorb(i.INTNO i.endline) cluster(clustervar)
			rename `x' Dit_registered
			}
			else{
				rename registered_walang_gutom `x'
				eststo reg_`counter': ivreghdfe old_`x' (`x' = treatment) if endline == 1 & tondo ==0, absorb(i.pair_rank) cluster(clustervar)
				rename `x' registered_walang_gutom
				}
	
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo D: appendmodels `reg_list' 
	qui count if endline == 0 & tondo == 0
	estadd scalar num_obs= `r(N)': D
	* export table
	esttab `coef_list' using "$diroverleaf/`file_name'.tex", ///
	cells("mean(pattern(1 1 0 0 0 0 0) fmt(2)) b(star pattern(0 0 1 1 1 1 1) fmt(2)) se(pattern(0 0 1 1 1 1 1) fmt(2))") ///
	label replace mtitle("Control" "Treatment" "LATE(pooled)" "LATE(urban)" "LATE(rural)" "LATE(tondo)" "LATE(non-tondo)") ///
	s(num_obs, fmt(0 ) labels("Nb households" )) ///
	starlevels(* 0.1 ** 0.05 *** 0.01) ///
	notes
}

* by baseline nutrition knowledge
{
local vars any_hunger_3mo hunger_frequent fies_raw fies_fao fcs_score_hh_avg fcs_score_adult_a fcs_score_adult_f fcs_score_adult_m fcs_score_child_3_17_a fcs_score_child_3_17_m fcs_score_child_3_17_f fcs_score_child_3_11_a fcs_score_child_3_11_m fcs_score_child_3_11_f fcs_score_child_12_17_a fcs_score_child_12_17_m fcs_score_child_12_17_f
local file_name "foodsecurity_late_nutritionknowledge"

	local coef_list meanc meant pooled A B C
	* MEANS POOLED
	eststo clear
	eststo meanc: quietly estpost summarize `vars' if treatment == 0 & endline == 1
	eststo meant: quietly estpost summarize `vars' if treatment == 1 & endline == 1
	* POOLED
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		if inlist("`x'","any_hunger_3mo","hunger_frequent","fies_raw","fies_fao"){
			rename Dit_registered `x'
			eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) , absorb(i.INTNO i.endline) cluster(clustervar)
			rename `x' Dit_registered
			}
			else{
				rename registered_walang_gutom `x'
				eststo reg_`counter': ivreghdfe old_`x' (`x' = treatment) if endline == 1,absorb(i.pair_rank) cluster(clustervar)
				rename `x' registered_walang_gutom
				}
	
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo pooled: appendmodels `reg_list'
	qui count if endline == 0
	estadd scalar num_obs= `r(N)': pooled
	*
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		if inlist("`x'","any_hunger_3mo","hunger_frequent","fies_raw","fies_fao"){
			rename Dit_registered `x'
			eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if higher_quiz_baseline == 1, absorb(i.INTNO i.endline) cluster(clustervar)
			rename `x' Dit_registered
			}
			else{
				rename registered_walang_gutom `x'
				eststo reg_`counter': ivreghdfe old_`x' (`x' = treatment) if endline == 1 & higher_quiz_baseline == 1,absorb(i.pair_rank) cluster(clustervar)
				rename `x' registered_walang_gutom
				}
	
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo A: appendmodels `reg_list'
	qui count if endline == 0 & higher_quiz_baseline == 1
	estadd scalar num_obs= `r(N)': A
	*
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		if inlist("`x'","any_hunger_3mo","hunger_frequent","fies_raw","fies_fao"){
			rename Dit_registered `x'
			eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if higher_quiz_baseline == 0, absorb(i.INTNO i.endline) cluster(clustervar)
			rename `x' Dit_registered
			}
			else{
				rename registered_walang_gutom `x'
				eststo reg_`counter': ivreghdfe old_`x' (`x' = treatment) if endline == 1 & higher_quiz_baseline == 0, absorb(i.pair_rank) cluster(clustervar)
				rename `x' registered_walang_gutom
				}
	
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo B: appendmodels `reg_list' 
	qui count if endline == 0 & higher_quiz_baseline == 0
	estadd scalar num_obs= `r(N)': B
	*
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		if inlist("`x'","any_hunger_3mo","hunger_frequent","fies_raw","fies_fao"){
			rename Dit_registered `x'
			eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if higherQ75_quiz_baseline == 1, absorb(i.INTNO i.endline) cluster(clustervar)
			rename `x' Dit_registered
			}
			else{
				rename registered_walang_gutom `x'
				eststo reg_`counter': ivreghdfe old_`x' (`x' = treatment) if endline == 1 & higherQ75_quiz_baseline == 1,absorb(i.pair_rank) cluster(clustervar)
				rename `x' registered_walang_gutom
				}
	
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo C: appendmodels `reg_list' 
	qui count if endline == 0 & higherQ75_quiz_baseline == 1
	estadd scalar num_obs= `r(N)': C

	* export table
	esttab `coef_list' using "$diroverleaf/`file_name'.tex", ///
	cells("mean(pattern(1 1 0 0 0 0) fmt(2)) b(star pattern(0 0 1 1 1 1) fmt(2)) se(pattern(0 0 1 1 1 1) fmt(2))") ///
	label replace mtitle("Control" "Treatment" "LATE(pooled)" "LATE(higher)" "LATE(lower)" "LATE(top quarter)") ///
	s(num_obs, fmt(0 ) labels("Nb households" )) ///
	starlevels(* 0.1 ** 0.05 *** 0.01) ///
	notes
}

* by baseline household size
{
local vars any_hunger_3mo hunger_frequent fies_raw fies_fao fcs_score_hh_avg fcs_score_adult_a fcs_score_adult_f fcs_score_adult_m fcs_score_child_3_17_a fcs_score_child_3_17_m fcs_score_child_3_17_f fcs_score_child_3_11_a fcs_score_child_3_11_m fcs_score_child_3_11_f fcs_score_child_12_17_a fcs_score_child_12_17_m fcs_score_child_12_17_f
local file_name "foodsecurity_late_hhsize"

	local coef_list meanc meant pooled A B
	* MEANS POOLED
	eststo clear
	eststo meanc: quietly estpost summarize `vars' if treatment == 0 & endline == 1
	eststo meant: quietly estpost summarize `vars' if treatment == 1 & endline == 1
	* POOLED
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		if inlist("`x'","any_hunger_3mo","hunger_frequent","fies_raw","fies_fao"){
			rename Dit_registered `x'
			eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) , absorb(i.INTNO i.endline) cluster(clustervar)
			rename `x' Dit_registered
			}
			else{
				rename registered_walang_gutom `x'
				eststo reg_`counter': ivreghdfe old_`x' (`x' = treatment) if endline == 1,absorb(i.pair_rank) cluster(clustervar)
				rename `x' registered_walang_gutom
				}
	
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo pooled: appendmodels `reg_list' 
	qui count if endline == 0 
	estadd scalar num_obs= `r(N)': pooled
	*
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		if inlist("`x'","any_hunger_3mo","hunger_frequent","fies_raw","fies_fao"){
			rename Dit_registered `x'
			eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if smaller_hhsize == 0, absorb(i.INTNO i.endline) cluster(clustervar)
			rename `x' Dit_registered
			}
			else{
				rename registered_walang_gutom `x'
				eststo reg_`counter': ivreghdfe old_`x' (`x' = treatment) if endline == 1 & smaller_hhsize == 0,absorb(i.pair_rank) cluster(clustervar)
				rename `x' registered_walang_gutom
				}
	
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo A: appendmodels `reg_list' 
	qui count if endline == 0 & smaller_hhsize == 0
	estadd scalar num_obs= `r(N)': A
	*
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		if inlist("`x'","any_hunger_3mo","hunger_frequent","fies_raw","fies_fao"){
			rename Dit_registered `x'
			eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if smaller_hhsize == 1, absorb(i.INTNO i.endline) cluster(clustervar)
			rename `x' Dit_registered
			}
			else{
				rename registered_walang_gutom `x'
				eststo reg_`counter': ivreghdfe old_`x' (`x' = treatment) if endline == 1 & smaller_hhsize == 1, absorb(i.pair_rank) cluster(clustervar)
				rename `x' registered_walang_gutom
				}
	
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo B: appendmodels `reg_list' 
	qui count if endline == 0 & smaller_hhsize == 1
	estadd scalar num_obs= `r(N)': B
	* export table
	esttab `coef_list' using "$diroverleaf/`file_name'.tex", ///
	cells("mean(pattern(1 1 0 0 0) fmt(2)) b(star pattern(0 0 1 1 1) fmt(2)) se(pattern(0 0 1 1 1) fmt(2))") ///
	label replace mtitle("Control" "Treatment" "LATE(pooled)" "LATE(higher)" "LATE(lower)") ///
	s(num_obs, fmt(0 ) labels("Nb households" )) ///
	starlevels(* 0.1 ** 0.05 *** 0.01) ///
	notes
}

* by baseline household size, dropping hh with large baseline/endline diff in hhsize (> 3 persons)
{
local vars any_hunger_3mo hunger_frequent fies_raw fies_fao fcs_score_hh_avg fcs_score_adult_a fcs_score_adult_f fcs_score_adult_m fcs_score_child_3_17_a fcs_score_child_3_17_m fcs_score_child_3_17_f fcs_score_child_3_11_a fcs_score_child_3_11_m fcs_score_child_3_11_f fcs_score_child_12_17_a fcs_score_child_12_17_m fcs_score_child_12_17_f
local file_name "foodsecurity_late_hhsize_littlechange"

	local coef_list meanc meant pooled A B
	* MEANS POOLED
	eststo clear
	eststo meanc: quietly estpost summarize `vars' if treatment == 0 & endline == 1 & hhsize_little_change ==1
	eststo meant: quietly estpost summarize `vars' if treatment == 1 & endline == 1 & hhsize_little_change ==1
	* POOLED
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		if inlist("`x'","any_hunger_3mo","hunger_frequent","fies_raw","fies_fao"){
			rename Dit_registered `x'
			eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if hhsize_little_change ==1 , absorb(i.INTNO i.endline) cluster(clustervar)
			rename `x' Dit_registered
			}
			else{
				rename registered_walang_gutom `x'
				eststo reg_`counter': ivreghdfe old_`x' (`x' = treatment) if endline == 1 & hhsize_little_change ==1,absorb(i.pair_rank) cluster(clustervar)
				rename `x' registered_walang_gutom
				}
	
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo pooled: appendmodels `reg_list' 
	qui count if endline == 0 & hhsize_little_change == 1
	estadd scalar num_obs= `r(N)': pooled
	*
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		if inlist("`x'","any_hunger_3mo","hunger_frequent","fies_raw","fies_fao"){
			rename Dit_registered `x'
			eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if smaller_hhsize == 0 & hhsize_little_change ==1, absorb(i.INTNO i.endline) cluster(clustervar)
			rename `x' Dit_registered
			}
			else{
				rename registered_walang_gutom `x'
				eststo reg_`counter': ivreghdfe old_`x' (`x' = treatment) if endline == 1 & smaller_hhsize == 0 & hhsize_little_change ==1, absorb(i.pair_rank) cluster(clustervar)
				rename `x' registered_walang_gutom
				}
	
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo A: appendmodels `reg_list'
	qui count if endline == 0 & hhsize_little_change == 1 & smaller_hhsize == 0
	estadd scalar num_obs= `r(N)': A
	*
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		if inlist("`x'","any_hunger_3mo","hunger_frequent","fies_raw","fies_fao"){
			rename Dit_registered `x'
			eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if smaller_hhsize == 1 & hhsize_little_change ==1, absorb(i.INTNO i.endline) cluster(clustervar)
			rename `x' Dit_registered
			}
			else{
				rename registered_walang_gutom `x'
				eststo reg_`counter': ivreghdfe old_`x' (`x' = treatment) if endline == 1 & smaller_hhsize == 1 & hhsize_little_change ==1, absorb(i.pair_rank) cluster(clustervar)
				rename `x' registered_walang_gutom
				}
	
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo B: appendmodels `reg_list' 
	qui count if endline == 0 & hhsize_little_change == 1 & smaller_hhsize == 1
	estadd scalar num_obs= `r(N)': B
	* export table
	esttab `coef_list' using "$diroverleaf/`file_name'.tex", ///
	cells("mean(pattern(1 1 0 0 0) fmt(2)) b(star pattern(0 0 1 1 1) fmt(2)) se(pattern(0 0 1 1 1) fmt(2))") ///
	label replace mtitle("Control" "Treatment" "LATE(pooled)" "LATE(higher)" "LATE(lower)") ///
	s(num_obs, fmt(0 ) labels("Nb households" )) ///
	starlevels(* 0.1 ** 0.05 *** 0.01) ///
	notes
}

* by baseline 4P status
{
local vars any_hunger_3mo hunger_frequent fies_raw fies_fao fcs_score_hh_avg fcs_score_adult_a fcs_score_adult_f fcs_score_adult_m fcs_score_child_3_17_a fcs_score_child_3_17_m fcs_score_child_3_17_f fcs_score_child_3_11_a fcs_score_child_3_11_m fcs_score_child_3_11_f fcs_score_child_12_17_a fcs_score_child_12_17_m fcs_score_child_12_17_f
local file_name "foodsecurity_late_4p"

	local coef_list meanc meant pooled A B
	* MEANS POOLED
	eststo clear
	eststo meanc: quietly estpost summarize `vars' if treatment == 0 & endline == 1
	eststo meant: quietly estpost summarize `vars' if treatment == 1 & endline == 1
	* POOLED
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		if inlist("`x'","any_hunger_3mo","hunger_frequent","fies_raw","fies_fao"){
			rename Dit_registered `x'
			eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) , absorb(i.INTNO i.endline) cluster(clustervar)
			rename `x' Dit_registered
			}
			else{
				rename registered_walang_gutom `x'
				eststo reg_`counter': ivreghdfe old_`x' (`x' = treatment) if endline == 1,absorb(i.pair_rank) cluster(clustervar)
				rename `x' registered_walang_gutom
				}
	
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo pooled: appendmodels `reg_list' 
	qui count if endline == 0
	estadd scalar num_obs= `r(N)': pooled
	*
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		if inlist("`x'","any_hunger_3mo","hunger_frequent","fies_raw","fies_fao"){
			rename Dit_registered `x'
			eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if baseline_4p == 1, absorb(i.INTNO i.endline) cluster(clustervar)
			rename `x' Dit_registered
			}
			else{
				rename registered_walang_gutom `x'
				eststo reg_`counter': ivreghdfe old_`x' (`x' = treatment) if endline == 1 & baseline_4p == 1,absorb(i.pair_rank) cluster(clustervar)
				rename `x' registered_walang_gutom
				}
	
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo A: appendmodels `reg_list' 
	qui count if endline == 0 & baseline_4p == 1
	estadd scalar num_obs= `r(N)': A
	*
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		if inlist("`x'","any_hunger_3mo","hunger_frequent","fies_raw","fies_fao"){
			rename Dit_registered `x'
			eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if baseline_4p == 0, absorb(i.INTNO i.endline) cluster(clustervar)
			rename `x' Dit_registered
			}
			else{
				rename registered_walang_gutom `x'
				eststo reg_`counter': ivreghdfe old_`x' (`x' = treatment) if endline == 1 & baseline_4p == 0, absorb(i.pair_rank) cluster(clustervar)
				rename `x' registered_walang_gutom
				}
	
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo B: appendmodels `reg_list' 
	qui count if endline == 0 & baseline_4p == 0
	estadd scalar num_obs= `r(N)': B
	* export table
	esttab `coef_list' using "$diroverleaf/`file_name'.tex", ///
	cells("mean(pattern(1 1 0 0 0) fmt(2)) b(star pattern(0 0 1 1 1) fmt(2)) se(pattern(0 0 1 1 1) fmt(2))") ///
	label replace mtitle("Control" "Treatment" "LATE(pooled)" "LATE(4Ps)" "LATE(non-4Ps)") ///
	s(num_obs, fmt(0 ) labels("Nb households" )) ///
	starlevels(* 0.1 ** 0.05 *** 0.01) ///
	notes
}

* by official 4P status
{
local vars any_hunger_3mo hunger_frequent fies_raw fies_fao fcs_score_hh_avg fcs_score_adult_a fcs_score_adult_f fcs_score_adult_m fcs_score_child_3_17_a fcs_score_child_3_17_m fcs_score_child_3_17_f fcs_score_child_3_11_a fcs_score_child_3_11_m fcs_score_child_3_11_f fcs_score_child_12_17_a fcs_score_child_12_17_m fcs_score_child_12_17_f
local file_name "foodsecurity_late_off4p"

	local coef_list meanc meant pooled A B
	* MEANS POOLED
	eststo clear
	eststo meanc: quietly estpost summarize `vars' if treatment == 0 & endline == 1
	eststo meant: quietly estpost summarize `vars' if treatment == 1 & endline == 1
	* POOLED
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		if inlist("`x'","any_hunger_3mo","hunger_frequent","fies_raw","fies_fao"){
			rename Dit_registered `x'
			eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) , absorb(i.INTNO i.endline) cluster(clustervar)
			rename `x' Dit_registered
			}
			else{
				rename registered_walang_gutom `x'
				eststo reg_`counter': ivreghdfe old_`x' (`x' = treatment) if endline == 1,absorb(i.pair_rank) cluster(clustervar)
				rename `x' registered_walang_gutom
				}
	
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo pooled: appendmodels `reg_list' 
	qui count if endline == 0
	estadd scalar num_obs= `r(N)': pooled
	*
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		if inlist("`x'","any_hunger_3mo","hunger_frequent","fies_raw","fies_fao"){
			rename Dit_registered `x'
			eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if actual_4P_31aug24 == 1, absorb(i.INTNO i.endline) cluster(clustervar)
			rename `x' Dit_registered
			}
			else{
				rename registered_walang_gutom `x'
				eststo reg_`counter': ivreghdfe old_`x' (`x' = treatment) if endline == 1 & actual_4P_31aug24 == 1,absorb(i.pair_rank) cluster(clustervar)
				rename `x' registered_walang_gutom
				}
	
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo A: appendmodels `reg_list' 
	qui count if endline == 0 & actual_4P_31aug24 == 1
	estadd scalar num_obs= `r(N)': A
	*
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		if inlist("`x'","any_hunger_3mo","hunger_frequent","fies_raw","fies_fao"){
			rename Dit_registered `x'
			eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if actual_4P_31aug24 == 0, absorb(i.INTNO i.endline) cluster(clustervar)
			rename `x' Dit_registered
			}
			else{
				rename registered_walang_gutom `x'
				eststo reg_`counter': ivreghdfe old_`x' (`x' = treatment) if endline == 1 & actual_4P_31aug24 == 0, absorb(i.pair_rank) cluster(clustervar)
				rename `x' registered_walang_gutom
				}
	
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo B: appendmodels `reg_list' 
	qui count if endline == 0 & actual_4P_31aug24 == 0
	estadd scalar num_obs= `r(N)': B
	* export table
	esttab `coef_list' using "$diroverleaf/`file_name'.tex", ///
	cells("mean(pattern(1 1 0 0 0) fmt(2)) b(star pattern(0 0 1 1 1) fmt(2)) se(pattern(0 0 1 1 1) fmt(2))") ///
	label replace mtitle("Control" "Treatment" "LATE(pooled)" "LATE(4Ps)" "LATE(non-4Ps)") ///
	s(num_obs, fmt(0 ) labels("Nb households" )) ///
	starlevels(* 0.1 ** 0.05 *** 0.01) ///
	notes
}

* by always 4P status (vs never 4p)
{
local vars any_hunger_3mo hunger_frequent fies_raw fies_fao fcs_score_hh_avg fcs_score_adult_a fcs_score_adult_f fcs_score_adult_m fcs_score_child_3_17_a fcs_score_child_3_17_m fcs_score_child_3_17_f fcs_score_child_3_11_a fcs_score_child_3_11_m fcs_score_child_3_11_f fcs_score_child_12_17_a fcs_score_child_12_17_m fcs_score_child_12_17_f
local file_name "foodsecurity_late_always4p"

	local coef_list meanc meant pooled A B
	* MEANS POOLED
	eststo clear
	eststo meanc: quietly estpost summarize `vars' if treatment == 0 & endline == 1
	eststo meant: quietly estpost summarize `vars' if treatment == 1 & endline == 1
	* POOLED
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		if inlist("`x'","any_hunger_3mo","hunger_frequent","fies_raw","fies_fao"){
			rename Dit_registered `x'
			eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) , absorb(i.INTNO i.endline) cluster(clustervar)
			rename `x' Dit_registered
			}
			else{
				rename registered_walang_gutom `x'
				eststo reg_`counter': ivreghdfe old_`x' (`x' = treatment) if endline == 1,absorb(i.pair_rank) cluster(clustervar)
				rename `x' registered_walang_gutom
				}
	
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo pooled: appendmodels `reg_list'
	qui count if endline == 0
	estadd scalar num_obs= `r(N)': pooled
	*
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		if inlist("`x'","any_hunger_3mo","hunger_frequent","fies_raw","fies_fao"){
			rename Dit_registered `x'
			eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if always_4p == 1, absorb(i.INTNO i.endline) cluster(clustervar)
			rename `x' Dit_registered
			}
			else{
				rename registered_walang_gutom `x'
				eststo reg_`counter': ivreghdfe old_`x' (`x' = treatment) if endline == 1 & always_4p == 1,absorb(i.pair_rank) cluster(clustervar)
				rename `x' registered_walang_gutom
				}
	
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo A: appendmodels `reg_list' 
	qui count if endline == 0 & always_4p == 1
	estadd scalar num_obs= `r(N)': A
	*
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		if inlist("`x'","any_hunger_3mo","hunger_frequent","fies_raw","fies_fao"){
			rename Dit_registered `x'
			eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if never_4p == 1, absorb(i.INTNO i.endline) cluster(clustervar)
			rename `x' Dit_registered
			}
			else{
				rename registered_walang_gutom `x'
				eststo reg_`counter': ivreghdfe old_`x' (`x' = treatment) if endline == 1 & never_4p == 1, absorb(i.pair_rank) cluster(clustervar)
				rename `x' registered_walang_gutom
				}
	
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo B: appendmodels `reg_list' 
	qui count if endline == 0 & never_4p == 1
	estadd scalar num_obs= `r(N)': B
	* export table
	esttab `coef_list' using "$diroverleaf/`file_name'.tex", ///
	cells("mean(pattern(1 1 0 0 0) fmt(2)) b(star pattern(0 0 1 1 1) fmt(2)) se(pattern(0 0 1 1 1) fmt(2))") ///
	label replace mtitle("Control" "Treatment" "LATE(pooled)" "LATE(4Ps)" "LATE(non-4Ps)") ///
	s(num_obs, fmt(0 ) labels("Nb households" )) ///
	starlevels(* 0.1 ** 0.05 *** 0.01) ///
	notes
}

* by always 4P status X nutrition knowledge X tondo
{
local vars any_hunger_3mo hunger_frequent fies_raw fies_fao fcs_score_hh_avg fcs_score_adult_a fcs_score_adult_f fcs_score_adult_m fcs_score_child_3_17_a fcs_score_child_3_17_m fcs_score_child_3_17_f fcs_score_child_3_11_a fcs_score_child_3_11_m fcs_score_child_3_11_f fcs_score_child_12_17_a fcs_score_child_12_17_m fcs_score_child_12_17_f
local file_name "foodsecurity_late_always4p_nutriknowledge_tondo"

	local coef_list A B C D E

	* 4Ps
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		if inlist("`x'","any_hunger_3mo","hunger_frequent","fies_raw","fies_fao"){
			rename Dit_registered `x'
			eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if always_4p == 1, absorb(i.INTNO i.endline) cluster(clustervar)
			rename `x' Dit_registered
			}
			else{
				rename registered_walang_gutom `x'
				eststo reg_`counter': ivreghdfe old_`x' (`x' = treatment) if endline == 1 & always_4p == 1,absorb(i.pair_rank) cluster(clustervar)
				rename `x' registered_walang_gutom
				}
	
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo A: appendmodels `reg_list' 
	qui count if endline == 0 & always_4p == 1
	estadd scalar num_obs= `r(N)': A
	
	* higher nutri knowledge
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		if inlist("`x'","any_hunger_3mo","hunger_frequent","fies_raw","fies_fao"){
			rename Dit_registered `x'
			eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if higher_quiz_baseline == 1, absorb(i.INTNO i.endline) cluster(clustervar)
			rename `x' Dit_registered
			}
			else{
				rename registered_walang_gutom `x'
				eststo reg_`counter': ivreghdfe old_`x' (`x' = treatment) if endline == 1 & higher_quiz_baseline == 1,absorb(i.pair_rank) cluster(clustervar)
				rename `x' registered_walang_gutom
				}
	
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo B: appendmodels `reg_list'
	qui count if endline == 0 & higher_quiz_baseline == 1
	estadd scalar num_obs= `r(N)': B

	* tondo
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		if inlist("`x'","any_hunger_3mo","hunger_frequent","fies_raw","fies_fao"){
			rename Dit_registered `x'
			eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if tondo == 1, absorb(i.INTNO i.endline) cluster(clustervar)
			rename `x' Dit_registered
			}
			else{
				rename registered_walang_gutom `x'
				eststo reg_`counter': ivreghdfe old_`x' (`x' = treatment) if endline == 1 & tondo == 1,absorb(i.pair_rank) cluster(clustervar)
				rename `x' registered_walang_gutom
				}
	
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo C: appendmodels `reg_list'
	qui count if endline == 0 & tondo == 1
	estadd scalar num_obs= `r(N)': C
	
	* 4Ps and higher nutri knowledge
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		if inlist("`x'","any_hunger_3mo","hunger_frequent","fies_raw","fies_fao"){
			rename Dit_registered `x'
			eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if always_4p == 1 & higher_quiz_baseline == 1, absorb(i.INTNO i.endline) cluster(clustervar)
			rename `x' Dit_registered
			}
			else{
				rename registered_walang_gutom `x'
				eststo reg_`counter': ivreghdfe old_`x' (`x' = treatment) if endline == 1 & always_4p == 1 & higher_quiz_baseline == 1, absorb(i.pair_rank) cluster(clustervar)
				rename `x' registered_walang_gutom
				}
	
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo D: appendmodels `reg_list' 
	qui count if endline == 0 & always_4p == 1 & higher_quiz_baseline == 1
	estadd scalar num_obs= `r(N)': D
	
	* 4Ps and higher nutri knowledge and tondo
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		if inlist("`x'","any_hunger_3mo","hunger_frequent","fies_raw","fies_fao"){
			rename Dit_registered `x'
			eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if always_4p == 1 & higher_quiz_baseline == 1 & tondo == 1, absorb(i.INTNO i.endline) cluster(clustervar)
			rename `x' Dit_registered
			}
			else{
				rename registered_walang_gutom `x'
				eststo reg_`counter': ivreghdfe old_`x' (`x' = treatment) if endline == 1 & always_4p == 1 & higher_quiz_baseline == 1 & tondo == 1, absorb(i.pair_rank) cluster(clustervar)
				rename `x' registered_walang_gutom
				}
	
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo E: appendmodels `reg_list' 
	qui count if endline == 0 & always_4p == 1 & higher_quiz_baseline == 1 & tondo == 1
	estadd scalar num_obs= `r(N)': E

	* export table
	esttab `coef_list' using "$diroverleaf/`file_name'.tex", ///
	cells("mean(pattern(0 0 0 0 0) fmt(2)) b(star pattern(1 1 1 1 1) fmt(2)) se(pattern(1 1 1 1 1) fmt(2))") ///
	label replace mtitle("LATE(4Ps)" "LATE(Higher NK)" "LATE(Tondo)" "LATE(4Ps+Higher NK)" "LATE(4Ps+Higher NK+Tondo)") ///
	s(num_obs, fmt(0 ) labels("Nb households" )) ///
	starlevels(* 0.1 ** 0.05 *** 0.01) ///
	notes
}

* by km to fixed vendor outside tondo
{
local vars any_hunger_3mo hunger_frequent fies_raw fies_fao fcs_score_hh_avg fcs_score_adult_a fcs_score_adult_f fcs_score_adult_m fcs_score_child_3_17_a fcs_score_child_3_17_m fcs_score_child_3_17_f fcs_score_child_3_11_a fcs_score_child_3_11_m fcs_score_child_3_11_f fcs_score_child_12_17_a fcs_score_child_12_17_m fcs_score_child_12_17_f
local file_name "foodsecurity_late_kmvendor"

	local coef_list meanc meant pooled A B C
	* MEANS POOLED
	eststo clear
	eststo meanc: quietly estpost summarize `vars' if treatment == 0 & endline == 1 & tondo ==0
	eststo meant: quietly estpost summarize `vars' if treatment == 1 & endline == 1 & tondo ==0
	* POOLED
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		if inlist("`x'","any_hunger_3mo","hunger_frequent","fies_raw","fies_fao"){
			rename Dit_registered `x'
			eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if tondo ==0 , absorb(i.INTNO i.endline) cluster(clustervar)
			rename `x' Dit_registered
			}
			else{
				rename registered_walang_gutom `x'
				eststo reg_`counter': ivreghdfe old_`x' (`x' = treatment) if endline == 1 & tondo ==0, absorb(i.pair_rank) cluster(clustervar)
				rename `x' registered_walang_gutom
				}
	
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo pooled: appendmodels `reg_list'
	qui count if endline == 0 & tondo ==0
	estadd scalar num_obs= `r(N)': pooled
	*
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		if inlist("`x'","any_hunger_3mo","hunger_frequent","fies_raw","fies_fao"){
			rename Dit_registered `x'
			eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if km_to_fixed_vendor_cat == "<= 1.5 km" & tondo ==0, absorb(i.INTNO i.endline) cluster(clustervar)
			rename `x' Dit_registered
			}
			else{
				rename registered_walang_gutom `x'
				eststo reg_`counter': ivreghdfe old_`x' (`x' = treatment) if endline == 1 &  km_to_fixed_vendor_cat == "<= 1.5 km" & tondo ==0,absorb(i.pair_rank) cluster(clustervar)
				rename `x' registered_walang_gutom
				}
	
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo A: appendmodels `reg_list'
	qui count if endline == 0 & km_to_fixed_vendor_cat == "<= 1.5 km" & tondo ==0
	estadd scalar num_obs= `r(N)': A
	*
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		if inlist("`x'","any_hunger_3mo","hunger_frequent","fies_raw","fies_fao"){
			rename Dit_registered `x'
			eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if km_to_fixed_vendor_cat == "> 1.5 km and <= 5 km" & tondo ==0, absorb(i.INTNO i.endline) cluster(clustervar)
			rename `x' Dit_registered
			}
			else{
				rename registered_walang_gutom `x'
				eststo reg_`counter': ivreghdfe old_`x' (`x' = treatment) if endline == 1 & km_to_fixed_vendor_cat == "> 1.5 km and <= 5 km" & tondo ==0, absorb(i.pair_rank) cluster(clustervar)
				rename `x' registered_walang_gutom
				}
	
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo B: appendmodels `reg_list' 
	qui count if endline == 0 & km_to_fixed_vendor_cat == "> 1.5 km and <= 5 km" & tondo ==0
	estadd scalar num_obs= `r(N)': B
	*
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		if inlist("`x'","any_hunger_3mo","hunger_frequent","fies_raw","fies_fao"){
			rename Dit_registered `x'
			eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if km_to_fixed_vendor_cat == "> 5 km" & tondo ==0, absorb(i.INTNO i.endline) cluster(clustervar)
			rename `x' Dit_registered
			}
			else{
				rename registered_walang_gutom `x'
				eststo reg_`counter': ivreghdfe old_`x' (`x' = treatment) if endline == 1 & km_to_fixed_vendor_cat == "> 5 km" & tondo ==0, absorb(i.pair_rank) cluster(clustervar)
				rename `x' registered_walang_gutom
				}
	
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo C: appendmodels `reg_list' 
	qui count if endline == 0 & km_to_fixed_vendor_cat == "> 5 km" & tondo ==0
	estadd scalar num_obs= `r(N)': C

	* export table
	esttab `coef_list' using "$diroverleaf/`file_name'.tex", ///
	cells("mean(pattern(1 1 0 0 0 0) fmt(2)) b(star pattern(0 0 1 1 1 1) fmt(2)) se(pattern(0 0 1 1 1 1) fmt(2))") ///
	label replace mtitle("Control" "Treatment" "LATE(pooled)" "LATE(0 to 1.5km)" "LATE(1.5 to 5km)" "LATE(above 5km)") ///
	s(num_obs, fmt(0 ) labels("Nb households" )) ///
	starlevels(* 0.1 ** 0.05 *** 0.01) ///
	notes
}

* any hunger at baseline X tondo/not tondo
{
local vars any_hunger_3mo hunger_frequent fies_raw fies_fao fcs_score_hh_avg fcs_score_adult_a fcs_score_adult_f fcs_score_adult_m fcs_score_child_3_17_a fcs_score_child_3_17_m fcs_score_child_3_17_f fcs_score_child_3_11_a fcs_score_child_3_11_m fcs_score_child_3_11_f fcs_score_child_12_17_a fcs_score_child_12_17_m fcs_score_child_12_17_f
local file_name "foodsecurity_late_hunger_tondo"

	local coef_list meanc meant pooled A B C D
	* MEANS POOLED
	eststo clear
	eststo meanc: quietly estpost summarize `vars' if treatment == 0 & endline == 1
	eststo meant: quietly estpost summarize `vars' if treatment == 1 & endline == 1
	* POOLED
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		if inlist("`x'","any_hunger_3mo","hunger_frequent","fies_raw","fies_fao"){
			rename Dit_registered `x'
			eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) , absorb(i.INTNO i.endline) cluster(clustervar)
			rename `x' Dit_registered
			}
			else{
				rename registered_walang_gutom `x'
				eststo reg_`counter': ivreghdfe old_`x' (`x' = treatment) if endline == 1,absorb(i.pair_rank) cluster(clustervar)
				rename `x' registered_walang_gutom
				}
	
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo pooled: appendmodels `reg_list'
	qui count if endline == 0 
	estadd scalar num_obs= `r(N)': pooled
	* A
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		if inlist("`x'","any_hunger_3mo","hunger_frequent","fies_raw","fies_fao"){
			rename Dit_registered `x'
			eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if any_hunger_3mo_baseline == 0 & tondo ==0, absorb(i.INTNO i.endline) cluster(clustervar)
			rename `x' Dit_registered
			}
			else{
				rename registered_walang_gutom `x'
				eststo reg_`counter': ivreghdfe old_`x' (`x' = treatment) if endline == 1 & any_hunger_3mo_baseline == 0 & tondo ==0,absorb(i.pair_rank) cluster(clustervar)
				rename `x' registered_walang_gutom
				}
	
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo A: appendmodels `reg_list'
	qui count if endline == 0 & any_hunger_3mo_baseline == 0 & tondo ==0
	estadd scalar num_obs= `r(N)': A
	* B
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		if inlist("`x'","any_hunger_3mo","hunger_frequent","fies_raw","fies_fao"){
			rename Dit_registered `x'
			eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if any_hunger_3mo_baseline == 1 & tondo ==0, absorb(i.INTNO i.endline) cluster(clustervar)
			rename `x' Dit_registered
			}
			else{
				rename registered_walang_gutom `x'
				eststo reg_`counter': ivreghdfe old_`x' (`x' = treatment) if endline == 1 & any_hunger_3mo_baseline == 1 & tondo ==0, absorb(i.pair_rank) cluster(clustervar)
				rename `x' registered_walang_gutom
				}
	
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo B: appendmodels `reg_list' 
	qui count if endline == 0 & any_hunger_3mo_baseline == 1 & tondo ==0
	estadd scalar num_obs= `r(N)': B
	* C
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		if inlist("`x'","any_hunger_3mo","hunger_frequent","fies_raw","fies_fao"){
			rename Dit_registered `x'
			eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if any_hunger_3mo_baseline == 0 & tondo ==1, absorb(i.INTNO i.endline) cluster(clustervar)
			rename `x' Dit_registered
			}
			else{
				rename registered_walang_gutom `x'
				eststo reg_`counter': ivreghdfe old_`x' (`x' = treatment) if endline == 1 & any_hunger_3mo_baseline == 0 & tondo ==1, absorb(i.pair_rank) cluster(clustervar)
				rename `x' registered_walang_gutom
				}
	
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo C: appendmodels `reg_list' 
	qui count if endline == 0 & any_hunger_3mo_baseline == 0 & tondo ==1
	estadd scalar num_obs= `r(N)': C
	* D
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		if inlist("`x'","any_hunger_3mo","hunger_frequent","fies_raw","fies_fao"){
			rename Dit_registered `x'
			eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if any_hunger_3mo_baseline == 1 & tondo ==1, absorb(i.INTNO i.endline) cluster(clustervar)
			rename `x' Dit_registered
			}
			else{
				rename registered_walang_gutom `x'
				eststo reg_`counter': ivreghdfe old_`x' (`x' = treatment) if endline == 1 & any_hunger_3mo_baseline == 1 & tondo ==1, absorb(i.pair_rank) cluster(clustervar)
				rename `x' registered_walang_gutom
				}
	
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo D: appendmodels `reg_list' 
	qui count if endline == 0 & any_hunger_3mo_baseline == 1 & tondo ==1
	estadd scalar num_obs= `r(N)': D
	* export table
	esttab `coef_list' using "$diroverleaf/`file_name'.tex", ///
	cells("mean(pattern(1 1 0 0 0 0 0) fmt(2)) b(star pattern(0 0 1 1 1 1 1) fmt(2)) se(pattern(0 0 1 1 1 1 1) fmt(2))") ///
	label replace mtitle("Control" "Treatment" "LATE(pooled)" "LATE(No Hunger/Not Tondo)" "LATE(Hunger/Not Tondo)" "LATE(No Hunger/Tondo)" "LATE(Hunger/Tondo)") ///
	s(num_obs, fmt(0 ) labels("Nb households" )) ///
	starlevels(* 0.1 ** 0.05 *** 0.01) ///
	notes
}

* by own food production at baseline outside Tondo
{
local vars any_hunger_3mo hunger_frequent fies_raw fies_fao fcs_score_hh_avg fcs_score_adult_a fcs_score_adult_f fcs_score_adult_m fcs_score_child_3_17_a fcs_score_child_3_17_m fcs_score_child_3_17_f fcs_score_child_3_11_a fcs_score_child_3_11_m fcs_score_child_3_11_f fcs_score_child_12_17_a fcs_score_child_12_17_m fcs_score_child_12_17_f
local file_name "foodsecurity_late_ownfoodprod"

	local coef_list meanc meant pooled A B
	* MEANS POOLED
	eststo clear
	eststo meanc: quietly estpost summarize `vars' if treatment == 0 & endline == 1 & tondo ==0
	eststo meant: quietly estpost summarize `vars' if treatment == 1 & endline == 1 & tondo ==0
	* POOLED
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		if inlist("`x'","any_hunger_3mo","hunger_frequent","fies_raw","fies_fao"){
			rename Dit_registered `x'
			eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if tondo ==0, absorb(i.INTNO i.endline) cluster(clustervar)
			rename `x' Dit_registered
			}
			else{
				rename registered_walang_gutom `x'
				eststo reg_`counter': ivreghdfe old_`x' (`x' = treatment) if endline == 1 & tondo ==0, absorb(i.pair_rank) cluster(clustervar)
				rename `x' registered_walang_gutom
				}
	
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo pooled: appendmodels `reg_list' 
	qui count if endline == 0 & tondo ==0
	estadd scalar num_obs= `r(N)': pooled
	* A
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		if inlist("`x'","any_hunger_3mo","hunger_frequent","fies_raw","fies_fao"){
			rename Dit_registered `x'
			eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if enterprise_ownfood_baseline == 1 & tondo ==0, absorb(i.INTNO i.endline) cluster(clustervar)
			rename `x' Dit_registered
			}
			else{
				rename registered_walang_gutom `x'
				eststo reg_`counter': ivreghdfe old_`x' (`x' = treatment) if endline == 1 & enterprise_ownfood_baseline == 1 & tondo ==0, absorb(i.pair_rank) cluster(clustervar)
				rename `x' registered_walang_gutom
				}
	
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo A: appendmodels `reg_list' 
	qui count if endline == 0 & enterprise_ownfood_baseline == 1 & tondo ==0
	estadd scalar num_obs= `r(N)': A
	* B
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		if inlist("`x'","any_hunger_3mo","hunger_frequent","fies_raw","fies_fao"){
			rename Dit_registered `x'
			eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if enterprise_ownfood_baseline == 0 & tondo ==0, absorb(i.INTNO i.endline) cluster(clustervar)
			rename `x' Dit_registered
			}
			else{
				rename registered_walang_gutom `x'
				eststo reg_`counter': ivreghdfe old_`x' (`x' = treatment) if endline == 1 & enterprise_ownfood_baseline == 0 & tondo ==0, absorb(i.pair_rank) cluster(clustervar)
				rename `x' registered_walang_gutom
				}
	
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo B: appendmodels `reg_list' 
	qui count if endline == 0 & enterprise_ownfood_baseline == 0 & tondo ==0
	estadd scalar num_obs= `r(N)': B
	* export table
	esttab `coef_list' using "$diroverleaf/`file_name'.tex", ///
	cells("mean(pattern(1 1 0 0 0) fmt(2)) b(star pattern(0 0 1 1 1) fmt(2)) se(pattern(0 0 1 1 1) fmt(2))") ///
	label replace mtitle("Control" "Treatment" "LATE(pooled)" "LATE(Prod. own food)" "LATE(No prod. own food)") ///
	s(num_obs, fmt(0 ) labels("Nb households" )) ///
	starlevels(* 0.1 ** 0.05 *** 0.01) ///
	notes
}


***************************************************************
** FOOD ACQUISITION (panel)
***************************************************************
* urban/rural / tondo/not tondo
{
local vars total2_food_1mo_php total2_food_1mo_php_pc total2_food_1mo_php_ln total2_food_1mo_php_ln_pc spend_1 spend_2 spend_3 spend_4 spend_5 spend_6 spend_7 spend_8 spend_9 spend_10 spend_11
local file_name "foodacquisition_late"

	local coef_list meanc meant pooled A B C D
	* MEANS POOLED
	eststo clear
	eststo meanc: quietly estpost summarize `vars' if treatment == 0 & endline == 1
	eststo meant: quietly estpost summarize `vars' if treatment == 1 & endline == 1
	* panel iv POOLED
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit), absorb(i.INTNO i.endline) cluster(clustervar)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo pooled: appendmodels `reg_list' 
	qui count if endline == 0 
	estadd scalar num_obs= `r(N)': pooled
	* panel iv URBAN
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if urban == 1, absorb(i.INTNO i.endline) cluster(clustervar)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo A: appendmodels `reg_list'
	qui count if endline == 0 & urban == 1
	estadd scalar num_obs= `r(N)': A
	* panel iv RURAL
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if urban == 0, absorb(i.INTNO i.endline) cluster(clustervar)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo B: appendmodels `reg_list' 
	qui count if endline == 0 & urban == 0
	estadd scalar num_obs= `r(N)': B
	* panel iv TONDO
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if tondo == 1, absorb(i.INTNO i.endline) cluster(clustervar)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo C: appendmodels `reg_list'
	qui count if endline == 0 & tondo == 1
	estadd scalar num_obs= `r(N)': C
	* panel iv NOT TONDO
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if tondo == 0, absorb(i.INTNO i.endline) cluster(clustervar)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo D: appendmodels `reg_list'
	qui count if endline == 0 & tondo == 0
	estadd scalar num_obs= `r(N)': D
	* export table
	esttab `coef_list' using "$diroverleaf/`file_name'.tex", ///
	cells("mean(pattern(1 1 0 0 0 0 0) fmt(2)) b(star pattern(0 0 1 1 1 1 1) fmt(2)) se(pattern(0 0 1 1 1 1 1) fmt(2))") ///
	label replace mtitle("Control" "Treatment" "LATE(pooled)" "LATE(urban)" "LATE(rural)" "LATE(tondo)" "LATE(non-tondo)") ///
	s(num_obs, fmt(0 ) labels("Nb households" )) ///
	starlevels(* 0.1 ** 0.05 *** 0.01) ///
	notes
}

* by baseline nutrition knowledge
{
local vars total2_food_1mo_php total2_food_1mo_php_pc total2_food_1mo_php_ln total2_food_1mo_php_ln_pc spend_1 spend_2 spend_3 spend_4 spend_5 spend_6 spend_7 spend_8 spend_9 spend_10 spend_11
local file_name "foodacquisition_late_nutritionknowledge"

	local coef_list meanc meant pooled A B C
	* MEANS POOLED
	eststo clear
	eststo meanc: quietly estpost summarize `vars' if treatment == 0 & endline == 1
	eststo meant: quietly estpost summarize `vars' if treatment == 1 & endline == 1
	* panel iv POOLED
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit), absorb(i.INTNO i.endline) cluster(clustervar)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo pooled: appendmodels `reg_list'
	qui count if endline == 0 
	estadd scalar num_obs= `r(N)': pooled
	* panel iv HIGHER
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if higher_quiz_baseline == 1, absorb(i.INTNO i.endline) cluster(clustervar)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo A: appendmodels `reg_list'
	qui count if endline == 0 & higher_quiz_baseline == 1
	estadd scalar num_obs= `r(N)': A
	* panel iv LOWER
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if higher_quiz_baseline == 0, absorb(i.INTNO i.endline) cluster(clustervar)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo B: appendmodels `reg_list' 
	qui count if endline == 0 & higher_quiz_baseline == 0
	estadd scalar num_obs= `r(N)': B
	*
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if higherQ75_quiz_baseline == 1, absorb(i.INTNO i.endline) cluster(clustervar)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo C: appendmodels `reg_list' 
	qui count if endline == 0 & higherQ75_quiz_baseline == 1
	estadd scalar num_obs= `r(N)': C
	* export table
	esttab `coef_list' using "$diroverleaf/`file_name'.tex", ///
	cells("mean(pattern(1 1 0 0 0 0) fmt(2)) b(star pattern(0 0 1 1 1 1) fmt(2)) se(pattern(0 0 1 1 1 1) fmt(2))") ///
	label replace mtitle("Control" "Treatment" "LATE(pooled)" "LATE(higher)" "LATE(lower)" "LATE(top quarter)") ///
	s(num_obs, fmt(0 ) labels("Nb households" )) ///
	starlevels(* 0.1 ** 0.05 *** 0.01) ///
	notes
}

* by baseline household size
{
local vars total2_food_1mo_php total2_food_1mo_php_pc total2_food_1mo_php_ln total2_food_1mo_php_ln_pc spend_1 spend_2 spend_3 spend_4 spend_5 spend_6 spend_7 spend_8 spend_9 spend_10 spend_11
local file_name "foodacquisition_late_hhsize"

	local coef_list meanc meant xtivpooled xtivhigher xtivlower
	* MEANS POOLED
	eststo clear
	eststo meanc: quietly estpost summarize `vars' if treatment == 0 & endline == 1
	eststo meant: quietly estpost summarize `vars' if treatment == 1 & endline == 1
	* panel iv POOLED
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit), absorb(i.INTNO i.endline) cluster(clustervar)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo xtivpooled: appendmodels `reg_list' 
	qui count if endline == 0
	estadd scalar num_obs= `r(N)': xtivpooled
	* panel iv HIGHER
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if smaller_hhsize == 0, absorb(i.INTNO i.endline) cluster(clustervar)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo xtivhigher: appendmodels `reg_list'
	qui count if endline == 0 & smaller_hhsize == 0
	estadd scalar num_obs= `r(N)': xtivhigher
	* panel iv LOWER
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if smaller_hhsize == 1, absorb(i.INTNO i.endline) cluster(clustervar)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo xtivlower: appendmodels `reg_list' 
	qui count if endline == 0 & smaller_hhsize == 1
	estadd scalar num_obs= `r(N)': xtivlower
	* export table
	esttab `coef_list' using "$diroverleaf/`file_name'.tex", ///
	cells("mean(pattern(1 1 0 0 0) fmt(2)) b(star pattern(0 0 1 1 1) fmt(2)) se(pattern(0 0 1 1 1) fmt(2))") ///
	label replace mtitle("Control" "Treatment" "LATE(pooled)" "LATE(higher)" "LATE(lower)") ///
	s(num_obs, fmt(0 ) labels("Nb households" )) ///
	starlevels(* 0.1 ** 0.05 *** 0.01) ///
	notes
}

* by baseline 4P status
{
local vars total2_food_1mo_php total2_food_1mo_php_pc total2_food_1mo_php_ln total2_food_1mo_php_ln_pc spend_1 spend_2 spend_3 spend_4 spend_5 spend_6 spend_7 spend_8 spend_9 spend_10 spend_11
local file_name "foodacquisition_late_4p"

	local coef_list meanc meant xtivpooled xtiv4p xtivnon4p
	* MEANS POOLED
	eststo clear
	eststo meanc: quietly estpost summarize `vars' if treatment == 0 & endline == 1
	eststo meant: quietly estpost summarize `vars' if treatment == 1 & endline == 1
	* panel iv POOLED
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit), absorb(i.INTNO i.endline) cluster(clustervar)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo xtivpooled: appendmodels `reg_list' 
	qui count if endline == 0
	estadd scalar num_obs= `r(N)': xtivpooled
	* panel iv 4P
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if baseline_4p == 1, absorb(i.INTNO i.endline) cluster(clustervar)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo xtiv4p: appendmodels `reg_list'
	qui count if endline == 0 & baseline_4p == 1
	estadd scalar num_obs= `r(N)': xtiv4p
	* panel iv NON 4P
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if baseline_4p == 0, absorb(i.INTNO i.endline) cluster(clustervar)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo xtivnon4p: appendmodels `reg_list' 
		qui count if endline == 0 & baseline_4p == 0
	estadd scalar num_obs= `r(N)': xtivnon4p
	* export table
	esttab `coef_list' using "$diroverleaf/`file_name'.tex", ///
	cells("mean(pattern(1 1 0 0 0) fmt(2)) b(star pattern(0 0 1 1 1) fmt(2)) se(pattern(0 0 1 1 1) fmt(2))") ///
	label replace mtitle("Control" "Treatment" "LATE(pooled)" "LATE(4P)" "LATE(non-4P)") ///
	s(num_obs, fmt(0 ) labels("Nb households" )) ///
	starlevels(* 0.1 ** 0.05 *** 0.01) ///
	notes
}

* by official 4P status
{
local vars total2_food_1mo_php total2_food_1mo_php_pc total2_food_1mo_php_ln total2_food_1mo_php_ln_pc spend_1 spend_2 spend_3 spend_4 spend_5 spend_6 spend_7 spend_8 spend_9 spend_10 spend_11
local file_name "foodacquisition_late_off4p"

	local coef_list meanc meant xtivpooled xtiv4p xtivnon4p
	* MEANS POOLED
	eststo clear
	eststo meanc: quietly estpost summarize `vars' if treatment == 0 & endline == 1
	eststo meant: quietly estpost summarize `vars' if treatment == 1 & endline == 1
	* panel iv POOLED
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit), absorb(i.INTNO i.endline) cluster(clustervar)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo xtivpooled: appendmodels `reg_list' 
	qui count if endline == 0
	estadd scalar num_obs= `r(N)': xtivpooled
	* panel iv 4P
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if actual_4P_31aug24 == 1, absorb(i.INTNO i.endline) cluster(clustervar)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo xtiv4p: appendmodels `reg_list'
	qui count if endline == 0 & actual_4P_31aug24 == 1
	estadd scalar num_obs= `r(N)': xtiv4p
	* panel iv NON 4P
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if actual_4P_31aug24 == 0, absorb(i.INTNO i.endline) cluster(clustervar)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo xtivnon4p: appendmodels `reg_list' 
	qui count if endline == 0 & actual_4P_31aug24 == 0
	estadd scalar num_obs= `r(N)': xtivnon4p
	* export table
	esttab `coef_list' using "$diroverleaf/`file_name'.tex", ///
	cells("mean(pattern(1 1 0 0 0) fmt(2)) b(star pattern(0 0 1 1 1) fmt(2)) se(pattern(0 0 1 1 1) fmt(2))") ///
	label replace mtitle("Control" "Treatment" "LATE(pooled)" "LATE(4P)" "LATE(non-4P)") ///
	s(num_obs, fmt(0 ) labels("Nb households" )) ///
	starlevels(* 0.1 ** 0.05 *** 0.01) ///
	notes
}

* by always 4P status (vs never 4p)
{
local vars total2_food_1mo_php total2_food_1mo_php_pc total2_food_1mo_php_ln total2_food_1mo_php_ln_pc spend_1 spend_2 spend_3 spend_4 spend_5 spend_6 spend_7 spend_8 spend_9 spend_10 spend_11
local file_name "foodacquisition_late_always4p"

	local coef_list meanc meant xtivpooled xtiv4p xtivnon4p
	* MEANS POOLED
	eststo clear
	eststo meanc: quietly estpost summarize `vars' if treatment == 0 & endline == 1
	eststo meant: quietly estpost summarize `vars' if treatment == 1 & endline == 1
	* panel iv POOLED
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit), absorb(i.INTNO i.endline) cluster(clustervar)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo xtivpooled: appendmodels `reg_list' 
	qui count if endline == 0
	estadd scalar num_obs= `r(N)': xtivpooled
	* panel iv 4P
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if always_4p == 1, absorb(i.INTNO i.endline) cluster(clustervar)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo xtiv4p: appendmodels `reg_list'
	qui count if endline == 0 & always_4p == 1
	estadd scalar num_obs= `r(N)': xtiv4p
	* panel iv NON 4P
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if never_4p == 1, absorb(i.INTNO i.endline) cluster(clustervar)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo xtivnon4p: appendmodels `reg_list' 
	qui count if endline == 0 & never_4p == 1
	estadd scalar num_obs= `r(N)': xtivnon4p
	* export table
	esttab `coef_list' using "$diroverleaf/`file_name'.tex", ///
	cells("mean(pattern(1 1 0 0 0) fmt(2)) b(star pattern(0 0 1 1 1) fmt(2)) se(pattern(0 0 1 1 1) fmt(2))") ///
	label replace mtitle("Control" "Treatment" "LATE(pooled)" "LATE(4P)" "LATE(non-4P)") ///
	s(num_obs, fmt(0 ) labels("Nb households" )) ///
	starlevels(* 0.1 ** 0.05 *** 0.01) ///
	notes
}

* always 4P status X nutrition knowledge
{
local vars total2_food_1mo_php total2_food_1mo_php_pc total2_food_1mo_php_ln total2_food_1mo_php_ln_pc spend_1 spend_2 spend_3 spend_4 spend_5 spend_6 spend_7 spend_8 spend_9 spend_10 spend_11
local file_name "foodacquisition_late_always4p_nutriknowledge_tondo"

	local coef_list A B C D E
	
	* panel iv 4P
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if always_4p == 1, absorb(i.INTNO i.endline) cluster(clustervar)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo A: appendmodels `reg_list' 
	qui count if endline == 0 & always_4p == 1
	estadd scalar num_obs= `r(N)': A
	
	* panel iv high baseline nutri knowledge
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if higher_quiz_baseline == 1, absorb(i.INTNO i.endline) cluster(clustervar)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo B: appendmodels `reg_list' 
	qui count if endline == 0 & higher_quiz_baseline == 1
	estadd scalar num_obs= `r(N)': B
	
	* panel iv tondo
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if tondo == 1, absorb(i.INTNO i.endline) cluster(clustervar)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo C: appendmodels `reg_list' 
	qui count if endline == 0 & tondo == 1
	estadd scalar num_obs= `r(N)': C
	
	* panel iv 4P and high nutri knowledge
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if always_4p == 1 & higher_quiz_baseline == 1, absorb(i.INTNO i.endline) cluster(clustervar)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo D: appendmodels `reg_list' 
	qui count if endline == 0 & always_4p == 1 & higher_quiz_baseline == 1
	estadd scalar num_obs= `r(N)': D
	
	* panel iv 4P and high nutri knowledge and tondo
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if always_4p == 1 & higher_quiz_baseline == 1 & tondo == 1, absorb(i.INTNO i.endline) cluster(clustervar)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo E: appendmodels `reg_list' 
	qui count if endline == 0 & always_4p == 1 & higher_quiz_baseline == 1 & tondo == 1
	estadd scalar num_obs= `r(N)': E
	
	* export table
	esttab `coef_list' using "$diroverleaf/`file_name'.tex", ///
	cells("mean(pattern(0 0 0 0 0) fmt(2)) b(star pattern(1 1 1 1 1) fmt(2)) se(pattern(1 1 1 1 1) fmt(2))") ///
	label replace mtitle("LATE(4Ps)" "LATE(High NK)" "LATE(Tondo)" "LATE(4Ps+High NK)" "LATE(4Ps+High NK+Tondo)") ///
	s(num_obs, fmt(0 ) labels("Nb households" )) ///
	starlevels(* 0.1 ** 0.05 *** 0.01) ///
	notes
}

* by km to fixed vendor
{
local vars total2_food_1mo_php total2_food_1mo_php_pc total2_food_1mo_php_ln total2_food_1mo_php_ln_pc spend_1 spend_2 spend_3 spend_4 spend_5 spend_6 spend_7 spend_8 spend_9 spend_10 spend_11
local file_name "foodacquisition_late_kmvendor"

	local coef_list meanc meant pooled A B C
	* MEANS POOLED
	eststo clear
	eststo meanc: quietly estpost summarize `vars' if treatment == 0 & endline == 1 & tondo ==0
	eststo meant: quietly estpost summarize `vars' if treatment == 1 & endline == 1 & tondo ==0
	* panel iv POOLED
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if tondo ==0, absorb(i.INTNO i.endline) cluster(clustervar)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo pooled: appendmodels `reg_list'
	qui count if endline == 0 & tondo ==0
	estadd scalar num_obs= `r(N)': pooled
	* A 
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if km_to_fixed_vendor_cat == "<= 1.5 km" & tondo ==0, absorb(i.INTNO i.endline) cluster(clustervar)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo A: appendmodels `reg_list'
	qui count if endline == 0 & km_to_fixed_vendor_cat == "<= 1.5 km" & tondo ==0
	estadd scalar num_obs= `r(N)': A
	* B
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if km_to_fixed_vendor_cat == "> 1.5 km and <= 5 km" & tondo ==0, absorb(i.INTNO i.endline) cluster(clustervar)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo B: appendmodels `reg_list' 
	qui count if endline == 0 & km_to_fixed_vendor_cat == "> 1.5 km and <= 5 km" & tondo ==0
	estadd scalar num_obs= `r(N)': B
	* C
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if km_to_fixed_vendor_cat == "> 5 km" & tondo ==0, absorb(i.INTNO i.endline) cluster(clustervar)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo C: appendmodels `reg_list' 
	qui count if endline == 0 & km_to_fixed_vendor_cat == "> 5 km" & tondo ==0
	estadd scalar num_obs= `r(N)': C
	* export table
	esttab `coef_list' using "$diroverleaf/`file_name'.tex", ///
	cells("mean(pattern(1 1 0 0 0 0) fmt(2)) b(star pattern(0 0 1 1 1 1) fmt(2)) se(pattern(0 0 1 1 1 1) fmt(2))") ///
	label replace mtitle("Control" "Treatment" "LATE(pooled)" "LATE(0 to 1.5km)" "LATE(1.5 to 5km)" "LATE(above 5km)") ///
	s(num_obs, fmt(0 ) labels("Nb households" )) ///
	starlevels(* 0.1 ** 0.05 *** 0.01) ///
	notes
}

* by own food production
{
local vars total2_food_1mo_php total2_food_1mo_php_pc total2_food_1mo_php_ln total2_food_1mo_php_ln_pc spend_1 spend_2 spend_3 spend_4 spend_5 spend_6 spend_7 spend_8 spend_9 spend_10 spend_11
local file_name "foodacquisition_late_ownfoodprod"

	local coef_list meanc meant pooled A B
	* MEANS POOLED
	eststo clear
	eststo meanc: quietly estpost summarize `vars' if treatment == 0 & endline == 1 & tondo ==0
	eststo meant: quietly estpost summarize `vars' if treatment == 1 & endline == 1 & tondo ==0
	* panel iv POOLED
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if tondo ==0, absorb(i.INTNO i.endline) cluster(clustervar)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo pooled: appendmodels `reg_list' 
	qui count if endline == 0 & tondo ==0
	estadd scalar num_obs= `r(N)': pooled
	* A
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if enterprise_ownfood_baseline == 1 & tondo ==0, absorb(i.INTNO i.endline) cluster(clustervar)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo A: appendmodels `reg_list'
	qui count if endline == 0 & enterprise_ownfood_baseline == 1 & tondo ==0
	estadd scalar num_obs= `r(N)': A
	* B
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if enterprise_ownfood_baseline == 0 & tondo ==0, absorb(i.INTNO i.endline) cluster(clustervar)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo B: appendmodels `reg_list' 
		qui count if endline == 0 & enterprise_ownfood_baseline == 0 & tondo ==0
	estadd scalar num_obs= `r(N)': B
	* export table
	esttab `coef_list' using "$diroverleaf/`file_name'.tex", ///
	cells("mean(pattern(1 1 0 0 0) fmt(2)) b(star pattern(0 0 1 1 1) fmt(2)) se(pattern(0 0 1 1 1) fmt(2))") ///
	label replace mtitle("Control" "Treatment" "LATE(pooled)" "LATE(Prod. own food)" "LATE(No prod. own food)") ///
	s(num_obs, fmt(0 ) labels("Nb households" )) ///
	starlevels(* 0.1 ** 0.05 *** 0.01) ///
	notes
}

* any hunger at baseline X tondo/not tondo
{
local vars total2_food_1mo_php total2_food_1mo_php_pc total2_food_1mo_php_ln total2_food_1mo_php_ln_pc spend_1 spend_2 spend_3 spend_4 spend_5 spend_6 spend_7 spend_8 spend_9 spend_10 spend_11
local file_name "foodacquisition_late_hunger_tondo"

	local coef_list meanc meant pooled A B C D
	* MEANS POOLED
	eststo clear
	eststo meanc: quietly estpost summarize `vars' if treatment == 0 & endline == 1
	eststo meant: quietly estpost summarize `vars' if treatment == 1 & endline == 1
	* panel iv POOLED
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit), absorb(i.INTNO i.endline) cluster(clustervar)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo pooled: appendmodels `reg_list' 
	qui count if endline == 0 
	estadd scalar num_obs= `r(N)': pooled
	* A
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if tondo == 0 & any_hunger_3mo_baseline == 0, absorb(i.INTNO i.endline) cluster(clustervar)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo A: appendmodels `reg_list'
	qui count if endline == 0 & tondo == 0 & any_hunger_3mo_baseline == 0
	estadd scalar num_obs= `r(N)': A
	* B
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if tondo == 0 & any_hunger_3mo_baseline == 1, absorb(i.INTNO i.endline) cluster(clustervar)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo B: appendmodels `reg_list' 
	qui count if endline == 0 & tondo == 0 & any_hunger_3mo_baseline == 1
	estadd scalar num_obs= `r(N)': B
	* C
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if tondo == 1 & any_hunger_3mo_baseline == 0, absorb(i.INTNO i.endline) cluster(clustervar)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo C: appendmodels `reg_list'
	qui count if endline == 0 & tondo == 1 & any_hunger_3mo_baseline == 0
	estadd scalar num_obs= `r(N)': C
	* D
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if tondo == 1 & any_hunger_3mo_baseline == 1, absorb(i.INTNO i.endline) cluster(clustervar)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo D: appendmodels `reg_list'
	qui count if endline == 0 & tondo == 1 & any_hunger_3mo_baseline == 1
	estadd scalar num_obs= `r(N)': D
	* export table
	esttab `coef_list' using "$diroverleaf/`file_name'.tex", ///
	cells("mean(pattern(1 1 0 0 0 0 0) fmt(2)) b(star pattern(0 0 1 1 1 1 1) fmt(2)) se(pattern(0 0 1 1 1 1 1) fmt(2))") ///
	label replace mtitle("Control" "Treatment" "LATE(pooled)" "LATE(No hunger/Not Tondo)" "LATE(Hunger/Not Tondo)" "LATE(No Hunger/Tondo)" "LATE(Hunger/Tondo)") ///
	s(num_obs, fmt(0 ) labels("Nb households" )) ///
	starlevels(* 0.1 ** 0.05 *** 0.01) ///
	notes
}



***************************************************************
** NON-FOOD EXPENDITURES (panel)
***************************************************************
* urban/rural, tondo/not tondo
{
local vars expenses_1 expenses_2 expenses_rent_utilities_php expenses_6  expenses_gifts_events_php expenses_entertainment_php expenses_10 expenses_vicegoods_php expenses_13 tot_non_food_expenses tot_non_food_expenses_ln tot_non_food_expenses_pc tot_non_food_expenses_pc_ln
local file_name "nonfoodexpenditures_late"

	local coef_list meanc meant pooled A B C D
	* MEANS POOLED
	eststo clear
	eststo meanc: quietly estpost summarize `vars' if treatment == 0 & endline == 1
	eststo meant: quietly estpost summarize `vars' if treatment == 1 & endline == 1
	* panel iv POOLED
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit), absorb(i.INTNO i.endline) cluster(clustervar)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo pooled: appendmodels `reg_list' 
	qui count if endline == 0
	estadd scalar num_obs= `r(N)': pooled
	
	* panel iv URBAN
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if urban == 1, absorb(i.INTNO i.endline) cluster(clustervar)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo A: appendmodels `reg_list'
	qui count if endline == 0 & urban == 1
	estadd scalar num_obs= `r(N)': A
	
	* panel iv RURAL
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if urban == 0, absorb(i.INTNO i.endline) cluster(clustervar)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo B: appendmodels `reg_list' 
	qui count if endline == 0 & urban == 0
	estadd scalar num_obs= `r(N)': B
	
	* panel iv TONDO
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if tondo == 1, absorb(i.INTNO i.endline) cluster(clustervar)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo C: appendmodels `reg_list'
	qui count if endline == 0 & tondo == 1
	estadd scalar num_obs= `r(N)': C
	
	* panel iv NOT TONDO
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if tondo == 0, absorb(i.INTNO i.endline) cluster(clustervar)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo D: appendmodels `reg_list'
	qui count if endline == 0 & tondo == 0
	estadd scalar num_obs= `r(N)': D
	
	* export table
	esttab `coef_list' using "$diroverleaf/`file_name'.tex", ///
	cells("mean(pattern(1 1 0 0 0 0 0) fmt(2)) b(star pattern(0 0 1 1 1 1 1) fmt(2)) se(pattern(0 0 1 1 1 1 1) fmt(2))") ///
	label replace mtitle("Control" "Treatment" "LATE(pooled)" "LATE(urban)" "LATE(rural)" "LATE(tondo)" "LATE(non-tondo)") ///
	s(num_obs, fmt(0 ) labels("Nb households" )) ///
	starlevels(* 0.1 ** 0.05 *** 0.01) ///
	notes
}

* by baseline household size
{
local vars expenses_1 expenses_2 expenses_rent_utilities_php expenses_6  expenses_gifts_events_php expenses_entertainment_php expenses_10 expenses_vicegoods_php expenses_13 tot_non_food_expenses tot_non_food_expenses_ln tot_non_food_expenses_pc tot_non_food_expenses_pc_ln
local file_name "nonfoodexpenditures_late_hhsize"

	local coef_list meanc meant xtivpooled xtivhigher xtivlower
	* MEANS POOLED
	eststo clear
	eststo meanc: quietly estpost summarize `vars' if treatment == 0 & endline == 1
	eststo meant: quietly estpost summarize `vars' if treatment == 1 & endline == 1
	* panel iv POOLED
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit), absorb(i.INTNO i.endline) cluster(clustervar)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo xtivpooled: appendmodels `reg_list' 
	qui count if endline == 0
	estadd scalar num_obs= `r(N)': xtivpooled
	
	* panel iv HIGHER
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if smaller_hhsize == 0, absorb(i.INTNO i.endline) cluster(clustervar)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo xtivhigher: appendmodels `reg_list'
	qui count if endline == 0 & smaller_hhsize == 0
	estadd scalar num_obs= `r(N)': xtivhigher
	
	* panel iv LOWER
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if smaller_hhsize == 1, absorb(i.INTNO i.endline) cluster(clustervar)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo xtivlower: appendmodels `reg_list' 
	qui count if endline == 0 & smaller_hhsize == 1
	estadd scalar num_obs= `r(N)': xtivlower
	
	* export table
	esttab `coef_list' using "$diroverleaf/`file_name'.tex", ///
	cells("mean(pattern(1 1 0 0 0) fmt(2)) b(star pattern(0 0 1 1 1) fmt(2)) se(pattern(0 0 1 1 1) fmt(2))") ///
	label replace mtitle("Control" "Treatment" "LATE(pooled)" "LATE(higher)" "LATE(lower)") ///
	s(num_obs, fmt(0 ) labels("Nb households" )) ///
	starlevels(* 0.1 ** 0.05 *** 0.01) ///
	notes
}

* clustering at pair level
{
local vars expenses_1 expenses_2 expenses_rent_utilities_php expenses_6  expenses_gifts_events_php expenses_entertainment_php expenses_10 expenses_vicegoods_php expenses_13 tot_non_food_expenses tot_non_food_expenses_ln tot_non_food_expenses_pc tot_non_food_expenses_pc_ln
local file_name "nonfoodexpenditures_late_clustpair"

	local coef_list meanc meant xtivpooled xtivurban xtivrural
	* MEANS POOLED
	eststo clear
	eststo meanc: quietly estpost summarize `vars' if treatment == 0 & endline == 1
	eststo meant: quietly estpost summarize `vars' if treatment == 1 & endline == 1
	* panel iv POOLED
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit), absorb(i.INTNO i.endline) cluster(pair_rank)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo xtivpooled: appendmodels `reg_list' 
	* panel iv URBAN
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if urban == 1, absorb(i.INTNO i.endline) cluster(pair_rank)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo xtivurban: appendmodels `reg_list'
	* panel iv RURAL
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if urban == 0, absorb(i.INTNO i.endline) cluster(pair_rank)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo xtivrural: appendmodels `reg_list' 
	* export table
	esttab `coef_list' using "$diroverleaf/`file_name'.tex", ///
	cells("mean(pattern(1 1 0 0 0) fmt(2)) b(star pattern(0 0 1 1 1) fmt(2)) se(pattern(0 0 1 1 1) fmt(2))") ///
	label replace mtitle("Control" "Treatment" "LATE(pooled)" "LATE(urban)" "LATE(rural)") ///
	s(num_obs, fmt(0 ) labels("Nb households" )) ///
	starlevels(* 0.1 ** 0.05 *** 0.01) ///
	notes
}

* by always 4P status (vs never 4p)
{
local vars expenses_1 expenses_2 expenses_rent_utilities_php expenses_6  expenses_gifts_events_php expenses_entertainment_php expenses_10 expenses_vicegoods_php expenses_13 tot_non_food_expenses tot_non_food_expenses_ln tot_non_food_expenses_pc tot_non_food_expenses_pc_ln
local file_name "nonfoodexpenditures_late_always4p"

	local coef_list meanc meant xtivpooled xtiv4p xtivnon4p
	* MEANS POOLED
	eststo clear
	eststo meanc: quietly estpost summarize `vars' if treatment == 0 & endline == 1
	eststo meant: quietly estpost summarize `vars' if treatment == 1 & endline == 1
	* panel iv POOLED
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit), absorb(i.INTNO i.endline) cluster(clustervar)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo xtivpooled: appendmodels `reg_list' 
	qui count if endline == 0
	estadd scalar num_obs= `r(N)': xtivpooled
	
	* panel iv 4P
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if always_4p == 1, absorb(i.INTNO i.endline) cluster(clustervar)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo xtiv4p: appendmodels `reg_list'
	qui count if endline == 0 & always_4p == 1
	estadd scalar num_obs= `r(N)': xtiv4p
	
	* panel iv NON 4P
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if never_4p == 1, absorb(i.INTNO i.endline) cluster(clustervar)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo xtivnon4p: appendmodels `reg_list' 
	qui count if endline == 0 & never_4p == 1
	estadd scalar num_obs= `r(N)': xtivnon4p
	
	* export table
	esttab `coef_list' using "$diroverleaf/`file_name'.tex", ///
	cells("mean(pattern(1 1 0 0 0) fmt(2)) b(star pattern(0 0 1 1 1) fmt(2)) se(pattern(0 0 1 1 1) fmt(2))") ///
	label replace mtitle("Control" "Treatment" "LATE(pooled)" "LATE(4P)" "LATE(non-4P)") ///
	s(num_obs, fmt(0 ) labels("Nb households" )) ///
	starlevels(* 0.1 ** 0.05 *** 0.01) ///
	notes
}

* by official 4P status
{
local vars expenses_1 expenses_2 expenses_rent_utilities_php expenses_6  expenses_gifts_events_php expenses_entertainment_php expenses_10 expenses_vicegoods_php expenses_13 tot_non_food_expenses tot_non_food_expenses_ln tot_non_food_expenses_pc tot_non_food_expenses_pc_ln
local file_name "nonfoodexpenditures_late_off4p"

	local coef_list meanc meant xtivpooled xtiv4p xtivnon4p
	* MEANS POOLED
	eststo clear
	eststo meanc: quietly estpost summarize `vars' if treatment == 0 & endline == 1
	eststo meant: quietly estpost summarize `vars' if treatment == 1 & endline == 1
	* panel iv POOLED
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit), absorb(i.INTNO i.endline) cluster(clustervar)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo xtivpooled: appendmodels `reg_list' 
	qui count if endline == 0
	estadd scalar num_obs= `r(N)': xtivpooled
	
	* panel iv 4P
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if actual_4P_31aug24 == 1, absorb(i.INTNO i.endline) cluster(clustervar)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo xtiv4p: appendmodels `reg_list'
	qui count if endline == 0 & actual_4P_31aug24 == 1
	estadd scalar num_obs= `r(N)': xtiv4p
	
	* panel iv NON 4P
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if actual_4P_31aug24 == 0, absorb(i.INTNO i.endline) cluster(clustervar)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo xtivnon4p: appendmodels `reg_list'
	qui count if endline == 0 & actual_4P_31aug24 == 0
	estadd scalar num_obs= `r(N)': xtivnon4p
	
	* export table
	esttab `coef_list' using "$diroverleaf/`file_name'.tex", ///
	cells("mean(pattern(1 1 0 0 0) fmt(2)) b(star pattern(0 0 1 1 1) fmt(2)) se(pattern(0 0 1 1 1) fmt(2))") ///
	label replace mtitle("Control" "Treatment" "LATE(pooled)" "LATE(4P)" "LATE(non-4P)") ///
	s(num_obs, fmt(0 ) labels("Nb households" )) ///
	starlevels(* 0.1 ** 0.05 *** 0.01) ///
	notes
}

* by km to fixed vendor
{
local vars expenses_1 expenses_2 expenses_rent_utilities_php expenses_6  expenses_gifts_events_php expenses_entertainment_php expenses_10 expenses_vicegoods_php expenses_13 tot_non_food_expenses tot_non_food_expenses_ln tot_non_food_expenses_pc tot_non_food_expenses_pc_ln
local file_name "nonfoodexpenditures_late_kmvendor"

	local coef_list meanc meant pooled A B C
	* MEANS POOLED
	eststo clear
	eststo meanc: quietly estpost summarize `vars' if treatment == 0 & endline == 1 & tondo ==0
	eststo meant: quietly estpost summarize `vars' if treatment == 1 & endline == 1 & tondo ==0
	* panel iv POOLED
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if tondo ==0, absorb(i.INTNO i.endline) cluster(clustervar)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo pooled: appendmodels `reg_list'
	qui count if endline == 0 & tondo ==0
	estadd scalar num_obs= `r(N)': pooled
	* A 
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if km_to_fixed_vendor_cat == "<= 1.5 km" & tondo ==0, absorb(i.INTNO i.endline) cluster(clustervar)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo A: appendmodels `reg_list'
	qui count if endline == 0 & km_to_fixed_vendor_cat == "<= 1.5 km" & tondo ==0
	estadd scalar num_obs= `r(N)': A
	* B
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if km_to_fixed_vendor_cat == "> 1.5 km and <= 5 km" & tondo ==0, absorb(i.INTNO i.endline) cluster(clustervar)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo B: appendmodels `reg_list' 
	qui count if endline == 0 & km_to_fixed_vendor_cat == "> 1.5 km and <= 5 km" & tondo ==0
	estadd scalar num_obs= `r(N)': B
	* C
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if km_to_fixed_vendor_cat == "> 5 km" & tondo ==0, absorb(i.INTNO i.endline) cluster(clustervar)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo C: appendmodels `reg_list' 
	qui count if endline == 0 & km_to_fixed_vendor_cat == "> 5 km" & tondo ==0
	estadd scalar num_obs= `r(N)': C
	* export table
	esttab `coef_list' using "$diroverleaf/`file_name'.tex", ///
	cells("mean(pattern(1 1 0 0 0 0) fmt(2)) b(star pattern(0 0 1 1 1 1) fmt(2)) se(pattern(0 0 1 1 1 1) fmt(2))") ///
	label replace mtitle("Control" "Treatment" "LATE(pooled)" "LATE(0 to 1.5km)" "LATE(1.5 to 5km)" "LATE(above 5km)") ///
	s(num_obs, fmt(0 ) labels("Nb households" )) ///
	starlevels(* 0.1 ** 0.05 *** 0.01) ///
	notes
}

* by own food prod
{
local vars expenses_1 expenses_2 expenses_rent_utilities_php expenses_6  expenses_gifts_events_php expenses_entertainment_php expenses_10 expenses_vicegoods_php expenses_13 tot_non_food_expenses tot_non_food_expenses_ln tot_non_food_expenses_pc tot_non_food_expenses_pc_ln
local file_name "nonfoodexpenditures_late_ownfoodprod"

	local coef_list meanc meant pooled A B
	* MEANS POOLED
	eststo clear
	eststo meanc: quietly estpost summarize `vars' if treatment == 0 & endline == 1 & tondo ==0
	eststo meant: quietly estpost summarize `vars' if treatment == 1 & endline == 1 & tondo ==0
	* POOLED
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if tondo ==0, absorb(i.INTNO i.endline) cluster(clustervar)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo pooled: appendmodels `reg_list' 
	qui count if endline == 0 & tondo ==0
	estadd scalar num_obs= `r(N)': pooled
	
	* A
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if enterprise_ownfood_baseline == 1 & tondo ==0, absorb(i.INTNO i.endline) cluster(clustervar)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo A: appendmodels `reg_list'
	qui count if endline == 0 & enterprise_ownfood_baseline == 1 & tondo ==0
	estadd scalar num_obs= `r(N)': A
	
	* B
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if enterprise_ownfood_baseline == 0 & tondo ==0, absorb(i.INTNO i.endline) cluster(clustervar)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo B: appendmodels `reg_list'
	qui count if endline == 0 & enterprise_ownfood_baseline == 0 & tondo ==0
	estadd scalar num_obs= `r(N)': B
	
	* export table
	esttab `coef_list' using "$diroverleaf/`file_name'.tex", ///
	cells("mean(pattern(1 1 0 0 0) fmt(2)) b(star pattern(0 0 1 1 1) fmt(2)) se(pattern(0 0 1 1 1) fmt(2))") ///
	label replace mtitle("Control" "Treatment" "LATE(pooled)" "LATE(Prod. own food)" "LATE(No prod. own food)") ///
	s(num_obs, fmt(0 ) labels("Nb households" )) ///
	starlevels(* 0.1 ** 0.05 *** 0.01) ///
	notes
}


***************************************************************
** BY MEAL PLANNER GENDER
***************************************************************
{
local vars any_hunger_3mo hunger_frequent fies_raw fies_fao fcs_score_hh_avg fcs_score_adult_a fcs_score_adult_f fcs_score_adult_m fcs_score_child_3_17_a fcs_score_child_3_17_m fcs_score_child_3_17_f total2_food_1mo_php spend_1 spend_2 spend_3 spend_4 spend_6 spend_7 tot_non_food_expenses expenses_1
local file_name "mealplannergender_late"

	local coef_list meanc meant pooled A B
	* MEANS POOLED
	eststo clear
	eststo meanc: quietly estpost summarize `vars' if treatment == 0 & endline == 1
	eststo meant: quietly estpost summarize `vars' if treatment == 1 & endline == 1
	* POOLED
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		if inlist("`x'","any_hunger_3mo","hunger_frequent","fies_raw","fies_fao"){
			rename Dit_registered `x'
			eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) , absorb(i.INTNO i.endline) cluster(clustervar)
			rename `x' Dit_registered
			}
			else{
				rename registered_walang_gutom `x'
				eststo reg_`counter': ivreghdfe old_`x' (`x' = treatment) if endline == 1,absorb(i.pair_rank) cluster(clustervar)
				rename `x' registered_walang_gutom
				}
	
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo pooled: appendmodels `reg_list'
	qui count if endline == 0 
	estadd scalar num_obs= `r(N)': pooled
	* 
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		if inlist("`x'","any_hunger_3mo","hunger_frequent","fies_raw","fies_fao"){
			rename Dit_registered `x'
			eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if meal_planner_gender_baseline ==1, absorb(i.INTNO i.endline) cluster(clustervar)
			rename `x' Dit_registered
			}
			else{
				rename registered_walang_gutom `x'
				eststo reg_`counter': ivreghdfe old_`x' (`x' = treatment) if endline == 1 & meal_planner_gender_baseline ==1,absorb(i.pair_rank) cluster(clustervar)
				rename `x' registered_walang_gutom
				}
	
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo A: appendmodels `reg_list'
	qui count if endline == 0 & meal_planner_gender_baseline == 1
	estadd scalar num_obs= `r(N)': A
	* 
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		if inlist("`x'","any_hunger_3mo","hunger_frequent","fies_raw","fies_fao"){
			rename Dit_registered `x'
			eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if meal_planner_gender_baseline ==0, absorb(i.INTNO i.endline) cluster(clustervar)
			rename `x' Dit_registered
			}
			else{
				rename registered_walang_gutom `x'
				eststo reg_`counter': ivreghdfe old_`x' (`x' = treatment) if endline == 1 & meal_planner_gender_baseline ==0, absorb(i.pair_rank) cluster(clustervar)
				rename `x' registered_walang_gutom
				}
	
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo B: appendmodels `reg_list' 
	qui count if endline == 0 & meal_planner_gender_baseline == 0
	estadd scalar num_obs= `r(N)': B
	* export table
	esttab `coef_list' using "$diroverleaf/`file_name'.tex", ///
	cells("mean(pattern(1 1 0 0 0) fmt(2)) b(star pattern(0 0 1 1 1) fmt(2)) se(pattern(0 0 1 1 1) fmt(2))") ///
	label replace mtitle("Control" "Treatment" "LATE(pooled)" "LATE(Male)" "LATE(Female)") ///
	s(num_obs, fmt(0 ) labels("Nb households" )) ///
	starlevels(* 0.1 ** 0.05 *** 0.01) ///
	notes
}



/*
***************************************************************
** HH INCOME (panel)
***************************************************************
codebook hh_income_1_mo hh_income_1_mo_pc ln_hh_income_1_mo ln_hh_income_1_mo_pc // ok

local vlist hh_income_1_mo hh_income_1_mo_pc ln_hh_income_1_mo ln_hh_income_1_mo_pc
foreach var of local vlist {
	ivreghdfe `var' (Dit_registered = Dit), absorb(i.INTNO i.endline) cluster(clustervar)
}
// no effect

***************************************************************
** ENTERPRISE FOOD (panel)
***************************************************************
su enterprise_food_rev_* if enterprise_food == 1 & endline == 0, d // ok

ivreghdfe enterprise_food (Dit_registered = Dit), absorb(i.INTNO i.endline) cluster(clustervar)
ivreghdfe enterprise_food_rev_1mo (Dit_registered = Dit), absorb(i.INTNO i.endline) cluster(clustervar)
ivreghdfe enterprise_food_rev_6mo (Dit_registered = Dit), absorb(i.INTNO i.endline) cluster(clustervar)
// no effect on avg

***************************************************************
** WAGES / WORK (panel)
***************************************************************
codebook wages_1_mo_total days_worked_1w hours_worked_1day // ok, no missing, not to many 0, possible outliers in hours_worked_1day or wrong label
replace hours_worked_1day = . if hours_worked_1day > 24 // 24 hours per day

ivreghdfe wages_1_mo_total (Dit_registered = Dit), absorb(i.INTNO i.endline) cluster(clustervar)
ivreghdfe days_worked_1w (Dit_registered = Dit), absorb(i.INTNO i.endline) cluster(clustervar)
ivreghdfe hours_worked_1day (Dit_registered = Dit), absorb(i.INTNO i.endline) cluster(clustervar)
// no effect on avg


***************************************************************
** SCHOOLING (endline)
***************************************************************
su went_school_may
ivreghdfe went_school_may (registered = treatment), absorb(i.pair_rank) cluster(clustervar)
// no effect

***************************************************************
** HEALTH ()
***************************************************************



/* OLD
***************************************************************
***************************************************************
** SUBGROUP ANALYSES (LATE ONLY)
***************************************************************
***************************************************************
local vars // endline ony
local vars2 // vars2 = avaible both at endline and baseline

***************************************************************
** ABOVE/BELOW MEDIAN BASELINE NUTRTION KNOWLEDGE 
***************************************************************
{
local file_name "all_bynutritionknowledge_late"
	local coef_list csivpooled xtivpooled csiv1 xtiv1 csiv0 xtiv0
	* cross sectional iv (endline) POOLED
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename registered_walang_gutom `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'=treatment) if endline == 1, absorb(i.pair_rank) cluster(clustervar)
		rename `x' registered_walang_gutom
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo csivpooled: appendmodels `reg_list' 
	* panel iv POOLED
	local counter = 1
	foreach x of local vars2 {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit), absorb(i.INTNO i.endline) cluster(clustervar)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo xtivpooled: appendmodels `reg_list' 
	* cross sectional iv (endline)
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename registered_walang_gutom `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'=treatment) if endline == 1 & higher_quiz_baseline == 1, absorb(i.pair_rank) cluster(clustervar)
		rename `x' registered_walang_gutom
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo csiv1: appendmodels `reg_list' 
	* panel iv
	local counter = 1
	foreach x of local vars2 {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if higher_quiz_baseline == 1, absorb(i.INTNO i.endline) cluster(clustervar)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo xtiv1: appendmodels `reg_list'
	* cross sectional iv (endline)
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename registered_walang_gutom `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'=treatment) if endline == 1 & higher_quiz_baseline == 0, absorb(i.pair_rank) cluster(clustervar)
		rename `x' registered_walang_gutom
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo csiv0: appendmodels `reg_list' 
	* panel iv
	local counter = 1
	foreach x of local vars2 {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if higher_quiz_baseline == 0, absorb(i.INTNO i.endline) cluster(clustervar)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo xtiv0: appendmodels `reg_list' 
	* export table
	esttab `coef_list' using "$diroverleaf/`file_name'.tex", ///
	cells("b(star pattern(1 1 1 1 1 1) fmt(2)) se(pattern(1 1 1 1 1 1) fmt(2))") ///
	label replace mtitle("LATE(endline)pooled" "LATE(twfe)pooled" "LATE(endline)higher" "LATE(twfe)higher" "LATE(endline)lower" "LATE(twfe)lower") ///
	starlevels(* 0.1 ** 0.05 *** 0.01) ///
	notes
}

***************************************************************
**  URBAN vs RURAL (LATE ONLY)
***************************************************************
{
local file_name "all_ruralurban_late"
	local coef_list csivpooled xtivpooled csiv1 xtiv1 csiv0 xtiv0
	* cross sectional iv (endline) POOLED
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename registered_walang_gutom `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'=treatment) if endline == 1, absorb(i.pair_rank) cluster(clustervar)
		rename `x' registered_walang_gutom
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo csivpooled: appendmodels `reg_list' 
	* panel iv POOLED
	local counter = 1
	foreach x of local vars2 {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit), absorb(i.INTNO i.endline) cluster(clustervar)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo xtivpooled: appendmodels `reg_list' 
	* cross sectional iv (endline)
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename registered_walang_gutom `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'=treatment) if endline == 1 & urban == 1, absorb(i.pair_rank) cluster(clustervar)
		rename `x' registered_walang_gutom
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo csiv1: appendmodels `reg_list' 
	* panel iv
	local counter = 1
	foreach x of local vars2 {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if urban == 1, absorb(i.INTNO i.endline) cluster(clustervar)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo xtiv1: appendmodels `reg_list'
	* cross sectional iv (endline)
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename registered_walang_gutom `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'=treatment) if endline == 1 & urban == 0, absorb(i.pair_rank) cluster(clustervar)
		rename `x' registered_walang_gutom
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo csiv0: appendmodels `reg_list' 
	* panel iv
	local counter = 1
	foreach x of local vars2 {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if urban == 0, absorb(i.INTNO i.endline) cluster(clustervar)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo xtiv0: appendmodels `reg_list' 
	* export table
	esttab `coef_list' using "$diroverleaf/`file_name'.tex", ///
	cells("b(star pattern(1 1 1 1 1 1) fmt(2)) se(pattern(1 1 1 1 1 1) fmt(2))") ///
	label replace mtitle("LATE(endline)pooled" "LATE(twfe)pooled" "LATE(endline)urban" "LATE(twfe)urban" "LATE(endline)rural" "LATE(twfe)rural") ///
	starlevels(* 0.1 ** 0.05 *** 0.01) ///
	notes
}

***************************************************************
**  HHSIZE
***************************************************************
{
local file_name "all_hhsize_late"
	local coef_list csivsmall xtivsmall csivmedium xtivmedium csivlarge xtivlarge
	* cross sectional iv (endline) small
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename registered_walang_gutom `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'=treatment) if endline == 1 & hhsize_category =="5 or less", absorb(i.pair_rank) cluster(clustervar)
		rename `x' registered_walang_gutom
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo csivsmall: appendmodels `reg_list' 
	* panel iv small
	local counter = 1
	foreach x of local vars2 {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if hhsize_category =="5 or less", absorb(i.INTNO i.endline) cluster(clustervar)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo xtivsmall: appendmodels `reg_list' 
	* cross sectional iv (endline) medium
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename registered_walang_gutom `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'=treatment) if endline == 1 & hhsize_category == "6 or 7", absorb(i.pair_rank) cluster(clustervar)
		rename `x' registered_walang_gutom
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo csivmedium: appendmodels `reg_list' 
	* panel iv medium
	local counter = 1
	foreach x of local vars2 {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if hhsize_category == "6 or 7", absorb(i.INTNO i.endline) cluster(clustervar)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo xtivmedium: appendmodels `reg_list'
	* cross sectional iv (endline) large
	local counter = 1
	foreach x of local vars {
		rename `x' old_`x'
		rename registered_walang_gutom `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'=treatment) if endline == 1 & hhsize_category == "8 or more", absorb(i.pair_rank) cluster(clustervar)
		rename `x' registered_walang_gutom
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo csivlarge: appendmodels `reg_list' 
	* panel iv large
	local counter = 1
	foreach x of local vars2 {
		rename `x' old_`x'
		rename Dit_registered `x'
		eststo reg_`counter': ivreghdfe old_`x' (`x'= Dit) if hhsize_category == "8 or more", absorb(i.INTNO i.endline) cluster(clustervar)
		rename `x' Dit_registered
		rename old_`x' `x' 
		local ++counter
		}	
	local --counter
	local reg_list reg_1
	forvalues x=2/`counter'{
		local reg_list `reg_list' reg_`x'
	}
	eststo xtivlarge: appendmodels `reg_list' 
	* export table
	esttab `coef_list' using "$diroverleaf/`file_name'.tex", ///
	cells("b(star pattern(1 1 1 1 1 1) fmt(2)) se(pattern(1 1 1 1 1 1) fmt(2))") ///
	label replace mtitle("LATE(endline)small" "LATE(twfe)small" "LATE(endline)medium" "LATE(twfe)medium" "LATE(endline)large" "LATE(twfe)large") ///
	starlevels(* 0.1 ** 0.05 *** 0.01) ///
	notes
}	
*/
*/




