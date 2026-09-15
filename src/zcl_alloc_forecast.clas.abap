CLASS zcl_alloc_forecast DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_qty_tt TYPE STANDARD TABLE OF menge_d WITH DEFAULT KEY.

    METHODS next_quantity
      IMPORTING
        it_quantities TYPE ty_qty_tt
        iv_window     TYPE i DEFAULT 3
      RETURNING
        VALUE(rv_qty) TYPE menge_d.

ENDCLASS.


CLASS zcl_alloc_forecast IMPLEMENTATION.

  METHOD next_quantity.
    DATA lv_count  TYPE i.
    DATA lv_start  TYPE i.
    DATA lv_index  TYPE i.
    DATA lv_sum    TYPE menge_d.
    DATA lv_used   TYPE i.
    DATA lv_window TYPE i.
    DATA lv_qty    TYPE menge_d.

    lv_window = iv_window.
    IF lv_window < 1.
      lv_window = 1.
    ENDIF.

    lv_count = lines( it_quantities ).
    IF lv_count = 0.
      rv_qty = 0.
      RETURN.
    ENDIF.

    lv_start = lv_count - lv_window + 1.
    IF lv_start < 1.
      lv_start = 1.
    ENDIF.

    lv_index = lv_start.
    WHILE lv_index <= lv_count.
      READ TABLE it_quantities INTO lv_qty INDEX lv_index.
      IF sy-subrc = 0.
        lv_sum = lv_sum + lv_qty.
        lv_used = lv_used + 1.
      ENDIF.
      lv_index = lv_index + 1.
    ENDWHILE.

    IF lv_used > 0.
      rv_qty = lv_sum / lv_used.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
