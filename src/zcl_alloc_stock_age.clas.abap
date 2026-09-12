CLASS zcl_alloc_stock_age DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_input,
             gr_date        TYPE d,
             reference_date TYPE d,
           END OF ty_input.

    METHODS calculate
      IMPORTING
        is_input       TYPE ty_input
      RETURNING
        VALUE(rv_days) TYPE i.

ENDCLASS.


CLASS zcl_alloc_stock_age IMPLEMENTATION.

  METHOD calculate.
    DATA lv_days TYPE i.

    IF is_input-gr_date IS INITIAL
        OR is_input-reference_date IS INITIAL.
      rv_days = 0.
      RETURN.
    ENDIF.

    lv_days = is_input-reference_date - is_input-gr_date.
    IF lv_days < 0.
      lv_days = 0.
    ENDIF.

    rv_days = lv_days.
  ENDMETHOD.

ENDCLASS.
