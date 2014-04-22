pro wgetnod_cal_noavg,twarm=twarm,tcold=tcold,ifnum=ifnum,son,soff,swarm,scold
;
;;Computes and calibrate using gettp for W-band input Tsys=vtsys
;
;;son = on scan
;;soff = off scan
;;plnum = pol-number
;;fdnum = beam-number
;;vtsys = Tsys [K] for Ta

;;inputs with respect to beam 1
;sclear
wonoff_cal,twarm=twarm,tcold=tcold,plnum=0,fdnum=0,ifnum=ifnum,son,soff,swarm,scold
;copy,0,10
accum
wonoff_cal,twarm=twarm,tcold=tcold,plnum=1,fdnum=0,ifnum=ifnum,son,soff,swarm,scold
;copy,0,11
accum
wonoff_cal,twarm=twarm,tcold=tcold,plnum=0,fdnum=1,ifnum=ifnum,soff,son,scold,swarm
;copy,0,12
accum
wonoff_cal,twarm=twarm,tcold=tcold,plnum=1,fdnum=1,ifnum=ifnum,soff,son,scold,swarm
;copy,0,13
accum
;ave


return
end



