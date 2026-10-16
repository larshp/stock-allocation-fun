CLASS zcl_alloc_delivery_split DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_qty_tt TYPE STANDARD TABLE OF menge_d WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_input,
             quantity     TYPE menge_d,
             max_delivery TYPE menge_d,
           END OF ty_input.

    METHODS split
      IMPORTING
        is_input      TYPE ty_input
      RETURNING
        VALUE(rt_qty) TYPE ty_qty_tt.

ENDCLASS.


CLASS zcl_alloc_delivery_split IMPLEMENTATION.

  METHOD split.
    DATA lv_remaining TYPE menge_d.
    DATA lv_part      TYPE menge_d.

    IF is_input-quantity <= 0 OR is_input-max_delivery <= 0.
      APPEND is_input-quantity TO rt_qty.
      RETURN.
    ENDIF.

    lv_remaining = is_input-quantity.

    WHILE lv_remaining > 0.
      lv_part = is_input-max_delivery.
      IF lv_part > lv_remaining.
        lv_part = lv_remaining.
      ENDIF.

      APPEND lv_part TO rt_qty.

      lv_remaining = lv_remaining - lv_part.
    ENDWHILE.
  ENDMETHOD.

ENDCLASS.
