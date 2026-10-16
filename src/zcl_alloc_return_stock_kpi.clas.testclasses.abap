CLASS ltcl_alloc_return_stock_kpi DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_return_stock_kpi.

    METHODS setup.

    METHODS stock
      IMPORTING
        iv_quantity     TYPE i
        iv_value        TYPE i
        iv_age          TYPE i
      RETURNING
        VALUE(rs_stock) TYPE zcl_alloc_return_stock_kpi=>ty_stock.

    METHODS builds_card     FOR TESTING.
    METHODS flags_aged      FOR TESTING.
    METHODS value_helper    FOR TESTING.
    METHODS age_helper      FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_return_stock_kpi IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_return_stock_kpi( ).
  ENDMETHOD.

  METHOD stock.
    rs_stock-quantity = iv_quantity.
    rs_stock-unit_value = iv_value.
    rs_stock-age_days = iv_age.
  ENDMETHOD.

  METHOD builds_card.
    DATA ls_kpi TYPE zcl_alloc_return_stock_kpi=>ty_kpi.

    ls_kpi = mo_cut->build( stock( iv_quantity = 10 iv_value = 5
                                   iv_age = 100 ) ).

    cl_abap_unit_assert=>assert_equals( act = ls_kpi-value exp = 50 ).
    cl_abap_unit_assert=>assert_equals( act = ls_kpi-age_days exp = 100 ).
  ENDMETHOD.

  METHOD flags_aged.
    DATA ls_kpi TYPE zcl_alloc_return_stock_kpi=>ty_kpi.

    ls_kpi = mo_cut->build( stock( iv_quantity = 10 iv_value = 5
                                   iv_age = 100 ) ).
    cl_abap_unit_assert=>assert_equals( act = ls_kpi-aged exp = abap_true ).

    ls_kpi = mo_cut->build( stock( iv_quantity = 10 iv_value = 5
                                   iv_age = 10 ) ).
    cl_abap_unit_assert=>assert_equals( act = ls_kpi-aged exp = abap_false ).
  ENDMETHOD.

  METHOD value_helper.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->value( iv_quantity = 10 iv_unit_value = 5 )
      exp = 50 ).
  ENDMETHOD.

  METHOD age_helper.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->age_days( iv_received = '20260101'
                              iv_check    = '20260111' )
      exp = 10 ).
  ENDMETHOD.

ENDCLASS.
