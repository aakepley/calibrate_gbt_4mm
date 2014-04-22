pro readproj_4mm,proj,mydata
;;
;;Makes lists and inputs values from a project 'AGBT12A_000_00'
;;and returns Data Structure mydata

mystring='/home/astro-util/projects/4mm/PRO/BIN/mkScanList ' + proj 
dir1='/home/astro-util/projects/4mm/PRO/LISTS/'
spawn,mystring

;;makes DCR,LO,GO, and AN lists


readcol,dir1+proj+'_ANlist',format='a24,i,a,d,d,d',a1,a2,a3,a4,a5,a6
file=a1
obj=a3
scan=a2
time=a4
elev=a6

readcol,dir1+proj+'_LOlist',format='a,i,d',b1,b2,b3
;;inGHz
freq=b3/1.e9

;readcol,proj+'_RXlist',format='a,i,d',c1,c2,c3

readcol,dir1+proj+'_GOlist',format='a,i,a,a,a,d,d,',c1,c2,c3,c4,c5,c6,c7
procname=c4
ra=c6
dec=c7

mydata=create_struct('proj',proj,'file',file,'scan',scan,'obj',obj,'procname',procname,'time',time,'freq',freq,'el',elev,'ra',ra,'dec',dec)

print,'Stucture: mydata.(proj,file,scan,obj,procnam,time,freq,el,ra,dec)'

return
end

