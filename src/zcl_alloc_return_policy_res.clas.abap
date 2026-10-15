CLASS zcl_alloc_return_policy_res DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_rule,
             tier        TYPE string,
             priority    TYPE string,
             window_days TYPE i,
             fee_percent TYPE i,
           END OF ty_rule.
    TYPES ty_rule_tt TYPE STANDARD TABLE OF ty_rule WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_policy,
             window_days TYPE i,
             fee_percent TYPE i,
           END OF ty_policy.

    METHODS resolve
      IMPORTING
        it_rules         TYPE ty_rule_tt
        iv_tier          TYPE string
        iv_priority      TYPE string
      RETURNING
        VALUE(rs_policy) TYPE ty_policy.

    METHODS window_of
      IMPORTING
        it_rules       TYPE ty_rule_tt
        iv_tier        TYPE string
      RETURNING
        VALUE(rv_days) TYPE i.

    METHODS fee_of
      IMPORTING
        it_rules      TYPE ty_rule_tt
        iv_tier       TYPE string
      RETURNING
        VALUE(rv_pct) TYPE i.

  PRIVATE SECTION.
    METHODS lookup
      IMPORTING
        it_rules       TYPE ty_rule_tt
        iv_tier        TYPE string
        iv_priority    TYPE string
      RETURNING
        VALUE(rs_rule) TYPE ty_rule.

ENDCLASS.


CLASS zcl_alloc_return_policy_res IMPLEMENTATION.

  METHOD lookup.
    LOOP AT it_rules INTO DATA(ls_rule).
      IF ls_rule-tier = iv_tier AND ls_rule-priority = iv_priority.
        rs_rule = ls_rule.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD resolve.
    DATA ls_rule TYPE ty_rule.

    " The rules are matched on tier and priority first, then on the tier alone,
    " and finally on the global default; nothing at all resolves to zeros.
    ls_rule = lookup( it_rules    = it_rules
                      iv_tier     = iv_tier
                      iv_priority = iv_priority ).

    IF ls_rule-tier IS INITIAL AND ls_rule-priority IS INITIAL.
      ls_rule = lookup( it_rules    = it_rules
                        iv_tier     = iv_tier
                        iv_priority = '' ).
    ENDIF.

    IF ls_rule-tier IS INITIAL AND ls_rule-priority IS INITIAL.
      ls_rule = lookup( it_rules    = it_rules
                        iv_tier     = ''
                        iv_priority = '' ).
    ENDIF.

    rs_policy-window_days = ls_rule-window_days.
    rs_policy-fee_percent = ls_rule-fee_percent.
  ENDMETHOD.

  METHOD window_of.
    DATA ls_policy TYPE ty_policy.

    ls_policy = resolve( it_rules    = it_rules
                         iv_tier     = iv_tier
                         iv_priority = '' ).
    rv_days = ls_policy-window_days.
  ENDMETHOD.

  METHOD fee_of.
    DATA ls_policy TYPE ty_policy.

    ls_policy = resolve( it_rules    = it_rules
                         iv_tier     = iv_tier
                         iv_priority = '' ).
    rv_pct = ls_policy-fee_percent.
  ENDMETHOD.

ENDCLASS.
