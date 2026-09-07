REPORT zstock_allocation.

PARAMETERS p_werks TYPE mard-werks OBLIGATORY.
PARAMETERS p_matnr TYPE mard-matnr.
PARAMETERS p_dispo TYPE marc-dispo.
PARAMETERS p_pkg TYPE i DEFAULT 0.
PARAMETERS p_pkgs TYPE i DEFAULT 0.
PARAMETERS p_cfg AS CHECKBOX DEFAULT abap_true.
PARAMETERS p_fair AS CHECKBOX.
PARAMETERS p_horiz TYPE i DEFAULT 0.
PARAMETERS p_lgort TYPE mard-lgort.
PARAMETERS p_cap TYPE i DEFAULT 0.
PARAMETERS p_stop TYPE zif_allocation=>ty_priority DEFAULT '50'.
PARAMETERS p_ship TYPE i DEFAULT 0.
PARAMETERS p_age TYPE i DEFAULT 0.
PARAMETERS p_plan AS CHECKBOX.
PARAMETERS p_whole AS CHECKBOX.
PARAMETERS p_quota AS CHECKBOX.
PARAMETERS p_work AS CHECKBOX.
PARAMETERS p_recut AS CHECKBOX.
PARAMETERS p_carry AS CHECKBOX.
PARAMETERS p_test AS CHECKBOX DEFAULT abap_true.

START-OF-SELECTION.

  " a package number that matches nothing would read the plant, allocate
  " nothing and report success, which is the one way a split job can fail
  " without anybody noticing. It is said and the run stops rather than
  " looking like a quiet night.
  IF zcl_demand_in_package=>is_a_package(
       iv_package  = p_pkg
       iv_packages = p_pkgs ) = abap_false.
    WRITE / |Package { p_pkg } of { p_pkgs } would cover no material at all|.
    RETURN.
  ENDIF.

  DATA lo_strategy TYPE REF TO zif_allocation_strategy.
  DATA lt_matnr    TYPE zif_demand_reader=>ty_matnr_tab.
  DATA lt_dispo    TYPE zcl_demand_of_controller=>ty_dispo_tab.
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
      cap_percent  = p_cap
      planned      = p_plan
      whole_units  = p_whole
      quota        = p_quota
      work_days    = p_work
      move_type    = zcl_reservation_writer=>c_default_move_type
      sto_priority = p_stop
      ship_days    = p_ship
      age_days     = p_age ).
  ENDIF.

  IF ls_settings-fair_share = abap_true.
    lo_strategy = NEW zcl_alloc_strategy_fairshare( ).
  ENDIF.

  IF p_matnr IS NOT INITIAL.
    APPEND p_matnr TO lt_matnr.
  ENDIF.

  " which materials a job covers is a property of the job rather than of the
  " plant, so it stays on the screen whatever P_CFG says. The screen offers one
  " controller, the class takes as many as a caller wiring it wants to name.
  IF p_dispo IS NOT INITIAL.
    APPEND p_dispo TO lt_dispo.
  ENDIF.

  DATA(lo_report) = NEW zcl_allocation_report(
    zcl_allocation_mass_run=>create_default(
      is_settings = ls_settings
      io_strategy = lo_strategy
      iv_recut    = p_recut
      it_dispo    = lt_dispo
      iv_package  = p_pkg
      iv_packages = p_pkgs ) ).

  DATA(lt_line) = lo_report->run(
    iv_werks    = p_werks
    it_matnr    = lt_matnr
    iv_simulate = p_test
    iv_carry_on = p_carry ).

  LOOP AT lt_line INTO DATA(lv_line).
    WRITE / lv_line.
  ENDLOOP.
