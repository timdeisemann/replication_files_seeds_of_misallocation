/*
	Replication code for "The seeds of misallocation: Fertilizer use and maize varietal misidentification in Ethiopia" by Nils Bohr, Tim Deisemann, Douglas Gollin, Frederic Kosmowski, Travis J. Lybbert (2024).
	
	Description: Computes summary statistics reported in Table A1.
	
	Table A1: Descriptive statistics by seed belief categories for demographic 
	and production variables with pairwise differences

	Author: Tim Deisemann
	Updated February 7, 2024
*/

/* ADAPT USER AND DIRECTORY HERE
global path ".../BDGLK_2024_replication_package"
global raw $path/raw/
global data $path/data/ */

use "${data}table_A1_data.dta", clear

* Loop over variables
foreach var of varlist 	dna_70_70 dna_80_80 dna_85_85 dna_90_90 ///
						dna_925_925 dna_95_95 dna_975_975 {
	tab `var'
}

foreach var of varlist 	tp_70 tp_80 tp_85 tp_90 tp_925 tp_95 tp_975 ///
						 {
	tab `var'
}

foreach var of varlist 	fp_70 fp_80 fp_85 fp_90 fp_925 fp_95 fp_975 {
	tab `var'
}

foreach var of varlist 	tn_70 tn_80 tn_85 tn_90 tn_925 tn_95 tn_975 {
	tab `var'
}

foreach var of varlist 	fn_70 fn_80 fn_85 fn_90 fn_925 fn_95 fn_975 {
	tab `var'
}

foreach var of varlist correctly_identified_70 correctly_identified_80 ///
 correctly_identified_85 correctly_identified_90 correctly_identified_925 ///
 correctly_identified_95 correctly_identified_975 {
	tab `var'
}
   
foreach var of varlist misidentified_70 misidentified_80 misidentified_85 ///
misidentified_90 misidentified_925 misidentified_95 misidentified_975 {
	tab `var'
}
   
   
 