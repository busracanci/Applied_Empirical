* ==============================================================================
*
* Title				: AK91 Replication
* Aim				: Data cleaning for Table IV
* Modified by		: Busra Canci
* Stata version  	: 16
* Last modified  	: 20230905
*
* ==============================================================================

set more off
clear all

global path "C:\Users\buca4591\Desktop\GIT\Applied_Empirical\task1\AK91"
	
cd "$path"

	global inputpath	"analysis/data" 
	global outputpath	"analysis/result"
		
	cd "$path"
	
	** LOG 
	log using "communications/logs/AK91_Replication.log", replace 
	
	** SET BUILD AND ANALYSIS PATH
	global build	"build/code" 
	global analysis	"analysis/code"
	
	** BUILD BASIC DATSET FOR ANALYSIS/INPUT
	foreach x in IV V VI {
		do "$build/Table_`x'_data.do"
	}
	
	** ANALYSIS TO REPLICATE TABLES
	foreach x in IV V VI {
		do "$analysis/Table `x'.do"
	}
	
	*** END OF DO FILE ***
	
	log close 
