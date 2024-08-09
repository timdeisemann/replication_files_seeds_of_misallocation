/*
	Replication code for "The seeds of misallocation: Fertilizer use and maize varietal misidentification in Ethiopia" by Nils Bohr, Tim Deisemann, Douglas Gollin, Frederic Kosmowski, Travis J. Lybbert (2024).
	
	Description: Computes summary statistics reported in 
	
	Table A4: Regression results for nitrogen (kg/ha) across different purity 
	thresholds

	Author: Tim Deisemann
	Updated February 10, 2024
*/

/* ADAPT USER AND DIRECTORY HERE
global path ".../BDGLK_2024_replication_package"
global raw $path/raw/
global data $path/data/ */

use "${data}merged_data.dta", clear

keep if dna_95_95 !=.

global keycontrols s7q04 s5q02 s3q08_ha manure_use
global ext_controls s7q04 s5q02 s3q08_ha manure_use gender s1q03a s2q04 dist_market dist_road dist_popcenter s7q06 s11b_ind_01 i.saq01
global aset s7q04 s5q02 s3q08_ha manure_use gender s1q03a s2q04 dist_market dist_road dist_popcenter s7q06 s11b_ind_01

global numericals gender s7q12 s7q14 s7q19 s7q20 s7q21 s7q22 s7q23 s7q32a_1 s7q32b_1 s7q32c_1 parcel_id field_id crop_id s4q11a s4q21a s4q21b s3q08_ha s3q28 s3q30a s3q30d s3q30g s3q31a s3q31c saq12 saq16 s1q03a s1q06 s4q03a s4q03b s4q04a s4q04b cs3q02 cs3q03 cs3q04b cs3q06 cs3q09 cs3q10 cs3q11 cs3q12b_1 cs4q02 cs4q06 cs4q07a cs4q16 cs4q17 cs4q18 cs4q21 cs4q23 cs4q24 cs4q25 cs4q26 dist_road dist_market dist_border dist_popcenter dist_admhq twi af_bio_1 af_bio_8 af_bio_12 af_bio_13 af_bio_16 slopepct srtm1k popdensity cropshare h2018_tot h2018_wetQstart h2018_wetQ h2019_tot h2019_wetQstart h2019_wetQ anntot_avg wetQ_avgstart wetQ_avg h2018_ndvi_avg h2018_ndvi_max h2019_ndvi_avg h2019_ndvi_max ndvi_avg ndvi_max plot_twi plot_srtm plot_srtmslp manure_use 

global categoricals saq01 saq15 s7q01 s7q04 s7q06 s7q09 s7q11_1 s7q15 s7q16 s7q17 s7q29 s4q02 s4q04 s4q08 s4q13a s4q13b s4q14 s4q22 s3q03b s3q04 s3q12 individual_id s3q14 s3q16 s3q17 s3q24 s3q25 s3q26 s3q27 s3q34 s3q37 s3q38 s3q40 s2q03 s2q05 s2q16 s5q02 s5q12 s5q16 s1q01 s1q02 s1q08 s1q09 s1q12 s1q13 s1q17 s1q16 s1q20 s1q21 s1q22 s2q01 s2q04 s2q19 s4q01 s4q33b s4q45 s4q48 s4q51 s4q53 s11b_ind_01 cs2aq01 cs2aq02 cs2aq03 cs2aq05 cs2aq06 cs2aq07 cs2aq09 cs2aq11 cs3q01 cs3q04a cs3q07 cs3q08 cs3q11a cs3q12a_1 cs4q01 cs4q03 cs4q04__0 cs4q04__1 cs4q04__2 cs4q04__3 cs4q04__4 cs4q04__5 cs4q04__6 cs4q04__7 cs4q04__8 cs4q04__9 cs4q04__10 cs4q04__11 cs4q04__12 cs4q04__13 cs4q05__0 cs4q05__1 cs4q05__2 cs4q05__3 cs4q05__4 cs4q05__5 cs4q05__6 cs4q05__7 cs4q05__8 cs4q05__9 cs4q05__10 cs4q05__11 cs4q05__12 cs4q05__13 cs4q11 cs4q14 cs4q19 cs4q20 cs4q22 cs4q27 cs4q29 cs4q31 cs4q32 cs4q33 cs4q34 cs4q38 cs4q39 cs4q41 cs4q43 cs4q47 cs4q50 cs4q52 cs4q54 cs4q56 cs4q58 cs5q01_1 cs5q02 cs5q06 cs5q09 cs6q01 ssa_aez09 sq1 sq2 sq3 sq4 sq5 sq6 sq7

** robustness at 0.70 **********************************************************

quietly: reg nitrogen_kg_pha belief dna_70_70 belief_x_dna_70_70 $ext_controls, rob cluster(ea_id)

eststo est_70_ols

* Standard errors and test statistics valid for the following variables only:
*    belief
quietly: pdslasso nitrogen_kg_pha belief (dna_70_70 belief_x_dna_70_70 i.dna_70_70#i.$categoricals i.dna_70_70#c.$numericals i.$categoricals c.$numericals i.$categoricals#i.$categoricals c.$numericals#c.$numericals c.$numericals#i.$categoricals), rob cluster(ea_id) aset(dna_70_70 belief_x_dna_70_70 $aset)

eststo est_70_pds

global controls_pds_70 dna_70_70 belief_x_dna_70_70 s7q04 s7q06 s4q13b s4q14 ///
s5q02 s5q16 s2q04 s11b_ind_01 cs4q38 s3q08_ha s1q03a cs4q26 dist_road ///
dist_market dist_popcenter manure_use gender

* Standard errors and test statistics valid for all variables: 
quietly: reg nitrogen_kg_pha belief $controls_pds_70 ,rob cluster(ea_id)

eststo est_70_pds_check

esttab est_70_ols est_70_pds, star(* 0.10 ** 0.05 *** 0.01) ///
se replace label keep(belief dna_70_70 belief_x_dna_70_70) b(2) se(2) 

** robustness at 0.80 **********************************************************

quietly: reg nitrogen_kg_pha belief dna_80_80 belief_x_dna_80_80 $ext_controls, rob cluster(ea_id)

eststo est_80_ols

quietly: pdslasso nitrogen_kg_pha belief (dna_80_80 belief_x_dna_80_80 i.dna_80_80#i.$categoricals i.dna_80_80#c.$numericals i.$categoricals c.$numericals i.$categoricals#i.$categoricals c.$numericals#c.$numericals c.$numericals#i.$categoricals), rob cluster(ea_id) aset(dna_80_80 belief_x_dna_80_80 $aset)

eststo est_80_pds

esttab est_80_ols est_80_pds, star(* 0.10 ** 0.05 *** 0.01) ///
se replace label keep(belief dna_80_80 belief_x_dna_80_80) b(2) se(2) 

** robustness at 0.85 **********************************************************

quietly: reg nitrogen_kg_pha belief dna_85_85 belief_x_dna_85_85 $ext_controls, rob cluster(ea_id)

eststo est_85_ols

quietly: pdslasso nitrogen_kg_pha belief (dna_85_85 belief_x_dna_85_85 i.dna_85_85#i.$categoricals i.dna_85_85#c.$numericals i.$categoricals c.$numericals i.$categoricals#i.$categoricals c.$numericals#c.$numericals c.$numericals#i.$categoricals), rob cluster(ea_id) aset(dna_85_85 belief_x_dna_85_85 $aset)

eststo est_85_pds

esttab est_85_ols est_85_pds, star(* 0.10 ** 0.05 *** 0.01) ///
se replace label keep(belief dna_85_85 belief_x_dna_85_85) b(2) se(2) 

** robustness at 0.90 **********************************************************

quietly: reg nitrogen_kg_pha belief dna_90_90 belief_x_dna_90_90 $ext_controls, rob cluster(ea_id)

eststo est_90_ols

quietly: pdslasso nitrogen_kg_pha belief (dna_90_90 belief_x_dna_90_90 i.dna_90_90#i.$categoricals i.dna_90_90#c.$numericals i.$categoricals c.$numericals i.$categoricals#i.$categoricals c.$numericals#c.$numericals c.$numericals#i.$categoricals), rob cluster(ea_id) aset(dna_90_90 belief_x_dna_90_90 $aset)

eststo est_90_pds

esttab est_90_ols est_90_pds, star(* 0.10 ** 0.05 *** 0.01) ///
se replace label keep(belief dna_90_90 belief_x_dna_90_90) b(2) se(2) 

** robustness at 0.925 **********************************************************

quietly: reg nitrogen_kg_pha belief dna_925_925 belief_x_dna_925_925 $ext_controls, rob cluster(ea_id)

eststo est_925_ols

quietly: pdslasso nitrogen_kg_pha belief (dna_925_925 belief_x_dna_925_925 i.dna_925_925#i.$categoricals i.dna_925_925#c.$numericals i.$categoricals c.$numericals i.$categoricals#i.$categoricals c.$numericals#c.$numericals c.$numericals#i.$categoricals), rob cluster(ea_id) aset(dna_925_925 belief_x_dna_925_925 $aset)

eststo est_925_pds

quietly: pdslasso nitrogen_kg_pha belief dna_925_925 belief_x_dna_925_925 (i.dna_925_925#i.$categoricals i.dna_925_925#c.$numericals i.$categoricals c.$numericals i.$categoricals#i.$categoricals c.$numericals#c.$numericals c.$numericals#i.$categoricals), rob cluster(ea_id) aset($aset)

esttab est_925_ols est_925_pds, star(* 0.10 ** 0.05 *** 0.01) ///
se replace label keep(belief dna_925_925 belief_x_dna_925_925) b(2) se(2)  

** robustness at 0.95 **********************************************************

quietly: reg nitrogen_kg_pha belief dna_95_95 belief_x_dna_95_95 $ext_controls, rob cluster(ea_id)

eststo est_95_ols

quietly: pdslasso nitrogen_kg_pha belief (dna_95_95 belief_x_dna_95_95 i.dna_95_95#i.$categoricals i.dna_95_95#c.$numericals i.$categoricals c.$numericals i.$categoricals#i.$categoricals c.$numericals#c.$numericals c.$numericals#i.$categoricals), rob cluster(ea_id) aset(dna_95_95 belief_x_dna_95_95 $aset)

eststo est_95_pds

esttab est_95_ols est_95_pds, star(* 0.10 ** 0.05 *** 0.01) ///
se replace label keep(belief dna_95_95 belief_x_dna_95_95) b(2) se(2)  

** robustness at 0.975 *********************************************************

quietly: reg nitrogen_kg_pha belief dna_975_975 belief_x_dna_975_975 $ext_controls, rob cluster(ea_id)

eststo est_975_ols

quietly: pdslasso nitrogen_kg_pha belief (dna_975_975 belief_x_dna_975_975 i.dna_975_975#i.$categoricals i.dna_975_975#c.$numericals i.$categoricals c.$numericals i.$categoricals#i.$categoricals c.$numericals#c.$numericals c.$numericals#i.$categoricals), rob cluster(ea_id) aset(dna_975_975 belief_x_dna_975_975 $aset)

eststo est_975_pds

esttab est_975_ols est_975_pds, star(* 0.10 ** 0.05 *** 0.01) ///
se replace label keep(belief dna_975_975 belief_x_dna_975_975) b(2) se(2)

********************************************************************************

* Results

** robustness at 0.70 **********************************************************

esttab est_70_ols est_70_pds, star(* 0.10 ** 0.05 *** 0.01) ///
se replace label keep(belief dna_70_70 belief_x_dna_70_70) b(2) se(2) 

** robustness at 0.80 **********************************************************

esttab est_80_ols est_80_pds, star(* 0.10 ** 0.05 *** 0.01) ///
se replace label keep(belief dna_80_80 belief_x_dna_80_80) b(2) se(2) 

** robustness at 0.85 **********************************************************

esttab est_85_ols est_85_pds, star(* 0.10 ** 0.05 *** 0.01) ///
se replace label keep(belief dna_85_85 belief_x_dna_85_85) b(2) se(2) 

** robustness at 0.90 **********************************************************

esttab est_90_ols est_90_pds, star(* 0.10 ** 0.05 *** 0.01) ///
se replace label keep(belief dna_90_90 belief_x_dna_90_90) b(2) se(2) 

** robustness at 0.925 **********************************************************

esttab est_925_ols est_925_pds, star(* 0.10 ** 0.05 *** 0.01) ///
se replace label keep(belief dna_925_925 belief_x_dna_925_925) b(2) se(2)  

** robustness at 0.95 **********************************************************

esttab est_95_ols est_95_pds, star(* 0.10 ** 0.05 *** 0.01) ///
se replace label keep(belief dna_95_95 belief_x_dna_95_95) b(2) se(2)  

** robustness at 0.975 *********************************************************

esttab est_975_ols est_975_pds, star(* 0.10 ** 0.05 *** 0.01) ///
se replace label keep(belief dna_975_975 belief_x_dna_975_975) b(2) se(2)
