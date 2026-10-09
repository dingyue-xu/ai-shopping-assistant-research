* ============================================================================ .
* SUPPLEMENTARY RUN — H1a contrasts and Welch's F                              .
* MSc Digital Economy | King's College London                                 .
* ---------------------------------------------------------------------------- .
* PURPOSE                                                                       .
* Six statistics in Chapter 4 section 4.4 are currently computed by hand from   .
* SPSS's own contrast values and mean square within, because the R2 run did not  .
* request them. This file asks SPSS to print them directly.                     .
*                                                                               .
* H1a is the only hypothesis the study overturned, so its key statistic should   .
* appear in the SPSS output rather than in the author's arithmetic.             .
*                                                                               .
* This is a SUPPLEMENT, not a re-run. Nothing here changes any result already    .
* reported; it only asks SPSS to print tests that were computed by hand.        .
* Do not re-run the full syntax and do not overwrite the R2 output files.       .
* ---------------------------------------------------------------------------- .
* WHAT H1a CLAIMS                                                               .
* That the decline from medium to high delegation exceeds the decline from low  .
* to medium. Comparing the two point estimates (1.092 vs 0.780) is NOT a test of .
* that claim. The quadratic trend contrast (1, -2, 1) IS: it is algebraically    .
* (m1 - m2) - (m2 - m3), exactly the difference between the two declines.        .
* ============================================================================ .

SET DECIMAL=DOT.
SET PRINTBACK=YES.

* >>> EDIT THIS LINE ONLY <<< absolute path, no tilde.
FILE HANDLE proj /NAME='/Users/YOURNAME/Desktop/spss'.

GET FILE='proj/AI_Shopping_n267.sav'.
DATASET NAME ds WINDOW=FRONT.

* Confirm the right file: expect N = 267 and cells 38/45/49/47/39/49.
CROSSTABS /TABLES=DELEG BY BACK /CELLS=COUNT /COUNT ROUND CELL.


* ============================================================ .
* A.  H1a — quadratic contrast, no covariates                   .
* ============================================================ .
* Contrast 1 and 2 reproduce the R2 run and are the check that   .
* nothing has shifted. Contrast 3 is the new one: it is the test .
* of H1a. POLYNOMIAL splits the effect into linear and quadratic .
* components; report the WEIGHTED linear term, since cells are   .
* unequal.                                                       .

ONEWAY DV BY DELEG
  /CONTRAST=1 -1 0
  /CONTRAST=0 1 -1
  /CONTRAST=1 -2 1
  /POLYNOMIAL=2
  /STATISTICS DESCRIPTIVES HOMOGENEITY
  /POSTHOC=BONFERRONI ALPHA(0.05).


* ============================================================ .
* B.  H1a — same contrast with the covariates in the model       .
* ============================================================ .
* LMATRIX tests the contrast inside the covariate-adjusted model. .
* Read "Contrast Results (K Matrix)" for the estimate and its     .
* standard error, and "Test Results" for F. Note t = sqrt(F),     .
* carrying the sign of the contrast estimate.                    .

UNIANOVA DV BY DELEG BACK WITH D2 S1 LIT B10 B11
  /METHOD=SSTYPE(3)
  /LMATRIX='H1a quadratic contrast (1 -2 1)' DELEG 1 -2 1
  /PRINT=ETASQ
  /DESIGN=D2 S1 LIT B10 B11 DELEG BACK DELEG*BACK.


* ============================================================ .
* C.  Does the same pattern hold elsewhere?                      .
* ============================================================ .
* The chapter reports that the direction is consistent but never  .
* significant. These three commands produce those figures.        .

* C1. Secondary outcome.
ONEWAY DV4 BY DELEG
  /CONTRAST=1 -2 1
  /STATISTICS DESCRIPTIVES.

* C2. Within each platform condition separately.
SORT CASES BY BACK.
SPLIT FILE LAYERED BY BACK.
ONEWAY DV BY DELEG
  /CONTRAST=1 -2 1
  /STATISTICS DESCRIPTIVES.
SPLIT FILE OFF.

* C3. The manipulation check itself. This matters: if perceived
*     autonomy were unequally spaced, a non-linear adoption
*     response would be expected for that reason alone. It is not
*     unequally spaced, which is what makes the H1a null credible.
ONEWAY M1 BY DELEG
  /CONTRAST=1 -2 1
  /STATISTICS DESCRIPTIVES.


* ============================================================ .
* D.  Welch's F for the manipulation checks                      .
* ============================================================ .
* Levene was significant for both M1 and M2 in the R2 run         .
* (p = .010 and p = .009), so the ordinary F assumes equal        .
* variances it does not have. Welch does not. Games-Howell is the .
* matching post hoc test.                                         .

ONEWAY M1 M2 BY DELEG
  /STATISTICS DESCRIPTIVES HOMOGENEITY WELCH BROWNFORSYTHE
  /POSTHOC=GAMES-HOWELL ALPHA(0.05).


* ============================================================ .
* E.  EXPORT                                                     .
* ============================================================ .
* New filenames. Do not overwrite the R2 files.                   .

OUTPUT SAVE OUTFILE='proj/SPSS_Supplement_H1a.spv'.

OUTPUT EXPORT
  /CONTENTS EXPORT=ALL
  /PDF DOCUMENTFILE='proj/SPSS_Supplement_H1a.pdf'.

OUTPUT EXPORT
  /CONTENTS EXPORT=ALL
  /XLSX DOCUMENTFILE='proj/SPSS_Supplement_H1a.xlsx' OPERATION=CREATEFILE.

* ============================================================ .
* END                                                            .
* ============================================================ .
