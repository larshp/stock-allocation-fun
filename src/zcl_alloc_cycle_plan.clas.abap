CLASS zcl_alloc_cycle_plan DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_bin,
             bin_id         TYPE string,
             last_count_day TYPE i,
           END OF ty_bin.
    TYPES ty_bin_tt TYPE STANDARD TABLE OF ty_bin WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_plan,
             bin_id     TYPE string,
             days_since TYPE i,
             due        TYPE abap_bool,
           END OF ty_plan.
    TYPES ty_plan_tt TYPE STANDARD TABLE OF ty_plan WITH DEFAULT KEY.

    METHODS plan
      IMPORTING
        it_bins        TYPE ty_bin_tt
        iv_today       TYPE i
        iv_frequency   TYPE i
      RETURNING
        VALUE(rt_plan) TYPE ty_plan_tt.

    METHODS due_count
      IMPORTING
        it_plan         TYPE ty_plan_tt
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_cycle_plan IMPLEMENTATION.

  METHOD plan.
    DATA ls_plan TYPE ty_plan.

    " A bin that was never counted has day zero, which makes it the most overdue.
    LOOP AT it_bins INTO DATA(ls_bin).
      CLEAR ls_plan.

      IF iv_today > ls_bin-last_count_day.
        ls_plan-days_since = iv_today - ls_bin-last_count_day.
      ENDIF.

      ls_plan-bin_id = ls_bin-bin_id.
      ls_plan-due = xsdbool( iv_frequency > 0
                         AND ls_plan-days_since >= iv_frequency ).

      APPEND ls_plan TO rt_plan.
    ENDLOOP.
  ENDMETHOD.

  METHOD due_count.
    LOOP AT it_plan INTO DATA(ls_plan).
      IF ls_plan-due = abap_true.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
