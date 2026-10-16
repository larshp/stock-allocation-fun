CLASS ltcl_alloc_stock_age DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_stock_age.
    DATA mt_item TYPE zcl_alloc_stock_age=>ty_item_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_material    TYPE matnr
        iv_receipt_day TYPE d.

    METHODS computes_age FOR TESTING.
    METHODS old_rule     FOR TESTING.
    METHODS counts_old   FOR TESTING.
    METHODS empty_input  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_stock_age IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_stock_age( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_item TYPE zcl_alloc_stock_age=>ty_item.

    ls_item-material = iv_material.
    ls_item-receipt_day = iv_receipt_day.
    APPEND ls_item TO mt_item.
  ENDMETHOD.

  METHOD computes_age.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->age_days( iv_receipt_day = '20260101'
                              iv_today       = '20260111' )
      exp = 10 ).
  ENDMETHOD.

  METHOD old_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_old( iv_age_days = 100 iv_threshold = 90 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_old( iv_age_days = 60 iv_threshold = 90 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD counts_old.
    add( iv_material = 'M1' iv_receipt_day = '20260101' ).
    add( iv_material = 'M2' iv_receipt_day = '20260401' ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->count_old( it_items = mt_item iv_today = '20260501'
                               iv_threshold = 90 )
      exp = 1 ).
  ENDMETHOD.

  METHOD empty_input.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->count_old( it_items = mt_item iv_today = '20260501'
                               iv_threshold = 90 )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
