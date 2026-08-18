CLASS zcl_stock_reader_sap DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_stock_reader.
ENDCLASS.

CLASS zcl_stock_reader_sap IMPLEMENTATION.
  METHOD zif_stock_reader~read_stock.
    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

    SELECT storage_stock~matnr AS material,
           storage_stock~werks AS plant,
           storage_stock~lgort AS storage_location,
           storage_stock~labst AS unrestricted_qty,
           plant_stock~eisbe AS safety_stock_qty
      FROM mard AS storage_stock
      INNER JOIN marc AS plant_stock
        ON plant_stock~matnr = storage_stock~matnr
        AND plant_stock~werks = storage_stock~werks
      FOR ALL ENTRIES IN @it_requests
      WHERE storage_stock~matnr = @it_requests-material
        AND storage_stock~werks = @it_requests-plant
        AND storage_stock~lgort = @it_requests-storage_location
      INTO CORRESPONDING FIELDS OF TABLE @rt_stock.
  ENDMETHOD.
ENDCLASS.
