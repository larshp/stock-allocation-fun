CLASS ltcl_alloc_clock DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.

    METHODS a_zone_is_always_answered FOR TESTING.
    METHODS a_day_becomes_a_stamp_and_back FOR TESTING.
    METHODS midnight_is_the_same_day FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_clock IMPLEMENTATION.

  METHOD a_zone_is_always_answered.

    " a system that has not said where it is still has to count days
    cl_abap_unit_assert=>assert_not_initial( zcl_alloc_clock=>zone( ) ).

  ENDMETHOD.

  METHOD a_day_becomes_a_stamp_and_back.

    DATA(lv_stamp) = zcl_alloc_clock=>stamp_of(
      iv_date = '20260610'
      iv_time = '120000' ).

    cl_abap_unit_assert=>assert_equals(
      act = zcl_alloc_clock=>date_of( lv_stamp )
      exp = CONV d( '20260610' )
      msg = 'a day written down and read back has to be the same day' ).

  ENDMETHOD.

  METHOD midnight_is_the_same_day.

    " the boundary itself is the case that goes wrong when the zones disagree
    DATA(lv_stamp) = zcl_alloc_clock=>stamp_of( '20260610' ).

    cl_abap_unit_assert=>assert_equals(
      act = zcl_alloc_clock=>date_of( lv_stamp )
      exp = CONV d( '20260610' ) ).

  ENDMETHOD.

ENDCLASS.
