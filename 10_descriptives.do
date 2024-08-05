// date: 25/07/2024
// project: 1809 ADF Philippines - Assignment 1: impact evaluation 
// author: silvia
// purpose: export tables of descriptive statistics

global data_folder "~/Development Pathways Ltd/PHL_AFD_2024_Walang Gutom - Technical/Impact Evaluation (Assignment 1)/Data"

use "$data_folder/Processed/FSP Baseline Processed.dta", clear

cd "$data_folder/Tables"

* IND LEVEL

global ind_vars age10yrs ethnicity marital edu work nowork_reason work_type* sector* agri_work wage_work unfit_work bop*

foreach var of varlist $ind_vars {
	table (MUN) (`var'), statistic(percent, across(`var')) nformat(%5.1f)
	collect export "Baseline stats.xlsx", as(xlsx) sheet("IND_`var'", replace) cell(B5) modify
	putexcel set "Baseline stats.xlsx", sheet("IND_`var'") modify
	putexcel B2 = "Population composition by `var' and location",  font("calibri" , 14)
	putexcel B3 = "Source: Walang Gutom RCT Baseline ($S_DATE)",  font("calibri" , 9)
}

**# Bookmark #2
* HH LEVEL
keep if rel==1

**********************
* Modules' shortcuts *
**********************

global general cluster_size hhsize_bin sex marital ethnicity km_to_fixed_vendor

global human_capital edu hh_maxedu hh_totedu hh_eduratio work_type hh_fitadults hh_depratio hh_fitwork  hh_emprate hh_unfit_work hh_child_lab hh_n_child_lab hh_n_vul_lab

global income HHTIncome crop CROPTOT1 livestock LIVESTOCKTOT1 fishing FISHINGTOT1 foodservice FOODSERVICETOT1 wholesale WHOLESALETOT1 manufacturing MANUFACTURINGTOT1 trasportation TRANSPORTATIONTOT1 OTHERTOT1 other_* OTHERPROG1 INCOMERECEIPTS1 n_sources_alt INCOMEALLSOURCES1 hh_farm_income hh_vuln_income hh_livelihood hh_income n_sources s_hh_vuln_income s_hh_vuln_livelihood HHI_income HHI_livelihood hh_n_jobs 

* global consumption fsec_score fooddivindex pcfoodcons ...

* global assets tot_asset_value assetindex n_assets liquid_assetindex ...

global debt tot_savings tot_borrow any_debt good_source bad_source good_reason bad_reason good_debt bad_debt 

global shocks hunger hunger_freq FIES_8 FIES_24 shop_diversity n_shocks any_shock n_disaster any_disaster n_climshock any_climshock n_strategies negative_strat n_neg_strat // ... 

global socpro hh_safetynet hh_safetynet2 hh_inclusion n_programs hh_socinsur 

global services hh_treat_child hh_ill_child //...

* global resilience ...

* keep hhid pid MUN MUN tondo $general $human_capital $income $consumption $assets $debt $shocks $socpro $services $resilience

******************
* Type shortcuts *
******************

global dummy crop livestock fishing foodservice wholesale manufacturing trasportation other_* hunger hh_unfit_work hh_child_lab *_debt *_source *d_reason any_shock any_disaster any_climshock negative_strat hh_safetynet* hh_inclusion hh_socinsur hh_treat_child hh_ill_child /* consumption assets */   

global numeric cluster_size hhsize km_to_fixed_vendor hh_totedu hh_fitadults hh_depratio hh_fitwork hh_n_child_lab hh_n_vul_lab HHTIncome CROPTOT1 LIVESTOCKTOT1 FISHINGTOT1 FOODSERVICETOT1 WHOLESALETOT1 MANUFACTURINGTOT1 TRANSPORTATIONTOT1 OTHERTOT1 ENTREPRENEURIALTOT1 OTHERPROG1 INCOMERECEIPTS1 INCOMEALLSOURCES1 hh_farm_income hh_vuln_income hh_livelihood hh_income n_sources hh_n_jobs /* consumption assets */ tot_savings tot_borrow FIES_8 FIES_24 shop_diversity n_shocks n_disaster n_climshock n_strategies n_neg_strat n_programs 

global share hh_eduratio hh_emprate s_hh_vuln_income s_hh_vuln_livelihood HHI_income HHI_livelihood /* consumption assets */

global categorical hhsize_bin sex marital ethnicity edu hh_maxedu work_type hunger_freq FIES_8 shop_diversity n_shocks n_disaster n_climshock n_strategies 

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

iebaltab $general $income $assets , grpvar(tondo) /*vce(cluster location) balmiss(groupmean)*/ total replace save("Tondo_Other.xlsx")
		
reg tondo $general $income $assets , robust
outreg2 using "Tondo_Other_reg.xlsx.xls", replace

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

