REPORT zstock_alloc_try.

PARAMETERS p_werks TYPE mard-werks OBLIGATORY.
PARAMETERS p_matnr TYPE mard-matnr OBLIGATORY.
PARAMETERS p_cap TYPE i DEFAULT 0.
PARAMETERS p_whole AS CHECKBOX.

START-OF-SELECTION.

  " where the stock comes from is the plant's decision and is not what this
  " report is asking about, so it is read rather than offered
  DATA(lo_config) = CAST zif_alloc_config( NEW zcl_alloc_config( ) ).
  DATA(ls_settings) = lo_config->for_plant( p_werks ).

  TRY.
      DATA(lt_line) = zcl_alloc_compare=>create_default(
        iv_lgort        = ls_settings-lgort
        iv_planned      = ls_settings-planned
        iv_horizon_days = ls_settings-horizon_days
        iv_ship_days    = ls_settings-ship_days )->run(
          iv_matnr       = p_matnr
          iv_werks       = p_werks
          iv_cap_percent = p_cap
          iv_whole_units = p_whole ).
    CATCH zcx_allocation INTO DATA(lx_error).
      lt_line = VALUE #( ( lx_error->get_text( ) ) ).
  ENDTRY.

  LOOP AT lt_line INTO DATA(lv_line).
    WRITE / lv_line.
  ENDLOOP.
