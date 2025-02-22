// date: 19/09/2024
// project: 1809 ADF Philippines - Assignment 1: impact evaluation 
// author: silvia
// purpose: clean data from Walang Gutom RCT endline survey, provided by ADB through AFD

* change directory
cd "~/Development Pathways Ltd/PHL_AFD_2024_Walang Gutom - Technical/Impact Evaluation (Assignment 1)/Data"

use "Processed/FSP Endline Processed.dta", clear

* food security (module 7)

	* any_hunger_3mo

*** Food Insecurity Experience Scale *

rename fies_raw FIES_8

/* food sources / where food is bought 

forval n = 1/7 { // types of places to buy food
	gen shop_`n' = (Q10_4_3_1 ==`n' | Q10_4_3_2 ==`n' | Q10_4_3_3 ==`n' | Q10_4_3_4 ==`n' | Q10_4_3_5 ==`n' | Q10_4_3_6 ==`n' | Q10_4_3_7 ==`n' | Q10_4_3_8 ==`n' | Q10_4_3_9 ==`n') // types of food
}

* 0-7 index
egen shop_diversity = rowtotal(shop_*)

*/

**************************************
		*** shocks ***
**************************************

forval i = 1/28 {
	recode Q16_A`i' 1=1 2=0
	rename Q16_A`i' Q16_`i'A
}

destring Q16_D_* Q16_C_* , replace

* month of last shock 

forval i = 1/28 {
	gen month_`i' = monthly(Q16_B_`i', "MY")
}
format month_* %tm

*** shock between baseline and endline (november 23 - july 24)

/*
forval i = 1/28 {
	clonevar recent_shock_`i' = shock_`i'
	replace recent_shock_`i' = 0 if (Q16_B_`i'>=8 & Q16_B_`i'<=11)
}
*/

** shock in the previous 6 months (since Feb 2024)

forval i = 1/28 {
	clonevar recent_shock_`i' = shock_`i'
	replace recent_shock_`i' = 0 if month_`i'<tm(2024m2) 
}

egen n_shocks = rowtotal(Q16_*A)
gen any_shock = n_shocks>0 & !missing(n_shocks)

* climate-related shocks (0-6): typhoon, flooding, landslide, drought, fire, crop pest/disease

egen n_climshock = rowtotal(shock_2 shock_3 shock_5 shock_6 shock_7 shock_8)
gen any_climshock = n_climshock>0 & !missing(n_climshock)

egen n_r_climshock = rowtotal(recent_shock_2 recent_shock_3 recent_shock_5 recent_shock_6 recent_shock_7 recent_shock_8)

gen any_r_climshock = n_r_climshock>0 & !missing(n_r_climshock)

* coping strategies

forval j = 1/28 {								// shocks
	forval i = 1/23 {							// strategies
		gen shock`j'strat`i' = (Q16_D_`j' ==`i')	// dummies
		
	}
}

	forval i = 1/23 {							// strategies
		egen strategy`i' = rowmax(shock*strat`i')
		egen n_strat`i' = rowtotal(shock*strat`i')
	}


egen n_strategies = rowtotal(strategy*)

* negative strategies: Sold land, sold productive asset, ate less food to reduce expenses, ate lower quality food to reduce expenses, took children out of school, sent household member away permanently, sent children to be fostered by relatives, sent children into domestic service, sent children to work somewhere other than domestic service
egen negative_strat = rowmax(strategy2 strategy4 strategy9 strategy10 strategy11 strategy14 strategy15 strategy16 strategy17) if any_shock==1 //<-- only for those who had shocks
egen n_neg_strat = rowtotal(n_strat2 n_strat4 n_strat9 n_strat10 n_strat11 n_strat1 n_strat15 n_strat16 n_strat17) if any_shock==1

	* climate shocks only 

	forval i = 1/23 {							// strategies
		egen cl_strategy`i' = rowmax(shock2strat`i' shock3strat`i' shock5strat`i' shock6strat`i' shock7strat`i' shock8strat`i')
	}

	egen negative_strat_climate = rowmax(cl_strategy2 cl_strategy4 cl_strategy9 cl_strategy10 cl_strategy11 cl_strategy14 cl_strategy15 cl_strategy16 cl_strategy17) if any_r_climshock==1	
	
* negative strategies used in the past 6 months

/*
br shock_2 month_2 Q16_D_2	/// 
shock_3 month_3 Q16_D_3		///
shock_5 month_5 Q16_D_5		///
shock_6 month_6 Q16_D_6		///
shock_7 month_7 Q16_D_7		///
shock_8 month_8 Q16_D_8 if any_climshock==1 
*/

foreach n of numlist 2 4 9 10 11 14 15 16 17 {
	gen Rcl_strategy`n' =	(Q16_D_2==`n' & month_2<tm(2024m2)) | ///
							(Q16_D_3==`n' & month_3<tm(2024m2)) | ///
							(Q16_D_5==`n' & month_5<tm(2024m2)) | ///
							(Q16_D_6==`n' & month_6<tm(2024m2)) | ///
							(Q16_D_7==`n' & month_7<tm(2024m2)) | ///
							(Q16_D_8==`n' & month_8<tm(2024m2))
}
	egen Rnegative_strat_climate = rowmax(Rcl_strategy2 Rcl_strategy4 Rcl_strategy9 Rcl_strategy10 Rcl_strategy11 Rcl_strategy14 Rcl_strategy15 Rcl_strategy16 Rcl_strategy17) if any_climshock==1	

	tab Q16_D_2 if MUN==138060 & month_2==tm(2024m7) // typhoon strategies in tondo if month of typhoon was july
	gen strat_gaemi = Q16_D_2 if MUN==138060 & month_2==tm(2024m7)
	gen negative_strat_gaemi =	Q16_D_2==2 | Q16_D_2==4  | Q16_D_2==9  | ///
								Q16_D_2==10  | Q16_D_2==11  | Q16_D_2==14 | ///
								Q16_D_2==15  | Q16_D_2==16  | Q16_D_2==17 if MUN==138060 & month_2==tm(2024m7) 
	
	
	
* outcome of the shock 

gen loss_assets = 0 if any_climshock==1	
gen loss_income = 0 if any_climshock==1	
gen loss_consum = 0 if any_climshock==1	

forval j = 1/28 {								// shocks
	forval i = 1/4 {							// outcomes
replace loss_assets = 1 if Q16_C_`j'_O`i'==1
replace loss_income = 1 if Q16_C_`j'_O`i'==2
replace loss_consum = 1 if Q16_C_`j'_O`i'==3
	}
}

gen loss_assets_cl = 0 if any_climshock==1	
gen loss_income_cl = 0 if any_climshock==1	
gen loss_consum_cl = 0 if any_climshock==1	

foreach j of numlist 2 3 5 6 7 8  {				// climate shocks
	forval i = 1/4 {							// outcomes
replace loss_assets_cl = 1 if Q16_C_`j'_O`i'==1
replace loss_income_cl = 1 if Q16_C_`j'_O`i'==2
replace loss_consum_cl = 1 if Q16_C_`j'_O`i'==3
	}
}

egen loss_incomeassets_cl = rowmax(loss_assets_cl loss_income_cl)
*egen loss_any = rowmax(loss_assets loss_income loss_consumption) 

gen hh_adapted = (loss_incomeassets_cl==1 & negative_strat_climate==0) // experienced climate shock with loss of income and/or assets but did not resort to negative strategies

gen no_negative_strat_climate = 1 - negative_strat_climate

gen no_negative_strat = (loss_assets==1 | loss_income==1 | loss_consum==1) & (negative_strat==0)


/*
foreach j of numlist 2 3 5 6 7 8  {								// climate shocks
	gen shock`j'_loss_asset = (Q16_`j'C1==1 | Q16_`j'C2==1 | Q16_`j'C3==1 | Q16_`j'C4==1)
	gen shock`j'_loss_income = (Q16_`j'C1==2 | Q16_`j'C2==2 | Q16_`j'C3==2 | Q16_`j'C4==2)
	gen shock`j'_loss_consumption = (Q16_`j'C1==3 | Q16_`j'C2==3 | Q16_`j'C3==3 | Q16_`j'C4==3)
}
su shock*_loss* if rel==1 & any_shock==1

*/

drop shock*strat*

**************************************
	*** subjective resilience ***
**************************************

forval i = 1/4 {
	recode resilience_climate_`i' (1/2=1 "Will cope") (3=0 "DK") (4/5=-1 "Will not cope"), gen(subj_res3v_`i')
	recode resilience_climate_`i' (1/2=1 "Confident will cope") (3/5=0 "Not confident"), gen(subj_res2v_`i')
}

egen subj_res_score = rowtotal(resilience_climate_*) 
replace subj_res_score = . if subj_res_score==0

gen subj_res_score_2 = (subj_res_score<=10)
label define res_score 0 "Low resilience" 1 "High resilience"
label values subj_res_score_2 res_score

	
* br hhid Q16_*D strategy* n_strat* if rel==1 & n_shocks>1

save "~/Development Pathways Ltd/PHL_AFD_2024_Walang Gutom - Technical/Impact Evaluation (Assignment 1)/Data/Processed/FSP Endline Processed.dta", replace
