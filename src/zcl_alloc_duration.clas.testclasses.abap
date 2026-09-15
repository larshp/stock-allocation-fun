CLASS ltcl_alloc_duration DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_duration.

    METHODS setup.

    METHODS one_hour          FOR TESTING.
    METHODS zero_seconds      FOR TESTING.
    METHODS under_a_minute    FOR TESTING.
    METHODS last_second_day   FOR TESTING.
    METHODS seconds_roundtrip FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_duration IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_duration( ).
  ENDMETHOD.

  METHOD one_hour.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->to_text( 3661 )
                                        exp = '1:01:01' ).
  ENDMETHOD.

  METHOD zero_seconds.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->to_text( 0 )
                                        exp = '0:00:00' ).
  ENDMETHOD.

  METHOD under_a_minute.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->to_text( 59 )
                                        exp = '0:00:59' ).
  ENDMETHOD.

  METHOD last_second_day.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->to_text( 86399 )
                                        exp = '23:59:59' ).
  ENDMETHOD.

  METHOD seconds_roundtrip.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->to_seconds( iv_hours   = 1
                                iv_minutes = 1
                                iv_seconds = 1 )
      exp = 3661 ).
  ENDMETHOD.

ENDCLASS.
