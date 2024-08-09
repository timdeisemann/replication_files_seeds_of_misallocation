/*
	Replication code for "The seeds of misallocation: Fertilizer use and maize varietal misidentification in Ethiopia" by Nils Bohr, Tim Deisemann, Douglas Gollin, Frederic Kosmowski, Travis J. Lybbert (2024).
	
	Description: Computes summary statistics reported in 
	
	Table A8: Total cost of purchased inputs, seed beliefs and DNA type

	Author: Tim Deisemann
	Updated February 10, 2024
*/

/* ADAPT USER AND DIRECTORY HERE
global path ".../BDGLK_2024_replication_package"
global raw $path/raw/
global data $path/data/ */

use "${data}merged_data.dta", clear

keep if dna_95_95 !=.


global keycontrols_costs s7q04 s3q08_ha manure_use
global ext_controls_costs s7q04 s3q08_ha manure_use gender s1q03a s2q04 dist_market dist_road dist_popcenter s7q06 s11b_ind_01 i.saq01
global aset_costs s7q04 s3q08_ha manure_use gender s1q03a s2q04 dist_market dist_road dist_popcenter s7q06 s11b_ind_01

global numericals gender s7q12 s7q14 s7q19 s7q20 s7q21 s7q22 s7q23 s7q32a_1 s7q32b_1 s7q32c_1 parcel_id field_id crop_id s4q11a s4q21a s4q21b s3q08_ha s3q28 s3q30a s3q30d s3q30g s3q31a s3q31c saq12 saq16 s1q03a s1q06 s4q03a s4q03b s4q04a s4q04b cs3q02 cs3q03 cs3q04b cs3q06 cs3q09 cs3q10 cs3q11 cs3q12b_1 cs4q02 cs4q06 cs4q07a cs4q16 cs4q17 cs4q18 cs4q21 cs4q23 cs4q24 cs4q25 cs4q26 dist_road dist_market dist_border dist_popcenter dist_admhq twi af_bio_1 af_bio_8 af_bio_12 af_bio_13 af_bio_16 slopepct srtm1k popdensity cropshare h2018_tot h2018_wetQstart h2018_wetQ h2019_tot h2019_wetQstart h2019_wetQ anntot_avg wetQ_avgstart wetQ_avg h2018_ndvi_avg h2018_ndvi_max h2019_ndvi_avg h2019_ndvi_max ndvi_avg ndvi_max plot_twi plot_srtm plot_srtmslp manure_use 

global categoricals saq01 saq15 s7q01 s7q04 s7q06 s7q09 s7q11_1 s7q15 s7q16 s7q17 s7q29 s4q02 s4q04 s4q08 s4q13a s4q13b s4q14 s4q22 s3q03b s3q04 s3q12 individual_id s3q14 s3q16 s3q17 s3q24 s3q25 s3q26 s3q27 s3q34 s3q37 s3q38 s3q40 s2q03 s2q05 s2q16 s5q12 s5q16 s1q01 s1q02 s1q08 s1q09 s1q12 s1q13 s1q17 s1q16 s1q20 s1q21 s1q22 s2q01 s2q04 s2q19 s4q01 s4q33b s4q45 s4q48 s4q51 s4q53 s11b_ind_01 cs2aq01 cs2aq02 cs2aq03 cs2aq05 cs2aq06 cs2aq07 cs2aq09 cs2aq11 cs3q01 cs3q04a cs3q07 cs3q08 cs3q11a cs3q12a_1 cs4q01 cs4q03 cs4q04__0 cs4q04__1 cs4q04__2 cs4q04__3 cs4q04__4 cs4q04__5 cs4q04__6 cs4q04__7 cs4q04__8 cs4q04__9 cs4q04__10 cs4q04__11 cs4q04__12 cs4q04__13 cs4q05__0 cs4q05__1 cs4q05__2 cs4q05__3 cs4q05__4 cs4q05__5 cs4q05__6 cs4q05__7 cs4q05__8 cs4q05__9 cs4q05__10 cs4q05__11 cs4q05__12 cs4q05__13 cs4q11 cs4q14 cs4q19 cs4q20 cs4q22 cs4q27 cs4q29 cs4q31 cs4q32 cs4q33 cs4q34 cs4q38 cs4q39 cs4q41 cs4q43 cs4q47 cs4q50 cs4q52 cs4q54 cs4q56 cs4q58 cs5q01_1 cs5q02 cs5q06 cs5q09 cs6q01 ssa_aez09 sq1 sq2 sq3 sq4 sq5 sq6 sq7

quietly: reg total_cost_purchased_inputs_pha belief dna_95_95 belief_x_dna_95_95 if total_cost_purchased_inputs_pha < 1111111, robust cluster(ea_id) // seeds are improved 

eststo est1
estadd local basic_controls no
estadd local ext_controls no

quietly: reg total_cost_purchased_inputs_pha belief dna_95_95 belief_x_dna_95_95 $keycontrols_costs if total_cost_purchased_inputs_pha < 1111111, robust cluster(ea_id) // seeds are improved 

eststo est2
estadd local basic_controls yes
estadd local ext_controls no

quietly: reg total_cost_purchased_inputs_pha belief dna_95_95 belief_x_dna_95_95 $ext_controls_costs if total_cost_purchased_inputs_pha < 1111111, robust cluster(ea_id) // seeds are not improved

eststo est3
estadd local basic_controls yes
estadd local ext_controls yes

global categoricals_costs saq01 saq15 s7q01 s7q04 s7q06 s7q09 s7q11_1 s7q15 s7q16 s7q17 s7q29 s4q02 s4q04 s4q08 s4q13a s4q13b s4q14 s4q22 s3q03b s3q04 s3q12 individual_id s3q14 s3q16 s3q17 s3q24 s3q25 s3q26 s3q27 s3q34 s3q37 s3q38 s3q40 s2q03 s2q05 s2q16 s5q12 s5q16 s1q01 s1q02 s1q08 s1q09 s1q12 s1q13 s1q17 s1q16 s1q20 s1q21 s1q22 s2q01 s2q04 s2q19 s4q01 s4q33b s4q45 s4q48 s4q51 s4q53 s11b_ind_01 cs2aq01 cs2aq02 cs2aq03 cs2aq05 cs2aq06 cs2aq07 cs2aq09 cs2aq11 cs3q01 cs3q04a cs3q07 cs3q08 cs3q11a cs3q12a_1 cs4q01 cs4q03 cs4q04__0 cs4q04__1 cs4q04__2 cs4q04__3 cs4q04__4 cs4q04__5 cs4q04__6 cs4q04__7 cs4q04__8 cs4q04__9 cs4q04__10 cs4q04__11 cs4q04__12 cs4q04__13 cs4q05__0 cs4q05__1 cs4q05__2 cs4q05__3 cs4q05__4 cs4q05__5 cs4q05__6 cs4q05__7 cs4q05__8 cs4q05__9 cs4q05__10 cs4q05__11 cs4q05__12 cs4q05__13 cs4q11 cs4q14 cs4q19 cs4q20 cs4q22 cs4q27 cs4q29 cs4q31 cs4q32 cs4q33 cs4q34 cs4q38 cs4q39 cs4q41 cs4q43 cs4q47 cs4q50 cs4q52 cs4q54 cs4q56 cs4q58 cs5q01_1 cs5q02 cs5q06 cs5q09 cs6q01 ssa_aez09 sq1 sq2 sq3 sq4 sq5 sq6 sq7

quietly: pdslasso total_cost_purchased_inputs_pha belief (dna_95_95 belief_x_dna_95_95 i.dna_95_95#i.$categoricals_costs i.dna_95_95#c.$numericals i.$categoricals_costs c.$numericals i.$categoricals_costs#i.$categoricals_costs c.$numericals#c.$numericals c.$numericals#i.$categoricals_costs) if total_cost_purchased_inputs_pha < 1111111, rob cluster(ea_id) aset(dna_95_95 belief_x_dna_95_95 $aset_costs)

* One observation excluded where total_cost_purchased_inputs_pha == 1111111 due to
* faulty data entry

gen saq01_15 = 1 if saq01 == 15
replace saq01_15 = 0 if saq01 != 15

gen saq01_3 = 1 if saq01 == 3
replace saq01_3 = 0 if saq01 != 3

gen sq7_3 = 1 if sq7 == 3
replace sq7_3 = 0 if sq7 != 3

gen sq7_3_x_saq01_15 = sq7_3*saq01_15


gen sq7_4 = 1 if sq7 == 4
replace sq7_4 = 0 if sq7 != 4

gen saq01_7 = 1 if saq01 == 7
replace saq01_7 = 0 if saq01 != 7

gen sq7_4_x_saq01_7 = sq7_4*saq01_7

gen manure_use_x_saq01_3 = saq01_3*manure_use

gen dna_95_95_x_saq01_15 = saq01_15*dna_95_95

global selected_vars_model_costs_belief dna_95_95 belief_x_dna_95_95 dna_95_95_x_saq01_15 ///
                                       s7q04 s7q06 s4q14 s5q16 s2q04 s11b_ind_01 cs4q43 ///
                                       s7q14 s7q20 s7q22 s3q08_ha s1q03a cs4q26 dist_road ///
                                       dist_market dist_popcenter cropshare manure_use ///
                                       saq01_15 gender sq7_3_x_saq01_15 ///
                                       sq7_4_x_saq01_7

quietly: reg total_cost_purchased_inputs_pha belief dna_95_95 belief_x_dna_95_95 $selected_vars_model_costs_belief if total_cost_purchased_inputs_pha < 1111111, robust cluster(ea_id) // seeds are not improved

eststo est4
estadd local basic_controls yes
estadd local ext_controls yes

quietly: pdslasso total_cost_purchased_inputs_pha dna_95_95 (belief belief_x_dna_95_95 i.belief#i.$categoricals_costs i.belief#c.$numericals i.$categoricals_costs c.$numericals i.$categoricals_costs#i.$categoricals_costs c.$numericals#c.$numericals c.$numericals#i.$categoricals_costs) if total_cost_purchased_inputs_pha < 1111111, rob cluster(ea_id) aset(belief belief_x_dna_95_95 $aset_costs)

global selected_vars_model_costs_dna belief belief_x_dna_95_95 s7q04 s7q06 s4q14 s5q16 ///
                                       s2q04 s11b_ind_01 cs4q43 sq5 s3q08_ha s1q03a ///
                                       dist_road dist_market dist_popcenter h2018_wetQstart ///
                                       manure_use gender ///
                                       manure_use_x_saq01_3

quietly: reg total_cost_purchased_inputs_pha belief dna_95_95 belief_x_dna_95_95 $selected_vars_model_costs_dna if total_cost_purchased_inputs_pha < 1111111, robust cluster(ea_id) // seeds are not improved

eststo est5
estadd local basic_controls yes
estadd local ext_controls yes

esttab est1 est2 est3 est4 est5, star(* 0.10 ** 0.05 *** 0.01) se ///
replace label keep(belief dna_95_95 belief_x_dna_95_95 s7q04 s3q08_ha ///
manure_use) b(2) se(2) stats(basic_controls ext_controls N r2 , fmt(0 0 0 2))
