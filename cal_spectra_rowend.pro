; ----------------------------------------------------------------------

pro cal_spectra_rowend,infile, outfile,$
                       ifnum=ifnum,plnum=plnum,fdnum=fdnum, gain=gain,$
                       noffs=noffs,declatmap=declatmap

; Purpose: do the initial calibration of the spectrum (ON-OFF) for
; each ifnum and polarization. This calibration uses the ends of the
; rows as the off.

; Inputs:

;       
;       outfile: name of output file
;       
;       ifnum: if number to be calibrated
;       
;       plnum: polarization number to be calibrated
;
;       fdnum: feed number to be calibrated (should be mapfdnum)
;
;       gain: gain for particular channel from calseq_sp_4mm
;
;       declatmap: if not set or zero then process as
;       RALongMap. Otherwise process as DecLatMap.
;
; Method:
;       The channel outputs for the W-band receiver (as of Winter
;       2013) are 
;       chan 1: plnum=0, fdnum=0
;       chan 3: plnum=1, fdnum=0
;       chan 5: plnum=0, fdnum=1
;       chan 7: plnum=1, fdnum=1

; Outputs:
;       calibrated spectra in out file
;
; Date          Programmer      Description of Changes
; ----------------------------------------------------------------------
; 2/?/2013      A.A. Kepley     Original Code 
; 5/6/2013      A.A. Kepley     modified to be more general

; setting up parameters
if n_elements(ifnum) eq 0 then ifnum = 0
if n_elements(plnum) eq 0 then plnum = 0
if n_elements(fdnum) eq 0 then fdnum = 0
if n_elements(noffs) eq 0 then noffs = 5
if n_elements(declatmap) eq 0 then declatmap = 0

if n_elements(gain) eq 0 then begin
   message, "Please give a valid gain."
   return
endif

if n_elements(outfile) eq 0 then outfile = 'junk.fits'

if n_elements(infile) eq 0 then begin
   message, "Please give an infile"
   return
endif

; setting up the input file
filein, infile

; setting up the output file
fileout, outfile
sprotect_off

; Get which scans are in the map. 
if not declatmap then begin
   mapscans = get_scan_numbers(count, procedure='RALongMap')
endif else begin
   mapscans = get_scan_numbers(count, procedure='DecLatMap')
endelse

; check to make sure we have a map
if count eq 0 then begin
   message, "No Map Scans Found"
   return
endif

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

   ;; get offs
   offlist = indgen(2*noffs)
   offlist[noffs:2*noffs-1] =  map_nint - reverse(indgen(noffs) ) - 1
   offchunk = getchunk(scan=mapscans[i], $
                       plnum=plnum, $
                       ifnum=ifnum, $
                       fdnum=fdnum, $
                       int=offlist, count=noffchunks)
   sclear
   for j = 0, noffchunks -1 do accum, dc=offchunk[j]
   ave

   data_free, offchunk
   
   ;; copy the off to a dc
   copy, 0, 1
   off = getdata(0)

   tsysvec=gain*off             ;; probably want to specify the gain per beam
   vtsys = median(tsysvec)

   ; get all the integrations for a row.
   rowchunk = getchunk(scan=mapscans[i], $
                       plnum=plnum, $
                       ifnum=ifnum, $
                       fdnum=fdnum, $
                       count=nrowchunks)

   ;; now go through the integrations and calibrate the ons.
   for j = 0, nrowchunks - 1 do begin
        
      set_data_container, rowchunk[j]
        
      ;; calculate the Ta
      copy, 0, 2
      subtract, 2, 1
      divide, 0, 1
        
      ;; put calibrated data back in main dc
      vec = getdata(0)
      vec1 = vtsys * vec
        
      !g.s[0].units='Ta'
      !g.s[0].tsys=vtsys
      setdata,vec1

      data_copy, !g.s[0], rowchunk[j]

   endfor  

   putchunk, rowchunk
   data_free, rowchunk

endfor



sprotect_on

fileout,'junk.fits'

end


;----------------------------------------------------------------------
