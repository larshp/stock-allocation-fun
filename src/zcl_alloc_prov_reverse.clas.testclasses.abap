CLASS ltcl_alloc_prov_reverse DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_prov_reverse.

    METHODS setup.

    METHODS computes_reversal FOR TESTING.
    METHODS leaves_remaining  FOR TESTING.
    METHODS full_rule         FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_prov_reverse IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_prov_reverse( ).
  ENDMETHOD.

  METHOD computes_reversal.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->reverse( iv_provision = 300 iv_reversal_percent = 50 )
      exp = 150 ).
  ENDMETHOD.

  METHOD leaves_remaining.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->amount( iv_provision = 300 iv_reversed = 150 )
      exp = 150 ).
  ENDMETHOD.

  METHOD full_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_full( iv_reversed = 300 iv_provision = 300 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_full( iv_reversed = 150 iv_provision = 300 )
      exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
