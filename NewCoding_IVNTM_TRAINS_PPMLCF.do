================================
  20250122 IVNTM+TRAINS+PPMLCF
================================
This is part of my working paper, showing recent work and empirical regressions, including 
1) calculation of instrumental variables, 
2) re-cleaning of UNCTAD TRAINS data, 
3) merging original panel data with TRAINS and IVs, 
4) complete regression code, and 
5) code for Figure 1, 
earlier tasks like CEPII-BACI and WTO I-TIP data cleaning were completed prior to this course.
Some of the code is taken from previous files, including baseline ppml, heckman，heterogeniety; others are new.

The log file only includes regressions and figure1 because: 
1) the original panel data was completed prior to this course, and 
2) I forgot to enable and save the logs for the recent cleaning of TRAINS and IV_NTM data. 
Given the large and complex nature of international trade and NTMs datasets, I decided not to replicate the logs.

================================================================Part 1==========
**get IVSPS and IVTBT （无视注释，验证无误）
***IVSPS_WTO_number
gen sps_sum = SPSN1_Sum  

bysort year HS6 (iso3num_d): gen sps_sum_excl_j = sum(sps_sum) - sps_sum
bysort year HS6 (iso3num_d): gen avg_sps_sum_excl_j = sps_sum_excl_j / (_N - 1) 

bysort year iso3num_d (HS6): gen sps_sum_excl_k = sum(sps_sum) - sps_sum
bysort year iso3num_d (HS6): gen avg_sps_sum_excl_k = sps_sum_excl_k / (_N - 1)

gen cross_avg_sps_sum = avg_sps_sum_excl_j * avg_sps_sum_excl_k

gen IV_SPS_sum = 0
replace IV_SPS_sum = 1 if cross_avg_sps_sum > 0

***IVSPS_WTO_dummy
gen sps_dum = 1 if SPSN1_Dum > 0  
replace sps_dum = 0 if SPSN1_Dum <= 0

bysort year HS6 (iso3num_d): gen sps_dum_excl_j = sum(sps_dum) - sps_dum
bysort year HS6 (iso3num_d): gen avg_sps_dum_excl_j = sps_dum_excl_j / (_N - 1) 

bysort year iso3num_d (HS6): gen sps_dum_excl_k = sum(sps_dum) - sps_dum
bysort year iso3num_d (HS6): gen avg_sps_dum_excl_k = sps_dum_excl_k / (_N - 1)

gen cross_avg_sps_dum = avg_sps_dum_excl_j * avg_sps_dum_excl_k

gen IV_SPS_dum = 0
replace IV_SPS_dum = 1 if cross_avg_sps_dum > 0

***IVTBT_WTO_number
gen tbt_sum = TBTN1_Sum  

bysort year HS6 (iso3num_d): gen tbt_sum_excl_j = sum(tbt_sum) - tbt_sum
bysort year HS6 (iso3num_d): gen avg_tbt_sum_excl_j = tbt_sum_excl_j / (_N - 1) 

bysort year iso3num_d (HS6): gen tbt_sum_excl_k = sum(tbt_sum) - tbt_sum
bysort year iso3num_d (HS6): gen avg_tbt_sum_excl_k = tbt_sum_excl_k / (_N - 1)

gen cross_avg_tbt_sum = avg_tbt_sum_excl_j * avg_tbt_sum_excl_k

gen IV_TBT_sum = 0
replace IV_TBT_sum = 1 if cross_avg_tbt_sum > 0

***IVTBT_WTO_dummy
gen tbt_dum = 1 if TBTN1_Sum > 0  
replace tbt_dum = 0 if TBTN1_Sum <= 0

bysort year HS6 (iso3num_d): gen tbt_dum_excl_j = sum(tbt_dum) - tbt_dum
bysort year HS6 (iso3num_d): gen avg_tbt_dum_excl_j = tbt_dum_excl_j / (_N - 1)  

bysort year iso3num_d (HS6): gen tbt_dum_excl_k = sum(tbt_dum) - tbt_dum
bysort year iso3num_d (HS6): gen avg_tbt_dum_excl_k = tbt_dum_excl_k / (_N - 1)

gen cross_avg_tbt_dum = avg_tbt_dum_excl_j * avg_tbt_dum_excl_k

gen IV_TBT_dum = 0
replace IV_TBT_dum = 1 if cross_avg_tbt_dum > 0
================================================================================

================================================================Part 2==========
**clean TRAINS dataset（drop duplicates done iso3 and iso3num，and rename _d）
***fit iso3_d and iso3num_d
merge m:1 iso3num_d using "C:\Users\UnlimitedFate\OneDrive\桌面\CNEXP_CEPII_BACI_TRAINS_WTO_NTMs_HS6新\2025改动_IVNTM_NewTRAINS\countries_iso3_iso3num_fit.dta", nogenerate
drop in 208081/208192 **手动 drop 样本外的国家
***list sample countries list
preserve
duplicates drop iso3num_d iso3_d, force
keep iso3num_d iso3_d
duplicates drop iso3num_d iso3_d, force
keep iso3num_d iso3_d
save "C:\Users\UnlimitedFate\OneDrive\桌面\CNEXP_CEPII_BACI_TRAINS_WTO_NTMs_HS6新\2025改动_IVNTM_NewTRAINS\countries_iso3_iso3num_reference.dta"
restore
***clean this panel，未区分SPS(A)和TBT(B)(watch out -foreach-, the laptop might boooooom)
keep if (hscode_cleaned_replaced >= 30000 & hscode_cleaned_replaced <= 39999) | (hscode_cleaned_replaced >= 160300 & hscode_cleaned_replaced <= 160599)
keep if affected_iso3=="CHN"
keep if year >= 2005 & year <= 2019
rename iso3 iso3_d
rename ntm NTMs_term
rename hscode_cleaned_replaced HS6

local folder_path "D:\文档\trains_iso3_hs6\test" 
cd "`folder_path'"
local files : dir "`folder_path'" files "*.csv"

foreach file in `files' {
    di "正在处理文件：`file'"

    import delimited "`folder_path'/`file'", clear

    keep if (hscode_cleaned_replaced >= 30000 & hscode_cleaned_replaced <= 39999) | (hscode_cleaned_replaced >= 160300 & hscode_cleaned_replaced <= 160599)
	keep if affected_iso3=="CHN"
	keep if year >= 2005 & year <= 2019
	rename iso3 iso3_d
	rename ntm NTMs_term
	rename hscode_cleaned_replaced HS6

    local dta_filename = subinstr("`file'", ".csv", ".dta", .)
    save "`folder_path'/`dta_filename'", replace

    di "已保存为：`dta_filename'"
}

di "所有文件处理完成！"

clear all
cd "C:\Users\UnlimitedFate\OneDrive\桌面\CNEXP_CEPII_BACI_TRAINS_WTO_NTMs_HS6新\2025改动_IVNTM_NewTRAINS\TRAINS_Clean" 
local files : dir . files "*.dta"

gen source_file = "" 

local i = 1
foreach file of local files {
    if `i' == 1 {
        
        use `"`file'"', clear
        gen source_file = "`file'" 
    }
    else {
        
        append using `"`file'"'
    }
    local i = `i' + 1
}

*divide SPS and TBT
preserve
keep if strpos(NTMs_term, "A") > 0
gen SPS_TRAINS = 1
restore
preserve
keep if strpos(NTMs_term, "B") > 0
gen TBT_TRAINS = 1
restore

*SPS_SUM and DUM
gen sps_count = .
bysort iso3_d year HS6 ( SPS_TRAINS ): gen SPS_TRAINS_SUM = _N if _n == _N
bysort iso3_d year HS6 ( SPS_TRAINS ): replace SPS_TRAINS_SUM = _N
duplicates drop iso3_d year HS6 SPS_TRAINS , force
gen SPS_TRAINS_DUM = SPS_TRAINS
*SPS_SUM and DUM
gen tbt_count = .
bysort iso3_d year HS6 ( TBT_TRAINS ): gen TBT_TRAINS_SUM = _N if _n == _N
bysort iso3_d year HS6 ( TBT_TRAINS ): replace TBT_TRAINS_SUM = _N
duplicates drop iso3_d year HS6 TBT_TRAINS , force
gen TBT_TRAINS_DUM = TBT_TRAINS
================================================================================

================================================================Part 3==========
*merge dataset(IVs>>>main panel)
merge 1:1 year  HS6 iso3_d using "C:\Users\UnlimitedFate\OneDrive\桌面\CNEXP_CEPII_BACI_TRAINS_WTO_NTMs_HS6新\2025改动_IVNTM_NewTRAINS\TRAINS_append_SPS_SUM_DUM_ready.dta"
drop if _merge==2
replace SPS_TRAINS_SUM = 0 if missing(SPS_TRAINS_SUM)
replace SPS_TRAINS_DUM = 0 if missing(SPS_TRAINS_DUM)
drop _merge
*merge dataset(TRAINS>>>main panel)
merge 1:1 year  HS6 iso3_d using "C:\Users\UnlimitedFate\OneDrive\桌面\CNEXP_CEPII_BACI_TRAINS_WTO_NTMs_HS6新\2025改动_IVNTM_NewTRAINS\TRAINS_append_TBT_SUM_DUM_ready.dta"
drop if _merge==2
replace TBT_TRAINS_SUM = 0 if missing(TBT_TRAINS_SUM)
replace TBT_TRAINS_DUM = 0 if missing(TBT_TRAINS_DUM)
drop _merge
================================================================================

================================================================Part 4==========
**************************************
***现在有全新的面板了 +IVNTM+TRAINS***
**************************************
egen code_d=group(iso3num_d)
  tabulate code_d,generate(d_fe)
egen hs_d=group( HS6 )
  tabulate hs_d,generate(HS_fe)
egen code_year=group(year)
  tabulate code_year,generate(year_fe)
global fe d_fe* HS_fe* year_fe*

*****Regression*****************************************************************
***Benchmark (i should use -ppmlhdfe-)
ppml value $fe lndist lnpop_d lngdp_d fta_wto comlang_off contig SPSN1_Sum TBTN1_Sum, cluster (iso3num_d)

***Robustness: Dummy
ppml value $fe lndist lnpop_d lngdp_d fta_wto comlang_off contig SPSN1_Dum TBTN1_Dum, cluster (iso3num_d)

***Robustness：TRAINS (only sue sum)
ppmlhdfe value lndist lnpop_d lngdp_d fta_wto comlang_off contig SPS_TRAINS_SUM TBT_TRAINS_SUM , absorb( year iso3num_d HS6 ) cluster( iso3num_d )
ppmlhdfe value lndist lnpop_d lngdp_d fta_wto comlang_off contig SPS_TRAINS_DUM TBT_TRAINS_DUM , absorb( year iso3num_d HS6 ) cluster( iso3num_d )

***Robustness: Heckman
gen lnvalue=ln(value)
heckman lnvalue lndist lnpop_d lngdp_d fta_wto contig SPSN1_Sum TBTN1_Sum i.code_d i.hs_d i.code_year, select(lndist lnpop_d lngdp_d fta_wto contig comlang_off SPSN1_Sum TBTN1_Sum i.code_d i.hs_d i.code_year) vce (robust)

****Robustness：IV_NTM+PPML+CF ()
*lagged
egen id=group( iso3num_d HS6 )
xtset id year
gen LSPSN1_Sum=L.SPSN1_Sum
gen LTBTN1_Sum =L.TBTN1_Sum
gen lvalue=ln(value+0.01)

egen code_d=group(iso3num_d)
  tabulate code_d,generate(d_fe)
egen hs_d=group( HS6 )
  tabulate hs_d,generate(HS_fe)
egen code_year=group(year)
  tabulate code_year,generate(year_fe)
global fe d_fe* HS_fe* year_fe* 

ppmlhdfe value lndist lnpop_d lngdp_d fta_wto comlang_off contig LSPSN1_Sum LTBTN1_Sum, absorb( year iso3num_d HS6 ) cluster( iso3num_d )

*PPMLHDFE全包?
ppmlhdfe SPSN1_Sum IV_SPS_sum lndist lnpop_d lngdp_d fta_wto comlang_off contig, absorb( year iso3num_d HS6 ) cluster( iso3num_d )
predict double SPS_hat, xb
gen double SPS_resid = SPSN1_Sum - exp(SPS_hat)

ppmlhdfe TBTN1_Sum IV_TBT_sum lndist lnpop_d lngdp_d fta_wto comlang_off contig, absorb( year iso3num_d HS6 ) cluster( iso3num_d )
predict double TBT_hat, xb
gen double TBT_resid = TBTN1_Sum - exp(TBT_hat)

ppmlhdfe value SPSN1_Sum TBTN1_Sum SPS_resid TBT_resid lndist lnpop_d lngdp_d fta_wto comlang_off contig, absorb( year iso3num_d HS6 ) cluster( iso3num_d )

***Heterogeneity of Products 
local hs6_values "030110 030191 030192 030193 030199 030211 030212 030219 030221 030222 030223 030229 030231 030232 030233 030239 030240 030250 030261 030262 030263 030264 030265 030266 030269 030270 030310 030321 030322 030329 030331 030332 030333 030339 030341 030342 030343 030349 030350 030360 030371 030372 030373 030374 030375 030376 030377 030378 030379 030380 030410 030420 030490 030510 030520 030530 030541 030542 030549 030551 030559 030561 030562 030563 030569 030611 030612 030613 030614 030619 030621 030622 030623 030624 030629 030710 030721 030729 030731 030739 030741 030749 030751 030759 030760 030791 030799 160300 160411 160412 160413 160414 160415 160416 160419 160420 160430 160510 160520 160530 160540 160590"

foreach value in `hs6_values' {
use "C:\Users\UnlimitedFate\OneDrive\桌面\CNEXP_CEPII_BACI_TRAINS_WTO_NTMs_HS6新\CN_CEPII_BACI_TRAINS_WTO_HS6_136cnty_EST_3.dta" 

preserve
    keep if HS6 == `value'
    egen code_d=group(iso3num_d)
      tabulate code_d,generate(d_fe)
    egen code_year=group(year)
      tabulate code_year,generate(year_fe)
    global fe d_fe* year_fe*

ppml value SPSN1_Sum TBTN1_Sum $fe

est store HS`value'
esttab HS`value',se mtitle star(* 0.1 ** 0.05 *** 0.01) r2 label, using "C:\Users\UnlimitedFate\OneDrive\桌面\NTMs图表202410\分组讨论_产品_稳健标准误\HS`value'", replace b(%6.3f) 
restore
}

esttab HS*,se mtitle star(* 0.1 ** 0.05 *** 0.01) r2 label, using "C:\Users\UnlimitedFate\OneDrive\桌面\NTMs图表202410\分组讨论_产品_稳健标准误\HS.csv", replace b(%6.3f)

***Heterogeneity of Economies 
preserve
keep if iso3num_d==8 | iso3num_d==10 | iso3num_d==20 | iso3num_d==36 | iso3num_d==40 | iso3num_d==56 | iso3num_d==60 | iso3num_d==70 | iso3num_d==100 | iso3num_d==112 | iso3num_d==124 | iso3num_d==162 | iso3num_d==166 | iso3num_d==191 | iso3num_d==196 | iso3num_d==203 | iso3num_d==208 | iso3num_d==233 | iso3num_d==234 | iso3num_d==246 | iso3num_d==248 | iso3num_d==250 | iso3num_d==276 | iso3num_d==292 | iso3num_d==300 | iso3num_d==304 | iso3num_d==334 | iso3num_d==336 | iso3num_d==348 | iso3num_d==352 | iso3num_d==372 | iso3num_d==376 | iso3num_d==380 | iso3num_d==392 | iso3num_d==428 | iso3num_d==438 | iso3num_d==440 | iso3num_d==442 | iso3num_d==470 | iso3num_d==492 | iso3num_d==498 | iso3num_d==499 | iso3num_d==528 | iso3num_d==554 | iso3num_d==574 | iso3num_d==578 | iso3num_d==616 | iso3num_d==620 | iso3num_d==642 | iso3num_d==643 | iso3num_d==666 | iso3num_d==674 | iso3num_d==680 | iso3num_d==688 | iso3num_d==703 | iso3num_d==705 | iso3num_d==724 | iso3num_d==744 | iso3num_d==752 | iso3num_d==756 | iso3num_d==804 | iso3num_d==807 | iso3num_d==826 | iso3num_d==831 | iso3num_d==832 | iso3num_d==833 | iso3num_d==840 | iso3num_d==158
ppml value $fe lndist lnpop_d lngdp_d fta_wto comlang_off contig SPSN1_Sum TBTN1_Sum, cluster (iso3num_d)

ppmlhdfe SPSN1_Sum IV_SPS_sum lndist lnpop_d lngdp_d fta_wto comlang_off contig, absorb( year iso3num_d HS6 ) cluster( iso3num_d )
predict double SPS_hat, xb
gen double SPS_resid = SPSN1_Sum - exp(SPS_hat)

ppmlhdfe TBTN1_Sum IV_TBT_sum lndist lnpop_d lngdp_d fta_wto comlang_off contig, absorb( year iso3num_d HS6 ) cluster( iso3num_d )
predict double TBT_hat, xb
gen double TBT_resid = TBTN1_Sum - exp(TBT_hat)

ppmlhdfe value SPSN1_Sum TBTN1_Sum SPS_resid TBT_resid lndist lnpop_d lngdp_d fta_wto comlang_off contig, absorb( year iso3num_d HS6 ) cluster( iso3num_d )
restore

preserve
keep if iso3num_d==4 | iso3num_d==12 | iso3num_d==16 | iso3num_d==24 | iso3num_d==28 | iso3num_d==31 | iso3num_d==32 | iso3num_d==44 | iso3num_d==48 | iso3num_d==50 | iso3num_d==51 | iso3num_d==52 | iso3num_d==64 | iso3num_d==68 | iso3num_d==72 | iso3num_d==74 | iso3num_d==76 | iso3num_d==84 | iso3num_d==86 | iso3num_d==90 | iso3num_d==92 | iso3num_d==96 | iso3num_d==104 | iso3num_d==108 | iso3num_d==116 | iso3num_d==120 | iso3num_d==132 | iso3num_d==136 | iso3num_d==140 | iso3num_d==144 | iso3num_d==148 | iso3num_d==152 | iso3num_d==156 | iso3num_d==170 | iso3num_d==174 | iso3num_d==175 | iso3num_d==178 | iso3num_d==180 | iso3num_d==184 | iso3num_d==188 | iso3num_d==192 | iso3num_d==204 | iso3num_d==212 | iso3num_d==214 | iso3num_d==218 | iso3num_d==222 | iso3num_d==226 | iso3num_d==231 | iso3num_d==232 | iso3num_d==238 | iso3num_d==239 | iso3num_d==242 | iso3num_d==254 | iso3num_d==258 | iso3num_d==260 | iso3num_d==262 | iso3num_d==266 | iso3num_d==268 | iso3num_d==270 | iso3num_d==275 | iso3num_d==288 | iso3num_d==296 | iso3num_d==308 | iso3num_d==312 | iso3num_d==316 | iso3num_d==320 | iso3num_d==324 | iso3num_d==328 | iso3num_d==332 | iso3num_d==340 | iso3num_d==344 | iso3num_d==356 | iso3num_d==360 | iso3num_d==364 | iso3num_d==368 | iso3num_d==384 | iso3num_d==388 | iso3num_d==398 | iso3num_d==400 | iso3num_d==404 | iso3num_d==408 | iso3num_d==410 | iso3num_d==414 | iso3num_d==417 | iso3num_d==418 | iso3num_d==422 | iso3num_d==426 | iso3num_d==430 | iso3num_d==434 | iso3num_d==446 | iso3num_d==450 | iso3num_d==454 | iso3num_d==458 | iso3num_d==462 | iso3num_d==466 | iso3num_d==474 | iso3num_d==478 | iso3num_d==480 | iso3num_d==484 | iso3num_d==496 | iso3num_d==500 | iso3num_d==504 | iso3num_d==508 | iso3num_d==512 | iso3num_d==516 | iso3num_d==520 | iso3num_d==524 | iso3num_d==531 | iso3num_d==533 | iso3num_d==534 | iso3num_d==535 | iso3num_d==540 | iso3num_d==548 | iso3num_d==558 | iso3num_d==562 | iso3num_d==566 | iso3num_d==570 | iso3num_d==580 | iso3num_d==581 | iso3num_d==583 | iso3num_d==584 | iso3num_d==585 | iso3num_d==586 | iso3num_d==591 | iso3num_d==598 | iso3num_d==600 | iso3num_d==604 | iso3num_d==608 | iso3num_d==612 | iso3num_d==624 | iso3num_d==626 | iso3num_d==630 | iso3num_d==634 | iso3num_d==638 | iso3num_d==646 | iso3num_d==652 | iso3num_d==654 | iso3num_d==659 | iso3num_d==660 | iso3num_d==662 | iso3num_d==663 | iso3num_d==670 | iso3num_d==678 | iso3num_d==682 | iso3num_d==686 | iso3num_d==690 | iso3num_d==694 | iso3num_d==702 | iso3num_d==704 | iso3num_d==706 | iso3num_d==710 | iso3num_d==716 | iso3num_d==728 | iso3num_d==729 | iso3num_d==732 | iso3num_d==740 | iso3num_d==748 | iso3num_d==760 | iso3num_d==762 | iso3num_d==764 | iso3num_d==768 | iso3num_d==772 | iso3num_d==776 | iso3num_d==780 | iso3num_d==784 | iso3num_d==788 | iso3num_d==792 | iso3num_d==795 | iso3num_d==796 | iso3num_d==798 | iso3num_d==800 | iso3num_d==818 | iso3num_d==834 | iso3num_d==850 | iso3num_d==854 | iso3num_d==858 | iso3num_d==860 | iso3num_d==862 | iso3num_d==876 | iso3num_d==882 | iso3num_d==887 | iso3num_d==894
ppml value $fe lndist lnpop_d lngdp_d fta_wto comlang_off contig SPSN1_Sum TBTN1_Sum, cluster (iso3num_d)

ppmlhdfe SPSN1_Sum IV_SPS_sum lndist lnpop_d lngdp_d fta_wto comlang_off contig, absorb( year iso3num_d HS6 ) cluster( iso3num_d )
predict double SPS_hat, xb
gen double SPS_resid = SPSN1_Sum - exp(SPS_hat)

ppmlhdfe TBTN1_Sum IV_TBT_sum lndist lnpop_d lngdp_d fta_wto comlang_off contig, absorb( year iso3num_d HS6 ) cluster( iso3num_d )
predict double TBT_hat, xb
gen double TBT_resid = TBTN1_Sum - exp(TBT_hat)

ppmlhdfe value SPSN1_Sum TBTN1_Sum SPS_resid TBT_resid lndist lnpop_d lngdp_d fta_wto comlang_off contig, absorb( year iso3num_d HS6 ) cluster( iso3num_d )
restore
================================================================================

================================================================Part 5==========
***Figure 1
gen totalquantity = spsquantity + tbt 
twoway (area totalquantity year, color(gs10) yaxis(1) lcolor(black) lpattern(solid)) (area spsquantity year, color(blue%50) yaxis(1) lcolor(blue) lpattern(solid)) (line valuemillion year, yaxis(2) lcolor(blue) lpattern(dash)), ytitle("Quantity (SPS & TBT)") ytitle("Value (in million)", axis(2)) xtitle("Year") legend(label(1 "TBT Quantity (stacked)") label(2 "SPS Quantity") label(3 "Value (in million, dashed)")) title("Stacked Area and Dashed Line Chart") scheme(s2color)
**OR
twoway (area totalquantity year, color(gs12) yaxis(1) lcolor(gs8) lpattern(solid)) (area spsquantity year, color(gs14) yaxis(1) lcolor(gs10) lpattern(solid)) (line valuemillion year, yaxis(2) lcolor(blue) lpattern(dash) mcolor(blue) msymbol(circle) msize(small)), ytitle("Quantity (SPS & TBT)") ytitle("Value (in million)", axis(2)) xtitle("Year") legend(label(1 "TBT Quantity (stacked)") label(2 "SPS Quantity") label(3 "Value (in million, dashed with points)")) scheme(s2color)



