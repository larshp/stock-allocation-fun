CLASS zcl_alloc_qty_discount DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_tier,
             quantity  TYPE i,
             unit_cost TYPE i,
           END OF ty_tier.
    TYPES ty_tier_tt TYPE STANDARD TABLE OF ty_tier WITH DEFAULT KEY.

    METHODS best_tier
      IMPORTING
        it_tiers        TYPE ty_tier_tt
        iv_quantity     TYPE i
      RETURNING
        VALUE(rv_index) TYPE i.

    METHODS cost_at
      IMPORTING
        it_tiers       TYPE ty_tier_tt
        iv_quantity    TYPE i
      RETURNING
        VALUE(rv_cost) TYPE i.

    METHODS is_cheaper
      IMPORTING
        it_tiers      TYPE ty_tier_tt
        iv_quantity_a TYPE i
        iv_quantity_b TYPE i
      RETURNING
        VALUE(rv_ok)  TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_qty_discount IMPLEMENTATION.

  METHOD best_tier.
    DATA lv_best_quantity TYPE i.
    DATA lv_found TYPE abap_bool.
    DATA lv_index TYPE i.

    " The applicable tier is the one with the largest quantity breakpoint that
    " the ordered quantity still reaches.
    LOOP AT it_tiers INTO DATA(ls_tier).
      lv_index = lv_index + 1.

      IF ls_tier-quantity <= iv_quantity AND ls_tier-unit_cost > 0.
        IF lv_found = abap_false OR ls_tier-quantity > lv_best_quantity.
          lv_found = abap_true.
          lv_best_quantity = ls_tier-quantity.
          rv_index = lv_index.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD cost_at.
    DATA lv_index TYPE i.
    DATA ls_tier TYPE ty_tier.

    lv_index = best_tier( it_tiers = it_tiers iv_quantity = iv_quantity ).
    IF lv_index <= 0.
      RETURN.
    ENDIF.

    READ TABLE it_tiers INTO ls_tier INDEX lv_index.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    rv_cost = iv_quantity * ls_tier-unit_cost.
  ENDMETHOD.

  METHOD is_cheaper.
    " One order quantity is cheaper once its total cost sits below the other.
    rv_ok = xsdbool( cost_at( it_tiers = it_tiers iv_quantity = iv_quantity_a )
                     < cost_at( it_tiers = it_tiers iv_quantity = iv_quantity_b ) ).
  ENDMETHOD.

ENDCLASS.
