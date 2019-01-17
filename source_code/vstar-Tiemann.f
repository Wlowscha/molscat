      SUBROUTINE VINIT(NV,RUNIT,VUNIT)
C  Copyright (C) 2018 J. M. Hutson & C. R. Le Sueur
C  Distributed under the GNU General Public License, version 3
C
C  THIS VERSION OF VINIT WRITTEN SPECIFICALLY FOR ALKALI-ALKALI
C  POTENTIALS PUBLISHED BY TIEMANN AND CO-WORKERS
C
C  IT MAKES USE OF MODULES WHICH CONTAINS THE ACTUAL DATA FOR A
C  SPECIFIC ALKALI-ALKALI SYSTEM.
      USE potential, ONLY: RUNAME,EPNAME
      USE pot_data_Tiemann
      IMPLICIT NONE
      LOGICAL :: LSETUP,G2B
      INTEGER :: NV, I
      DOUBLE PRECISION :: RUNIT,VUNIT
      DOUBLE PRECISION :: R, RA, XI, V, VMID, VLR, VEXCH
      DOUBLE PRECISION :: DVDR, DXIDR, DXINDR
      DOUBLE PRECISION :: POWER,DPOWER
      DOUBLE PRECISION GAMOLD,BETOLD,AOLD,ASROLD,BSROLD
      DOUBLE PRECISION :: EPSIL = 1.D0
      SAVE
C
C  NV=1:  1SIGMA POTENTIAL
C  NV=2:  3SIGMA POTENTIAL
C
      IF (NV.LT.1 .OR. NV.GT.2) THEN
          WRITE(6,*) "NV OUT OF RANGE -- NV:",NV
          STOP ' PROGRAM HALTED IN POTENTIAL SYS_SS_POT '
      ENDIF
      IF (IPRINT.GE.1) WRITE(6,*) ' JMH routine for Tiemann-style',
     1                            ' alkali dimer potentials'
      IF (IPRINT.GE.1) WRITE(6,*) POTNAM 
      IF (IPRINT.GE.2) WRITE(6,100) ' For potential ',NV,' at RLR =',
     1                              RLR(NV)
  100 FORMAT(1X,A,I2,A,G20.13)
C
C  MATCH AT LONG-RANGE POINT TO ADJUST A(0)
C
      GAMOLD=GAMMA
      BETOLD=BETA
C
C  THREE CHOICES HERE:
C  CALCULATE EXCHANGE POWER GAMMA FROM EXPONENT BETA,
C  OR BETA FROM GAMMA, OR LEAVE BOTH UNCHANGED
C
      IF (GAMBET.EQ.2) THEN
        BETA = 7.D0 / (bohr_to_angstrom * (GAMMA + 1.D0))
      ELSEIF (GAMBET.EQ.1) THEN
        GAMMA = 7.D0 / (BETA * bohr_to_angstrom) - 1.D0
      ENDIF
C 
      VEXCH = AEX * RLR(NV)**GAMMA * EXP(-BETA*RLR(NV))
      VLR = EXSIGN(NV)*VEXCH 
     X    - C6/RLR(NV)**6 - C8/RLR(NV)**8 - C10/RLR(NV)**10
      IF (NEX.GT.0) VLR = VLR - CEX/RLR(NV)**NEX
      XI = (RLR(NV) - RM(NV))/(RLR(NV)+B(NV)*RM(NV))
      VMID = POWER(XI,A(0,NV),NA(NV))
      AOLD = A(0,NV)
      A(0,NV)=A(0,NV)+VLR-VMID

      IF (IPRINT.GE.2) THEN
        IF (GAMBET.EQ.2) THEN
          WRITE(6,200) ' beta  shifted from ',BETOLD,' A-1'
          WRITE(6,200) '                 to ',BETA,' A-1'
  200     FORMAT(1X,A,G20.13:,A)
        ELSEIF (GAMBET.EQ.1) THEN
          WRITE(6,200) ' gamma shifted from ',GAMOLD
          WRITE(6,200) '                 to ',GAMMA
        ELSE
          WRITE(6,*) ' input gamma and beta unchanged'
        ENDIF
        WRITE(6,200) ' V = ',VMID
        WRITE(6,200) ' A(0)  shifted from ',AOLD,' cm-1'
        WRITE(6,200) '                 to ',A(0,NV),' cm-1'
      ENDIF
C
C  MATCH AT SHORT-RANGE POINT
C  GET VALUES OF ASR AND BSR FROM THE POTENTIAL AND ITS DERIVATIVE
      XI = (RSR(NV) - RM(NV))/(RSR(NV)+B(NV)*RM(NV))
      VMID = POWER(XI,A(0,NV),NA(NV))
C  DERIVATIVE OF XI
      DXIDR = (B(NV)+1.D0) * RM(NV) / (RSR(NV)+B(NV)*RM(NV))**2
      DVDR = DXIDR*DPOWER(XI,A(0,NV),NA(NV))

      BSROLD=BSR(NV)
      IF (MATCHD) BSR(NV) = -DVDR*RSR(NV)**(NSR(NV)+1.D0)/NSR(NV)
      ASROLD = ASR(NV)
      ASR(NV) = VMID - BSR(NV)/RSR(NV)**NSR(NV)

      IF (IPRINT.GE.2) THEN
        WRITE(6,400) ' For potential ',NV,' at RSR =',RSR(NV),' A'
  400   FORMAT(1X,A,I3,A,G20.13,A)
        WRITE(6,500) ' V = ',VMID,'cm-1, dV/dR = ',DVDR,
     1             'cm-1/A and n = ',NSR(NV)
  500   FORMAT(1X,A,G20.13,A,G20.13,A,G20.13)
        IF (MATCHD) THEN
          WRITE(6,200) ' B(SR) shifted from ',BSROLD ,' cm-1 A^n'
          WRITE(6,200) '                 to ',BSR(NV),' cm-1 A^n'
        ELSE
          WRITE(6,*) ' B(SR) not shifted to match dV/dR'
        ENDIF
        WRITE(6,200) ' A(SR) shifted from ',ASROLD ,' cm-1'
        WRITE(6,200) '                 to ',ASR(NV),' cm-1'
      ENDIF
C
C  SET MOLSCAT/BOUND ENERGY UNITS TO CM-1
C  SET MOLSCAT/BOUND LENGTH UNITS TO A OR BOHR AS IN DATA MODULE
C
      RUNIT = RUNITM
      VUNIT = EPSIL
      RUNAME(1:8)=LENUNT
      RETURN
C
      ENTRY VSTAR(NV,R,V)
C
C  CALCULATE POTENTIAL POINT:
C  FIRST CONVERT INPUT R FROM MOLSCAT RM UNITS TO ANGSTROM
C
      RA = R*RUNITM
C
      IF (RA.LT.RSR(NV)) THEN
          V = ASR(NV)+BSR(NV)/RA**NSR(NV)
      ELSEIF (RA.LE.RLR(NV)) THEN
          XI = (RA - RM(NV))/(RA+B(NV)*RM(NV))
          V = POWER(XI,A(0,NV),NA(NV))
      ELSE
          VEXCH = AEX * RA**GAMMA * EXP(-BETA*RA)
          V = EXSIGN(NV)*VEXCH - C6/RA**6 - C8/RA**8 - C10/RA**10
          IF (NEX.GT.0) V = V - CEX/RA**NEX
      ENDIF
C
      V = V / EPSIL
C
      RETURN
C
      ENTRY VSTAR1(NV,R,V)
C
C  CALCULATE DERIVATIVE POINT:
C  FIRST CONVERT INPUT R FROM MOLSCAT RM UNITS TO ANGSTROM
C
      RA = R*RUNITM
C
      IF (RA.LT.RSR(NV)) THEN
        V = -NSR(NV)*BSR(NV)/RA**(NSR(NV)+1.D0)
      ELSEIF (RA.LE.RLR(NV)) THEN
        XI = (RA - RM(NV))/(RA+B(NV)*RM(NV))
        DXIDR = (B(NV)+1.D0) * RM(NV) / (RA+B(NV)*RM(NV))**2
        DVDR = DXIDR*DPOWER(XI,A(0,NV),NA(NV))
        V = DVDR
      ELSE
          VEXCH = AEX * RA**GAMMA * EXP(-BETA*RA)
          V = EXSIGN(NV) * (GAMMA/RA-BETA) * VEXCH
     1      + 6.D0*C6/RA**7 + 8.D0*C8/RA**9 + 10.D0*C10/RA**11
          IF (NEX.GT.0) V = V + DBLE(NEX)*CEX/RA**(NEX+1)
      ENDIF
C
C     CONVERT DERIVATIVE TO EXTERNAL LENGTH UNITS
C
      V = V * RUNITM / EPSIL
      RETURN
C
      ENTRY VSTAR2(NV,R,V)
C
C  SECOND DERIVATIVES NOT IMPLEMENTED BUT WOULD BE EASY IF NEEDED
C
      WRITE(6,*) ' CALLED VSTAR2: SECOND DERIVATIVES OF',
     1           ' TIEMANN-STYLE POTENTIAL NOT IMPLEMENTED'
      STOP
      END
C
      DOUBLE PRECISION FUNCTION POWER(X,A,N)
C
C  EVALUATE A POWER SERIES WITH COEFFICIENTS IN A
C
      IMPLICIT NONE
      INTEGER N,I
      DOUBLE PRECISION X,A(N)

      POWER=0.D0
      DO 10 I=N,2,-1
        POWER=POWER+A(I)
        POWER=POWER*X
   10 CONTINUE
      POWER=POWER+A(1)

      RETURN
      END
C
      DOUBLE PRECISION FUNCTION DPOWER(X,A,N)
C
C  EVALUATE DERIVATIVE OF A POWER SERIES WITH COEFFICIENTS IN A
C
      IMPLICIT NONE
      INTEGER N,I
      DOUBLE PRECISION X,A(N)

      DPOWER=0.D0
      DO 10 I=N,3,-1
        DPOWER=DPOWER+DBLE(I-1)*A(I)
        DPOWER=DPOWER*X
   10 CONTINUE
      DPOWER=DPOWER+A(2)

      RETURN
      END
