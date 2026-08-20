REPORT zstock_alloc_what.

PARAMETERS p_werks TYPE mard-werks OBLIGATORY.
PARAMETERS p_matnr TYPE mard-matnr OBLIGATORY.
PARAMETERS p_menge TYPE zif_allocation=>ty_quantity OBLIGATORY.
PARAMETERS p_datum TYPE d.
PARAMETERS p_kunnr TYPE vbak-kunnr.
PARAMETERS p_prio TYPE zif_allocation=>ty_priority DEFAULT '50'.

START-OF-SELECTION.

  DATA lo_strategy TYPE REF TO zif_allocation_strategy.

  " the answer has to be worked out the way a run would work it out, or it is
  " answering a different question in the same words, so everything but the
  " order being asked about comes from the plant's own settings
  DATA(lo_config) = CAST zif_alloc_config( NEW zcl_alloc_config( ) ).
  DATA(ls_settings) = lo_config->for_plant( p_werks ).

  IF ls_settings-fair_share = abap_true.
    lo_strategy = NEW zcl_alloc_strategy_fairshare( ).
  ENDIF.

  TRY.
      DATA(lt_line) = zcl_alloc_whatif=>create_default(
        iv_lgort        = ls_settings-lgort
        iv_planned      = ls_settings-planned
        iv_horizon_days = ls_settings-horizon_days
        iv_ship_days    = ls_settings-ship_days
        iv_age_days     = ls_settings-age_days
        io_strategy     = lo_strategy
        iv_cap_percent  = ls_settings-cap_percent
        iv_whole_units  = ls_settings-whole_units
        iv_quota        = ls_settings-quota )->run(
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
