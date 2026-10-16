CLASS zcl_alloc_cycle_detect DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_values_tt TYPE STANDARD TABLE OF i WITH DEFAULT KEY.

    METHODS loop_detected
      IMPORTING
        it_steps     TYPE ty_values_tt
        iv_step      TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS is_loop
      IMPORTING
        it_steps     TYPE ty_values_tt
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS reason
      IMPORTING
        iv_loop          TYPE abap_bool
      RETURNING
        VALUE(rv_reason) TYPE string.

ENDCLASS.


CLASS zcl_alloc_cycle_detect IMPLEMENTATION.

  METHOD loop_detected.
    " A step that has been visited before signals a loop.
    LOOP AT it_steps INTO DATA(lv_step).
      IF lv_step = iv_step.
        rv_ok = abap_true.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_loop.
    DATA lv_idx TYPE i.
    DATA lv_pos TYPE i.

    " Any step that appears twice in the list is a loop.
    LOOP AT it_steps INTO DATA(lv_outer).
      lv_idx = lv_idx + 1.
      lv_pos = 0.
      LOOP AT it_steps INTO DATA(lv_inner).
        lv_pos = lv_pos + 1.
        IF lv_pos < lv_idx AND lv_inner = lv_outer.
          rv_ok = abap_true.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD reason.
    " The reading tells whether the cycle came back on itself.
    IF iv_loop = abap_true.
      rv_reason = 'cycle revisited'.
    ELSE.
      rv_reason = 'clear'.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
