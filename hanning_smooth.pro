pro hanning_smooth, myfilein, myfileout

filein,myfilein
fileout, myfileout

freeze

for i = 0, nrecords() - 1 do begin

    getrec, i
    hanning,/decimate,ok=ok
    if not ok then begin
        message,'Hanning smoothed failed on index ', i
        return
    endif

    keep

endfor

fileout, 'junk.fits'

end
