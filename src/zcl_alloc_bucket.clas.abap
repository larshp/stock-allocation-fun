CLASS zcl_alloc_bucket DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_qty_tt TYPE STANDARD TABLE OF menge_d WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_input,
             value      TYPE menge_d,
             boundaries TYPE ty_qty_tt,
           END OF ty_input.

    METHODS bucket
      IMPORTING
        is_input         TYPE ty_input
      RETURNING
        VALUE(rv_bucket) TYPE i.

ENDCLASS.


CLASS zcl_alloc_bucket IMPLEMENTATION.

  METHOD bucket.
    rv_bucket = 1.

    LOOP AT is_input-boundaries INTO DATA(lv_boundary).
      IF is_input-value >= lv_boundary.
        rv_bucket = rv_bucket + 1.
      ELSE.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
