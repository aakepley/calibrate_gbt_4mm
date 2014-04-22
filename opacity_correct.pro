pro opacity_correct, myinfile, myoutfile, mb_eff, mjd_int=mjd_int

;; Purpose: correct the input spectra for the atmospheric opacity and
;; main beam efficiency. The main beam efficiency needs to be
;; calculated from the flux calibrator observations.
;;
;; Input:
;;
;;      myinfile: file of input spectra
;;
;;      myoutfile: file of output spectra
;;
;;      mb_eff: main beam efficiency. This quantity needs to be
;;      calculate from the flux calibrator observations.
;
;       mjd_int: interval in minutes to calculate the opacity
;;
;; Output:
;;
;;      spectra corrected for the main beam efficiency and atmospheric
;;      opacity in fileout
;;
;;
;; Method: 
;;
;;      Based on equations in 4mm chapter of observer's guide to
;;      the GBT. Units are not entirely clear, so I'm going to ask David
;;      Frayer about them when he gets back.
;;      
;;      T_mb = T_a * exp(tau_0 * A) / nu_mb
;;
;;      where T_mb is the main beam temperature, tau_0 is the
;;      atmospheric opacity at zenith, A is the airmass, and nu_mb is
;;      the main beam efficiency. I'm using the getatmos.pro program
;;      to calculate the atmospheric opacity from Ron Maddalena's
;;      models. Ron says that the models are only calculated one an
;;      hour. Any sampling more frequently than that is just
;;      interpolated between the two times. When I interpolate to find
;;      the opacity for the individual integrations from the values
;;      returned from getatmos.pro, it may not be numerically
;;      stable. However, since things appear to be well-behaved for
;;      now I'm going to live with it.
;;
;;      To calculate the main beam efficiency.
;;
;;      nu_mb = 0.8899 * nu_a * (theta_FWHM * D / lambda)^2
;;
;;      where nu_a is the aperture efficiency of the GBT, theta_FHWM
;;      is the FWHM of the beam size in radians, D is the diameter of
;;      the GBT (100m) [UNITS?] and lambda is the observing wavelength
;;      [UNITS?].
;;
;;      theta_FWHM [radians] = (1.02 + 0.0135 Te(Db) ) * lambda / 100m 
;;
;;      where Te(Db) is the edge taper of the feed's illumination of
;;      the dish in decibels and is typically 14 +/- 2 dB.
;;
;;      To calculate nu_a, I need a observation of a source of known
;;      flux density (S_nu [UNITS?]), then
;;
;;      nu_a = 0.3516 * Ta * exp(tau_0 * A) / S_nu
;;
;;      I'm going to calculate nu_a using my calibration
;;      observations. The correction here will be specified in mb_eff,
;;      so that I can easily change as needed.
;;
;;
;; Date         Programmer              Description of Changes
;;----------------------------------------------------------------------
;; 5/7/2013     A.A. Kepley             Original Code

if n_params() ne 3 then begin
    message,/info,"opacity_correct,myinfile,myoutfile,mb_eff"
    return
endif

if n_elements(mjd_int) eq 0 then mjd_int = 5.0

filein,myinfile
fileout,myoutfile ;; why is this throwing an error?

; I'm going to get a grid of opacities and then use the interpolate
; function to get the opacity for particular sample. This should take
; less time than getting all of them. Do I want to use getatmos as is
; or to use the startMJD, stopMJD, and incrMJD options to get the grid.

; Getting the opacities at the beginning and end of the 
getrec, 0
obs_freq = !g.s[0].observed_frequency/1e9
startMJD = !g.s[0].mjd

getrec, nrecords() - 1
stopMJD = !g.s[0].mjd

incrMJD = mjd_int / (60.0 * 24.0) ; increment every mjd_int minutes

getatmos_arr, obs_freq,startMJD,stopMJD,incrMJD,tau_0_arr,mjd_arr    

for i = 0, nrecords() - 1 do begin

    getrec, i
    
    ;; calculate the opacity
    if n_elements(tau_0_arr) eq 1 then begin
       tau_0 = tau_0_arr
    endif else begin
       tau_0 = interpol(tau_0_arr,mjd_arr,!g.s[0].mjd)
    endelse

       
;    print, tau_0

    ;; get the airmass. For angles less than 60deg, then A = sec z =
    ;; 1/cos(z) = 1/cos (90-elev)
    A = 1/cos((90.0 - !g.s[0].elevation) * !dpi/180.0)
   
    coeff = exp(tau_0 * A) / mb_eff

    scale, coeff

    ;show

    ;stop
    keep

endfor

fileout,'junk.fits'

end
