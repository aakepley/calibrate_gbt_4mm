function get_temp, path_to_fits=path_to_fits

; Purpose: get warm and cold temperature for HCN / HCO+ observing sessions
;
; Date          Programmer              Description of Changes
; ----------------------------------------------------------------------
; 3/13/2014     C. Lee                  Original Code
; 3/17/2014     L. Barcos-Munoz         Slightly modified (path_to_fits


if n_elements(path_to_fits) eq 0 then begin
   name=''
   session=''
   Rcvr=''
   READ, name, PROMPT='Enter the name of the project (e.g: AGBT14A_437): '
   READ, session, PROMPT='Enter the session number (e.g: 08): '
   READ, Rcvr, PROMPT='Enter the Receiver name (e.g: Rcvr68_92): '
   path_to_fits='/home/gbtdata/'+name+'_'+session+'/'+Rcvr+'/'
   ;message, "Please provide the path to the receiver fits files when you call this function. [e.g. med_temp = get_temp(path_to_fits = '/home/gbtdata/AGBT14A_437A_05/Rcvr68_92/') ] "
;   path_to_fits = '/home/gbtdata/AGBT14A_437_05/Rcvr68_92/'
endif

raw_rcvr_fits_list = file_search(path_to_fits + '*.fits')

n_raw_rcvr_fits = n_elements(raw_rcvr_fits_list)

twarm_arr = dblarr(n_raw_rcvr_fits -1)
tcold_arr = dblarr(n_raw_rcvr_fits -1)
time_arr = dblarr(n_raw_rcvr_fits -1)


for i=0, n_raw_rcvr_fits-2 do begin


   this_hdr = headfits(raw_rcvr_fits_list[i+1])

   twarm_arr[i] = sxpar(this_hdr, "TWARM")
   tcold_arr[i] = sxpar(this_hdr, "TCOLD")

   ; TBD : need to think about how to get time..
   ; "DATE-OBS" has the time in the unit of 'YYYY-MM-DDTHH:MM:SS'
;  stop
endfor

print, median(twarm_arr), mean(twarm_arr), stddev(twarm_arr), $
       median(tcold_arr), mean(tcold_arr), stddev(tcold_arr)


return, median(twarm_arr)

end
