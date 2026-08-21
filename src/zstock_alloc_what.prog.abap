REPORT zstock_alloc_what.

PARAMETERS p_werks TYPE mard-werks OBLIGATORY.
PARAMETERS p_matnr TYPE mard-matnr OBLIGATORY.
PARAMETERS p_menge TYPE zif_allocation=>ty_quantity OBLIGATORY.
PARAMETERS p_datum TYPE d.
PARAMETERS p_kunnr TYPE vbak-kunnr.
PARAMETERS p_prio TYPE zif_allocation=>ty_priority DEFAULT '50'.

START-OF-SELECTION.

  " the answer has to be worked out the way a run would work it out, or it is
  " answering a different question in the same words, so everything but the
  " order being asked about comes from the plant's own settings
  TRY.
      DATA(lt_line) = zcl_alloc_whatif=>create_for_plant( p_werks )->run(
        iv_matnr    = p_matnr
        iv_werks    = p_werks
        iv_quantity = p_menge
        iv_req_date = p_datum
        iv_kunnr    = p_kunnr
        iv_priority = p_prio ).
    CATCH zcx_allocation INTO DATA(lx_error).
      lt_line = VALUE #( ( lx_error->get_text( ) ) ).
  ENDTRY.

  LOOP AT lt_line INTO DATA(lv_line).
    WRITE / lv_line.
  ENDLOOP.
