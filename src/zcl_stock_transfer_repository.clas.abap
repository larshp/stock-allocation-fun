CLASS zcl_stock_transfer_repository DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_stock_transfer_repository.
ENDCLASS.

CLASS zcl_stock_transfer_repository IMPLEMENTATION.

  METHOD zif_stock_transfer_repository~get_stock_in_transfer.
    DATA lv_plant_quantity TYPE marc-umlmc.
    DATA lv_location_quantity TYPE mard-umlme.

    SELECT SUM( umlmc )
      FROM marc
      WHERE matnr = @iv_material
        AND werks = @iv_plant
      INTO @lv_plant_quantity.

    IF iv_storage_location IS INITIAL.
      SELECT SUM( umlme )
        FROM mard
        WHERE matnr = @iv_material
          AND werks = @iv_plant
        INTO @lv_location_quantity.
    ELSE.
      SELECT SINGLE umlme
        FROM mard
        WHERE matnr = @iv_material
          AND werks = @iv_plant
          AND lgort = @iv_storage_location
        INTO @lv_location_quantity.
    ENDIF.

    rs_balance-plant_transfer_quantity = lv_plant_quantity.
    rs_balance-sloc_transfer_quantity = lv_location_quantity.
  ENDMETHOD.

  METHOD zif_stock_transfer_repository~get_stock_in_transfer_bulk.
    TYPES:
      BEGIN OF ty_plant_row,
        material                TYPE marc-matnr,
        plant                   TYPE marc-werks,
        plant_transfer_quantity TYPE marc-umlmc,
      END OF ty_plant_row,
      ty_plant_rows TYPE STANDARD TABLE OF ty_plant_row WITH EMPTY KEY,
      ty_plant_totals TYPE HASHED TABLE OF ty_plant_row
        WITH UNIQUE KEY material plant,
      BEGIN OF ty_location_row,
        material               TYPE mard-matnr,
        plant                  TYPE mard-werks,
        storage_location       TYPE mard-lgort,
        sloc_transfer_quantity TYPE mard-umlme,
      END OF ty_location_row,
      ty_location_rows TYPE STANDARD TABLE OF ty_location_row
        WITH EMPTY KEY.
    DATA lt_plant_rows TYPE ty_plant_rows.
    DATA lt_plant_totals TYPE ty_plant_totals.
    DATA lt_location_rows TYPE ty_location_rows.

    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

    SELECT matnr AS material,
           werks AS plant,
           umlmc AS plant_transfer_quantity
      FROM marc
      FOR ALL ENTRIES IN @it_requests
      WHERE matnr = @it_requests-material
        AND werks = @it_requests-plant
      INTO CORRESPONDING FIELDS OF TABLE @lt_plant_rows.

    LOOP AT lt_plant_rows INTO DATA(ls_plant_row).
      INSERT ls_plant_row INTO TABLE lt_plant_totals.
    ENDLOOP.

    SELECT matnr AS material,
           werks AS plant,
           lgort AS storage_location,
           umlme AS sloc_transfer_quantity
      FROM mard
      FOR ALL ENTRIES IN @it_requests
      WHERE matnr = @it_requests-material
        AND werks = @it_requests-plant
      INTO CORRESPONDING FIELDS OF TABLE @lt_location_rows.

    LOOP AT it_requests INTO DATA(ls_request).
      DATA(lv_plant_quantity) = CONV marc-umlmc( 0 ).
      DATA(lv_location_quantity) = CONV mard-umlme( 0 ).
      READ TABLE lt_plant_totals INTO DATA(ls_plant_total)
        WITH TABLE KEY material = ls_request-material
                       plant = ls_request-plant.
      IF sy-subrc = 0.
        lv_plant_quantity = ls_plant_total-plant_transfer_quantity.
      ENDIF.

      LOOP AT lt_location_rows INTO DATA(ls_location_row)
          WHERE material = ls_request-material
            AND plant = ls_request-plant.
        IF ls_request-storage_location IS INITIAL
            OR ls_location_row-storage_location
              = ls_request-storage_location.
          lv_location_quantity +=
            ls_location_row-sloc_transfer_quantity.
        ENDIF.
      ENDLOOP.

      APPEND VALUE #(
        request_id              = ls_request-request_id
        material                = ls_request-material
        plant                   = ls_request-plant
        storage_location        = ls_request-storage_location
        plant_transfer_quantity = lv_plant_quantity
        sloc_transfer_quantity  = lv_location_quantity )
        TO rt_results.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_stock_transfer_repository~get_transfer_locations_bulk.
    TYPES:
      BEGIN OF ty_location_row,
        material          TYPE mard-matnr,
        plant             TYPE mard-werks,
        storage_location  TYPE mard-lgort,
        transfer_quantity TYPE mard-umlme,
      END OF ty_location_row,
      ty_location_rows TYPE STANDARD TABLE OF ty_location_row WITH EMPTY KEY.
    DATA lt_location_rows TYPE ty_location_rows.

    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

    SELECT matnr AS material,
           werks AS plant,
           lgort AS storage_location,
           umlme AS transfer_quantity
      FROM mard
      FOR ALL ENTRIES IN @it_requests
      WHERE matnr = @it_requests-material
        AND werks = @it_requests-plant
        AND umlme <> 0
      INTO CORRESPONDING FIELDS OF TABLE @lt_location_rows.

    SORT lt_location_rows BY material plant storage_location.
    LOOP AT it_requests INTO DATA(ls_request).
      LOOP AT lt_location_rows INTO DATA(ls_location_row)
          WHERE material = ls_request-material
            AND plant = ls_request-plant.
        APPEND VALUE #(
          request_id        = ls_request-request_id
          material          = ls_request-material
          plant             = ls_request-plant
          storage_location  = ls_location_row-storage_location
          transfer_quantity = ls_location_row-transfer_quantity )
          TO rt_results.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_stock_transfer_repository~get_transfer_batches_bulk.
    TYPES:
      BEGIN OF ty_batch_row,
        material          TYPE mchb-matnr,
        plant             TYPE mchb-werks,
        storage_location  TYPE mchb-lgort,
        batch             TYPE mchb-charg,
        transfer_quantity TYPE mchb-cumlm,
      END OF ty_batch_row,
      ty_batch_rows TYPE STANDARD TABLE OF ty_batch_row WITH EMPTY KEY.
    DATA lt_batch_rows TYPE ty_batch_rows.

    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

    SELECT matnr AS material,
           werks AS plant,
           lgort AS storage_location,
           charg AS batch,
           cumlm AS transfer_quantity
      FROM mchb
      FOR ALL ENTRIES IN @it_requests
      WHERE matnr = @it_requests-material
        AND werks = @it_requests-plant
        AND cumlm <> 0
      INTO CORRESPONDING FIELDS OF TABLE @lt_batch_rows.

    SORT lt_batch_rows BY material plant storage_location batch.
    LOOP AT it_requests INTO DATA(ls_request).
      LOOP AT lt_batch_rows INTO DATA(ls_batch_row)
          WHERE material = ls_request-material
            AND plant = ls_request-plant.
        APPEND VALUE #(
          request_id        = ls_request-request_id
          material          = ls_request-material
          plant             = ls_request-plant
          storage_location  = ls_batch_row-storage_location
          batch             = ls_batch_row-batch
          transfer_quantity = ls_batch_row-transfer_quantity )
          TO rt_results.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_stock_transfer_repository~get_stock_in_transfer_by_batch.
    SELECT lgort AS storage_location,
           charg AS batch,
           cumlm AS transfer_quantity
      FROM mchb
      WHERE matnr = @iv_material
        AND werks = @iv_plant
        AND cumlm <> 0
      ORDER BY lgort, charg
      INTO TABLE @rt_balances.
  ENDMETHOD.

ENDCLASS.
