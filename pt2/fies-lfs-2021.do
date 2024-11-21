// date: 8/11/2024
// project: 1809 ADF Philippines - Assignment 2
// author: silvia
// purpose: process FIES 2021


import delimited "~/Development Pathways Ltd/SEA - Data/philippines/FIES LFS 2021/FIES-LFS PUF 2021 - HHMEM.CSV", case(preserve) clear //716,393

* duplicates tag SEQUENCE_NO LC101_LNO, gen(dup)

tempfile individual
save `individual', replace

import delimited "~/Development Pathways Ltd/SEA - Data/philippines/FIES LFS 2021/FIES-LFS PUF 2021 - HHLD_SUMMARY", case(preserve) clear //165,029

merge 1:m SEQUENCE_NO using `individual'

****

 * weights *

destring PWGTPRV, gen(wgt) force // individual weights

list SEQUENCE_NO if missing(wgt)
br SEQUENCE_NO LC101_LNO FSIZE PWGTPRV wgt if SEQUENCE_NO==59949 | SEQUENCE_NO==112590 | SEQUENCE_NO==153068 | SEQUENCE_NO==153078 | SEQUENCE_NO==153264 

tab W_REGN [iw=wgt]
tab W_REGN [iw=RFACT]
tab W_REGN [iw=RFACT_POP]

import delimited "~/Development Pathways Ltd/SEA - Data/philippines/FIES LFS 2021/FIES-LFS PUF 2021 - HHLD_SUMMARY", case(preserve) clear //165,029

tab W_REGN [iw=RFACT*FSIZE]
tab W_REGN [iw=RFACT_POP*FSIZE]

su TOINC PCINC NPCINC RPCINC PPCINC FOOD NFOOD TOTEX 

gen PCEXP = TOTEX/FSIZE

tab W_PROV  [iw=RFACT]

gen WG = 0 
_pctile PCEXP if W_PROV==	7	[iw=RFACT], p(	31.54	)
replace WG = PCEXP < r(r1) if W_PROV==7
_pctile PCEXP if W_PROV==	13	[iw=RFACT], p(	1.86	)
replace WG = PCEXP < r(r1) if W_PROV==13
_pctile PCEXP if W_PROV==	17	[iw=RFACT], p(	5.41	)
replace WG = PCEXP < r(r1) if W_PROV==17
_pctile PCEXP if W_PROV==	22	[iw=RFACT], p(	1.27	)
replace WG = PCEXP < r(r1) if W_PROV==22
_pctile PCEXP if W_PROV==	26	[iw=RFACT], p(	6.58	)
replace WG = PCEXP < r(r1) if W_PROV==26
_pctile PCEXP if W_PROV==	31	[iw=RFACT], p(	0.73	)
replace WG = PCEXP < r(r1) if W_PROV==31
_pctile PCEXP if W_PROV==	35	[iw=RFACT], p(	1.62	)
replace WG = PCEXP < r(r1) if W_PROV==35
_pctile PCEXP if W_PROV==	37	[iw=RFACT], p(	5.26	)
replace WG = PCEXP < r(r1) if W_PROV==37
_pctile PCEXP if W_PROV==	38	[iw=RFACT], p(	13.58	)
replace WG = PCEXP < r(r1) if W_PROV==38
_pctile PCEXP if W_PROV==	39	[iw=RFACT], p(	0.29	)
replace WG = PCEXP < r(r1) if W_PROV==39
_pctile PCEXP if W_PROV==	45	[iw=RFACT], p(	6.74	)
replace WG = PCEXP < r(r1) if W_PROV==45
_pctile PCEXP if W_PROV==	46	[iw=RFACT], p(	6.20	)
replace WG = PCEXP < r(r1) if W_PROV==46
_pctile PCEXP if W_PROV==	47	[iw=RFACT], p(	0.82	)
replace WG = PCEXP < r(r1) if W_PROV==47
_pctile PCEXP if W_PROV==	48	[iw=RFACT], p(	3.63	)
replace WG = PCEXP < r(r1) if W_PROV==48
_pctile PCEXP if W_PROV==	60	[iw=RFACT], p(	6.74	)
replace WG = PCEXP < r(r1) if W_PROV==60
_pctile PCEXP if W_PROV==	62	[iw=RFACT], p(	3.18	)
replace WG = PCEXP < r(r1) if W_PROV==62
_pctile PCEXP if W_PROV==	66	[iw=RFACT], p(	11.68	)
replace WG = PCEXP < r(r1) if W_PROV==66
_pctile PCEXP if W_PROV==	67	[iw=RFACT], p(	1.08	)
replace WG = PCEXP < r(r1) if W_PROV==67
_pctile PCEXP if W_PROV==	70	[iw=RFACT], p(	9.02	)
replace WG = PCEXP < r(r1) if W_PROV==70
_pctile PCEXP if W_PROV==	72	[iw=RFACT], p(	10.27	)
replace WG = PCEXP < r(r1) if W_PROV==72
_pctile PCEXP if W_PROV==	83	[iw=RFACT], p(	9.63	)
replace WG = PCEXP < r(r1) if W_PROV==83

tab W_PROV WG [iw=RFACT], row nofreq
tab WG [iw=RFACT]
