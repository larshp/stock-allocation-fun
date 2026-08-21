REPORT zstock_alloc_hist.

PARAMETERS p_werks TYPE mard-werks OBLIGATORY.
PARAMETERS p_vbeln TYPE vbap-vbeln OBLIGATORY.
PARAMETERS p_posnr TYPE vbap-posnr.

START-OF-SELECTION.

  TRY.
      DATA(lt_line) = zcl_alloc_history=>create_default( )->run(
        iv_werks = p_werks
        iv_vbeln = p_vbeln
        iv_posnr = p_posnr ).
    CATCH zcx_allocation INTO DATA(lx_error).
      lt_line = VALUE #( ( lx_error->get_text( ) ) ).
  ENDTRY.

  LOOP AT lt_line INTO DATA(lv_line).
    WRITE / lv_line.
  ENDLOOP.
