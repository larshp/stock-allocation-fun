CLASS zcl_alloc_backpressure DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_input,
             queue_depth    TYPE i,
             capacity       TYPE i,
             drain_per_tick TYPE i,
           END OF ty_input.

    TYPES: BEGIN OF ty_decision,
             action     TYPE string,
             wait_ticks TYPE i,
             load_pct   TYPE i,
           END OF ty_decision.

    METHODS assess
      IMPORTING
        is_input           TYPE ty_input
      RETURNING
        VALUE(rs_decision) TYPE ty_decision.

ENDCLASS.


CLASS zcl_alloc_backpressure IMPLEMENTATION.

  METHOD assess.
    DATA lv_excess TYPE i.

    IF is_input-capacity <= 0.
      rs_decision-action = 'reject'.
      rs_decision-load_pct = 100.
      RETURN.
    ENDIF.

    IF is_input-queue_depth <= 0.
      rs_decision-action = 'accept'.
      RETURN.
    ENDIF.

    rs_decision-load_pct = is_input-queue_depth * 100 DIV is_input-capacity.
    IF rs_decision-load_pct > 100.
      rs_decision-load_pct = 100.
    ENDIF.

    IF is_input-queue_depth <= is_input-capacity
       AND rs_decision-load_pct < 80.
      rs_decision-action = 'accept'.
      RETURN.
    ENDIF.

    IF is_input-queue_depth <= is_input-capacity.
      rs_decision-action = 'throttle'.
      rs_decision-wait_ticks = 1.
      RETURN.
    ENDIF.

    IF is_input-drain_per_tick <= 0.
      rs_decision-action = 'reject'.
      RETURN.
    ENDIF.

    lv_excess = is_input-queue_depth - is_input-capacity.
    rs_decision-action = 'throttle'.
    rs_decision-wait_ticks = lv_excess DIV is_input-drain_per_tick.
    IF lv_excess MOD is_input-drain_per_tick > 0.
      rs_decision-wait_ticks = rs_decision-wait_ticks + 1.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
