CLASS zcl_alloc_layer_split DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_values_tt TYPE STANDARD TABLE OF i WITH DEFAULT KEY.

    METHODS split
      IMPORTING
        iv_quantity     TYPE i
        iv_parts        TYPE i
      RETURNING
        VALUE(rt_parts) TYPE ty_values_tt.

    METHODS parts
      IMPORTING
        iv_quantity     TYPE i
        iv_part_size    TYPE i
      RETURNING
        VALUE(rv_parts) TYPE i.

    METHODS total_qty
      IMPORTING
        it_parts        TYPE ty_values_tt
      RETURNING
        VALUE(rv_total) TYPE i.

ENDCLASS.


CLASS zcl_alloc_layer_split IMPLEMENTATION.

  METHOD split.
    DATA lv_base TYPE i.
    DATA lv_rest TYPE i.
    DATA lv_part TYPE i.

    " The quantity is cut into equal parts; the remainder rides on the first.
    IF iv_parts <= 0.
      RETURN.
    ENDIF.

    lv_base = iv_quantity DIV iv_parts.
    lv_rest = iv_quantity MOD iv_parts.

    DO iv_parts TIMES.
      lv_part = lv_base.
      IF sy-index = 1.
        lv_part = lv_base + lv_rest.
      ENDIF.

      APPEND lv_part TO rt_parts.
    ENDDO.
  ENDMETHOD.

  METHOD parts.
    " The number of parts of a given size is rounded up.
    IF iv_part_size <= 0.
      RETURN.
    ENDIF.

    rv_parts = ( iv_quantity + iv_part_size - 1 ) DIV iv_part_size.
  ENDMETHOD.

  METHOD total_qty.
    " The parts add back up to the whole.
    LOOP AT it_parts INTO DATA(lv_part).
      rv_total = rv_total + lv_part.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
