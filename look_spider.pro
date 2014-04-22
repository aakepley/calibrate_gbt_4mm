pro look_spider,lats,longs

scans=indgen(74-63+1)+63

lats=0.0
longs=0.0

for i=0, n_elements(scans)-1 do begin
    
    s = !g.lineio->get_spectra(scan=scans[i],pol='RR')

    lats = [lats,s.latitude_axis]
    longs= [longs,s.longitude_axis]

endfor

if n_elements(lats) gt 1 and n_elements(longs) gt 1 then begin
    lats = lats[1:(n_elements(lats)-1)]
    longs = longs[1:(n_elements(longs)-1)]
endif

plot,lats,longs,psym=5,/ynozero,/isotropic

end
