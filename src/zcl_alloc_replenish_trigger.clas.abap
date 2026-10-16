CLASS zcl_alloc_replenish_trigger DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_trigger,
             material TYPE matnr,
             need     TYPE i,
           END OF ty_trigger.
    TYPES ty_trigger_tt TYPE STANDARD TABLE OF ty_trigger WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_summary,
             trigger_count  TYPE i,
             total_quantity TYPE i,
           END OF ty_summary.

    METHODS build
      IMPORTING
        it_triggers       TYPE ty_trigger_tt
      RETURNING
        VALUE(rs_summary) TYPE ty_summary.

    METHODS trigger_count
      IMPORTING
        it_triggers     TYPE ty_trigger_tt
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS total_quantity
      IMPORTING
        it_triggers     TYPE ty_trigger_tt
      RETURNING
        VALUE(rv_total) TYPE i.

ENDCLASS.


CLASS zcl_alloc_replenish_trigger IMPLEMENTATION.

  METHOD trigger_count.
    " Only a positive need raises a trigger.
    LOOP AT it_triggers INTO DATA(ls_trigger).
      IF ls_trigger-need > 0.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD total_quantity.
    " The triggered quantity sums the positive needs.
    LOOP AT it_triggers INTO DATA(ls_trigger).
      IF ls_trigger-need > 0.
        rv_total = rv_total + ls_trigger-need.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD build.
    rs_summary-trigger_count = trigger_count( it_triggers ).
    rs_summary-total_quantity = total_quantity( it_triggers ).
  ENDMETHOD.

ENDCLASS.
