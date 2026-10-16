CLASS zcl_alloc_stock_age DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_item,
             material    TYPE matnr,
             receipt_day TYPE d,
           END OF ty_item.
    TYPES ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    METHODS age_days
      IMPORTING
        iv_receipt_day TYPE d
        iv_today       TYPE d
      RETURNING
        VALUE(rv_days) TYPE i.

    METHODS is_old
      IMPORTING
        iv_age_days  TYPE i
        iv_threshold TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS count_old
      IMPORTING
        it_items        TYPE ty_item_tt
        iv_today        TYPE d
        iv_threshold    TYPE i
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_stock_age IMPLEMENTATION.

  METHOD age_days.
    DATA lv_days TYPE i.

    " Without a receipt date the age cannot be told.
    IF iv_receipt_day IS INITIAL OR iv_today IS INITIAL.
      RETURN.
    ENDIF.

    lv_days = iv_today - iv_receipt_day.
    IF lv_days < 0.
      RETURN.
    ENDIF.

    rv_days = lv_days.
  ENDMETHOD.

  METHOD is_old.
    " The stock is old once it reaches the threshold.
    rv_ok = xsdbool( iv_age_days >= iv_threshold ).
  ENDMETHOD.

  METHOD count_old.
    DATA lv_days TYPE i.

    LOOP AT it_items INTO DATA(ls_item).
      lv_days = age_days( iv_receipt_day = ls_item-receipt_day
                          iv_today       = iv_today ).

      IF is_old( iv_age_days   = lv_days
                  iv_threshold = iv_threshold ) = abap_true.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
