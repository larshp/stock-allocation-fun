CLASS ltcl_alloc_hold DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    CONSTANTS c_werks TYPE mard-werks VALUE '9901'.
    CONSTANTS c_matnr TYPE mard-matnr VALUE 'HOLDCLS-MAT-01'.
    CONSTANTS c_today TYPE d VALUE '20260301'.

    METHODS teardown.

    METHODS given_hold
      IMPORTING
        iv_reason TYPE zstock_alloc_hld-reason DEFAULT 'quality are looking at it'
        iv_until  TYPE zstock_alloc_hld-until_date DEFAULT '00000000'.

    METHODS a_hold_is_found FOR TESTING.
    METHODS the_reason_comes_back FOR TESTING.
    METHODS a_lapsed_hold_is_gone FOR TESTING.
    METHODS a_hold_with_no_reason FOR TESTING.
    METHODS no_hold_is_no_reason FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_hold IMPLEMENTATION.

  METHOD teardown.

    DELETE FROM zstock_alloc_hld WHERE werks = @c_werks.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

  ENDMETHOD.

  METHOD given_hold.

    DATA lt_row TYPE STANDARD TABLE OF zstock_alloc_hld WITH EMPTY KEY.

    lt_row = VALUE #(
      ( mandt      = sy-mandt
        werks      = c_werks
        matnr      = c_matnr
        reason     = iv_reason
        until_date = iv_until ) ).

    INSERT zstock_alloc_hld FROM TABLE @lt_row.
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0
      msg = 'hold fixture could not be inserted' ).

  ENDMETHOD.

  METHOD a_hold_is_found.

    given_hold( ).

    cl_abap_unit_assert=>assert_equals(
      act = zcl_alloc_hold=>materials(
        iv_werks = c_werks
        iv_today = c_today )
      exp = VALUE zif_demand_reader=>ty_matnr_tab( ( c_matnr ) ) ).

  ENDMETHOD.

  METHOD the_reason_comes_back.

    given_hold( ).

    cl_abap_unit_assert=>assert_equals(
      act = zcl_alloc_hold=>reason_for(
        iv_matnr = c_matnr
        iv_werks = c_werks
        iv_today = c_today )
      exp = `quality are looking at it`
      msg = 'the reason is what somebody needs to decide whether it can go' ).

  ENDMETHOD.

  METHOD a_lapsed_hold_is_gone.

    given_hold( iv_until = '20260228' ).

    cl_abap_unit_assert=>assert_initial(
      act = zcl_alloc_hold=>reason_for(
        iv_matnr = c_matnr
        iv_werks = c_werks
        iv_today = c_today )
      msg = 'what "on hold" means is decided in one place, lapsing included' ).

  ENDMETHOD.

  METHOD a_hold_with_no_reason.

    given_hold( iv_reason = '' ).

    cl_abap_unit_assert=>assert_equals(
      act = zcl_alloc_hold=>reason_for(
        iv_matnr = c_matnr
        iv_werks = c_werks
        iv_today = c_today )
      exp = `no reason given`
      msg = 'a hold nobody explained is still a hold, and saying so beats silence' ).

  ENDMETHOD.

  METHOD no_hold_is_no_reason.

    cl_abap_unit_assert=>assert_initial(
      act = zcl_alloc_hold=>reason_for(
        iv_matnr = c_matnr
        iv_werks = c_werks
        iv_today = c_today )
      msg = 'a material nobody held has nothing to explain' ).

  ENDMETHOD.

ENDCLASS.
