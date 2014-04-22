pro cal_spectra_rowend,gain=gain,outfile=outfile

; This routine uses the ends of the rows as the off.

; setting up the output file. should probably do this programmatically
; in the future
fileout, outfile
sprotect_off

; Get which scans are in the map. Here I'm assuming RALongMap, but I
; can easily adapt to DecLatMap
mapscans = get_scan_numbers(count, procedure='RALongMap')
if count eq 0 then mapscans = get_scan_numbers(count, procedure='DecLatMap')

; Get information on the data. Assume that the first scan is
; representative of the entire map
myinfo = scan_info(mapscans[0])
map_nint = myinfo.n_integrations

; ignoring all this for now, but may come back to it for processing
; the other windows and the other polarizations.
map_npol = myinfo.n_polarizations
map_polval = myinfo.polarizations
map_nifs = myinfo.n_ifs 

for i = 0, n_elements(mapscans) - 1 do begin

    setfind, 'scan', mapscans[i]
    setfind, 'polarization', 'YY' 
    setfind, 'ifnum', 0

    setfind, 'int', '0:5'
    setfind, 'int', (map_nint - 5),(map_nint-1),/append
    
    
    fdnum = (i+1) mod 2
    setfind, 'fdnum', fdnum

    ; output the find parameters so I can check the results
    listfind
    
    ; get the off scans and average them
    find
    avgstack

    ; copy the off to a dc
    copy, 0, 1
    off = getdata(0)

    tsysvec=gain[fdnum]*off ; probably want to specify the gain per beam
    vtsys = median(tsysvec)

    ; clear everything for next interation
    emptystack

    ; now go through the integrations and calibrate the ons.
    for j = 0, map_nint - 1 do begin
        
        ; find the right integration
        setfind, 'int', j
        listfind
        find
        
        ; copy the integration to the main dc
        getrec, astack(0)
        
        ; calculate the Ta
        copy, 0, 2
        subtract, 2, 1
        divide, 0, 1
        
        ; put calibrated data back in main dc
        vec = getdata(0)
        vec1 = vtsys * vec
        
        !g.s[0].units='Ta'
        !g.s[0].tsys=vtsys
        setdata,vec1

        ; save to the output file
        keep

        ; reset for next
        emptystack

    endfor
        
endfor

sprotect_on

end


;----------------------------------------------------------------------

pro cal_spectra_offbeam, gain=gain, outfile=outfile

; This routine uses the "off-beams" to calibrate the row sandwiched between.

; setting up the output file. should probably do this programmatically
; in the future
fileout, outfile
sprotect_off

; Get which scans are in the map. Here I'm assuming RALongMap, but I
; can easily adapt to DecLatMap
mapscans = get_scan_numbers(count, procedure='RALongMap')
if count eq 0 then mapscans = get_scan_numbers(count, procedure='DecLatMap')

; Get information on the data. Assume that the first scan is
; representative of the entire map
myinfo = scan_info(mapscans[0])
map_nint = myinfo.n_integrations

; ignoring all this for now, but may come back to it for processing
; the other windows and the other polarizations.
map_npol = myinfo.n_polarizations
map_polval = myinfo.polarizations
map_nifs = myinfo.n_ifs 

; I'm not going to process the first and last rows because they don't
; have offs.
for i = 1, n_elements(mapscans) - 2 do begin

    setfind, 'polarization', 'YY' 
    setfind, 'ifnum', 0

    fdnum = (i+1) mod 2
    setfind, 'fdnum', fdnum

    setfind, 'scan', mapscans[i-1] 
    setfind, 'int', map_nint-5,map_nint-1

    listfind

    ; get the off scans and average them
    find

    setfind, 'scan', mapscans[i+1]
    setfind, 'int', 0,5

    listfind

    find,/append
    
    avgstack

    ; copy the off to a dc
    copy, 0, 1
    off = getdata(0)

    tsysvec=gain[fdnum]*off ; probably want to specify the gain per beam
    vtsys = median(tsysvec)

    ; clear everything for next interation
    emptystack
    clearfind

    ; setting up for data scans
    setfind, 'scan', mapscans[i]
    setfind, 'fdnum', fdnum
    setfind, 'polarization', 'YY' 
    setfind, 'ifnum', 0
    
    ; now go through the integrations and calibrate the ons.
    for j = 0, map_nint - 1 do begin
        
        ; find the right integration
        setfind, 'int', j
        
        listfind
        find
        
        ; copy the integration to the main dc
        getrec, astack(0)
        
        ; calculate the Ta
        copy, 0, 2
        subtract, 2, 1
        divide, 0, 1
        
        ; put calibrated data back in main dc
        vec = getdata(0)
        vec1 = vtsys * vec
        
        !g.s[0].units='Ta'
        !g.s[0].tsys=vtsys
        setdata,vec1

        ; save to the output file
        keep

        ; reset for next
        emptystack


    endfor

    clearfind
        
endfor

sprotect_on

end

;----------------------------------------------------------------------

pro cal_spectra_otf, scanno, gain, ra_border, dec_border, docos=docos, $
                     outfile=outfile

; Purpose: calibrate a continuous stream of map data using dumps
; a specified number of pixels from the edge of the map. It assumes
; that the map is somewhat rectangular.

; Inputs:
;       scanno: scan number of map
;       gain:   gain to use for map
;       ra_border: size of border region to use for offs in arcmin
;       dec_border: size of border region to use for offs in arcmin
;       docos: flag to set whether or not we correct for cos
;       theta. probably want to do this most times.
;       outfile: output filename
;
; Outputs:
;       calibrated spectra in file name outfile
;
; Date          Programmer              Description of Changes
;----------------------------------------------------------------------
; 2/27/2013     A.A. Kepley             Original Code

; set defaults if I don't have yet.
if n_elements(docos) eq 0 then docos=1
if n_elements(outfile) eq 0 then outfile = 'junk.fits'

; opening output file
fileout, outfile
sprotect_off

; Get info on map
myinfo = scan_info(scanno)
map_nint = myinfo.n_integrations
nchan = myinfo.n_channels

; ignoring all this for now, but may come back to it for processing
; the other windows and the other polarizations.
map_npol = myinfo.n_polarizations
map_polval = myinfo.polarizations
map_nifs = myinfo.n_ifs 

; get position
rip_positions, scanno, intnum, inttime, ra, dec

; get size of map
ra_size = max(ra) - min(ra)
ra_center = mean(ra)

dec_size = max(dec) - min(dec)
dec_center = mean(dec)

; Decide I want to correct for cos theta
if docos then begin
    costerm = cos(dec_center * !pi/180.0)
endif else begin
    costerm = 1.0
endelse

; check on border size
if ra_border/60.0 ge ra_size/2.0 then begin
    message, "RA border size greater than map size."
    return
endif

; check on border size
if dec_border/60.0 ge dec_size/2.0 then begin
    message, "Dec border size greater than map size."
    return
endif

; identify edges.
edges = where( abs(ra - ra_center) gt (ra_size/2.0 - ra_border/(60.0*costerm)) or $
               abs(dec - dec_center) gt (dec_size/2.0 - dec_border/60.0), $
               count)

; warn user if no edges selected
if count eq 0 then begin
    message, "no integrations selected for offs"
    return
endif

; check edges
plot, ra, dec,/ynozero
oplot, ra[edges], dec[edges], psym=2

; create array for identifying references
refarray = intarr(n_elements(ra))
refarray[edges] = 1.0

; label the different off regions
off_region = label_region(refarray)
n_off_region = histogram(off_region)

; find the ons
sigarray = refarray eq 0

; label the ons
on_region = label_region(sigarray)
; For some reason the on_region isn't properly labeling the endpoints
; of the array. The below is a kludge to fix this because I know that
; the first and last integrations of the scan are "on".
on_region[0] = 1
on_region[n_elements(on_region) - 1] = max(on_region)
n_on_region = histogram(on_region)

; calibrate all integrations doing it a chunk at a time.
for i = 1, n_elements(n_on_region) - 1.0 do begin
    
    ; find the on integrations for this chunk
    this_chunk = where(on_region eq i,Non)

    ; create off
    emptystack
    ; choose appropriate offs
    case i of
        1: appendstack, intnum[where(off_region eq i,count)]
        n_elements(n_on_region) - 1: appendstack, intnum[where(off_region eq i-1,count)]
        else: appendstack, intnum[where(off_region eq i-1 or off_region eq i,count)]
    endcase
    
    ; average all the offs
    tellstack
    avgstack

    ; save the off
    copy, 0, 1
    off = getdata(0)
    
    ; calculate the system temperature
    tsysvec=gain*off 
    vtsys = median(tsysvec)
    
    ; now loop through all the integrations in the on and calibrate
    for j = 0, Non - 1 do begin

        print, j, intnum[this_chunk[j]]
        getrec,  intnum[this_chunk[j]]
        copy, 0, 2
        subtract, 2, 1
        divide, 0, 1
        
        vec = getdata(0)
        vec1 = vtsys * vec
        
        !g.s[0].units='Ta'
        !g.s[0].tsys=vtsys
        setdata,vec1
        
        ; save to the output file
        keep      

    endfor

endfor

sprotect_on

end

; ----------------------------------------------------------------------

pro cal_spectra_rowend_nobeamswitch,gain=gain,outfile=outfile

; This routine uses the ends of the rows as the off.

; setting up the output file. should probably do this programmatically
; in the future
fileout, outfile
sprotect_off

; Get which scans are in the map. Here I'm assuming RALongMap, but I
; can easily adapt to DecLatMap
mapscans = get_scan_numbers(count, procedure='RALongMap')
if count eq 0 then mapscans = get_scan_numbers(count, procedure='DecLatMap')

; Get information on the data. Assume that the first scan is
; representative of the entire map
myinfo = scan_info(mapscans[0])
map_nint = myinfo.n_integrations

; ignoring all this for now, but may come back to it for processing
; the other windows and the other polarizations.
map_npol = myinfo.n_polarizations
map_polval = myinfo.polarizations
map_nifs = myinfo.n_ifs 

for i = 0, n_elements(mapscans) - 1 do begin

    setfind, 'scan', mapscans[i]
    setfind, 'polarization', 'YY' 
    setfind, 'ifnum', 0

    setfind, 'int', '0:5'
    setfind, 'int', (map_nint - 5),(map_nint-1),/append
    
    
;    fdnum = (i+1) mod 2
    fdnum = 0
    setfind, 'fdnum', fdnum

    ; output the find parameters so I can check the results
    listfind
    
    ; get the off scans and average them
    find
    avgstack

    ; copy the off to a dc
    copy, 0, 1
    off = getdata(0)

    tsysvec=gain*off ; probably want to specify the gain per beam
    vtsys = median(tsysvec)

    ; clear everything for next interation
    emptystack

    ; now go through the integrations and calibrate the ons.
    for j = 0, map_nint - 1 do begin
        
        ; find the right integration
        setfind, 'int', j
        listfind
        find
        
        ; copy the integration to the main dc
        getrec, astack(0)
        
        ; calculate the Ta
        copy, 0, 2
        subtract, 2, 1
        divide, 0, 1
        
        ; put calibrated data back in main dc
        vec = getdata(0)
        vec1 = vtsys * vec
        
        !g.s[0].units='Ta'
        !g.s[0].tsys=vtsys
        setdata,vec1

        ; save to the output file
        keep

        ; reset for next
        emptystack

    endfor
        
endfor

sprotect_on

end


;----------------------------------------------------------------------
