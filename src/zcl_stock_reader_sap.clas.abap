CLASS zcl_stock_reader_sap DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_stock_reader.
ENDCLASS.

CLASS zcl_stock_reader_sap IMPLEMENTATION.
  METHOD zif_stock_reader~read_stock.
    DATA(ls_scope) = zcl_stock_snapshot_validator=>validate(
      it_requests       = it_requests
      it_stock_balances = VALUE #( ) ).
    IF ls_scope-is_valid = abap_false.
      rs_result-message = ls_scope-message.
      RETURN.
    ENDIF.

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
    IF sy-subrc <> 0 AND sy-subrc <> 4.
      rs_result-message = 'Stock read failed'.
      RETURN.
    ENDIF.

    DATA(ls_snapshot) = zcl_stock_snapshot_validator=>validate(
      it_requests       = it_requests
      it_stock_balances = rs_result-stock ).
    IF ls_snapshot-is_valid = abap_false.
      CLEAR rs_result-stock.
      rs_result-message = ls_snapshot-message.
      RETURN.
    ENDIF.

    rs_result-is_success = abap_true.
    rs_result-message = 'Stock read completed'.
  ENDMETHOD.
ENDCLASS.
