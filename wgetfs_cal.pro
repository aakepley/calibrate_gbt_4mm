pro wgetfs_cal,twarm=twarm,tcold=tcold,plnum=plnum,fdnum=fdnum,ifnum=ifnum,scan,swarm,scold
;
;;Computes and calibrate using gettp for W-band input Tsys=vtsys
;
;;son = on scan
;;soff = off scan
;;plnum = pol-number
;;fdnum = beam-number
;;vtsys = Tsys [K] for Ta

;;Get ON
gettp,scan,plnum=plnum,fdnum=fdnum,ifnum=ifnum,sig_state=0
copy,0,1

;;Get OFF
gettp,scan,plnum=plnum,fdnum=fdnum,ifnum=ifnum,sig_state=1
;;Reference smoothing  (not recommended in general)
;if (nsmooth gt 1) then begin
;   rawdata=getdata(0)
;   smdata=smooth(rawdata,nsmooth,/nan,/edge_truncate)
;   setdata,smdata
;endif
copy,0,2

;;Get WARM scan
;gettp,swarm,plnum=plnum,fdnum=fdnum,ifnum=ifnum,sig_state=0
gettp,swarm,plnum=plnum,fdnum=fdnum,ifnum=ifnum
copy,0,3

;;Get COLD scan
;gettp,scold,plnum=plnum,fdnum=fdnum,ifnum=ifnum,sig_state=0
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

;gettp,scan,sig_state=1
;gettp,scan,sig_state=0
;GBTIDL -> print,!g.s[0].reference_channel
;GBTIDL -> print,!g.s[0].observed_frequency
;GBTIDL -> gettp,58,sig_state=1
;Compute shift:
;GBTIDL -> print,(val1-val2)/!g.s[0].frequency_interval

