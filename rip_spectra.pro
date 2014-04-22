pro rip_spectra, infiles, savefile

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

; figures out the number of records in each file.
nfiles = n_elements(infiles)
nints = intarr(n_elements(infiles))

for i = 0, nfiles - 1 do begin    
    filein,infiles[i]
    nints[i] = nrecords()
endfor

nspectra = total(nints)
filein,infiles[0]
myscans = get_scan_numbers()
myinfo = scan_info(myscans[0])
nchan = myinfo.n_channels

; Creating the arrays to hold the output spectra
ra = dblarr(nspectra)
dec = dblarr(nspectra)
velocity = dblarr(nspectra, nchan)

; now go back into files and get the spectra.
for i = 0, nfiles - 1 do begin

    filein, infiles[i]

    for j = 0, nints[i] - 1 do begin
        
        case i of
            0: startint = 0
            1: startint = nints[0]
            else: startint = total(nints[0:i-1])
        endcase

        getrec, j
        print, j,  !g.s[0].longitude_axis, !g.s[0].latitude_axis
        ra[j+startint] = !g.s[0].longitude_axis
        dec[j+startint] = !g.s[0].latitude_axis
        velocity[j+startint, * ] = *!g.s[0].data_ptr        

    endfor

endfor

; Saving the resulting arrays in a savefile
save, ra, dec, velocity, filename=savefile        
        
end
