pro wgetps_cal,twarm=twarm,tcold=tcold,plnum=plnum,fdnum=fdnum,ifnum=ifnum,son,soff,swarm,scold
;
;;Computes and calibrate using gettp for W-band input Tsys=vtsys
;
;;son = on scan
;;soff = off scan
;;plnum = pol-number
;;fdnum = beam-number
;;vtsys = Tsys [K] for Ta

;;Get ON
gettp,son,plnum=plnum,fdnum=fdnum,ifnum=ifnum
copy,0,1

;;Get OFF
gettp,soff,plnum=plnum,fdnum=fdnum,ifnum=ifnum
;;Reference smoothing  (not recommended in general)
;if (nsmooth gt 1) then begin
;   rawdata=getdata(0)
;   smdata=smooth(rawdata,nsmooth,/nan,/edge_truncate)
;   setdata,smdata
;endif
copy,0,2

;;Get WARM scan
gettp,swarm,plnum=plnum,fdnum=fdnum,ifnum=ifnum
copy,0,3

;;Get COLD scan
gettp,scold,plnum=plnum,fdnum=fdnum,ifnum=ifnum
copy,0,4


;; Ta=(twarm-tcold)*(ON-OFF)/(warm-cold)
subtract,1,2
copy,0,5
subtract,3,4
copy,0,6
divide,5,6
vec=getdata(0)
vec=vec*(twarm-tcold)
!g.s[0].units='Ta'


;;compute Tsys
;;warm-cold
vec1=getdata(6)
;off
vec2=getdata(2)
;;tsys=g*voff
tsysvec=(twarm-tcold)*vec2/vec1

vtsys=median(tsysvec)
print,'Median Tsys across band',vtsys
!g.s[0].tsys=vtsys

setdata,vec

return
end



