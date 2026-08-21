REPORT zstock_alloc_cover.

PARAMETERS p_werks TYPE mard-werks OBLIGATORY.
PARAMETERS p_hours TYPE i DEFAULT 24.

START-OF-SELECTION.

  TRY.
      DATA(lt_line) = zcl_alloc_coverage=>create_for_plant( p_werks )->run(
        iv_werks = p_werks
        iv_hours = p_hours ).
    CATCH zcx_allocation INTO DATA(lx_error).
      lt_line = VALUE #( ( lx_error->get_text( ) ) ).
  ENDTRY.

  LOOP AT lt_line INTO DATA(lv_line).
    WRITE / lv_line.
  ENDLOOP.
