CLASS zcl_alloc_stress DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_levels_tt TYPE STANDARD TABLE OF i WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_step,
             level_pct TYPE i,
             threshold TYPE menge_d,
             breached  TYPE abap_bool,
           END OF ty_step.
    TYPES ty_step_tt TYPE STANDARD TABLE OF ty_step WITH DEFAULT KEY.

    METHODS ladder
      IMPORTING
        iv_from          TYPE i
        iv_to            TYPE i
        iv_step          TYPE i
      RETURNING
        VALUE(rt_levels) TYPE ty_levels_tt.

    METHODS assess
      IMPORTING
        it_levels       TYPE ty_levels_tt
        iv_base         TYPE menge_d
        iv_total        TYPE menge_d
      RETURNING
        VALUE(rt_steps) TYPE ty_step_tt.

ENDCLASS.


CLASS zcl_alloc_stress IMPLEMENTATION.

  METHOD ladder.
    DATA lv_level TYPE i.

    IF iv_step <= 0 OR iv_to < iv_from.
      RETURN.
    ENDIF.

    lv_level = iv_from.
    WHILE lv_level <= iv_to.
      APPEND lv_level TO rt_levels.
      lv_level = lv_level + iv_step.
    ENDWHILE.
  ENDMETHOD.

  METHOD assess.
    DATA ls_step      TYPE ty_step.
    DATA lv_threshold TYPE menge_d.

    LOOP AT it_levels INTO DATA(lv_level).
      CLEAR ls_step.
      lv_threshold = iv_base * lv_level DIV 100.

      ls_step-level_pct = lv_level.
      ls_step-threshold = lv_threshold.

      IF iv_total > lv_threshold.
        ls_step-breached = abap_true.
      ELSE.
        ls_step-breached = abap_false.
      ENDIF.

      APPEND ls_step TO rt_steps.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
