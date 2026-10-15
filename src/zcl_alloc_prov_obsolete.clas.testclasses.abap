CLASS ltcl_alloc_prov_obsolete DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_prov_obsolete.

    METHODS setup.

    METHODS computes_provision FOR TESTING.
    METHODS reads_percent      FOR TESTING.
    METHODS provisioned_rule   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_prov_obsolete IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_prov_obsolete( ).
  ENDMETHOD.

  METHOD computes_provision.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->provision( iv_value = 1000 iv_percent = 30 )
      exp = 300 ).
  ENDMETHOD.

  METHOD reads_percent.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->percent( iv_value = 1000 iv_provision = 300 )
      exp = 30 ).
  ENDMETHOD.

  METHOD provisioned_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_provisioned( 30 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_provisioned( 0 ) exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
