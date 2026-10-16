CLASS ltcl_alloc_val_scrap DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_val_scrap.

    METHODS setup.

    METHODS values_scrap   FOR TESTING.
    METHODS computes_share FOR TESTING.
    METHODS scrapped_rule  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_val_scrap IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_val_scrap( ).
  ENDMETHOD.

  METHOD values_scrap.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->value( iv_original_value = 1000 iv_scrap_percent = 20 )
      exp = 200 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->value( iv_original_value = 1000 iv_scrap_percent = 0 )
      exp = 0 ).
  ENDMETHOD.

  METHOD computes_share.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->scrap_percent( iv_original_value = 1000
                                   iv_scrap_value    = 200 )
      exp = 20 ).
  ENDMETHOD.

  METHOD scrapped_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_scrapped( 20 ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_scrapped( 0 ) exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
