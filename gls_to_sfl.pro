function gls_to_sfl, orig_hdr

;+
; NAME:
;
; gls_to_sfl
;
; PURPOSE:
;
; silly little program to hack a header and change the name of the projection
; from GLS to SFL. Please be careful, though, this is correct only for the new
; GLS. For the old GLS there's an AIPS memo from the mid 80s that describes
; what you need to do, which is basically setting the reference position to
; sit on the equator.
;
; CATEGORY:
;
; glorified string command
;
; CALLING SEQUENCE:
;
; hacked_header = gls_to_sfl(real_header)
;
; INPUTS:
;
; A fits header?
;
; OPTIONAL INPUTS:
;
; nichts
;
; KEYWORD PARAMETERS:
;
; nada
;
; OUTPUTS:
; 
; The SFL header.
;
; OPTIONAL OUTPUTS:
;
; zilch
;
; COMMON BLOCKS:
;
; zero
;
; SIDE EFFECTS:
;
; yup
;
; RESTRICTIONS:
;
; redacted
;
; PROCEDURES USED:
;
;
; MODIFICATION HISTORY:
;
; written - 17 nov 08 leroy@mpia.de
;
;-

; COPY THE ORIGINAL
  hdr_copy = orig_hdr

  ctype1 = sxpar(hdr_copy,'CTYPE1')
  if strcompress(ctype1,/remove_all) eq 'RA---GLS' then $
    sxaddpar, hdr_copy, 'CTYPE1', 'RA---SFL', 'REPLACED GLS'

  ctype2 = sxpar(hdr_copy,'CTYPE2')
  if  strcompress(ctype2,/remove_all) eq 'DEC--GLS' then $
    sxaddpar, hdr_copy, 'CTYPE2', 'DEC--SFL', 'REPLACED GLS'

; RETURN THE FAKE HEADER
  return, hdr_copy
end
