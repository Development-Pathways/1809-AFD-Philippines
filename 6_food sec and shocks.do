// date: 25/07/2024
// project: 1809 ADF Philippines - Assignment 1: impact evaluation 
// author: silvia
// purpose: clean data from Walang Gutom RCT baseline survey, provided by ADB through AFD

* change directory
cd "~/Development Pathways Ltd/PHL_AFD_2024_Walang Gutom - Technical/Impact Evaluation (Assignment 1)/Data"

use "Processed/FSP Baseline Processed.dta", clear

* food security (module 7)

recode Q7_1_A (1=1 "Yes") (2=0 "No"), gen(hunger) // past 3 months
rename Q7_1_B hunger_freq // frequency in past 3 months
* Q7_2A* = food security (module 7)

*** Food Insecurity Experience Scale *

forval n = 1/8 {
	replace Q7_2A`n' = Q7_2A`n' - 1 
	replace Q7_2A`n' = . if Q7_2A`n' > 3 
	recode Q7_2A`n' 0=0 1/3=1, gen(fies_`n')
}

egen FIES_24 = rowtotal (Q7_2A*)

egen FIES_8 = rowtotal(fies_*)

* food sources / where food is bought 

forval n = 1/7 { // types of places to buy food
	gen shop_`n' = (Q10_4_3_1 ==`n' | Q10_4_3_2 ==`n' | Q10_4_3_3 ==`n' | Q10_4_3_4 ==`n' | Q10_4_3_5 ==`n' | Q10_4_3_6 ==`n' | Q10_4_3_7 ==`n' | Q10_4_3_8 ==`n' | Q10_4_3_9 ==`n') // types of food
}

* 0-7 index
egen shop_diversity = rowtotal(shop_*)

**************************************
		*** shocks ***
**************************************

forval i = 1/28 {
	recode Q16_`i'A 1=1 2=0
}

	* check incidence of shocks
	tab MUN Q16_1A if rel==1, row
	mean Q16_1A if rel==1, over(MUN)

egen n_shocks = rowtotal(Q16_*A)
gen any_shock = n_shocks>0 & !missing(n_shocks)

* disasters (0-7)

egen n_disaster = rowtotal(Q16_1A Q16_2A Q16_3A Q16_4A Q16_5A Q16_6A Q16_7A)
gen any_disaster = n_disaster>0 & !missing(n_disaster)

* climate-related shocks (0-6): typhoon, flooding, landslide, drought, fire, crop pest/disease

egen n_climshock = rowtotal(Q16_2A Q16_3A Q16_5A Q16_6A Q16_7A Q16_8A)
gen any_climshock = n_climshock>0 & !missing(n_climshock)

* coping strategies

forval j = 1/28 {								// shocks
	forval i = 1/23 {							// strategies
		gen shock`j'strat`i' = (Q16_`j'D ==`i')	// dummies
		
	}
}

	forval i = 1/23 {							// strategies
		egen strategy`i' = rowmax(shock*strat`i')
		egen n_strat`i' = rowtotal(shock*strat`i')
	}


egen n_strategies = rowtotal(strategy*)

* negative strategies: Sold land, sold productive asset, ate less food to reduce expenses, ate lower quality food to reduce expenses, took children out of school, sent household member away permanently, sent children to be fostered by relatives, sent children into domestic service, sent children to work somewhere other than domestic service
egen negative_strat = rowmax(strategy2 strategy4 strategy9 strategy10 strategy11 strategy14 strategy15 strategy16 strategy17) if any_shock==1
egen n_neg_strat = rowtotal(n_strat2 n_strat4 n_strat9 n_strat10 n_strat11 n_strat1 n_strat15 n_strat16 n_strat17) if any_shock==1

	* climate shocks only 

	forval i = 1/23 {							// strategies
		egen cl_strategy`i' = rowmax(shock2strat`i' shock3strat`i' shock5strat`i' shock6strat`i' shock7strat`i' shock8strat`i')
	}

	egen negative_strat_climate = rowmax(cl_strategy2 cl_strategy4 cl_strategy9 cl_strategy10 cl_strategy11 cl_strategy14 cl_strategy15 cl_strategy16 cl_strategy17) if any_climshock==1
	
	
* br hhid Q16_*D strategy* n_strat* if rel==1 & n_shocks>1

save "Processed/FSP Baseline Processed.dta", replace
