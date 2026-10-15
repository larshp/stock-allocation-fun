CLASS zcl_alloc_return_kpi DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_kpi,
             rate_percent TYPE i,
             on_target    TYPE abap_bool,
             value        TYPE i,
           END OF ty_kpi.

    METHODS build
      IMPORTING
        iv_returned       TYPE i
        iv_shipped        TYPE i
        iv_target_percent TYPE i
        iv_unit_value     TYPE i
      RETURNING
        VALUE(rs_kpi)     TYPE ty_kpi.

    METHODS rate_percent
      IMPORTING
        iv_returned   TYPE i
        iv_shipped    TYPE i
      RETURNING
        VALUE(rv_pct) TYPE i.

    METHODS value
      IMPORTING
        iv_returned     TYPE i
        iv_unit_value   TYPE i
      RETURNING
        VALUE(rv_value) TYPE i.

ENDCLASS.


CLASS zcl_alloc_return_kpi IMPLEMENTATION.

  METHOD rate_percent.
    IF iv_shipped <= 0 OR iv_returned <= 0.
      RETURN.
    ENDIF.

    rv_pct = iv_returned * 100 DIV iv_shipped.
  ENDMETHOD.

  METHOD value.
    " The returned value is what the returns are worth; a bad input is worth
    " nothing.
    IF iv_returned <= 0 OR iv_unit_value <= 0.
      RETURN.
    ENDIF.

    rv_value = iv_returned * iv_unit_value.
  ENDMETHOD.

  METHOD build.
    " A return rate is a "lower is better" measure, so the card is on target when
    " the rate is at or below the target.
    rs_kpi-rate_percent = rate_percent( iv_returned = iv_returned
                                        iv_shipped  = iv_shipped ).
    rs_kpi-on_target = xsdbool( rs_kpi-rate_percent <= iv_target_percent ).
    rs_kpi-value = value( iv_returned   = iv_returned
                          iv_unit_value = iv_unit_value ).
  ENDMETHOD.

ENDCLASS.
