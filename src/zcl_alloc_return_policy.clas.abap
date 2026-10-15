CLASS zcl_alloc_return_policy DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_policy,
             name        TYPE string,
             window_days TYPE i,
             fee_percent TYPE i,
           END OF ty_policy.

    METHODS preset
      IMPORTING
        iv_tier          TYPE string
      RETURNING
        VALUE(rs_policy) TYPE ty_policy.

    METHODS window_days
      IMPORTING
        iv_tier        TYPE string
      RETURNING
        VALUE(rv_days) TYPE i.

    METHODS fee_percent
      IMPORTING
        iv_tier       TYPE string
      RETURNING
        VALUE(rv_pct) TYPE i.

ENDCLASS.


CLASS zcl_alloc_return_policy IMPLEMENTATION.

  METHOD preset.
    " Each named tier carries its own return window and restocking fee.
    rs_policy-name = iv_tier.

    CASE iv_tier.
      WHEN 'STANDARD'.
        rs_policy-window_days = 30.
        rs_policy-fee_percent = 0.
      WHEN 'PREMIUM'.
        rs_policy-window_days = 60.
        rs_policy-fee_percent = 0.
      WHEN 'FLEX'.
        rs_policy-window_days = 90.
        rs_policy-fee_percent = 0.
      WHEN 'CLEARANCE'.
        rs_policy-window_days = 14.
        rs_policy-fee_percent = 10.
      WHEN OTHERS.
        rs_policy-window_days = 0.
        rs_policy-fee_percent = 0.
    ENDCASE.
  ENDMETHOD.

  METHOD window_days.
    DATA ls_policy TYPE ty_policy.

    ls_policy = preset( iv_tier ).
    rv_days = ls_policy-window_days.
  ENDMETHOD.

  METHOD fee_percent.
    DATA ls_policy TYPE ty_policy.

    ls_policy = preset( iv_tier ).
    rv_pct = ls_policy-fee_percent.
  ENDMETHOD.

ENDCLASS.
