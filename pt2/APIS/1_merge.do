// date: 14/11/2024
// project: 1809 ADF Philippines - Assignment 2
// author: silvia
// purpose: process APIS 2022

global datafolder "~/Development Pathways Ltd/SEA - Data/philippines/APIS 2022/dta"
global processed "~/Development Pathways Ltd/PHL_AFD_2024_Walang Gutom - Technical/Exploratory analysis of ASP (Assignment 2)/Data"

*** reshape ***

	* social insurance 
	use "$datafolder/APIS PUF 2022 RTG1 - Social Protection - Social Insurance.dta",clear
	recode G1 (1=1 "Yes") (2=0 "No"), gen(G1_)
	drop G1 G2 G3A G3B // beneficiary member (letter)
	reshape wide G1_, i(HHID) j(G1CODE)
	save "$datafolder/APIS PUF 2022 RTG1 - Social Protection - Social Insurance.dta",replace

	* social assistance module
	use "$datafolder/APIS PUF 2022 RTG2 - Social Protection - Social Assistance.dta",clear
	recode G5 (1=1 "Yes") (2=0 "No"), gen(G5_)
	drop G5 G6 // beneficiary member (letter)
	reshape wide G5_, i(HHID) j(G5CODE)
	save "$datafolder/APIS PUF 2022 RTG2 - Social Protection - Social Assistance.dta",replace

	* labour mkt (SLP)
	use "$datafolder/APIS PUF 2022 RTG3 - Social Protection - Labor Market Intervention.dta",clear
	recode G9 (1=1 "Yes") (2=0 "No"), gen(G9_)
	drop G9 G10 // beneficiary member (letter)
	reshape wide G9_, i(HHID) j(G9CODE)
	save "$datafolder/APIS PUF 2022 RTG3 - Social Protection - Labor Market Intervention.dta",replace

	* feeding prog
	use "$datafolder/APIS PUF 2022 RTG4 - Government Feeding Program.dta",clear
	recode G11 (1=1 "Yes") (2=0 "No"), gen(G11_)
	drop G11 G12 // beneficiary member (letter)
	reshape wide G11_, i(HHID) j(G11CODE)
	save "$datafolder/APIS PUF 2022 RTG4 - Government Feeding Program.dta",replace

*** merge ***	
	
* household record
use "$datafolder/APIS PUF 2022 Household Record.dta", clear
* housing
merge 1:1 REG HHID using "$datafolder/APIS PUF 2022 RTI - Housing.dta", nogenerate
* wash
merge 1:1 REG HHID using "$datafolder/APIS PUF 2022 RTJ - Water Sanitation and Hygiene.dta", nogenerate
* other info (self-reported income and consumption)
merge 1:1 REG HHID using "$datafolder/APIS PUF 2022 RTK - Other Relevant Information.dta", nogenerate
* social insurance 
merge 1:1 REG HHID using "$datafolder/APIS PUF 2022 RTG1 - Social Protection - Social Insurance.dta", nogenerate
* social assistance 
merge 1:1 REG HHID using "$datafolder/APIS PUF 2022 RTG2 - Social Protection - Social Assistance.dta", nogenerate
* philhealth
merge 1:1 REG HHID using "$datafolder/APIS PUF 2022 RTG5 - Social Protection - Philhealth, Children, Disaster Preparedness and Recovery.dta", nogenerate
* lab mkt intervention
merge 1:1 REG HHID using "$datafolder/APIS PUF 2022 RTG3 - Social Protection - Labor Market Intervention.dta", nogenerate
* gvt feeding 
merge 1:1 REG HHID using "$datafolder/APIS PUF 2022 RTG4 - Government Feeding Program.dta", nogenerate
* gvt services 

* member record
merge 1:m REG HHID using "$datafolder/APIS PUF 2022 Member Record.dta", nogenerate
order REG HHID C101_LNO-MEM_RFACT3, first 

*** 

save "$processed/processed/APIS 2022 merged.dta", replace

*** NAP ***

import excel "$processed/NAP/NAP.xlsx", sheet("NAP-region") cellrange(A1:AK18) firstrow clear
merge 1:m REG using "$processed/processed/APIS 2022 merged.dta"

save "$processed/processed/APIS2022_merged_nap.dta", replace

