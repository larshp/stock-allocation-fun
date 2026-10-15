CLASS ltcl_alloc_wip_overhead DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_wip_overhead.

    METHODS setup.

    METHODS computes_overhead FOR TESTING.
    METHODS computes_absorbed FOR TESTING.
    METHODS reads_balance     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_wip_overhead IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_wip_overhead( ).
  ENDMETHOD.

  METHOD computes_overhead.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->overhead( iv_base = 1000 iv_percent = 8 )
      exp = 80 ).
  ENDMETHOD.

  METHOD computes_absorbed.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->absorbed( iv_planned = 1000 iv_percent = 90 )
      exp = 900 ).
  ENDMETHOD.

  METHOD reads_balance.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->balance( iv_planned = 1000 iv_absorbed = 900 )
      exp = 100 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->balance( iv_planned = 1000 iv_absorbed = 1200 )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
