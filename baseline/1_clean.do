// date: 1/07/2024
// project: 1809 ADF Philippines - Assignment 1: impact evaluation 
// author: silvia
// purpose: clean data from Walang Gutom RCT baseline survey, provided by ADB through AFD

* change directory
cd "~/Development Pathways Ltd/PHL_AFD_2024_Walang Gutom - Technical/Impact Evaluation (Assignment 1)/Data"

use "Processed/FSP Baseline Merged.dta", clear

* recode missing values

ds, has(type numeric)  
foreach var of varlist `r(varlist)' {
	replace `var' = . if `var'==999998 | `var'==999999
}

* ID

rename INTNO hhid
rename HH_ROSTER pid

* location

gen tondo = (MUN==138060)
label define tondo 0 "Other" 1 "Tondo"
label values tondo tondo
egen provmun = group(PROVINCE MUN), label

* roster (sociodemographic) 

* individual

recode Q2D (1=0 "Male") (2=1 "Female"), gen(sex)
gen age = Q2E if Q2E!=998
recode age	(0/9=0 "0-9") (10/19=1 "10-19") (20/29=2 "20-29") (30/39=3 "30-39") ///
			(40/49=4 "40-49") (50/59=5 "50-59") (60/69=6 "60-69") ///
			(70/79=7 "70-79") (80/max=8 "80+"), gen(age10yrs)
rename Q2G rel 
recode Q2I (5/max = .), gen(marital)
recode Q2J (12=1 "Tagalog") (4=2 "Ilocano") (1=3 "Bicolano") (6=4 "Cebuano") (2 3 5 7/11 13/15 88 = 5 "Other") (89/max = .), gen(ethnicity)


* gender of meal planner

gen meal_planner_gender0 = Q2D if pid==Q2L
egen meal_planner_gender = max(meal_planner_gender0), by(hhid)

* education
recode Q2H (0/1 = 0 "No grade completed") (2/6 = 1 "Incomplete Primary") (7 = 3 "Primary") (8/10 = 4 "Incomplete Junior High") (11 = 5 "Junior High") (12 = 6 "1st year Senior High") (13 = 7 "Senior High") (14/17 = 8 "Tertiary") (18/max =.) , gen(edu)

* household

rename NO_MEM hhsize

	* check 1 hh head
	bysort hhid:egen head_count=sum(rel==1)
	drop head_count

recode hhsize (1=1 "1 Person") (2=2 "2 Persons") (3/5=3 "3-5 Persons")   (6/7=4 "6-7 Persons") (8/10=5 "8-10 Persons") (11/max =6 "More than 10 persons") , gen(hhsize_bin)	

su hhsize, d
gen hhsize_2 = (hhsize>r(p50))
label define hhsize_2 0 "Smaller (1-7)" 1 "Larger (8+)"
label values hhsize_2 hhsize_2
	
/* household head - add labels or recode
foreach x in sex age edu marital ethnicity work {
    by hhid, sort: egen head_`x' = max(cond(rel == 1, `x', .))
}
*/

* max education level in household
egen hh_maxedu = max(Q2H) if Q2H<98, by(hhid)
label values hh_maxedu edu 

* total yrs of education in household
egen hh_totedu = sum(edu) if edu!=98, by(hhid)

* education potential 

gen edu_pot = age-4 // potential max n. yrs of education
replace edu_pot = 0 if edu_pot<0
replace edu_pot = 17 if edu_pot>17
egen hh_edu_pot = sum(edu_pot), by(hhid)

gen hh_edupotratio = hh_maxedu/hh_edu_pot 
replace hh_edupotratio = 0 if hh_edu_pot==0
replace hh_edupotratio = 1 if hh_edupotratio>1

* age-appropriate education

gen age_edu = (age==6 & Q2H>=1 & !missing(Q2H))
replace age_edu = 1 if (age==7 & Q2H>=2 & !missing(Q2H))
replace age_edu = 1 if (age==8 & Q2H>=3 & !missing(Q2H))
replace age_edu = 1 if (age==9 & Q2H>=4 & !missing(Q2H))
replace age_edu = 1 if (age==10 & Q2H>=5 & !missing(Q2H))
replace age_edu = 1 if (age==11 & Q2H>=6 & !missing(Q2H))
replace age_edu = 1 if (age==12 & Q2H>=7 & !missing(Q2H))
replace age_edu = 1 if (age==13 & Q2H>=8 & !missing(Q2H))
replace age_edu = 1 if (age==14 & Q2H>=9 & !missing(Q2H))
replace age_edu = 1 if (age==15 & Q2H>=10 & !missing(Q2H))
replace age_edu = 1 if (age==16 & Q2H>=11 & !missing(Q2H))
replace age_edu = 1 if (age==17 & Q2H>=12 & !missing(Q2H))

egen n_age_appr_edu = sum(age_edu), by(hhid) // --> see end of script

*Number of school aged children attending school, school age  5-17
gen attend_school = (age>=5 & age<=17) & (edu!=0 & edu!=.) // highest grade higher than preschool
egen hh_n_school = sum(attend_school), by(hhid)
egen hh_school = max(attend_school), by(hhid)

*Proportion of school aged children attending school, school age  5-17
egen n_school_age = sum(age>=5 & age<=17), by(hhid)
gen prop_attend_school = hh_n_school / n_school_age

* other household characteristics
	
	* number of children
	egen n_child05 = sum(age<5), by(hhid) // excluding 5yo
	gen has_child05 = n_child05>0 
	
	egen n_child017 = sum(age<18), by(hhid)
	gen has_child017 = n_child017>0 

	gen n_adults = hhsize - n_child017
	
	* household composition
	egen hh_couple = max(rel==2), by(hhid)
	egen hh_son = max(rel==3), by(hhid)
	egen hh_grandson = max(rel==6), by(hhid)

	* skipped generation
	gen hh_skipgen = (hh_grandson==1 & hh_son==0) // there is head's grandchild but not child
	
	* single parent
	gen hh_singlepar = (hh_son==1 & hh_couple==0) // there is head's child but not spouse
	
gen hhtype = 8
replace hhtype = 2 if hh_couple==1 & n_child017==0 
replace hhtype = 1 if hh_couple==1 & n_child017>0 
replace hhtype = 3 if n_adults==1 & n_child017>0
replace hhtype = 4 if hhsize==1 & n_adults==1 & n_child017==0 & age>=60
replace hhtype = 5 if hhsize==1 & n_adults==1 & n_child017==0 & age>=18 & age<60
replace hhtype = 6 if hh_son==1 & hh_grandson==1
replace hhtype = 7 if hh_grandson==1 & hh_son==0
 
label define hhtypeg 1 "Couple household, with children"    ///
					2 "Couple household, with no children"   ///
                    3 "Single parent/caregiver (<60 years)"  ///
                    4 "One-person household, 60+ years"      ///
                    5 "One-person household, 18-59 years"    ///
                    6 "Three generation household"            ///
                    7 "Skipped generation"                    ///
                    8 "Other household types"
label values hhtype hhtypeg
	
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

* share of school-age children in education // VALIDATE
egen hh_schooling = sum(age>=12 & age<18 & nowork_reason==8), by(hhid)	
egen hh_12to17 = sum(age>=12 & age<18), by(hhid)	
gen hh_eduratio = hh_schooling/hh_12to17

* child labour 

gen child_lab = (age<15 & work==1) if age<18
egen hh_child_lab = max(child_lab), by(hhid)
egen hh_n_child_lab = sum(child_lab), by(hhid)

gen child_lab_hrs = 0 if age<18 // missing work hrs (69) automatically assumed as too many (overestimate)
replace child_lab_hrs = 1 if (age>=5 & age<=11) & (paid_work==1) // children 5-11 in paid work for at least 1 hr (n/a)
replace child_lab_hrs = 1 if (age>=12 & age<=14) & (paid_work==1 & work_hrs>14) // children 12-14 in paid work for at least 14 hrs - wrk hrs refer to any job (they may do <14 hrs paid plus hrs of unpaid work)
replace child_lab_hrs = 1 if (age>=5 & age<=14) & (paid_work==0 & work_hrs>21 & !missing(work_hrs)) // children 5-11 and 12-14 in unpaid work for at least 21 hrs
replace child_lab_hrs = 1 if (age>=15 & age<=17) & (paid_work==1 & work_hrs>43 & !missing(work_hrs)) // children 15-17 in paid work for at least 43 hrs - wrk hrs refer to any job (they may do <43 hrs paid plus hrs of unpaid work)

tab1 child_lab child_lab_hrs // less child labour using hrs worked --> will use simple definition

* vulnerable labour

gen vuln_lab = (child_lab==1) | (age>=65 & paid_work==1)
egen hh_vul_lab = max(vuln_lab), by(hhid)

// 

gen age_appr_edu_ratio = n_age_appr_edu / n_child017 if n_child017>0


save "Processed/FSP Baseline Processed.dta", replace
