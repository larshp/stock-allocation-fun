CLASS zcl_alloc_demand DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_periods_tt TYPE STANDARD TABLE OF i WITH DEFAULT KEY.

    METHODS total
      IMPORTING
        it_periods      TYPE ty_periods_tt
      RETURNING
        VALUE(rv_total) TYPE i.

    METHODS average
      IMPORTING
        it_periods    TYPE ty_periods_tt
      RETURNING
        VALUE(rv_avg) TYPE i.

    METHODS period_count
      IMPORTING
        it_periods      TYPE ty_periods_tt
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_demand IMPLEMENTATION.

  METHOD total.
    " A demand is never negative, so a period with no demand adds nothing.
    LOOP AT it_periods INTO DATA(lv_value).
      IF lv_value > 0.
        rv_total = rv_total + lv_value.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD period_count.
    LOOP AT it_periods INTO DATA(lv_value).
      IF lv_value > 0.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD average.
    DATA lv_count TYPE i.

    lv_count = period_count( it_periods ).

    " The average demand is spread over the periods that carry demand.
    IF lv_count <= 0.
      RETURN.
    ENDIF.

    rv_avg = total( it_periods ) DIV lv_count.
  ENDMETHOD.

ENDCLASS.
