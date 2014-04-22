pro getaipsbeam, hdr_in, bmaj=bmaj, bmin=bmin, bpa=bpa $
                 , found=found, verbose=verbose $
                 , forward=forward

; VERBOSE is diagnostic, don't actually use it.

; Works on this type of line:
; HISTORY AIPS   CLEAN BMAJ=  1.7599E-03 BMIN=  1.5740E-03 BPA=   2.61

; REVERSE THE HEADER TO GET THE MOST RECENT BEAM  
  hdr = keyword_set(forward) ? hdr_in : reverse(hdr_in)

  found = 0B
  wherefound = -1
  for i = 0,n_elements(hdr)-1 do begin
     here = strpos(hdr[i],'BMAJ')
     if (here ne -1) then begin
        found = found+1
        if (wherefound eq -1) then wherefound = i
     endif
  endfor
  
  if (keyword_set(verbose)) then begin
     if (found eq 0) then begin
         print, 'GETAIPSBEAM: No beam information found. Stopping.'
         STOP
      endif else begin
         print, 'GETAIPSBEAM: found ', found, ' lines with a beam in it.'
      endelse
   endif
  
  if (found gt 0) then begin
     line = hdr[wherefound]
     bmaj_pos = strpos(line,'BMAJ')
     bmin_pos = strpos(line,'BMIN')
     bpa_pos = strpos(line,'BPA')
     bmaj = float(strmid(line,bmaj_pos+5,bmin_pos-1-(bmaj_pos+5)))
     bmin = float(strmid(line,bmin_pos+5,bpa_pos-1-(bmin_pos+5)))
     bpa = float(strmid(line,bpa_pos+4,strlen(line)-(bpa_pos+4)))
  endif

end
