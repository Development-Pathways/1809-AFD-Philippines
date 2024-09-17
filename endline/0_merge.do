
clear
clear matrix
set maxvar 32000

global path "~/Downloads/ADB Philippines Food Stamp IE data shared/endline data"

* INDIVIDUAL LEVEL
import delimited "$path/FSP ENDLINE 2024_Section 2-3.5_Long LABELS (17Aug24).csv", case(preserve) clear // INTNO COUNT 37,147

* identify and drop non-numeric
list INTNO if missing(real(INTNO))
drop if missing(real(INTNO)) 

save "~/Development Pathways Ltd/PHL_AFD_2024_Walang Gutom - Technical/Impact Evaluation (Assignment 1)/Data/ADB Dropbox/endline_ind.dta" , replace

* HOUSEHOLD LEVEL
import delimited "$path/FSP Endline 2024 Main Questionnaire_VALUE (21Aug24).csv", case(preserve) clear // INTNO 4,941

* identify and drop non-numeric
list INTNO if missing(real(INTNO))
drop if missing(real(INTNO)) 

merge 1:m INTNO using "~/Development Pathways Ltd/PHL_AFD_2024_Walang Gutom - Technical/Impact Evaluation (Assignment 1)/Data/ADB Dropbox/endline_ind.dta" , nogenerate keep(3)

save "~/Development Pathways Ltd/PHL_AFD_2024_Walang Gutom - Technical/Impact Evaluation (Assignment 1)/Data/ADB Dropbox/endline_merged.dta" , replace


