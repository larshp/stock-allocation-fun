CLASS ltcl_alloc_drv_trend DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_drv_trend.

    METHODS setup.

    METHODS reads_direction FOR TESTING.
    METHODS rising_rule     FOR TESTING.
    METHODS computes_delta  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_drv_trend IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_drv_trend( ).
  ENDMETHOD.

  METHOD reads_direction.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->direction( iv_previous = 1000 iv_current = 1200 )
      exp = 'UP' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->direction( iv_previous = 1200 iv_current = 1000 )
      exp = 'DOWN' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->direction( iv_previous = 1000 iv_current = 1000 )
      exp = 'FLAT' ).
  ENDMETHOD.

  METHOD rising_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_rising( iv_previous = 1000 iv_current = 1200 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_rising( iv_previous = 1200 iv_current = 1000 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD computes_delta.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->delta( iv_previous = 1000 iv_current = 1200 )
      exp = 200 ).
  ENDMETHOD.

ENDCLASS.
