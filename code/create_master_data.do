/*
	Replication code for "The seeds of misallocation: Fertilizer use and maize varietal misidentification in Ethiopia" by Nils Bohr, Tim Deisemann, Douglas Gollin, Frederic Kosmowski, Travis J. Lybbert (2024).
	
	Description: Prepare dataset from raw data used for tables and figures.

	File paths are relative to the "replications_files_devec-d-23-01245" directory.

	Author: Tim Deisemann and Nils Bohr
	Updated August 7, 2024
	
	Instructions to run: change path with user and directory in line 18
*/

********************************************************************************

clear all

* ADAPT USER AND DIRECTORY HERE
global path ".../BDGLK_2024_replication_package"
global path "/Users/timdeisemann/Library/CloudStorage/Dropbox/BDGLK_2024_replication_package"

global raw $path/raw/

global data $path/data/

********************************************************************************
****** merge DNA data and ... *******
********************************************************************************

*** import seed sample

clear all

import excel "${raw}DNA_data_21May20.xlsx", sheet("DNA_data") firstrow // observed DNA fingerprinting measurements

rename subbinReferences subbinreferences 

save "${data}intermediate_data", replace

*** import seed classification and merge with sample

clear all

** new file
import delimited "${raw}Var_data_new.csv" // Maize seed library

**import excel "${raw}Var_data.xlsx", sheet("Var_data") firstrow

drop if crop != "Maize"

merge 1:m subbinreferences using "${data}intermediate_data"

drop if _merge != 3

drop _merge

save "${data}intermediate_data", replace

*** import crop cut and merge with classified sample

clear all 

use "${raw}sect9a_pp_w4.dta"

rename s4q01b fruit 

drop if fruit != 2  // where 2 is labelled 'MAIZE' 

drop if sccq01 == 2 // cropcutselected = 'NO'

drop if sccq05 == ""

drop if sccq05 == "##N/A##"

destring sccq05, replace

drop if sccq05 > 9999

rename sccq05 ID // Crop cut sample var code

save "${data}seeds_crop_cut", replace

clear all

use "${data}intermediate_data.dta"

merge 1:1 ID using "${data}seeds_crop_cut"

drop if _merge != 3

drop _merge 

tostring crop_id, replace

save "${data}intermediate_data", replace 

*** Merge with rosters // SEC 1-5

*** Merge SEC cover at HH level

clear  all

use "${raw}sect5_pp_w4.dta"

 drop if s5q0B != 2 

replace s5q01b = 3 if s5q01b ==3 // improved / saved from last year
replace s5q01b = 4 if s5q01b ==2 // improved / recycled
replace s5q01b = 2 if s5q01b ==1 // improved / new
replace s5q01b = 1 if s5q01b ==. // traditional

rename s5q01b seedtype

tostring seed_id, replace

save "${data}sect5_pp_w4", replace

*** Now HH questionnaire

* All household members, primary and secondary responsible person, household head

clear all

use "${raw}sect_cover_hh_w4.dta"

drop saq12 saq21 
rename saq09 saq12

save "${data}sect_cover_hh_w4", replace

// PP - post-planting

clear all

use "${raw}sect_cover_pp_w4.dta"

drop saq21 // as *confidential*

*** skip: SEC 1 at individual level

merge 1:m holder_id household_id using"${raw}sect2_pp_w4", nogenerate

merge 1:m holder_id household_id parcel_id using"${raw}sect3_pp_w4", nogenerate 

merge 1:m holder_id household_id parcel_id field_id using"${raw}sect4_pp_w4", nogenerate // 

tostring crop_id, replace

rename s4q11 seedtype

keep if s4q01b == 2

merge m:1 holder_id using"${raw}sect7_pp_w4"
drop if _merge != 3
drop _merge

drop saq13 // irrelevant as confidential
rename s3q13 individual_id

merge m:1 household_id using"${data}sect_cover_hh_w4" // 
drop if _merge != 3
drop _merge

merge m:1 household_id individual_id using"${raw}sect1_hh_w4" // 
drop if _merge != 3
drop _merge

drop s2q01 s3q01

merge m:1 household_id individual_id using"${raw}sect2_hh_w4" // 
drop if _merge != 3
drop _merge

merge m:1 household_id individual_id using"${raw}sect3_hh_w4" // 
drop if _merge != 3
drop _merge

merge m:1 household_id individual_id using"${raw}sect4_hh_w4" // 
drop if _merge != 3
drop _merge

merge m:1 household_id individual_id using"${raw}sect11b1_hh_w4" // 
drop if _merge != 3
drop _merge

merge m:1 household_id individual_id using"${raw}sect5a_hh_w4" // 
drop if _merge != 3
drop _merge

drop saq21

merge m:1 ea_id using"${raw}sect01a_com_w4" // 
drop if _merge != 3
drop _merge

merge m:1 ea_id using"${raw}sect01b_com_w4" // 
drop if _merge != 3
drop _merge

merge m:1 ea_id using"${raw}sect03_com_w4" // 
drop if _merge != 3
drop _merge

merge m:1 ea_id using"${raw}sect04_com_w4" // 
drop if _merge != 3
drop _merge

merge m:1 ea_id using"${raw}sect05_com_w4" // 
drop if _merge != 3
drop _merge

merge m:1 ea_id using"${raw}sect06_com_w4" // 
drop if _merge != 3
drop _merge

merge m:1 household_id using"${raw}ETH_HouseholdGeovariables_Y4" // 
drop if _merge != 3
drop _merge

merge m:1 household_id holder_id parcel_id field_id  using"${raw}ETH_PlotGeovariables_Y4" // 
drop if _merge != 3
drop _merge

********************************************************************************

merge m:1 holder_id household_id parcel_id field_id crop_id using"${data}intermediate_data" // 
drop _merge


merge m:1 holder_id seedtype using"${data}sect5_pp_w4" 
drop if _merge != 3
drop _merge

/* Logic behind merging section 5 many to 1

Several plots use the same seed, but each plot only has one seed. 

This works, as holder_id and seedtype provide an unambiguous identifier for the
fields and seeds covered in section 5 and all other sections. 
(otherwise we couldn't merge this way) 

If we had 1 plot, with two matching crops surveyed, e.g. holder 1 has 
crop 1 and crop 2 both with seedtype 1, and holder 1 has plot 1 with 
seedtype 1 we wouldn't know which ones to merge, but this is not the case,
therefore matching by rule of exclusion works in practice*/ 


********************************************************************************

gen belief = 0 if seedtype == 1
replace belief = 1 if seedtype != 1

gen dna_70_70 = 1 if (crop_specific_variety_type == "OPV" & exotic_source=="Yes" & puritypurityPercent >= 70) | (crop_specific_variety_type == "Hybrid" & exotic_source=="Yes" & puritypurityPercent >= 70)
replace dna_70_70 = 0 if !((crop_specific_variety_type == "OPV" & exotic_source=="Yes" & puritypurityPercent >= 70) | (crop_specific_variety_type == "Hybrid" & exotic_source=="Yes" & puritypurityPercent >= 70))
replace dna_70_70 =. if subbinreferences == ""
count if dna_70_70 == 1 & belief == 1 // TP
count if dna_70_70 == 0 & belief == 1 // FP
count if dna_70_70 == 0 & belief == 0 // TN
count if dna_70_70 == 1 & belief == 0 // FN

gen dna_75_75 = 1 if (crop_specific_variety_type == "OPV" & exotic_source=="Yes" & puritypurityPercent >= 75) | (crop_specific_variety_type == "Hybrid" & exotic_source=="Yes" & puritypurityPercent >= 75)
replace dna_75_75 = 0 if !((crop_specific_variety_type == "OPV" & exotic_source=="Yes" & puritypurityPercent >= 75) | (crop_specific_variety_type == "Hybrid" & exotic_source=="Yes" & puritypurityPercent >= 75))
replace dna_75_75 =. if subbinreferences == ""

count if dna_75_75 == 1 & belief == 1 // TP
count if dna_75_75 == 0 & belief == 1 // FP
count if dna_75_75 == 0 & belief == 0 // TN
count if dna_75_75 == 1 & belief == 0 // FN

gen dna_80_80 = 1 if (crop_specific_variety_type == "OPV" & exotic_source=="Yes" & puritypurityPercent >= 80) | (crop_specific_variety_type == "Hybrid" & exotic_source=="Yes" & puritypurityPercent >= 80)
replace dna_80_80 = 0 if !((crop_specific_variety_type == "OPV" & exotic_source=="Yes" & puritypurityPercent >= 80) | (crop_specific_variety_type == "Hybrid" & exotic_source=="Yes" & puritypurityPercent >= 80))
replace dna_80_80 =. if subbinreferences == ""

count if dna_80_80 == 1 & belief == 1 // TP
count if dna_80_80 == 0 & belief == 1 // FP
count if dna_80_80 == 0 & belief == 0 // TN
count if dna_80_80 == 1 & belief == 0 // FN

gen dna_85_85 = 1 if (crop_specific_variety_type == "OPV" & exotic_source=="Yes" & puritypurityPercent >= 85) | (crop_specific_variety_type == "Hybrid" & exotic_source=="Yes" & puritypurityPercent >= 85)
replace dna_85_85 = 0 if !((crop_specific_variety_type == "OPV" & exotic_source=="Yes" & puritypurityPercent >= 85) | (crop_specific_variety_type == "Hybrid" & exotic_source=="Yes" & puritypurityPercent >= 85))
replace dna_85_85 =. if subbinreferences == ""

count if dna_85_85 == 1 & belief == 1 // TP
count if dna_85_85 == 0 & belief == 1 // FP
count if dna_85_85 == 0 & belief == 0 // TN
count if dna_85_85 == 1 & belief == 0 // FN

gen dna_90_90 = 1 if (crop_specific_variety_type == "OPV" & exotic_source=="Yes" & puritypurityPercent >= 90) | (crop_specific_variety_type == "Hybrid" & exotic_source=="Yes" & puritypurityPercent >= 90)
replace dna_90_90 = 0 if !((crop_specific_variety_type == "OPV" & exotic_source=="Yes" & puritypurityPercent >= 90) | (crop_specific_variety_type == "Hybrid" & exotic_source=="Yes" & puritypurityPercent >= 90))
replace dna_90_90 =. if subbinreferences == ""

count if dna_90_90 == 1 & belief == 1 // TP
count if dna_90_90 == 0 & belief == 1 // FP
count if dna_90_90 == 0 & belief == 0 // TN
count if dna_90_90 == 1 & belief == 0 // FN

gen dna_925_925 = 1 if (crop_specific_variety_type == "OPV" & exotic_source=="Yes" & puritypurityPercent >= 92.5) | (crop_specific_variety_type == "Hybrid" & exotic_source=="Yes" & puritypurityPercent >= 92.5)
replace dna_925_925 = 0 if !((crop_specific_variety_type == "OPV" & exotic_source=="Yes" & puritypurityPercent >= 92.5) | (crop_specific_variety_type == "Hybrid" & exotic_source=="Yes" & puritypurityPercent >= 92.5))
replace dna_925_925 =. if subbinreferences == ""

count if dna_925_925 == 1 & belief == 1 // TP
count if dna_925_925 == 0 & belief == 1 // FP
count if dna_925_925 == 0 & belief == 0 // TN
count if dna_925_925 == 1 & belief == 0 // FN

gen dna_95_95 = 1 if (crop_specific_variety_type == "OPV" & exotic_source=="Yes" & puritypurityPercent >= 95) | (crop_specific_variety_type == "Hybrid" & exotic_source=="Yes" & puritypurityPercent >= 95)
replace dna_95_95 = 0 if !((crop_specific_variety_type == "OPV" & exotic_source=="Yes" & puritypurityPercent >= 95) | (crop_specific_variety_type == "Hybrid" & exotic_source=="Yes" & puritypurityPercent >= 95))
replace dna_95_95 =. if subbinreferences == ""

count if dna_95_95 == 1 & belief == 1 // TP
count if dna_95_95 == 0 & belief == 1 // FP
count if dna_95_95 == 0 & belief == 0 // TN
count if dna_95_95 == 1 & belief == 0 // FN

gen dna_975_975 = 1 if (crop_specific_variety_type == "OPV" & exotic_source=="Yes" & puritypurityPercent >= 97.5) | (crop_specific_variety_type == "Hybrid" & exotic_source=="Yes" & puritypurityPercent >= 97.5)
replace dna_975_975 = 0 if !((crop_specific_variety_type == "OPV" & exotic_source=="Yes" & puritypurityPercent >= 97.5) | (crop_specific_variety_type == "Hybrid" & exotic_source=="Yes" & puritypurityPercent >= 97.5))
replace dna_975_975 =. if subbinreferences == ""

count if dna_975_975 == 1 & belief == 1 // TP
count if dna_975_975 == 0 & belief == 1 // FP
count if dna_975_975 == 0 & belief == 0 // TN
count if dna_975_975 == 1 & belief == 0 // FN

replace s3q29b = 0 if s3q29b ==.
replace s3q29c = 0 if s3q29c ==.
replace s3q29d = 0 if s3q29d ==.
replace s3q29f = 0 if s3q29f ==.
replace s3q29g = 0 if s3q29g ==.
replace s3q29h = 0 if s3q29h ==.
replace s3q29j = 0 if s3q29j ==.
replace s3q29k = 0 if s3q29k ==.
replace s3q29l = 0 if s3q29l ==.
replace s3q29n = 0 if s3q29n ==.
replace s3q29o = 0 if s3q29o ==.
replace s3q29p = 0 if s3q29p ==.

gen total_hh_labor_psqm = (s3q29b * s3q29c * s3q29d + s3q29f * s3q29g * s3q29h + s3q29j * s3q29k * s3q29l + s3q29n * s3q29o * s3q29p) / s3q08 // divide by area in square meters

gen total_hh_labor_pha = total_hh_labor_psqm * 10000

replace s3q30a = 0 if s3q30a ==.
replace s3q30b = 0 if s3q30b ==.
replace s3q30d = 0 if s3q30d ==.
replace s3q30e = 0 if s3q30e ==.
replace s3q30g = 0 if s3q30g ==.
replace s3q30h = 0 if s3q30h ==.

gen total_hired_labor_psqm = (s3q30a * s3q30b + s3q30d * s3q30e + s3q30g * s3q30h) / s3q08

gen total_hired_labor_pha = total_hired_labor_psqm * 10000

replace s3q31a = 0 if s3q31a ==.
replace s3q31b = 0 if s3q31b ==.
replace s3q31c = 0 if s3q31c ==.
replace s3q31d = 0 if s3q31d ==.
replace s3q31e = 0 if s3q31e ==.
replace s3q31f = 0 if s3q31f ==.

gen total_other_hh_labor_psqm = (s3q31a * s3q31b + s3q31c * s3q31d + s3q31e * s3q31f) / s3q08

replace s3q21a = 0 if s3q21a ==.
replace s3q22a = 0 if s3q22a ==.
replace s3q23a = 0 if s3q23a ==.

gen nitrogen_kg_psqm = (0.46 * s3q21a + 0.18 * s3q22a + 0.1 * s3q23a) / s3q08

gen phosphorus_kg_psqm = (0.46 * s3q22a + 0.42 * s3q23a) / s3q08

gen any_prevention_binary = 1 if s4q04 == 1
replace any_prevention_binary = 0 if any_prevention_binary != 1

gen manure_use = 1 if s3q25 == 1 
replace manure_use = 0 if s3q25 == 2

gen compost_use = 1 if s3q26 == 1 
replace compost_use = 0 if s3q26 == 2

gen UREA_kg_psqm = s3q21a / s3q08
gen DAP_kg_psqm = s3q22a / s3q08
gen NPS_kg_psqm = s3q23a / s3q08

gen nitrogen_kg_pha = nitrogen_kg_psqm * 10000

gen UREA_kg_pha = UREA_kg_psqm*10000

gen DAP_kg_pha = DAP_kg_psqm*10000

gen NPS_kg_pha = NPS_kg_psqm*10000


tab s1q02 // gender
gen gender = s1q02 - 1

tab s2q04 // Has |[NAME] ever |   attended |any school?
replace s2q04 = 0 if s2q04 == 2

replace s7q04 = 0 if s7q04 == 2

replace saq15 = 0 if saq15 == 1
replace saq15 = 1 if saq15 == 3

replace s7q06 = 0 if s7q06 == 2
replace s7q06 = 1 if s7q06 == 1

replace s4q22 = 0 if s4q22 == 2

replace s11b_ind_01 = 0 if s11b_ind_01 == 2
drop if s11b_ind_01 == 97

gen orthodox = 1 if s1q08 == 1
replace orthodox = 0 if s1q08 != 1

gen phosphorus_kg_pha = phosphorus_kg_psqm*10000

gen s3q08_ha = s3q08 / 10000 // area in hectar

sum s3q08_ha

gen opv = 1 if crop_specific_variety_type == "OPV"
replace opv = 0 if crop_specific_variety_type != "OPV"

gen hybrid = 1 if crop_specific_variety_type == "Hybrid"
replace hybrid = 0 if crop_specific_variety_type != "Hybrid"

** Create region dummies

tabulate saq01, generate(saq01_bin_)

keep if nitrogen_kg_pha < 10000 // drop miscoded values

replace s5q02 = 0 if s5q02 == 2

foreach x of varlist s5q07{
	destring `x', replace
	replace `x' = 0 if (`x' == .)

}

replace s3q21d = "" if s3q21d == "091"
replace s3q21d = "6.3" if s3q21d == "6,3"

foreach x of varlist s3q21d s3q22d s3q23d s3q24d {
	destring `x', replace
	replace `x' = 0 if (`x' == .)

}

gen s5q07_ha = s5q07 / s3q08_ha

gen s3q21d_ha = s3q21d / s3q08_ha

gen s3q22d_ha = s3q22d / s3q08_ha

gen s3q23d_ha = s3q23d / s3q08_ha

gen s3q24d_ha = s3q24d / s3q08_ha

gen total_cost_purchased_inputs_pha = (s3q21d_ha + s3q22d_ha + s3q23d_ha + s3q24d_ha + s5q07_ha)

tab ea_id, generate(ea_id_bin_)

destring crop_id, replace
destring dist_household, replace

keep if nitrogen_kg_pha < 5000

order s7q04

gen belief_x_dna_70_70 = belief*dna_70_70
gen belief_x_dna_80_80 = belief*dna_80_80
gen belief_x_dna_85_85 = belief*dna_85_85
gen belief_x_dna_90_90 = belief*dna_90_90
gen belief_x_dna_925_925 = belief*dna_925_925
gen belief_x_dna_95_95 = belief*dna_95_95
gen belief_x_dna_975_975 = belief*dna_975_975

label variable belief "Belief"
label variable dna_70_70 "DNA (purity: >70%)"
label variable dna_80_80 "DNA (purity: >80%)"
label variable dna_85_85 "DNA (purity: >85%)"
label variable dna_90_90 "DNA (purity: >90%)"
label variable dna_925_925 "DNA (purity: >92.5%)"
label variable dna_95_95 "DNA (purity: >95%)"
label variable dna_975_975 "DNA (purity: > 97.5%)"

label variable belief_x_dna_70_70 "Belief X DNA"
label variable belief_x_dna_80_80 "Belief X DNA"
label variable belief_x_dna_85_85 "Belief X DNA"
label variable belief_x_dna_90_90 "Belief X DNA"
label variable belief_x_dna_925_925 "Belief X DNA"
label variable belief_x_dna_95_95 "Belief X DNA"
label variable belief_x_dna_975_975 "Belief X DNA"

label variable s7q04 "Extension contact"
label variable s5q02 "Seeds purchased"
label variable s3q08_ha "Field size (ha)"
label variable manure_use "Manure use"

sort household_id individual_id parcel_id field_id crop_id
 
save "${data}merged_data", replace

********************************************************************************

** Create fig1_data

*** TP / FP / TN / FN

drop if exotic_source ==""

local thresholds 70 80 85 90 95

foreach t in `thresholds' {
    gen tp_`t' = .
    replace tp_`t' = 1 if belief == 1 & exotic_source == "Yes" & puritypurityPercent >= `t'
    replace tp_`t' = 0 if tp_`t' != 1 & exotic_source != ""

    gen fp_`t' = .
    replace fp_`t' = 1 if (belief == 1 & exotic_source == "No") | (belief == 1 & puritypurityPercent < `t')
    replace fp_`t' = 0 if fp_`t' != 1 & exotic_source != ""

    gen tn_`t' = .
    replace tn_`t' = 1 if (belief == 0 & exotic_source == "No") | (belief == 0 & puritypurityPercent < `t')
    replace tn_`t' = 0 if tn_`t' != 1 & exotic_source != ""

    gen fn_`t' = .
    replace fn_`t' = 1 if belief == 0 & exotic_source == "Yes" & puritypurityPercent >= `t'
    replace fn_`t' = 0 if fn_`t' != 1 & exotic_source != ""
}

local thresholds 925 975

foreach t in `thresholds' {
    local purity = `t' / 10

    gen tp_`t' = .
    replace tp_`t' = 1 if belief == 1 & exotic_source == "Yes" & puritypurityPercent >= `purity'
    replace tp_`t' = 0 if tp_`t' != 1 & exotic_source != ""

    gen fp_`t' = .
    replace fp_`t' = 1 if (belief == 1 & exotic_source == "No") | (belief == 1 & puritypurityPercent < `purity')
    replace fp_`t' = 0 if fp_`t' != 1 & exotic_source != ""

    gen tn_`t' = .
    replace tn_`t' = 1 if (belief == 0 & exotic_source == "No") | (belief == 0 & puritypurityPercent < `purity')
    replace tn_`t' = 0 if tn_`t' != 1 & exotic_source != ""

    gen fn_`t' = .
    replace fn_`t' = 1 if belief == 0 & exotic_source == "Yes" & puritypurityPercent >= `purity'
    replace fn_`t' = 0 if fn_`t' != 1 & exotic_source != ""
}

local thresholds 70 80 85 90 925 95 975

foreach t in `thresholds' {
    gen correctly_identified_`t' = tp_`t' + tn_`t'
    tab correctly_identified_`t'

    gen misidentified_`t' = fp_`t' + fn_`t'
    tab misidentified_`t'
}

keep dna_70_70 dna_80_80 dna_85_85 dna_90_90 dna_925_925 dna_95_95 ///
dna_975_975 tp_975 fp_975 tn_975 fn_975 tp_95 fp_95 tn_95 fn_95 tp_925 ///
fp_925 tn_925 fn_925 tp_90 fp_90 tn_90 fn_90 tp_85 fp_85 tn_85 fn_85 ///
tp_80 fp_80 tn_80 fn_80 tp_70 fp_70 tn_70 fn_70 ///
correctly_identified_70 correctly_identified_80 correctly_identified_85 correctly_identified_90 correctly_identified_925 correctly_identified_95 correctly_identified_975 ///
misidentified_70 misidentified_80 misidentified_85 misidentified_90 misidentified_925 misidentified_95 misidentified_975

save "${data}table_A1_data", replace

keep tp_975 fp_975 tn_975 fn_975 tp_95 fp_95 tn_95 fn_95 tp_925 fp_925 tn_925 fn_925 tp_90 fp_90 tn_90 fn_90 tp_85 fp_85 tn_85 fn_85 tp_80 fp_80 tn_80 fn_80 tp_70 fp_70 tn_70 fn_70

export delimited using "${data}figure1_data.csv", replace
