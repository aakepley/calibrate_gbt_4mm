pro wonoff_gain,plnum=plnum,fdnum=fdnum,ifnum=ifnum,son,soff,gain
;
;;Computes and calibrate using gettp for W-band input gain 
;;which can be obtained using calseq_sp_4mm.pro
;;Script does a "scalar" gain calibration to avoid baseline
;;issue for 800MHz bandwidth windows
;;
;;son = on scan
;;soff = off scan
;;plnum = pol-number
;;fdnum = beam-number
;;gain = input gain for plnum and fdnum

;;Get ON
gettp,son,plnum=plnum,fdnum=fdnum,ifnum=ifnum
copy,0,1

;;Get OFF
gettp,soff,plnum=plnum,fdnum=fdnum,ifnum=ifnum
copy,0,2
off=getdata(0)

;;compute Tsys
tsysvec=gain*off

vtsys=median(tsysvec)
print,'Median Tsys across band',vtsys

;; Ta=Tsys*(ON-OFF)/OFF 
subtract,1,2
divide,0,2

vec=getdata(0)
vec1=vtsys*vec

!g.s[0].units='Ta'
!g.s[0].tsys=vtsys
setdata,vec1

return
end



