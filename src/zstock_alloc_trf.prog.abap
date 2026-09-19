REPORT zstock_alloc_trf.

PARAMETERS p_werks TYPE mard-werks.
PARAMETERS p_matnr TYPE mard-matnr.
PARAMETERS p_all AS CHECKBOX.
PARAMETERS p_test AS CHECKBOX DEFAULT 'X'.

START-OF-SELECTION.

  DATA lt_line TYPE zcl_alloc_propose=>ty_line_tab.

  " a plant or all of them. Every plant is the schedulable shape: since
  " feature 170 a note is a claim on the plant it asks, so one job covering
  " the company decides who gets the spare, and twenty jobs leave it to
  " whichever one the operator happened to start first.
  IF p_all = abap_false AND p_werks IS INITIAL.
    WRITE / 'Name a plant, or tick every plant'.
    RETURN.
  ENDIF.

  TRY.
      DATA(lo_propose) = zcl_alloc_propose=>create_default( ).

      IF p_all = abap_true.
        lt_line = lo_propose->run_everywhere( p_test ).
      ELSE.
        lt_line = lo_propose->run(
          iv_werks = p_werks
          iv_matnr = p_matnr
          iv_test  = p_test ).
      ENDIF.
    CATCH zcx_allocation INTO DATA(lx_error).
      lt_line = VALUE #( ( lx_error->get_text( ) ) ).
  ENDTRY.

  LOOP AT lt_line INTO DATA(lv_line).
    WRITE / lv_line.
  ENDLOOP.
