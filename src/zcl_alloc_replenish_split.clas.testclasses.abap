CLASS ltcl_alloc_replenish_split DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_replenish_split.

    METHODS setup.

    METHODS splits_batches  FOR TESTING.
    METHODS counts_batches  FOR TESTING.
    METHODS covers_rule     FOR TESTING.
    METHODS guards_input    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_replenish_split IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_replenish_split( ).
  ENDMETHOD.

  METHOD splits_batches.
    DATA lt_batches TYPE zcl_alloc_replenish_split=>ty_values_tt.

    lt_batches = mo_cut->split( iv_total = 10 iv_batch_size = 4 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_batches ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lt_batches[ 1 ] exp = 4 ).
    cl_abap_unit_assert=>assert_equals( act = lt_batches[ 2 ] exp = 4 ).
    cl_abap_unit_assert=>assert_equals( act = lt_batches[ 3 ] exp = 2 ).
  ENDMETHOD.

  METHOD counts_batches.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->batch_count( iv_total = 10 iv_batch_size = 4 )
      exp = 3 ).
  ENDMETHOD.

  METHOD covers_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->covers_total( iv_total = 12 iv_batch_size = 4 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->covers_total( iv_total = 10 iv_batch_size = 4 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD guards_input.
    DATA lt_batches TYPE zcl_alloc_replenish_split=>ty_values_tt.

    lt_batches = mo_cut->split( iv_total = 10 iv_batch_size = 0 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_batches ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->batch_count( iv_total = 10 iv_batch_size = 0 )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
