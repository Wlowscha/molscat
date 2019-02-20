      FUNCTION IPASYM(JI,NK,A)
C  Copyright (C) 2019 J. M. Hutson & C. R. Le Sueur
C  Distributed under the GNU General Public License, version 3
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
C
C  ROUTINE TO SET SYMMETRY BLOCK CODE FOR ASYMMETRIC TOP FUNCTIONS.
C
C               IPASYM     K-PAR     +/- PAR
C                 0        EVEN         +
C                 1        EVEN         -
C                 2         ODD         +
C                 3         ODD         -
C
      DIMENSION A(NK)
      DATA EPS/1.D-4/
C
      IPAR=-1
      KPAR=-1
      IF (NK.EQ.2*JI+1) GOTO 1000

 1999 WRITE(6,699) JI,NK,(A(I),I=1,NK)
  699 FORMAT(/'  * * * ERROR.  FOLLOWING SET OF ASYMMETRIC TOP ',
     1       'COEFFICIENTS ARE INVALID (PARITY).',2I6/(10X,6F12.8))
      IPASYM=-1
      RETURN

C  NORMALIZE IF NECESSARY . . .
 1000 XN=0.D0
      DO 1100 I=1,NK
 1100   XN=XN+A(I)*A(I)
      IF (ABS(XN).GE.EPS) GOTO 1200

      WRITE(6,602)
  602 FORMAT(/'  * * * ERROR.  COEFFICIENTS CANNOT BE NORMALIZED.')
      GOTO 1999

 1200 XN=1.D0/SQRT(XN)
      IF (ABS(XN-1.D0).LE.EPS) GOTO 2000

      WRITE(6,601) XN
  601 FORMAT(10X,'COEFFICIENTS NORMALIZED WITH FACTOR',E14.6)

 2000 DO 2100 I=1,NK
 2100   A(I)=A(I)*XN
C
C  AT THE END OF THIS LOOP, KPAR WILL BE 1 IF LARGE COEFFICIENTS ONLY
C  FOR A(ODD K), KPAR WILL BE 0 IF LARGE COEFFICIENTS ONLY FOR A(EVEN K)
      NMID=JI+1
C  DETERMINE EVEN/ODD K
      LP=0
      IF (ABS(A(NMID)).LE.EPS) GOTO 3100
      KPAR=0
 3100 IF (JI.LE.0) GOTO 4000
      DO 3200 I=1,JI
        LP=ABS(LP-1)
        IF (ABS(A(NMID+I)).LE.EPS .AND. ABS(A(NMID-I)).LE.EPS)
     &    GOTO 3200
        IF (KPAR.GE.0) GOTO 3300
        KPAR=LP
        GOTO 3200
 3300   IF (KPAR.EQ.LP) GOTO 3200
        KPAR=-1
        GOTO 1999
 3200 CONTINUE
C
C  NOW DO +/- KPARITY . . .
 4000 IF (ABS(A(NMID)).LE.EPS) GOTO 4100

      IPAR=0
 4100 IF (JI.LE.0) GOTO 5000

C  THIS LOOP CHECKS FOR SYMMETRY/ANTISYMMETRY OF A COEFFICIENTS ABOUT K=0 -
C  SYMMETRIC MAKES IPAR=0, ANTISYMMETRIC MAKES IPAR=1
      DO 4200 I=1,JI
        IF (ABS(A(NMID-I)).GT.EPS) GOTO 4300
        IF (ABS(A(NMID+I)).LE.EPS) GOTO 4200
        IPAR=-1
        GOTO 1999
 4300   RATIO=A(NMID+I)/A(NMID-I)
        IF (ABS(RATIO-1.D0).LE.EPS) GOTO 4400
        IF (ABS(RATIO+1.D0).LE.EPS) GOTO 4500
        IPAR=-1
        GOTO 1999
 4500   IF (IPAR) 4501,4502,4200
 4501   IPAR=1
        GOTO 4200
 4502   IPAR=-1
        GOTO 1999
 4400   IF (IPAR) 4401,4200,4402
 4401   IPAR=0
        GOTO 4200
 4402   IPAR=-1
        GOTO 1999
 4200 CONTINUE
C
 5000 IF (KPAR.LT.0 .OR. IPAR.LT.0) GOTO 1999
C
C  IPASYM IS A BINARY REPRESENTATION OF KPAR AND IPAR
      IPASYM=2*KPAR+IPAR
      RETURN
      END
