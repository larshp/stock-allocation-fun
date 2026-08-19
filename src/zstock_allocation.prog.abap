REPORT zstock_allocation.

PARAMETERS p_werks TYPE mard-werks OBLIGATORY.
PARAMETERS p_matnr TYPE mard-matnr.
PARAMETERS p_fair AS CHECKBOX.
PARAMETERS p_horiz TYPE i DEFAULT 0.
PARAMETERS p_lgort TYPE mard-lgort.
PARAMETERS p_cap TYPE i DEFAULT 0.
PARAMETERS p_test AS CHECKBOX DEFAULT abap_true.

START-OF-SELECTION.

  DATA lo_strategy TYPE REF TO zif_allocation_strategy.
  DATA lt_matnr    TYPE zif_demand_reader=>ty_matnr_tab.

  IF p_fair = abap_true.
    lo_strategy = NEW zcl_alloc_strategy_fairshare( ).
  ENDIF.

  IF p_matnr IS NOT INITIAL.
    APPEND p_matnr TO lt_matnr.
  ENDIF.

  DATA(lo_report) = NEW zcl_allocation_report(
    zcl_allocation_mass_run=>create_default(
      io_strategy     = lo_strategy
      iv_horizon_days = p_horiz
      iv_lgort        = p_lgort
      iv_cap_percent  = p_cap ) ).

  DATA(lt_line) = lo_report->run(
    iv_werks    = p_werks
    it_matnr    = lt_matnr
    iv_simulate = p_test ).

  LOOP AT lt_line INTO DATA(lv_line).
    WRITE / lv_line.
  ENDLOOP.
