CLASS zcl_alloc_return_coq DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_cost,
             category TYPE string,
             amount   TYPE i,
           END OF ty_cost.
    TYPES ty_cost_tt TYPE STANDARD TABLE OF ty_cost WITH DEFAULT KEY.

    METHODS total
      IMPORTING
        it_costs        TYPE ty_cost_tt
      RETURNING
        VALUE(rv_total) TYPE i.

    METHODS scrap_share
      IMPORTING
        it_costs      TYPE ty_cost_tt
      RETURNING
        VALUE(rv_pct) TYPE i.

    METHODS rework_share
      IMPORTING
        it_costs      TYPE ty_cost_tt
      RETURNING
        VALUE(rv_pct) TYPE i.

  PRIVATE SECTION.
    METHODS sum_category
      IMPORTING
        it_costs        TYPE ty_cost_tt
        iv_category     TYPE string
      RETURNING
        VALUE(rv_total) TYPE i.

ENDCLASS.


CLASS zcl_alloc_return_coq IMPLEMENTATION.

  METHOD sum_category.
    " An empty category means every cost; negative amounts never reduce the total.
    LOOP AT it_costs INTO DATA(ls_cost).
      IF iv_category IS NOT INITIAL
         AND ls_cost-category <> iv_category.
        CONTINUE.
      ENDIF.

      IF ls_cost-amount > 0.
        rv_total = rv_total + ls_cost-amount.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD total.
    rv_total = sum_category( it_costs    = it_costs
                             iv_category = '' ).
  ENDMETHOD.

  METHOD scrap_share.
    DATA lv_total TYPE i.
    DATA lv_scrap TYPE i.

    lv_total = sum_category( it_costs    = it_costs
                             iv_category = '' ).
    IF lv_total <= 0.
      RETURN.
    ENDIF.

    lv_scrap = sum_category( it_costs    = it_costs
                             iv_category = 'SCRAP' ).

    rv_pct = lv_scrap * 100 DIV lv_total.
  ENDMETHOD.

  METHOD rework_share.
    DATA lv_total  TYPE i.
    DATA lv_rework TYPE i.

    lv_total = sum_category( it_costs    = it_costs
                             iv_category = '' ).
    IF lv_total <= 0.
      RETURN.
    ENDIF.

    lv_rework = sum_category( it_costs    = it_costs
                              iv_category = 'REWORK' ).

    rv_pct = lv_rework * 100 DIV lv_total.
  ENDMETHOD.

ENDCLASS.
