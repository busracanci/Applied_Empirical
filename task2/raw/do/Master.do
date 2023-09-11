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

global path "C:\Users\buca4591\Desktop\2nd year\applied\busra_canci\task2"
	
cd "$path"

global inputpath	"analysis/data" 
global outputpath	"analysis/results"
	
	** LOG FILE
	log using "communications/Logs/Task2.log", replace 
	
	** SET BUILD AND ANALYSIS PATH
	global b	"build/do" 
	global a	"analysis/do"
	
	
	**** TASK 2A
	* Normalize dateset
	do "$b/DataConstruction.do"
	* Install the program
	do "$b/Programs.do"
	* Value review
	do "$a/ValueReview.do"
	
	**** TASK 2B
	do "$a/AK91Tables.do"
	
	log close 
