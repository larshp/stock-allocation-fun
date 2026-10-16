CLASS ltcl_alloc_drv_capacity DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_drv_capacity.

    METHODS setup.

    METHODS reads_capacity FOR TESTING.
    METHODS over_rule      FOR TESTING.
    METHODS computes_spare FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_drv_capacity IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_drv_capacity( ).
  ENDMETHOD.

  METHOD reads_capacity.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->capacity( iv_used = 80 iv_available = 100 )
      exp = 80 ).
  ENDMETHOD.

  METHOD over_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_over( iv_used = 120 iv_available = 100 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_over( iv_used = 80 iv_available = 100 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD computes_spare.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->spare( iv_used = 80 iv_available = 100 )
      exp = 20 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->spare( iv_used = 120 iv_available = 100 )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
