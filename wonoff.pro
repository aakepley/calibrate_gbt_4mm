pro wonoff,son,soff,plnum=plnum,fdnum=fdnum,ifnum=ifnum,vtsys
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
copy,0,10

;;Get OFF
gettp,soff,plnum=plnum,fdnum=fdnum,ifnum=ifnum
;;Reference smoothing  (not recommended in general)
;if (nsmooth gt 1) then begin
;   rawdata=getdata(0)
;   smdata=smooth(rawdata,nsmooth,/nan,/edge_truncate)
;   setdata,smdata
;endif
copy,0,11

;; Ta=Tsys(ON-OFF)/OFF
subtract,10,11
divide,0,11
print,'Data scaled to Tsys=',vtsys
vec=getdata(0)
vec=vec*vtsys
!g.s[0].units='Ta'
!g.s[0].tsys=vtsys
setdata,vec

return
end



