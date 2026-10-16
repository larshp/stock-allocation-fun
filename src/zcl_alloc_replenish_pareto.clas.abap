CLASS zcl_alloc_replenish_pareto DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_values_tt TYPE STANDARD TABLE OF i WITH DEFAULT KEY.

    METHODS cumulative_percent
      IMPORTING
        it_values         TYPE ty_values_tt
      RETURNING
        VALUE(rt_percent) TYPE ty_values_tt.

    METHODS vital_few
      IMPORTING
        it_values            TYPE ty_values_tt
        iv_threshold_percent TYPE i
      RETURNING
        VALUE(rv_count)      TYPE i.

    METHODS pareto
      IMPORTING
        it_values       TYPE ty_values_tt
      RETURNING
        VALUE(rv_count) TYPE i.

  PRIVATE SECTION.
    TYPES: BEGIN OF ty_work,
             value TYPE i,
             seq   TYPE i,
           END OF ty_work.

    METHODS sorted_desc
      IMPORTING
        it_values        TYPE ty_values_tt
      RETURNING
        VALUE(rt_values) TYPE ty_values_tt.

    METHODS total_value
      IMPORTING
        it_values       TYPE ty_values_tt
      RETURNING
        VALUE(rv_total) TYPE i.

ENDCLASS.


CLASS zcl_alloc_replenish_pareto IMPLEMENTATION.

  METHOD sorted_desc.
    DATA lt_work TYPE STANDARD TABLE OF ty_work WITH DEFAULT KEY.
    DATA ls_work TYPE ty_work.
    DATA lv_seq  TYPE i.

    " The values are carried with their position, so equal values keep their
    " original order once sorted by value.
    LOOP AT it_values INTO DATA(lv_value).
      lv_seq = lv_seq + 1.
      ls_work-value = lv_value.
      ls_work-seq = lv_seq.
      APPEND ls_work TO lt_work.
    ENDLOOP.

    SORT lt_work BY value DESCENDING seq ASCENDING.

    LOOP AT lt_work INTO ls_work.
      APPEND ls_work-value TO rt_values.
    ENDLOOP.
  ENDMETHOD.

  METHOD total_value.
    LOOP AT it_values INTO DATA(lv_value).
      rv_total = rv_total + lv_value.
    ENDLOOP.
  ENDMETHOD.

  METHOD cumulative_percent.
    DATA lt_sorted TYPE ty_values_tt.
    DATA lv_total  TYPE i.
    DATA lv_cum    TYPE i.
    DATA lv_pct    TYPE i.

    " Each rank carries the running share of the total, from the largest down.
    lt_sorted = sorted_desc( it_values ).
    lv_total = total_value( it_values ).
    IF lv_total <= 0.
      RETURN.
    ENDIF.

    LOOP AT lt_sorted INTO DATA(lv_value).
      lv_cum = lv_cum + lv_value.
      lv_pct = lv_cum * 100 DIV lv_total.
      APPEND lv_pct TO rt_percent.
    ENDLOOP.
  ENDMETHOD.

  METHOD vital_few.
    DATA lt_sorted TYPE ty_values_tt.
    DATA lv_total  TYPE i.
    DATA lv_cum    TYPE i.
    DATA lv_pct    TYPE i.

    " The vital few are the largest values that make up the threshold share.
    lt_sorted = sorted_desc( it_values ).
    lv_total = total_value( it_values ).
    IF lv_total <= 0.
      RETURN.
    ENDIF.

    LOOP AT lt_sorted INTO DATA(lv_value).
      lv_cum = lv_cum + lv_value.
      lv_pct = lv_cum * 100 DIV lv_total.
      rv_count = rv_count + 1.

      IF lv_pct >= iv_threshold_percent.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD pareto.
    " The classic Pareto cut is the vital few at eighty percent.
    rv_count = vital_few( it_values            = it_values
                          iv_threshold_percent = 80 ).
  ENDMETHOD.

ENDCLASS.
