CLASS ltcl_alloc_hu_pack DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_hu_pack.

    METHODS setup.

    METHODS full_and_partial FOR TESTING.
    METHODS exact_fit        FOR TESTING.
    METHODS zero_quantity    FOR TESTING.
    METHODS zero_capacity    FOR TESTING.
    METHODS single_unit      FOR TESTING.
    METHODS unit_count_reads FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_hu_pack IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_hu_pack( ).
  ENDMETHOD.

  METHOD full_and_partial.
    DATA lt_units TYPE zcl_alloc_hu_pack=>ty_unit_tt.

    lt_units = mo_cut->pack( iv_quantity = 10 iv_capacity = 4 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_units ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lt_units[ 1 ]-quantity exp = 4 ).
    cl_abap_unit_assert=>assert_equals( act = lt_units[ 3 ]-quantity exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_units[ 3 ]-unit_no exp = 3 ).
  ENDMETHOD.

  METHOD exact_fit.
    DATA lt_units TYPE zcl_alloc_hu_pack=>ty_unit_tt.

    lt_units = mo_cut->pack( iv_quantity = 8 iv_capacity = 4 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_units ) exp = 2 ).
  ENDMETHOD.

  METHOD zero_quantity.
    DATA lt_units TYPE zcl_alloc_hu_pack=>ty_unit_tt.

    lt_units = mo_cut->pack( iv_quantity = 0 iv_capacity = 4 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_units ) exp = 0 ).
  ENDMETHOD.

  METHOD zero_capacity.
    DATA lt_units TYPE zcl_alloc_hu_pack=>ty_unit_tt.

    lt_units = mo_cut->pack( iv_quantity = 7 iv_capacity = 0 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_units ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_units[ 1 ]-quantity exp = 7 ).
  ENDMETHOD.

  METHOD single_unit.
    DATA lt_units TYPE zcl_alloc_hu_pack=>ty_unit_tt.

    lt_units = mo_cut->pack( iv_quantity = 3 iv_capacity = 10 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_units ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_units[ 1 ]-quantity exp = 3 ).
  ENDMETHOD.

  METHOD unit_count_reads.
    DATA lt_units TYPE zcl_alloc_hu_pack=>ty_unit_tt.

    lt_units = mo_cut->pack( iv_quantity = 10 iv_capacity = 4 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->unit_count( it_units = lt_units ) exp = 3 ).
  ENDMETHOD.

ENDCLASS.
