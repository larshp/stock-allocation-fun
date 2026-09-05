CLASS zcl_stock_source_sap DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_stock_source.
ENDCLASS.

CLASS zcl_stock_source_sap IMPLEMENTATION.
  METHOD zif_stock_source~read.
    IF requests IS INITIAL.
      RETURN.
    ENDIF.
    DATA(keys) = requests.
    SORT keys BY material plant storage.
    DELETE ADJACENT DUPLICATES FROM keys COMPARING material plant storage.
    LOOP AT keys INTO DATA(request).
      DATA(stock) = VALUE zif_stock_alloc_types=>ty_stock(
        material = request-material
        plant    = request-plant
        storage  = request-storage ).
      SELECT SINGLE labst FROM mard
        WHERE matnr = @request-material
          AND werks = @request-plant
          AND lgort = @request-storage
          AND lvorm = @space
        INTO @stock-quantity.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      SELECT SINGLE meins FROM mara
        WHERE matnr = @request-material
        INTO @stock-unit.
      IF sy-subrc <> 0 OR stock-unit IS INITIAL.
        RAISE EXCEPTION TYPE zcx_stock_alloc
          EXPORTING reason = |Missing base unit for material { stock-material }|.
      ENDIF.
      " Negative stock can exist in SAP, but cannot supply an allocation.
      IF stock-quantity < 0.
        stock-quantity = 0.
      ENDIF.
      APPEND stock TO stocks.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
