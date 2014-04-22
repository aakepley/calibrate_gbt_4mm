function calseq_sp_4mm,cal_wheel_scans,twarm=twarm,tcold=tcold,ifnum=ifnum
;
;; Purpose: Computes and calibrate using gettp for W-band input Tsys=vtsys
;
;;sky= sky scan
;;cold1= cold1 scan
;;cold2= cold2 scan
;;ifnum = spectral window number
;;twarm = ambient temperature from Rx page
;;tcold = effective cold-load temperature measured from the LAB

; Date          Programmer      Description of Changes
; ----------------------------------------------------------------------
; ?             Dave Frayer     Original Code
; 5/6/2013      A. Kepley       Modified to return an array of gains.

if (n_elements(ifnum) eq 0) then ifnum = 0
if (n_elements(twarm) eq 0) then twarm = 280
if (n_elements(tcold) eq 0) then tcold = 50

;;tcold=53 from Jan-April 2012
;;Added some RF absorbing foam to help with baselines
;;and tcold~56 (lab) 15 May 2012
;;Actual twarm can be found on the Rx cleo page (~280K typical)
;;(twarm colder in the winter months)

if n_elements(cal_wheel_scans) ne 3 then begin
    message,/info,"cal_wheel_scans must have 3 elements"
    return,-1
endif

sky = cal_wheel_scans[0]
cold1 = cal_wheel_scans[1] 
cold2 = cal_wheel_scans[2] 

;;Get sky ch1,ch3,ch5,ch7 for ifnum
gettp,sky,plnum=0,fdnum=0,ifnum=ifnum
vec1=getdata(0)
gettp,sky,plnum=1,fdnum=0,ifnum=ifnum
vec3=getdata(0)
gettp,sky,plnum=0,fdnum=1,ifnum=ifnum
vec5=getdata(0)
gettp,sky,plnum=1,fdnum=1,ifnum=ifnum
vec7=getdata(0)


;;Get cold1 ch1,ch3,ch5,ch7 for ifnum
gettp,cold1,plnum=0,fdnum=0,ifnum=ifnum
vec1c1=getdata(0)
gettp,cold1,plnum=1,fdnum=0,ifnum=ifnum
vec3c1=getdata(0)
gettp,cold1,plnum=0,fdnum=1,ifnum=ifnum
vec5c1=getdata(0)
gettp,cold1,plnum=1,fdnum=1,ifnum=ifnum
vec7c1=getdata(0)

;;Get cold2 ch1,ch3,ch5,ch7 for ifnum
gettp,cold2,plnum=0,fdnum=0,ifnum=ifnum
vec1c2=getdata(0)
gettp,cold2,plnum=1,fdnum=0,ifnum=ifnum
vec3c2=getdata(0)
gettp,cold2,plnum=0,fdnum=1,ifnum=ifnum
vec5c2=getdata(0)
gettp,cold2,plnum=1,fdnum=1,ifnum=ifnum
vec7c2=getdata(0)

;;
;;Vector Calibration (remove median below) -- watch baselines
;;Scalar calibration (use median below)
gvec1=(twarm-tcold)/median(vec1c2-vec1c1)
gvec3=(twarm-tcold)/median(vec3c2-vec3c1)
gvec5=(twarm-tcold)/median(vec5c1-vec5c2)
gvec7=(twarm-tcold)/median(vec7c1-vec7c2)
;;
tsys1=vec1*gvec1
tsys3=vec3*gvec3
tsys5=vec5*gvec5
tsys7=vec7*gvec7

print,'sky scan, Twarm, Tcold',sky,twarm,tcold
print,'Median Values across band:'
print,'Tsys(1,3,5,7)=',median(tsys1),median(tsys3),median(tsys5),median(tsys7)

;;for vector cal
;print,'Gains(1,3,5,7)=',median(gvec1),median(gvec3),median(gvec5),median(gvec7)

;;for scalar cal
print,'Gains(1,3,5,7)=',gvec1,gvec3,gvec5,gvec7

gainvec = [gvec1,gvec3,gvec5,gvec7]

return, gainvec

end



