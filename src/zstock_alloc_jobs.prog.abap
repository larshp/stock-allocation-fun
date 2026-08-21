REPORT zstock_alloc_jobs.

PARAMETERS p_werks TYPE mard-werks OBLIGATORY.
PARAMETERS p_jobs TYPE i DEFAULT 4.
PARAMETERS p_recut AS CHECKBOX.
PARAMETERS p_test AS CHECKBOX DEFAULT abap_true.

START-OF-SELECTION.

  TRY.
      DATA(lt_jobname) = zcl_alloc_job_split=>create_default( )->run(
        iv_werks = p_werks
        iv_jobs  = p_jobs
        iv_test  = p_test
        iv_recut = p_recut ).

      WRITE / |{ lines( lt_jobname ) } job(s) scheduled to start now|.

      LOOP AT lt_jobname INTO DATA(lv_jobname).
        WRITE / lv_jobname.
      ENDLOOP.
    CATCH zcx_allocation INTO DATA(lx_error).
      WRITE / lx_error->get_text( ).
  ENDTRY.
