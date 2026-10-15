CLASS zcl_so_stock_repository DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_so_stock_repository.
ENDCLASS.

CLASS zcl_so_stock_repository IMPLEMENTATION.

  METHOD zif_so_stock_repository~read_base_units_bulk.
    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

    SELECT material~matnr AS material,
           material~meins AS base_unit
      FROM mara AS material
      FOR ALL ENTRIES IN @it_requests
      WHERE material~matnr = @it_requests-material
      INTO CORRESPONDING FIELDS OF TABLE @rt_units.
  ENDMETHOD.

  METHOD zif_so_stock_repository~read_order_items_bulk.
    IF it_item_requests IS INITIAL.
      RETURN.
    ENDIF.

    SELECT vbeln AS sales_document,
           posnr AS item_number,
           matnr AS material,
           werks AS plant
      FROM vbap
      FOR ALL ENTRIES IN @it_item_requests
      WHERE vbeln = @it_item_requests-sales_document
        AND posnr = @it_item_requests-item_number
      INTO CORRESPONDING FIELDS OF TABLE @rt_items.
  ENDMETHOD.

  METHOD zif_so_stock_repository~read_stock_bulk.
    TYPES:
      BEGIN OF ty_plant_batch,
        material        TYPE mcha-matnr,
        plant           TYPE mcha-werks,
        batch           TYPE mcha-charg,
        expiration_date TYPE mcha-vfdat,
      END OF ty_plant_batch,
      ty_plant_batches TYPE HASHED TABLE OF ty_plant_batch
        WITH UNIQUE KEY material plant batch,
      BEGIN OF ty_global_batch,
        material        TYPE mch1-matnr,
        batch           TYPE mch1-charg,
        expiration_date TYPE mch1-vfdat,
      END OF ty_global_batch,
      ty_global_batches TYPE HASHED TABLE OF ty_global_batch
        WITH UNIQUE KEY material batch.
    DATA lt_plant_batches TYPE ty_plant_batches.
    DATA lt_global_batches TYPE ty_global_batches.

    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

    SELECT stock~kdauf AS sales_document,
           stock~kdpos AS item_number,
           stock~matnr AS material,
           stock~werks AS plant,
           stock~lgort AS storage_location,
           stock~charg AS batch,
           material~meins AS base_unit,
           stock~kalab AS quantity
      FROM mska AS stock
      INNER JOIN mara AS material
        ON material~matnr = stock~matnr
      FOR ALL ENTRIES IN @it_requests
      WHERE stock~sobkz = 'E'
        AND stock~kdauf = @it_requests-sales_document
        AND stock~kdpos = @it_requests-item_number
        AND stock~matnr = @it_requests-material
        AND stock~werks = @it_requests-plant
      INTO CORRESPONDING FIELDS OF TABLE @rt_rows.

    IF rt_rows IS INITIAL.
      RETURN.
    ENDIF.

    SELECT matnr AS material,
           werks AS plant,
           charg AS batch,
           vfdat AS expiration_date
      FROM mcha
      FOR ALL ENTRIES IN @rt_rows
      WHERE matnr = @rt_rows-material
        AND werks = @rt_rows-plant
        AND charg = @rt_rows-batch
        AND charg <> @space
      INTO CORRESPONDING FIELDS OF TABLE @lt_plant_batches.

    SELECT matnr AS material,
           charg AS batch,
           vfdat AS expiration_date
      FROM mch1
      FOR ALL ENTRIES IN @rt_rows
      WHERE matnr = @rt_rows-material
        AND charg = @rt_rows-batch
        AND charg <> @space
      INTO CORRESPONDING FIELDS OF TABLE @lt_global_batches.

    LOOP AT rt_rows ASSIGNING FIELD-SYMBOL(<ls_stock>).
      IF <ls_stock>-batch IS INITIAL.
        CONTINUE.
      ENDIF.

      READ TABLE lt_plant_batches INTO DATA(ls_plant_batch)
        WITH TABLE KEY material = <ls_stock>-material
                       plant = <ls_stock>-plant
                       batch = <ls_stock>-batch.
      IF sy-subrc = 0 AND ls_plant_batch-expiration_date IS NOT INITIAL.
        <ls_stock>-expiration_date = ls_plant_batch-expiration_date.
      ELSE.
        READ TABLE lt_global_batches INTO DATA(ls_global_batch)
          WITH TABLE KEY material = <ls_stock>-material
                         batch = <ls_stock>-batch.
        IF sy-subrc = 0.
          <ls_stock>-expiration_date = ls_global_batch-expiration_date.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_so_stock_repository~read_reservations_bulk.
    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

    SELECT kdauf AS sales_document,
           kdpos AS item_number,
           matnr AS material,
           werks AS plant,
           lgort AS storage_location,
           charg AS batch,
           rsnum AS reservation_number,
           rspos AS reservation_item,
           bdter AS required_date,
           bdmng AS required_quantity,
           enmng AS withdrawn_quantity,
           meins AS base_unit
      FROM resb
      FOR ALL ENTRIES IN @it_requests
      WHERE sobkz = 'E'
        AND xloek = @space
        AND kzear = @space
        AND kdauf = @it_requests-sales_document
        AND kdpos = @it_requests-item_number
        AND matnr = @it_requests-material
        AND werks = @it_requests-plant
      INTO CORRESPONDING FIELDS OF TABLE @rt_rows.

  ENDMETHOD.

ENDCLASS.
