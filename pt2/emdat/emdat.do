

import excel "~/Development Pathways Ltd/PHL_AFD_2024_Walang Gutom - Technical/Exploratory analysis of ASP (Assignment 2)/Data/EM-DAT/public_emdat_custom_request_2024-10-10_de927560-7f38-4318-98e2-5ff8dadb5065.xlsx", sheet("EM-DAT Data") firstrow

gen byte	Basilan = (strpos(Location, "Basilan") >0 ) | (strpos(Location, "basilan") >0 )
gen byte	Bukidnon = (strpos(Location, "Bukidnon") >0 )
gen byte	CamarinesSur = (strpos(Location, "Camarines Sur") >0 )
gen byte 	Cebu	 = (strpos(Location, "Cebu") >0 )
gen byte 	EasternSamar	 = (strpos(Location, "Eastern Samar") >0 )
gen byte 	Isabela	 = (strpos(Location, "Isabela") >0 )
gen byte 	LanaodelNorte	 = (strpos(Location, "Lanao del Norte") >0 )
gen byte 	Leyte	 = (strpos(Location, "Leyte") >0 )
gen byte 	Maguindanao	 = (strpos(Location, "Maguindanao") >0 )
gen byte 	Manila	 = (strpos(Location, "Manila") >0 )
gen byte 	NegrosOccidental	 = (strpos(Location, "Negros Occidental") >0 )
gen byte 	NegrosOriental	 = (strpos(Location, "Negros Oriental") >0 )
gen byte 	Cotabato	 = (strpos(Location, "Cotabato") >0 )
gen byte 	NorthernSamar	 = (strpos(Location, "Northern Samar") >0 )
gen byte 	SamarWestern	 = (strpos(Location, "Samar (Western)") >0 )
gen byte 	Sorsogon	 = (strpos(Location, "Sorsogon") >0 )
gen byte 	Sulu	 = (strpos(Location, "Sulu") >0 )
gen byte 	SurigaodelNorte	 = (strpos(Location, "Surigao del Norte") >0 )
gen byte 	Tawi-tawi	 = (strpos(Location, "Tawi") >0 )
gen byte 	ZamboangadelNorte	 = (strpos(Location, "Zamboanga del Norte") >0 )
gen byte 	ZamboangaSibugay	 = (strpos(Location, "Zamboanga Sibugay") >0 )

gen byte NCR = (strpos(Location, "National Capital Region") >0 ) | (strpos(Location, "NCR") >0 )
gen byte REG2 = (strpos(Location, "II") >0 ) | (strpos(Location, "Cagayan") >0 )
gen byte REG5 = (strpos(Location, "V") >0 ) | (strpos(Location, "Bicol") >0 )
gen byte REG6 = (strpos(Location, "VI") >0 ) | (strpos(Location, "Western Visayas") >0 )
gen byte REG7 = (strpos(Location, "VII") >0 ) | (strpos(Location, "Central Visayas") >0 )
gen byte REG8 = (strpos(Location, "VIII") >0 ) | (strpos(Location, "Eastern Visayas") >0 )
gen byte REG9 = (strpos(Location, "IX") >0 ) | (strpos(Location, "Zamboanga") >0 )
gen byte REG10 = (strpos(Location, " X") >0 ) | (strpos(Location, "Northern Mindanao") >0 )
gen byte REG12 = (strpos(Location, "XII") >0 ) | (strpos(Location, "SOCCSKSARGEN") >0 )
gen byte REG13 = (strpos(Location, "XIII") >0 ) | (strpos(Location, "Caraga") >0 )

replace REG5 = 1 if CamarinesSur==1 | Sorsogon==1 
