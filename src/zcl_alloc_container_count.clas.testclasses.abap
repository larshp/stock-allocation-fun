CLASS ltcl_alloc_container_count DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_container_count.

    METHODS setup.

    METHODS rounds_up       FOR TESTING.
    METHODS exact_count     FOR TESTING.
    METHODS zero_pieces     FOR TESTING.
    METHODS zero_per_box    FOR TESTING.
    METHODS some_open       FOR TESTING.
    METHODS all_returned    FOR TESTING.
    METHODS nothing_issued  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_container_count IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_container_count( ).
  ENDMETHOD.

  METHOD rounds_up.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->needed( iv_pieces = 11 iv_per_container = 5 )
      exp = 3 ).
  ENDMETHOD.

  METHOD exact_count.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->needed( iv_pieces = 10 iv_per_container = 5 )
      exp = 2 ).
  ENDMETHOD.

  METHOD zero_pieces.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->needed( iv_pieces = 0 iv_per_container = 5 )
      exp = 0 ).
  ENDMETHOD.

  METHOD zero_per_box.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->needed( iv_pieces = 10 iv_per_container = 0 )
      exp = 0 ).
  ENDMETHOD.

  METHOD some_open.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->outstanding( iv_out = 10 iv_in = 4 ) exp = 6 ).
  ENDMETHOD.

  METHOD all_returned.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->outstanding( iv_out = 4 iv_in = 4 ) exp = 0 ).
  ENDMETHOD.

  METHOD nothing_issued.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->outstanding( iv_out = 0 iv_in = 4 ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
