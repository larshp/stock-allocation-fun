CLASS zcl_stock_alloc_date DEFINITION PUBLIC FINAL CREATE PRIVATE.
  PUBLIC SECTION.
    CLASS-METHODS validate
      IMPORTING date TYPE d
      RAISING   zcx_stock_alloc.
ENDCLASS.

CLASS zcl_stock_alloc_date IMPLEMENTATION.
  METHOD validate.
    IF date IS INITIAL OR date CN '0123456789'.
      RAISE EXCEPTION TYPE zcx_stock_alloc
        EXPORTING reason = |Invalid calendar date { date }|.
    ENDIF.
    DATA(year) = CONV i( date(4) ).
    DATA(month) = CONV i( date+4(2) ).
    DATA(day) = CONV i( date+6(2) ).
    DATA days TYPE i VALUE 31.
    IF year = 0 OR month < 1 OR month > 12 OR day < 1.
      RAISE EXCEPTION TYPE zcx_stock_alloc
        EXPORTING reason = |Invalid calendar date { date }|.
    ENDIF.
    CASE month.
      WHEN 4 OR 6 OR 9 OR 11.
        days = 30.
      WHEN 2.
        days = 28.
        IF year MOD 400 = 0 OR ( year MOD 4 = 0 AND year MOD 100 <> 0 ).
          days = 29.
        ENDIF.
    ENDCASE.
    IF day > days.
      RAISE EXCEPTION TYPE zcx_stock_alloc
        EXPORTING reason = |Invalid calendar date { date }|.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
