// date: 1/07/2024
// project: 1809 ADF Philippines - Assignment 1: impact evaluation 
// author: silvia
// purpose: clean data from Walang Gutom RCT baseline survey, provided by ADB through AFD

* change directory
cd "~/Development Pathways Ltd/PHL_AFD_2024_Walang Gutom - Technical/Impact Evaluation (Assignment 1)/Data"

use "Processed/FSP Baseline Merged.dta", clear

* location

gen tondo = (MUN==138060)
label define tondo 0 "Other" 1 "Tondo"
label values tondo tondo
egen provmun = group(PROVINCE MUN), label

* roster (sociodemographic) 

* individual

recode Q2D (1=0 "Male") (2=1 "Female"), gen(sex)
rename Q2E age
recode age	(0/9=0 "0-9") (10/19=1 "10-19") (20/29=2 "20-29") (30/39=3 "30-39") ///
			(40/49=4 "40-49") (50/59=5 "50-59") (60/69=6 "60-69") ///
			(70/79=7 "70-79") (80/max=8 "80+"), gen(age10yrs)
rename Q2H edu // temporary - recode
* recode Q2H ... , gen(edu)
rename Q2G rel 
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

* type of work 

gen paid_work = (work_type==1 | work_type_2==1 | work_type==2 | work_type_2==2) if !missing(work) // exclude unpaid work

gen wage_work = (work_type==1 | work_type_2==1) if !missing(work) // either primary or secondary activity

gen agri_work = (sector==1) if !missing(work) // primary activity

* household

rename NO_MEM hhsize

	* check 1 hh head
	bysort hhid:egen head_count=sum(rel==1)
	drop head_count

recode hhsize (1=1 "1 Person") (2=2 "2 Persons") (3/5=3 "3-5 Persons")   (6/7=4 "6-7 Persons") (8/10=5 "8-10 Persons") (11/max =6 "More than 10 persons") , gen(hhsize_bin)	
	
/* household head - add labels or recode
foreach x in sex age edu marital ethnicity work {
    by hhid, sort: egen head_`x' = max(cond(rel == 1, `x', .))
}
*/

* max education level in household
egen hh_maxedu = max(edu) if edu!=98, by(hhid)

* total yrs of education in household
egen hh_totedu = sum(edu) if edu!=98, by(hhid)

* other household characteristics
	* number of children
	* skipped generation
	* ...

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

	* number of fit-to-work adults working
	egen hh_fitwork = sum(fitadult==1 & work==1), by(hhid)
	
* household employment rate
gen hh_emprate = hh_fitwork/hh_fitadults

*unfit to work yet working person in the household
gen unfit_work = (fitadult==0 & work==1)
egen hh_unfit_work = max(fitadult==0 & work==1), by(hhid)

* child labour 

gen child_lab = (age<15 & work==1) if age<18
egen hh_child_lab = max(child_lab), by(hhid)
egen hh_n_child_lab = sum(child_lab), by(hhid)

gen child_lab_hrs = 0 if age<18
replace child_lab_hrs = 1 if (age>=5 & age<=11) & (paid_work==1) // children 5-11 in paid work for at least 1 hr (n/a)
replace child_lab_hrs = 1 if (age>=12 & age<=14) & (paid_work==1 & work_hrs>14) // children 12-14 in paid work for at least 14 hrs - wrk hrs refer to any job (they may do <14 hrs paid plus hrs of unpaid work)
replace child_lab_hrs = 1 if (age>=5 & age<=14) & (paid_work==0 & work_hrs>21) // children 5-11 and 12-14 in unpaid work for at least 21 hrs
replace child_lab_hrs = 1 if (age>=15 & age<=17) & (paid_work==1 & work_hrs>43) // children 15-17 in paid work for at least 43 hrs - wrk hrs refer to any job (they may do <43 hrs paid plus hrs of unpaid work)

* assert child_lab==child_lab_hrs

* vulnerable labour

gen vuln_lab = (child_lab==1) | (age>=65 & paid_work==1)
egen hh_n_vul_lab = sum(vuln_lab), by(hhid)



save "Processed/FSP Baseline Processed.dta", replace
