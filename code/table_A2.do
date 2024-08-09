/*
	Replication code for "The seeds of misallocation: Fertilizer use and maize varietal misidentification in Ethiopia" by Nils Bohr, Tim Deisemann, Douglas Gollin, Frederic Kosmowski, Travis J. Lybbert (2024).
	
	Description: Computes summary statistics reported in Table A2.
	
	Table A2: Descriptive statistics by seed belief categories for additional 
	outcome variables with pairwise differences and tests

	Author: Tim Deisemann
	Updated February 11, 2024
*/

/* ADAPT USER AND DIRECTORY HERE
global path ".../BDGLK_2024_replication_package"
global raw $path/raw/
global data $path/data/ */

use "${data}merged_data.dta", clear

keep if dna_95_95 !=.

gen farmer_types_95_95 = cond(dna_95_95 == 1 & belief == 1, 1, ///
                              cond(dna_95_95 == 0 & belief == 1, 2, ///
                                   cond(dna_95_95 == 0 & belief == 0, 3, 4)))

* Loop over variables
foreach var of varlist 	phosphorus_kg_pha ///
						NPS_kg_pha DAP_kg_pha UREA_kg_pha ///
						s3q23d_ha s3q22d_ha s3q21d_ha ///
						 total_hired_labor_pha  ///
						 s7q06 s11b_ind_01 dist_market dist_road ///
						dist_popcenter {
  * Summarize and pairwise mean comparison
	sum `var' if dna_95_95 == 1 & belief == 1 // TP
	sum `var' if dna_95_95 == 0 & belief == 1 // FP
    sum `var' if dna_95_95 == 0 & belief == 0 // TN
    sum `var' if dna_95_95 == 1 & belief == 0 // FN
    pwmean `var', over(farmer_types_95_95) mcompare(tukey) effects
}

// Total cost of purchased inputs (ETB/ha) - exclude one entry due to data entry issue
sum total_cost_purchased_inputs_pha if dna_95_95 == 1 & belief == 1 & total_cost_purchased_inputs_pha < 1111111 // TP
	sum total_cost_purchased_inputs_pha if dna_95_95 == 0 & belief == 1 & total_cost_purchased_inputs_pha < 1111111  // FP
    sum total_cost_purchased_inputs_pha if dna_95_95 == 0 & belief == 0 & total_cost_purchased_inputs_pha < 1111111 // TN
    sum total_cost_purchased_inputs_pha if dna_95_95 == 1 & belief == 0 & total_cost_purchased_inputs_pha < 1111111 // FN
    pwmean total_cost_purchased_inputs_pha if total_cost_purchased_inputs_pha < 1111111, over(farmer_types_95_95) mcompare(tukey) effects
	
// Cost of maize seeds purchased (ETB/ha) - exclude one entry due to data entry issue
sum s5q07_ha if dna_95_95 == 1 & belief == 1 & s5q07_ha < 1111111 // TP
	sum s5q07_ha if dna_95_95 == 0 & belief == 1 & s5q07_ha < 1111111  // FP
    sum s5q07_ha if dna_95_95 == 0 & belief == 0 & s5q07_ha < 1111111 // TN
    sum s5q07_ha if dna_95_95 == 1 & belief == 0 & s5q07_ha < 1111111 // FN
    pwmean s5q07_ha if s5q07_ha < 1111111, over(farmer_types_95_95) mcompare(tukey) effects
	
// Total household labor (hours/ha) - exclude one entry due to data entry issue
sum total_hh_labor_pha if dna_95_95 == 1 & belief == 1 & s5q07_ha < 1111111 // TP
	sum total_hh_labor_pha if dna_95_95 == 0 & belief == 1 & s5q07_ha < 1111111  // FP
    sum total_hh_labor_pha if dna_95_95 == 0 & belief == 0 & s5q07_ha < 1111111 // TN
    sum total_hh_labor_pha if dna_95_95 == 1 & belief == 0 & s5q07_ha < 1111111 // FN
    pwmean total_hh_labor_pha if s5q07_ha < 1111111, over(farmer_types_95_95) mcompare(tukey) effects
	
	
	
	
	
	
	
	
	
	
	
	
	