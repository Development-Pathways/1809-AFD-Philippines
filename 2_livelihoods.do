// date: 25/07/2024
// project: 1809 ADF Philippines - Assignment 1: impact evaluation 
// author: silvia
// purpose: clean data from Walang Gutom RCT baseline survey, provided by ADB through AFD

* change directory
cd "~/Development Pathways Ltd/PHL_AFD_2024_Walang Gutom - Technical/Impact Evaluation (Assignment 1)/Data"

use "Processed/FSP Baseline Processed.dta", clear

* basis of payment
recode Q3I (0/3 6/max = 0 "vulnerable") (4/5 = 1 "non-vulnerable"), gen(bop_1)
recode Q3P (0/3 6/max = 0 "vulnerable") (4/5 = 1 "non-vulnerable"), gen(bop_2)

egen bop = rowmax(bop_1 bop_2) // non-vulnerable if at least one b.o.p. is non-vulnerable
label define bop 0 "Vulnerable" 1 "Non-vulnerable"
label values bop bop
label variable bop "Basis of payment"

* income from work
/*
HHMPINCOME = income from primary occupation (IND) <-- wage 
HHMSINCOME = income from seondary occupation (IND) <-- wage
HHMOIncome = income from other occupation (?)
HHTIncome = total income from work (HH)
*/

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

	egen CHECK = rowtotal(HHTIncome CROPTOT1 LIVESTOCKTOT1 FISHINGTOT1 FOODSERVICETOT1 WHOLESALETOT1 MANUFACTURINGTOT1 TRANSPORTATIONTOT1 OTHERTOT1 OTHERPROG1 INCOMERECEIPTS1) if !missing(INCOMEALLSOURCES1)
	assert CHECK==INCOMEALLSOURCES1

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

	* income diversity 

* diversity index = share of income from activities

foreach x of varlist HHTIncome CROPTOT1 LIVESTOCKTOT1 FISHINGTOT1 FOODSERVICETOT1 WHOLESALETOT1 MANUFACTURINGTOT1 TRANSPORTATIONTOT1 OTHERTOT1 OTHERPROG1 {
	gen s1A_`x' = `x'/hh_income
	gen s2A_`x' = (s1A_`x')^2
}

egen check_A = rowtotal(s1A_*)
replace check_A = round(check_A)
replace check_A=. if check_A==0
assert check_A==1 if !missing(check_A)

egen HHI_income = rowtotal(s2A_*) // calculated manually, surely there's a stata command

foreach x of varlist HHTIncome CROPTOT1 LIVESTOCKTOT1 FISHINGTOT1 FOODSERVICETOT1 WHOLESALETOT1 MANUFACTURINGTOT1 TRANSPORTATIONTOT1 OTHERTOT1 {
	gen s1B_`x' = `x'/hh_livelihood
	gen s2B_`x' = (s1B_`x')^2
}

egen check_B = rowtotal(s1B_*)
replace check_B = round(check_B)
replace check_B=. if check_B==0
assert check_B==1 if !missing(check_B)

egen HHI_livelihood = rowtotal(s2B_*)

* hh activities

	* number of jobs (wage employment only)

	gen work1 = (work_type==1)
	gen work2 = (work_type_2==1)
	egen n_jobs = rowtotal(work1 work2)
	egen hh_n_jobs = total(n_jobs), by(hhid)

forval i = 1/8 {
	replace Q4_`i'_1A = 2-Q4_`i'_1A // recode from 1-2 to 0-1
}

rename Q4_1_1A crop
rename Q4_2_1A livestock
rename Q4_3_1A fishing
rename Q4_4_1A foodservice
rename Q4_5_1A wholesale
rename Q4_6_1A manufacturing
rename Q4_7_1A trasportation
rename Q4_8_1A other_activ
drop Q4*

* other income

gen other_progs = (	Q5_1A	== 1 | ///
					Q5_2A	== 1 | ///
					Q5_3A	== 1 | ///
					Q5_4A	== 1 | ///
					Q5_5A	== 1 | ///
					Q5_6A	== 1 | ///
					Q5_7A	== 1 | ///
					Q5_8A	== 1 | ///
					Q5_9A	== 1 | ///
					Q5_10C	== 1 | ///
					Q5_11C	== 1 | ///
					Q5_12C	== 1 | ///
					Q5_13C	== 1 | ///
					Q5_14C	== 1 | ///
					Q5_15C	== 1 | ///
					Q5_16C	== 1 | ///
					Q5_20C_OTH	== 1) 
					
gen other_assistance = (Q6_1_1A	== 1 | ///
						Q6_1_2A	== 1 | ///
						Q6_1_3A	== 1 | ///
						Q6_1_4A	== 1 )

gen other_pension = (Q6_2_1A== 1 )
					
gen other_rentals = (Q6_3_1A== 1 | ///
					Q6_3_2A	== 1 | ///
					Q6_3_3A	== 1 )
					
gen other_interests = (Q6_4_1A	== 1 | ///
					Q6_4_2A	== 1 | ///
					Q6_4_3A	== 1 )
					
gen other_other = ( Q6_5_1A	== 1 | ///
					Q6_5_2A	== 1 | ///
					Q6_5_3A	== 1 | ///
					Q6_5_4A	== 1 | ///
					Q6_5_5A	== 1 | ///
					Q6_5_6A	== 1 | ///
					Q6_5_7A	== 1 | ///
					Q6_5_8A	== 1 | ///
					Q6_5_9A	== 1 | ///
					Q6_5_10A== 1 | ///
					Q6_5_11A== 1 )
					
egen other_sources = rowmax(other_progs other_assistance other_pension other_rentals other_interests)
label variable other_sources "Other sources of income (modules 5 and 6)"

					
* number of income sources

egen n_sources = rowtotal(hh_n_jobs crop livestock fishing foodservice wholesale manufacturing trasportation other_activ other_progs other_assistance other_pension other_rentals other_interests)		

egen n_sources_alt = rowtotal(hh_n_jobs crop livestock fishing foodservice wholesale manufacturing trasportation other_activ other_sources)		

save "Processed/FSP Baseline Processed.dta", replace


