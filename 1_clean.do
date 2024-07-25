// date: 1/07/2024
// project: 1809 ADF Philippines - Assignment 1: impact evaluation 
// author: silvia
// purpose: clean data from Walang Gutom RCT baseline survey, provided by ADB through AFD

* change directory
cd "~/Development Pathways Ltd/PHL_AFD_2024_Walang Gutom - Technical/Impact Evaluation (Assignment 1)/Data"

use "Processed/FSP Baseline Merged.dta", clear

* location

gen tondo = (MUN==138060)

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

* employment

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

* max education level in household
egen hh_maxedu = max(edu) if edu!=98, by(hhid)

* total yrs of education in household
egen hh_totedu = sum(edu) if edu!=98, by(hhid)

* share of school-age children in education // VALIDATE
egen hh_schooling = sum(age>=12 & age<18 & nowork_reason==8), by(hhid)	
egen hh_12to17 = sum(age>=12 & age<18), by(hhid)	
gen hh_eduratio = hh_schooling/hh_12to17

*fit-to-work working age adults
gen fitadult = (age>=15 & age<65 & nowork_reason!=6) 	
egen hh_fitadults = sum(age>=15 & age<65 & nowork_reason!=6), by(hhid)	

*number of dependents
gen hh_ndep = hhsize - hh_fitadults

*dependency ratio (fit-to-work/unfit-to-work)
gen	hh_depratio = hh_ndep/hh_fitadults

{
* unemployed and inactive
recode nowork_reason (2/5 11 = 1 "Unemployed") (1 6/10 = 0 "Inactive") (96=.), gen(unemployed)

egen active = rowmax(work unemployed)

*number of working age adults 	
egen hh_nwadults = sum(age>=15 & age<65), by(hhid)	
label variable hh_nwadults "No. of working age adults (15-64)"

*number of dependents
gen hh_ndep1 = hhsize - hh_nwadults
label variable hh_ndep1 "No. of dependents (0-14 & 65+)"	

*household age dependency ratio (work age/non-work age)
gen	hh_depratio1 = hh_ndep/hh_nwadults
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
}

*unfit to work yet working person in the household
gen unfit_work = (fitadult==0 & work==1)
egen hh_unfit_work = max(fitadult==0 & work==1), by(hhid)

save "Processed/FSP Baseline Processed.dta", replace
