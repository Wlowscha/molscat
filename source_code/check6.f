      SUBROUTINE CHECK6(N,JL,A)
C  Copyright (C) 2019 J. M. Hutson & C. R. Le Sueur
C  Distributed under the GNU General Public License, version 3
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
C  THIS SUBROUTINE CHECKS THAT FOR ASYMMETRIC TOP FUNCTIONS, THE A
C  COEFFICIENTS FOR REPEATED SETS OF JI (=JL(...,1)) ARE ORTHOGONAL TO
C  EACH OTHER
C
C  IT FOLLOWS THE SAME LOGIC AS CHCK6I, BUT THE JL ARRAY IS THE OTHER
C  WAY AROUND (AND BIGGER)
C
      DIMENSION JL(N,6),A(1)
      DATA EPS/7.D-6/
      WRITE(6,600)
  600 FORMAT(/' CHECK6.  INPUT FUNCTIONS WILL BE CHECKED FOR ',
     &       'ORTHOGONALITY.')
      NERR=0
      DO 1000 I1=2,N
      DO 1000 I2=1,I1-1
C  SEE IF SAME J-VALUE
        IF (JL(I2,1).NE.JL(I1,1)) GOTO 1000
C  CHECK THAT NK AGREE
        NK1=JL(I1,5)
        NK2=JL(I2,5)
 3000   IF (NK1.EQ.NK2) GOTO 1001
        WRITE(6,699) I1,I2,NK1,NK2
  699   FORMAT(/' ***** CHECK6 ERROR.  FOR LEVELS',2I4,
     &         ', NK NOT EQUAL.',2I5)
        NERR=NERR+1
        GOTO 1000

 1001   TOTAL=0.D0
        DO 1100 II=1,NK1
 1100     TOTAL=TOTAL+A(JL(I1,4)+II)*A(JL(I2,4)+II)
        IF (ABS(TOTAL).LE.EPS) GOTO 1000
        WRITE(6,698) I1,I2,TOTAL
  698   FORMAT(/' ***** CHECK6 ERROR.  LEVEL',2I4,' ARE NOT ORTHOGONAL.'
     &         ,'  OVERLAP =',E12.4)
        NERR=NERR+1
 1000 CONTINUE

      IF (NERR.LE.0) RETURN
      WRITE(6,697) NERR
  697 FORMAT(/' *****'/'  ***** CHECK6.  NUMBER OF ERRORS =',I4/
     1       '  ***** EXECUTION TERMINATING UNLESS CHECK6 MODIFIED'/
     2       '  *****')
      STOP
      END
