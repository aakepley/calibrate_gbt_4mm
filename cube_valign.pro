function cube_valign, file_in = file_in $
                      , file_out = file_out $
                      , cube_in = input $
                      , hdr_in = orig_hdr $
                      , hdr_out = new_hdr $
                      , target_hdr = target_hdr $
                      , target_vaxis = target_vaxis $
                      , quiet=quiet $
                      , noreturn=noreturn $
                      , cubic=cubic $
                      , _extra = _extra
;+
; NAME:
;
; cube_valign
;
; PURPOSE:
;
; Accept a file name or a cube + header and a target velocity axis (either in
; a header or as a vector). Aligns the third (velocity) axis of the input cube
; to the target astrometry and either returns the cube or writes it to a new
; file.
;
; CATEGORY:
;
; Science program (sort-of-astrometry utility).
;
; CALLING SEQUENCE:
;
; dummy = cube_valign(file_in = file_in, file_out=file_out 
;                      , target_hdr=target_hdr, /quiet, /noreturn)
;
; -or-
;
; new_cube = cube_valign(cube_in = cube_in, hdr_in=hdr_in, 
;                         , target_vaxis = target_vaxis)
;
; INPUTS:
;
; The program requires a header (hdr_in) and cube (cube_in) to be changed and
; either a velocity axis or a "target" header (target_hdr) containing the
; desired velocity axis. The rest is gravy.
;
; OPTIONAL INPUTS:
;
; CUBE_HASTROM will read the cube+header from file_in and will write a new
; file and header to file_out.
;
; KEYWORD PARAMETERS:
;
; If you don't want the cube (sometimes large) returned then flip the
; /noreturn flag. If you don't want to see the progress counter, flip the
; /quiet flag.
;
; OUTPUTS:
; 
; The newly-aligned cube.
;
; OPTIONAL OUTPUTS:
;
; An updated header (hdr_out) and a file written to disk (file_out).
;
; COMMON BLOCKS:
;
; None.
;
; SIDE EFFECTS:
;
; A profound sense of moral superiority.
;
; RESTRICTIONS:
;
; Corrective lenses.
;
; PROCEDURES USED:
;
; counter (could be commented out w/ no problem), readfits, writefits,
; sx---par, twod_head
;
; MODIFICATION HISTORY:
;
; documented - 09 aug 08 leroy@mpia.de
;
; major bug squash - apr 10 aleroy@nrao.edu
;-

; &$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$
; READ DATA AND DO A BIT OF ERROR CHECKING
; &$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$

; READ FILE FROM DISK IF FILENAME SUPPLIED
  if n_elements(file_in) gt 0 then begin
      input = readfits(file_in,orig_hdr)
  endif

; COPY THE ORIGINAL AND TARGET HEADERS SO WE CAN FUTZ WITH THEM
  hdr_copy = orig_hdr
   
; GET THE SIZES OF THE INPUT DATA SET
  nz = (size(input))[3]
  nx = sxpar(hdr_copy,'NAXIS1')
  ny = sxpar(hdr_copy,'NAXIS2')

; &$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$
; PROCESS THE VELOCITY AXIS OF THE DATA CUBE AS DESIRED
; &$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$

  make_axes, hdr_copy, vaxis=orig_vaxis, /vonly

  if keyword_set(ms_to_kms) then $
     orig_vaxis /= 1e3

  if keyword_set(hel_to_lsr) then begin
; ... TBD
  endif
       
  if keyword_set(lsr_to_hel) then begin
; ... TBD
  endif

; NOTE THE RANGE OF THE ORIGINAL VELOCITY AXIS
  orig_vmax = max(orig_vaxis)
  orig_vmin = min(orig_vaxis)

; &$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$
; WORK OUT THE TARGET VELOCITY AXIS
; &$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$

  if n_elements(target_vaxis) eq 0 then begin
     if n_elements(target_hdr) eq 0 then $
        message, 'Requires either a target velocity axis or a target header.'
     make_axes, target_hdr, /vonly, vaxis=target_vaxis
  endif

  nz_new = n_elements(target_vaxis)

; NOTE THE RANGE OF THE TARGET VELOCITY AXIS
  target_vmax = max(target_vaxis)
  target_vmin = min(target_vaxis)

; NOTE THE STEP SIZE (AND SIGN) IN BOTH AXES
  target_vdelt = target_vaxis[1] - target_vaxis[0]
  orig_vdelt = orig_vaxis[1] - orig_vaxis[0]

; &$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$
; INITIALIZE THE OUTPUT
; &$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$  

; INITIALIZE AN OUTPUT CUBE
  output = dblarr(nx,ny,nz_new)*!values.f_nan

; &$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$  
; WORK OUT THE LINEAR INTERPOLATION
; &$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$  

  interp_ind = $
     where(target_vaxis le orig_vmax and target_vaxis ge orig_vmin $
           , interp_ct)

  if interp_ct gt 0 then begin
     upper_ind = lonarr(interp_ct)
     upper_wt = fltarr(interp_ct)
     lower_ind = lonarr(interp_ct)
     lower_wt = fltarr(interp_ct)

     for i = 0, interp_ct-1 do begin
        target_v = target_vaxis[interp_ind[i]]
        equal_ind = where(target_v eq orig_vaxis, eq_ct)
        if eq_ct eq 1 then begin
           upper_ind[i] = equal_ind
           upper_wt[i] = 0.5
           lower_ind[i] = equal_ind
           lower_wt[i] = 0.5
        endif else begin

           min_dist = $
              min(abs(target_v - orig_vaxis), minind)
           
           if orig_vaxis[minind] gt target_v then begin
              if orig_vdelt gt 0 then begin
                 upper_ind[i] = minind
                 lower_ind[i] = minind-1
              endif else begin
                 upper_ind[i] = minind
                 lower_ind[i] = minind+1                 
              endelse
           endif else begin
              if orig_vdelt gt 0 then begin
                 upper_ind[i] = minind+1
                 lower_ind[i] = minind
              endif else begin
                 upper_ind[i] = minind
                 lower_ind[i] = minind-1
              endelse
           endelse

           upper_wt[i] = abs(orig_vaxis[upper_ind[i]] - target_v)
           lower_wt[i] = abs(orig_vaxis[lower_ind[i]] - target_v)
           total_wt = upper_wt[i] + lower_wt[i]
           upper_wt[i] /= total_wt
           lower_wt[i] /= total_wt
        endelse
     endfor
  endif

; &$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$
; LOOP OVER THE CUBE AND FILL IN THE OUTPUT CUBE (A BIT SLOW)
; &$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$

  if interp_ct gt 0 then begin
     for i = 0, nx-1 do begin
        for j = 0, ny-1 do begin
;       ... TBD: NAN HANDLING, WHICH COULD BE DONE BY WORKING OUT THE LINEAR
;       INTERPOLTION NUMBERS ABOVE AND JUST DOING THE CALCULATION BY HAND
           spec = input[i,j,*]
                                ;interp = interpol(spec,orig_vaxis,
                                ;target_vaxis[interp_ind])        
           interp = upper_wt*spec[upper_ind] + lower_wt*spec[lower_ind]
           output[i,j,interp_ind] = interp
        endfor
     endfor
  endif

; &$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$
; UPDATE THE HEADER
; &$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$

  hdr_out = orig_hdr
  sxaddpar, hdr_out, 'NAXIS',sxpar(orig_hdr,'NAXIS')
  sxaddpar, hdr_out,'NAXIS3',nz_new,after='NAXIS2'

  if n_elements(target_hdr) gt 0 then begin
; ... TBD
  endif else begin
; ... TBD
  endelse
  
; &$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$
; RETURN OR WRITE THE NEW CUBE
; &$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$&$

; IF REQUESTED, WRITE TO DISK
  if n_elements(file_out) gt 0 then begin
      writefits,file_out,output,hdr_out
  endif

; RETURN THE CUBE (UNLESS THE USER REQUESTS NOT)
  if keyword_set(noreturn) then begin
      return, -1
  endif else begin
      return, output
  endelse

end
