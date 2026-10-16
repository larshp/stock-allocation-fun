CLASS ltcl_alloc_rout_capacity DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_rout_capacity.

    METHODS setup.

    METHODS computes_capacity FOR TESTING.
    METHODS over_rule         FOR TESTING.
    METHODS reads_spare       FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_rout_capacity IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_rout_capacity( ).
  ENDMETHOD.

  METHOD computes_capacity.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->capacity( iv_available = 300 iv_unit_time = 3 )
      exp = 100 ).
  ENDMETHOD.

  METHOD over_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_over( iv_required = 120 iv_capacity = 100 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_over( iv_required = 80 iv_capacity = 100 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD reads_spare.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->spare( iv_capacity = 100 iv_required = 80 )
      exp = 20 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->spare( iv_capacity = 100 iv_required = 120 )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
