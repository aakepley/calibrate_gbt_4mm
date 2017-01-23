pro calseq,scan,tcold=tcold,ifnum=ifnum,plnum=plnum,fdnum=fdnum,OUTgain
;
;;Computes gain and Tsys for W-band channel 
;
;;Inputs:
;;scan = auto calseq scan
;;tcold = effective temperature of cold load (e.g., 50K)
;;ifnum = IFnum of spectral window
;;plnum = pol-number
;;fdnum = beam-number
;;
;;Output:
;;Prints Tsys and gain and returns OUTgain
;;OUTgain= gain = Twarm-Tcold)/(warm-cold) [K/counts]
;;Tsys=median(gain*sky)
  
if (n_elements(ifnum) eq 0) then ifnum = 0
if (n_elements(fdnum) eq 0) then fdnum = 0
if (n_elements(plnum) eq 0) then plnum = 0
if (n_elements(tcold) eq 0) then tcold = 50.

gettp,scan,plnum=plnum,fdnum=fdnum,ifnum=ifnum,quiet=1,wcalpos='Observing'
vsky=getdata(0)
twarm=!g.s[0].twarm
gettp,scan,plnum=plnum,fdnum=fdnum,ifnum=ifnum,quiet=1,wcalpos='Cold1'
vcold1=getdata(0)
gettp,scan,plnum=plnum,fdnum=fdnum,ifnum=ifnum,quiet=1,wcalpos='Cold2'
vcold2=getdata(0)

;;Feed =1 or 2 for the two possible receiver beams
feed=!g.s[0].feed
gain=0.0
if (feed eq 1) then gain=(twarm-tcold)/median(vcold2-vcold1)
if (feed eq 2) then gain=(twarm-tcold)/median(vcold1-vcold2)
tsys=median(gain*vsky)

print,'Twarm, Tcold:',twarm,tcold
print,'IFNUM, FDNUM, PLNUM:',ifnum,fdnum,plnum
print,'Tsys =',tsys
print,'Gain [K/counts]=',gain
OUTgain=gain

return
end



