REPORT zstock_alloc_reorg.

PARAMETERS p_werks TYPE mard-werks OBLIGATORY.
PARAMETERS p_cfg AS CHECKBOX DEFAULT abap_true.
PARAMETERS p_days TYPE i DEFAULT 90.
PARAMETERS p_test AS CHECKBOX DEFAULT abap_true.

START-OF-SELECTION.

  DATA lv_keep_days TYPE i.

  " how long a plant keeps its recorded runs belongs with the rest of its
  " allocation settings, so a scheduled housekeeping job needs the plant and
  " nothing besides. P_DAYS is there for a one off clean up.
  IF p_cfg = abap_true.
    DATA(lo_config) = CAST zif_alloc_config( NEW zcl_alloc_config( ) ).
    lv_keep_days = lo_config->for_plant( p_werks )-keep_days.
  ELSE.
    lv_keep_days = p_days.
  ENDIF.

  TRY.
      DATA(ls_outcome) = zcl_alloc_housekeeping=>create_default( )->run(
        iv_werks     = p_werks
        iv_keep_days = lv_keep_days
        iv_test      = p_test ).

      WRITE / |{ COND string( WHEN p_test = abap_true
                              THEN 'Test run, nothing was removed. Would remove'
                              ELSE 'Removed' ) } | &&
              |{ ls_outcome-deleted } run(s), | &&
              |{ ls_outcome-kept } still in use|.
    CATCH zcx_allocation INTO DATA(lx_error).
      WRITE / lx_error->get_text( ).
  ENDTRY.
