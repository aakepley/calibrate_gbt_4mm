pro calseq_dcr_4mm_beam1,dd,twarm=twarm,tcold=tcold,sky,cold1,cold2,result
;;
;;For VLBI calibration Tsys measurement assuming using beam-1 
;;
;;Scalar reduction of calibration sequence 
;;returns result Tsys and gains of each channel
;;for input twarm and tcold values and input sky,cold1,and cold2 scans
;;

if (n_elements(ifnum) eq 0) then ifnum = 0
if (n_elements(twarm) eq 0) then twarm = 280
if (n_elements(tcold) eq 0) then tcold = 50

;;
;;dd=input meta-data structure from readProj
;;
;;gain=(Twarm-Tcold)/(Vwarm-Vcold)
;;Tsys=gain*Tsky

;;usage,
;IDL>readproj_4mm,'TGBT11B_503_05',s5
;IDL>summary_4mm,s5
;; Pick out scan numbers for sky, cold1, cold2
;IDL>calseq_dcr_4mm_beam1,s5,twarm=278.5,tcold=50.,78,79,80,myresult
;

scan_dcr_4mm,dd,sky,mydata1
scan_dcr_4mm,dd,cold1,mydata2
scan_dcr_4mm,dd,cold2,mydata3

;DCR calibration
m3d0=median(mydata3[0,*],/even)
m3d1=median(mydata3[1,*],/even)
m2d0=median(mydata2[0,*],/even)
m2d1=median(mydata2[1,*],/even)

g1=(twarm-tcold)/(m3d0-m2d0)
g3=(twarm-tcold)/(m3d1-m2d1)


tsys1=median(mydata1[0,*],/even)*g1
tsys3=median(mydata1[1,*],/even)*g3


print,'scan, twarm, tcold',sky,twarm,tcold
print,'Tsys and std for Ch1, ch3'
print,tsys1,tsys3
print,'Gains(1,3):',g1,g3

result=[tsys1,tsys3,g1,g3]


return
end
