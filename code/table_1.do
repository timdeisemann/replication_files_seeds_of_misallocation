/*
	Replication code for "The seeds of misallocation: Fertilizer use and maize varietal misidentification in Ethiopia" by Nils Bohr, Tim Deisemann, Douglas Gollin, Frederic Kosmowski, Travis J. Lybbert (2024).
	
	Description: Computes summary statistics reported in Table 1.
	
	Table 1: Descriptive statistics by seed belief categories for demographic 
	and production variables with pairwise differences

	Author: Tim Deisemann
	Updated February 7, 2024
*/

/* ADAPT USER AND DIRECTORY HERE
global path ".../BDGLK_2024_replication_package"
global raw $path/raw/
global data $path/data/ */

use "${data}merged_data.dta", clear

keep if dna_95_95 !=.

* Generate farmer_types_95_95
gen farmer_types_95_95 = cond(dna_95_95 == 1 & belief == 1, 1, ///
                              cond(dna_95_95 == 0 & belief == 1, 2, ///
                                   cond(dna_95_95 == 0 & belief == 0, 3, 4)))

* Loop over variables
foreach var of varlist 	gender s1q03a s2q04 s7q04 s5q02 s3q08_ha ///
						nitrogen_kg_pha manure_use {
  * Summarize and pairwise mean comparison
	sum `var' if dna_95_95 == 1 & belief == 1 // TP
	sum `var' if dna_95_95 == 0 & belief == 1 // FP
    sum `var' if dna_95_95 == 0 & belief == 0 // TN
    sum `var' if dna_95_95 == 1 & belief == 0 // FN
    pwmean `var', over(farmer_types_95_95) mcompare(tukey) effects
}
