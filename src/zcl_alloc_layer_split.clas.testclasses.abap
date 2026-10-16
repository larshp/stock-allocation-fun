CLASS ltcl_alloc_layer_split DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_layer_split.

    METHODS setup.

    METHODS splits_quantity FOR TESTING.
    METHODS counts_parts    FOR TESTING.
    METHODS sums_parts      FOR TESTING.
    METHODS guards_parts    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_layer_split IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_layer_split( ).
  ENDMETHOD.

  METHOD splits_quantity.
    DATA lt_parts TYPE zcl_alloc_layer_split=>ty_values_tt.

    lt_parts = mo_cut->split( iv_quantity = 100 iv_parts = 3 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_parts ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lt_parts[ 1 ] exp = 34 ).
    cl_abap_unit_assert=>assert_equals( act = lt_parts[ 2 ] exp = 33 ).
    cl_abap_unit_assert=>assert_equals( act = lt_parts[ 3 ] exp = 33 ).
  ENDMETHOD.

  METHOD counts_parts.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->parts( iv_quantity = 100 iv_part_size = 30 ) exp = 4 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->parts( iv_quantity = 90 iv_part_size = 30 ) exp = 3 ).
  ENDMETHOD.

  METHOD sums_parts.
    DATA lt_parts TYPE zcl_alloc_layer_split=>ty_values_tt.

    lt_parts = mo_cut->split( iv_quantity = 100 iv_parts = 3 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total_qty( lt_parts ) exp = 100 ).
  ENDMETHOD.

  METHOD guards_parts.
    cl_abap_unit_assert=>assert_equals(
      act = lines( mo_cut->split( iv_quantity = 100 iv_parts = 0 ) ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->parts( iv_quantity = 100 iv_part_size = 0 ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
