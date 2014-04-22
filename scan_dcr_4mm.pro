pro scan_dcr_4mm,dd,scan,outdata
;;
;;Plots the data for a scan and chnum and returns outvec
;;
;; v.2012.02.07
;;
;; Use to readProj to fill in data-structure with meta-data
;;readProj,'TGBT11B_503_05',s5

;;usage scan_DCR,dd,2,0,outvec
;;were dd=input data structure, 2=scan,0=chan


;;data dir
ddir='/home/gbtdata'

bb=where(dd.scan[*] eq scan)
INfile=ddir+'/'+dd.proj+'/DCR/'+dd.file[bb]
print,INfile

;;Extract Data
ftab_ext,INfile,[1,2,3,4],fif,subs,tt,data,exten_no=3 

outdata=data

return
end
