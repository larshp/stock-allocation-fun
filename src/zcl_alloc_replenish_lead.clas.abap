CLASS zcl_alloc_replenish_lead DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_values_tt TYPE STANDARD TABLE OF i WITH DEFAULT KEY.

    METHODS actual
      IMPORTING
        iv_ordered_day  TYPE d
        iv_received_day TYPE d
      RETURNING
        VALUE(rv_days)  TYPE i.

    METHODS average
      IMPORTING
        it_days        TYPE ty_values_tt
      RETURNING
        VALUE(rv_days) TYPE i.

    METHODS is_late
      IMPORTING
        iv_actual    TYPE i
        iv_planned   TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_replenish_lead IMPLEMENTATION.

  METHOD actual.
    DATA lv_days TYPE i.

    " The actual lead time is the span from the order to the receipt.
    IF iv_ordered_day IS INITIAL OR iv_received_day IS INITIAL.
      RETURN.
    ENDIF.

    lv_days = iv_received_day - iv_ordered_day.
    IF lv_days < 0.
      RETURN.
    ENDIF.

    rv_days = lv_days.
  ENDMETHOD.

  METHOD average.
    DATA lv_count TYPE i.

    " The average spreads the lead times over their count.
    lv_count = lines( it_days ).
    IF lv_count = 0.
      RETURN.
    ENDIF.

    LOOP AT it_days INTO DATA(lv_day).
      rv_days = rv_days + lv_day.
    ENDLOOP.

    rv_days = rv_days DIV lv_count.
  ENDMETHOD.

  METHOD is_late.
    " The receipt is late once the actual lead time passes the plan.
    rv_ok = xsdbool( iv_actual > iv_planned ).
  ENDMETHOD.

ENDCLASS.
