function get_cal_wheel_scans

  ;; Purpose: get the number of cal wheel and make size consistent
  ;; with what reduction software wants.


  myscans = get_scan_numbers(nscans,procedure='CALSEQ')

  if nscans mod 3 ne 0 then begin
     message,"Number of cal scans not a multiple of 3"
     return, -1
  endif
  
  if nscans eq 0 then begin
     message, "No cal scans found"
     return, -1
  endif

  return, reform(myscans,3,nscans/3)


end
