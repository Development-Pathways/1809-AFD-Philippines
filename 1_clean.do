// date: 1/07/2024
// project: 1809 ADF Philippines - Assignment 1: impact evaluation 
// author: silvia
// purpose: clean data from Walang Gutom RCT baseline survey, provided by ADB through AFD

* change directory
cd "~/Development Pathways Ltd/PHL_AFD_2024_Walang Gutom - Technical/Impact Evaluation (Assignment 1)/Data"

use "Processed/FSP Baseline Merged.dta", clear

* roster (sociodemographic) 

* individual

egen provmun = group(PROVINCE MUN), label
recode Q2D (1=0 "Male") (2=1 "Female"), gen(sex)
rename Q2E age
rename Q2G rel 

rename Q2H edu // temporary - recode
* recode Q2H ... , gen(edu)

recode Q2I (5/max = .), gen(marital)
recode Q2J (88/max = .), gen(ethnicity)

recode Q3A (1=1 "Yes") (2=0 "No"), gen(work) // any work past 6 months (age 12+)
rename Q3B nowork_reason 

recode Q3E (9998 9999 = .), gen(work_hrs) // typical week in past 6 months

rename Q3F work_type // primary occupation
rename Q3H sector
rename Q3M work_type_2 // secondary occupation
rename Q3O sector_2

* household

rename NO_MEM hhsize

	* check 1 hh head
	bysort hhid:egen head_count=sum(rel==1)
	drop head_count
	
* household head - add labels or recode
foreach x in sex age edu marital ethnicity work {
    by hhid, sort: egen head_`x' = max(cond(rel == 1, `x', .))
}

* unemployed and inactive
recode nowork_reason (2/5 11 = 1 "Unemployed") (1 6/10 = 0 "Inactive") (96=.), gen(unemployed)

egen active = rowmax(work unemployed)

*number of working age adults 	
egen hh_nwadults = sum(age>=15 & age<65), by(hhid)	
label variable hh_nwadults "No. of working age adults (15-64)"

*number of dependents
gen hh_ndep = hhsize - hh_nwadults
label variable hh_ndep "No. of dependents (0-14 & 65+)"	

*household age dependency ratio (work age/non-work age)
gen	hh_depratio = hh_ndep/hh_nwadults
label variable hh_depratio "Dependency ratio"

	*number of adults who could work (labour force)
	egen hh_active = sum(age>=15 & age<65 & active==1), by(hhid)	
	tab hh_active hh_nwadults 
	* dependents
	gen hh_ndep2 = hhsize - hh_active
	* dependency ratio
	gen	hh_depratio2 = hh_ndep2/hh_active
	
	*number of working hh members (any age)
	egen hh_work = sum(work==1), by(hhid)		
	* dependents
	gen hh_ndep3 = hhsize - hh_work
	* dependency ratio
	gen	hh_depratio3 = hh_ndep3/hh_work

	*number of working adults
	egen hh_wawork = sum(age>=15 & age<65 & work==1), by(hhid)		
	* dependents
	gen hh_ndep4 = hhsize - hh_wawork
	* dependency ratio
	gen	hh_depratio4 = hh_ndep4/hh_wawork

* income from work
/*
HHMPINCOME = income from primary occupation (IND)
HHMSINCOME = income from seondary occupation (IND)
Q3U = income from other occupation (IND)
HHMOIncome = total income from work (IND)
HHTIncome = total income from work (HH)
*/

* hh activities

rename Q4_1_1A crop
rename Q4_2_1A livestock
rename Q4_3_1A fishing
rename Q4_4_1A foodservice
rename Q4_5_1A wholesale
rename Q4_6_1A manufacturing
rename Q4_7_1A trasportation
rename Q4_8_1A other_activ
drop Q4*


* income aggregates (HH)

/*
HHTIncome = total income from work (module 3) - 6 months
CROPTOT1 LIVESTOCKTOT1 FISHINGTOT1 FOODSERVICETOT1 WHOLESALETOT1 MANUFACTURINGTOT1 TRANSPORTATIONTOT1 OTHERTOT1 = income from entrepreneurial activities (module 4) - 12 months
ENTREPRENEURIALTOT1 = total income from entrepreneurial activities - 12 months
OTHERPROG1 = income from programs (module 5) - 12 months
INCOMERECEIPTS1 = income from other receipts (module 6) - 12 months
	Q6_1_T = cash assistance total
	Q6_2_T = pension and retirement benefits total
	Q6_3_T = rentals total
	Q6_4_T = interests and dividends total 
	Q6_5_T = other receipts total 
INCOMEALLSOURCES1 = total household income - 12 months 
*/

* food security (module 7)

rename Q7_1_A hunger // past 3 months
rename Q7_1_B hunger_freq // frequency in past 3 months
* Q7_2A* = food security (module 7)

* consumption (module 9)

* food groups consumed

forvalues i = 1/45 {
	replace Q9_1_`i' = Q9_1_`i'- 1  // recode 1-2 to 0-1
}

egen any_breadandcereal = rowmax(Q9_1_1 Q9_1_2 Q9_1_3 Q9_1_4)
// etc



* TOTAL[food group] = food consumption 
assert TOTAL_11  == TOTALCOOKED // and so on 

	egen food_consumption = rowtotal(TOTALRICE-TOTALCOOKED) // wrong: exceeds TOTALCONSUMPTION
	replace food_consumption = food_consumption/2 // similar not identical to TOTALCONSUMPTION

	egen check = rowtotal(Q9_1_6A_CASH_T Q9_1_6A_PAID_T Q9_1_6A_KIND_T Q9_1_6B_CASH_T Q9_1_6B_PAID_T Q9_1_6B_KIND_T Q9_1_6C_CASH_T Q9_1_6C_PAID_T Q9_1_6C_KIND_T Q9_1_6D_CASH_T Q9_1_6D_PAID_T Q9_1_6D_KIND_T)

* Q9_2_* = non-food consumption (monthly average over past 6 months)
* TOTALCONSUMPTION 

* productive assets (module 13)
rename Q13_3C12V tot_asset_value

egen temp = rowtotal(Q13_3A*)
recode temp (17/max = 17 "17+"), gen(n_assets)

* savings and banking (module 14) 
rename Q_575 tot_savings

* borrowing (module 15)
rename Q15_1_CT tot_borrow

* shocks last 12 months (module 16)

save "Processed/FSP Baseline Processed.dta", replace
