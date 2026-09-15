CLASS zcl_alloc_policy_diff DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             field_name TYPE c LENGTH 20,
             old_value  TYPE c LENGTH 20,
             new_value  TYPE c LENGTH 20,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_input,
             old_policy TYPE zcl_stock_allocator=>ty_policy,
             new_policy TYPE zcl_stock_allocator=>ty_policy,
           END OF ty_input.

    METHODS compare
      IMPORTING
        is_input        TYPE ty_input
      RETURNING
        VALUE(rt_lines) TYPE ty_line_tt.

  PRIVATE SECTION.
    METHODS add
      IMPORTING
        iv_field        TYPE string
        iv_old          TYPE string
        iv_new          TYPE string
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rt_lines) TYPE ty_line_tt.

ENDCLASS.


CLASS zcl_alloc_policy_diff IMPLEMENTATION.

  METHOD add.
    DATA ls_line TYPE ty_line.

    rt_lines = it_lines.

    ls_line-field_name = iv_field.
    ls_line-old_value = iv_old.
    ls_line-new_value = iv_new.
    APPEND ls_line TO rt_lines.
  ENDMETHOD.

  METHOD compare.
    IF is_input-old_policy-use_fefo <> is_input-new_policy-use_fefo.
      rt_lines = add( iv_field = 'USE_FEFO'
                      iv_old   = |{ is_input-old_policy-use_fefo }|
                      iv_new   = |{ is_input-new_policy-use_fefo }|
                      it_lines = rt_lines ).
    ENDIF.

    IF is_input-old_policy-whole_sales_units
        <> is_input-new_policy-whole_sales_units.
      rt_lines = add( iv_field = 'WHOLE_UNITS'
                      iv_old   = |{ is_input-old_policy-whole_sales_units }|
                      iv_new   = |{ is_input-new_policy-whole_sales_units }|
                      it_lines = rt_lines ).
    ENDIF.

    IF is_input-old_policy-include_quality
        <> is_input-new_policy-include_quality.
      rt_lines = add( iv_field = 'QUALITY'
                      iv_old   = |{ is_input-old_policy-include_quality }|
                      iv_new   = |{ is_input-new_policy-include_quality }|
                      it_lines = rt_lines ).
    ENDIF.

    IF is_input-old_policy-include_blocked
        <> is_input-new_policy-include_blocked.
      rt_lines = add( iv_field = 'BLOCKED'
                      iv_old   = |{ is_input-old_policy-include_blocked }|
                      iv_new   = |{ is_input-new_policy-include_blocked }|
                      it_lines = rt_lines ).
    ENDIF.

    IF is_input-old_policy-max_picks <> is_input-new_policy-max_picks.
      rt_lines = add( iv_field = 'MAX_PICKS'
                      iv_old   = |{ is_input-old_policy-max_picks }|
                      iv_new   = |{ is_input-new_policy-max_picks }|
                      it_lines = rt_lines ).
    ENDIF.

    IF is_input-old_policy-under_tolerance
        <> is_input-new_policy-under_tolerance.
      rt_lines = add( iv_field = 'UNDER_TOLERANCE'
                      iv_old   = |{ is_input-old_policy-under_tolerance }|
                      iv_new   = |{ is_input-new_policy-under_tolerance }|
                      it_lines = rt_lines ).
    ENDIF.

    IF is_input-old_policy-min_remaining_days
        <> is_input-new_policy-min_remaining_days.
      rt_lines = add( iv_field = 'MIN_REM_DAYS'
                      iv_old   = |{ is_input-old_policy-min_remaining_days }|
                      iv_new   = |{ is_input-new_policy-min_remaining_days }|
                      it_lines = rt_lines ).
    ENDIF.

    IF lines( is_input-old_policy-allowed_lgorts )
        <> lines( is_input-new_policy-allowed_lgorts ).
      rt_lines = add( iv_field = 'ALLOWED_COUNT'
                      iv_old   = |{ lines( is_input-old_policy-allowed_lgorts ) }|
                      iv_new   = |{ lines( is_input-new_policy-allowed_lgorts ) }|
                      it_lines = rt_lines ).
    ENDIF.

    IF lines( is_input-old_policy-excluded_lgorts )
        <> lines( is_input-new_policy-excluded_lgorts ).
      rt_lines = add( iv_field = 'EXCLUDED_COUNT'
                      iv_old   = |{ lines( is_input-old_policy-excluded_lgorts ) }|
                      iv_new   = |{ lines( is_input-new_policy-excluded_lgorts ) }|
                      it_lines = rt_lines ).
    ENDIF.
  ENDMETHOD.

ENDCLASS.
