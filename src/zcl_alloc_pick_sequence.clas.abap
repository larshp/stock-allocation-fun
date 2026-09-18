CLASS zcl_alloc_pick_sequence DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_item,
             lgort    TYPE lgort_d,
             charg    TYPE c LENGTH 10,
             quantity TYPE menge_d,
           END OF ty_item.
    TYPES ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    METHODS sequence
      IMPORTING
        it_items        TYPE ty_item_tt
      RETURNING
        VALUE(rt_items) TYPE ty_item_tt.

ENDCLASS.


CLASS zcl_alloc_pick_sequence IMPLEMENTATION.

  METHOD sequence.
    rt_items = it_items.
    SORT rt_items BY lgort ASCENDING
                     charg ASCENDING.
  ENDMETHOD.

ENDCLASS.
