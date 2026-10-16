CLASS zcl_alloc_key_agg DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_raw,
             key      TYPE i,
             quantity TYPE menge_d,
           END OF ty_raw.
    TYPES ty_raw_tt TYPE STANDARD TABLE OF ty_raw WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_sum,
             key      TYPE i,
             quantity TYPE menge_d,
           END OF ty_sum.
    TYPES ty_sum_tt TYPE STANDARD TABLE OF ty_sum WITH DEFAULT KEY.

    METHODS reset.

    METHODS add
      IMPORTING
        iv_key      TYPE i
        iv_quantity TYPE menge_d.

    METHODS sums
      RETURNING
        VALUE(rt_sums) TYPE ty_sum_tt.

    METHODS find
      IMPORTING
        iv_key        TYPE i
      RETURNING
        VALUE(rv_qty) TYPE menge_d.

    METHODS size
      RETURNING
        VALUE(rv_size) TYPE i.

    METHODS visits
      RETURNING
        VALUE(rv_visits) TYPE i.

  PRIVATE SECTION.
    DATA mt_raw    TYPE ty_raw_tt.
    DATA mt_sums   TYPE ty_sum_tt.
    DATA mv_visits TYPE i.
    DATA mv_sorted TYPE abap_bool.
    DATA mv_built  TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_key_agg IMPLEMENTATION.

  METHOD reset.
    CLEAR mt_raw.
    CLEAR mt_sums.
    CLEAR mv_visits.
    CLEAR mv_sorted.
    CLEAR mv_built.
  ENDMETHOD.

  METHOD add.
    DATA ls_raw TYPE ty_raw.

    " Collecting is a single append, so adding n rows costs n.
    ls_raw-key = iv_key.
    ls_raw-quantity = iv_quantity.
    APPEND ls_raw TO mt_raw.

    mv_visits = mv_visits + 1.
    CLEAR mv_sorted.
    CLEAR mv_built.
  ENDMETHOD.

  METHOD size.
    rv_size = lines( mt_raw ).
  ENDMETHOD.

  METHOD visits.
    rv_visits = mv_visits.
  ENDMETHOD.

  METHOD sums.
    DATA ls_sum  TYPE ty_sum.
    DATA lv_key  TYPE i.
    DATA lv_qty  TYPE menge_d.
    DATA lv_have TYPE abap_bool.

    IF mv_built = abap_true.
      rt_sums = mt_sums.
      RETURN.
    ENDIF.

    " One sort, then a single forward pass that merges equal keys, so the
    " grouping itself is linear in the number of rows instead of quadratic.
    IF mv_sorted = abap_false.
      SORT mt_raw BY key.
      mv_sorted = abap_true.
    ENDIF.

    LOOP AT mt_raw INTO DATA(ls_raw).
      mv_visits = mv_visits + 1.

      IF lv_have = abap_true AND ls_raw-key = lv_key.
        lv_qty = lv_qty + ls_raw-quantity.
        CONTINUE.
      ENDIF.

      IF lv_have = abap_true.
        CLEAR ls_sum.
        ls_sum-key = lv_key.
        ls_sum-quantity = lv_qty.
        APPEND ls_sum TO mt_sums.
      ENDIF.

      lv_key = ls_raw-key.
      lv_qty = ls_raw-quantity.
      lv_have = abap_true.
    ENDLOOP.

    IF lv_have = abap_true.
      CLEAR ls_sum.
      ls_sum-key = lv_key.
      ls_sum-quantity = lv_qty.
      APPEND ls_sum TO mt_sums.
    ENDIF.

    mv_built = abap_true.
    rt_sums = mt_sums.
  ENDMETHOD.

  METHOD find.
    DATA lt_sums TYPE ty_sum_tt.
    DATA lv_lo   TYPE i.
    DATA lv_hi   TYPE i.
    DATA lv_mid  TYPE i.

    lt_sums = sums( ).
    IF lines( lt_sums ) = 0.
      RETURN.
    ENDIF.

    " Binary search, so the lookup is logarithmic rather than linear.
    lv_lo = 1.
    lv_hi = lines( lt_sums ).

    WHILE lv_lo <= lv_hi.
      mv_visits = mv_visits + 1.
      lv_mid = ( lv_lo + lv_hi ) DIV 2.

      READ TABLE lt_sums INTO DATA(ls_sum) INDEX lv_mid.

      IF ls_sum-key = iv_key.
        rv_qty = ls_sum-quantity.
        RETURN.
      ENDIF.

      IF ls_sum-key < iv_key.
        lv_lo = lv_mid + 1.
      ELSE.
        lv_hi = lv_mid - 1.
      ENDIF.
    ENDWHILE.
  ENDMETHOD.

ENDCLASS.
