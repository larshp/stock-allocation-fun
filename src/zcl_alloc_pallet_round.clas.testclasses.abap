CLASS ltcl_alloc_pallet_round DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_pallet_round.

    METHODS setup.

    METHODS counts_pallets FOR TESTING.
    METHODS remainder      FOR TESTING.
    METHODS full_rule      FOR TESTING.
    METHODS guards_input   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_pallet_round IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_pallet_round( ).
  ENDMETHOD.

  METHOD counts_pallets.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->pallets( iv_quantity = 13 iv_per_pallet = 5 )
      exp = 3 ).
  ENDMETHOD.

  METHOD remainder.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->remainder( iv_quantity = 13 iv_per_pallet = 5 )
      exp = 3 ).
  ENDMETHOD.

  METHOD full_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_full( iv_quantity = 15 iv_per_pallet = 5 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_full( iv_quantity = 13 iv_per_pallet = 5 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD guards_input.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->pallets( iv_quantity = 13 iv_per_pallet = 0 )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
