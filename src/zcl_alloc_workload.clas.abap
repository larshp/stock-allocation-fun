CLASS zcl_alloc_workload DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_operation,
             order_id    TYPE string,
             work_centre TYPE string,
             period      TYPE i,
             load_hours  TYPE menge_d,
           END OF ty_operation.
    TYPES ty_operation_tt TYPE STANDARD TABLE OF ty_operation
                          WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_load,
             work_centre TYPE string,
             period      TYPE i,
             load_hours  TYPE menge_d,
             seq         TYPE i,
             over        TYPE abap_bool,
           END OF ty_load.
    TYPES ty_load_tt TYPE STANDARD TABLE OF ty_load WITH DEFAULT KEY.

    METHODS build
      IMPORTING
        it_operations  TYPE ty_operation_tt
        iv_capacity    TYPE menge_d
      RETURNING
        VALUE(rt_load) TYPE ty_load_tt.

    METHODS overload_count
      IMPORTING
        it_load         TYPE ty_load_tt
      RETURNING
        VALUE(rv_count) TYPE i.

  PRIVATE SECTION.
    TYPES: BEGIN OF ty_raw,
             seq         TYPE i,
             work_centre TYPE string,
             period      TYPE i,
             load_hours  TYPE menge_d,
           END OF ty_raw.
    TYPES ty_raw_tt TYPE STANDARD TABLE OF ty_raw WITH DEFAULT KEY.

    METHODS add_row
      IMPORTING
        iv_work_centre TYPE string
        iv_period      TYPE i
        iv_load_hours  TYPE menge_d
        iv_seq         TYPE i
        it_load        TYPE ty_load_tt
      RETURNING
        VALUE(rt_load) TYPE ty_load_tt.

ENDCLASS.


CLASS zcl_alloc_workload IMPLEMENTATION.

  METHOD add_row.
    DATA ls_row TYPE ty_load.

    rt_load = it_load.

    ls_row-work_centre = iv_work_centre.
    ls_row-period = iv_period.
    ls_row-load_hours = iv_load_hours.
    ls_row-seq = iv_seq.
    APPEND ls_row TO rt_load.
  ENDMETHOD.

  METHOD build.
    DATA lt_raw   TYPE ty_raw_tt.
    DATA ls_raw   TYPE ty_raw.
    DATA lv_wc    TYPE string.
    DATA lv_per   TYPE i.
    DATA lv_hours TYPE menge_d.
    DATA lv_seq   TYPE i.
    DATA lv_have  TYPE abap_bool.

    LOOP AT it_operations INTO DATA(ls_op).
      CLEAR ls_raw.
      ls_raw-seq = lines( lt_raw ) + 1.
      ls_raw-work_centre = ls_op-work_centre.
      ls_raw-period = ls_op-period.
      ls_raw-load_hours = ls_op-load_hours.
      APPEND ls_raw TO lt_raw.
    ENDLOOP.

    " One sort by work centre and period, then a single forward pass that merges
    " equal cells, instead of scanning the load table once per operation.
    SORT lt_raw BY work_centre period seq.

    LOOP AT lt_raw INTO ls_raw.
      IF lv_have = abap_true
         AND ls_raw-work_centre = lv_wc
         AND ls_raw-period = lv_per.
        lv_hours = lv_hours + ls_raw-load_hours.
        CONTINUE.
      ENDIF.

      IF lv_have = abap_true.
        rt_load = add_row( iv_work_centre = lv_wc
                           iv_period      = lv_per
                           iv_load_hours  = lv_hours
                           iv_seq         = lv_seq
                           it_load        = rt_load ).
      ENDIF.

      lv_wc = ls_raw-work_centre.
      lv_per = ls_raw-period.
      lv_hours = ls_raw-load_hours.
      lv_seq = ls_raw-seq.
      lv_have = abap_true.
    ENDLOOP.

    IF lv_have = abap_true.
      rt_load = add_row( iv_work_centre = lv_wc
                         iv_period      = lv_per
                         iv_load_hours  = lv_hours
                         iv_seq         = lv_seq
                         it_load        = rt_load ).
    ENDIF.

    " Restore the order in which the cells were first seen.
    SORT rt_load BY seq.

    IF iv_capacity > 0.
      LOOP AT rt_load ASSIGNING FIELD-SYMBOL(<ls_load>).
        IF <ls_load>-load_hours > iv_capacity.
          <ls_load>-over = abap_true.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD overload_count.
    LOOP AT it_load INTO DATA(ls_load).
      IF ls_load-over = abap_true.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
