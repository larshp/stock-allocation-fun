CLASS ltcl_alloc_fast_mover DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_fast_mover.
    DATA mt_item TYPE zcl_alloc_fast_mover=>ty_item_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_material  TYPE matnr
        iv_turn_rate TYPE i.

    METHODS computes_turns FOR TESTING.
    METHODS fast_rule      FOR TESTING.
    METHODS counts_fast    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_fast_mover IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_fast_mover( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_item TYPE zcl_alloc_fast_mover=>ty_item.

    ls_item-material = iv_material.
    ls_item-turn_rate = iv_turn_rate.
    APPEND ls_item TO mt_item.
  ENDMETHOD.

  METHOD computes_turns.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->turns( iv_annual_demand = 1200 iv_average_stock = 100 )
      exp = 12 ).
  ENDMETHOD.

  METHOD fast_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_fast( iv_turns = 12 iv_threshold = 10 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_fast( iv_turns = 8 iv_threshold = 10 )
      exp = abap_false ).
  ENDMETHOD.

  METHOD counts_fast.
    add( iv_material = 'M1' iv_turn_rate = 12 ).
    add( iv_material = 'M2' iv_turn_rate = 8 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->count_fast( it_items = mt_item iv_threshold = 10 )
      exp = 1 ).
  ENDMETHOD.

ENDCLASS.
