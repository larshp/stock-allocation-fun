CLASS zcl_alloc_pareto_threshold DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_values_tt TYPE STANDARD TABLE OF i WITH DEFAULT KEY.

    METHODS count_vital
      IMPORTING
        it_values            TYPE ty_values_tt
        iv_threshold_percent TYPE i
      RETURNING
        VALUE(rv_count)      TYPE i.

    METHODS is_vital
      IMPORTING
        iv_rank              TYPE i
        it_values            TYPE ty_values_tt
        iv_threshold_percent TYPE i
      RETURNING
        VALUE(rv_ok)         TYPE abap_bool.

    METHODS threshold
      IMPORTING
        it_values            TYPE ty_values_tt
        iv_threshold_percent TYPE i
      RETURNING
        VALUE(rv_value)      TYPE i.

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


CLASS zcl_alloc_pareto_threshold IMPLEMENTATION.

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

  METHOD count_vital.
    DATA lt_sorted     TYPE ty_values_tt.
    DATA lv_total      TYPE i.
    DATA lv_cumulative TYPE i.
    DATA lv_share      TYPE i.

    lt_sorted = sorted_desc( it_values ).
    lv_total = total_value( it_values ).
    IF lv_total <= 0.
      RETURN.
    ENDIF.

    " The vital few are the largest values that make up the threshold share.
    LOOP AT lt_sorted INTO DATA(lv_value).
      lv_cumulative = lv_cumulative + lv_value.
      lv_share = lv_cumulative * 100 DIV lv_total.
      rv_count = rv_count + 1.

      IF lv_share >= iv_threshold_percent.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_vital.
    DATA lv_count TYPE i.

    " A rank is vital while it sits within the vital few.
    IF iv_rank <= 0.
      RETURN.
    ENDIF.

    lv_count = count_vital( it_values            = it_values
                            iv_threshold_percent = iv_threshold_percent ).
    rv_ok = xsdbool( iv_rank <= lv_count ).
  ENDMETHOD.

  METHOD threshold.
    DATA lt_sorted     TYPE ty_values_tt.
    DATA lv_total      TYPE i.
    DATA lv_cumulative TYPE i.
    DATA lv_share      TYPE i.

    lt_sorted = sorted_desc( it_values ).
    lv_total = total_value( it_values ).
    IF lv_total <= 0.
      RETURN.
    ENDIF.

    " The threshold marks the value of the last vital item.
    LOOP AT lt_sorted INTO DATA(lv_value).
      lv_cumulative = lv_cumulative + lv_value.
      lv_share = lv_cumulative * 100 DIV lv_total.

      IF lv_share >= iv_threshold_percent.
        rv_value = lv_value.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
