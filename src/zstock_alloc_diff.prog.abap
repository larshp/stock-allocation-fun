REPORT zstock_alloc_diff.

PARAMETERS p_werks TYPE mard-werks OBLIGATORY.
PARAMETERS p_kunnr TYPE vbak-kunnr.
PARAMETERS p_worse AS CHECKBOX.
PARAMETERS p_prev AS CHECKBOX.

START-OF-SELECTION.

  TRY.
      " a preview works the plant out again as it stands, with the plant's own
      " settings, which is the same calculation a run does and takes about as
      " long
      DATA(lt_line) = zcl_alloc_changes=>create_for_plant( p_werks )->run(
        iv_werks      = p_werks
        iv_kunnr      = p_kunnr
        iv_worse_only = p_worse
        iv_preview    = p_prev ).
    CATCH zcx_allocation INTO DATA(lx_error).
      lt_line = VALUE #( ( lx_error->get_text( ) ) ).
  ENDTRY.

  LOOP AT lt_line INTO DATA(lv_line).
    WRITE / lv_line.
  ENDLOOP.
