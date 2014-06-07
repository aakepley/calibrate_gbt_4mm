; Purpose: calibrate spectra for HCN, HCO+ maps
;
; Date          Programmer              Description of Changes
; ----------------------------------------------------------------------
; 5/8/2013      A.A. Kepley             Original Code
; 2/12/2014     A.A. Kepley             Updated for use with NGC2146
; 3/20/2014     A.A. Kepley             Modified for use with VEGAS

;----------------------------------------------------------------------
;                        Calibration Parameters
;----------------------------------------------------------------------

; Change the parameters below to alter the calibration. You may need
; to change the flagging manually below in the main body of the program.

; Data
mydataprefix = '/home/thales/scratch/akepley/gbt_hcn_test/n6946/data/'
mydata = 'N6946_11_DecLatMap_1.raw.vegas'
origdata = mydataprefix+mydata

mapfdnum = 0 ; feed number that is mapping the galaxy

doflag = 1 ; Do initial flagging on bad center channel? Only needs to be done once.
dosmooth =  80 ; Do initial smoothing on data? Only needs to be done once. 0 if not. nchan if yes

; Calibration scan info
mytwarm = 270; K. THIS VALUE NEEDS TO BE UPDATED FOR 14A VALUE
mytcold = 50 ; K. DOUBLE-CHECK THIS VALUE.

noffs = 4 ; number of intergations to use for the off

; baseline fitting
norder = 1
nregion = [50,150,250,400]

; main beam efficiency
mb_eff = [0.263,0.292,0.263,0.292]  ;; THIS VALUE NEEDS TO BE UPDATED FOR 14A VALUE

dofinalsmooth = 0
ngauss = 10; number of channels to gaussian smooth the final spectrum to. 

;----------------------------------------------------------------------
;               End Calibration Parameters
;----------------------------------------------------------------------

freeze

;; Flagging
;; ------------------------------

if doflag then begin
   
   print, "Flagging"

   ; bad center channel
   initial_flag,origdata,fdnum=0,plnum=0,ifnum=0,chans=16384
   initial_flag,origdata,fdnum=0,plnum=1,ifnum=0,chans=16384
   initial_flag,origdata,fdnum=0,plnum=0,ifnum=1,chans=16384
   initial_flag,origdata,fdnum=0,plnum=1,ifnum=1,chans=16384
   initial_flag,origdata,fdnum=1,plnum=0,ifnum=0,chans=16384
   initial_flag,origdata,fdnum=1,plnum=1,ifnum=0,chans=16384
   initial_flag,origdata,fdnum=1,plnum=0,ifnum=1,chans=16384
   initial_flag,origdata,fdnum=1,plnum=1,ifnum=1,chans=16384
   
   ; spikes in middle of data. Worse in YY polarization
   initial_flag,origdata,fdnum=0,plnum=0,ifnum=0,chans=[16316,16334,16335,16359,16409,16433,16434,16452,16481]  
   initial_flag,origdata,fdnum=0,plnum=0,ifnum=1,chans=[16236,16285,16483,16532]
   initial_flag,origdata,fdnum=1,plnum=0,ifnum=0,chans=[16286,16316,16335,16433,16452]
   initial_flag,origdata,fdnum=1,plnum=0,ifnum=1,chans=[16286,16316,16335,16360,16408,16433,16452,16482]
   initial_flag,origdata,fdnum=1,plnum=0,ifnum=1,bchan=15933,echan=15996
   initial_flag,origdata,fdnum=1,plnum=0,ifnum=1,bchan=16778,echan=16839
         
endif

;; Initial Smoothing
;; ------------------

gaussfile = mydata + '.gauss.fits'

if dosmooth GT 0 then begin

   print, "initial smoothing"

   gauss_smooth_spectra,origdata,gaussfile,dosmooth
   
endif


; Calculating Gain values
; -----------------------

print, "Calculating Gain Values"

filein, gaussfile

cal_wheel_scans = get_cal_wheel_scans()

n_cal_wheel_scans = (size(cal_wheel_scans))[0]

if n_cal_wheel_scans eq 1 then begin

    mygains_if0 = calseq_sp_4mm(cal_wheel_scans,twarm=mytwarm,tcold=mytcold,ifnum=0)
    mygains_if1 = calseq_sp_4mm(cal_wheel_scans,twarm=mytwarm,tcold=mytcold,ifnum=1)
    
endif else begin
    
    mygains = dblarr(4,n_cal_wheel_scans)
    for i = 0, n_cal_wheel_scans - 1 do begin
        mygains[*,i] = calseq_sp_4mm(cal_wheel_scans[*,i],twarm=mytwarm,tcold=mytcold,ifnum=0)
    endfor

    mygains_if0 = total(mygains,2) / n_cal_wheel_scans

    mygains = dblarr(4,n_cal_wheel_scans)
    for i = 0, n_cal_wheel_scans - 1 do begin
        mygains[*,i] = calseq_sp_4mm(cal_wheel_scans[*,i],twarm=mytwarm,tcold=mytcold,ifnum=1)
    endfor

    mygains_if1 = total(mygains,2) / n_cal_wheel_scans
  

endelse

; Calibrating the individual spectra
; ----------------------------------

print, "Calibrating Individual Spectra"

if mapfdnum eq 0 then begin
   pl0chan = 0
   pl1chan = 1
endif else begin
   pl0chan = 2
   pl1chan = 3
endelse

cal_file_if0_pl0 = mydata + '.cal_if0_pl0_fd'+string(mapfdnum,format='(I1)')+'.fits'
cal_spectra_rowend,gaussfile,cal_file_if0_pl0,$
                   ifnum=0,plnum=0,fdnum=mapfdnum,gain=mygains_if0[pl0chan],$
                   noffs=noffs

cal_file_if0_pl1 = mydata + '.cal_if0_pl1_fd'+string(mapfdnum,format='(I1)')+'.fits'
cal_spectra_rowend,gaussfile,cal_file_if0_pl1,$
                   ifnum=0,plnum=1,fdnum=mapfdnum,gain=mygains_if0[pl1chan],$
                   noffs=noffs

cal_file_if1_pl0 = mydata + '.cal_if1_pl0_fd'+string(mapfdnum,format='(I1)')+'.fits'
cal_spectra_rowend,gaussfile,cal_file_if1_pl0,$
                   ifnum=1,plnum=0,fdnum=mapfdnum,gain=mygains_if1[pl0chan],$
                   noffs=noffs

cal_file_if1_pl1 = mydata + '.cal_if1_pl1_fd'+string(mapfdnum,format='(I1)')+'.fits'
cal_spectra_rowend,gaussfile,cal_file_if1_pl1,$
                   ifnum=1,plnum=1,fdnum=mapfdnum,gain=mygains_if1[pl1chan],$
                   noffs=noffs


; Baseline Subtraction
; --------------------

print, "Baseline Subtracting"

cal_file_if0_pl0_bsub = mydata + '.cal_if0_pl0_fd'+string(mapfdnum,format='(I1)')+'_bsub.fits'
baseline_subtract,cal_file_if0_pl0, cal_file_if0_pl0_bsub,norder,nregion

cal_file_if0_pl1_bsub = mydata + '.cal_if0_pl1_fd'+string(mapfdnum,format='(I1)')+'_bsub.fits'
baseline_subtract,cal_file_if0_pl1, cal_file_if0_pl1_bsub,norder,nregion

cal_file_if1_pl0_bsub = mydata + '.cal_if1_pl0_fd'+string(mapfdnum,format='(I1)')+'_bsub.fits'
baseline_subtract,cal_file_if1_pl0, cal_file_if1_pl0_bsub,norder,nregion

cal_file_if1_pl1_bsub = mydata + '.cal_if1_pl1_fd'+string(mapfdnum,format='(I1)')+'_bsub.fits'
baseline_subtract,cal_file_if1_pl1, cal_file_if1_pl1_bsub,norder,nregion



; Opacity correction and TMB conversion
; -------------------------------------

print, "Opacity and TMB Correction"

cal_file_if0_pl0_bsub_opacity = mydata + '.cal_if0_pl0_fd'+string(mapfdnum,format='(I1)')+'_tau.fits'
opacity_correct,cal_file_if0_pl0_bsub,cal_file_if0_pl0_bsub_opacity,mb_eff[0]

cal_file_if0_pl1_bsub_opacity = mydata + '.cal_if0_pl1_fd'+string(mapfdnum,format='(I1)')+'_tau.fits'
opacity_correct,cal_file_if0_pl1_bsub,cal_file_if0_pl1_bsub_opacity,mb_eff[0]

cal_file_if1_pl0_bsub_opacity = mydata + '.cal_if1_pl0_fd'+string(mapfdnum,format='(I1)')+'_tau.fits'
opacity_correct,cal_file_if1_pl0_bsub,cal_file_if1_pl0_bsub_opacity,mb_eff[1]

cal_file_if1_pl1_bsub_opacity = mydata + '.cal_if1_pl1_fd'+string(mapfdnum,format='(I1)')+'_tau.fits'
opacity_correct,cal_file_if1_pl1_bsub,cal_file_if1_pl1_bsub_opacity,mb_eff[1]


; Final Smoothing 
; ----------------

if dofinalsmooth then begin

   print, "Final Smoothing"

   gaussfile_if0_pl0 = mydata + '.cal_if0_pl0_fd'+string(mapfdnum,format='(I1)') + '_gauss.fits'
   gauss_smooth_spectra,cal_file_if0_pl0_bsub_opacity,gaussfile_if0_pl0,ngauss

   gaussfile_if0_pl1 = mydata + '.cal_if0_pl1_fd'+string(mapfdnum,format='(I1)') + '_gauss.fits'
   gauss_smooth_spectra,cal_file_if0_pl1_bsub_opacity,gaussfile_if0_pl1,ngauss

   gaussfile_if1_pl0 = mydata + '.cal_if1_pl0_fd'+string(mapfdnum,format='(I1)') + '_gauss.fits'
   gauss_smooth_spectra,cal_file_if1_pl0_bsub_opacity,gaussfile_if1_pl0,ngauss

   gaussfile_if1_pl1 = mydata + '.cal_if1_pl1_fd'+string(mapfdnum,format='(I1)') + '_gauss.fits'
   gauss_smooth_spectra,cal_file_if1_pl1_bsub_opacity,gaussfile_if1_pl1,ngauss

endif

; Reset Plotter
; -------------

unfreeze

end
