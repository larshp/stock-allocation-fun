CLASS ltcl_calendar_factory DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    CONSTANTS c_werks TYPE mard-werks VALUE '9101'.
    CONSTANTS c_blank TYPE mard-werks VALUE '9102'.

    DATA mo_cut TYPE REF TO zif_work_calendar.

    METHODS setup.
    METHODS teardown.

    METHODS given_plant
      IMPORTING
        iv_werks TYPE mard-werks
        iv_fabkl TYPE t001w-fabkl.

    METHODS a_week_is_five_days FOR TESTING RAISING cx_static_check.
    METHODS the_weekend_is_skipped FOR TESTING RAISING cx_static_check.
    METHODS counting_from_a_saturday FOR TESTING RAISING cx_static_check.
    METHODS no_days_is_the_same_day FOR TESTING RAISING cx_static_check.
    METHODS the_plant_is_read_once FOR TESTING RAISING cx_static_check.
    METHODS a_plant_without_one_is_said FOR TESTING.

ENDCLASS.


CLASS ltcl_calendar_factory IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_calendar_factory( ).
  ENDMETHOD.

  METHOD teardown.

    DELETE FROM t001w WHERE werks = @c_werks OR werks = @c_blank.
    cl_abap_unit_assert=>assert_true( xsdbool( sy-subrc = 0 OR sy-subrc = 4 ) ).

  ENDMETHOD.

  METHOD given_plant.

    DATA lt_row TYPE STANDARD TABLE OF t001w WITH EMPTY KEY.

    lt_row = VALUE #(
      ( mandt = sy-mandt
        werks = iv_werks
        name1 = 'Test plant'
        fabkl = iv_fabkl ) ).

    INSERT t001w FROM TABLE @lt_row.
    cl_abap_unit_assert=>assert_subrc( ).

  ENDMETHOD.

  METHOD a_week_is_five_days.

    given_plant( iv_werks = c_werks
                 iv_fabkl = '01' ).

    " Wednesday the 10th of June 2026, two working days back, is the Monday
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->days_before( iv_werks = c_werks
                                 iv_date  = '20260610'
                                 iv_days  = 2 )
      exp = CONV d( '20260608' ) ).

  ENDMETHOD.

  METHOD the_weekend_is_skipped.

    given_plant( iv_werks = c_werks
                 iv_fabkl = '01' ).

    " three working days before the Wednesday is the Friday before, not the
    " Sunday: a plant that does not pick at the weekend has to start earlier
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->days_before( iv_werks = c_werks
                                 iv_date  = '20260610'
                                 iv_days  = 3 )
      exp = CONV d( '20260605' ) ).

  ENDMETHOD.

  METHOD counting_from_a_saturday.

    given_plant( iv_werks = c_werks
                 iv_fabkl = '01' ).

    " goods wanted on the Saturday have to be ready on the Friday, so one
    " working day before that is the Thursday
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->days_before( iv_werks = c_werks
                                 iv_date  = '20260613'
                                 iv_days  = 1 )
      exp = CONV d( '20260611' ) ).

  ENDMETHOD.

  METHOD no_days_is_the_same_day.

    given_plant( iv_werks = c_werks
                 iv_fabkl = '01' ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->days_before( iv_werks = c_werks
                                 iv_date  = '20260613'
                                 iv_days  = 0 )
      exp = CONV d( '20260613' )
      msg = 'no shipping time is no question for the calendar' ).

  ENDMETHOD.

  METHOD the_plant_is_read_once.

    given_plant( iv_werks = c_werks
                 iv_fabkl = '01' ).

    mo_cut->days_before( iv_werks = c_werks
                         iv_date  = '20260610'
                         iv_days  = 1 ).

    DELETE FROM t001w WHERE werks = @c_werks.
    cl_abap_unit_assert=>assert_subrc( ).

    " a run asks per material, and which calendar a plant keeps does not
    " change while it runs
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->days_before( iv_werks = c_werks
                                 iv_date  = '20260610'
                                 iv_days  = 1 )
      exp = CONV d( '20260609' ) ).

  ENDMETHOD.

  METHOD a_plant_without_one_is_said.

    given_plant( iv_werks = c_blank
                 iv_fabkl = '' ).

    TRY.
        mo_cut->days_before( iv_werks = c_blank
                             iv_date  = '20260610'
                             iv_days  = 1 ).
        cl_abap_unit_assert=>fail( 'guessing at a week for a plant that has not said one is a promise it never made' ).
      CATCH zcx_allocation.
        RETURN.
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
