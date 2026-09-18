CLASS zcl_alloc_load_test DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_input,
             virtual_users      TYPE i,
             iterations         TYPE i,
             rows_per_iteration TYPE i,
             ms_per_row         TYPE i,
           END OF ty_input.

    TYPES: BEGIN OF ty_plan,
             total_operations  TYPE i,
             total_rows        TYPE i,
             estimated_ms      TYPE i,
             estimated_seconds TYPE i,
           END OF ty_plan.

    METHODS plan
      IMPORTING
        is_input       TYPE ty_input
      RETURNING
        VALUE(rs_plan) TYPE ty_plan.

ENDCLASS.


CLASS zcl_alloc_load_test IMPLEMENTATION.

  METHOD plan.
    IF is_input-virtual_users <= 0 OR is_input-iterations <= 0.
      RETURN.
    ENDIF.

    rs_plan-total_operations = is_input-virtual_users * is_input-iterations.
    rs_plan-total_rows = rs_plan-total_operations * is_input-rows_per_iteration.
    rs_plan-estimated_ms = rs_plan-total_rows * is_input-ms_per_row.
    rs_plan-estimated_seconds = rs_plan-estimated_ms DIV 1000.
  ENDMETHOD.

ENDCLASS.
