CLASS zcl_alloc_landed_duty DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             material TYPE matnr,
             value    TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    TYPES ty_values_tt TYPE STANDARD TABLE OF i WITH DEFAULT KEY.

    METHODS apportion
      IMPORTING
        it_lines        TYPE ty_line_tt
        iv_rate_percent TYPE i
      RETURNING
        VALUE(rt_duty)  TYPE ty_values_tt.

    METHODS total_duty
      IMPORTING
        it_duty         TYPE ty_values_tt
      RETURNING
        VALUE(rv_total) TYPE i.

    METHODS rate_percent
      IMPORTING
        iv_duty_value     TYPE i
        iv_customs_value  TYPE i
      RETURNING
        VALUE(rv_percent) TYPE i.

ENDCLASS.


CLASS zcl_alloc_landed_duty IMPLEMENTATION.

  METHOD apportion.
    DATA lv_duty TYPE i.
    DATA ls_line TYPE ty_line.

    " The duty is charged on each line's customs value at the given rate.
    LOOP AT it_lines INTO ls_line.
      lv_duty = ls_line-value * iv_rate_percent DIV 100.
      APPEND lv_duty TO rt_duty.
    ENDLOOP.
  ENDMETHOD.

  METHOD total_duty.
    LOOP AT it_duty INTO DATA(lv_duty).
      rv_total = rv_total + lv_duty.
    ENDLOOP.
  ENDMETHOD.

  METHOD rate_percent.
    " The implied rate is the duty related to the customs value.
    IF iv_customs_value <= 0.
      RETURN.
    ENDIF.

    rv_percent = iv_duty_value * 100 DIV iv_customs_value.
  ENDMETHOD.

ENDCLASS.
