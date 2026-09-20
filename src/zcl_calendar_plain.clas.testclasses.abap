CLASS ltcl_calendar_plain DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    CONSTANTS c_werks TYPE mard-werks VALUE '1000'.

    DATA mo_cut TYPE REF TO zif_work_calendar.

    METHODS setup.

    METHODS days_are_taken_off FOR TESTING RAISING cx_static_check.
    METHODS a_weekend_is_a_day_like_any FOR TESTING RAISING cx_static_check.
    METHODS no_days_is_the_same_day FOR TESTING RAISING cx_static_check.
    METHODS no_date_stays_no_date FOR TESTING RAISING cx_static_check.

ENDCLASS.


CLASS ltcl_calendar_plain IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_calendar_plain( ).
  ENDMETHOD.

  METHOD days_are_taken_off.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->days_before( iv_werks = c_werks
                                 iv_date  = '20260610'
                                 iv_days  = 3 )
      exp = CONV d( '20260607' ) ).

  ENDMETHOD.

  METHOD a_weekend_is_a_day_like_any.

    " the 8th of June 2026 is a Monday, and three plain days before it is the
    " Friday: a plant that has not asked for working days works every day
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->days_before( iv_werks = c_werks
                                 iv_date  = '20260608'
                                 iv_days  = 3 )
      exp = CONV d( '20260605' ) ).

  ENDMETHOD.

  METHOD no_days_is_the_same_day.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->days_before( iv_werks = c_werks
                                 iv_date  = '20260610'
                                 iv_days  = 0 )
      exp = CONV d( '20260610' ) ).

  ENDMETHOD.

  METHOD no_date_stays_no_date.

    cl_abap_unit_assert=>assert_initial(
      act = mo_cut->days_before( iv_werks = c_werks
                                 iv_date  = '00000000'
                                 iv_days  = 3 )
      msg = 'a line with no date is wanted now, and now cannot be brought forward' ).

  ENDMETHOD.

ENDCLASS.
