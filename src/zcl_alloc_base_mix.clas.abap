CLASS zcl_alloc_base_mix DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             name     TYPE string,
             quantity TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS mix
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_total) TYPE i.

    METHODS is_mixed
      IMPORTING
        it_lines     TYPE ty_line_tt
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS largest
      IMPORTING
        it_lines          TYPE ty_line_tt
      RETURNING
        VALUE(rv_largest) TYPE i.

ENDCLASS.


CLASS zcl_alloc_base_mix IMPLEMENTATION.

  METHOD mix.
    " The mix is the total quantity behind the base.
    LOOP AT it_lines INTO DATA(ls_line).
      rv_total = rv_total + ls_line-quantity.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_mixed.
    DATA lv_first TYPE i.
    DATA lv_seen  TYPE abap_bool.

    " A base is mixed once its lines do not all carry the same quantity.
    LOOP AT it_lines INTO DATA(ls_line).
      IF lv_seen = abap_false.
        lv_first = ls_line-quantity.
        lv_seen = abap_true.
        CONTINUE.
      ENDIF.

      IF ls_line-quantity <> lv_first.
        rv_ok = abap_true.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD largest.
    DATA lv_first TYPE abap_bool.

    " The largest line carries the most quantity.
    lv_first = abap_true.

    LOOP AT it_lines INTO DATA(ls_line).
      IF lv_first = abap_true OR ls_line-quantity > rv_largest.
        rv_largest = ls_line-quantity.
        lv_first = abap_false.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
