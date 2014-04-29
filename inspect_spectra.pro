pro inspect_spectra, myinfile, waitTime,scan=scan,plnum=plnum,ifnum=ifnum,fdnum=fdnum

filein,myinfile

if n_elements(scan) eq 0 then scan = get_scan_numbers()
if n_elements(plnum) eq 0 then plnum = 0
if n_elements(ifnum) eq 0 then ifnum = 0
if n_elements(fdnum) eq 0 then fdnum = 0

emptystack
clearfind

setfind,'plnum',plnum
setfind,'ifnum',ifnum
setfind,'fdnum',fdnum

if n_elements(scan) gt 1 then begin
    for i = 0, n_elements(scan) - 1 do setfind, 'scan',scan[i],/append
endif else begin
    setfind, 'scan',scan
endelse

find

n_stack = n_elements(astack())

if n_stack le 0 then begin
   message, 'No spectra selected'
   return
endif

unfreeze
for i = 0, n_stack - 1 do begin
    getrec, astack(i)
    wait, waitTime
endfor

emptystack
clearfind

end
