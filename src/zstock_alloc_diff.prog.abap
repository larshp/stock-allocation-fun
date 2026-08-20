REPORT zstock_alloc_diff.

PARAMETERS p_werks TYPE mard-werks OBLIGATORY.
PARAMETERS p_kunnr TYPE vbak-kunnr.
PARAMETERS p_worse AS CHECKBOX.

START-OF-SELECTION.

  TRY.
      DATA(lt_line) = zcl_alloc_changes=>create_default( )->run(
        iv_werks      = p_werks
        iv_kunnr      = p_kunnr
        iv_worse_only = p_worse ).
    CATCH zcx_allocation INTO DATA(lx_error).
      lt_line = VALUE #( ( lx_error->get_text( ) ) ).
  ENDTRY.

  LOOP AT lt_line INTO DATA(lv_line).
    WRITE / lv_line.
  ENDLOOP.
