CLASS zcl_alloc_replenish_kpi DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_kpi,
             fill_rate       TYPE i,
             on_time_percent TYPE i,
           END OF ty_kpi.

    METHODS fill_rate
      IMPORTING
        iv_delivered   TYPE i
        iv_requested   TYPE i
      RETURNING
        VALUE(rv_rate) TYPE i.

    METHODS on_time_percent
      IMPORTING
        iv_on_time        TYPE i
        iv_total          TYPE i
      RETURNING
        VALUE(rv_percent) TYPE i.

    METHODS build
      IMPORTING
        iv_fill_rate       TYPE i
        iv_on_time_percent TYPE i
      RETURNING
        VALUE(rs_kpi)      TYPE ty_kpi.

ENDCLASS.


CLASS zcl_alloc_replenish_kpi IMPLEMENTATION.

  METHOD fill_rate.
    " The fill rate is the delivered part of the request, in percent.
    IF iv_requested <= 0.
      RETURN.
    ENDIF.

    rv_rate = iv_delivered * 100 DIV iv_requested.
  ENDMETHOD.

  METHOD on_time_percent.
    " The on-time share is the punctual part of the whole, in percent.
    IF iv_total <= 0.
      RETURN.
    ENDIF.

    rv_percent = iv_on_time * 100 DIV iv_total.
  ENDMETHOD.

  METHOD build.
    " The card carries the two headline numbers.
    rs_kpi-fill_rate = iv_fill_rate.
    rs_kpi-on_time_percent = iv_on_time_percent.
  ENDMETHOD.

ENDCLASS.
