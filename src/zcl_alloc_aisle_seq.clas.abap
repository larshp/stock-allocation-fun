CLASS zcl_alloc_aisle_seq DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_aisles_tt TYPE STANDARD TABLE OF i WITH DEFAULT KEY.

    METHODS sequence
      IMPORTING
        it_aisles       TYPE ty_aisles_tt
        iv_start        TYPE i
      RETURNING
        VALUE(rt_order) TYPE ty_aisles_tt.

ENDCLASS.


CLASS zcl_alloc_aisle_seq IMPLEMENTATION.

  METHOD sequence.
    DATA lt_high TYPE ty_aisles_tt.
    DATA lt_low  TYPE ty_aisles_tt.

    " Aisle sequence: walk the aisles at or above the start in ascending order,
    " then come back for the aisles below the start in descending order, so the
    " picker turns around once instead of criss-crossing.
    LOOP AT it_aisles INTO DATA(lv_aisle).
      IF lv_aisle >= iv_start.
        APPEND lv_aisle TO lt_high.
      ELSE.
        APPEND lv_aisle TO lt_low.
      ENDIF.
    ENDLOOP.

    SORT lt_high ASCENDING.
    SORT lt_low DESCENDING.

    LOOP AT lt_high INTO DATA(lv_high).
      APPEND lv_high TO rt_order.
    ENDLOOP.

    LOOP AT lt_low INTO DATA(lv_low).
      APPEND lv_low TO rt_order.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
