CLASS ltcl_alloc_dead_stock DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_dead_stock.
    DATA mt_item TYPE zcl_alloc_dead_stock=>ty_item_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_material          TYPE matnr
        iv_last_movement_day TYPE d
        iv_stock             TYPE i.

    METHODS computes_days FOR TESTING.
    METHODS dead_rule     FOR TESTING.
    METHODS counts_dead   FOR TESTING.
    METHODS empty_input   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_dead_stock IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_dead_stock( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_item TYPE zcl_alloc_dead_stock=>ty_item.

    ls_item-material = iv_material.
    ls_item-last_movement_day = iv_last_movement_day.
    ls_item-stock = iv_stock.
    APPEND ls_item TO mt_item.
  ENDMETHOD.

  METHOD computes_days.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->days_since( iv_last_movement_day = '20260101'
                                iv_today             = '20260131' )
      exp = 30 ).
  ENDMETHOD.

  METHOD dead_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_dead( iv_days_since = 30 iv_threshold = 90 )
      exp = abap_false ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_dead( iv_days_since = 100 iv_threshold = 90 )
      exp = abap_true ).
  ENDMETHOD.

  METHOD counts_dead.
    add( iv_material = 'M1' iv_last_movement_day = '20260101' iv_stock = 10 ).
    add( iv_material = 'M2' iv_last_movement_day = '20260401' iv_stock = 5 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->count_dead( it_items = mt_item iv_today = '20260401'
                                iv_threshold = 90 )
      exp = 1 ).
  ENDMETHOD.

  METHOD empty_input.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->count_dead( it_items = mt_item iv_today = '20260401'
                                iv_threshold = 90 )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
