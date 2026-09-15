CLASS ltcl_alloc_calendar DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_calendar.

    METHODS setup.

    METHODS input
      IMPORTING
        iv_start      TYPE d
        iv_days       TYPE i
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_calendar=>ty_input.

    METHODS weekend_flags   FOR TESTING.
    METHODS one_working_day FOR TESTING.
    METHODS three_days      FOR TESTING.
    METHODS zero_days       FOR TESTING.
    METHODS from_saturday   FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_calendar IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_calendar( ).
  ENDMETHOD.

  METHOD input.
    rs_row-start_date = iv_start.
    rs_row-days = iv_days.
  ENDMETHOD.

  METHOD weekend_flags.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_weekend( '20260912' ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_weekend( '20260913' ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_weekend( '20260914' ) exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_weekend( '20260911' ) exp = abap_false ).
  ENDMETHOD.

  METHOD one_working_day.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->add_working_days( input( iv_start = '20260911'
                                             iv_days  = 1 ) )
      exp = '20260914' ).
  ENDMETHOD.

  METHOD three_days.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->add_working_days( input( iv_start = '20260911'
                                             iv_days  = 3 ) )
      exp = '20260916' ).
  ENDMETHOD.

  METHOD zero_days.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->add_working_days( input( iv_start = '20260911'
                                             iv_days  = 0 ) )
      exp = '20260911' ).
  ENDMETHOD.

  METHOD from_saturday.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->add_working_days( input( iv_start = '20260912'
                                             iv_days  = 1 ) )
      exp = '20260914' ).
  ENDMETHOD.

ENDCLASS.
