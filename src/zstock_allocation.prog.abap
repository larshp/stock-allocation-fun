REPORT zstock_allocation.

PARAMETERS p_werks TYPE mard-werks OBLIGATORY.
PARAMETERS p_matnr TYPE mard-matnr.
PARAMETERS p_cfg AS CHECKBOX DEFAULT abap_true.
PARAMETERS p_fair AS CHECKBOX.
PARAMETERS p_horiz TYPE i DEFAULT 0.
PARAMETERS p_lgort TYPE mard-lgort.
PARAMETERS p_cap TYPE i DEFAULT 0.
PARAMETERS p_test AS CHECKBOX DEFAULT abap_true.

START-OF-SELECTION.

  DATA lo_strategy TYPE REF TO zif_allocation_strategy.
  DATA lt_matnr    TYPE zif_demand_reader=>ty_matnr_tab.
  DATA ls_settings TYPE zif_alloc_config=>ty_config.

  " P_CFG on is what a scheduled job runs with: the plant is the only thing it
  " has to know, everything else is Customizing. Off, the screen decides, which
  " is how a person tries something out without changing the settings.
  IF p_cfg = abap_true.
    DATA(lo_config) = CAST zif_alloc_config( NEW zcl_alloc_config( ) ).
    ls_settings = lo_config->for_plant( p_werks ).
  ELSE.
    ls_settings = VALUE #(
      werks        = p_werks
      fair_share   = p_fair
      horizon_days = p_horiz
      lgort        = p_lgort
      cap_percent  = p_cap ).
  ENDIF.

  IF ls_settings-fair_share = abap_true.
    lo_strategy = NEW zcl_alloc_strategy_fairshare( ).
  ENDIF.

  IF p_matnr IS NOT INITIAL.
    APPEND p_matnr TO lt_matnr.
  ENDIF.

  DATA(lo_report) = NEW zcl_allocation_report(
    zcl_allocation_mass_run=>create_default(
      io_strategy     = lo_strategy
      iv_horizon_days = ls_settings-horizon_days
      iv_lgort        = ls_settings-lgort
      iv_cap_percent  = ls_settings-cap_percent ) ).

  DATA(lt_line) = lo_report->run(
    iv_werks    = p_werks
    it_matnr    = lt_matnr
    iv_simulate = p_test ).

  LOOP AT lt_line INTO DATA(lv_line).
    WRITE / lv_line.
  ENDLOOP.
