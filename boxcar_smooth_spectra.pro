pro boxcar_smooth_spectra, myfilein, myfileout, mynchan

; Purpose: smooth data to desired resolution.

; Input:
;       myfilein: file to smooth spectra 
;       
;       myfileout: output file
;       
;       nchan: number of channels to boxcar smooth.
;
;  Output:
;       fileout with smooth spectra
;
;  Date         Programmer              Description of Changes
;----------------------------------------------------------------------
; 7/23/2012     A.A. Kepley             Original Code
; 5/7/2013      A.A. Kepley             Modified for pipeline

if n_elements(myfilein) eq 0 then begin
    message,/info,"Please give file to process."
    return
endif

if n_elements(myfileout) eq 0 then begin
    message,/info,"Please give output file name."
    return
endif

if n_elements(mynchan) eq 0 then begin
    message,/info,"Please give the number of channels you wish to smooth."
    return
endif

print, 'Input file: ', myfilein
filein, myfilein

print, 'Output file: ', myfileout
fileout, myfileout

;; getting number of scans
print, 'boxcar smoothing by ', mynchan
for j = 0, nrecords() - 1 do begin
    getrec, j
    boxcar, mynchan,/decimate
    keep
endfor

fileout, 'junk.fits'

end
