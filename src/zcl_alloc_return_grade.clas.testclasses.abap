CLASS ltcl_alloc_return_grade DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_return_grade.

    METHODS setup.

    METHODS bands        FOR TESTING.
    METHODS boundaries   FOR TESTING.
    METHODS scores       FOR TESTING.
    METHODS unknown_grade FOR TESTING.
    METHODS sellable     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_return_grade IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_return_grade( ).
  ENDMETHOD.

  METHOD bands.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->grade( 95 ) exp = 'A' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->grade( 80 ) exp = 'B' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->grade( 65 ) exp = 'C' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->grade( 45 ) exp = 'D' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->grade( 10 ) exp = 'F' ).
  ENDMETHOD.

  METHOD boundaries.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->grade( 90 ) exp = 'A' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->grade( 89 ) exp = 'B' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->grade( 75 ) exp = 'B' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->grade( 60 ) exp = 'C' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->grade( 40 ) exp = 'D' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->grade( 39 ) exp = 'F' ).
  ENDMETHOD.

  METHOD scores.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->score( 'A' ) exp = 90 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->score( 'F' ) exp = 0 ).
  ENDMETHOD.

  METHOD unknown_grade.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->score( 'Z' ) exp = -1 ).
  ENDMETHOD.

  METHOD sellable.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_sellable( 60 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_sellable( 59 ) exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
