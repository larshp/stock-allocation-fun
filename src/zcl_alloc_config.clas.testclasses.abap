CLASS ltcl_alloc_config DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_werks TYPE mard-werks VALUE '9101'.

    DATA mo_cut TYPE REF TO zif_alloc_config.

    METHODS setup.
    METHODS teardown.

    METHODS given_settings
      IMPORTING
        iv_strategy TYPE zstock_alloc_cfg-strategy DEFAULT ''
        iv_horizon  TYPE zstock_alloc_cfg-horizon_days DEFAULT 0
        iv_lgort    TYPE zstock_alloc_cfg-lgort DEFAULT ''
        iv_cap      TYPE zstock_alloc_cfg-cap_percent DEFAULT 0
        iv_keep     TYPE zstock_alloc_cfg-keep_days DEFAULT 0
        iv_planned  TYPE zstock_alloc_cfg-planned DEFAULT ''.

    METHODS config
      RETURNING
        VALUE(rs_config) TYPE zif_alloc_config=>ty_config.

    METHODS unconfigured_plant_is_default FOR TESTING.
    METHODS settings_are_read FOR TESTING.
    METHODS priority_is_anything_but_f FOR TESTING.
    METHODS negative_horizon_is_no_limit FOR TESTING.
    METHODS cap_cannot_exceed_the_pool FOR TESTING.
    METHODS negative_cap_is_no_cap FOR TESTING.
    METHODS keeping_nothing_is_a_setting FOR TESTING.
    METHODS other_plant_is_not_read FOR TESTING.
    METHODS planned_supply_is_read FOR TESTING.
    METHODS planned_supply_is_off_default FOR TESTING.
    METHODS anything_but_x_is_no FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_config IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_config( ).
  ENDMETHOD.

  METHOD teardown.

    DELETE FROM zstock_alloc_cfg WHERE werks = @c_werks.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

  ENDMETHOD.

  METHOD given_settings.

    DATA lt_row TYPE STANDARD TABLE OF zstock_alloc_cfg WITH EMPTY KEY.

    lt_row = VALUE #(
      ( mandt        = sy-mandt
        werks        = c_werks
        strategy     = iv_strategy
        horizon_days = iv_horizon
        lgort        = iv_lgort
        cap_percent  = iv_cap
        keep_days    = iv_keep
        planned      = iv_planned ) ).

    INSERT zstock_alloc_cfg FROM TABLE @lt_row.
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0
      msg = 'settings fixture could not be inserted' ).

  ENDMETHOD.

  METHOD config.
    rs_config = mo_cut->for_plant( c_werks ).
  ENDMETHOD.

  METHOD unconfigured_plant_is_default.

    cl_abap_unit_assert=>assert_equals(
      act = config( )
      exp = VALUE zif_alloc_config=>ty_config(
        werks     = c_werks
        keep_days = zcl_alloc_config=>c_default_keep_days )
      msg = 'allocation has to work in a plant nobody has configured' ).

  ENDMETHOD.

  METHOD settings_are_read.

    given_settings(
      iv_strategy = zcl_alloc_config=>c_fair_share
      iv_horizon  = 30
      iv_lgort    = '0001'
      iv_cap      = 25
      iv_keep     = 14 ).

    cl_abap_unit_assert=>assert_equals(
      act = config( )
      exp = VALUE zif_alloc_config=>ty_config(
        werks        = c_werks
        fair_share   = abap_true
        horizon_days = 30
        lgort        = '0001'
        cap_percent  = 25
        keep_days    = 14 ) ).

  ENDMETHOD.

  METHOD priority_is_anything_but_f.

    given_settings( iv_strategy = 'P' ).

    cl_abap_unit_assert=>assert_false(
      act = config( )-fair_share
      msg = 'only F asks for a fair share, everything else is priority' ).

  ENDMETHOD.

  METHOD negative_horizon_is_no_limit.

    given_settings( iv_horizon = -10 ).

    cl_abap_unit_assert=>assert_equals(
      act = config( )-horizon_days
      exp = 0
      msg = 'a night run must not stop because somebody typed a minus' ).

  ENDMETHOD.

  METHOD cap_cannot_exceed_the_pool.

    given_settings( iv_cap = 150 ).

    cl_abap_unit_assert=>assert_equals(
      act = config( )-cap_percent
      exp = zcl_alloc_config=>c_max_percent
      msg = 'a share of the pool cannot be more than the whole of it' ).

  ENDMETHOD.

  METHOD negative_cap_is_no_cap.

    given_settings( iv_cap = -5 ).

    cl_abap_unit_assert=>assert_equals(
      act = config( )-cap_percent
      exp = 0 ).

  ENDMETHOD.

  METHOD keeping_nothing_is_a_setting.

    given_settings( iv_keep = 0 ).

    cl_abap_unit_assert=>assert_equals(
      act = config( )-keep_days
      exp = 0
      msg = 'a configured zero means zero, the default is for plants with no row' ).

  ENDMETHOD.

  METHOD planned_supply_is_read.

    given_settings( iv_planned = 'X' ).

    cl_abap_unit_assert=>assert_equals(
      act = config( )-planned
      exp = abap_true
      msg = 'a plant that trusts its plan may allocate against it' ).

  ENDMETHOD.

  METHOD planned_supply_is_off_default.

    given_settings( ).

    cl_abap_unit_assert=>assert_equals(
      act = config( )-planned
      exp = abap_false
      msg = 'promising stock nobody has ordered yet has to be asked for' ).

  ENDMETHOD.

  METHOD anything_but_x_is_no.

    given_settings( iv_planned = 'Y' ).

    cl_abap_unit_assert=>assert_equals(
      act = config( )-planned
      exp = abap_false
      msg = 'a flag holding something else is not a yes' ).

  ENDMETHOD.

  METHOD other_plant_is_not_read.

    given_settings( iv_horizon = 30 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->for_plant( '9102' )-horizon_days
      exp = 0 ).

  ENDMETHOD.

ENDCLASS.
