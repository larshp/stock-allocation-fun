REPORT zstock_alloc_trf.

PARAMETERS p_werks TYPE mard-werks OBLIGATORY.
PARAMETERS p_matnr TYPE mard-matnr.
PARAMETERS p_test AS CHECKBOX DEFAULT 'X'.

START-OF-SELECTION.

  TRY.
      DATA(lt_line) = zcl_alloc_propose=>create_default( )->run(
        iv_werks = p_werks
        iv_matnr = p_matnr
        iv_test  = p_test ).
    CATCH zcx_allocation INTO DATA(lx_error).
      lt_line = VALUE #( ( lx_error->get_text( ) ) ).
  ENDTRY.

  LOOP AT lt_line INTO DATA(lv_line).
    WRITE / lv_line.
  ENDLOOP.
