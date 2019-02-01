      SUBROUTINE SPROPN(WIDTH, EIGNOW, HP, Y1, Y4, Y2, NCH)
C  This subroutine is part of the MOLSCAT, BOUND and FIELD suite of programs
C  Tijs Karman
C  CURRENT REVISION DATE: 25-10-2017
C-----------------------------------------------------------------------
C  THIS SUBROUTINE CALCULATES DIAGONAL Y1,Y2,Y4 MATRICES FOR PROPAGATING
C  THE LOG-DERIVATIVE MATRIX USING AIRY FUNCTIONS AS INDEP. SOLUTIONS
C    AI/BI[W1^1/3 (W0/W1 + R-R0 ) ]
C  WHERE R IS THE RADIAL COORDINATE AND APPROX. -W = W0 + W1(R-R0)
C  [WARNING; NOTICE THE SIGN DIFFERENCE IN DEFINITION OF W BETWEEN TWO
C  REFS MENTIONED BELOW. HERE, W CORRESPONDS TO EIGNOW, AND HENCE W
C  AS DEFINED IN J. CHEM. PHYS. 86 2044 (1987)].
C  
C  FOR SMALL SLOPES, ABS(W1^1/3 * W0/W1) > EXP(AC), WE USE THE 
C  ASYMPTOTIC EXPANSIONS DEVELOPED IN J. CHEM. PHYS. 141 064102 (2014)
C      SOME NOTES AS THIS REFERENCE DISCUSSES RENORMALIZED PROPAGATION.
C      Y1, Y2, AND Y4 ARE DEFINED IN TERMS OF C1, C2, AND C4 IN
C      EQS. (21A-C) OF J. CHEM. PHYS. 86 2044 (1987) DISCUSSED BELOW.
C      USING THE DEFINITIONS OF X/Y^\PM, (A5/A8 OF THE 2014 PAPER)
C      WE HAVE:
C              C1 = - Y^+ / WRONSKIAN   (WITH GRID POINT I = N)
C              C2 =   X^+ / WRONSKIAN   (WITH GRID POINT I = N)
C              C4 = - Y^- / WRONSKIAN   (WITH GRID POINT I = N+1)
C
C  OTHERWISE, FOR ABS(W1^1/3 * W0/W1) .LE. EXP(AC), WE USE THE OLD 
C  APPROACH BASED ON DIRECTLY COMPUTING THE AIRY FUNCTIONS, FROM THERE
C  THEIR MODULI AND PHASES, AND SUBSEQUENTLY Y1, Y2, AND Y4 USING EQS.
C  FROM J. CHEM. PHYS. 86 2044 (1987) 
C  
C  AC = 3.D0 AT PRESENT.
C
C  INCREASING AC MEANS OLD MODULI AND PHASE METHOD IS USED FOR SMALLER
C  SLOPES, AND MAY PRODUCE NUMERICAL NOISE.
C  DECREASING AC MEANS ASYMPTOTIC (SMALL SLOPE) EXPANSION IS USED FOR
C  LARGER SLOPES. THIS WILL PRODUCE WARNINGS IF SUMS FAIL TO CONVERGE.
C-----------------------------------------------------------------------
C  VARIABLES IN CALL LIST:
C  WIDTH:      WIDTH OF THE CURRENT INTERVAL
C  EIGNOW:     ARRAY CONTAINING THE SQUARED WAVEVECTORS
C              THESE ARE DEFINED BY EQ. (6) OF M.ALEXANDER,
C              J. CHEM. PHYS. 81,4510 (1984)
C  HP:         ARRAY CONTAINING THE NEGATIVE OF DIAGONAL ELEMENTS OF THE
C              DERIVATIVE OF THE WAVEVECTOR MATRIX AT THE CENTER OF THE
C              CURRENT INTERVAL [SEE EQ. (9) OF M.ALEXANDER,
C              J. CHEM. PHYS. 81,4510 (1984)]
C              THIS ARRAY THUS CONTAINS THE DERIVATIVE OF THE DIAGONAL
C              ELEMENTS OF THE TRANSFORMED HAMILTONIAN MATRIX
C              THUS, THE NEGATIVE OF THE DERIVATIVE OF EIGNOW!
C  Y1, Y2, Y4: ON RETURN, CONTAIN THE DESIRED DIAGONAL ELEMENTS OF THE
C              IMBEDDING PROPAGATOR
C  NCH:        THE NUMBER OF CHANNELS, THIS EQUALS THE DIMENSIONS OF THE
C              EIGNOW, HP, Y1, Y4, AND B ARRAYS
C-----------------------------------------------------------------------
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DOUBLE PRECISION DALPHA, DBETA, DHALF, DONETH, DROOT, DSLOPE,
     :                 DTWOTH, DLZETA, DMMOD1, DMMOD2, DNMOD1, DNMOD2,
     :                 DPI, DX1, DX2, DZETA1, DZETA2, DPHI1, DPHI2,
     :                 DTHET1, DTHET2, DTNHFM, DTNHFP, DARG, DCAY, DKAP,
     :                 OFLOW,X1,X2
     :                 Z,DEL,RTIJS,Y2TIJS,C1,C2,C4,E1,E2,E4
      DIMENSION EIGNOW(1), HP(1), Y1(1), Y2(1), Y4(1)
      INTEGER I, NCH
      DATA     DONETH,             DTWOTH,     DHALF
     :  / 0.333333333333333D0, 0.666666666666667D0, 0.5D0 /
      DATA  DPI / 3.1415926535897932D0 /
C  AC REFERS TO THE AIRY CRITERION. 
C  USES ASYMPTOTIC EXPANSION OF AIRY FUNCTIONS FOR ABS(W0/W1).GT.EXP(AC)
C  USES MODULI AND PHASES OF DIRECTLY COMPUTED AIRY FUNCTIONS OTHERWISE
      PARAMETER (AC=3.D0)
C  ACCURACY FOR NUMERICALLY COMPUTING THE SERIES OCCURING IN EQ. (A12-15)
      ACCU = 10.**(-20)
C  THE PARAMETER OFLOW IS THE LARGEST VALUE OF X FOR WHICH EXP(X)
C  DOES NOT CAUSE A SINGLE PRECISION OVERFLOW
C                                     N
C  A REASONABLE VALUE IS X = [ LN(2) 2 ] - 5, WHERE N IS THE NUMBER OF
C  BITS? THE CHARACTERISTIC OF A FLOATING POINT NUMBER
      DATA OFLOW / 83.D0 /
C  NOW DETERMINE B_MIN1, Y1, AND Y4 PARAMETERS FOR ALL NCH CHANNELS
      DO 10  I = 1, NCH
        DSLOPE = HP(I)
        DARG = 1.E+10
        IF (DSLOPE.NE.0.D0)
     :    DARG = LOG(ABS(EIGNOW(I))) - DTWOTH*LOG(ABS(DSLOPE))
        IF (DARG.GT.AC) THEN
C-----------------------------------------------------------------------
C
C TK MODIFIED OCT 2017
C
C COMMENTED OUT SECTION THAT SWITCHED TO CONSTANT REFERENCE POTENTIAL
C
C-----------------------------------------------------------------------
CC  HERE IF THE RELATIVE SLOPE IN THE WAVEVECTOR MATRIX IS LESS THAN
CC  EXP**(-AC) IN MAGNITUDE, IN WHICH CASE THE POTENTIAL IS ASSUMED TO BE
CC  CONSTANT
C          IF (EIGNOW(I).GT.0) THEN
CC  HERE FOR CLASSICALLY ALLOWED REGION (SINES AND COSINES AS REFERENCE
CC  SOLUTIONS)
C            DCAY = SQRT(EIGNOW(I))
C            DARG = DCAY * WIDTH
C            Y1(I) = DCAY / TAN(DARG)
C            Y4(I) = Y1(I)
C            Y2(I) = DCAY / SIN(DARG)
C          ELSE
CC  HERE FOR CLASSICALLY FORBIDDEN REGION (HYPERBOLIC SINES AND COSINES
CC  ARE REFERENCE SOLUTIONS)
C            DKAP = SQRT( - EIGNOW(I))
C            DARG = DKAP * WIDTH
C            Y1(I) = DKAP / TANH(DARG)
C            Y4(I) = Y1(I)
C            Y2(I) = DKAP / SINH(DARG)
C          ENDIF
C-----------------------------------------------------------------------
C
C TK BEGIN INSERTED OCT 2017
C
C START OF LARGE ARGUMENT AIRY EVALUATION
C
C-----------------------------------------------------------------------

C-------------------------
          IF (DSLOPE.EQ.0.D0) THEN
            DSLOPE=1.D-30
          ENDIF
C-------------------------

          DROOT = ( ABS(DSLOPE) ) ** DONETH
          DALPHA= SIGN(DROOT, DSLOPE)
          DBETA = - EIGNOW(I) / DSLOPE
          X1    = DALPHA * ( DBETA - WIDTH * DHALF)
          X2    = DALPHA * ( DBETA + WIDTH * DHALF)
          DEL   = DALPHA*WIDTH
C  CALL AIRY_ABPAPB TO COMPUTE Y+/WRONSKIAN = -C1
          CALL AIRY_ABPAPB(C1,E1,X1,DEL,ACCU)
          C1 = -C1
C  CALL AIRY_ABAB TO COMPUTE   X+ =  C2*WRONSKIAN
          CALL AIRY_ABAB(C2,E2,X1,DEL,ACCU)
          C2 = DPI*C2/DALPHA
C  CALL AIRY_ABPAPB TO COMPUTE Y-/WRONSKIAN = -C4
          CALL AIRY_ABPAPB(C4,E4,X2,-DEL,ACCU)
          C4 = -C4

C  INVARIANT IMBEDDING
          Y1(I) = EXP(E1-E2)*C1/C2
          Y2(I) = EXP(-E2)/C2
          Y4(I) = EXP(E4-E2)*C4/C2

C-----------------------------------------------------------------------
C
C TK END INSERTED OCT 2017
C
C END OF LARGE ARGUMENT AIRY EVALUATION
C
C-----------------------------------------------------------------------
        ELSE
C  HERE IF THE RELATIVE SLOPE IN THE WAVEVECTOR MATRIX IS GREATER THAN
C  EXP.**(-AC) IN MAGNITUDE, IN WHICH CASE A LINEAR REFERENCE POTENTIAL IS
C  USED WITH AIRY FUNCTIONS AS REFERENCE SOLUTIONS
          DROOT = ( ABS(DSLOPE) ) ** DONETH
          DALPHA   = SIGN(DROOT, DSLOPE)
          DBETA = - EIGNOW(I) / DSLOPE
          DX1 = DALPHA * ( DBETA - WIDTH * DHALF)
          DX2 = DALPHA * ( DBETA + WIDTH * DHALF)
          IF (DX1.GT.0.D0) DZETA1 = DTWOTH * DX1 * SQRT(DX1)
          IF (DX2.GT.0.D0) DZETA2 = DTWOTH * DX2 * SQRT(DX2)
          CALL AIRYMP(DX1, DTHET1, DPHI1, DMMOD1, DNMOD1)
          CALL AIRYMP(DX2, DTHET2, DPHI2, DMMOD2, DNMOD2)
          X1 = DX1
          X2 = DX2

C-----------------------------------------------------------------------
          IF (X1.LE.0.D0 .AND. X2.LE.0.D0) THEN
C  HERE FOR BOTH X_1 AND X_2 NEGATIVE (SEE EQNS 38A, 38B, 38C)
C

            B =  DMMOD1 * DMMOD2 * SIN(DTHET2 - DTHET1)
            Y2(I) = 1.D0 / B
            Y1(I) = DNMOD1 * SIN(DPHI1 - DTHET2)
     :            / (DMMOD1 * SIN(DTHET2 - DTHET1) )
            Y4(I) = DNMOD2 * SIN(DPHI2 - DTHET1)
     :            / (DMMOD2 * SIN(DTHET2 - DTHET1) )
C-----------------------------------------------------------------------
          ELSEIF (X1.GT.0.D0 .AND. X2.GT.0.D0) THEN
C  HERE FOR BOTH X_1 AND X_2 POSITIVE (SEE EQNS 39A, 39B, 39C AND 40,
C  BUT THET1/2 CORRESPOND TO CHI1/2 AND PHI1/2 CORRESPOND TO ETA1/2)
C

            TNHFAC = TANH(DZETA2 - DZETA1)
            BFACT = SINH(DTHET1 - DTHET2) +
     :              TNHFAC * SINH(DTHET1 + DTHET2)
            DLZETA = ABS(DZETA2 - DZETA1)
            Y2(I) = 0.
            IF (DLZETA.LE.OFLOW) THEN
              B = DMMOD1 * DMMOD2 * COSH(DZETA2 - DZETA1) * BFACT
              Y2(I) = 1.D0 / B
            ENDIF
            Y1(I) = DNMOD1 * (SINH(DTHET2 - DPHI1)
     :            - TNHFAC * SINH(DTHET2 + DPHI1) ) / (DMMOD1 * BFACT)
            Y4(I) = DNMOD2 * (SINH(DTHET1 - DPHI2)
     :            + TNHFAC * SINH(DTHET1 + DPHI2) ) / (DMMOD2 * BFACT)


C-----------------------------------------------------------------------
          ELSEIF (X1.GT.0.D0 .AND. X2.LE.0.D0) THEN
C  HERE FOR X_1 POSITIVE AND X_2 NEGATIVE (SEE EQNS 41A, 41B, 41C AND 42,
C  BUT THET1 CORRESPONDS TO CHI1 AND PHI1 CORRESPONDS TO ETA1
C
            DTNHFP = 1 + TANH(DZETA1)
            DTNHFM = 1 - TANH(DZETA1)
            BFACT = COSH(DTHET1) * ( - COS(DTHET2) * DTNHFP
     :            + TANH(DTHET1) * SIN(DTHET2) * DTNHFM)
            Y2(I) = 0.
            IF (ABS(DZETA1).LE.OFLOW) THEN
              Y2(I) = COSH(DZETA1) * (DMMOD1 * DMMOD2 * BFACT)
              Y2(I) = 1.D0 / Y2(I)
            ENDIF
            Y1(I) = (DNMOD1 * COSH(DPHI1) * ( COS(DTHET2) * DTNHFP
     :            - TANH(DPHI1) * SIN(DTHET2) * DTNHFM) )
     :            / (DMMOD1 * BFACT)
            Y4(I) = (DNMOD2 * COSH(DTHET1) * ( - COS(DPHI2) * DTNHFP
     :            + TANH(DTHET1) * SIN(DPHI2) * DTNHFM) )
     :            / (DMMOD2 * BFACT)
C-----------------------------------------------------------------------
          ELSEIF (X2.GT.0.D0 .AND. X1.LE.0.D0) THEN
C  HERE FOR X_1 NEGATIVE AND X_2 POSITIVE (SEE EQNS 43A, 43B, 43C AND
C  44, BUT THET2 CORRESPONDS TO CHI2 AND PHI2 CORRESPONDS TO ETA2
C
            DTNHFP = 1 + TANH(DZETA2)
            DTNHFM = 1 - TANH(DZETA2)
            BFACT = COSH(DTHET2) * ( COS(DTHET1) * DTNHFP
     :            - TANH(DTHET2) * SIN(DTHET1) * DTNHFM)
            Y2(I) = 0.
            IF (ABS(DZETA2).LE.OFLOW) THEN
              Y2(I) =  COSH(DZETA2) * (DMMOD1 * DMMOD2 * BFACT)
              Y2(I) = 1.D0 / Y2(I)
            ENDIF
            Y4(I) = (DNMOD2 * COSH(DPHI2) * ( COS(DTHET1) * DTNHFP
     :            - TANH(DPHI2) * SIN(DTHET1) * DTNHFM) )
     :            / (DMMOD2 * BFACT)
            Y1(I) = (DNMOD1 * COSH(DTHET2) * ( - COS(DPHI1) * DTNHFP
     :            + TANH(DTHET2) * SIN(DPHI1) * DTNHFM) )
     :            / (DMMOD1 * BFACT)
C-----------------------------------------------------------------------
          ENDIF
          Y1(I) = DALPHA * Y1(I)
          Y4(I) = DALPHA * Y4(I)
          Y2(I) = DALPHA * Y2(I) / DPI
C  AT THIS POINT THE Y1, Y2, AND Y4 PROPAGATORS CORRESPOND IDENTICALLY
C  TO EQS. (38)-(44) OF M. ALEXANDER AND D. MANOLOPOULOS, "A STABLE
C  LINEAR REFERENCE POTENTIAL ALGORITHM FOR SOLUTION ..."
        ENDIF
10    CONTINUE
      RETURN
      END

C-----------------------------------------------------------------------
C
C  TK 2017
C
C  AUXILIARY FUNCTIONS FOR LARGE-ARGUMENT AIRY EVALUATION
C
C-----------------------------------------------------------------------

      SUBROUTINE ONEXKM(R,X,K,ACCU)
C  TK OCT 2017
C  COMPUTES (1+X)^K-1 FOR SMALL X, RETURNED IN R
C  ACCURATE TO ACCU
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DOUBLE PRECISION R,X,K,ACCU,UACCU,C,E(100)
      INTEGER I,N

C  INITIALIZE AND FIRST TERM IN EXPANSION
      I     = 1
      C     = K
      E(1)  = C*X
      UACCU = ABS(E(1))*ACCU

C  RECURSIVELY UPDATE COEFFICIENTS: MULTIPLY BY APPROPRIATE POWERS OF
C  X UNTIL CONTRIBUTION IS SMALL COMPARED TO THE LOWEST TERM
      DO WHILE (ABS(E(I)).GT.UACCU .AND. I.LT.98)
        C    = C*(K-I)/(I+1)
        I    = I+1
        E(I) = C*(X**I)
      ENDDO
      N=I

C  DISPLAY WARNING IF ACCURACY NOT UP TO SCRATCH.
      IF (ABS(E(I)).GT.UACCU) THEN
        UACCU = ABS(E(I)/E(1))
        WRITE(6,*) 'WARNING: ONEXKM: ACCURACY ONLY ',UACCU,'AFTER',
     +              N,'ITERATIONS, RAN FOR ARGUMENTS X=',X,'K=',K
        WRITE(6,*) 'INCREASE AIRY CRITERION AC TO AVOID THIS ERROR'
      ENDIF

C  FINALLY ADD ALL TERMS STARTING FROM THE SMALLEST
      R=0.D0
      DO I=N,1,-1
        R = R + E(I)
      ENDDO

      RETURN
      END

C-----------------------------------------------------------------------

      SUBROUTINE AIRY_EXPX(R,X,ACCU)
C  TK OCT 2017
C  COMPUTES SUM_K C_K X^-K, RETURN VALUE IN R
C  ACCURATE TO ACCU
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DOUBLE PRECISION R,X,ACCU,C,E(100)
      INTEGER I,N

C  INITIALIZE AND FIRST TERM IN EXPANSION
      I     = 0
      C     = 1.D0
      E(1)  = 1.D0

C  RECURSIVELY UPDATE COEFFICIENTS MULTIPLY BY APPROPRIATE POWERS OF
C  X UNTIL CONTRIBUTION IS SMALL COMPARED TO THE LOWEST TERM
      DO WHILE (ABS(E(I+1)).GT.ACCU .AND. I.LT.98)
        I    = I+1
C  UPDATE GAMMA(3I+1/2)        
        C    = C*3D0/8D0*(2D0*I-1D0)*(6D0*I-5D0)*(6D0*I-1D0)
C  UPDATE 1 / FACTORIAL(I) 54^I GAMMA(I+1/2)
        C    = C/(54*I*(I-0.5D0))
        E(I+1) = C/(X**(I))
      ENDDO
      N=I

C  DISPLAY WARNING IF ACCURACY NOT UP TO SCRATCH.
      IF (ABS(E(I+1)).GT.ACCU) THEN
        UACCU = ABS(E(I+1))
        WRITE(6,*) 'WARNING: AIRY EXPX: ACCURACY ONLY ',UACCU,'AFTER',
     +              N,'ITERATIONS, RAN FOR ARGUMENT X=',X
        WRITE(6,*) 'INCREASE AIRY CRITERION AC TO AVOID THIS ERROR'
      ENDIF

C  FINALLY ADD ALL TERMS STARTING FROM THE SMALLEST
      R=0D0
      DO I=N,0,-1
        R = R + E(I+1)
      ENDDO

      RETURN
      END

C-----------------------------------------------------------------------

      SUBROUTINE AIRY_EXPY(R,X,ACCU)
C  TK OCT 2017
C  COMPUTES SUM_K D_K X^-K, RETURN VALUE IN R
C  ACCURATE TO ACCU
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DOUBLE PRECISION R,X,ACCU,C,D,E(100)
      INTEGER I,N

C  INITIALIZE AND FIRST TERM IN EXPANSION
      I     = 0
      C     = 1.D0
      D     = 1.D0
      E(1)  = 1.D0

C  RECURSIVELY UPDATE COEFFICIENTS MULTIPLY BY APPROPRIATE POWERS OF
C  X UNTIL CONTRIBUTION IS SMALL COMPARED TO THE LOWEST TERM
      DO WHILE (ABS(E(I+1)).GT.ACCU .AND. I.LT.98)
        I    = I+1
C  UPDATE GAMMA(3I+1/2)        
        C    = C*3D0/8D0*(2D0*I-1D0)*(6D0*I-5D0)*(6D0*I-1D0)
C  UPDATE 1 / FACTORIAL(I) 54^I GAMMA(I+1/2)
        C    = C/(54*I*(I-0.5D0))
        D    = -C*(6.D0*I+1.0D0)/(6.D0*I-1.0D0)
        E(I+1) = D/(X**(I))
      ENDDO
      N=I

C  DISPLAY WARNING IF ACCURACY NOT UP TO SCRATCH.
      IF (ABS(E(I+1)).GT.ACCU) THEN
        UACCU = ABS(E(I+1))
        WRITE(6,*) 'WARNING: AIRY EXPY: ACCURACY ONLY ',UACCU,'AFTER',
     +              N,'ITERATIONS, RAN FOR ARGUMENT X=',X
        WRITE(6,*) 'INCREASE AIRY CRITERION AC TO AVOID THIS ERROR'
      ENDIF

C  FINALLY ADD ALL TERMS STARTING FROM THE SMALLEST
      R=0D0
      DO I=N,0,-1
        R = R + E(I+1)
      ENDDO

      RETURN
      END

C-----------------------------------------------------------------------

      SUBROUTINE AIRY_EXPXO(R,X,ACCU)
C  TK OCT 2017
C  COMPUTES SUM_K (-1)^K C_(2K+1) X^-(2K+1), RETURN VALUE IN R
C  ACCURATE TO ACCU
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DOUBLE PRECISION R,X,ACCU,UACCU,C,E(100)
      INTEGER I,K,N

C  INITIALIZE AND FIRST TERM IN EXPANSION
      I     = 1
      K     = 0
      C     = 3.75D0/54.D0
      E(1)  = C/X
      UACCU = ACCU*ABS(E(1))

C  RECURSIVELY UPDATE COEFFICIENTS MULTIPLY BY APPROPRIATE POWERS OF
C  X UNTIL CONTRIBUTION IS SMALL COMPARED TO THE LOWEST TERM
      DO WHILE (ABS(E(K+1)).GT.UACCU .AND. K.LT.98)
        K = K+1
        DO WHILE (I.LT.2*K+1)
          I = I+1
          C = C*3D0/8D0*(2D0*I-1D0)*(6D0*I-5D0)*(6D0*I-1D0)
          C = C/(54*I*(I-0.5D0))
        ENDDO
        E(K+1) = C/(X**(I))
      ENDDO
      N=K

C  DISPLAY WARNING IF ACCURACY NOT UP TO SCRATCH.
      IF (ABS(E(K+1)).GT.UACCU) THEN
        UACCU = ABS(E(K+1)/E(1))
        WRITE(6,*) 'WARNING: AIRY EXPXO: ACCURACY ONLY ',UACCU,'AFTER',
     +              N,'ITERATIONS, RAN FOR ARGUMENT X=',X
        WRITE(6,*) 'INCREASE AIRY CRITERION AC TO AVOID THIS ERROR'
      ENDIF

C  FINALLY ADD ALL TERMS STARTING FROM THE SMALLEST
      R=0D0
      DO K=N,0,-1
        R = R + (-1)**(K)*E(K+1)
      ENDDO

      RETURN
      END

C-----------------------------------------------------------------------

      SUBROUTINE AIRY_EXPYO(R,X,ACCU)
C  TK OCT 2017
C  COMPUTES SUM_K (-1)^K D_(2K+1) X^-(2K+1), RETURN VALUE IN R
C  ACCURATE TO ACCU
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DOUBLE PRECISION R,X,ACCU,UACCU,C,D,E(100)
      INTEGER I,K,N

C  INITIALIZE AND FIRST TERM IN EXPANSION
      I     = 1
      K     = 0
      C     = 3.75D0/54.D0
      D     = -C*(6.D0*I+1.0D0)/(6.D0*I-1.0D0)
      E(1)  = D/X
      UACCU = ACCU*ABS(E(1))

C  RECURSIVELY UPDATE COEFFICIENTS MULTIPLY BY APPROPRIATE POWERS OF
C  X UNTIL CONTRIBUTION IS SMALL COMPARED TO THE LOWEST TERM
      DO WHILE (ABS(E(K+1)).GT.UACCU .AND. K.LT.98)
        K = K+1
        DO WHILE (I.LT.2*K+1)
          I = I+1
          C = C*3D0/8D0*(2D0*I-1D0)*(6D0*I-5D0)*(6D0*I-1D0)
          C = C/(54*I*(I-0.5D0))
          D  = -C*(6.D0*I+1.0D0)/(6.D0*I-1.0D0)
        ENDDO
        E(K+1) = D/(X**(I))
      ENDDO
      N=K

C  DISPLAY WARNING IF ACCURACY NOT UP TO SCRATCH.
      IF (ABS(E(K+1)).GT.UACCU) THEN
        UACCU = ABS(E(K+1)/E(1))
        WRITE(6,*) 'WARNING: AIRY EXPYO: ACCURACY ONLY ',UACCU,'AFTER',
     +              N,'ITERATIONS, RAN FOR ARGUMENT X=',X
        WRITE(6,*) 'INCREASE AIRY CRITERION AC TO AVOID THIS ERROR'
      ENDIF

C  FINALLY ADD ALL TERMS STARTING FROM THE SMALLEST
      R=0D0
      DO K=N,0,-1
        R = R + (-1)**(K)*E(K+1)
      ENDDO

      RETURN
      END

C-----------------------------------------------------------------------

      SUBROUTINE AIRY_EXPXE(R,X,ACCU)
C  TK OCT 2017
C  COMPUTES SUM_K (-1)^K C_(2K) X^-(2K), RETURN VALUE IN R
C  ACCURATE TO ACCU
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DOUBLE PRECISION R,X,ACCU,UACCU,C,E(100)
      INTEGER I,K,N

C  INITIALIZE AND FIRST TERM IN EXPANSION
      I     = 0 
      K     = 0
      C     = 1.D0
      E(1)  = C
      UACCU = ACCU*ABS(E(1))

C  RECURSIVELY UPDATE COEFFICIENTS MULTIPLY BY APPROPRIATE POWERS OF
C  X UNTIL CONTRIBUTION IS SMALL COMPARED TO THE LOWEST TERM
      DO WHILE (ABS(E(K+1)).GT.UACCU .AND. K.LT.98)
        K = K+1
        DO WHILE (I.LT.2*K)
          I = I+1
          C = C*3D0/8D0*(2D0*I-1D0)*(6D0*I-5D0)*(6D0*I-1D0)
          C = C/(54*I*(I-0.5D0))
        ENDDO
        E(K+1) = C/(X**(I))
      ENDDO
      N=K

C  DISPLAY WARNING IF ACCURACY NOT UP TO SCRATCH.
      IF (ABS(E(K+1)).GT.UACCU) THEN
        UACCU = ABS(E(K+1)/E(1))
        WRITE(6,*) 'WARNING: AIRY EXPXE: ACCURACY ONLY ',UACCU,'AFTER',
     +              N,'ITERATIONS, RAN FOR ARGUMENT X=',X
        WRITE(6,*) 'INCREASE AIRY CRITERION AC TO AVOID THIS ERROR'
      ENDIF

C  FINALLY ADD ALL TERMS STARTING FROM THE SMALLEST
      R=0D0
      DO K=N,0,-1
        R = R + (-1)**(K)*E(K+1)
      ENDDO

      RETURN
      END

C-----------------------------------------------------------------------

      SUBROUTINE AIRY_EXPYE(R,X,ACCU)
C  TK OCT 2017
C  COMPUTES SUM_K (-1)^K D_(2K) X^-(2K), RETURN VALUE IN R
C  ACCURATE TO ACCU
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DOUBLE PRECISION R,X,ACCU,UACCU,C,E(100)
      INTEGER I,K,N

C  INITIALIZE AND FIRST TERM IN EXPANSION
      I     = 0
      K     = 0
      C     = 1.D0
      D     = 1.D0
      E(1)  = 1.D0
      UACCU = ACCU*ABS(E(1))

C  RECURSIVELY UPDATE COEFFICIENTS MULTIPLY BY APPROPRIATE POWERS OF
C  X UNTIL CONTRIBUTION IS SMALL COMPARED TO THE LOWEST TERM
      DO WHILE (ABS(E(K+1)).GT.UACCU .AND. K.LT.98)
        K = K+1
        DO WHILE (I.LT.2*K)
          I = I+1
          C = C*3D0/8D0*(2D0*I-1D0)*(6D0*I-5D0)*(6D0*I-1D0)
          C = C/(54*I*(I-0.5D0))
          D = -C*(6.D0*I+1.0D0)/(6.D0*I-1.0D0)
        ENDDO
        E(K+1) = D/(X**(I))
      ENDDO
      N=K

C  DISPLAY WARNING IF ACCURACY NOT UP TO SCRATCH.
      IF (ABS(E(K+1)).GT.UACCU) THEN
        UACCU = ABS(E(K+1)/E(1))
        WRITE(6,*) 'WARNING: AIRY EXPYE: ACCURACY ONLY ',UACCU,'AFTER',
     +              N,'ITERATIONS, RAN FOR ARGUMENT X=',X
        WRITE(6,*) 'INCREASE AIRY CRITERION AC TO AVOID THIS ERROR'
      ENDIF

C  FINALLY ADD ALL TERMS STARTING FROM THE SMALLEST
      R=0D0
      DO K=N,0,-1
        R = R + (-1)**(K)*E(K+1)
      ENDDO

      RETURN
      END


C-----------------------------------------------------------------------

      SUBROUTINE AIRY_ABAB(R,E,X,DEL,ACCU)
C  TK OCT 2017
C  FOR LARGE ARGUMENTS:
C  COMPUTES AI(Z)*BI(Z+DELTA)-AI(Z+DELTA)*BI(Z), RETURN VALUE IN R
C  EXPONENTIALLY SCALED VERSION, R IS MISSING FACTOR EXP(E).
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DOUBLE PRECISION R,E,X,DEL,DELX,ACCU,Z,DELZ,ZETA,EXPTRIGARG
     :                ,R141,R32,E1,E2,E3,E4
      DOUBLE PRECISION DPI,DONETH,DTWOTH,DHALF
      DATA  DPI / 3.1415926535897932D0 /
      DATA     DONETH,             DTWOTH,     DHALF
     :  / 0.333333333333333D0, 0.666666666666667D0, 0.5D0 /

C  FOR X LARGE COMPARED TO DELTA, USE ASYMPTOTIC EXPANSIONS
      DELX = DEL/X
      IF (X.GT.0.D0) THEN
C  LARGE POSITIVE X
C  EQ. (A12) OF JCP 141 064102 (2014)

C  INITIALIZE 
        Z      = X
        DELZ   = DELX
        ZETA   = DTWOTH*Z*Z**DHALF
        CALL ONEXKM(R141,DELZ,0.25D0,ACCU)
        CALL ONEXKM(R32,DELZ,1.5D0,ACCU)
        R141   = R141 + 1.D0
        R321   = R32 + 1.D0
        EXPTRIGARG = R32*ZETA

C  SUMS IN PARENTHESES
        CALL AIRY_EXPX(E1,-ZETA,ACCU)
        CALL AIRY_EXPX(E2,ZETA*R321,ACCU)
        CALL AIRY_EXPX(E3,ZETA,ACCU)
        CALL AIRY_EXPX(E4,-ZETA*R321,ACCU)

C  COMBINE EXPANSION
        IF (EXPTRIGARG.GT.0.D0) THEN
          R = E1*E2-EXP(-2.D0*EXPTRIGARG)*E3*E4
          E = EXPTRIGARG
        ELSE
          R = EXP(2.D0*EXPTRIGARG)*E1*E2-E3*E4
          E = -EXPTRIGARG
        ENDIF
        R = R/(2.D0*DPI*SQRT(Z)*R141)

      ELSE
C  LARGE NEGATIVE X
C  EQ. (A13) OF JCP 141 064102 (2014)

C  INITIALIZE
        Z      = -X
        DELZ   = -DELX
        ZETA   = DTWOTH*Z*Z**DHALF
        CALL ONEXKM(R141,-DELZ,0.25D0,ACCU)
        CALL ONEXKM(R32,-DELZ,1.5D0,ACCU)
        R141   = R141 + 1.D0
        R321   = R32 + 1.D0
        EXPTRIGARG = R32*ZETA

C  SUMS IN PARENTHESES
        CALL AIRY_EXPXO(E1,ZETA*R321,ACCU)
        CALL AIRY_EXPXO(E2,ZETA,ACCU)
        CALL AIRY_EXPXE(E3,ZETA,ACCU)
        CALL AIRY_EXPXE(E4,ZETA*R321,ACCU)

C  COMBINE EXPANSION
        R = -SIN(EXPTRIGARG)*(E1*E2+E3*E4)+
     +       COS(EXPTRIGARG)*(E1*E3-E2*E4)
        R = R/(DPI*SQRT(Z)*R141)
        E = 0.D0

      ENDIF

      RETURN
      END


C-----------------------------------------------------------------------

      SUBROUTINE AIRY_ABPAPB(R,E,X,DEL,ACCU)
C  TK OCT 2017
C  FOR LARGE ARGUMENTS:
C  COMPUTES [ AI(Z)*BI'(Z+DELTA)-AI'(Z+DELTA)*BI(Z) ]/W, RETURN VALUE IN R
C  WHERE W IS THE WRONSKIAN.
C  EXPONENTIALLY SCALED VERSION, R IS MISSING FACTOR EXP(E).
      IMPLICIT DOUBLE PRECISION (A-H,O-Z)
      DOUBLE PRECISION R,E,X,DEL,DELX,ACCU,Z,DELZ,ZETA,EXPTRIGARG
     :                ,R141,R32,E1,E2,E3,E4
      DOUBLE PRECISION DPI,DONETH,DTWOTH,DHALF
      DATA  DPI / 3.1415926535897932D0 /
      DATA     DONETH,             DTWOTH,     DHALF
     :  / 0.333333333333333D0, 0.666666666666667D0, 0.5D0 /

C  FOR X LARGE COMPARED TO DELTA, USE ASYMPTOTIC EXPANSIONS
      DELX = DEL/X
      IF (X.GT.0.D0) THEN
C  LARGE POSITIVE X
C  EQ. (A14) OF JCP 141 064102 (2014)

C  INITIALIZE
        Z      = X
        DELZ   = DELX
        ZETA   = DTWOTH*Z*Z**DHALF
        CALL ONEXKM(R141,DELZ,0.25D0,ACCU)
        CALL ONEXKM(R32,DELZ,1.5D0,ACCU)
        R141    = R141 + 1.D0
        R321   = R32 + 1.D0
        EXPTRIGARG = R32*ZETA

C  SUMS IN PARENTHESES
        CALL AIRY_EXPY(E1,-ZETA,ACCU)
        CALL AIRY_EXPX(E2,ZETA*R321,ACCU)
        CALL AIRY_EXPY(E3,ZETA,ACCU)
        CALL AIRY_EXPX(E4,-ZETA*R321,ACCU)

C  COMBINE EXPANSION
        IF (EXPTRIGARG.GT.0.D0) THEN
          R = E1*E2+EXP(-2.D0*EXPTRIGARG)*E3*E4
          E = EXPTRIGARG
        ELSE
          R = EXP(2.D0*EXPTRIGARG)*E1*E2+E3*E4
          E = -EXPTRIGARG
        ENDIF
        R = -R/(2.D0*R141)

      ELSE
C  LARGE NEGATIVE X
C  EQ. (A15) OF JCP 141 064102 (2014)

C  INITIALIZE
        Z      = -X
        DELZ   = -DELX
        ZETA   = DTWOTH*Z*Z**DHALF
        CALL ONEXKM(R141,-DELZ,0.25D0,ACCU)
        CALL ONEXKM(R32,-DELZ,1.5D0,ACCU)
        R141    = R141 + 1.D0
        R321   = R32 + 1.D0
        EXPTRIGARG = R32*ZETA

C  SUMS IN PARENTHESES
        CALL AIRY_EXPXO(E1,ZETA*R321,ACCU)
        CALL AIRY_EXPYO(E2,ZETA,ACCU)
        CALL AIRY_EXPYE(E3,ZETA,ACCU)
        CALL AIRY_EXPXE(E4,ZETA*R321,ACCU)

C  COMBINE EXPANSION
        R = COS(EXPTRIGARG)*(E1*E2+E3*E4)+
     +        SIN(EXPTRIGARG)*(E1*E3-E2*E4)
        R = -R/R141
        E = 0.D0

      ENDIF

      RETURN
      END
