	set more off
	clear all
	set maxvar 10000

	global path = "C:\Users\buca4591\Desktop\GIT\Applied_Empirical\task5"
	cd "$path"
	
	global inputpath	"raw/data"
	global outputpath	"analysis/input"

	use "$inputpath/penn_jae.dta", clear

	** Generate and labeling variables
	gen treatment = (tg == 4) if !mi(tg)
	foreach i of numlist 1 2 3 5 6 {
		drop if tg == `i' 
	}
	gen loginuidur = log(inuidur1)
	order treatment loginuidur, before(inuidur1)
	
	la var treatment 	"Treatment"
	la var abdt			"Location within state"
	la var loginuidur	"Log duration of unemployment"
	la var agelt35 		"Age LT 35"
	la var agegt54		"Age GT 54"
	la var female		"Female"
	la var black 		"Black"
	la var hispanic		"Hispanic"
	la var othrace 		"Other race"
	la var dep			"Number of dependents"
	la var q1			"Quarter 1"
	la var q2			"Quarter 2"
	la var q3			"Quarter 3"
	la var q4			"Quarter 4"
	la var q5			"Quarter 5"
	la var q6			"Quarter 6"
	la var recall 		"Recall experiment"
	la var husd			"Type of occupation"
	la var durable		"Durable"
	la var nondurable	"Non-durable"
	
	// Location dummy 
	levelsof abdt, local(LOCS)
	foreach LOC of local LOCS {
		gen loc_`LOC' = (abdt == `LOC') if !mi(abdt)
		la var loc_`LOC' "Location `LOC'"
	}
	
	** Saving variable labels 
	foreach v of var * {
 	local l`v' : variable label `v'
        if `"`l`v''"' == "" {
 		local l`v' "`v'"
		}
	}
 
	** Drop unnecessary variables
	drop v14 v25 v26 lusd muld inuidur2

	** Global covariates
	global covariates "female black hispanic othrace dep q1 q2 q3 q4 q5 q6 recall agelt35 agegt54 durable nondurable husd loc_10404-loc_10880"
	
	** Create second-order terms 
	unab vars : $covariates
	local nvar : word count `vars'
	forval i = 1/`nvar' {
		local x : word `i' of `vars'
		gen `x'X`x'  = `x' * `x' 
		la var `x'X`x' "`l`x'' X `l`x''"
		forval j = 1/`=`i'-1' {
			local x : word `i' of `vars'
			local y : word `j' of `vars'
			gen `x'X`y' = `x' * `y'
			la var `x'X`y' "`l`x'' X `l`y''"
		}
	}
	
	// Dep is the only non-dummy variable, we interact with all covariates 
	foreach var of varlist $covariates {
		gen depsqX`var' = depXdep*`var'
		la var depsqX`var' "Dep$^2$ X `l`var''"
	}
	
	drop loc*loc* // interaction between locations are not informative (only 0)
	
	
	** Save dataset 
	save "$outputpath/LassoAnalysis.dta", replace 


**** END OF DO FILE 
