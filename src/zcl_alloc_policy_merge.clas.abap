CLASS zcl_alloc_policy_merge DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_input,
             base     TYPE zcl_stock_allocator=>ty_policy,
             override TYPE zcl_stock_allocator=>ty_policy,
           END OF ty_input.

    METHODS merge
      IMPORTING
        is_input         TYPE ty_input
      RETURNING
        VALUE(rs_policy) TYPE zcl_stock_allocator=>ty_policy.

ENDCLASS.


CLASS zcl_alloc_policy_merge IMPLEMENTATION.

  METHOD merge.
    rs_policy = is_input-base.

    IF is_input-override-include_quality = abap_true.
      rs_policy-include_quality = abap_true.
    ENDIF.
    IF is_input-override-include_blocked = abap_true.
      rs_policy-include_blocked = abap_true.
    ENDIF.
    IF is_input-override-include_restricted = abap_true.
      rs_policy-include_restricted = abap_true.
    ENDIF.
    IF is_input-override-include_transit = abap_true.
      rs_policy-include_transit = abap_true.
    ENDIF.
    IF is_input-override-use_fefo = abap_true.
      rs_policy-use_fefo = abap_true.
    ENDIF.
    IF is_input-override-whole_sales_units = abap_true.
      rs_policy-whole_sales_units = abap_true.
    ENDIF.

    IF is_input-override-max_picks <> 0.
      rs_policy-max_picks = is_input-override-max_picks.
    ENDIF.
    IF is_input-override-under_tolerance <> 0.
      rs_policy-under_tolerance = is_input-override-under_tolerance.
    ENDIF.
    IF is_input-override-min_remaining_days <> 0.
      rs_policy-min_remaining_days = is_input-override-min_remaining_days.
    ENDIF.
    IF is_input-override-safety_stock <> 0.
      rs_policy-safety_stock = is_input-override-safety_stock.
    ENDIF.
    IF is_input-override-reference_date IS NOT INITIAL.
      rs_policy-reference_date = is_input-override-reference_date.
    ENDIF.
    IF is_input-override-horizon_date IS NOT INITIAL.
      rs_policy-horizon_date = is_input-override-horizon_date.
    ENDIF.

    IF lines( is_input-override-allowed_lgorts ) > 0.
      rs_policy-allowed_lgorts = is_input-override-allowed_lgorts.
    ENDIF.
    IF lines( is_input-override-excluded_lgorts ) > 0.
      rs_policy-excluded_lgorts = is_input-override-excluded_lgorts.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
