pro baseline_subtract, myinfile, myoutfile, myorder, myregion

; Purpose: subtract a baseline from each spectrum in a map
;
; Input:
;       myinfile: input filename
;
;       myoutfile: output filename
;       
;       myorder: order of fit
;
;       myregion: region to fit over (vector)
; 
; Output:
;
;       baseline subtracted spectra in outfile
;
; Date          Programmer              Description of Changes
; ----------------------------------------------------------------------
; 7/23/2012     A.A. Kepley             Original Code

if n_elements(myinfile) eq 0 then begin
    message,/info,"Please give input file to process"
    return
endif

if n_elements(myoutfile) eq 0 then begin
    message,/info,"Please give output file to process"
    return
endif

if n_elements(myorder) eq 0 then begin
    message,/info,"Please give the polynomial order you wish to fit"
    return
endif

if n_elements(myregion) eq 0 then begin
    message,/info, "Please give the region you wish to fit (in channels)"
    return
endif

print, 'Input file: ', myinfile
filein, myinfile

print, 'Output file: ', myoutfile
fileout, myoutfile

nregion, myregion
nfit, myorder

;; going through scans and baseline subtracting
print, 'Baseline subtraction order ', myorder
for j = 0, nrecords() - 1 do begin
    getrec, j
    baseline
    keep
endfor

fileout,'junk.fits'

end
