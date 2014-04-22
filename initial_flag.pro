pro initial_flag, filename, $
                  fdnum=fdnum,plnum=plnum,ifnum=ifnum,chans=chans,$
                  chanwidth=chanwidth

filein, filename

scannos = get_scan_numbers(nscans)

flag,scanrange=[scannos[0],scannos[nscans-1]], $
  fdnum=fdnum, plnum=plnum,ifnum=ifnum,$
  chans=chans,chanwidth=chanwidth


end


