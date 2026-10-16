CLASS ltcl_alloc_inspect_lot DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_inspect_lot.

    METHODS setup.

    METHODS empty_lot       FOR TESTING.
    METHODS tracks_samples  FOR TESTING.
    METHODS remaining_drops FOR TESTING.
    METHODS ignores_noise   FOR TESTING.
    METHODS clear_resets    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_inspect_lot IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_inspect_lot( ).
  ENDMETHOD.

  METHOD empty_lot.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->lot_size( ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->remaining( ) exp = 0 ).
  ENDMETHOD.

  METHOD tracks_samples.
    mo_cut->set_lot_size( iv_lot_size = 1000 ).
    mo_cut->add_sample( iv_inspected = 50 iv_defects = 2 ).
    mo_cut->add_sample( iv_inspected = 30 iv_defects = 1 ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->inspected( ) exp = 80 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->defects( ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->remaining( ) exp = 920 ).
  ENDMETHOD.

  METHOD remaining_drops.
    mo_cut->set_lot_size( iv_lot_size = 100 ).
    mo_cut->add_sample( iv_inspected = 120 iv_defects = 0 ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->remaining( ) exp = 0 ).
  ENDMETHOD.

  METHOD ignores_noise.
    mo_cut->set_lot_size( iv_lot_size = -5 ).
    mo_cut->add_sample( iv_inspected = -10 iv_defects = -3 ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->lot_size( ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->inspected( ) exp = 0 ).
  ENDMETHOD.

  METHOD clear_resets.
    mo_cut->set_lot_size( iv_lot_size = 100 ).
    mo_cut->add_sample( iv_inspected = 10 iv_defects = 1 ).
    mo_cut->clear( ).

    cl_abap_unit_assert=>assert_equals( act = mo_cut->lot_size( ) exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->defects( ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
