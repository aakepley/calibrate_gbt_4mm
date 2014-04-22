pro wtip_reduc,twarm=twarm,tcold=tcold,ifnum=ifnum,scstart,scend
;;
;;assumes cal_seq,sky,cold1,cold2
if (n_elements(ifnum) eq 0) then ifnum = 0
if (n_elements(twarm) eq 0) then twarm = 280
if (n_elements(tcold) eq 0) then tcold = 53
;;
d2r=3.14159/180.
nn=fix(scend-scstart+1)/3
tsys1=fltarr(nn)
tsys3=fltarr(nn)
tsys5=fltarr(nn)
tsys7=fltarr(nn)
ael=fltarr(nn)
jj=0
for ii=scstart,scend,3 do begin
   print,'sky scan',ii
   calseq_sp_4mm,twarm=twarm,tcold=tcold,ifnum=ifnum,ii,ii+1,ii+2,a,b
   ael[jj]=!g.s[0].elevation
   tsys1[jj]=a[0]
   tsys3[jj]=a[1]
   tsys5[jj]=a[2]
   tsys7[jj]=a[3]
   jj=jj+1
endfor

;print,ael
vec1=1./(sin(ael*d2r))
;print,vec1
;print,tsys1
;;compute tau_o using ladfit 
;;Tsys~exp(tau_o*A)
;;ln(Tsys)~tau_o*A
;;A=1/sin(el)
;;Below 12deg (airmass>~4.8), tsys begins to saturate in good weather
;;and need to stop at el>20deg (airmass<3) in marginal weather (or will
;;underestimate tau in linear approximation

;;use 1.3,1.7,2.1,2.5,2.9 airmas
;;el=50.3,36.0,28.4,23.6,20.2

bb=where(vec1 lt 3.0)

res1=ladfit(vec1[bb],alog(tsys1[bb]))
res3=ladfit(vec1[bb],alog(tsys3[bb]))
res5=ladfit(vec1[bb],alog(tsys5[bb]))
res7=ladfit(vec1[bb],alog(tsys7[bb]))

print,'Tau_o from Tips for ch(1),(3),(5),(7)'
print,res1[1],res3[1],res5[1],res7[1]

return
end


