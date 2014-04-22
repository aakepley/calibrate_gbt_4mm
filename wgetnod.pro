pro wgetnod,ifnum=ifnum,tsys=tsys,son,soff
;
;;Computes and calibrate using gettp for W-band input Tsys=vtsys
;
;;son = on scan with respect to beam 1 (fdnum=0)
;;soff = off scan with respect to beam2 (fdnum=1)
;;plnum = pol-number
;;fdnum = beam-number
;;vtsys = Tsys [K] for Ta


if (n_elements(ifnum) eq 0) then ifnum = 0
if (n_elements(tsys) eq 0) then tsys = 1.0

;;inputs with respect to beam 1
sclear
wonoff,plnum=0,fdnum=0,ifnum=ifnum,son,soff,tsys
;copy,0,10
accum
wonoff,plnum=1,fdnum=0,ifnum=ifnum,son,soff,tsys
;copy,0,11
accum
wonoff,plnum=0,fdnum=1,ifnum=ifnum,soff,son,tsys
;copy,0,12
accum
wonoff,plnum=1,fdnum=1,ifnum=ifnum,soff,son,tsys
;copy,0,13
accum
ave


return
end



