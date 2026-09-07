REPORT zstock_alloc_free.

PARAMETERS p_werks TYPE mard-werks OBLIGATORY.
PARAMETERS p_matnr TYPE mard-matnr OBLIGATORY.
PARAMETERS p_test AS CHECKBOX DEFAULT abap_true.

START-OF-SELECTION.

  TRY.
      DATA(ls_outcome) = zcl_alloc_release=>create_default( )->run(
        iv_matnr = p_matnr
        iv_werks = p_werks
        iv_test  = p_test ).

      IF ls_outcome-freed = 0.
        WRITE / |Nothing is earmarked for { p_matnr } in { p_werks }|.
        RETURN.
      ENDIF.

      WRITE / |{ COND string( WHEN p_test = abap_true
                              THEN 'Test run, nothing was given back. Would give back'
                              ELSE 'Gave back' ) } | &&
              |{ ls_outcome-freed } reservation(s), | &&
              |{ ls_outcome-quantity } back into the pool|.
    CATCH zcx_allocation INTO DATA(lx_error).
      WRITE / lx_error->get_text( ).
  ENDTRY.
