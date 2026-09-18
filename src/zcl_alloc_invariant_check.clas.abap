CLASS zcl_alloc_invariant_check DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_check,
             rule_id TYPE string,
             ok      TYPE abap_bool,
             detail  TYPE string,
           END OF ty_check.
    TYPES ty_check_tt TYPE STANDARD TABLE OF ty_check WITH DEFAULT KEY.

    METHODS check
      IMPORTING
        it_result        TYPE zcl_stock_allocator=>ty_result_tt
        iv_available     TYPE menge_d
      RETURNING
        VALUE(rt_checks) TYPE ty_check_tt.

    METHODS is_clean
      IMPORTING
        it_checks    TYPE ty_check_tt
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

  PRIVATE SECTION.
    CONSTANTS c_rule_negative  TYPE string VALUE 'no_negative'.
    CONSTANTS c_rule_over      TYPE string VALUE 'not_over_requested'.
    CONSTANTS c_rule_shortage  TYPE string VALUE 'shortage_consistent'.
    CONSTANTS c_rule_available TYPE string VALUE 'within_available'.
    CONSTANTS c_rule_trace     TYPE string VALUE 'trace_present'.

    METHODS ok_of
      IMPORTING
        iv_failed    TYPE abap_bool
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS add_row
      IMPORTING
        iv_rule          TYPE string
        iv_ok            TYPE abap_bool
        iv_detail        TYPE string
        it_checks        TYPE ty_check_tt
      RETURNING
        VALUE(rt_checks) TYPE ty_check_tt.

ENDCLASS.


CLASS zcl_alloc_invariant_check IMPLEMENTATION.

  METHOD ok_of.
    " A rule is satisfied when its failure flag was not raised.
    IF iv_failed = abap_false.
      rv_ok = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD add_row.
    DATA ls_check TYPE ty_check.

    rt_checks = it_checks.

    ls_check-rule_id = iv_rule.
    ls_check-ok = iv_ok.
    ls_check-detail = iv_detail.
    APPEND ls_check TO rt_checks.
  ENDMETHOD.

  METHOD check.
    DATA lv_allocated TYPE menge_d.
    DATA lv_detailed  TYPE menge_d.
    DATA lv_negative  TYPE abap_bool.
    DATA lv_over      TYPE abap_bool.
    DATA lv_shortage  TYPE abap_bool.
    DATA lv_trace     TYPE abap_bool.
    DATA lv_avail_fail TYPE abap_bool.

    LOOP AT it_result INTO DATA(ls_line).
      lv_allocated = lv_allocated + ls_line-allocated_qty.

      IF ls_line-allocated_qty < 0.
        lv_negative = abap_true.
      ENDIF.

      IF ls_line-allocated_qty > ls_line-requested_qty.
        lv_over = abap_true.
      ENDIF.

      IF ls_line-shortage_qty <> ls_line-requested_qty - ls_line-allocated_qty.
        lv_shortage = abap_true.
      ENDIF.

      CLEAR lv_detailed.
      LOOP AT ls_line-allocations INTO DATA(ls_alloc).
        lv_detailed = lv_detailed + ls_alloc-quantity.
      ENDLOOP.

      IF ls_line-allocated_qty > 0 AND lines( ls_line-allocations ) = 0.
        lv_trace = abap_true.
      ENDIF.

      IF lv_detailed <> ls_line-allocated_qty.
        lv_trace = abap_true.
      ENDIF.
    ENDLOOP.

    " A zero available quantity means the caller has no stock figure to check
    " against, so the rule passes by definition.
    IF iv_available > 0 AND lv_allocated > iv_available.
      lv_avail_fail = abap_true.
    ENDIF.

    rt_checks = add_row( iv_rule   = c_rule_negative
                         iv_ok     = ok_of( iv_failed = lv_negative )
                         iv_detail = 'a line has a negative allocated quantity'
                         it_checks = rt_checks ).

    rt_checks = add_row( iv_rule   = c_rule_over
                         iv_ok     = ok_of( iv_failed = lv_over )
                         iv_detail = 'a line is allocated more than requested'
                         it_checks = rt_checks ).

    rt_checks = add_row( iv_rule   = c_rule_shortage
                         iv_ok     = ok_of( iv_failed = lv_shortage )
                         iv_detail = 'shortage does not match requested minus allocated'
                         it_checks = rt_checks ).

    rt_checks = add_row( iv_rule   = c_rule_trace
                         iv_ok     = ok_of( iv_failed = lv_trace )
                         iv_detail = 'allocation details do not sum to the allocated quantity'
                         it_checks = rt_checks ).

    rt_checks = add_row( iv_rule   = c_rule_available
                         iv_ok     = ok_of( iv_failed = lv_avail_fail )
                         iv_detail = 'allocated total exceeds the available quantity'
                         it_checks = rt_checks ).
  ENDMETHOD.

  METHOD is_clean.
    rv_ok = abap_true.

    LOOP AT it_checks INTO DATA(ls_check).
      IF ls_check-ok = abap_false.
        rv_ok = abap_false.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
