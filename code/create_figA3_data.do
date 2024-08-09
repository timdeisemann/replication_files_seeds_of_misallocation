/*
	Replication code for BDGLK (JDE 2024)
	Description: Prepare dataset from raw data used for Figure A3.

	File paths are relative to the "replications_files_devec-d-23-01245" directory.

	Author: Tim Deisemann
	Updated April 21, 2024
	
	Instructions to run: change path with user and diorectory in line 18

*/

********************************************************************************

clear all

* ADAPT USER AND DIRECTORY HERE
*global path "C:\Users\DeisemaT\Dropbox\replications_files_devec-d-23-01245\"
global path "/Users/timdeisemann/Library/CloudStorage/Dropbox/replications_files_devec-d-23-01245"


global raw $path/raw/

global data $path/data/

********************************************************************************
****** merge DNA data and ... *******
********************************************************************************

*** import seed sample

clear all

use "${data}merged_data"

// Steps

// 1 Load and prep yield datasets
// 2 Merge yield data with prior data set
// 3 Run LASSO to select controls
// 4 Create transformed vars for outcome, structural parms, and selected controls
// 5 Run production function OLS
// 6 Document and plot residuals

*** Merge post-harvest for yields

merge 1:1 household_id holder_id parcel_id field_id crop_id using "${raw}sect9_ph_w4"

drop if _merge != 3
drop _merge

merge 1:1 household_id holder_id parcel_id field_id crop_id using "${raw}sect10_ph_w4"

drop if _merge != 3
drop _merge

rename s4q01b crop_code

*** Units for yields

*** Yields

tab s9q05a // quantity
tab s9q05b // units
tab s9q05b_os // other units 
	
rename s9q05b unit_cd

drop if crop_code != 2

** save here - than load crop wave and merge the other way

save "${data}seeds_yields", replace

clear all
	
use "${raw}Crop_CF_Wave4.dta"

drop if crop_code != 2

tab unit_cd

merge 1:m unit_cd using "${data}seeds_yields"

drop if _merge != 3
drop _merge

gen yield_per_ha = mean_cf_nat * s9q05a * 10000 / s3q08
replace yield_per_ha = mean_cf1 * s9q05a * 10000 / s3q08  if saq01 == 1 // region-specific 
replace yield_per_ha = mean_cf3 * s9q05a * 10000 / s3q08 if saq01 == 3 // region-specific 
replace yield_per_ha = mean_cf4 * s9q05a * 10000 / s3q08 if saq01 == 4 // region-specific 
replace yield_per_ha = mean_cf7 * s9q05a * 10000 / s3q08 if saq01 == 7 // region-specific 
replace yield_per_ha = mean_cf99 * s9q05a * 10000 / s3q08 if saq01 != 1 & saq01 != 3 & saq01 != 4 & saq01 != 7 // region-specific 

sum yield_per_ha, detail
_pctile yield_per_ha, nq(1000)

return list 

replace yield_per_ha = r(r25) if yield_per_ha < r(r25)
replace yield_per_ha = r(r975) if yield_per_ha > r(r975)

save "${data}production_data", replace
