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

* normalised asset value (square root transformation)
gen sqrt_asset_value = sqrt(tot_asset_value)
su sqrt_asset_value
gen z_asset_value = (sqrt_asset_value-r(mean))/r(sd)

// Land 

gen agri_land = (q13_1_a1==1) if !missing(q13_1_a1)
gen agri_land_sqm = q13_1_b1 if (q13_1_b1!=999998|q13_1_b1!=999999)
gen agri_land_pc = agri_land_sqm/hhsize
replace agri_land_pc = 0 if agri_land_sqm==0

gen resid_land = (q13_1_a2==1) if !missing(q13_1_a2)
gen resid_land_sqm = q13_1_b2 if (q13_1_b2!=999998|q13_1_b2!=999999)

// Farm assets

forvalues i = 1/5 {
	
	replace q13_2_a`i' = . if (q13_2_a`i'== 8 | q13_2_a`i'== 98 | q13_2_a`i'== 99)
	replace q13_2_c`i' = . if q13_2_c`i'== 999998 | q13_2_c`i'== 999999
	
	winsor2 q13_2_a`i', cuts(0 99)
	
	*average price for each asset (hh level)
	gen price_f`i' = q13_2_c`i' / q13_2_a`i'_w // price/number
*	replace price_f`i' = 0 if q13_2_a`i'==0
	winsor2 price_f`i', cuts(0 99)

	*average price for each asset (municipality level)
	egen avg_price_f`i' = mean(price_f`i'_w), by(MUN)
}

egen n_f_assets = rowtotal(q13_2_a*) 

egen value_f_asset_set = rowtotal(avg_price_f*) // total value of having one of each asset 

forvalues i = 1/5 { 
	
	*relative value (weight) of each asset type
	gen wg_asset_f`i' = avg_price_f`i' / value_f_asset_set
	
	*weighted ownership of each asset by its relative value
	gen weighted_af`i' = q13_2_a`i' * wg_asset_f`i'	

	* value of assets
	gen value_f`i' = avg_price_f`i' * q13_2_a`i'
}

egen value_f_asset = rowtotal(value_f*)

// Non-farm assets

* shop/commercial structure
rename Q13_3A1 n_shops_owned // rename to exclude shop/commercial structure from asset index
rename Q13_3D1 value_shop

	* average price of shop/commercial structure
	gen price_shop = value_shop / n_shops_owned 
	egen avg_price_shop = mean(price_shop), by(MUN)

* other assets
egen n_assets = rowtotal(Q13_3A*) 

forvalues i = 2/12 { 
    
	replace Q13_3C`i' = . if Q13_3C`i' == 999998
	
	winsor2 Q13_3A`i', cuts(0 99)
	
	*average price for each asset (hh level)
	gen price_`i' = Q13_3C`i' / Q13_3A`i'_w // price/number
*	replace price_`i' = 0 if Q13_3A`i'==0
	winsor2 price_`i', cuts(0 99)

	*average price for each asset (municipality level)
	egen avg_price_`i' = mean(price_`i'_w), by(MUN)
		
	* value using average price
	gen value_`i' = Q13_3A`i' * avg_price_`i'
	
	* has at least one 
	gen has_asset_`i' = Q13_3A`i'>0 & !missing(Q13_3A`i')
}

egen value_asset_set = rowtotal(avg_price*) // total value of having one of each asset 

forvalues i = 2/12 { 
	
	*relative value (weight) of each asset type
	gen wg_asset_`i' = avg_price_`i' / value_asset_set
	
	*weighted ownership of each asset by its relative value 
	gen weighted_a`i' = Q13_3A`i' * wg_asset_`i'	
	
				****
				
	*Liquid assets - ownership of excess (>1) assets weighted by relative asset value
	
	gen extra_asset_`i' = Q13_3A`i'_w-1
	replace extra_asset_`i' = 0 if extra_asset_`i'<0
	
	gen weighted_extra`i' = extra_asset_`i' * wg_asset_`i'

	gen value_e`i' = extra_asset_`i' * avg_price_`i'
}
 
egen n_extra_assets = rowtotal(extra_asset_*) 

egen value_asset = rowtotal(value_2-value_12)

egen value_extra_asset = rowtotal(value_e*)

* looking at all assets 
egen value_full_asset_set = rowtotal(avg_price_*) // total value of having one of each asset

*relative value  of each asset type
foreach p of varlist avg_price_* {
	gen wg_`p' = `p' / value_full_asset_set
}	
*weighted ownership of each asset by its relative value 
//	gen weighted_full_agri_land = wg_avg_price_agri_land*agri_land_sqm
//	gen weighted_full_res_land = wg_avg_price_res_land*resid_land_sqm
	forvalues i = 1/5 { 
		gen weighted_full_f`i'= wg_avg_price_f`i'* q13_2_a`i'
	}
	gen weighted_full_shop = wg_avg_price_shop * n_shops_owned
	forvalues i = 2/12 { 
		gen weighted_full_`i'= wg_avg_price_`i'* Q13_3A`i'
	}
*/
	

egen n_asset_types = rowtotal(has_asset_*) // 1 point per asset type (non-farm)

 egen asset_index_farm = rowtotal(weighted_af*) // only farm

 egen asset_index = rowtotal(weighted_a*) // only non-farm (excl. shop)

 egen asset_index_liquid = rowtotal(weighted_extra*) // only extra non-farm (excl. shop)

 egen asset_index_total = rowtotal(weighted_full_*) // farm assets + shops + other assets 


// PCA Asset index 

* non-farm
pca Q13_3A*
predict assetindex_pca_nf, score

* all 

foreach var of varlist agri_land_sqm resid_land_sqm q13_2_a* {
	replace `var' = 0 if missing(`var')
}

pca agri_land_sqm resid_land_sqm q13_2_a* n_shops_owned Q13_3A*
predict assetindex_pca

hist assetindex_pca

drop wg* weighted* *price*

save "Processed/FSP Baseline Processed.dta", replace
