* ==============================================================================
*
* Title				: AK91 Replication
* Modified by		: Busra Canci
* Stata version  	: 16
* Last modified  	: 20230909
*
* ==============================================================================
	

set more off
clear all

global path "C:\Users\buca4591\Desktop\GIT\Applied_Empirical\task2"
	
cd "$path"

global inputpath	"analysis/data" 
global outputpath	"analysis/results"

	** INITIALLIZE PROGRAM
	do "build/do/Programs.do"
	
	** VALUE REVIEW USING PROGRAM
	valuereview using "$inputpath/AK91_Data.dta", numericfile("$outputpath/AK91_ValueReview.tex")
	valuereview using "$inputpath/AL99_Grade4_Data.dta", numericfile("$outputpath/AL99_Grade4_ValueReview.tex")
	valuereview using "$inputpath/AL99_Grade5_Data.dta", numericfile("$outputpath/AL99_Grade5_ValueReview.tex")
	
	*** END OF DO FILE ***

	
	