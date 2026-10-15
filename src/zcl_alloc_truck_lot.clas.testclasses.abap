CLASS ltcl_alloc_truck_lot DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_truck_lot.

    METHODS setup.

    METHODS counts_lots     FOR TESTING.
    METHODS computes_fill   FOR TESTING.
    METHODS efficient_rule  FOR TESTING.
    METHODS guards_input    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_truck_lot IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_truck_lot( ).
  ENDMETHOD.

  METHOD counts_lots.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->lots( iv_quantity = 13 iv_lot_size = 5 )
      exp = 3 ).
  ENDMETHOD.

  METHOD computes_fill.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->fill_percent( iv_quantity = 13 iv_lot_size = 5 )
      exp = 86 ).
  ENDMETHOD.

  METHOD efficient_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_efficient( iv_fill_percent = 86 iv_threshold = 80 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_efficient( iv_fill_percent = 70 iv_threshold = 80 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD guards_input.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->fill_percent( iv_quantity = 13 iv_lot_size = 0 )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
