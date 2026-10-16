CLASS zcl_alloc_return_load DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_item,
             material    TYPE matnr,
             quantity    TYPE i,
             unit_volume TYPE i,
           END OF ty_item.
    TYPES ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_load,
             material TYPE matnr,
             quantity TYPE i,
             volume   TYPE i,
           END OF ty_load.
    TYPES ty_load_tt TYPE STANDARD TABLE OF ty_load WITH DEFAULT KEY.

    METHODS plan
      IMPORTING
        it_items       TYPE ty_item_tt
      RETURNING
        VALUE(rt_load) TYPE ty_load_tt.

    METHODS total_volume
      IMPORTING
        it_items         TYPE ty_item_tt
      RETURNING
        VALUE(rv_volume) TYPE i.

    METHODS is_feasible
      IMPORTING
        it_items     TYPE ty_item_tt
        iv_capacity  TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_return_load IMPLEMENTATION.

  METHOD plan.
    DATA ls_load TYPE ty_load.

    " Each load line carries the volume of the whole line, i.e. quantity times the
    " unit volume; a line with no quantity or no volume contributes nothing.
    LOOP AT it_items INTO DATA(ls_item).
      IF ls_item-quantity <= 0 OR ls_item-unit_volume <= 0.
        CONTINUE.
      ENDIF.

      CLEAR ls_load.
      ls_load-material = ls_item-material.
      ls_load-quantity = ls_item-quantity.
      ls_load-volume = ls_item-quantity * ls_item-unit_volume.
      APPEND ls_load TO rt_load.
    ENDLOOP.
  ENDMETHOD.

  METHOD total_volume.
    DATA lt_load TYPE ty_load_tt.

    lt_load = plan( it_items ).

    LOOP AT lt_load INTO DATA(ls_load).
      rv_volume = rv_volume + ls_load-volume.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_feasible.
    " The load fits when the total volume is within the vehicle's capacity.
    IF iv_capacity <= 0.
      RETURN.
    ENDIF.

    rv_ok = xsdbool( total_volume( it_items ) <= iv_capacity ).
  ENDMETHOD.

ENDCLASS.
