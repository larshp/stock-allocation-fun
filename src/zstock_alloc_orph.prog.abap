REPORT zstock_alloc_orph.

PARAMETERS p_werks TYPE mard-werks OBLIGATORY.
PARAMETERS p_test AS CHECKBOX DEFAULT abap_true.

START-OF-SELECTION.

  TRY.
      DATA(lt_line) = zcl_alloc_orphans=>create_for_plant( p_werks )->run(
        iv_werks = p_werks
        iv_test  = p_test ).
    CATCH zcx_allocation INTO DATA(lx_error).
      lt_line = VALUE #( ( lx_error->get_text( ) ) ).
  ENDTRY.

  LOOP AT lt_line INTO DATA(lv_line).
    WRITE / lv_line.
  ENDLOOP.
