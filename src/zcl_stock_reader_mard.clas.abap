CLASS zcl_stock_reader_mard DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_stock_reader.
ENDCLASS.

CLASS zcl_stock_reader_mard IMPLEMENTATION.
  METHOD zif_stock_reader~read_stock.
    IF iv_material IS INITIAL OR iv_plant IS INITIAL.
      RETURN.
    ENDIF.
    SELECT * FROM mard
      WHERE mandt = @sy-mandt AND matnr = @iv_material AND werks = @iv_plant AND labst > 0
      ORDER BY PRIMARY KEY
      INTO TABLE @rt_stock.
  ENDMETHOD.
ENDCLASS.
