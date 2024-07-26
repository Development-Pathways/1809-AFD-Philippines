// date: 24/07/2024
// project: 1809 ADF Philippines - Assignment 1: impact evaluation 
// author: nayha
// purpose: clean data from Walang Gutom RCT baseline survey, provided by ADB through AFD 
// 			process asset module

* change directory
cd "~/Development Pathways Ltd/PHL_AFD_2024_Walang Gutom - Technical/Impact Evaluation (Assignment 1)/Data"

use "Processed/FSP Baseline Processed.dta", clear

//Value of assets
rename Q13_3C12V tot_asset_value

//Number of non-farm assets
egen temp = rowtotal(Q13_3A*)
recode temp (17/max = 17 "17+"), gen(n_assets)

local max_assets = 12 

forvalues i = 1/`max_assets' {
    
	*average price for each asset
	gen avg_price_`i' = Q13_3C`i' / Q13_3A`i'
	replace avg_price_`i' = . if Q13_3C`i' == 999998
	

	*relative value of each asset type
	gen rel_value_asset_`i'=.
	replace rel_value_asset_`i' = avg_price_`i' / tot_asset_value
	
	*weighted ownership of each asset by its relative value
	gen weighted_asset_`i'=Q13_3A`i' * rel_value_asset_`i'	
	replace weighted_asset_`i'=Q13_3A`i' if weighted_asset_`i' == .							//check if this is correct
	
	*Liquid assets - ownership of excess (>1) assets weighted by relative asset value
	gen weighted_excess_own_`i' = rel_value_asset_`i'
    replace weighted_excess_own_`i' = 0 if Q13_3A`i' <= 1
		
}

//Asset index (ownership of non-farm assets weighted by relative asset value)

forvalues i = 1/`max_assets' {
	gen asset_`i'_=0
	replace asset_`i'_=1 if weighted_asset_`i'>0
	}	

pca asset_2_ asset_3_ asset_4_ asset_5_ asset_6_ asset_7_ asset_8_ asset_9_ asset_10_ asset_11_ asset_12_
predict assetindex, score
label variable assetindex "Asset index (PCA)"


//Productive assets
**Agriculture assets not included in baseline data

// Liquid assets index
forvalues i = 1/`max_assets' {
	gen liquid_asset_`i'_=0
	replace liquid_asset_`i'_=1 if weighted_excess_own_`i'>=2
	}	

pca liquid_asset_2_ liquid_asset_3_ liquid_asset_4_ liquid_asset_5_ liquid_asset_6_ liquid_asset_7_ liquid_asset_8_ liquid_asset_9_ liquid_asset_10_ liquid_asset_11_ liquid_asset_12_
predict liquid_assetindex, score
label variable liquid_assetindex "Liquid asset index (PCA)"

save "Processed/FSP Baseline Processed.dta", replace
