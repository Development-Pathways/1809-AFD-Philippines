// date: 19/11/2024
// project: 1809 ADF Philippines - Assignment 2
// author: silvia
// purpose: stats from APIS 2022

global processed "~/Development Pathways Ltd/PHL_AFD_2024_Walang Gutom - Technical/Exploratory analysis of ASP (Assignment 2)/Data/processed"
use "$processed/APIS 2022 processed.dta", clear

mean G16_NAT_DISAS [aw=RFACT], over(REG)
mean G16A_EVAC [aw=RFACT], over(REG)
mean G16B_RECOV [aw=RFACT], over(REG)



* characteristics of programme beneficiaries

* 4Ps 
tab REG HH_4Ps [aw=RFACT], row nofreq // prevalence/coverage by region
tab REG HH_4Ps [aw=RFACT], col nofreq // distribution across regions
mean FSIZE CHLD_6_11 CHLD_12_15 EDUC_6_11 EDUC_12_15 H04_SEX H05_AGE H06_STATUS H12_HGC URB K4 K5, over(HH_4Ps)

* WG (simulated)
mean FSIZE CHLD_6_11 CHLD_12_15 EDUC_6_11 EDUC_12_15 H04_SEX H05_AGE URB K4 K5 n_prog, over(WG)

/*
eststo clear
bysort WG: eststo: quietly estpost sum URB FSIZE N_* H04_SEX H05_AGE G1_* G5_* G9_* feed_prog philhealth G16_NAT_DISAS G16A_EVAC G16B_RECOV I6-I8 K4 K5 n_prog
esttab using "$processed/WGvsOther.csv", cells("mean") replace
*/

table (REG) () [aw=RFACT], statistic(mean G1_* G5_*)
table (REG) () [aw=RFACT], statistic(mean G9_* G11_*)

table () (REG) [aw=RFACT], statistic(mean URB FSIZE N_* H04_SEX H05_AGE G1_* G5_* G9_* feed_prog philhealth n_prog G16_NAT_DISAS G16A_EVAC G16B_RECOV I6-I8 )  nformat(%5.2f)
table () (REG) [aw=RFACT], statistic(mean K4 K5)  nformat(%5.0f)

table () (WG) [aw=RFACT], statistic(mean URB FSIZE N_* H04_SEX H05_AGE G1_* G5_* G9_* feed_prog philhealth n_prog G16_NAT_DISAS G16A_EVAC G16B_RECOV I6-I8 )  nformat(%5.2f)
table () (WG) [aw=RFACT], statistic(mean PC_INC PC_FCONS)  nformat(%5.0f)

local vars URB FSIZE H04_SEX H05_AGE G1_* G5_* G9_* feed_prog philhealth n_prog G16_NAT_DISAS G16A_EVAC G16B_RECOV I6-I8 n_asset_type no_water process_water WS15 WS17 PC_INC PC_FCONS
mean `vars' [aw=RFACT] // 43517
mean `vars' [aw=RFACT] if HH_4Ps==1 // 7382
mean `vars' [aw=RFACT] if lab_mkt==1 // 1736
mean `vars' [aw=RFACT] if WG==1 // 562
mean `vars' [aw=RFACT] if WG_1==1 // 562
mean `vars' [aw=RFACT] if WG_2==1 // 562

table () (REG) if WG==1 [aw=RFACT], statistic(mean URB FSIZE H04_SEX H05_AGE G1_* G5_* G9_* feed_prog philhealth n_prog G16_NAT_DISAS G16A_EVAC G16B_RECOV I6-I8 n_asset_type no_water process_water WS15 WS17 )  nformat(%5.2f)
table () (REG) if WG==1 [aw=RFACT], statistic(mean PC_INC PC_FCONS)  nformat(%5.0f)

table () (REG) if WG==1 [aw=RFACT], statistic(mean process_water WS15 WS17)  nformat(%5.2f)

table () (REG WG) if WG_region==1 [aw=RFACT], statistic(mean N_*)  nformat(%5.2f) nototal

tab I1 WG [aw=RFACT], col nofreq
tab I2 WG [aw=RFACT], col nofreq
tab I3 WG [aw=RFACT], col nofreq
tab I4 WG [aw=RFACT], col nofreq
tab I5 WG [aw=RFACT], col nofreq

tab WS1 WG [aw=RFACT], col nofreq
tab WS2 WG [aw=RFACT], col nofreq
tab WS3 WG [aw=RFACT], col nofreq
tab WS8 WG [aw=RFACT], col nofreq
tab WS11A WG [aw=RFACT], col nofreq
tab WS14 WG [aw=RFACT], col nofreq

mean I9A-I9T [aw=RFACT] if WG==0
mean I9A-I9T [aw=RFACT] if WG==1

 * overlap 

 tab HH_4Ps if WG==1 [aw=RFACT]
 tab REG HH_4Ps if WG==1 [aw=RFACT], row nofreq
 tab REG lab_mkt if WG==1 [aw=RFACT], row nofreq
 tab REG slp_4ps if WG==1 [aw=RFACT], row nofreq
 tab REG any_prog if WG==1 [aw=RFACT], row nofreq
 
 * coverage
 
 mean WG [aw=RFACT], over(INC_dec)
 mean WG [aw=RFACT], over(FCONS_dec)
* mean WG [aw=RFACT], over(PMT_dec)


drop C101_LNO-MEM_RFACT3
merge 1:m REG HHID using "$datafolder/APIS PUF 2022 Member Record.dta"
 mean WG [aw=RFACT], over(age5yrs)

 
 