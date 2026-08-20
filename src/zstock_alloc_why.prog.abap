REPORT zstock_alloc_why.

PARAMETERS p_werks TYPE mard-werks OBLIGATORY.
PARAMETERS p_matnr TYPE mard-matnr OBLIGATORY.

START-OF-SELECTION.

  DATA lo_strategy TYPE REF TO zif_allocation_strategy.

  " which locations count and whether the plan counts are decisions about the
  " plant, and the working shown has to be the working a run would do
  DATA(lo_config) = CAST zif_alloc_config( NEW zcl_alloc_config( ) ).
  DATA(ls_settings) = lo_config->for_plant( p_werks ).

  " the working shown has to be the working done, so the plant's own rule and
  " its own limits are the ones the explanation uses
  IF ls_settings-fair_share = abap_true.
    lo_strategy = NEW zcl_alloc_strategy_fairshare( ).
  ENDIF.

  TRY.
      DATA(lt_line) = zcl_alloc_explain=>create_default(
        iv_lgort        = ls_settings-lgort
        iv_planned      = ls_settings-planned
        iv_horizon_days = ls_settings-horizon_days
        iv_ship_days    = ls_settings-ship_days
        iv_age_days     = ls_settings-age_days
        io_strategy     = lo_strategy
        iv_cap_percent  = ls_settings-cap_percent
        iv_whole_units  = ls_settings-whole_units
        iv_quota        = ls_settings-quota )->run(
          iv_matnr = p_matnr
          iv_werks = p_werks ).
    CATCH zcx_allocation INTO DATA(lx_error).
      lt_line = VALUE #( ( lx_error->get_text( ) ) ).
  ENDTRY.

  LOOP AT lt_line INTO DATA(lv_line).
    WRITE / lv_line.
  ENDLOOP.
