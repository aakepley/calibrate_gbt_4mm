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
; 6/7/2016      A.A. Kepley             modified to use getchunk and putchunk

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

freeze 

scans = get_scan_numbers(/unique)

for i = 0, n_elements(scans) - 1 do begin

   chunk = getchunk(scan=scans[i],count=nchunk)

   for j = 0, nchunk -1 do begin
      
      tmp  = chunk[j]

      dcboxcar,tmp,mynchan,/decimate

      chunk[j] = tmp

   endfor

   putchunk,chunk
   data_free,chunk

endfor


fileout, 'junk.fits'

end
