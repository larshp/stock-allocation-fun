CLASS ltcl_alloc_area_model DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_area_model.

    METHODS setup.

    METHODS empty_area   FOR TESTING.
    METHODS sums_bins    FOR TESTING.
    METHODS free_space   FOR TESTING.
    METHODS free_floor   FOR TESTING.
    METHODS counts_bins  FOR TESTING.
    METHODS ignores_noise FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_area_model IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_area_model( ).
  ENDMETHOD.

  METHOD empty_area.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total_capacity( ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->free_space( ) exp = 0 ).
  ENDMETHOD.

  METHOD sums_bins.
    mo_cut->add_bin( iv_capacity = 100 iv_used = 40 ).
    mo_cut->add_bin( iv_capacity = 50 iv_used = 10 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total_capacity( ) exp = 150 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->total_used( ) exp = 50 ).
  ENDMETHOD.

  METHOD free_space.
    mo_cut->add_bin( iv_capacity = 100 iv_used = 40 ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->free_space( ) exp = 60 ).
  ENDMETHOD.

  METHOD free_floor.
    mo_cut->add_bin( iv_capacity = 100 iv_used = 140 ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->free_space( ) exp = 0 ).
  ENDMETHOD.

  METHOD counts_bins.
    mo_cut->add_bin( iv_capacity = 100 iv_used = 40 ).
    mo_cut->add_bin( iv_capacity = 0 iv_used = 0 ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->bin_count( ) exp = 2 ).
  ENDMETHOD.

  METHOD ignores_noise.
    mo_cut->add_bin( iv_capacity = -5 iv_used = -3 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total_capacity( ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->total_used( ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
