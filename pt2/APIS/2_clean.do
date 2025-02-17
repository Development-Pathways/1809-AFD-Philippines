// date: 18/11/2024
// project: 1809 ADF Philippines - Assignment 2
// author: silvia
// purpose: process APIS 2022

global processed "~/Development Pathways Ltd/PHL_AFD_2024_Walang Gutom - Technical/Exploratory analysis of ASP (Assignment 2)/Data/processed"
use "$processed/APIS2022_merged_nap.dta", clear

cap drop _merge

replace URB = 2-URB

* demographics

replace H04_SEX = H04_SEX-1

recode C05_AGE	(0/9=0 "0-9") (10/19=1 "10-19") (20/29=2 "20-29") (30/39=3 "30-39") ///
			(40/49=4 "40-49") (50/59=5 "50-59") (60/69=6 "60-69") ///
			(70/79=7 "70-79") (80/max=8 "80+"), gen(age10yrs)
recode C05_AGE (0/4=0 "0-4") (5/9=1 "5-9") (10/14=2 "10-14") (15/19=3  "15-19") ///
(20/24=4 "20-24") (25/29=5 "25-29") (30/34=6 "30-34") (35/39=7 "35-39") ///
(40/44=8 "40-44") (45/49=9 "45-49") (50/54=10 "50-54") (55/59=11 "55-59") ///
(60/64=12 "60-64") (65/69=13 "65-69") (70/74=14 "70-74") (75/79=15 "75-79") ///
(80/max=16 "80+"), gen(age5yrs)

			
egen N_0_5 = sum(C05_AGE<=5), by(HHID)
egen N_6_10 = sum(C05_AGE>=6 & C05_AGE<=10), by(HHID)
egen N_11_14 = sum(C05_AGE>=11 & C05_AGE<=14), by(HHID)
egen N_15_18 = sum(C05_AGE>=15 & C05_AGE<=18), by(HHID)
egen N_19_49 = sum(C05_AGE>=19 & C05_AGE<=49), by(HHID)
egen N_50_64 = sum(C05_AGE>=50 & C05_AGE<=64), by(HHID)
egen N_65 = sum(C05_AGE>=65), by(HHID)

duplicates drop HHID, force // back to HH level

* social insurance 
egen soc_ins = rowmax(G1_1-G1_5)

* social assistance

*** regular and modified 4Ps ***

egen HH_4Ps = rowmax(G5_1 G5_2)

*** other (non 4Ps)
egen soc_assist = rowmax(G5_3-G5_8)

* overlaps
egen n_prog = rowtotal(G5_*)

* labour mkt intervention
egen lab_mkt = rowmax(G9_1-G9_4)

egen slp_4ps = rowmax(lab_mkt HH_4Ps)

* feeding prog
egen feed_prog = rowmax(G11_1 G11_2)

* any programme

egen any_prog = rowmax(G5_* lab_mkt feed_prog)
egen any_prog159 = rowmax(G1_* G5_* G9_*)
egen any_prog59 = rowmax(G5_* G9_*)

egen n_prog2 = rowtotal(G5_* lab_mkt feed_prog)

* philhealth

gen philhealth = (G13_PHEALTH==1|G13_PHEALTH==2) //paying or non-paying

* disaster preparedness 

destring G15A_TYPE_* G16A_EVAC G16B_RECOV G16C_HELP_A-G16C_HELP_F, replace

replace G16_NAT_DISAS = 2-G16_NAT_DISAS
replace G16A_EVAC = 2-G16A_EVAC
replace G16B_RECOV = 2-G16B_RECOV

* wash

destring WS3 WS8 WS14 WS15 WS10_A-WS10_Z, replace
gen no_water = (WS7==1)
gen process_water = (WS9==1)
replace WS15 = 2-WS15

foreach var of varlist WS10_A-WS10_Z {
	replace `var' =1 if !missing(`var')
	replace `var' =0 if `var'!=1 & process_water==1
}

* welfare (self-reported)

gen PC_INC = K5/FSIZE // average monthly per capita income jan-jun
gen PC_FCONS = K4/FSIZE/6 // monthly per capita food consumption

xtile INC_dec = PC_INC [aw=RFACT], n(10)
xtile FCONS_dec = PC_FCONS [aw=RFACT], n(10)

* assets 
foreach item of varlist I8 I9A-I9T { // recode from 1-2 to 0-1
	replace `item' = 2-`item'
}

egen n_asset_type = rowtotal(I9A-I9T)

pca I9A-I9T
predict pca_assets, score

*** simulate PMT ***

* ref. pop for pmt estimation = bottom 40%
_pctile K5 [iw=RFACT], p(40)
gen bottom40 = K5 < r(r1) 

* national capital region vs rest of the philippines
gen NCR = (REG==13)

gen ln_inc = log(PC_INC)

/*
* first stage
reg PC_INC I1-I9T WS1-WS3A WS11A WS14 WS15 HW1 URB i.REG [aw = RFACT] if bottom40==1, robust
predict yhat
* second stage
reg ln_inc yhat [aw = RFACT], robust // ????
*/

destring WS2 WS17 C07_HGC_LEVEL , replace

local household H06_STATUS H04_SEX FSIZE I5 I1-I3 WS1 /*WS2*/ WS11A I8 /*WS17*/
local assets I9J I9G I9P I9M I9N I9R I9S I9O I9A-I9D
*local individual C05_AGE C07_HGC_LEVEL //occupation n/a

*reg ln_inc `household' `assets' URB `individual' if NCR==1 [aw = RFACT], robust

reg ln_inc `household' `assets' URB H05_AGE H12_HGC N_* if NCR==1 [aw = RFACT], robust
outreg2 using "$processed/pmt.xls"
predict yhat_ncr
reg ln_inc `household' `assets' URB H05_AGE H12_HGC N_*  i.REG if NCR==0 [aw = RFACT], robust
outreg2 using "$processed/pmt.xls", append
predict yhat
replace yhat = yhat_ncr if NCR==1 
egen PMT = max(yhat), by(HHID)

xtile PMT_dec = PMT [aw=RFACT], n(10)

*** simulate WG ***
gen WG=0
_pctile PMT if REG==	13	[iw=RFACT], p(	0.04	)
replace WG = PMT < r(r1) if REG == 13
_pctile PMT if REG==	2	[iw=RFACT], p(	0.34	)
replace WG = PMT < r(r1) if REG == 2
_pctile PMT if REG==	5	[iw=RFACT], p(	2.24	)
replace WG = PMT < r(r1) if REG == 5
_pctile PMT if REG==	6	[iw=RFACT], p(	2.22	)
replace WG = PMT < r(r1) if REG == 6
_pctile PMT if REG==	7	[iw=RFACT], p(	1.61	)
replace WG = PMT < r(r1) if REG == 7
_pctile PMT if REG==	8	[iw=RFACT], p(	4.46	)
replace WG = PMT < r(r1) if REG == 8
_pctile PMT if REG==	9	[iw=RFACT], p(	10.01	)
replace WG = PMT < r(r1) if REG == 9
_pctile PMT if REG==	10	[iw=RFACT], p(	0.77	)
replace WG = PMT < r(r1) if REG == 10				
_pctile PMT if REG==	15	[iw=RFACT], p(	4.99	)
replace WG = PMT < r(r1) if REG == 15
_pctile PMT if REG==	16	[iw=RFACT], p(	0.21	)
replace WG = PMT < r(r1) if REG == 16

tab REG WG //[iw=RFACT], row nofreq
tab WG [iw=RFACT]

*** exclude 4Ps 
egen rank = rank(PMT) if HH_4P==0, unique by (REG)

tab REG WG

gen WG_1=0
replace WG_1=1 if REG== 2 & rank<= 7
replace WG_1=1 if REG== 5 & rank<= 53
replace WG_1=1 if REG== 6 & rank<= 44
replace WG_1=1 if REG== 7 & rank<= 33
replace WG_1=1 if REG== 8 & rank<= 127
replace WG_1=1 if REG== 9 & rank<= 188
replace WG_1=1 if REG== 10 & rank<= 21
replace WG_1=1 if REG== 15 & rank<= 115
replace WG_1=1 if REG== 13 & rank<= 2
replace WG_1=1 if REG== 16 & rank<= 4

tab REG WG_1 [iw=RFACT], row nofreq

*** exclude 4Ps & SLP
egen rank2 = rank(PMT) if HH_4P==0 & lab_mkt==0, unique by (REG)

gen WG_2=0
replace WG_2=1 if REG== 2 & rank2<= 7
replace WG_2=1 if REG== 5 & rank2<= 53
replace WG_2=1 if REG== 6 & rank2<= 44
replace WG_2=1 if REG== 7 & rank2<= 33
replace WG_2=1 if REG== 8 & rank2<= 127
replace WG_2=1 if REG== 9 & rank2<= 188
replace WG_2=1 if REG== 10 & rank2<= 21
replace WG_2=1 if REG== 15 & rank2<= 115
replace WG_2=1 if REG== 13 & rank2<= 2
replace WG_2=1 if REG== 16 & rank2<= 4

tab REG WG_2 [iw=RFACT], row nofreq

gen WG_region = (REG==2|REG==5|REG==6|REG==7|REG==8|REG==9|REG==10|REG==15|REG==13|REG==16)

/* simulate change in food consumption 
	* monhtly transfers higher than average food consumption over 6 months (K4)
gen cpi2022 = 115.283
gen cpi2025 = 130.056
gen WGtv = 3000 * cpi2022/cpi2025 if WG==1
gen WGtv_pc = WGtv/FSIZE

egen food_wg = rowtotal(PC_FCONS WGtv)

gen d_food = (food_wg-PC_FCONS)/PC_FCONS

su K4 WGtv WGtv_pc PC_FCONS food_wg d_food [aw=RFACT] //if WG==1
*/

/*

* province
gen PROV = substr(E51A,1,2)

*/

save "$processed/APIS 2022 processed.dta", replace

