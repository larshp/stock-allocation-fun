REPORT zstock_alloc_alt.

PARAMETERS p_werks TYPE mard-werks OBLIGATORY.
PARAMETERS p_matnr TYPE mard-matnr.

START-OF-SELECTION.

  TRY.
      DATA(lt_line) = zcl_alloc_substitute=>create_for_plant( p_werks )->run(
        iv_werks = p_werks
        iv_matnr = p_matnr ).
    CATCH zcx_allocation INTO DATA(lx_error).
      lt_line = VALUE #( ( lx_error->get_text( ) ) ).
  ENDTRY.

  LOOP AT lt_line INTO DATA(lv_line).
    WRITE / lv_line.
  ENDLOOP.
