clear
clear matrix
set more off

gl out "C:\Users\Akirawisnu\Dropbox\COVID-Response\pondok-pesantren"
cap mkdir "$out/listponpes"

local link "https://ditpdpontren.kemenag.go.id/pdpp/profil/"
qui{
	forval i=1/27741{
		noi: di in green "Scraping for Ponpes ID: " `i'
		cap copy "`link'`i'" "$out/listponpes/ponpes-`i'.html", replace
		
		import delimited using "$out/listponpes/ponpes-`i'.html", case(lower) delim("|X|", collapse) clear
		
		keep v1
		gen important=.
		replace important=1 if regexm(v1,`"class="nama-pondok"')
		replace important=1 if regexm(v1,`"class="nspp-pondok""')
		replace important=1 if regexm(v1,`"alt="icon kyai"')
		replace important=1 if regexm(v1,`"alt="icon lokasi"')
		replace important=1 if regexm(v1[_n-1],`"<h1>Profil Singkat</h1>"')
		replace important=1 if regexm(v1[_n-3],`"<h1>Profil Singkat</h1>"')
		
		keep if important==1
		
		gen name_pontren=subinstr(v1,`"<h3 class="nama-pondok color-green mgTop-0">"',"",.) in 1
		replace name_pontren=subinstr(name_pontren,`"</h3>"',"",.)
		gen nspp_pontren=subinstr(v1,`"<div class="nspp-pondok">NSPP"',"",.) in 2
		replace nspp_pontren=subinstr(nspp_pontren,`"</div>"',"",.)
		gen hm_pontren=subinstr(v1,`"                        <img src="https://ditpdpontren.kemenag.go.id/pdpp/umum/images/icon-kyai.png" alt="icon kyai">"',"",.) in 3
		gen loc_pontren=v1 in 5
		gen detail_pontren=v1 in 6
		
		drop v1 important
		ds *
		foreach j in `r(varlist)'{
			forval k=1/3{
				replace `j'=`j'[_n-`k'] if `j'==""
				replace `j'=`j'[_n+`k'] if `j'==""
				}
			}
		keep in 1
		gen kode="`i'"
		compress
		ds *
		foreach j in `r(varlist)'{
			replace `j'=trim(`j')
			}
		
		** get important varlist
		if loc_pontren==""{
			gen loc_pontren2=""
			gen loc_pontren3=""
			}
		else{
			split loc_pontren, parse("berdiri pada" "beralamat di")
			}
		if detail_pontren==""{
			gen detail_pontren2=""
			gen detail_pontren3=""
			gen detail_pontren4=""
			}
		else{
			split detail_pontren, parse("jumlah santri pria berjumlah" "dan santri perempuan berjumlah" ", dengan tenaga pengajar berjumlah")
			}
		
		ren loc_pontren2 built_yr_pontren
		ren loc_pontren3 address_pontren
		ren detail_pontren2 male_stud_pontren
		ren detail_pontren3 female_stud_pontren
		ren detail_pontren4 lecturer_pontren
		
		keep kode name_pontren nspp_pontren hm_pontren built_yr_pontren address_pontren male_stud_pontren female_stud_pontren lecturer_pontren
		order kode name_pontren nspp_pontren hm_pontren built_yr_pontren address_pontren male_stud_pontren female_stud_pontren lecturer_pontren
		
		compress
		foreach j in male_stud_pontren female_stud_pontren lecturer_pontren{
			destring `j' , gen(`j'x) i(o r a n g .)
			drop `j'
			ren `j'x `j'
			}
		compress
		tempfile snsd`i'
		saveold `snsd`i'', replace
		
		*copy "$out/ponpes-`i'.html" "$out/listponpes/ponpes-`i'.html", replace
		*rm "$out/ponpes-`i'.html"
		}	
		
	noi: di ""
	noi: di "Starting to Append ALL"
	noi: di ""
	cap drop _all
	forval i=1/27741{
		append using `snsd`i''
		}
	compress
	saveold "$out/dbase-ponpes-may2020.dta", replace
	noi: di "SAVED"
	}

exit