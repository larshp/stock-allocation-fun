REPORT zstock_alloc_reorg.

PARAMETERS p_werks TYPE mard-werks OBLIGATORY.
PARAMETERS p_days TYPE i DEFAULT 90.
PARAMETERS p_test AS CHECKBOX DEFAULT abap_true.

START-OF-SELECTION.

  TRY.
      DATA(ls_outcome) = zcl_alloc_housekeeping=>create_default( )->run(
        iv_werks     = p_werks
        iv_keep_days = p_days
        iv_test      = p_test ).

      WRITE / |{ COND string( WHEN p_test = abap_true
                              THEN 'Test run, nothing was removed. Would remove'
                              ELSE 'Removed' ) } | &&
              |{ ls_outcome-deleted } run(s), | &&
              |{ ls_outcome-kept } still in use|.
    CATCH zcx_allocation INTO DATA(lx_error).
      WRITE / lx_error->get_text( ).
  ENDTRY.
