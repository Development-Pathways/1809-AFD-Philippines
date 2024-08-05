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
rename Q13_3A1 n_shops_owned // rename to exclude shop/commercial structure
egen n_assets = rowtotal(Q13_3A*) 
* recode temp (17/max = 17 "17+"), gen(n_assets)

forvalues i = 2/12 { 
    
	replace Q13_3C`i' = . if Q13_3C`i' == 999998
	
	*average price for each asset (hh level)
	gen price_`i' = Q13_3C`i' / Q13_3A`i' // price/number
	
		*average price for each asset (municipality level)
		egen avg_price_`i' = mean(price_`i'), by(MUN)
}

egen value_asset_set = rowtotal(avg_price*) // total value of having one of each asset 

forvalues i = 2/12 { 
	
	*relative value (weight) of each asset type
	gen wg_asset_`i' = avg_price_`i' / value_asset_set
	
	*weighted ownership of each asset by its relative value
	gen weighted_a`i' = Q13_3A`i' * wg_asset_`i'	
	
				****
				
	*Liquid assets - ownership of excess (>1) assets weighted by relative asset value
	
	gen extra_asset_`i' = Q13_3A`i'-1
	replace extra_asset_`i' = 0 if extra_asset_`i'<0
	
	gen weighted_extra`i' = extra_asset_`i' * wg_asset_`i'
	
}

// Simple asset index 

egen asset_index = rowtotal(weighted_a*)
egen asset_index_liquid = rowtotal(weighted_extra*)

// PCA Asset index (ownership of non-farm assets weighted by relative asset value)

* based on number of assets
pca Q13_3A*
predict assetindex_0, score

* based on total value of assets (will have missings) <-- doesn't even work
pca Q13_3C* // includes Q13_3C1 
predict assetindex_1, score

* based on relative value of assets (only 4,917 obs - why?)
pca weighted_a*
predict assetindex_2, score

/*

forvalues i = 1/`max_assets' {
	gen asset_`i'_=0
	replace asset_`i'_=1 if weighted_asset_`i'>0 // ????
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

*/

save "Processed/FSP Baseline Processed.dta", replace
