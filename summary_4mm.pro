pro summary_4mm,dd
;;
;;prints out summary of data 

nn=n_elements(dd.scan[*])
fmt='(a24,i8,a15,a20,f12.3,f12.6,f12.6)'
print,'File                        Scan      OBJECT          PROCNAME         TIME        FREQ        EL'
for ii=0,nn-1 do begin
 print,format=fmt,dd.file[ii],dd.scan[ii],dd.obj[ii],dd.procname[ii],dd.time[ii],dd.freq[ii],dd.el[ii]
endfor

return
end
