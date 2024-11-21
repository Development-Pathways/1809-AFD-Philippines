// date: 18/11/2024
// project: 1809 ADF Philippines - Assignment 2
// author: silvia
// purpose: process APIS 2022

global processed "~/Development Pathways Ltd/PHL_AFD_2024_Walang Gutom - Technical/Exploratory analysis of ASP (Assignment 2)/Data/processed"
use "$processed/APIS 2022 merged.dta", clear

cap drop _merge

* demographics

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

* feeding prog
egen feed_prog = rowmax(G11_1 G11_2)

* welfare (self-reported)

gen PC_INC = K5/FSIZE/6 // monthly per capita income 
gen PC_FCONS = K4/FSIZE/6 // monthly per capita food consumption

* assets 
foreach item of varlist I9A-I9T { // recode from 1-2 to 0-1
	replace `item' = 2-`item'
}

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
predict yhat_ncr
reg ln_inc `household' `assets' URB H05_AGE H12_HGC N_*  i.REG if NCR==0 [aw = RFACT], robust
predict yhat
replace yhat = yhat_ncr if NCR==1 
egen PMT = max(yhat), by(HHID)


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
_pctile PMT if REG==	7	[iw=RFACT], p(	1.62	)
replace WG = PMT < r(r1) if REG == 7
_pctile PMT if REG==	8	[iw=RFACT], p(	4.46	)
replace WG = PMT < r(r1) if REG == 8
_pctile PMT if REG==	9	[iw=RFACT], p(	10.02	)
replace WG = PMT < r(r1) if REG == 9
_pctile PMT if REG==	10	[iw=RFACT], p(	0.77	)
replace WG = PMT < r(r1) if REG == 10				
_pctile PMT if REG==	12	[iw=RFACT], p(	3.91	)
replace WG = PMT < r(r1) if REG == 12
_pctile PMT if REG==	16	[iw=RFACT], p(	0.21	)
replace WG = PMT < r(r1) if REG == 16

tab REG WG [iw=RFACT], row nofreq
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
replace WG_1=1 if REG== 12 & rank<= 83
replace WG_1=1 if REG== 13 & rank<= 2
replace WG_1=1 if REG== 16 & rank<= 4

tab REG WG_1 [iw=RFACT], row nofreq

*** exclude 4Ps & SLP
egen rank = rank(PMT) if HH_4P==0 & SLP==0, unique by (REG)

gen WG_2=0
replace WG_2=1 if REG== 2 & rank<= 7
replace WG_2=1 if REG== 5 & rank<= 53
replace WG_2=1 if REG== 6 & rank<= 44
replace WG_2=1 if REG== 7 & rank<= 33
replace WG_2=1 if REG== 8 & rank<= 127
replace WG_2=1 if REG== 9 & rank<= 188
replace WG_2=1 if REG== 10 & rank<= 21
replace WG_2=1 if REG== 12 & rank<= 83
replace WG_2=1 if REG== 13 & rank<= 2
replace WG_2=1 if REG== 16 & rank<= 4

tab REG WG_2 [iw=RFACT], row nofreq

/*

* province
gen PROV = substr(E51A,1,2)

*/

save "$processed/APIS 2022 processed.dta", replace

