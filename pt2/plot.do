global darkblue 	"0 57 114"
global darkorange 	"239 93 59"
global lightgrey 	"242 242 242"

import excel "$processed/NAP/NAP.xlsx", sheet("Sheet6") firstrow clear

twoway 	scatter Povertyrate2023 Riskcategory if WG==0, mcolor("0 57 114")  || ///
		scatter Povertyrate2023 Riskcategory if WG==1, mcolor("239 93 59") ///
		legend(order(1 "No WG" 2 "WG") region(color("242 242 242"))) ///
		graphregion(color("242 242 242")) plotregion(color("242 242 242"))
		
		
