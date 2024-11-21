
* Philippines APIS 2022 
* save as .dta

global rawdata "~/Development Pathways Ltd/SEA - Data/philippines/APIS 2022"
global dta "~/Development Pathways Ltd/SEA - Data/philippines/APIS 2022/dta"

import delimited "$rawdata/APIS PUF 2022 Household Record.CSV", case(preserve) clear
save "$dta/APIS PUF 2022 Household Record.dta"

import delimited "$rawdata/APIS PUF 2022 Member Record.CSV", case(preserve) clear
	* fix errors
	replace C101_LNO = 5 if HHID==34197 & C03_REL==6 & C101_LNO==2
	replace C101_LNO = 1 if HHID==35425 & C03_REL==1
save "$dta/APIS PUF 2022 Member Record.dta"

import delimited "$rawdata/APIS PUF 2022 RTG1 - Social Protection - Social Insurance.CSV", case(preserve) clear
save "$dta/APIS PUF 2022 RTG1 - Social Protection - Social Insurance.dta"

import delimited "$rawdata/APIS PUF 2022 RTG2 - Social Protection - Social Assistance.CSV", case(preserve) clear
save "$dta/APIS PUF 2022 RTG2 - Social Protection - Social Assistance.dta"

import delimited "$rawdata/APIS PUF 2022 RTG3 - Social Protection - Labor Market Intervention.CSV", case(preserve) clear
save "$dta/APIS PUF 2022 RTG3 - Social Protection - Labor Market Intervention.dta"

import delimited "$rawdata/APIS PUF 2022 RTG4 - Government Feeding Program.CSV", case(preserve) clear
save "$dta/APIS PUF 2022 RTG4 - Government Feeding Program.dta"

import delimited "$rawdata/APIS PUF 2022 RTG5 - Social Protection - Philhealth, Children, Disaster Preparedness and Recovery.CSV", case(preserve) clear
save "$dta/APIS PUF 2022 RTG5 - Social Protection - Philhealth, Children, Disaster Preparedness and Recovery.dta"

import delimited "$rawdata/APIS PUF 2022 RTH - Access to Government Services.CSV", case(preserve) clear
save "$dta/APIS PUF 2022 RTH - Access to Government Services.dta"

import delimited "$rawdata/APIS PUF 2022 RTI - Housing.CSV", case(preserve) clear
save "$dta/APIS PUF 2022 RTI - Housing.dta"

import delimited "$rawdata/APIS PUF 2022 RTJ - Water Sanitation and Hygiene.CSV", case(preserve) clear
save "$dta/APIS PUF 2022 RTJ - Water Sanitation and Hygiene.dta"

import delimited "$rawdata/APIS PUF 2022 RTK - Other Relevant Information.CSV", case(preserve) clear
save "$dta/APIS PUF 2022 RTK - Other Relevant Information.dta"



