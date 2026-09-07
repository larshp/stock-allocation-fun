REPORT zstock_alloc_prom.

PARAMETERS p_werks TYPE mard-werks OBLIGATORY.
PARAMETERS p_all AS CHECKBOX.

START-OF-SELECTION.

  TRY.
      DATA(lt_line) = zcl_alloc_promise_list=>create_default( )->run(
        iv_werks = p_werks
        iv_all   = p_all ).
    CATCH zcx_allocation INTO DATA(lx_error).
      lt_line = VALUE #( ( lx_error->get_text( ) ) ).
  ENDTRY.

  LOOP AT lt_line INTO DATA(lv_line).
    WRITE / lv_line.
  ENDLOOP.
