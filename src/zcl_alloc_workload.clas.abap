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

ENDCLASS.


CLASS zcl_alloc_workload IMPLEMENTATION.

  METHOD build.
    DATA lt_load TYPE ty_load_tt.
    DATA ls_row  TYPE ty_load.
    DATA ls_new  TYPE ty_load.

    LOOP AT it_operations INTO DATA(ls_op).
      READ TABLE lt_load INTO ls_row
        WITH KEY work_centre = ls_op-work_centre period = ls_op-period.

      IF sy-subrc = 0.
        ls_new-work_centre = ls_op-work_centre.
        ls_new-period = ls_op-period.
        ls_new-load_hours = ls_row-load_hours + ls_op-load_hours.

        DELETE lt_load WHERE work_centre = ls_op-work_centre
                          AND period = ls_op-period.
        APPEND ls_new TO lt_load.
        CONTINUE.
      ENDIF.

      CLEAR ls_new.
      ls_new-work_centre = ls_op-work_centre.
      ls_new-period = ls_op-period.
      ls_new-load_hours = ls_op-load_hours.
      APPEND ls_new TO lt_load.
    ENDLOOP.

    IF iv_capacity > 0.
      LOOP AT lt_load ASSIGNING FIELD-SYMBOL(<ls_load>).
        IF <ls_load>-load_hours > iv_capacity.
          <ls_load>-over = abap_true.
        ENDIF.
      ENDLOOP.
    ENDIF.

    rt_load = lt_load.
  ENDMETHOD.

  METHOD overload_count.
    LOOP AT it_load INTO DATA(ls_load).
      IF ls_load-over = abap_true.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
