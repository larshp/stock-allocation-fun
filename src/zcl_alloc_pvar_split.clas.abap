CLASS zcl_alloc_pvar_split DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_weight,
             group  TYPE string,
             weight TYPE i,
           END OF ty_weight.
    TYPES ty_weight_tt TYPE STANDARD TABLE OF ty_weight WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_share,
             group  TYPE string,
             amount TYPE i,
           END OF ty_share.
    TYPES ty_share_tt TYPE STANDARD TABLE OF ty_share WITH DEFAULT KEY.

    METHODS split
      IMPORTING
        iv_total         TYPE i
        it_weights       TYPE ty_weight_tt
      RETURNING
        VALUE(rt_shares) TYPE ty_share_tt.

    METHODS share_of
      IMPORTING
        iv_part           TYPE i
        iv_total          TYPE i
      RETURNING
        VALUE(rv_percent) TYPE i.

    METHODS per_unit
      IMPORTING
        iv_amount      TYPE i
        iv_qty         TYPE i
      RETURNING
        VALUE(rv_unit) TYPE i.

ENDCLASS.


CLASS zcl_alloc_pvar_split IMPLEMENTATION.

  METHOD split.
    DATA lv_total_weight TYPE i.
    DATA ls_share TYPE ty_share.

    " Every group takes its share of the total at its weight.
    LOOP AT it_weights INTO DATA(ls_weight).
      lv_total_weight = lv_total_weight + ls_weight-weight.
    ENDLOOP.

    IF lv_total_weight <= 0.
      RETURN.
    ENDIF.

    LOOP AT it_weights INTO DATA(ls_line).
      CLEAR ls_share.
      ls_share-group = ls_line-group.
      ls_share-amount = iv_total * ls_line-weight DIV lv_total_weight.
      APPEND ls_share TO rt_shares.
    ENDLOOP.

    SORT rt_shares BY group ASCENDING.
  ENDMETHOD.

  METHOD share_of.
    " The share is one part as a percentage of the whole.
    IF iv_total = 0.
      RETURN.
    ENDIF.

    rv_percent = iv_part * 100 DIV iv_total.
  ENDMETHOD.

  METHOD per_unit.
    " The unit amount spreads the amount over the quantity.
    IF iv_qty <= 0.
      RETURN.
    ENDIF.

    rv_unit = iv_amount DIV iv_qty.
  ENDMETHOD.

ENDCLASS.
