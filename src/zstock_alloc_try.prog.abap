REPORT zstock_alloc_try.

PARAMETERS p_werks TYPE mard-werks OBLIGATORY.
PARAMETERS p_matnr TYPE mard-matnr OBLIGATORY.
PARAMETERS p_cap TYPE i DEFAULT 0.
PARAMETERS p_whole AS CHECKBOX.
PARAMETERS p_quota AS CHECKBOX.

START-OF-SELECTION.

  " where the stock comes from is the plant's decision and is not what this
  " report is asking about, so it is read rather than offered
  TRY.
      DATA(lt_line) = zcl_alloc_compare=>create_for_plant( p_werks )->run(
        iv_matnr       = p_matnr
        iv_werks       = p_werks
        iv_cap_percent = p_cap
        iv_whole_units = p_whole
        iv_quota       = p_quota ).
    CATCH zcx_allocation INTO DATA(lx_error).
      lt_line = VALUE #( ( lx_error->get_text( ) ) ).
  ENDTRY.

  LOOP AT lt_line INTO DATA(lv_line).
    WRITE / lv_line.
  ENDLOOP.
