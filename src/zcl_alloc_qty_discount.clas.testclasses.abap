CLASS ltcl_alloc_qty_discount DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_qty_discount.
    DATA mt_tier TYPE zcl_alloc_qty_discount=>ty_tier_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_quantity  TYPE i
        iv_unit_cost TYPE i.

    METHODS picks_tier   FOR TESTING.
    METHODS computes_cost FOR TESTING.
    METHODS cheaper_rule FOR TESTING.
    METHODS empty_input  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_qty_discount IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_qty_discount( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_tier TYPE zcl_alloc_qty_discount=>ty_tier.

    ls_tier-quantity = iv_quantity.
    ls_tier-unit_cost = iv_unit_cost.
    APPEND ls_tier TO mt_tier.
  ENDMETHOD.

  METHOD picks_tier.
    add( iv_quantity = 10 iv_unit_cost = 5 ).
    add( iv_quantity = 100 iv_unit_cost = 4 ).
    add( iv_quantity = 500 iv_unit_cost = 3 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->best_tier( it_tiers = mt_tier iv_quantity = 50 )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->best_tier( it_tiers = mt_tier iv_quantity = 200 )
      exp = 2 ).
  ENDMETHOD.

  METHOD computes_cost.
    add( iv_quantity = 10 iv_unit_cost = 5 ).
    add( iv_quantity = 100 iv_unit_cost = 4 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->cost_at( it_tiers = mt_tier iv_quantity = 200 )
      exp = 800 ).
  ENDMETHOD.

  METHOD cheaper_rule.
    add( iv_quantity = 10 iv_unit_cost = 5 ).
    add( iv_quantity = 100 iv_unit_cost = 4 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_cheaper( it_tiers = mt_tier iv_quantity_a = 10
                                iv_quantity_b = 200 )
      exp = abap_true ).
  ENDMETHOD.

  METHOD empty_input.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->best_tier( it_tiers = mt_tier iv_quantity = 50 )
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->cost_at( it_tiers = mt_tier iv_quantity = 50 )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
