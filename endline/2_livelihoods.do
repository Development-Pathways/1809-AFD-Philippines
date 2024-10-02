// date: 19/09/2024
// project: 1809 ADF Philippines - Assignment 1: impact evaluation 
// author: silvia
// purpose: clean data from Walang Gutom RCT endline survey, provided by ADB through AFD

* change directory
cd "~/Development Pathways Ltd/PHL_AFD_2024_Walang Gutom - Technical/Impact Evaluation (Assignment 1)/Data"

use "Processed/FSP Endline Processed.dta", clear

* basis of payment
recode Q3j (-1 = .) (0/3 6/max = 0 "vulnerable") (4/5 = 1 "non-vulnerable"), gen(bop_1)
recode Q3p (-1 = .) (0/3 6/max = 0 "vulnerable") (4/5 = 1 "non-vulnerable"), gen(bop_2)

egen bop = rowmax(bop_1 bop_2) // non-vulnerable if at least one b.o.p. is non-vulnerable

replace bop = 0 if missing(bop)

label define bop 0 "Vulnerable" 1 "Non-vulnerable"
label values bop bop
label variable bop "Basis of payment"

egen hh_bop = max(bop), by(hhid) // vulnerable if no non-vulnerable incomes in hh --> at least 1 non-vulnerable income in the household indicates resilience
label values hh_bop bop

gen hh_vul_bop = 1 - hh_bop // opposite: no regular income in the household indicates vulnerability

***

/*

use "/Users/silvianastasi/Downloads/ADB Philippines Food Stamp IE data shared/endline data/endline_household_data.dta"

egen check = rowtotal(wages_1_mo_total crop_sold_php_1mo livestock_sold_php_1mo fish_sold_php_1mo enterprise_food_rev_1mo enterprise_retail_rev_1mo enterprise_manufacturing_rev_1mo enterprise_transport_rev_1mo enterprise_other_rev_1mo other_income_php_1mo health_subsidy_php_1mo cash_assistance_php_1mo pension_income_php_1mo rental_income_php_1mo interest_income_php_1mo)
assert round(check) == round(hh_income_1_mo) if !missing(hh_income_1_mo)

egen hh_farm_income = rowtotal(CROPTOT1 LIVESTOCKTOT1 FISHINGTOT1)

egen hh_vuln_income = rowtotal(CROPTOT1 LIVESTOCKTOT1 FISHINGTOT1 FOODSERVICETOT1 WHOLESALETOT1 MANUFACTURINGTOT1 TRANSPORTATIONTOT1 OTHERTOT1) // all but wage employment and transfers?

egen hh_livelihood = rowtotal(HHTIncome CROPTOT1 LIVESTOCKTOT1 FISHINGTOT1 FOODSERVICETOT1 WHOLESALETOT1 MANUFACTURINGTOT1 TRANSPORTATIONTOT1 OTHERTOT1) // income from work and entrepreneurial activities

egen hh_income = rowtotal(HHTIncome CROPTOT1 LIVESTOCKTOT1 FISHINGTOT1 FOODSERVICETOT1 WHOLESALETOT1 MANUFACTURINGTOT1 TRANSPORTATIONTOT1 OTHERTOT1 OTHERPROG1) // everything but "other receipts"

* share of income from vulnerable sources

gen s_hh_vuln_income = hh_vuln_income/hh_income
gen s_hh_vuln_livelihood = hh_vuln_income/hh_livelihood

foreach var of varlist HHTIncome ENTREPRENEURIALTOT1 INCOMEALLSOURCES1 hh_livelihood hh_income {
	gen `var'_pc = `var'/hhsize
}

* hh_livelihood_pc/INCOMEALLSOURCES1_pc ?

	* income diversity 

* income diversity index 

foreach x of varlist HHTIncome CROPTOT1 LIVESTOCKTOT1 FISHINGTOT1 FOODSERVICETOT1 WHOLESALETOT1 MANUFACTURINGTOT1 TRANSPORTATIONTOT1 OTHERTOT1 OTHERPROG1 INCOMERECEIPTS1 {
	gen s1A_`x' = `x'/INCOMEALLSOURCES1
	gen s2A_`x' = (s1A_`x')^2
}

egen check_A = rowtotal(s1A_*)
replace check_A = round(check_A)
replace check_A=. if check_A==0
assert check_A==1 if !missing(check_A)


egen HHI_income = rowtotal(s2A_*) // calculated manually, surely there's a stata command

replace HHI_income = . if HHTIncome==. & CROPTOT1==. & LIVESTOCKTOT1==. & FISHINGTOT1==. & FOODSERVICETOT1==. & WHOLESALETOT1==. & MANUFACTURINGTOT1==. & TRANSPORTATIONTOT1==. & OTHERTOT1==. & OTHERPROG1==. & INCOMERECEIPTS1==.

* diversity index of income-generating actitivities 

foreach x of varlist HHTIncome CROPTOT1 LIVESTOCKTOT1 FISHINGTOT1 FOODSERVICETOT1 WHOLESALETOT1 MANUFACTURINGTOT1 TRANSPORTATIONTOT1 OTHERTOT1 {
	gen s1B_`x' = `x'/hh_livelihood
	gen s2B_`x' = (s1B_`x')^2
}

egen check_B = rowtotal(s1B_*)
replace check_B = round(check_B)
replace check_B=. if check_B==0
assert check_B==1 if !missing(check_B)

egen HHI_livelihood = rowtotal(s2B_*)

* set to missing if missing info on all income sources
replace HHI_livelihood = . if HHTIncome==. & CROPTOT1==. & LIVESTOCKTOT1==. & FISHINGTOT1==. & FOODSERVICETOT1==. & WHOLESALETOT1==. & MANUFACTURINGTOT1==. & TRANSPORTATIONTOT1==. & OTHERTOT1==. & OTHERPROG1==. & INCOMERECEIPTS1==.
* set to 1 (no diversification) if income comes from programmes and receipts only
replace HHI_livelihood = 1 if HHI_livelihood==0


* main livelihood

egen max = rowmax(HHTIncome CROPTOT1 LIVESTOCKTOT1 FISHINGTOT1 FOODSERVICETOT1 WHOLESALETOT1 MANUFACTURINGTOT1 TRANSPORTATIONTOT1 OTHERTOT1)
gen main_livelihood_str = ""
foreach activity in "HHTIncome" "CROPTOT1" "LIVESTOCKTOT1" "FISHINGTOT1" "FOODSERVICETOT1" "WHOLESALETOT1" "MANUFACTURINGTOT1" "TRANSPORTATIONTOT1" "OTHERTOT1" "OTHERPROG1" "INCOMERECEIPTS1" {
	replace main_livelihood = "`activity'" if max==`activity' & !missing(`activity')
}
encode main_livelihood_str, gen(main_livelihood) label(lvlhd)

          CROPTOT1 |        367        6.90        6.90
       FISHINGTOT1 |        147        2.76        9.66
   FOODSERVICETOT1 |        213        4.00       13.67
         HHTIncome |      3,213       60.39       74.06
   INCOMERECEIPTS1 |        437        8.21       82.27 *
     LIVESTOCKTOT1 |         74        1.39       83.67
 MANUFACTURINGTOT1 |         20        0.38       84.04
        OTHERPROG1 |        482        9.06       93.10 *
         OTHERTOT1 |         29        0.55       93.65
TRANSPORTATIONTOT1 |         78        1.47       95.11
     WHOLESALETOT1 |        260        4.89      100.00
*/

* hh activities

	* number of jobs (wage employment only)

	gen work1 = (work_type==1)
	gen work2 = (work_type_2==1)
	egen n_jobs = rowtotal(work1 work2)
	egen hh_n_jobs = total(n_jobs), by(hhid)
	
	gen jobs_pc = hh_n_jobs/hhsize

egen crop_lives_fish = rowmax(enterprise_crop_farming enterprise_livestock enterprise_fish)

* household livelihood based on sector, not source

*1* crop livestock fishing
gen farming_ind = (sector==1 | sector_2==1 | crop_lives_fish==1)
egen hh_farming = max(farming_ind), by(hhid)
*2* foodservice
gen foodservice_ind = (sector==9 | sector_2==9 | enterprise_food==1)
egen hh_foodservice = max(foodservice_ind), by(hhid)
*3* wholesale/trade
gen wholesale_ind = (sector==7 | sector_2==7 | enterprise_retail==1)
egen hh_wholesale = max(wholesale_ind), by(hhid)
*4* manufacturing
gen manufacturing_ind = (sector==3 | sector_2==3 | enterprise_manufacturing==1)
egen hh_manufacturing = max(manufacturing_ind), by(hhid)
*5* transportation
gen transportation_ind = (sector==8 | sector_2==8 | enterprise_transport==1)
egen hh_transportation = max(transportation_ind), by(hhid)
*6* other incl. construction
gen other_activ_ind = ( enterprise_other==1 | ///
sector==2 | sector==4  | sector==5  | sector==6 | (sector>=10 & !missing(sector)) | ///
sector_2==2 | sector_2==4  | sector_2==5  | sector_2==6 | (sector_2>=10 & !missing(sector_2)) )
egen hh_other_activ = max(other_activ_ind), by(hhid)

* other income
					
egen other_sources = rowmax(health_subsidy_1-health_subsidy_99 cash_assistance_1-cash_assistance_99  other_subsidy_* receives_pension receives_rental_income receives_interest_income receives_other_income receives_interest_relatives)
label variable other_sources "Other sources of income (modules 5 and 6)"

					
* number of income sources

* egen n_sources = rowtotal(hh_n_jobs health_subsidy_1-health_subsidy_99 cash_assistance_1-cash_assistance_99  other_subsidy_* receives_pension receives_rental_income receives_interest_income receives_other_income receives_interest_relatives)		

egen n_sources = rowtotal(hh_n_jobs enterprise_crop_farming enterprise_livestock enterprise_fish enterprise_food enterprise_retail enterprise_manufacturing enterprise_transport enterprise_other)		

* * 

gen hh_vuln_livelihood = (crop_lives_fish==1 & hh_vul_bop==1) // vulnerable if engages in farming AND no regular income from employment 

** help from outside the household ** 

foreach var of varlist Q16_D_* {
	count if `var'=="19"
}
destring Q16_D_*, replace

gen network_help = (Q6_1_A1==1 | Q6_1_A2==1 | Q6_1_A3==1| borrow_friends==1 | Q16_D_2==19 ) // received transfers from relative or friends or borrowed from friends and neighbours or received emergency cash tranfer from migrated hh memeber in response to shock

gen gave_gifts = (expenses_7>0 & expenses_7!=.)

gen hh_network =  (Q6_1_A1==1 | Q6_1_A2==1 | Q6_1_A3==1| borrow_friends==1 | Q6_5_A4==1 | Q6_5_A6==1 | gave_gifts==1 | Q16_D_2==19) // add repaid money and made transfers

save "Processed/FSP Endline Processed.dta", replace
