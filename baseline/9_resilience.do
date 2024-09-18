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
keep if rel==1
	
************************
* Absorptive resilence *
************************

swindex	hh_bop has_savings value_extra_asset FIES_8 share_food hh_network negative_strat_climate n_safetynet hh_healthins  health_access , gen(abs_index_A) displayw /*normby(control) fullrescale*/ flip(FIES_8 share_food negative_strat_climate )

pca hh_bop has_savings value_extra_asset FIES_8 share_food hh_network negative_strat_climate n_safetynet hh_healthins  health_access 
predict abs_index_pca_A, score
	
swindex	hh_bop has_savings value_extra_asset FIES_8 share_food hh_network negative_strat_climate, gen(abs_index_B) displayw /*normby(control) fullrescale*/ flip(FIES_8 share_food)

pca hh_bop has_savings value_extra_asset FIES_8 share_food hh_network negative_strat_climate 
predict abs_index_pca_B, score

swindex	hh_bop has_savings value_extra_asset FIES_8 share_food hh_network, gen(abs_index_C) displayw /*normby(control) fullrescale*/ flip(FIES_8 share_food negative_strat_climate )

pca hh_bop has_savings value_extra_asset FIES_8 share_food hh_network
predict abs_index_pca_C, score

*correlation matrix	
asdoc pwcorr hh_bop has_savings value_extra_asset FIES_8 share_food hh_network negative_strat_climate n_safetynet hh_healthins  health_access , bonferroni star(all) save(abs_corr_3A.doc) replace

**********************
* Adaptive resilence *
**********************

swindex	n_sources n_asset_types access_info good_debt no_negative_strat_climate crop_lives_fish hh_inclusion hh_socinsur hh_emprate , gen(adapt_index_A) displayw /*normby(control) fullrescale*/ flip(crop_lives_fish )

pca n_sources n_asset_types access_info good_debt no_negative_strat_climate crop_lives_fish hh_inclusion hh_socinsur hh_emprate
predict adapt_index_pca_A, score

swindex	n_sources n_asset_types access_info good_debt no_negative_strat_climate, gen(adapt_index_B) displayw /*normby(control) fullrescale*/

pca n_sources n_asset_types access_info good_debt no_negative_strat_climate
predict adapt_index_pca_B, score

swindex	n_sources n_asset_types access_info good_debt, gen(adapt_index_C) displayw /*normby(control) fullrescale*/

pca n_sources n_asset_types access_info good_debt 
predict adapt_index_pca_C, score
	
*correlation matrix	
asdoc pwcorr n_sources crop_lives_fish n_asset_types access_info good_debt no_negative_strat_climate hh_inclusion hh_socinsur hh_emprate , bonferroni star(all) save(adapt_corr_2A.doc) replace

*****************************
* Transformative resilience *
*****************************

swindex	exp_edu_pchild age_appr_edu_ratio , gen(transf_index_2) displayw /*normby(control) fullrescale*/

pca exp_edu_pchild age_appr_edu_ratio 
predict transf_index_pca_2, score

*correlation matrix	
asdoc pwcorr exp_edu_pchild age_appr_edu_ratio , bonferroni star(all) save(transf_corr_2.doc) replace

*** balance ***

global index_comp hh_bop has_savings value_extra_asset FIES_8 share_food hh_network negative_strat_climate n_safetynet hh_healthins  health_access ///
n_sources crop_lives_fish n_asset_types access_info good_debt no_negative_strat_climate hh_inclusion hh_socinsur hh_emprate ///
exp_edu_pchild age_appr_edu_ratio 

iebaltab $index_comp *_index* , grpvar(treatment) vce(cluster final_cluster) /*balmiss(groupmean)*/ total replace save("index_balance.xlsx")

save "~/Development Pathways Ltd/PHL_AFD_2024_Walang Gutom - Technical/Impact Evaluation (Assignment 1)/Data/Processed/FSP Baseline Processed_HH.dta", replace

// summary of index components

cd "~/Development Pathways Ltd/PHL_AFD_2024_Walang Gutom - Technical/Impact Evaluation (Assignment 1)/Data/Tables"

global general hhsize has_child05 has_child017 hh_skipgen hh_singlepar hh_depratio ///
hh_ill_child has_pregnant health_access ///
hh_totedu prop_attend_s* hh_emprate hh_child_lab hh_n_jobs  ///
crop livestock fishing foodservice wholesale manufacturing trasportation other_activ other_sources ///
hh_farming hh_foodservice hh_wholesale hh_manufacturing hh_transportation hh_other_activ ///
HHTIncome HHTIncome_pc CROPTOT1 LIVESTOCKTOT1 FISHINGTOT1 FOODSERVICETOT1 WHOLESALETOT1 MANUFACTURINGTOT1 TRANSPORTATIONTOT1 OTHERTOT1 ENTREPRENEURIALTOT1_pc OTHERPROG1 INCOMERECEIPTS1 INCOMEALLSOURCES1 INCOMEALLSOURCES1_pc /// 12 months
n_sources ///
TOTALCONSUMPTION food_consumption_pc total_consumption_pc share_food exp_edu ///
tot_asset_value agri_land resid_land n_shops_owned n_f_assets value_f_asset n_assets value_asset n_asset_types n_extra_assets value_extra_asset assetindex_pca ///
tot_savings tot_borrow any_debt bad_source bad_reason bad_debt good_debt ///
hunger FIES_24 shop_diversity n_climshock any_climshock ///
loss_assets_cl loss_income_cl loss_consum_cl hh_adapted ///
prog_* n_prog 

eststo clear
bysort MUN: eststo: quietly estpost sum  $index_comp *_index* $general 
eststo: quietly estpost sum $index_comp *_index* $general 
esttab using "summary_components_1709.csv", cells("count mean sd min max") replace


