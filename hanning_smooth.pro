pro hanning_smooth, myfilein, myfileout

; Purpose: hanning smooth data
;
; Input:
;       myfilein: file to hanning smooth
;
;       myfileout: output file
;
; Output:
;       fileout with hanning smoothed spectra
;
; Method:
;
;       to get chunk values to update correctly, need to create tmp
;       then pass onto chunk. data_copy doesn't work correctly
;       because passing array, which is by value rather than by reference.
; 
; Date          Programmer      Description of Changes
;----------------------------------------------------------------------
; 6/7/2016      A.A. Kepley     modified original code to use getchunk
;                               and putchunk and error messages.

if n_elements(myfilein) eq 0 then begin
    message,/info,"Please give file to process."
    return
endif

if n_elements(myfileout) eq 0 then begin
    message,/info,"Please give output file name."
    return
endif

print, 'Input file: ', myfilein
filein,myfilein

print, 'Output file: ', myfileout
fileout, myfileout

freeze

scans = get_scan_numbers(/unique)

for i = 0, n_elements(scans) - 1 do begin

   chunk = getchunk(scan=scans[i],count=nchunk)

   for j = 0, nchunk -1 do begin
      
      tmp  = chunk[j]

      dchanning,tmp,/decimate,ok=ok

      if not ok then begin
         message, 'Hanning smoothed failed on index ', i
         data_free, chunk
         return
      endif

      chunk[j] = tmp

   endfor

   putchunk,chunk
   data_free,chunk

endfor

fileout, 'junk.fits'

;; for i = 0, nrecords() - 1 do begin

;;     getrec, i
;;     hanning,/decimate,ok=ok
;;     if not ok then begin
;;         message,'Hanning smoothed failed on index ', i
;;         return
;;     endif

;;     keep

;; endfor

;; fileout, 'junk.fits'

end
