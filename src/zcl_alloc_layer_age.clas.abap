CLASS zcl_alloc_layer_age DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_layer,
             receipt_day TYPE d,
             quantity    TYPE i,
           END OF ty_layer.
    TYPES ty_layer_tt TYPE STANDARD TABLE OF ty_layer WITH DEFAULT KEY.

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

    METHODS oldest
      IMPORTING
        it_layers      TYPE ty_layer_tt
        iv_today       TYPE d
      RETURNING
        VALUE(rv_days) TYPE i.

ENDCLASS.


CLASS zcl_alloc_layer_age IMPLEMENTATION.

  METHOD age_days.
    DATA lv_days TYPE i.

    " The age is the span from the receipt to today, never negative.
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
    " A layer is old once its age passes the threshold.
    rv_ok = xsdbool( iv_age_days > iv_threshold ).
  ENDMETHOD.

  METHOD oldest.
    DATA lv_days TYPE i.

    " The oldest layer is the one that has been in stock the longest.
    LOOP AT it_layers INTO DATA(ls_layer).
      lv_days = age_days( iv_receipt_day = ls_layer-receipt_day
                          iv_today       = iv_today ).
      IF lv_days > rv_days.
        rv_days = lv_days.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
