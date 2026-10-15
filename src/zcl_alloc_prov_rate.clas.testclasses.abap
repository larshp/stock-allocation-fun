CLASS ltcl_alloc_prov_rate DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_prov_rate.

    METHODS setup.

    METHODS reads_rate        FOR TESTING.
    METHODS computes_provision FOR TESTING.
    METHODS high_rule         FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_prov_rate IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_prov_rate( ).
  ENDMETHOD.

  METHOD reads_rate.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->rate( iv_provision = 300 iv_value = 1000 ) exp = 30 ).
  ENDMETHOD.

  METHOD computes_provision.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->provision( iv_value = 1000 iv_rate = 30 ) exp = 300 ).
  ENDMETHOD.

  METHOD high_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_high( iv_rate = 30 iv_threshold = 20 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_high( iv_rate = 10 iv_threshold = 20 )
      exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
