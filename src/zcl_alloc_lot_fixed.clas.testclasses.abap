CLASS ltcl_alloc_lot_fixed DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_lot_fixed.

    METHODS setup.

    METHODS exact_multiple     FOR TESTING.
    METHODS rounds_up          FOR TESTING.
    METHODS zero_requirement   FOR TESTING.
    METHODS no_lot_size        FOR TESTING.
    METHODS negative_demand    FOR TESTING.
    METHODS counts_lots        FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_lot_fixed IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_lot_fixed( ).
  ENDMETHOD.

  METHOD exact_multiple.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->size( iv_requirement = 10 iv_lot_size = 5 )
      exp = 10 ).
  ENDMETHOD.

  METHOD rounds_up.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->size( iv_requirement = 7 iv_lot_size = 5 )
      exp = 10 ).
  ENDMETHOD.

  METHOD zero_requirement.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->size( iv_requirement = 0 iv_lot_size = 5 )
      exp = 0 ).
  ENDMETHOD.

  METHOD no_lot_size.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->size( iv_requirement = 7 iv_lot_size = 0 )
      exp = 7 ).
  ENDMETHOD.

  METHOD negative_demand.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->size( iv_requirement = -3 iv_lot_size = 5 )
      exp = 0 ).
  ENDMETHOD.

  METHOD counts_lots.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->lots_of( iv_requirement = 7 iv_lot_size = 5 )
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->lots_of( iv_requirement = 10 iv_lot_size = 5 )
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->lots_of( iv_requirement = 0 iv_lot_size = 5 )
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->lots_of( iv_requirement = 10 iv_lot_size = 0 )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
