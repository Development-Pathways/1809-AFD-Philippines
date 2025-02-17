

import excel "~/Development Pathways Ltd/PHL_AFD_2024_Walang Gutom - Technical/Exploratory analysis of ASP (Assignment 2)/Data/fies2023.xlsx", sheet("povline") cellrange(F2:H89) firstrow clear

tempfile povline
save `povline'

import delimited "~/Development Pathways Ltd/SEA - Data/philippines/FIES 2023/FIES PUF 2023 Volume1.csv", case(preserve) clear

merge m:1 W_PROV using `povline', nogen

	gen totex = TOTEX/12 // yearly to monthly
	gen totinc = TOINC/12
	gen totfood = FOOD/12
	gen totnonfood = NFOOD/12
	
	gen totfood_week = FOOD/365*7 // yearly to weekly
	
foreach var of varlist totex totinc totfood totnonfood {
	gen `var'_pc = `var'/FSIZE
}

	xtile decile_exp = totex_pc [aw=RFACT], n(10)
	xtile decile_inc = totex_pc [aw=RFACT], n(10)
	xtile decile_food = totfood_pc [aw=RFACT], n(10)
{
gen NCR12 = (W_PROV==39|W_PROV==74)
gen cotabato_barmm = (W_REGN==15 & W_PROV==47)

gen WG = 0 

_pctile totex_pc if NCR12 == 1	[iw=RFACT], p(	0.04	)
replace WG = totex_pc < r(r1) if NCR12 == 1

_pctile totex_pc if W_PROV==	31	[iw=RFACT], p(	0.73	)
replace WG = totex_pc < r(r1) if W_PROV==31

_pctile totex_pc if W_PROV==	17	[iw=RFACT], p(	5.41	)
replace WG = totex_pc < r(r1) if W_PROV==17

_pctile totex_pc if W_PROV==	62	[iw=RFACT], p(	3.18	)
replace WG = totex_pc < r(r1) if W_PROV==62

_pctile totex_pc if W_PROV==	45	[iw=RFACT], p(	6.74	)
replace WG = totex_pc < r(r1) if W_PROV==45

_pctile totex_pc if W_PROV==	22	[iw=RFACT], p(	1.27	)
replace WG = totex_pc < r(r1) if W_PROV==22

_pctile totex_pc if W_PROV==	46	[iw=RFACT], p(	6.2	)
replace WG = totex_pc < r(r1) if W_PROV==46

_pctile totex_pc if W_PROV==	26	[iw=RFACT], p(	6.58	)
replace WG = totex_pc < r(r1) if W_PROV==26

_pctile totex_pc if W_PROV==	37	[iw=RFACT], p(	5.26	)
replace WG = totex_pc < r(r1) if W_PROV==37

_pctile totex_pc if W_PROV==	48	[iw=RFACT], p(	3.63	)
replace WG = totex_pc < r(r1) if W_PROV==48

_pctile totex_pc if W_PROV==	60	[iw=RFACT], p(	6.74	)
replace WG = totex_pc < r(r1) if W_PROV==60

_pctile totex_pc if W_PROV==	72	[iw=RFACT], p(	10.27	)
replace WG = totex_pc < r(r1) if W_PROV==72

_pctile totex_pc if W_PROV==	83	[iw=RFACT], p(	9.63	)
replace WG = totex_pc < r(r1) if W_PROV==83

_pctile totex_pc if W_PROV==	13	[iw=RFACT], p(	1.86	)
replace WG = totex_pc < r(r1) if W_PROV==13

_pctile totex_pc if W_PROV==	35	[iw=RFACT], p(	1.62	)
replace WG = totex_pc < r(r1) if W_PROV==35

_pctile totex_pc if W_PROV==	67	[iw=RFACT], p(	1.08	)
replace WG = totex_pc < r(r1) if W_PROV==67

_pctile totex_pc if W_PROV==	7	[iw=RFACT], p(	31.54	)
replace WG = totex_pc < r(r1) if W_PROV==7

_pctile totex_pc if W_PROV==	66	[iw=RFACT], p(	11.68	)
replace WG = totex_pc < r(r1) if W_PROV==66

_pctile totex_pc if W_PROV==	70	[iw=RFACT], p(	9.02	)
replace WG = totex_pc < r(r1) if W_PROV==70

_pctile totex_pc if cotabato_barmm==1 		[iw=RFACT], p(	5.3	)
replace WG = totex_pc < r(r1) if cotabato_barmm==1

_pctile totex_pc if W_PROV==	38	[iw=RFACT], p(	13.58	)
replace WG = totex_pc < r(r1) if W_PROV==38

egen WG_PROV = max(WG), by(W_PROV)
egen WG_REGN = max(WG), by(W_REGN)

tab W_PROV WG if WG_PROV==1 [aw=RFACT], row nofreq
}
	* share of food 
		
	gen share_FOOD = FOOD/TOTEX
	mean share_FOOD [aw=RFACT], over(WG)
	
gen cpi2023 = 122.175
gen cpi2025 = 130.056
gen WGtv = 3000 * cpi2023/cpi2025 if WG==1

tabstat totfood_week WGtv if WG==1 [aw=RFACT], by(W_PROV)
gen week_diff = totfood_week-WGtv

**# Bookmark #2
egen totex_wg = rowtotal(totex WGtv)
egen totinc_wg = rowtotal(totinc WGtv)
egen totfood_wg = rowtotal (totfood WGtv)

egen totfood_week_wg = rowtotal(totfood_week WGtv)

	gen wg_food = WGtv*share_FOOD
	gen wg_nonfood =  WGtv*(1-share_FOOD)
	assert round(wg_food+wg_nonfood)==round(WGtv)

	egen food_wg = rowtotal(totfood wg_food)
	egen nonfood_wg = rowtotal(totnonfood wg_nonfood)

foreach var of varlist totex_wg totinc_wg totfood_wg food_wg nonfood_wg {
	gen `var'_pc = `var'/FSIZE
}
	
gen d_totex = (totex_wg_pc-totex_pc)/totex_pc
gen d_totinc = (totinc_wg_pc-totinc_pc)/totinc_pc
gen d_totfood = (totfood_wg_pc-totfood_pc)/totfood_pc

	gen d_food = (food_wg_pc - totfood_pc)/totfood_pc
	gen d_nonfood = (nonfood_wg_pc - totnonfood_pc)/totnonfood_pc

mean *tot* [aw=RFACT] if WG==1

tab decile_exp WG [aw=RFACT], col nofreq // distribution by decile

tabstat d_totinc if WG==1 [aw=RFACT], by(W_PROV)

**# Bookmark #1
	tabstat totfood totnonfood food_wg nonfood_wg d_food d_nonfood [aw=RFACT], by(W_PROV)
			
***
* simulation with lumpiness * 

gen food_wg2 = WGtv + (totfood-totfood_week) + (share_FOOD*totfood_week) // WG in redemption week + 3 weeks of normal food consumption plus food consumption saved in WG week (food share)
gen nonfood_wg2 = totnonfood + ((1-share_FOOD)*totfood_week) // normal non-food consumption plus food consumption saved in WG week (non-food share)
egen totex_wg2 = rowtotal(food_wg2 nonfood_wg2)

gen sharefood_wg2 = food_wg2/totex_wg2

	
***	

	* targeting 

	cumul totex_pc [aw=RFACT], gen(cdf_totex)
	
	xtile perc = totex_pc [aw=RFACT], n(100)
	tabstat WG [aw=RFACT], by(perc) format(%10.0g)

	*programme coverage threshold 
	sum WG [aw=RFACT] 
	gen prcovthresh = cdf_totex <r(mean)

	tab WG [iw=RFACT] if prcovthresh==1
	gen tot = r(N)
	//exclusion
	tab WG [iw = RFACT] if WG==0 & prcovthresh==1
	display r(N)*100/tot
	//inclusion
	tab WG [iw = RFACT] if WG==1 & prcovthresh==0
	display r(N)*100/tot

* poverty

gen pov_inc = PERCAPITA<povline

gen pov_exp = (TOTEX/FSIZE)<povline

gen pov_inc_wg = totinc_wg_pc<(povline/12)

gen pov_exp_wg = totex_wg_pc<(povline/12)

mean pov* [aw=RFACT] if WG==1

tabstat pov_inc* if WG==1 [aw=RFACT], by(W_PROV)

* share of poor covered by WG

tab WG pov_inc [aw=RFACT], cell nofreq

tab WG pov_inc [aw=RFACT], col nofreq
tab WG if pov_inc==1 [aw=RFACT]

tab W_PROV WG if pov_inc==1 [aw=RFACT], row nofreq

tabstat pov_inc if WG==1 [aw=RFACT], by(W_PROV) 

* adequacy 

*su povline [aw=RFACT] if WG==1 
*gen povline_m = r(mean)/12
gen povline_m = povline/12
gen WGtv_pc = WGtv/FSIZE
gen tv_sharepovline = WGtv_pc/povline_m if WG==1
su povline_m WGtv_pc tv_sharepovline if WG==1 [aw=RFACT] // WG = 17% of povline

gen food_pc = FOOD/FSIZE/12 
gen tv_sharefood = WGtv_pc/food_pc if WG==1
su food_pc WGtv_pc tv_sharefood if WG==1 [aw=RFACT] // WG = 58%% of food expenditure

gen tv_sharexp = WGtv_pc/totex_pc if WG==1
su totex_pc WGtv_pc tv_sharexp if WG==1 [aw=RFACT] // WG = 34% of tot exp

save "~/Development Pathways Ltd/PHL_AFD_2024_Walang Gutom - Technical/Exploratory analysis of ASP (Assignment 2)/Data/processed/fies2023.dta", replace

* nap exposure chart

import excel "~/Development Pathways Ltd/PHL_AFD_2024_Walang Gutom - Technical/Exploratory analysis of ASP (Assignment 2)/Data/NAP/NAP.xlsx", sheet("exposure_fies") firstrow clear

merge 1:m W_PROV using "~/Development Pathways Ltd/PHL_AFD_2024_Walang Gutom - Technical/Exploratory analysis of ASP (Assignment 2)/Data/processed/fies2023.dta"

* twoway rcap pov_inc pov_inc_wg nap_risk if WG==1 // no

gen d_pov_inc = -(pov_inc_wg-pov_inc)/pov_inc
egen mean_d_pov = mean(d_pov_inc), by(W_PROV)

twoway scatter mean_d_pov nap_risk if WG==1, mcolor("239 93 59")

* food consumption cdf

 cumul food_pc [aw=RFACT] if WG==0 , gen(cdf_noWG)
 cumul food_pc [aw=RFACT] if WG==1 , gen(cdf_WG)

twoway 	(line food_pc cdf_noWG if cdf_noWG<=.99 [aw=RFACT], sort) ///
		(line food_pc cdf_WG if cdf_WG<=.99 [aw=RFACT], sort)

