CLASS ltcl_alloc_grade DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_grade.

    METHODS setup.

    METHODS input
      IMPORTING
        iv_coverage   TYPE i
        iv_shortage   TYPE abap_bool
      RETURNING
        VALUE(rs_row) TYPE zcl_alloc_grade=>ty_input.

    METHODS perfect_is_a      FOR TESTING.
    METHODS shortage_blocks_a FOR TESTING.
    METHODS high_coverage_b   FOR TESTING.
    METHODS good_coverage_c   FOR TESTING.
    METHODS fair_coverage_d   FOR TESTING.
    METHODS weak_coverage_e   FOR TESTING.
    METHODS poor_coverage_f   FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_grade IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_grade( ).
  ENDMETHOD.

  METHOD input.
    rs_row-coverage_pct = iv_coverage.
    rs_row-has_shortage = iv_shortage.
  ENDMETHOD.

  METHOD perfect_is_a.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->grade( input( iv_coverage = 100
                                  iv_shortage = abap_false ) )
      exp = 'A' ).
  ENDMETHOD.

  METHOD shortage_blocks_a.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->grade( input( iv_coverage = 100
                                  iv_shortage = abap_true ) )
      exp = 'B' ).
  ENDMETHOD.

  METHOD high_coverage_b.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->grade( input( iv_coverage = 95
                                  iv_shortage = abap_true ) )
      exp = 'B' ).
  ENDMETHOD.

  METHOD good_coverage_c.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->grade( input( iv_coverage = 80
                                  iv_shortage = abap_true ) )
      exp = 'C' ).
  ENDMETHOD.

  METHOD fair_coverage_d.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->grade( input( iv_coverage = 60
                                  iv_shortage = abap_true ) )
      exp = 'D' ).
  ENDMETHOD.

  METHOD weak_coverage_e.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->grade( input( iv_coverage = 40
                                  iv_shortage = abap_true ) )
      exp = 'E' ).
  ENDMETHOD.

  METHOD poor_coverage_f.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->grade( input( iv_coverage = 10
                                  iv_shortage = abap_true ) )
      exp = 'F' ).
  ENDMETHOD.

ENDCLASS.
