REPORT zstock_alloc_trfr.

PARAMETERS p_werks TYPE mard-werks OBLIGATORY.
PARAMETERS p_since TYPE d.

START-OF-SELECTION.

  TRY.
      DATA(lt_line) = zcl_alloc_trf_review=>create_default( )->run(
        iv_werks = p_werks
        iv_since = p_since ).
    CATCH zcx_allocation INTO DATA(lx_error).
      lt_line = VALUE #( ( lx_error->get_text( ) ) ).
  ENDTRY.

  LOOP AT lt_line INTO DATA(lv_line).
    WRITE / lv_line.
  ENDLOOP.
