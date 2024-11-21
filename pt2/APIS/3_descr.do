// date: 19/11/2024
// project: 1809 ADF Philippines - Assignment 2
// author: silvia
// purpose: stats from APIS 2022

global processed "~/Development Pathways Ltd/PHL_AFD_2024_Walang Gutom - Technical/Exploratory analysis of ASP (Assignment 2)/Data/processed"
use "$processed/APIS 2022 processed.dta", clear





* characteristics of programme beneficiaries

* 4Ps 
tab REG HH_4Ps [aw=RFACT], row nofreq // prevalence/coverage by region
tab REG HH_4Ps [aw=RFACT], col nofreq // distribution across regions
mean FSIZE CHLD_6_11 CHLD_12_15 EDUC_6_11 EDUC_12_15 H04_SEX H05_AGE H06_STATUS H12_HGC URB K4 K5, over(HH_4Ps)

* WG (simulated)
mean FSIZE CHLD_6_11 CHLD_12_15 EDUC_6_11 EDUC_12_15 H04_SEX H05_AGE H06_STATUS H12_HGC URB K4 K5 n_prog, over(WG)

eststo clear
bysort WG: eststo: quietly estpost sum FSIZE CHLD_6_11 CHLD_12_15 EDUC_6_11 EDUC_12_15 H04_SEX H05_AGE H06_STATUS H12_HGC URB K4 K5 n_prog
esttab using "$processed/WGvsOther.csv", cells("mean") replace
