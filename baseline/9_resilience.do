// date: 25/07/2024
// project: 1809 ADF Philippines - Assignment 1: impact evaluation 
// author: silvia
// purpose: resilience index

* load data
cd "~/Development Pathways Ltd/PHL_AFD_2024_Walang Gutom - Technical/Impact Evaluation (Assignment 1)/Data"
use "Processed/FSP Baseline Processed.dta", clear

* tables folder
cd "~/Development Pathways Ltd/PHL_AFD_2024_Walang Gutom - Technical/Impact Evaluation (Assignment 1)/Data/Tables"

drop if missing(treatment)
cap gen control = (treatment==0)
**# Bookmark #1
keep if rel==1
	
************************
* Absorptive resilence *
************************
{
global assets tot_asset_value z_asset_value agri_land_sqm agri_land_pc resid_land_sqm n_f_assets value_f_asset n_shops_owned /*value_shop*/ n_assets value_asset n_extra_assets value_extra_asset n_asset_types assetindex_pca_nf assetindex_pca asset_swindex asset_index*

global absorptive_all $assets hh_treat_child hh_safetynet* n_programs share_food share_necess FIES_* shop_diversity negative_strat* n_neg_strat hh_vul_lab hh_n_child_lab hh_child_lab hh_emprate hh_work tot_savings bad_debt any_debt hh_vuln_livelihood crop_lives_fish hh_bop loss_consum network_help

global absorptive_1 n_extra_assets n_programs share_food FIES_8 negative_strat_climate hh_emprate tot_savings bad_debt
	
global absorptive_2 hh_vul_lab has_savings bad_debt value_extra_asset FIES_8 share_food n_safetynet hh_healthins hh_network negative_strat_climate health_access
}

**# Bookmark #2
global absorptive_3A hh_bop has_savings bad_debt value_extra_asset FIES_8 share_food n_safetynet hh_healthins hh_network health_access negative_strat_climate 

global absorptive_3B hh_bop has_savings value_extra_asset FIES_8 share_food hh_network  

global absorptive_3C hh_bop has_savings value_extra_asset FIES_8 share_food hh_network negative_strat_climate

swindex	$absorptive_3A if rel==1, gen(abs_index_A) displayw /*normby(control) fullrescale*/ ///
	flip(bad_debt FIES_8 share_food negative_strat_climate )

pca $absorptive_3A
predict abs_index_pca_A, score
	
swindex	$absorptive_3B if rel==1, gen(abs_index_B) displayw /*normby(control) fullrescale*/ ///
	flip(bad_debt FIES_8 share_food)

pca $absorptive_3B
predict abs_index_pca_B, score

swindex	$absorptive_3C if rel==1, gen(abs_index_C) displayw /*normby(control) fullrescale*/ ///
	flip(bad_debt FIES_8 share_food negative_strat_climate )

pca $absorptive_3C
predict abs_index_pca_C, score
	
asdoc pwcorr $absorptive_3A if rel==1, bonferroni star(all) save(abs_corr_3A.doc) replace

	reg abs_index_A $absorptive_3A i.MUN, robust 
*	outreg2 using "abs_reg.xls", append ctitle (abs_index_A)				

reg abs_index_A $absorptive_3A if MUN==20313 , robust // san mariano 
	
/* matrix without stars
putexcel set "corr_matrix.xlsx", sheet("absorptive") modify
pwcorr $absorptive_all abs_index if rel==1, bonferroni star(0.05) 
putexcel A1=matrix(r(C)) , names
*/

iebaltab $absorptive_3A abs_index_* if rel==1 , grpvar(treatment) vce(cluster final_cluster) /*balmiss(groupmean)*/ total replace save("abs_balance_3.xlsx")

**********************
* Adaptive resilence *
**********************
{
global adaptive_all n_asset_types pregnant_health has_pregnant access_info hh_socinsur hh_SLP negative_strat no_negative_strat  hh_adapted s_hh_vuln_income s_hh_vuln_livelihood HHI_* n_sources hh_depratio hh_fitadults hh_wawork good_debt good_source hh_vuln_livelihood crop_lives_fish hh_farming hh_vul_work

global adaptive_1 n_asset_types pregnant_health access_info hh_socinsur hh_SLP no_negative_strat hh_farming hh_vul_work HHI_livelihood good_debt
}

**# Bookmark #3
global adaptive_2A n_sources crop_lives_fish /*hh_vul_bop*/ hh_inclusion no_negative_strat_climate /* no_negative_strat */  hh_socinsur n_asset_types access_info good_debt hh_emprate 

global adaptive_2B n_sources crop_lives_fish hh_vul_bop n_asset_types access_info good_debt

global adaptive_2C n_sources crop_lives_fish hh_vul_bop no_negative_strat n_asset_types access_info good_debt
 
swindex	$adaptive_2A if rel==1, gen(adapt_index_A) displayw /*normby(control) fullrescale*/ ///
	flip(crop_lives_fish hh_vul_bop)
swindex	$adaptive_2B if rel==1, gen(adapt_index_B) displayw /*normby(control) fullrescale*/ ///
	flip(crop_lives_fish hh_vul_bop)
swindex	$adaptive_2C if rel==1, gen(adapt_index_C) displayw /*normby(control) fullrescale*/ ///
	flip(crop_lives_fish hh_vul_bop)

pca $adaptive_2A
predict adapt_index_pca_A, score
pca $adaptive_2B
predict adapt_index_pca_B, score
pca $adaptive_2C
predict adapt_index_pca_C, score
		
asdoc pwcorr $adaptive_2A if rel==1, bonferroni star(all) save(adapt_corr_2A.doc) replace

iebaltab $adaptive_2A adapt_index_* if rel==1 , grpvar(treatment) vce(cluster final_cluster) /*balmiss(groupmean)*/ total replace save("adapt_balance_2.xlsx")

*****************************
* Transformative resilience *
*****************************

global transformative_all $assets hh_school prop_attend_school hh_inclusion hh_maxedu hh_totedu hh_edu_pot hh_edupotratio HHI_livelihood

global transformative tot_asset_value agri_land_pc resid_land_sqm hh_inclusion hh_edupotratio HHI_livelihood

global transformative_1 agri_land_pc resid_land_sqm n_shops_owned exp_edu age_appr_edu_ratio 

**# Bookmark #4
global transformative_2 exp_edu_pchild age_appr_edu_ratio 

swindex	$transformative_2 if rel==1, gen(transf_index_2) displayw /*normby(control) fullrescale*/

pca $transformative_2
predict transf_index_pca_2, score

asdoc pwcorr $transformative_2 if rel==1, bonferroni star(all) save(transf_corr_2.doc) replace

iebaltab $transformative_2 transf_index_* if rel==1 , grpvar(treatment) vce(cluster final_cluster) /*balmiss(groupmean)*/ total replace save("transf_balance_2.xlsx")

save "~/Development Pathways Ltd/PHL_AFD_2024_Walang Gutom - Technical/Impact Evaluation (Assignment 1)/Data/Processed/FSP Baseline Processed_HH.dta", replace

// summary of index components

cd "~/Development Pathways Ltd/PHL_AFD_2024_Walang Gutom - Technical/Impact Evaluation (Assignment 1)/Data/Tables"

global general hhsize has_child05 has_child017 hh_skipgen hh_singlepar hh_depratio ///
hh_ill_child has_pregnant health_access ///
hh_totedu prop_attend_s* hh_emprate hh_child_lab hh_n_jobs  ///
crop livestock fishing crop_lives_fish foodservice wholesale manufacturing trasportation other_activ other_sources ///
HHTIncome HHTIncome_pc CROPTOT1 LIVESTOCKTOT1 FISHINGTOT1 FOODSERVICETOT1 WHOLESALETOT1 MANUFACTURINGTOT1 TRANSPORTATIONTOT1 OTHERTOT1 ENTREPRENEURIALTOT1_pc OTHERPROG1 INCOMERECEIPTS1 INCOMEALLSOURCES1 INCOMEALLSOURCES1_pc /// 12 months
hh_farming /// someone in hh engages in farming/fishing in any form 
n_sources ///
TOTALCONSUMPTION food_consumption_pc total_consumption_pc share_food exp_edu ///
tot_asset_value agri_land resid_land n_shops_owned n_f_assets value_f_asset n_assets value_asset n_asset_types n_extra_assets value_extra_asset assetindex_pca ///
tot_savings tot_borrow any_debt bad_source bad_reason bad_debt good_debt ///
hunger FIES_24 shop_diversity n_climshock any_climshock ///
loss_assets_cl loss_income_cl loss_consum_cl hh_adapted ///
prog_* n_prog 

eststo clear
bysort MUN: eststo: quietly estpost sum  $absorptive_3A abs_index_* $adaptive_2A adapt_index_* $transformative_2 transf_index_* $general 
eststo: quietly estpost sum $absorptive_3A abs_index_* $adaptive_2A adapt_index_* $transformative_2 transf_index_* $general
esttab using "summary_components_1609.csv", cells("count mean sd min max") replace

/*
import delimited summary_components.csv, clear
foreach var of varlist * {
    replace `var'= ustrregexra(`var', `"[="]"', "")
}

export excel using "summary_components", sheet("summary_components") sheetreplace
*/

