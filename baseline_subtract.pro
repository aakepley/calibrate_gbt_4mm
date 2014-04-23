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
scans = get_scan_numbers(/unique)
for i = 0, n_elements(scans) - 1 do begin
   chunk = getchunk(scan=scans[i],count=nchunk)
   for j = 0, nchunk - 1 do begin
      set_data_container, chunk[j]
      baseline
      data_copy, !g.s[0],chunk[j]
   endfor
   putchunk, chunk
   data_free, chunk
endfor

fileout,'junk.fits'

end
