CLASS zcl_alloc_dock_slot DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS slot_of
      IMPORTING
        iv_arrival     TYPE i
        iv_slot_length TYPE i
      RETURNING
        VALUE(rv_slot) TYPE i.

    METHODS slot_start
      IMPORTING
        iv_slot         TYPE i
        iv_slot_length  TYPE i
      RETURNING
        VALUE(rv_start) TYPE i.

    METHODS slot_end
      IMPORTING
        iv_slot        TYPE i
        iv_slot_length TYPE i
      RETURNING
        VALUE(rv_end)  TYPE i.

ENDCLASS.


CLASS zcl_alloc_dock_slot IMPLEMENTATION.

  METHOD slot_of.
    " Slots are numbered from zero, so slot 0 is the start of the day. An arrival
    " exactly on a boundary belongs to the slot that begins there.
    IF iv_slot_length <= 0 OR iv_arrival < 0.
      RETURN.
    ENDIF.

    rv_slot = iv_arrival DIV iv_slot_length.
  ENDMETHOD.

  METHOD slot_start.
    IF iv_slot_length <= 0 OR iv_slot < 0.
      RETURN.
    ENDIF.

    rv_start = iv_slot * iv_slot_length.
  ENDMETHOD.

  METHOD slot_end.
    DATA lv_start TYPE i.

    lv_start = slot_start( iv_slot        = iv_slot
                           iv_slot_length = iv_slot_length ).
    IF lv_start <= 0 AND iv_slot <= 0.
      RETURN.
    ENDIF.

    rv_end = lv_start + iv_slot_length.
  ENDMETHOD.

ENDCLASS.
