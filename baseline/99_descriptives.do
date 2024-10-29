// date: 25/07/2024
// project: 1809 ADF Philippines - Assignment 1: impact evaluation 
// author: silvia
// purpose: export tables of descriptive statistics

********************************************************************************
      * summary of all variables * 
********************************************************************************

cd "~/Development Pathways Ltd/PHL_AFD_2024_Walang Gutom - Technical/Impact Evaluation (Assignment 1)/Data/Tables"

use "~/Development Pathways Ltd/PHL_AFD_2024_Walang Gutom - Technical/Impact Evaluation (Assignment 1)/Data/Processed/FSP Baseline Processed_HH.dta", clear

global all hhsize sex age n_child05 n_child017 has_child05 has_child017 hh_skipgen hh_singlepar /*hh_fitadults*/ hh_depratio edu hh_maxedu hh_totedu hh_edupotratio hh_eduratio work work_hrs paid_work wage_work agri_work hh_fitwork hh_emprate hh_unfit_work hh_child_lab hh_vul_lab hh_n_jobs HHTIncome HHTIncome_pc crop livestock fishing foodservice wholesale manufacturing trasportation other_activ other_progs other_assista*e other_pension other_rentals other_interests other_other other_sources hh_farm_income hh_vuln_income hh_livelihood hh_livelihood*c hh_income n_sources s_hh_vuln_inc*e s_hh_vuln_liv*d HHI_income HHI_livelihood food_consumpt*n food_consumpt*c nonfood_consu*n neces_consump*n total_consump*n total_consump*c share_food share_necess tot_asset_value agri_land agri_land_sqm agri_land_pc resid_land resid_land_sqm n_shops_owned n_f_assets n_assets n_asset_types asset_index_f*m asset_index asset_index_l*d asset_index_t*l tot_savings savings_pc tot_borrow any_debt good_source bad_source good_reason bad_reason good_debt bad_debt hunger hunger_freq FIES_8 FIES_24 shop_diversity n_shocks any_shock n_disaster any_disaster n_climshock any_climshock n_strategies negative_strat n_neg_strat negative_stra*e hh_safetynet hh_inclusion n_prog hh_socinsur hh_treat_child hh_ill_child has_pregnant has_preg_or_c*d health_access day_care access_info hh_school prop_attend_s*l z_asset_value value_f_asset value_asset n_extra_assets value_extra_a*t assetindex_pc*f assetindex_pca asset_swindex hh_safetynet2 hh_safetynet*4p hh_n_child_lab hh_work hh_vuln crop_lives_fish hh_bop loss_consum network_help pregnant_health hh_SLP no_negative_s*t hh_adapted hh_wawork loss_assets loss_income loss_assets_cl loss_income_cl loss_consum_cl loss_incomeas*l hh_farming hh_vul_work hh_edu_pot

eststo clear
bysort MUN: eststo: quietly estpost sum $all
eststo: quietly estpost sum $all 
esttab using "summary_by_mun.csv", cells("count mean sd min max") replace

import delimited summary_by_mun.csv, clear
foreach var of varlist * {
    replace `var'= ustrregexra(`var', `"[="]"', "")
}

export excel using "summary_by_mun", sheet("summary_by_mun") sheetreplace

********************************************************************************
/*
********************************************************************************


use "~/Development Pathways Ltd/PHL_AFD_2024_Walang Gutom - Technical/Impact Evaluation (Assignment 1)/Data/Processed/FSP Baseline Processed_HH.dta", clear

eststo clear
bysort MUN: eststo: quietly estpost sum $general $absorptive $adaptive $transformative 
eststo: quietly estpost sum $general $absorptive $adaptive $transformative
esttab using "summary_by_mun_short.csv", cells("count mean sd min max") replace

import delimited summary_by_mun.csv, clear
foreach var of varlist * {
    replace `var'= ustrregexra(`var', `"[="]"', "")
}

export excel using "summary_by_mun", sheet("summary_by_mun") sheetreplace


********************************************************************************

********************************************************************************

global data_folder "~/Development Pathways Ltd/PHL_AFD_2024_Walang Gutom - Technical/Impact Evaluation (Assignment 1)/Data"

use "$data_folder/Processed/FSP Baseline Processed.dta", clear

cd "$data_folder/Tables"

/*

drop if missing(treatment)

* IND LEVEL

global ind_vars age10yrs ethnicity marital edu work nowork_reason work_type* sector* agri_work wage_work unfit_work bop*

foreach var of varlist $ind_vars {
 table (MUN) (`var'), statistic(percent, across(`var')) nformat(%5.1f)
 collect export "Baseline stats.xlsx", as(xlsx) sheet("IND_`var'", replace) cell(B5) modify
 putexcel set "Baseline stats.xlsx", sheet("IND_`var'") modify
 putexcel B2 = "Population composition by `var' and location",  font("calibri" , 14)
 putexcel B3 = "Source: Walang Gutom RCT Baseline ($S_DATE)",  font("calibri" , 9)
}

*/

**# Bookmark #2
* HH LEVEL
keep if rel==1

**********************
* Modules' shortcuts * 
**********************

global general hhid pid PROVINCE MUN BRGY treatment pair_rank final_cluster cluster_size km_to_fixed_vendor hhsize sex age rel marital ethnicity  n_child* has_child* hh_skipgen hh_singlepar hhtype hh_fitadults hh_depratio 

global edu edu hh_maxedu hh_totedu hh_edupotratio hh_eduratio

global work work nowork_reason work_hrs work_type* sector* paid_work wage_work agri_work hh_fitwork hh_emprate hh_unfit_work hh_child_lab hh_n_child_lab hh_vul_lab bop* HHMPINCOME HHMSINCOME HHMOIncome hh_n_jobs

global income HHTIncome* crop CROPTOT1 livestock LIVESTOCKTOT1 fishing FISHINGTOT1 foodservice FOODSERVICETOT1 wholesale WHOLESALETOT1 manufacturing MANUFACTURINGTOT1 trasportation TRANSPORTATIONTOT1 ENTREPRENEURIALTOT1* OTHERTOT1 other_* OTHERPROG1 Q6_*_T INCOMERECEIPTS1 n_sources_alt INCOMEALLSOURCES1* hh_farm_income hh_vuln_income hh_livelihood* hh_income n_sources n_sources_alt s_hh_vuln_income s_hh_vuln_livelihood s1A_* HHI_income s1B_* HHI_livelihood  

global consumption TOTALBREADANDCEREALS TOTALMEAT TOTALFISHANDSEAFOOD TOTALMILKDAIRYANDEGGS TOTALOILDANDFATS TOTALFRUITSANDNUTS TOTALVEGETABLES TOTALSUGARPROD TOTALFOODNEC TOTALNONALCOHOL TOTALCOOKED food_consumption* Q9_2_* nonfood_consumption neces_consumption total_consumption* share_food share_necess 

global assets tot_asset_value agri_land* resid_land* n_shops_owned price_shop price_* weighted_a* has_asset_* n_f_assets n_assets n_asset_types asset_index*

global debt tot_savings savings_pc tot_borrow any_debt good_source bad_source good_reason bad_reason good_debt bad_debt 

global shocks hunger hunger_freq FIES_8 FIES_24 shop_diversity n_shocks any_shock n_disaster any_disaster n_climshock any_climshock n_strategies negative_strat n_neg_strat negative_strat_climate 

global socpro Q5_*A Q5_*B Q5_*C Q6_2_1* hh_safetynet hh_safetynet2 hh_inclusion n_programs hh_socinsur 

global services hh_treat_child hh_ill_child has_pregnant has_preg_or_child health_access day_care access_info hh_school prop_attend_school 

global resilience /*abs_index*/ 

global all $general $edu $work $income $consumption $assets $debt $shocks $socpro $services $resilience

* keep $general $edu $work $income $consumption $assets $debt $shocks $socpro $services $resilience

missings report $all

****************************
* summary of all variables * 
****************************

eststo clear
eststo: quietly estpost sum $all 
* esttab using "summary.csv", cells("count mean sd min max") replace
bysort MUN: eststo: quietly estpost summarize $all 
esttab using "summary_by_mun.csv", cells("count mean sd min max") replace
import delimited summary_by_mun.csv, clear
foreach var of varlist * {
    replace `var'= ustrregexra(`var', `"[="]"', "")
}
export excel using "summary_by_mun", sheet("summary_by_mun") sheetreplace

******************
* Type shortcuts *
******************

use "$data_folder/Processed/FSP Baseline Processed.dta", clear

* global dummy crop livestock fishing foodservice wholesale manufacturing trasportation other_* hunger hh_unfit_work hh_child_lab *_debt *_source *d_reason Q16_*A any_shock any_disaster any_climshock negative_strat hh_safetynet* hh_inclusion hh_socinsur hh_treat_child hh_ill_child 

* global numeric cluster_size hhsize km_to_fixed_vendor hh_totedu hh_fitadults hh_depratio hh_fitwork hh_n_child_lab hh_n_vul_lab HHTIncome* CROPTOT1 LIVESTOCKTOT1 FISHINGTOT1 FOODSERVICETOT1 WHOLESALETOT1 MANUFACTURINGTOT1 TRANSPORTATIONTOT1 OTHERTOT1 ENTREPRENEURIALTOT1* OTHERPROG1 INCOMERECEIPTS1 INCOMEALLSOURCES1* hh_farm_income hh_vuln_income hh_livelihood* hh_income* n_sources hh_n_jobs food_consumption* total_consumption* tot_savings savings_pc tot_borrow FIES_8 FIES_24 shop_diversity n_shocks n_disaster n_climshock n_strategies n_neg_strat n_programs 

* global share hh_eduratio hh_edupotratio hh_emprate s_hh_vuln_income s_hh_vuln_livelihood HHI_income HHI_livelihood 

global categorical hhsize_bin hhtype age10yrs sex marital ethnicity edu nowork_reason work_type* sector* bop* n_sources n_shops_owned n_f_assets n_assets n_asset_types hunger_freq FIES_8 n_shocks n_disaster n_climshock n_strategies n_programs 

********************************************
* Distribution (level variables) by location
********************************************

foreach var of varlist $categorical {
 table (`var') (MUN), statistic(frequency) statistic(percent, across(`var'))
 collect recode result frequency = column1
 collect recode result percent = column2
 collect layout (`var') (MUN#result[column1 column2])
 collect style cell result[column1], nformat (%5.0f)
 collect style cell result[column2], nformat (%3.0f)
 collect label levels result column1 "Freq"
 collect label levels result column2 "%"
 collect export "Baseline stats.xlsx", as(xlsx) sheet("`var'", replace) cell(B5) modify
 putexcel set "Baseline stats.xlsx", sheet("`var'") modify
 putexcel B2 = "Frequency and share of `var' by location",  font("calibri" , 14)
 putexcel B3 = "Source: Walang Gutom RCT Baseline ($S_DATE)",  font("calibri" , 9)
}

/*
************************
* Freq & share (dummies)
************************

foreach var of varlist $dummy {
 table MUN, statistic(total `var') statistic(frequency) statistic(mean `var') statistic(sd `var')
 collect export "Baseline stats.xlsx", as(xlsx) sheet("`var'", replace) cell(B5) modify
 putexcel set "Baseline stats.xlsx", sheet("`var'") modify
 putexcel B2 = "Frequency and share of `var' by location",  font("calibri" , 14)
 putexcel B3 = "Source: Walang Gutom RCT Baseline ($S_DATE)",  font("calibri" , 9)
}

***********************************
* Summary by location (numerical) *
***********************************

foreach var of varlist $numeric $share {
 table MUN, statistic(mean `var') statistic(sd `var') statistic(min `var') statistic(max `var')  statistic(frequency) 
 collect export "Baseline stats.xlsx", as(xlsx) sheet("`var'_n", replace) cell(B5) modify
 putexcel set "Baseline stats.xlsx", sheet("`var'_n") modify
 putexcel B2 = "Summary statistics of `var' by location",  font("calibri" , 14)
 putexcel B3 = "Source: Walang Gutom RCT Baseline ($S_DATE)",  font("calibri" , 9)
}

************************
* Tondo vs other areas *
************************

iebaltab $general $income $assets , grpvar(tondo) /*vce(cluster final_cluster) balmiss(groupmean)*/ total replace save("Tondo_Other.xlsx")
  
reg tondo $general $income $assets , robust
outreg2 using "Tondo_Other_reg.xlsx.xls", replace

*/

************************
* Histograms (numerical)
************************

hist HHI_income HHI_livelihood

*************
* Correlation
*************

asdoc pwcorr $general $income $assets , bonferroni star(all) save(correlation.doc)

**********************************
* Treatment vs Control (balance) *
**********************************

* Absorptive resilence
iebaltab $absorptive abs_index , grpvar(treatment) vce(cluster final_cluster) /*balmiss(groupmean)*/ total replace save("abs_balance.xlsx")


*******************
* other questions *
*******************

* are shops urban assets?
mean Q13_3D1, over(MUN) // 106 obs
mean n_shops_owned, over(MUN)

* how many people experienced shocks?
mean any_shock any_disaster any_climshock, over(MUN)

* which strategies were used?
su strategy*  negative_strat if rel==1 & any_shock==1

* are negative strategies related to type of income source?
pwcorr negative_strat crop livestock fishing foodservice wholesale manufacturing trasportation other_activ if rel==1, bonferroni star(0.05)

* do crop hhs use less negative strat because they're more food secure?
pwcorr FIES_8 crop livestock fishing foodservice wholesale manufacturing trasportation other_activ if rel==1, bonferroni star(0.05)




* variation in asset prices within item and location



/*

**********************************
* Treatment vs Control (endline) *
**********************************

* differences

iebaltab $general $income $assets , grpvar(treatment) /*vce(cluster location) balmiss(groupmean)*/ total replace save("iebaltab.xlsx")

* dummy 
foreach var of varlist $dummy {
 table (MUN) (treatment), statistic(total `var') statistic(frequency) statistic(mean `var') statistic(sd `var')
 collect recode result total = column1
 collect recode result frequency = column2 
 collect recode result mean = column3
 collect recode result sd = column4
 collect layout (MUN) (treatment#result[column1 column2 column3 column4])
 collect style cell result[column1], nformat (%5.0f)
 collect style cell result[column2], nformat (%5.0f)
 collect style cell result[column3], nformat (%5.2f)
 collect style cell result[column4], nformat (%5.3f)
 collect label levels result column1 "Freq"
 collect label levels result column2 "Tot"
 collect label levels result column3 "%"
 collect label levels result column4 "SD"
 collect export "Baseline stats.xlsx", as(xlsx) sheet("`var'", replace) cell(B5) modify
 putexcel set "Baseline stats.xlsx", sheet("`var'") modify
 putexcel B2 = "Frequency and share of `var' by location and treatment group",  font("calibri" , 14)
 putexcel B3 = "Source: Walang Gutom RCT Baseline ($S_DATE)",  font("calibri" , 9)
}

* numerical 
foreach var of varlist $varlist{
 table (MUN) (treatment), statistic(mean $varlist) statistic(sd $varlist) statistic(min $varlist) statistic(max $varlist)  statistic(frequency) 
 collect recode result mean = column1
 collect recode result sd = column2
 collect recode result min = column3
 collect recode result max = column4
 collect recode result frequency = column5
 collect layout (MUN) (treatment#result[column1 column2 column3 column4 column5])
 collect style cell result[column1], nformat (%5.1f)
 collect style cell result[column2], nformat (%5.1f)
 collect style cell result[column3], nformat (%5.0f)
 collect style cell result[column4], nformat (%5.0f)
 collect style cell result[column5], nformat (%5.0f)
 collect label levels result column1 "Mean"
 collect label levels result column2 "SD"
 collect label levels result column3 "Min"
 collect label levels result column4 "Max"
 collect label levels result column5 "Obs"
 collect export "baseline-stats.xlsx", as(xlsx) sheet("_`var'", replace) cell(B5) modify
 putexcel set "baseline-stats.xlsx", sheet("_`var'") modify
 putexcel B2 = "Mean, standard deviation, minimum, maximum amd number of observations `var' by location",  font("calibri" , 14)
 putexcel B3 = "Source: Walang Gutom RCT Baseline ($S_DATE)",  font("calibri" , 9)
}
*/
*/


use "~/Development Pathways Ltd/PHL_AFD_2024_Walang Gutom - Technical/Impact Evaluation (Assignment 1)/Data/Processed/FSP Baseline Processed_HH.dta", clear

global darkblue 	"0 57 114"
global darkorange 	"239 93 59"
global lightgrey 	"242 242 242"
global teal 		"41 139 156"
global yellow 		"250 180 31"
global purple 		"112 48 160"

// plot

twoway scatter hh_livelihood n_sources

tab hhsize_bin MUN, col nofreq

graph box food_consumption_pc /*share_food*/ , over(MUN)

graph box share_food , over(MUN)

graph box hhsize , over(MUN)

graph box hhsize, over(MUN) box(1, fcolor($lightgrey ) lcolor($darkblue )) medtype(cline) medline(lcolor($darkblue )) cwhisker lines(lcolor($darkblue )) marker(1, mcolor($darkblue )) ytitle("Household size") graphregion(fcolor($lightgrey ) lcolor($lightgrey ) ifcolor($lightgrey ) ilcolor($lightgrey )) plotregion(fcolor($lightgrey) lcolor($lightgrey ) ifcolor($lightgrey ) ilcolor($lightgrey ))

mean prog_8, over(MUN)
mean hh_safetynet_no4p, over(MUN)

tab n_safetynet MUN, col nofreq
graph hbox n_safetynet , over(MUN)

recode n_sources (6/max = 6 "6 or more"), gen (n_sources_bin)
tab n_sources_bin MUN, col nofreq

mean any_climshock Q16_2A Q16_3A Q16_6A Q16_7A Q16_8A //, over(MUN)

mean crop livestock fishing foodservice wholesale manufacturing trasportation other_activ other_sources //, over (MUN)

tab main_livelihood MUN, col nofreq

tabstat hh_farming hh_foodservice hh_wholesale hh_manufacturing hh_transportation hh_other_activ, statistics( mean ) by(MUN)

graph box value_extra_asset if round==0, over(MUN)

table () (MUN), statistic(mean $index ) nototals
mean $index
