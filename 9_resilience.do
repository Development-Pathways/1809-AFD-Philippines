// date: 25/07/2024
// project: 1809 ADF Philippines - Assignment 1: impact evaluation 
// author: silvia
// purpose: resilience index

* load data
cd "~/Development Pathways Ltd/PHL_AFD_2024_Walang Gutom - Technical/Impact Evaluation (Assignment 1)/Data"
use "Processed/FSP Baseline Processed.dta", clear

* tables folder
cd "~/Development Pathways Ltd/PHL_AFD_2024_Walang Gutom - Technical/Impact Evaluation (Assignment 1)/Data/Tables"

cap gen control = (treatment==0)	

************************
* Absorptive resilence *
************************

global absorptive_all asset_index* hh_treat_child hh_safetynet* n_programs share_food share_necess FIES_* shop_diversity negative_strat* n_neg_strat hh_vul_lab hh_n_child_lab hh_child_lab hh_emprate hh_work tot_savings bad_debt any_debt

global absorptive asset_index_liquid ///
		hh_treat_child ///
		hh_safetynet ///
		share_food  ///
		FIES_8 ///
		negative_strat_climate ///
		hh_vul_lab ///
		hh_emprate ///
		tot_savings ///
		bad_debt
		
swindex	$absorptive if rel==1, gen(abs_index) displayw /*normby(control) fullrescale*/ ///
	flip(share_food FIES_8 negative_strat hh_vul_lab bad_debt)

* pwcorr $absorptive abs_index if rel==1, bonferroni star(all) 
asdoc pwcorr $absorptive abs_index if rel==1, bonferroni star(all) save(abs_corr.doc) replace

iebaltab $absorptive abs_index if rel==1 , grpvar(treatment) vce(cluster final_cluster) /*balmiss(groupmean)*/ total replace save("abs_balance.xlsx")

**********************
* Adaptive resilence *
**********************

global adaptive_all n_asset_types pregnant_health has_pregnant access_info hh_socinsur negative_strat  s_hh_vuln_income s_hh_vuln_livelihood HHI_* n_sources hh_depratio hh_fitadults hh_wawork good_debt good_source

global adaptive n_asset_types pregnant_health access_info hh_socinsur negative_strat s_hh_vuln_livelihood n_sources hh_depratio good_debt

swindex	$adaptive if rel==1, gen(adapt_index) displayw /*normby(control) fullrescale*/ ///
	flip(negative_strat s_hh_vuln_livelihood hh_depratio)

asdoc pwcorr $adaptive_all adapt_index if rel==1, bonferroni star(all) save(adapt_corr.doc) replace

iebaltab $adaptive adapt_index if rel==1 , grpvar(treatment) vce(cluster final_cluster) /*balmiss(groupmean)*/ total replace save("adapt_balance.xlsx")

*****************************
* Transformative resilience *
*****************************

global transformative_all tot_asset_value asset_index asset_index_farm asset_index_total n_assets agri_land_sqm resid_land_sqm hh_school prop_attend_school hh_inclusion hh_maxedu hh_totedu hh_edu_pot hh_edupotratio HHI_livelihood

global transformative tot_asset_value agri_land_sqm resid_land_sqm prop_attend_school hh_inclusion hh_edupotratio HHI_livelihood

swindex	$transformative if rel==1, gen(transf_index) displayw /*normby(control) fullrescale*/ 

asdoc pwcorr $transformative_all transf_index if rel==1, bonferroni star(all) save(transf_corr.doc) replace

iebaltab $transformative transf_index if rel==1 , grpvar(treatment) vce(cluster final_cluster) /*balmiss(groupmean)*/ total replace save("transf_balance.xlsx")

save "~/Development Pathways Ltd/PHL_AFD_2024_Walang Gutom - Technical/Impact Evaluation (Assignment 1)/Data/Processed/FSP Baseline Processed.dta", replace
