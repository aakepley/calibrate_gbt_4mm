pro calc_snu, myinfile, cal_scans, calwheel_scans, S_nu,$
                 ifnum=ifnum,fdnum=fdnum,$
                 mb_eff=mb_eff,$
                 twarm=twarm,tcold=tcold,$
                 outfile=myoutfile
                 
; Purpose: calculate the main beam efficiency and the aperture
; efficiency
;
; Input:
;       myinfile: file with calibration data
;
;       cal_scans: calibration source scan numbers
;
;       calwheel_scan: calibration wheel scan numbers
;
;       S_nu: flux density of calibration source
;
;       ifnum: IF number to calculate this for.
;
; Output:
;
;       mb_eff: main beam efficiency
;
;       ap_eff: aperture efficiency
;
; Date          Programmer              Description of Changes
;----------------------------------------------------------------------
; 5/8/2013      A.A. Kepley             Original Code

;; Check and setup the parameters
if n_params() ne 4 then begin
    message,/info,"calc_Snu, myinfile,cal_scans,calwheel_scans,S_nu,ifnum=ifnum,fdnum=fdnum,mb_eff=mb_eff"
    return
endif

if ((size(calwheel_scans))[1] ne 3) then begin
    message,/info, "Cal wheel scans come in sets of three"
    return
endif

if n_elements(ifnum) eq 0 then ifnum=0
if n_elements(twarm) eq 0 then twarm=280 ;K
if n_elements(tcold) eq 0 then tcold=50 ; K
if n_elements(fdnum) eq 0 then fdnum=0

if n_elements(myoutfile) ne 0 then begin
    fileout,myoutfile
    dokeep=0
endif else dokeep=0

filein, myinfile

; calculate the gains
n_calwheel_scans = (size(calwheel_scans))[0]

avggain = dblarr(4)

if n_calwheel_scans eq 1 then begin
    mygains = calseq_sp_4mm(calwheel_scans,twarm=twarm,tcold=tcold,ifnum=ifnum)  
    avggain = mygains
endif else begin
    mygains = dblarr(4,n_calwheel_scans)
    for i = 0, n_calwheel_scans - 1 do begin
        mygains[*,i] = calseq_sp_4mm(calwheel_scans[*,i],twarm=twarm,tcold=tcold,ifnum=ifnum)
    endfor
    avggain = total(mygains,2) / n_calwheel_scans
endelse


; calibrating the flux calibrator scans.
sclear
n_cal_scans = n_elements(cal_scans)
gettp,cal_scans[0]

mytime = !g.s[0].mjd
myfreq = !g.s[0].observed_frequency/1e9
myelev = !g.s[0].elevation
mytau = getatmos(mytime,myfreq)

for i = 0, n_cal_scans - 1 do begin

    if fdnum eq 0 then begin
        pl0chan = 0
        pl1chan = 1
    endif else begin
        pl0chan = 2
        pl1chan = 3
    endelse

    wonoff_gain, cal_scans[i],cal_scans[i]+1,avggain[pl0chan],ifnum=ifnum,plnum=0
    accum
    wonoff_gain, cal_scans[i],cal_scans[i]+1,avggain[pl1chan],ifnum=ifnum,plnum=1
    accum
    
endfor

ave

; Calculating the aperture and main beam efficiencies
A = 1/cos((90.0 - myelev) * !dpi/180.0)
coeff = exp(mytau * A) / mb_eff
scale,coeff
stats,ret=mystats
S_nu = mystats.mean
print, 'S_nu (Jy) = ', S_nu

; saving the resulting spectrum if necessary
if dokeep then keep

end
