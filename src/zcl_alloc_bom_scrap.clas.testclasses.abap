CLASS ltcl_alloc_bom_scrap DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_bom_scrap.

    METHODS setup.

    METHODS computes_scrap FOR TESTING.
    METHODS scrapped_rule  FOR TESTING.
    METHODS computes_gross FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_bom_scrap IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_bom_scrap( ).
  ENDMETHOD.

  METHOD computes_scrap.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->scrap_qty( iv_gross = 100 iv_scrap_percent = 10 )
      exp = 10 ).
  ENDMETHOD.

  METHOD scrapped_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_scrapped( 10 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_scrapped( 0 ) exp = abap_false ).
  ENDMETHOD.

  METHOD computes_gross.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->gross_qty( iv_net = 90 iv_scrap_percent = 10 )
      exp = 100 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->gross_qty( iv_net = 90 iv_scrap_percent = 0 )
      exp = 90 ).
  ENDMETHOD.

ENDCLASS.
