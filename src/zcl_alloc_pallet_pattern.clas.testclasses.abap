CLASS ltcl_alloc_pallet_pattern DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_pallet_pattern.

    METHODS setup.

    METHODS per_pallet_reads FOR TESTING.
    METHODS per_pallet_zero  FOR TESTING.
    METHODS layers_round_up  FOR TESTING.
    METHODS layers_exact     FOR TESTING.
    METHODS pallets_one      FOR TESTING.
    METHODS pallets_partial  FOR TESTING.
    METHODS pallets_zero_fit FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_pallet_pattern IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_pallet_pattern( ).
  ENDMETHOD.

  METHOD per_pallet_reads.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->per_pallet( iv_per_layer = 6 iv_layers = 4 )
      exp = 24 ).
  ENDMETHOD.

  METHOD per_pallet_zero.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->per_pallet( iv_per_layer = 0 iv_layers = 4 )
      exp = 0 ).
  ENDMETHOD.

  METHOD layers_round_up.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->layers_for( iv_quantity = 13 iv_per_layer = 6 )
      exp = 3 ).
  ENDMETHOD.

  METHOD layers_exact.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->layers_for( iv_quantity = 12 iv_per_layer = 6 )
      exp = 2 ).
  ENDMETHOD.

  METHOD pallets_one.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->pallets_for( iv_quantity = 20 iv_per_layer = 6
                                 iv_layers = 4 )
      exp = 1 ).
  ENDMETHOD.

  METHOD pallets_partial.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->pallets_for( iv_quantity = 25 iv_per_layer = 6
                                 iv_layers = 4 )
      exp = 2 ).
  ENDMETHOD.

  METHOD pallets_zero_fit.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->pallets_for( iv_quantity = 25 iv_per_layer = 0
                                 iv_layers = 4 )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
