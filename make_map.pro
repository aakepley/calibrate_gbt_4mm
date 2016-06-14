pro make_map, savefile, fitsfile, $
              headerfile,$
              beam_fwhm=beam_fwhm,$
              pix_per_beam=pix_per_beam, $
              _Extra=extra
              

;; Purpose: create a fits image from a save file full of spectra.

;; Input: save file with ra, dec, and spectra
;; 
;; Output: fitsfile

;; Is header file the best way to get the frequency?

;; Date         Programmer              Description of Changes
;; ----------------------------------------------------------------------
;; 5/10/2013    A.A. Kepley             Original Code
;; 7/17/2014    A.A. Kepley             Updating to dealin with
;;                                      multiple save files

; checking inputs
if n_params(make_map) ne 3 then begin
    message,/info,"make_map,savefile,fitsfile,headerfile"
 endif

; opening save files
restore,savefile[0]

if n_elements(savefile) gt 1 then begin

   ra_orig = ra
   dec_orig = dec
   velocity_orig = velocity
   for i = 1, n_elements(savefile) -1 do begin
      restore, savefile[i],/verb
      ra_orig = [ra,ra_orig]
      dec_orig = [dec,dec_orig]
      velocity_orig = [velocity,velocity_orig]
   endfor

   ra = ra_orig
   dec = dec_orig
   velocity = velocity_orig

endif

; Creating Header
filein, headerfile
getrec, 0

; getting number of channels
nchan = n_elements(velocity[0,*])

; getting RA and Dec grid set
good = where(ra ne 0 and dec ne 0 ,count)

xctr = mean(ra[good])
yctr = mean(dec[good])

xsize = (max(ra[good]) - min(ra[good]))*cos(yctr*!DtoR)
ysize = max(dec[good]) - min(dec[good])

if n_elements(beam_fwhm) eq 0 then begin

    ;; Getting the beam size
    lambda = !gc.light_speed / (!g.s[0].observed_frequency)

    beam_fwhm = (1.02 + 0.0135*14.0 )* lambda / 100.0 ; radians
    beam_fwhm = beam_fwhm / !dtor ; degrees

endif else begin
    beam_fwhm = beam_fwhm/3600.00 ; arcsec -> degrees
endelse



; Getting the pixel grid
if n_elements(pix_per_beam) eq 0 then pix_per_beam = 4.0
pix_scale = (beam_fwhm/pix_per_beam)

nxpix = ceil(xsize/pix_scale)
nypix  = ceil(ysize/pix_scale)

xrefpix = (xctr/min(ra[good])) * nxpix
yrefpix = (yctr/min(dec[good])) * nypix

; Making the header
naxis_vec = [nxpix, nypix, nchan]
mkhdr, hdr, 3, naxis_vec

sxaddpar, hdr, 'CTYPE1', 'RA---TAN'
sxaddpar, hdr, 'CRVAL1', xctr
sxaddpar, hdr, 'CRPIX1', nxpix/2
sxaddpar, hdr, 'CDELT1', -1.0*pix_scale


sxaddpar, hdr, 'CTYPE2', 'DEC--TAN'
sxaddpar, hdr, 'CRVAL2', yctr
sxaddpar, hdr, 'CRPIX2', nypix/2
sxaddpar, hdr, 'CDELT2', pix_scale



sxaddpar, hdr, 'CTYPE3', 'FREQ'
sxaddpar, hdr, 'CUNIT3', 'Hz'
sxaddpar, hdr, 'CRVAL3', !g.s[0].reference_frequency
sxaddpar, hdr, 'CRPIX3', !g.s[0].reference_channel+1.0 ;; confused about having to add one here, but makes everything line up.
sxaddpar, hdr, 'CDELT3', !g.s[0].frequency_interval
sxaddpar, hdr, 'RESTFREQ', !g.s[0].line_rest_frequency

sxaddpar, hdr, 'EQUINOX', 2000
sxaddpar, hdr, 'BMAJ', beam_fwhm
sxaddpar, hdr, 'BMIN', beam_fwhm
sxaddpar, hdr, 'BUNIT', 'K', 'Tmb'

; Gridding


grid_otf, data=velocity[good,*], ra=ra[good], dec=dec[good],target_hdr=hdr,out_root=fitsfile,_Extra=extra


end
