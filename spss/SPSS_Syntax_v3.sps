* ============================================================================ .
* Consumer Adoption Barriers to AI Shopping Assistants in Chinese E-Commerce   .
* MSc Digital Economy | King's College London                                 .
* Data: AI_Shopping_n267.sav  (N = 267, cleaned, labelled)                     .
* ---------------------------------------------------------------------------- .
* VERSION 3 (supersedes v1 and v2)                                             .
*   v2 fixed: check variables were named d1-d6; SPSS variable names are        .
*             CASE-INSENSITIVE, so d1-d4 overwrote the demographics D1-D4 and  .
*             the following DELETE destroyed them, killing STEP 2, STEP 5 and  .
*             the main ANCOVA. They are now named chk_*.                       .
*   v2 fixed: PROCESS v5 is the current release; STEP 10 rewritten.            .
*   v3 fixes: removed the bare `PROCESS.` load test, which produced eight      .
*             harmless but output-polluting errors in the R2 run.              .
*   v3 adds:  Welch's F for the manipulation checks (Levene was significant    .
*             for both M1 and M2 in the R2 run).                               .
*   v3 adds:  GRAPH commands for the two chapter figures SPSS can produce.     .
* ---------------------------------------------------------------------------- .
* BEFORE RUNNING - edit ONE line only: the FILE HANDLE path in STEP 0.         .
* PROCESS macro (Hayes) v5 must be in the same folder: processmacro.org        .
* ---------------------------------------------------------------------------- .
* All factorial models use Type III sums of squares (/METHOD=SSTYPE(3)).       .
* The design is unbalanced (cell n = 38/45/49/47/39/49), so Type II and        .
* Type III are NOT equivalent; Type III is the reported specification.         .
* ============================================================================ .

SET DECIMAL=DOT.
SET PRINTBACK=YES.
SET ERRORS=BOTH.
SET RNG=MT MTINDEX=20260810.


* ============================================================ .
* STEP 0.  PATHS AND DATA                                       .
* ============================================================ .
* >>> EDIT THIS LINE ONLY <<< absolute path, no tilde.          .

FILE HANDLE proj /NAME='/Users/YOURNAME/Desktop/spss'.

GET FILE='proj/AI_Shopping_n267.sav'.
DATASET NAME ds WINDOW=FRONT.

DISPLAY DICTIONARY.
FREQUENCIES VARIABLES=SCENARIO DELEG BACK
  /ORDER=ANALYSIS.


* ============================================================ .
* STEP 1.  VARIABLE CHECK                                       .
* ============================================================ .
* The composites are already stored in the .sav. They are        .
* recomputed here so the construction is visible in the output;  .
* the six differences must all be exactly zero.                  .

COMPUTE T5R_chk   = 8 - T5.
COMPUTE DV_chk    = MEAN(DV1, DV2, DV3).
COMPUTE RISK_chk  = MEAN(PR1, PR2, PR3, PR4, PR5, PR6).
COMPUTE TRUST_chk = MEAN(T1, T2, T3, T4, T5R).
COMPUTE LIT_chk   = MEAN(B1, B2, B3, B4).
COMPUTE FAMQW_chk = MEAN(B8_5, B9_5).
EXECUTE.

* NOTE: named chk_* deliberately. SPSS variable names are CASE-INSENSITIVE,
*       so d1-d4 would collide with the demographic variables D1-D4.
COMPUTE chk_dv    = DV     - DV_chk.
COMPUTE chk_risk  = RISK   - RISK_chk.
COMPUTE chk_trust = TRUST  - TRUST_chk.
COMPUTE chk_lit   = LIT    - LIT_chk.
COMPUTE chk_t5r   = T5R    - T5R_chk.
COMPUTE chk_famqw = FAM_QW - FAMQW_chk.
EXECUTE.
DESCRIPTIVES VARIABLES=chk_dv chk_risk chk_trust chk_lit chk_t5r chk_famqw
  /STATISTICS=MEAN MIN MAX.

* Sentinel: D1-D4 must exist before and after the DELETE.
DESCRIPTIVES VARIABLES=D1 D2 D3 D4 /STATISTICS=MEAN MIN MAX.

DELETE VARIABLES chk_dv chk_risk chk_trust chk_lit chk_t5r chk_famqw
  T5R_chk DV_chk RISK_chk TRUST_chk LIT_chk FAMQW_chk.

DESCRIPTIVES VARIABLES=D1 D2 D3 D4 /STATISTICS=MEAN MIN MAX.


* ============================================================ .
* STEP 2.  SAMPLE CHARACTERISTICS   -> Table 4.1, Table E1     .
* ============================================================ .

FREQUENCIES VARIABLES=S1 D1 D2 D3 D4 B5 B10
  /ORDER=ANALYSIS.

DESCRIPTIVES VARIABLES=DURATION
  /STATISTICS=MEAN STDDEV MIN MAX.

FREQUENCIES VARIABLES=DURATION
  /FORMAT=NOTABLE
  /PERCENTILES=25 50 75.


* ============================================================ .
* STEP 3.  RELIABILITY   -> Table 4.2                           .
* ============================================================ .

RELIABILITY
  /VARIABLES=DV1 DV2 DV3
  /SCALE('Willingness to adopt') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE CORR
  /SUMMARY=TOTAL MEANS.

RELIABILITY
  /VARIABLES=PR1 PR2 PR3 PR4 PR5 PR6
  /SCALE('Perceived risk') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE CORR
  /SUMMARY=TOTAL MEANS.

RELIABILITY
  /VARIABLES=T1 T2 T3 T4 T5R
  /SCALE('Trust') ALL
  /MODEL=ALPHA
  /STATISTICS=DESCRIPTIVE SCALE CORR
  /SUMMARY=TOTAL MEANS.

RELIABILITY
  /VARIABLES=B1 B2 B3 B4
  /SCALE('AI literacy') ALL
  /MODEL=ALPHA
  /SUMMARY=TOTAL.


* ============================================================ .
* STEP 4.  FACTOR STRUCTURE AND COMMON METHOD BIAS              .
* ============================================================ .
* SPSS Base cannot fit a confirmatory factor model. The three-   .
* factor principal-axis solution approximates the CFA loadings   .
* reported in the thesis; the CFA was estimated separately       .
* (chi-square(74) = 123.52, CFI = .982, RMSEA = .050).           .

FACTOR
  /VARIABLES DV1 DV2 DV3 PR1 PR2 PR3 PR4 PR5 PR6 T1 T2 T3 T4 T5R
  /MISSING LISTWISE
  /ANALYSIS DV1 DV2 DV3 PR1 PR2 PR3 PR4 PR5 PR6 T1 T2 T3 T4 T5R
  /PRINT INITIAL KMO EXTRACTION ROTATION
  /FORMAT SORT BLANK(.30)
  /CRITERIA FACTORS(3) ITERATE(50)
  /EXTRACTION PAF
  /ROTATION PROMAX(4)
  /METHOD=CORRELATION.

* Harman single-factor test. Report the extraction "% of Variance"
* for factor 1; it must be below 50%.
FACTOR
  /VARIABLES DV1 DV2 DV3 PR1 PR2 PR3 PR4 PR5 PR6 T1 T2 T3 T4 T5R
  /MISSING LISTWISE
  /PRINT INITIAL EXTRACTION
  /CRITERIA FACTORS(1)
  /EXTRACTION PAF
  /ROTATION NOROTATE
  /METHOD=CORRELATION.


* ============================================================ .
* STEP 5.  RANDOMISATION CHECKS   -> Table E2                   .
* ============================================================ .
* In the R2 run two of these were significant (education        .
* p = .036; age band p < .001). Report them as they come out.   .

CROSSTABS
  /TABLES=SCENARIO BY D1 D2 D4 S1
  /STATISTICS=CHISQ
  /CELLS=COUNT EXPECTED
  /COUNT ROUND CELL.

ONEWAY LIT B7 B11 FAM_TB FAM_QW BY SCENARIO
  /STATISTICS DESCRIPTIVES HOMOGENEITY.


* ============================================================ .
* STEP 6.  MANIPULATION CHECKS   -> Table 4.3                   .
* ============================================================ .
* WELCH is requested because Levene was significant for both M1 .
* and M2 in the R2 run; report Welch's F alongside the ANOVA F. .

ONEWAY M1 M2 BY DELEG
  /STATISTICS DESCRIPTIVES HOMOGENEITY WELCH BROWNFORSYTHE
  /POSTHOC=GAMES-HOWELL BONFERRONI ALPHA(0.05).

CROSSTABS
  /TABLES=BACK BY M3
  /STATISTICS=CHISQ
  /CELLS=COUNT ROW
  /COUNT ROUND CELL.

T-TEST GROUPS=BACK(1 2)
  /VARIABLES=M4 FAM_TB FAM_QW
  /CRITERIA=CI(.95).


* ============================================================ .
* STEP 7.  DESCRIPTIVES AND CORRELATIONS   -> Table 4.4, F3     .
* ============================================================ .

MEANS TABLES=DV RISK TRUST BY DELEG BY BACK
  /CELLS=MEAN COUNT STDDEV.

MEANS TABLES=DV RISK TRUST BY DELEG
  /CELLS=MEAN COUNT STDDEV.

MEANS TABLES=DV RISK TRUST BY BACK
  /CELLS=MEAN COUNT STDDEV.

DESCRIPTIVES VARIABLES=DV RISK TRUST DV4 LIT B11 Q1 Q2 Q3 Q4 Q6 PB1
  /STATISTICS=MEAN STDDEV MIN MAX KURTOSIS SKEWNESS.

CORRELATIONS
  /VARIABLES=DV RISK TRUST LIT B7 B11 DELEG BACK
  /PRINT=TWOTAIL NOSIG
  /STATISTICS DESCRIPTIVES
  /MISSING=PAIRWISE.


* ============================================================ .
* STEP 8.  MAIN ANALYSIS - TWO-WAY ANCOVA   -> Tables 4.5, 4.6  .
* H1 (delegation), H2 (embeddedness), H3 (interaction)          .
* ============================================================ .
* Model A: full model with covariates. This is the reported model.

UNIANOVA DV BY DELEG BACK WITH D2 S1 LIT B10 B11
  /METHOD=SSTYPE(3)
  /INTERCEPT=INCLUDE
  /EMMEANS=TABLES(DELEG) COMPARE ADJ(BONFERRONI)
  /EMMEANS=TABLES(BACK) COMPARE ADJ(BONFERRONI)
  /EMMEANS=TABLES(DELEG*BACK) COMPARE(BACK) ADJ(BONFERRONI)
  /PLOT=PROFILE(DELEG*BACK) TYPE=LINE ERRORBAR=SE(1) MEANREFERENCE=NO
  /PLOT=PROFILE(DELEG) TYPE=LINE ERRORBAR=CI MEANREFERENCE=NO
  /PRINT=ETASQ DESCRIPTIVE HOMOGENEITY PARAMETER
  /CRITERIA=ALPHA(.05)
  /DESIGN=D2 S1 LIT B10 B11 DELEG BACK DELEG*BACK.

* Model B: no covariates, reported in the note under the ANCOVA table.

UNIANOVA DV BY DELEG BACK
  /METHOD=SSTYPE(3)
  /INTERCEPT=INCLUDE
  /EMMEANS=TABLES(DELEG) COMPARE ADJ(BONFERRONI)
  /EMMEANS=TABLES(BACK)
  /POSTHOC=DELEG(BONFERRONI)
  /PRINT=ETASQ DESCRIPTIVE HOMOGENEITY
  /CRITERIA=ALPHA(.05)
  /DESIGN=DELEG BACK DELEG*BACK.

* ---- H1a: the threshold prediction ---- .
*   Contrast 1 ( 1 -1  0) : low vs medium                        .
*   Contrast 2 ( 0  1 -1) : medium vs high                       .
*   Contrast 3 ( 1 -2  1) : QUADRATIC - this is the actual test  .
*                                                                .
* H1a claims the second decline exceeds the first. Comparing the .
* two point estimates is NOT a test of that claim. Contrast 3 is .
* algebraically (m1-m2) - (m2-m3), i.e. exactly the difference   .
* between the two declines, and it IS the test. In the R2 data   .
* it was t(264) = -1.19, p = .236: H1a is not supported.         .

ONEWAY DV BY DELEG
  /CONTRAST=1 -1 0
  /CONTRAST=0 1 -1
  /CONTRAST=1 -2 1
  /POLYNOMIAL=2
  /STATISTICS DESCRIPTIVES HOMOGENEITY EFFECTS
  /POSTHOC=BONFERRONI ALPHA(0.05).

* Same quadratic contrast with the covariates in the model.
UNIANOVA DV BY DELEG WITH D2 S1 LIT B10 B11
  /METHOD=SSTYPE(3)
  /CONTRAST(DELEG)=SPECIAL(1 -2 1)
  /PRINT=ETASQ PARAMETER
  /DESIGN=D2 S1 LIT B10 B11 DELEG.

* Same test on the secondary outcome and within each platform.
ONEWAY DV4 BY DELEG
  /CONTRAST=1 -2 1
  /STATISTICS DESCRIPTIVES.

SORT CASES BY BACK.
SPLIT FILE LAYERED BY BACK.
ONEWAY DV BY DELEG
  /CONTRAST=1 -2 1
  /STATISTICS DESCRIPTIVES.
SPLIT FILE OFF.

* The manipulation check must also be tested for equal spacing:
* if perceived autonomy is itself non-linear, a non-linear
* adoption response would be expected for that reason alone.
ONEWAY M1 BY DELEG
  /CONTRAST=1 -2 1
  /STATISTICS DESCRIPTIVES.


* ============================================================ .
* STEP 9.  ROBUSTNESS CHECKS   -> Table E4                      .
* ============================================================ .

* (a) Controlling Qwen familiarity and company familiarity.
*     This is the specification reported in the thesis.
UNIANOVA DV BY DELEG BACK WITH FAM_QW M4
  /METHOD=SSTYPE(3)
  /PRINT=ETASQ
  /DESIGN=FAM_QW M4 DELEG BACK DELEG*BACK.

* (a2) Additionally controlling Taobao familiarity.
UNIANOVA DV BY DELEG BACK WITH FAM_TB FAM_QW M4
  /METHOD=SSTYPE(3)
  /PRINT=ETASQ
  /DESIGN=FAM_TB FAM_QW M4 DELEG BACK DELEG*BACK.

* (b) Subsample: participants who had at least heard of AI shopping assistants.
TEMPORARY.
SELECT IF (B10 NE 4).
UNIANOVA DV BY DELEG BACK
  /METHOD=SSTYPE(3)
  /PRINT=ETASQ DESCRIPTIVE
  /DESIGN=DELEG BACK DELEG*BACK.

* (c) Scenario-bound adoption item (DV4) as the alternative outcome.
UNIANOVA DV4 BY DELEG BACK
  /METHOD=SSTYPE(3)
  /PRINT=ETASQ DESCRIPTIVE
  /DESIGN=DELEG BACK DELEG*BACK.


* ============================================================ .
* STEP 10.  MEDIATION - PROCESS MODEL 4   -> Table 4.7          .
* ============================================================ .
* PROCESS v5 is the current release. Load it ONE of two ways.    .
*                                                                .
* OPTION 1 - permanent install (recommended):                    .
*   Extensions > Install Local Extension Bundle... > process.spe .
*   then COMMENT OUT the INSERT line below.                      .
*                                                                .
* OPTION 2 - load once per session, via the INSERT below.        .
*   Check the actual filename in the download folder first:      .
*   v5 may ship it as process.sps, PROCESS.sps or process_v5.sps.
*                                                                .
* Do NOT add a bare `PROCESS.` command to test whether the macro .
* loaded: v5 treats it as an analysis with no Y, X or model and  .
* emits eight errors that pollute the output. If the macro did   .
* not load, the first real PROCESS command below will say so.    .

INSERT FILE='proj/process.sps'.

* Every option below (y x m cov model boot conf seed total
* effsize decimals mcx) has been stable since PROCESS v3 and was
* accepted by v5 in the R2 run. If a future version rejects one,
* delete ONLY that option from that one command; do not change
* the model number, the variables or the bootstrap count.

* ---- H4a  Delegation -> Perceived risk -> Adoption (PRIMARY) ---- .
* DELEG entered as a linear predictor. This is the reported model.
PROCESS y=DV /x=DELEG /m=RISK /cov=LIT B10 B11
  /model=4 /boot=5000 /conf=95 /bc=1 /seed=20260810
  /total=1 /effsize=1 /decimals=F10.4.

* ---- H4a supplementary: DELEG multicategorical ---- .
* Indicator coding, low delegation as reference. Yields two
* RELATIVE indirect effects, so the numbers will NOT match the
* primary model. Report as a specification check only, never as
* the primary test of H4a.
PROCESS y=DV /x=DELEG /m=RISK /cov=LIT B10 B11
  /model=4 /mcx=1 /boot=5000 /conf=95 /bc=1 /seed=20260810
  /total=1 /decimals=F10.4.

* ---- H4b  Platform embeddedness -> Trust -> Adoption ---- .
PROCESS y=DV /x=BACK /m=TRUST /cov=LIT B10 B11
  /model=4 /boot=5000 /conf=95 /bc=1 /seed=20260810
  /total=1 /effsize=1 /decimals=F10.4.

* ---- Post hoc 1  Embeddedness -> Perceived risk -> Adoption ---- .
PROCESS y=DV /x=BACK /m=RISK /cov=LIT B10 B11
  /model=4 /boot=5000 /conf=95 /bc=1 /seed=20260810
  /total=1 /effsize=1 /decimals=F10.4.

* ---- Post hoc 2  Delegation -> Trust -> Adoption ---- .
PROCESS y=DV /x=DELEG /m=TRUST /cov=LIT B10 B11
  /model=4 /boot=5000 /conf=95 /bc=1 /seed=20260810
  /total=1 /effsize=1 /decimals=F10.4.


* ============================================================ .
* STEP 11.  EXPLORATORY ANALYSES   -> Table E5                  .
* ============================================================ .

T-TEST PAIRS=Q1 Q3 WITH Q2 Q4 (PAIRED)
  /ES DISPLAY(TRUE)
  /CRITERIA=CI(.9500).

FREQUENCIES VARIABLES=Q5
  /ORDER=ANALYSIS.

DESCRIPTIVES VARIABLES=Q6
  /STATISTICS=MEAN STDDEV.

TEMPORARY.
SELECT IF (BACK EQ 2).
DESCRIPTIVES VARIABLES=PB1
  /STATISTICS=MEAN STDDEV MIN MAX.

TEMPORARY.
SELECT IF (BACK EQ 2).
CORRELATIONS
  /VARIABLES=PB1 RISK TRUST DV
  /PRINT=TWOTAIL NOSIG
  /MISSING=PAIRWISE.


* ============================================================ .
* STEP 12.  FIGURES SPSS CAN PRODUCE                            .
* ============================================================ .
* Figure 4.2 in the thesis: the three focal variables across     .
* delegation levels. SPSS cannot draw the attrition flow chart   .
* or the conceptual path diagram; those are built externally.    .

GRAPH
  /LINE(MULTIPLE) MEAN(DV) MEAN(RISK) MEAN(TRUST) BY DELEG
  /TITLE='Adoption, perceived risk and trust across delegation levels'.

* Figure 4.6: delegation willingness by category and price.
GRAPH
  /BAR(SIMPLE)=MEAN(Q1) MEAN(Q2) MEAN(Q3) MEAN(Q4)
  /INTERVAL SE(1)
  /TITLE='Willingness to delegate by product category and price'.


* ============================================================ .
* STEP 13.  EXPORT OUTPUT                                       .
* ============================================================ .

OUTPUT SAVE OUTFILE='proj/SPSS_R3_Output_Full.spv'.

OUTPUT EXPORT
  /CONTENTS EXPORT=ALL LAYERS=PRINTSETTING MODELVIEWS=PRINTSETTING
  /PDF DOCUMENTFILE='proj/SPSS_R3_Output_Full.pdf'.

OUTPUT EXPORT
  /CONTENTS EXPORT=ALL LAYERS=PRINTSETTING MODELVIEWS=PRINTSETTING
  /DOC DOCUMENTFILE='proj/SPSS_R3_Output_Full.doc'.

* /XLSX requires SPSS 25 or later. Delete this block if it errors.
OUTPUT EXPORT
  /CONTENTS EXPORT=ALL
  /XLSX DOCUMENTFILE='proj/SPSS_R3_All_Tables.xlsx' OPERATION=CREATEFILE.

* ============================================================ .
* END OF SYNTAX                                                 .
* ============================================================ .
