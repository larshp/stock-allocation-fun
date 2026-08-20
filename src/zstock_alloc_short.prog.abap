REPORT zstock_alloc_short.

PARAMETERS p_werks TYPE mard-werks OBLIGATORY.
PARAMETERS p_until TYPE d.
PARAMETERS p_top TYPE i DEFAULT 0.
PARAMETERS p_dispo TYPE marc-dispo.
PARAMETERS p_kunnr TYPE vbak-kunnr.

START-OF-SELECTION.

  TRY.
      DATA(lt_line) = zcl_alloc_shortage_list=>create_default( )->run(
        iv_werks = p_werks
        iv_until = p_until
        iv_top   = p_top
        iv_dispo = p_dispo
        iv_kunnr = p_kunnr ).
    CATCH zcx_allocation INTO DATA(lx_error).
      lt_line = VALUE #( ( lx_error->get_text( ) ) ).
  ENDTRY.

  LOOP AT lt_line INTO DATA(lv_line).
    WRITE / lv_line.
  ENDLOOP.
