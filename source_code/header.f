      SUBROUTINE HEADER(W,WX,N,NSQ,P,VL,IV,
     1                  EINT,CENT,DIAG,MXLAM,NPOTL,ICODE,ISAV,
     2                  ERED,EFIRST,RMLMDA,IPRINT)
C  Copyright (C) 2019 J. M. Hutson & C. R. Le Sueur
C  Distributed under the GNU General Public License, version 3
      USE efvs
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
C
C  ROUTINE TO WRITE/CHECK A HEADER LABEL ON UNIT ISCRU FOR USE
C  WITH THE OPTION TO SAVE TRANSFORMATION MATRICES FOR A SUBSEQUENT
C  RUN. THE LABEL CONSISTS OF ALL INTEGRATION TOLERANCES AND
C  A SAMPLE POTENTIAL MATRIX.
C
C  THE VARIOUS FLAGS ARE USED AS FOLLOWS:
C     ICODE=1, ISAV=1:  FIRST ENERGY, WRITE HEADER
C     ICODE=1, ISAV=-1: FIRST ENERGY, CHECK HEADER
C     ICODE=2:          SUBSEQUENT ENERGY, SKIP HEADER
C
C
      INTEGER, PARAMETER :: NPAR=14
      DIMENSION W(NSQ),WX(NSQ),P(MXLAM),VL(1),IV(1),EINT(N),CENT(N),
     1          DIAG(N),PAR(NPAR),PARX(NPAR)
      DIMENSION EFVTMP(0:MAXEFV)
C
C  COMMON BLOCK FOR CONTROL OF USE OF PROPAGATION SCRATCH FILE
      LOGICAL IREAD,IWRITE
      COMMON /PRPSCR/ ESHIFT,ISCRU,IREAD,IWRITE
C
C  COMMON BLOCK FOR CONTROL OF PROPAGATION SEGMENTS
      COMMON /RADIAL/ RMNINT,RMXINT,RMID,RMATCH,DRS,DRL,STEPS,STEPL,
     1                POWRS,POWRL,TOLHIS,TOLHIL,CAYS,CAYL,UNSET,
     2                IPROPS,IPROPL,NSEG

C  DYNAMIC STORAGE COMMON BLOCK ...
      COMMON /MEMORY/ MX,IXNEXT,NIPR,IDUMMY,X(1)
      EQUIVALENCE(PAR(1),RMNINT)
C
      IF (ISCRU.EQ.0) RETURN
      REWIND ISCRU
      IF (ISAV.EQ.0) RETURN
      IF (ICODE.EQ.1) GOTO 40
C
C  SUBSEQUENT ENERGY CALC. - SKIP OVER ANY HEADER
C
      READ(ISCRU)
      READ(ISCRU)
      READ(ISCRU)
      RETURN
C
40    IF (ISAV.EQ.-1) GOTO 60
C
C  WRITE OUT A HEADER
C
      RX=2.D0*RMIN
      CALL WAVMAT(W,N,RX,P,VL,IV,ERED,EINT,CENT,RMLMDA,DIAG,
     1            MXLAM,NPOTL,IPRINT)
      WRITE(ISCRU) N,EFIRST,RX,PAR
      WRITE(ISCRU) NEFV,(EFV(IEFV),IEFV=IEFVST,NEFVP)
      WRITE(ISCRU) W
      RETURN
C
C  READ AND VERIFY HEADER. NO ACTUAL
C  SCATTERING CALCULATION IS TO BE DONE FOR THIS ENERGY.
C  SET ICODE=2 SO THAT A "SUBSEQUENT ENERGY"  CALCULATION IS DONE
C
60    READ(ISCRU) NX,EFIRST,RX,PARX
      IF (N.NE.NX) GOTO 999
      DO 62 I=1,NPAR
        IF (PAR(I).NE.PARX(I)) GOTO 999
62    CONTINUE
      READ(ISCRU) NEFVTM,(EFVTMP(IEFV),IEFV=IEFVST,NEFVP)
      IF (NEFVTM.NE.NEFV) GOTO 997
      DO 63 IEFV=IEFVST,NEFVP
        IF (EFVTMP(IEFV).NE.EFV(IEFV)) GOTO 997
63    CONTINUE
      CALL WAVMAT(W,N,RX,P,VL,IV,EFIRST,EINT,CENT,RMLMDA,DIAG,
     1            MXLAM,NPOTL,IPRINT)
      READ(ISCRU) WX
      DO 64 I=1,NSQ
        IF (W(I).NE.WX(I)) GOTO 998
64    CONTINUE
      ICODE=2
      WRITE(6,603) ISCRU
603   FORMAT(/' HEADER LABEL ON UNIT',I3,' SUCCESSFULLY VERIFIED.')
      RETURN
C
C  HEADER IS WRONG - RUN TERMINATED
C
998   WRITE(6,600) ISCRU
600   FORMAT(/' ****** ERROR - HEADER ON UNIT',I3,' DOES NOT AGREE',
     1       ' WITH DATA FOR CURRENT RUN'/)
      WRITE(6,601) (W(I),WX(I),I=1,NSQ)
601   FORMAT(2E24.15,10X,2E24.15)
997   WRITE(6,600) ISCRU
      WRITE(6,602) NEFV,NEFVTM,(EFV(IEFV),EFVTMP(IEFV),
     1                          IEFV=IEFVST,NEFVP)
999   WRITE(6,600) ISCRU
      WRITE(6,602) N,NX,(PAR(I),PARX(I),I=1,NPAR)
602   FORMAT(2I8/(2E24.15))
      STOP
      END
