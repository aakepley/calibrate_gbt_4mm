function getatmos,time,freq
;;Procedure to return zenith opacity (ztau) and AtmTsys (atmtsys) from
;;RMaddale

;; modified to return only a single vlaue

my1='/users/rmaddale/bin/getForecastValues '
;my2=string(elev)
my3=' -freqList '
my4=string(freq)
my5=' -timeList '
my6=string(time)

mystr1=my1+my3+my4+my5+my6

;mystr2=mystr1+' -type AtmTsys'
mystr3=mystr1+' -type Opacity'

;print,mystr1
;print,mystr2
;print,mystr3

;spawn,mystr2,result1
spawn,mystr3,result2
;print,result1
print,result2

tmp=strsplit(result2,/extract)
ztau=float(tmp[2])

;tmp=strsplit(result1,/extract)
;atmtsys=float(tmp[2])

return,ztau
end

