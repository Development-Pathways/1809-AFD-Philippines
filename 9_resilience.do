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

global assets tot_asset_value z_asset_value agri_land_sqm agri_land_pc resid_land_sqm n_f_assets value_f_asset n_shops_owned /*value_shop*/ n_assets value_asset n_extra_assets value_extra_asset n_asset_types assetindex_pca_nf assetindex_pca asset_swindex asset_index*

global absorptive_all $assets hh_treat_child hh_safetynet* n_programs share_food share_necess FIES_* shop_diversity negative_strat* n_neg_strat hh_vul_lab hh_n_child_lab hh_child_lab hh_emprate hh_work tot_savings bad_debt any_debt hh_vuln crop_lives_fish hh_bop loss_consum network_help

global absorptive n_extra_assets n_programs share_food FIES_8 negative_strat_climate hh_emprate tot_savings bad_debt
		
swindex	$absorptive if rel==1, gen(abs_index) displayw /*normby(control) fullrescale*/ ///
	flip(share_food FIES_8 negative_strat_climate bad_debt)

asdoc pwcorr $absorptive_all abs_index if rel==1, bonferroni star(all) save(adapt_corr.doc) replace
	
/* matrix without stars
putexcel set "corr_matrix.xlsx", sheet("absorptive") modify
pwcorr $absorptive_all abs_index if rel==1, bonferroni star(0.05) 
putexcel A1=matrix(r(C)) , names
*/

iebaltab $absorptive abs_index if rel==1 , grpvar(treatment) vce(cluster final_cluster) /*balmiss(groupmean)*/ total replace save("abs_balance.xlsx")

**********************
* Adaptive resilence *
**********************

global adaptive_all n_asset_types pregnant_health has_pregnant access_info hh_socinsur hh_SLP negative_strat no_negative_strat  hh_adapted s_hh_vuln_income s_hh_vuln_livelihood HHI_* n_sources hh_depratio hh_fitadults hh_wawork good_debt good_source hh_vuln crop_lives_fish hh_farming hh_vul_work

global adaptive n_asset_types pregnant_health access_info hh_socinsur hh_SLP no_negative_strat hh_farming hh_vul_work HHI_livelihood good_debt

swindex	$adaptive if rel==1, gen(adapt_index) displayw /*normby(control) fullrescale*/ ///
	flip(hh_farming hh_vul_work HHI_livelihood)

asdoc pwcorr $adaptive_all adapt_index if rel==1, bonferroni star(all) save(adapt_corr.doc) replace

iebaltab $adaptive adapt_index if rel==1 , grpvar(treatment) vce(cluster final_cluster) /*balmiss(groupmean)*/ total replace save("adapt_balance.xlsx")

*****************************
* Transformative resilience *
*****************************

global transformative_all $assets hh_school prop_attend_school hh_inclusion hh_maxedu hh_totedu hh_edu_pot hh_edupotratio HHI_livelihood

global transformative tot_asset_value agri_land_pc resid_land_sqm hh_inclusion hh_edupotratio HHI_livelihood

swindex	$transformative if rel==1, gen(transf_index) displayw /*normby(control) fullrescale*/ flip (HHI_livelihood)

asdoc pwcorr $transformative_all transf_index if rel==1, bonferroni star(all) save(transf_corr.doc) replace

iebaltab $transformative transf_index if rel==1 , grpvar(treatment) vce(cluster final_cluster) /*balmiss(groupmean)*/ total replace save("transf_balance.xlsx")

save "~/Development Pathways Ltd/PHL_AFD_2024_Walang Gutom - Technical/Impact Evaluation (Assignment 1)/Data/Processed/FSP Baseline Processed_HH.dta", replace

