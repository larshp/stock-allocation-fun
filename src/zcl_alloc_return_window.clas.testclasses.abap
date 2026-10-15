CLASS ltcl_alloc_return_window DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_return_window.

    METHODS setup.

    METHODS expiry_same_month   FOR TESTING.
    METHODS expiry_next_month   FOR TESTING.
    METHODS expiry_next_year    FOR TESTING.
    METHODS expiry_leap_day     FOR TESTING.
    METHODS ordinary_february   FOR TESTING.
    METHODS open_inclusive      FOR TESTING.
    METHODS closed_late         FOR TESTING.
    METHODS closed_before_start FOR TESTING.
    METHODS days_left_counts    FOR TESTING.
    METHODS bad_input           FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_return_window IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_return_window( ).
  ENDMETHOD.

  METHOD expiry_same_month.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->expiry_day( iv_receipt_day = '20260101'
                                iv_window_days = 30 )
      exp = '20260131' ).
  ENDMETHOD.

  METHOD expiry_next_month.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->expiry_day( iv_receipt_day = '20260115'
                                iv_window_days = 20 )
      exp = '20260204' ).
  ENDMETHOD.

  METHOD expiry_next_year.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->expiry_day( iv_receipt_day = '20261231'
                                iv_window_days = 1 )
      exp = '20270101' ).
  ENDMETHOD.

  METHOD expiry_leap_day.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->expiry_day( iv_receipt_day = '20240228'
                                iv_window_days = 1 )
      exp = '20240229' ).
  ENDMETHOD.

  METHOD ordinary_february.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->expiry_day( iv_receipt_day = '20230228'
                                iv_window_days = 1 )
      exp = '20230301' ).
  ENDMETHOD.

  METHOD open_inclusive.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_open( iv_return_day  = '20260115'
                             iv_receipt_day = '20260101'
                             iv_window_days = 30 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_open( iv_return_day  = '20260131'
                             iv_receipt_day = '20260101'
                             iv_window_days = 30 )
      exp = abap_true ).
  ENDMETHOD.

  METHOD closed_late.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_open( iv_return_day  = '20260201'
                             iv_receipt_day = '20260101'
                             iv_window_days = 30 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD closed_before_start.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_open( iv_return_day  = '20251231'
                             iv_receipt_day = '20260101'
                             iv_window_days = 30 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD days_left_counts.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->days_left( iv_return_day  = '20260115'
                               iv_receipt_day = '20260101'
                               iv_window_days = 30 )
      exp = 16 ).
  ENDMETHOD.

  METHOD bad_input.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->expiry_day( iv_receipt_day = '20260101'
                                iv_window_days = -1 )
      exp = '00000000' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_open( iv_return_day  = '20260115'
                             iv_receipt_day = '20260101'
                             iv_window_days = -1 )
      exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->days_left( iv_return_day  = '20260115'
                               iv_receipt_day = '20260101'
                               iv_window_days = -1 )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
