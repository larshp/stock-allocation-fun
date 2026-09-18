CLASS zcl_alloc_batch_tune DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_input,
             total_rows      TYPE i,
             rows_per_second TYPE i,
             target_seconds  TYPE i,
             min_batch       TYPE i,
             max_batch       TYPE i,
           END OF ty_input.

    TYPES: BEGIN OF ty_plan,
             batch_size  TYPE i,
             batch_count TYPE i,
           END OF ty_plan.

    METHODS tune
      IMPORTING
        is_input       TYPE ty_input
      RETURNING
        VALUE(rs_plan) TYPE ty_plan.

ENDCLASS.


CLASS zcl_alloc_batch_tune IMPLEMENTATION.

  METHOD tune.
    DATA lv_size TYPE i.

    IF is_input-total_rows <= 0.
      RETURN.
    ENDIF.

    lv_size = is_input-rows_per_second * is_input-target_seconds.
    IF lv_size < 1.
      lv_size = is_input-total_rows.
    ENDIF.

    IF is_input-max_batch > 0 AND lv_size > is_input-max_batch.
      lv_size = is_input-max_batch.
    ENDIF.

    IF is_input-min_batch > 0 AND lv_size < is_input-min_batch.
      lv_size = is_input-min_batch.
    ENDIF.

    IF lv_size > is_input-total_rows.
      lv_size = is_input-total_rows.
    ENDIF.

    rs_plan-batch_size = lv_size.
    rs_plan-batch_count = is_input-total_rows DIV lv_size.
    IF is_input-total_rows MOD lv_size > 0.
      rs_plan-batch_count = rs_plan-batch_count + 1.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
