CLASS zcl_stock_reader DEFINITION PUBLIC FINAL CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_stock_reader.

ENDCLASS.


CLASS zcl_stock_reader IMPLEMENTATION.

  METHOD zif_stock_reader~read_available_stock.

    SELECT matnr,
           werks,
           lgort,
           labst AS available
      FROM mard
      WHERE matnr = @iv_matnr
        AND werks = @iv_werks
        AND lvorm = @space
      ORDER BY matnr, werks, lgort
      INTO TABLE @rt_stock.
    IF sy-subrc <> 0.
      CLEAR rt_stock.
    ENDIF.

  ENDMETHOD.

ENDCLASS.
