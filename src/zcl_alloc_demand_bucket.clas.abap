CLASS zcl_alloc_demand_bucket DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_period,
             period TYPE i,
             value  TYPE i,
           END OF ty_period.
    TYPES ty_period_tt TYPE STANDARD TABLE OF ty_period WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_bucket,
             bucket TYPE i,
             total  TYPE i,
             count  TYPE i,
           END OF ty_bucket.
    TYPES ty_bucket_tt TYPE STANDARD TABLE OF ty_bucket WITH DEFAULT KEY.

    METHODS bucket_of
      IMPORTING
        it_periods        TYPE ty_period_tt
      RETURNING
        VALUE(rt_buckets) TYPE ty_bucket_tt.

    METHODS total_in
      IMPORTING
        it_periods      TYPE ty_period_tt
        iv_period       TYPE i
      RETURNING
        VALUE(rv_total) TYPE i.

    METHODS count_in
      IMPORTING
        it_periods      TYPE ty_period_tt
        iv_period       TYPE i
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_demand_bucket IMPLEMENTATION.

  METHOD bucket_of.
    DATA lt_count TYPE SORTED TABLE OF ty_bucket WITH UNIQUE KEY bucket.
    DATA ls_count TYPE ty_bucket.

    " The demand is summed per period key in a sorted table, so the buckets come
    " out in period order.
    LOOP AT it_periods INTO DATA(ls_period).
      READ TABLE lt_count ASSIGNING FIELD-SYMBOL(<ls_count>)
        WITH KEY bucket = ls_period-period.

      IF sy-subrc <> 0.
        CLEAR ls_count.
        ls_count-bucket = ls_period-period.
        INSERT ls_count INTO TABLE lt_count ASSIGNING <ls_count>.
      ENDIF.

      <ls_count>-total = <ls_count>-total + ls_period-value.
      <ls_count>-count = <ls_count>-count + 1.
    ENDLOOP.

    rt_buckets = lt_count.
  ENDMETHOD.

  METHOD total_in.
    LOOP AT it_periods INTO DATA(ls_period).
      IF ls_period-period = iv_period.
        rv_total = rv_total + ls_period-value.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD count_in.
    LOOP AT it_periods INTO DATA(ls_period).
      IF ls_period-period = iv_period.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
