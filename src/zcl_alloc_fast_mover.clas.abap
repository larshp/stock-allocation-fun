CLASS zcl_alloc_fast_mover DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_item,
             material  TYPE matnr,
             turn_rate TYPE i,
           END OF ty_item.
    TYPES ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    METHODS is_fast
      IMPORTING
        iv_turns     TYPE i
        iv_threshold TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS turns
      IMPORTING
        iv_annual_demand TYPE i
        iv_average_stock TYPE i
      RETURNING
        VALUE(rv_turns)  TYPE i.

    METHODS count_fast
      IMPORTING
        it_items        TYPE ty_item_tt
        iv_threshold    TYPE i
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_fast_mover IMPLEMENTATION.

  METHOD turns.
    " The turnover rate spreads the annual demand over the average stock.
    IF iv_average_stock <= 0.
      RETURN.
    ENDIF.

    rv_turns = iv_annual_demand DIV iv_average_stock.
  ENDMETHOD.

  METHOD is_fast.
    " A material moves fast once its turnover reaches the threshold.
    rv_ok = xsdbool( iv_turns >= iv_threshold ).
  ENDMETHOD.

  METHOD count_fast.
    LOOP AT it_items INTO DATA(ls_item).
      IF is_fast( iv_turns     = ls_item-turn_rate
                  iv_threshold = iv_threshold ) = abap_true.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
