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
      rs_result-is_success = abap_true.
      rs_result-message = 'Stock read completed'.
      RETURN.
    ENDIF.

    SELECT storage_stock~matnr AS material,
           storage_stock~werks AS plant,
           storage_stock~lgort AS storage_location,
           material_master~meins AS base_unit,
           storage_stock~labst AS unrestricted_qty,
           plant_stock~eisbe AS safety_stock_qty
      FROM mard AS storage_stock
      INNER JOIN marc AS plant_stock
        ON plant_stock~matnr = storage_stock~matnr
        AND plant_stock~werks = storage_stock~werks
      INNER JOIN mara AS material_master
        ON material_master~matnr = storage_stock~matnr
      FOR ALL ENTRIES IN @it_requests
      WHERE storage_stock~matnr = @it_requests-material
        AND storage_stock~werks = @it_requests-plant
      INTO CORRESPONDING FIELDS OF TABLE @rs_result-stock.
    IF sy-subrc = 0 OR sy-subrc = 4.
      rs_result-is_success = abap_true.
      rs_result-message = 'Stock read completed'.
    ELSE.
      rs_result-message = 'Stock read failed'.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
