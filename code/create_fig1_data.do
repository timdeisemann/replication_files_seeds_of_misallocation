use "/Users/timdeisemann/Library/CloudStorage/Dropbox/replications_files_devec-d-23-01245/data/merged_data.dta", clear

*** TP / FP / TN / FN

drop if exotic_source ==""

*** 70 ***

gen tp_70 =.
replace tp_70 = 1 if belief == 1 & exotic_source == "Yes" & puritypurityPercent >= 70 
replace tp_70 = 0 if tp_70 != 1 & exotic_source !=""

gen fp_70 =.
replace fp_70 = 1 if belief == 1 & exotic_source == "No" | belief == 1 & puritypurityPercent < 70
replace fp_70 = 0 if fp_70 != 1 & exotic_source !=""

gen tn_70 =.
replace tn_70 = 1 if belief == 0 & exotic_source == "No" | belief == 0 & puritypurityPercent < 70 
replace tn_70 = 0 if tn_70 != 1 & exotic_source !=""

gen fn_70 =.
replace fn_70 = 1 if belief == 0 & exotic_source == "Yes" & puritypurityPercent >= 70 
replace fn_70 = 0 if fn_70 != 1 & exotic_source !=""

count if tp_70 == 1
count if fp_70 == 1
count if tn_70 == 1
count if fn_70 == 1

*** 80 ***

gen tp_80 =.
replace tp_80 = 1 if belief == 1 & exotic_source == "Yes" & puritypurityPercent >= 80 
replace tp_80 = 0 if tp_80 != 1 & exotic_source !=""

gen fp_80 =.
replace fp_80 = 1 if belief == 1 & exotic_source == "No" | belief == 1 & puritypurityPercent < 80
replace fp_80 = 0 if fp_80 != 1 & exotic_source !=""

gen tn_80 =.
replace tn_80 = 1 if belief == 0 & exotic_source == "No" | belief == 0 & puritypurityPercent < 80 
replace tn_80 = 0 if tn_80 != 1 & exotic_source !=""

gen fn_80 =.
replace fn_80 = 1 if belief == 0 & exotic_source == "Yes" & puritypurityPercent >= 80 
replace fn_80 = 0 if fn_80 != 1 & exotic_source !=""

count if tp_80 == 1
count if fp_80 == 1
count if tn_80 == 1
count if fn_80 == 1

*** 85 ***

gen tp_85 =.
replace tp_85 = 1 if belief == 1 & exotic_source == "Yes" & puritypurityPercent >= 85 
replace tp_85 = 0 if tp_85 != 1 & exotic_source !=""

gen fp_85 =.
replace fp_85 = 1 if belief == 1 & exotic_source == "No" | belief == 1 & puritypurityPercent < 85
replace fp_85 = 0 if fp_85 != 1 & exotic_source !=""

gen tn_85 =.
replace tn_85 = 1 if belief == 0 & exotic_source == "No" | belief == 0 & puritypurityPercent < 85 
replace tn_85 = 0 if tn_85 != 1 & exotic_source !=""

gen fn_85 =.
replace fn_85 = 1 if belief == 0 & exotic_source == "Yes" & puritypurityPercent >= 85 
replace fn_85 = 0 if fn_85 != 1 & exotic_source !=""

count if tp_85 == 1
count if fp_85 == 1
count if tn_85 == 1
count if fn_85 == 1

*** 90 ***

gen tp_90 =.
replace tp_90 = 1 if belief == 1 & exotic_source == "Yes" & puritypurityPercent >= 90 
replace tp_90 = 0 if tp_90 != 1 & exotic_source !=""

gen fp_90 =.
replace fp_90 = 1 if belief == 1 & exotic_source == "No" | belief == 1 & puritypurityPercent < 90
replace fp_90 = 0 if fp_90 != 1 & exotic_source !=""

gen tn_90 =.
replace tn_90 = 1 if belief == 0 & exotic_source == "No" | belief == 0 & puritypurityPercent < 90 
replace tn_90 = 0 if tn_90 != 1 & exotic_source !=""

gen fn_90 =.
replace fn_90 = 1 if belief == 0 & exotic_source == "Yes" & puritypurityPercent >= 90 
replace fn_90 = 0 if fn_90 != 1 & exotic_source !=""

count if tp_90 == 1
count if fp_90 == 1
count if tn_90 == 1
count if fn_90 == 1

*** 925 ***

gen tp_925 =.
replace tp_925 = 1 if belief == 1 & exotic_source == "Yes" & puritypurityPercent >= 92.5 
replace tp_925 = 0 if tp_925 != 1 & exotic_source !=""

gen fp_925 =.
replace fp_925 = 1 if belief == 1 & exotic_source == "No" | belief == 1 & puritypurityPercent < 92.5
replace fp_925 = 0 if fp_925 != 1 & exotic_source !=""

gen tn_925 =.
replace tn_925 = 1 if belief == 0 & exotic_source == "No" | belief == 0 & puritypurityPercent < 92.5 
replace tn_925 = 0 if tn_925 != 1 & exotic_source !=""

gen fn_925 =.
replace fn_925 = 1 if belief == 0 & exotic_source == "Yes" & puritypurityPercent >= 92.5 
replace fn_925 = 0 if fn_925 != 1 & exotic_source !=""

count if tp_925 == 1
count if fp_925 == 1
count if tn_925 == 1
count if fn_925 == 1

*** 95 ***

gen tp_95 =.
replace tp_95 = 1 if belief == 1 & exotic_source == "Yes" & puritypurityPercent >= 95 
replace tp_95 = 0 if tp_95 != 1 & exotic_source !=""

gen fp_95 =.
replace fp_95 = 1 if belief == 1 & exotic_source == "No" | belief == 1 & puritypurityPercent < 95
replace fp_95 = 0 if fp_95 != 1 & exotic_source !=""

gen tn_95 =.
replace tn_95 = 1 if belief == 0 & exotic_source == "No" | belief == 0 & puritypurityPercent < 95 
replace tn_95 = 0 if tn_95 != 1 & exotic_source !=""

gen fn_95 =.
replace fn_95 = 1 if belief == 0 & exotic_source == "Yes" & puritypurityPercent >= 95 
replace fn_95 = 0 if fn_95 != 1 & exotic_source !=""

count if tp_95 == 1
count if fp_95 == 1
count if tn_95 == 1
count if fn_95 == 1

*** 975 ***

gen tp_975 =.
replace tp_975 = 1 if belief == 1 & exotic_source == "Yes" & puritypurityPercent >= 97.5 
replace tp_975 = 0 if tp_975 != 1 & exotic_source !=""

gen fp_975 =.
replace fp_975 = 1 if belief == 1 & exotic_source == "No" | belief == 1 & puritypurityPercent < 97.5
replace fp_975 = 0 if fp_975 != 1 & exotic_source !=""

gen tn_975 =.
replace tn_975 = 1 if belief == 0 & exotic_source == "No" | belief == 0 & puritypurityPercent < 97.5 
replace tn_975 = 0 if tn_975 != 1 & exotic_source !=""

gen fn_975 =.
replace fn_975 = 1 if belief == 0 & exotic_source == "Yes" & puritypurityPercent >= 97.5 
replace fn_975 = 0 if fn_975 != 1 & exotic_source !=""

keep tp_975 fp_975 tn_975 fn_975 tp_95 fp_95 tn_95 fn_95 tp_925 fp_925 tn_925 fn_925 tp_90 fp_90 tn_90 fn_90 tp_85 fp_85 tn_85 fn_85 tp_80 fp_80 tn_80 fn_80 tp_70 fp_70 tn_70 fn_70


gen correctly_identified_70 = tp_70 + tn_70
tab correctly_identified_70

gen misidentified_70 = fp_70 + fn_70
tab misidentified_70

gen correctly_identified_80 = tp_80 + tn_80
tab correctly_identified_80

gen misidentified_80 = fp_80 + fn_80
tab misidentified_80

gen correctly_identified_85 = tp_85 + tn_85
tab correctly_identified_85

gen misidentified_85 = fp_85 + fn_85
tab misidentified_85

gen correctly_identified_90 = tp_90 + tn_90
tab correctly_identified_90

gen misidentified_90 = fp_90 + fn_90
tab misidentified_90

gen correctly_identified_925 = tp_925 + tn_925
tab correctly_identified_925

gen misidentified_925 = fp_925 + fn_925
tab misidentified_925

gen correctly_identified_95 = tp_95 + tn_95
tab correctly_identified_95

gen misidentified_95 = fp_95 + fn_95
tab misidentified_95

gen correctly_identified_975 = tp_975 + tn_975
tab correctly_identified_975

gen misidentified_975 = fp_975 + fn_975
tab misidentified_975

export delimited using "/Users/timdeisemann/Library/CloudStorage/Dropbox/replications_files_devec-d-23-01245/data/figure1_data.csv", replace


// export the data as a csv file
*export delimited "path/to/output/file.csv", delimiter(",") replace

*export delimited "${datasets}figure1_data.csv", delimiter(",") replace
