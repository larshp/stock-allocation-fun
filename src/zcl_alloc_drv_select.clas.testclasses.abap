CLASS ltcl_alloc_drv_select DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_drv_select.

    METHODS setup.

    METHODS chooses_driver FOR TESTING.
    METHODS volume_rule    FOR TESTING.
    METHODS reads_reason   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_drv_select IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_drv_select( ).
  ENDMETHOD.

  METHOD chooses_driver.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->choose( iv_volume = 1000 iv_value = 500 )
      exp = 'VOLUME' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->choose( iv_volume = 500 iv_value = 1000 )
      exp = 'VALUE' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->choose( iv_volume = 0 iv_value = 0 )
      exp = 'NONE' ).
  ENDMETHOD.

  METHOD volume_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_volume( 'VOLUME' ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_volume( 'VALUE' ) exp = abap_false ).
  ENDMETHOD.

  METHOD reads_reason.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->reason( 'VOLUME' ) exp = 'usage based' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->reason( 'VALUE' ) exp = 'value based' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->reason( 'NONE' ) exp = 'unassigned' ).
  ENDMETHOD.

ENDCLASS.
