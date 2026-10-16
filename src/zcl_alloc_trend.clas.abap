CLASS zcl_alloc_trend DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_qty_tt TYPE STANDARD TABLE OF menge_d WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_trend,
             count      TYPE i,
             first_qty  TYPE menge_d,
             last_qty   TYPE menge_d,
             change_pct TYPE i,
             direction  TYPE c LENGTH 1,
           END OF ty_trend.

    METHODS analyze
      IMPORTING
        it_quantities   TYPE ty_qty_tt
      RETURNING
        VALUE(rs_trend) TYPE ty_trend.

ENDCLASS.


CLASS zcl_alloc_trend IMPLEMENTATION.

  METHOD analyze.
    DATA lv_count TYPE i.

    lv_count = lines( it_quantities ).
    rs_trend-count = lv_count.

    IF lv_count = 0.
      rs_trend-direction = 'F'.
      RETURN.
    ENDIF.

    READ TABLE it_quantities INTO rs_trend-first_qty INDEX 1.
    READ TABLE it_quantities INTO rs_trend-last_qty INDEX lv_count.

    IF rs_trend-first_qty > 0.
      rs_trend-change_pct = ( rs_trend-last_qty - rs_trend-first_qty )
        * 100 DIV rs_trend-first_qty.
    ENDIF.

    IF rs_trend-last_qty > rs_trend-first_qty.
      rs_trend-direction = 'U'.
    ELSEIF rs_trend-last_qty < rs_trend-first_qty.
      rs_trend-direction = 'D'.
    ELSE.
      rs_trend-direction = 'F'.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
