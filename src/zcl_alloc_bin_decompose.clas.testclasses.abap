CLASS ltcl_alloc_bin_decompose DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_bin_decompose.

    METHODS setup.

    METHODS splits_parts   FOR TESTING.
    METHODS drops_empty    FOR TESTING.
    METHODS counts_parts   FOR TESTING.
    METHODS key_from_parts FOR TESTING.
    METHODS short_key      FOR TESTING.
    METHODS empty_id       FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_bin_decompose IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_bin_decompose( ).
  ENDMETHOD.

  METHOD splits_parts.
    DATA lt_parts TYPE zcl_alloc_bin_decompose=>ty_parts_tt.

    lt_parts = zcl_alloc_bin_decompose=>split( 'A-01-03-02' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_parts ) exp = 4 ).
    cl_abap_unit_assert=>assert_equals( act = lt_parts[ 1 ] exp = 'A' ).
    cl_abap_unit_assert=>assert_equals( act = lt_parts[ 4 ] exp = '02' ).
  ENDMETHOD.

  METHOD drops_empty.
    DATA lt_parts TYPE zcl_alloc_bin_decompose=>ty_parts_tt.

    lt_parts = zcl_alloc_bin_decompose=>split( 'A--B' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_parts ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_parts[ 1 ] exp = 'A' ).
    cl_abap_unit_assert=>assert_equals( act = lt_parts[ 2 ] exp = 'B' ).
  ENDMETHOD.

  METHOD counts_parts.
    cl_abap_unit_assert=>assert_equals(
      act = zcl_alloc_bin_decompose=>part_count( 'B-12-9' ) exp = 3 ).
  ENDMETHOD.

  METHOD key_from_parts.
    DATA ls_key TYPE zcl_alloc_bin_decompose=>ty_key.

    ls_key = zcl_alloc_bin_decompose=>decompose( 'B-12-9-04' ).

    cl_abap_unit_assert=>assert_equals( act = ls_key-block exp = 'B' ).
    cl_abap_unit_assert=>assert_equals( act = ls_key-aisle exp = '12' ).
    cl_abap_unit_assert=>assert_equals( act = ls_key-rack exp = '9' ).
    cl_abap_unit_assert=>assert_equals( act = ls_key-level exp = '04' ).
  ENDMETHOD.

  METHOD short_key.
    DATA ls_key TYPE zcl_alloc_bin_decompose=>ty_key.

    ls_key = zcl_alloc_bin_decompose=>decompose( 'B-12' ).

    cl_abap_unit_assert=>assert_equals( act = ls_key-block exp = 'B' ).
    cl_abap_unit_assert=>assert_equals( act = ls_key-aisle exp = '12' ).
    cl_abap_unit_assert=>assert_equals( act = ls_key-rack exp = '' ).
    cl_abap_unit_assert=>assert_equals( act = ls_key-level exp = '' ).
  ENDMETHOD.

  METHOD empty_id.
    DATA lt_parts TYPE zcl_alloc_bin_decompose=>ty_parts_tt.

    lt_parts = zcl_alloc_bin_decompose=>split( '' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_parts ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = zcl_alloc_bin_decompose=>part_count( '' ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
