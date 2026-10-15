CLASS zcl_alloc_slow_mover DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_item,
             material  TYPE matnr,
             movements TYPE i,
           END OF ty_item.
    TYPES ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    METHODS is_slow
      IMPORTING
        iv_movements TYPE i
        iv_threshold TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS movement_class
      IMPORTING
        iv_movements    TYPE i
      RETURNING
        VALUE(rv_class) TYPE string.

    METHODS count_slow
      IMPORTING
        it_items        TYPE ty_item_tt
        iv_threshold    TYPE i
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_slow_mover IMPLEMENTATION.

  METHOD is_slow.
    " A material moves slowly while its movements stay below the threshold.
    rv_ok = xsdbool( iv_movements < iv_threshold ).
  ENDMETHOD.

  METHOD movement_class.
    " The movement count is folded into three bands.
    IF iv_movements <= 2.
      rv_class = 'SLOW'.
    ELSEIF iv_movements <= 10.
      rv_class = 'MEDIUM'.
    ELSE.
      rv_class = 'FAST'.
    ENDIF.
  ENDMETHOD.

  METHOD count_slow.
    LOOP AT it_items INTO DATA(ls_item).
      IF is_slow( iv_movements = ls_item-movements
                  iv_threshold = iv_threshold ) = abap_true.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
