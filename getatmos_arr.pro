pro getatmos_arr,freq,startMJD,stopMJD,incrMJD,ztau_arr,mjd_arr
;;             atmtsys
;;Procedure to return zenith opacity (ztau) and AtmTsys (atmtsys) from
;;RMaddale

;; modified to only get Opacity and not Tsys. 5/7/2013. AAK
;; modified to return opacities for a set of MJDS.

my1='/users/rmaddale/bin/getForecastValues '
my2=' -freqList '
my3=string(freq)
my4=' -startMJD '
my5=string(startMJD)
my6=' -stopMJD '
my7=string(stopMJD)
my8=' -incrMJD '
my9 = string(incrMJD)

mystr1=my1+my2+my3+my4+my5+my6+my7+my8+my9

mystr3=mystr1+' -type Opacity'

;print,mystr1
;print,mystr2
;print,mystr3

;spawn,mystr2,result1
spawn,mystr3,result2
;print,result1
print,result2

ztau_arr = dblarr(n_elements(result2))
mjd_arr = dblarr(n_elements(result2))

for i = 0, n_elements(result2) - 1 do begin
  ztau_arr[i] = (strsplit(result2[i],/extract))[2]
  mjd_arr[i] = strmid(result2[i],18,9)
endfor

return
end

