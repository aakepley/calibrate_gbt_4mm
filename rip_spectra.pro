pro rip_spectra, infiles, savefile, droplast=droplast

; Purpose: Take RA, Dec, and Spectra for each position

; Input:
;       filelist: list of files to do this for

; Output:
;
;       ra: array of ras
;
;       dec: array of decs
;       
;       spectra: array of spectra
;
;       savefile: file to save everything in


; Date          Programmer              Description of Changes
; ----------------------------------------------------------------------
; 7/23/2012     A.A. Kepley             Original Code
; 5/10/2013     A.A. Kepley             Modified to allow each map to
;                                       have a different number of integrations

; check inputs
if n_elements(infiles) eq 0 then begin
    message,/info,"Please input a list of files to get ras and decs from"
    return
endif

if n_elements(savefile) eq 0 then begin
    message,/info,"Please give the name of a save file to save the resulting arrays in"
    return
 endif

; drop last integration, which might be bad.
if n_elements(droplast) eq 0 then droplast = 1

; figures out the number of records in each file.
nfiles = n_elements(infiles)
nints = intarr(n_elements(infiles))

for i = 0, nfiles - 1 do begin    
    filein,infiles[i]
    nints[i] = nrecords()
endfor

nspectra = total(nints)
filein,infiles[0]

; now go back into files and get the spectra.
for i = 0, nfiles - 1 do begin

    filein, infiles[i]

    scans = get_scan_numbers(/unique)

    for j = 0, n_elements(scans) - 1 do begin

       row = getchunk(scan=scans[j],count=rowints)
       
       if droplast then lastint = rowints - 2 else lastint = rowints-1
       
       ; if first data, initialize vectors. Otherwise add to them.
       if i eq 0 and j eq 0 then begin
          ra = row.longitude_axis
          dec = row.latitude_axis
          velocity = *row[0].data_ptr
          for k = 1, lastint do velocity = [[velocity],[*row[k].data_ptr]]
       endif else begin
          ra = [ra, row.longitude_axis]
          dec = [dec, row.latitude_axis]
          for k = 0, lastint do velocity = [[velocity],[*row[k].data_ptr]]
       endelse

       data_free, row

    endfor

endfor

velocity = transpose(velocity)

; Saving the resulting arrays in a savefile
save, ra, dec, velocity, filename=savefile        
        
end
