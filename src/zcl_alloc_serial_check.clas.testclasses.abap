CLASS ltcl_alloc_serial_check DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_serial_check.
    DATA mt_ser TYPE zcl_alloc_serial_check=>ty_int_tt.

    METHODS setup.

    METHODS inside_range   FOR TESTING.
    METHODS at_bounds      FOR TESTING.
    METHODS outside_range  FOR TESTING.
    METHODS unique_flag    FOR TESTING.
    METHODS finds_dupes    FOR TESTING.
    METHODS bad_range      FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_serial_check IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_serial_check( ).
  ENDMETHOD.

  METHOD inside_range.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->in_range( iv_serial = 5 iv_from = 1 iv_to = 10 )
      exp = abap_true ).
  ENDMETHOD.

  METHOD at_bounds.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->in_range( iv_serial = 1 iv_from = 1 iv_to = 10 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->in_range( iv_serial = 10 iv_from = 1 iv_to = 10 )
      exp = abap_true ).
  ENDMETHOD.

  METHOD outside_range.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->in_range( iv_serial = 11 iv_from = 1 iv_to = 10 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD bad_range.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->in_range( iv_serial = 5 iv_from = 10 iv_to = 1 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD unique_flag.
    APPEND 1 TO mt_ser.
    APPEND 2 TO mt_ser.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_unique( mt_ser ) exp = abap_true ).
  ENDMETHOD.

  METHOD finds_dupes.
    DATA lt_dupes TYPE zcl_alloc_serial_check=>ty_int_tt.

    APPEND 1 TO mt_ser.
    APPEND 2 TO mt_ser.
    APPEND 1 TO mt_ser.
    APPEND 2 TO mt_ser.
    APPEND 2 TO mt_ser.

    lt_dupes = mo_cut->duplicates( mt_ser ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_dupes ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lt_dupes[ 1 ] exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_unique( mt_ser ) exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
