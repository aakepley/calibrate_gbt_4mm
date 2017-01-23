function vanecal_func,scan1,$
                      ifnum=ifnum,$
                      fdnum=fdnum,$
                      plnum=plnum
;
;;Computes Tsys values for Argus beams for ifnum 
;
;;Inputs:
;;scan1 = vane scan (sky scan assume to be scan1+1)
;;ifnum = IFnum of spectral window
;;plnum = pol-number =0 for argus
;;fdnum = beam-number -1 for argus
;;
;;Output:
;;Prints approximate effective Tsys* for each beam (Tsys* = Tsys *exp(tau)/eta_l)
;;
;; Tsys*=Tcal[Coff]/[Con-Coff]
  
if (n_elements(ifnum) eq 0) then ifnum = 0

;;get center beam scan for ATM parameters
gettp,scan1,ifnum=ifnum,fdnum=10

;;Compute Tcal
;;twarm in C
twarm=!g.s[0].twarm+273.15
time=!g.s[0].mjd
el=!g.s[0].elevation
freq = !g.s[0].reference_frequency/1.e9
;elevation not available in data during maintenance
getatmos,el=el,mjd=time,freq=freq,outvals
if (n_elements(tau) eq 0) then tau=outvals(0)
tatm=outvals(2)
am=1./sin(el*!pi/180.)

;;
tbg=2.725
tcal=(tatm -tbg) + (twarm-tatm)*exp(tau*am)

print,'Tcal, Twarm, tatm:',tcal,twarm,tatm

;; for i=0,15 do begin
;;   getsigref,scan1,scan1+1,ifnum=ifnum,fdnum=i,/quiet
;;   tsys_beam[i] = tcal/median(getdata(0))  
;;   print,'beam, Tsys*[K]: ',i+1, tsys_beam[i]  
;; endfor

getsigref,scan1,scan1+1,ifnum=ifnum,fdnum=fdnum,plnum=plnum,/quiet
tsys_beam = tcal/median(getdata(0))
print,'beam, Tsys*[K]: ',fdnum+1, tsys_beam  

gettp, scan1+1,ifnum=ifnum,fdnum=fdnum,plnum=plnum,/quiet
gain_beam = tsys_beam / median(getdata(0))

return, gain_beam

end



