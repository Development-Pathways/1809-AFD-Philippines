// date: 25/07/2024
// project: 1809 ADF Philippines - Assignment 1: impact evaluation 
// author: silvia
// purpose: resilience index

* change directory
cd "~/Development Pathways Ltd/PHL_AFD_2024_Walang Gutom - Technical/Impact Evaluation (Assignment 1)/Data"

use "Processed/FSP Baseline Processed.dta", clear

gen control = (treatment==0)	

* Absorptive resilence

global absorptive asset_index_liquid ///
		hh_treat_child ///
		hh_safetynet /*hh_safetynet2*/ ///
		share_food /*share_necess*/ ///
		FIES_8 /*FIES_24 shop_diversity */ ///
		negative_strat /*n_neg_strat*/ ///
		hh_vul_lab /*hh_n_child_lab hh_child_lab*/ ///
		hh_emprate /*hh_work*/ ///
		tot_savings ///
		bad_debt /*any_debt*/ 

swindex	$absorptive if rel==1, gen(abs_index) displayw normby(control) fullrescale ///
	flip(share_food FIES_8 negative_strat hh_vul_lab bad_debt)

* pwcorr $absorptive abs_index if rel==1, bonferroni star(all) 
asdoc pwcorr $absorptive abs_index if rel==1, bonferroni star(all) save(correlation.doc) replace

	
save "Processed/FSP Baseline Processed.dta", replace
