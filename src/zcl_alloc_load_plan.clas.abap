CLASS zcl_alloc_load_plan DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_item,
             stop     TYPE i,
             material TYPE matnr,
             quantity TYPE menge_d,
           END OF ty_item.
    TYPES ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_load,
             load_pos TYPE i,
             stop     TYPE i,
             material TYPE matnr,
             quantity TYPE menge_d,
           END OF ty_load.
    TYPES ty_load_tt TYPE STANDARD TABLE OF ty_load WITH DEFAULT KEY.

    METHODS plan
      IMPORTING
        it_items       TYPE ty_item_tt
      RETURNING
        VALUE(rt_load) TYPE ty_load_tt.

ENDCLASS.


CLASS zcl_alloc_load_plan IMPLEMENTATION.

  METHOD plan.
    DATA lt_sorted TYPE ty_item_tt.
    DATA lv_pos    TYPE i.
    DATA ls_load   TYPE ty_load.

    lt_sorted = it_items.

    " A trailer is loaded last-stop-first so that the first delivery can be
    " unloaded from the door. The material keeps the order inside a stop stable.
    SORT lt_sorted BY stop DESCENDING
                      material ASCENDING.

    LOOP AT lt_sorted INTO DATA(ls_item).
      lv_pos = lv_pos + 1.

      CLEAR ls_load.
      ls_load-load_pos = lv_pos.
      ls_load-stop = ls_item-stop.
      ls_load-material = ls_item-material.
      ls_load-quantity = ls_item-quantity.
      APPEND ls_load TO rt_load.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
