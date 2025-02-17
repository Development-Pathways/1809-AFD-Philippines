// date: 19/11/2024
// project: 1809 ADF Philippines - Assignment 2
// author: silvia
// purpose: stats from APIS 2022

global processed "~/Development Pathways Ltd/PHL_AFD_2024_Walang Gutom - Technical/Exploratory analysis of ASP (Assignment 2)/Data/processed"
use "$processed/APIS 2022 processed.dta", clear

* disaster recovery

tabstat G16_NAT_DISAS G16A_EVAC G16B_RECOV [aw=RFACT], by(REG)
tabstat G16_NAT_DISAS G16B_RECOV [aw=RFACT] if WG==1 , by(REG)

* shock associated with lower income
reg PC_INC G16_NAT_DISAS i.REG [aw=RFACT]

tabstat PC_INC [aw=RFACT], by(G16_NAT_DISAS)
tabstat PC_INC [aw=RFACT] if HH_4Ps==1, by(G16_NAT_DISAS)
tabstat PC_INC [aw=RFACT] if WG_1==1, by(G16_NAT_DISAS)

iebaltab PC_INC [aw=RFACT], grpvar(G16_NAT_DISAS) pttest pftest save("$processed/iebaltab/all.xlsx")
iebaltab PC_INC [aw=RFACT] if HH_4Ps==1, grpvar(G16_NAT_DISAS) pttest pftest save("$processed/iebaltab/4ps.xlsx")
iebaltab PC_INC [aw=RFACT] if WG_1==1, grpvar(G16_NAT_DISAS) pttest pftest save("$processed/iebaltab/wg.xlsx")

* beneficiaries more subject to disaster
mean G16_NAT_DISAS [aw=RFACT], over(WG)
* probability of beneficiaries being affected by disaster 
logit G16_NAT_DISAS i.WG i.REG [iw=RFACT]
margins WG

* lower probability of recovery for perspective beneficiaries
mean G16B_RECOV [aw=RFACT] /*if G16_NAT_DISAS==1*/ , over(WG)
logit G16B_RECOV i.WG i.REG [iw=RFACT]
margins WG

**# Bookmark #1
logit G16B_RECOV i.WG PC_INC FSIZE I2-I4 I8 WS1 WS2 n_prog2 H12_HGC  i.REG i.URB [iw=RFACT]
outreg2 using "$processed/recovery.xls"
margins WG


* characteristics of programme beneficiaries

* 4Ps 
tab REG HH_4Ps [aw=RFACT], row nofreq // prevalence/coverage by region
tab REG HH_4Ps [aw=RFACT], col nofreq // distribution across regions
mean FSIZE CHLD_6_11 CHLD_12_15 EDUC_6_11 EDUC_12_15 H04_SEX H05_AGE H06_STATUS H12_HGC URB K4 K5, over(HH_4Ps)

* WG (simulated)
mean FSIZE CHLD_6_11 CHLD_12_15 EDUC_6_11 EDUC_12_15 H04_SEX H05_AGE URB K4 K5 n_prog, over(WG)

tab INC_dec WG_2 [aw=RFACT], row nofreq
tab FCONS_dec WG_2 [aw=RFACT], row nofreq

/*
eststo clear
bysort WG: eststo: quietly estpost sum URB FSIZE N_* H04_SEX H05_AGE G1_* G5_* G9_* feed_prog philhealth G16_NAT_DISAS G16A_EVAC G16B_RECOV I6-I8 K4 K5 n_prog
esttab using "$processed/WGvsOther.csv", cells("mean") replace
*/

tabstat G1_* soc_ins G5_* HH_4Ps soc_assist G9_* lab_mkt feed_prog any_prog159 WG* [aw=RFACT], by(REG)

table () (REG) [aw=RFACT], statistic(mean URB FSIZE N_* H04_SEX H05_AGE G1_* G5_* G9_* feed_prog philhealth n_prog G16_NAT_DISAS G16A_EVAC G16B_RECOV I6-I8 )  nformat(%5.2f)
table () (REG) [aw=RFACT], statistic(mean K4 K5)  nformat(%5.0f)

table () (WG) [aw=RFACT], statistic(mean URB FSIZE N_* H04_SEX H05_AGE G1_* G5_* G9_* feed_prog philhealth n_prog G16_NAT_DISAS G16A_EVAC G16B_RECOV I6-I8 )  nformat(%5.2f)
table () (WG) [aw=RFACT], statistic(mean PC_INC PC_FCONS)  nformat(%5.0f)

local vars URB FSIZE H04_SEX H05_AGE G1_* G5_* G9_* feed_prog philhealth n_prog G16_NAT_DISAS G16A_EVAC G16B_RECOV I6-I8 n_asset_type no_water process_water WS15 WS17 PC_INC PC_FCONS
su `vars' [aw=RFACT] // 43517
su `vars' [aw=RFACT] if HH_4Ps==1 // 7382
su `vars' [aw=RFACT] if lab_mkt==1 // 1736
su `vars' [aw=RFACT] if WG==1 // 562
su `vars' [aw=RFACT] if WG_2==1 // 562

egen either4p_wg = rowtotal(HH_4Ps WG_2)
egen eitherslp_wg = rowtotal(lab_mkt WG_2)

local vars URB FSIZE H04_SEX H05_AGE G1_* G5_* G9_* feed_prog philhealth n_prog G16_NAT_DISAS I6-I8 n_asset_type no_water process_water PC_INC PC_FCONS
iebaltab `vars' [aw=RFACT] if either4p_wg==1 , grpvar(WG_2) onerow replace save("$processed/iebaltab/4ps_vs_wg.xlsx")
iebaltab `vars' [aw=RFACT] if eitherslp_wg==1 , grpvar(WG_2) onerow replace save("$processed/iebaltab/slp_vs_wg.xlsx")



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
 
 tabstat HH_4Ps	lab_mkt slp_4ps any_prog if WG==1 [aw=RFACT], by(REG)
 
 * coverage

 egen slp_4ps_wg = rowmax(lab_mkt HH_4Ps WG)
 egen slp_4ps_wg1 = rowmax(lab_mkt HH_4Ps WG_1)
 egen slp_4ps_wg2 = rowmax(lab_mkt HH_4Ps WG_2)

* egen anyprog_pluswg = rowmax(any_prog159 WG)
* egen anyprog_pluswg1 = rowmax(any_prog159 WG_1)
* egen anyprog_pluswg2 = rowmax(any_prog159 WG_2)

 egen anyprog_pluswg = rowmax(any_prog59 WG)
 egen anyprog_pluswg1 = rowmax(any_prog59 WG_1)
 egen anyprog_pluswg2 = rowmax(any_prog59 WG_2)

 
* tabstat WG WG_1 WG_2 HH_4Ps lab_mkt slp_4ps any_prog [aw=RFACT], by(INC_dec)
 tabstat slp_4ps slp_4ps_wg slp_4ps_wg1 slp_4ps_wg2 [aw=RFACT], by(INC_dec)
 
 tabstat G1_* soc_ins G5_1 G5_2 HH_4Ps G5_3-G5_8 soc_assist G9_* lab_mkt feed_prog any_prog59 WG WG_1 WG_2 anyprog_pluswg* [aw=RFACT], by(REG)
 tabstat G1_* soc_ins G5_1 G5_2 HH_4Ps G5_3-G5_8 soc_assist G9_* lab_mkt feed_prog any_prog59 WG WG_1 WG_2 anyprog_pluswg* [aw=RFACT], by(INC_dec) 
 
* mean WG [aw=RFACT], over(PMT_dec)

 * cdf
 
* cumul PC_FCONS [aw=RFACT] if WG==0 , gen(cdf_noWG)
* cumul PMT [aw=RFACT] if WG==0 , gen(cdf_noWG)
 cumul PC_INC [aw=RFACT] if WG==0 , gen(cdf_noWG)
 cumul PC_INC [aw=RFACT] if WG==1 , gen(cdf_WG)

twoway 	(line PC_INC cdf_noWG if cdf_noWG<=.99 [aw=RFACT], sort) ///
		(line PC_INC cdf_WG if cdf_WG<=.99 [aw=RFACT], sort)

tabstat PC_INC PC_FCONS if HH_4Ps==1 & WG_region==1 [aw=RFACT], by(REG)
tabstat PC_INC PC_FCONS if WG_1==1 [aw=RFACT], by(REG)
		
		
* coverage vs impact

egen tot_impact = rowtotal(impact_*)

egen mean_cov = mean(WG), by(REG)

twoway scatter mean_cov tot_impact // ???
		
* share of wg with no work_age

egen N_19_64 = rowtotal(N_19_49 N_50_64)		
gen has_workage = N_19_64>0	& !missing(N_19_64)
tab has_workage WG_2 [aw=RFACT], col nofreq
		
/*
drop C101_LNO-MEM_RFACT3
merge 1:m REG HHID using "$datafolder/APIS PUF 2022 Member Record.dta"
 mean WG [aw=RFACT], over(age5yrs)

 
 