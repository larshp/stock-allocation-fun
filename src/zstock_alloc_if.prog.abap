REPORT zstock_alloc_if.

PARAMETERS p_werks TYPE mard-werks OBLIGATORY.
PARAMETERS p_matnr TYPE mard-matnr OBLIGATORY.
PARAMETERS p_menge TYPE zif_allocation=>ty_quantity OBLIGATORY.
PARAMETERS p_datum TYPE d.

START-OF-SELECTION.

  TRY.
      DATA(lt_line) = zcl_alloc_if_supply=>create_for_plant( p_werks )->run(
        iv_matnr    = p_matnr
        iv_werks    = p_werks
        iv_quantity = p_menge
        iv_date     = p_datum ).
    CATCH zcx_allocation INTO DATA(lx_error).
      lt_line = VALUE #( ( lx_error->get_text( ) ) ).
  ENDTRY.

  LOOP AT lt_line INTO DATA(lv_line).
    WRITE / lv_line.
  ENDLOOP.
