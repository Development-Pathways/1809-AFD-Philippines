// date: 19/09/2024
// project: 1809 ADF Philippines - Assignment 1: impact evaluation 
// author: silvia
// purpose: clean data from Walang Gutom RCT endline survey, provided by ADB through AFD 
// 			process asset module

* change directory
cd "~/Development Pathways Ltd/PHL_AFD_2024_Walang Gutom - Technical/Impact Evaluation (Assignment 1)/Data"

use "Processed/FSP Endline Processed.dta", clear

*su farm_asset_* non_farm_asset_*f

// Land 

gen agri_land = (Q13_1_A1==1) 

destring Q13_1_B_1,gen(agri_land_sqm) 

gen agri_land_pc = agri_land_sqm/hhsize
replace agri_land_pc = 0 if agri_land_sqm==0

gen resid_land = (Q13_1_A2==1) 

destring Q13_1_B_2,gen(resid_land_sqm) 

destring Q13_2_C_* Q13_3_C_* , replace

// Farm assets

egen n_f_assets = rowtotal(farm_asset_1-farm_asset_5) 

forvalues i = 1/5 {
	
	replace Q13_2_A_`i' = . if Q13_2_A_`i'== 99
	replace Q13_2_C_`i' = . if Q13_2_C_`i'>= 999998 
	
	*average price for each asset (hh level)
	gen price_f`i' = Q13_2_C_`i' / Q13_2_A_`i' // price/number
	
	*average price for each asset (municipality level)
	egen avg_price_f`i' = mean(price_f`i'), by(MUN)
	
	* value of assets
	gen value_f`i' = avg_price_f`i' * Q13_2_A_`i'
}

egen value_f_asset = rowtotal(value_f*)

// Non-farm assets

* shop/commercial structure
rename Q13_3_A_1 n_shops_owned // rename to exclude shop/commercial structure from asset index

destring Q13_3_D, gen(value_shop)
replace value_shop=. if value_shop>=999998 

	* average price of shop/commercial structure
	gen price_shop = value_shop / n_shops_owned 
	egen avg_price_shop = mean(price_shop), by(MUN)

* other assets
egen n_assets = rowtotal(non_farm_asset_2-non_farm_asset_12) 

forvalues i = 2/12 { 
    
	replace Q13_3_C_`i' = . if Q13_3_C_`i' >= 999998
	
	*average price for each asset (hh level)
	gen price_`i' = Q13_3_C_`i' / Q13_3_A_`i' // price/number
	
	*average price for each asset (municipality level)
	egen avg_price_`i' = mean(price_`i'), by(MUN)
		
	* value using average price
	gen value_`i' = Q13_3_A_`i' * avg_price_`i'
	
	* has at least one 
	gen has_asset_`i' = Q13_3_A_`i'>0 & !missing(Q13_3_A_`i')
	
	
	*Liquid assets - ownership of excess (>1) assets weighted by relative asset value
	
	gen extra_asset_`i' = Q13_3_A_`i'-1
	replace extra_asset_`i' = 0 if extra_asset_`i'<0
	
	gen value_e`i' = extra_asset_`i' * avg_price_`i'
}

egen n_extra_assets = rowtotal(extra_asset_*) 

egen value_nf_asset = rowtotal(value_2-value_12)

egen value_extra_asset = rowtotal(value_e*)

egen n_asset_types = rowtotal(has_asset_*) // 1 point per asset type (non-farm)

egen value_assets = rowtotal(value_f_asset value_shop value_nf_asset)

*Access to information (Dummy if has phone, radio, tv)
gen access_info = (non_farm_asset_2>0 | non_farm_asset_3>0 | non_farm_asset_4>0)
label variable access_info "Access to info (radio, tv, phone)"

save "Processed/FSP Endline Processed.dta", replace
