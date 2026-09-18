CLASS zcl_alloc_policy_preset DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_name TYPE c LENGTH 10.

    METHODS preset
      IMPORTING
        iv_name          TYPE ty_name
      RETURNING
        VALUE(rs_policy) TYPE zcl_stock_allocator=>ty_policy.

ENDCLASS.


CLASS zcl_alloc_policy_preset IMPLEMENTATION.

  METHOD preset.
    CASE iv_name.
      WHEN 'FEFO'.
        rs_policy-use_fefo = abap_true.
      WHEN 'WHOLE'.
        rs_policy-whole_sales_units = abap_true.
      WHEN 'SAFE'.
        rs_policy-include_quality = abap_true.
        rs_policy-include_blocked = abap_true.
      WHEN 'LIMIT'.
        rs_policy-max_picks = 1.
      WHEN 'TOLERANT'.
        rs_policy-under_tolerance = 10.
    ENDCASE.
  ENDMETHOD.

ENDCLASS.
