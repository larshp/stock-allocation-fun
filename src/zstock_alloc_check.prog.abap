REPORT zstock_alloc_check.

PARAMETERS p_werks TYPE mard-werks OBLIGATORY.

START-OF-SELECTION.

  TRY.
      DATA(lt_line) = zcl_alloc_consistency=>create_default( )->run( p_werks ).
    CATCH zcx_allocation INTO DATA(lx_error).
      lt_line = VALUE #( ( lx_error->get_text( ) ) ).
  ENDTRY.

  LOOP AT lt_line INTO DATA(lv_line).
    WRITE / lv_line.
  ENDLOOP.
