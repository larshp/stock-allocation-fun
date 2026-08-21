REPORT zstock_alloc_hist.

PARAMETERS p_werks TYPE mard-werks OBLIGATORY.
PARAMETERS p_vbeln TYPE vbap-vbeln.
PARAMETERS p_posnr TYPE vbap-posnr.
PARAMETERS p_ebeln TYPE ekko-ebeln.

START-OF-SELECTION.

  " a sales order or a stock transport order: the plant on the other end of a
  " transfer is waiting exactly as a customer is
  IF p_vbeln IS INITIAL AND p_ebeln IS INITIAL.
    WRITE / 'Name a sales order or a purchasing document'.
    RETURN.
  ENDIF.

  TRY.
      DATA(lt_line) = zcl_alloc_history=>create_default( )->run(
        iv_werks = p_werks
        iv_vbeln = p_vbeln
        iv_posnr = p_posnr
        iv_ebeln = p_ebeln ).
    CATCH zcx_allocation INTO DATA(lx_error).
      lt_line = VALUE #( ( lx_error->get_text( ) ) ).
  ENDTRY.

  LOOP AT lt_line INTO DATA(lv_line).
    WRITE / lv_line.
  ENDLOOP.
