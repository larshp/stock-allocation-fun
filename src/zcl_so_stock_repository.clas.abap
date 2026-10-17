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

    SELECT matnr AS material,
           meins AS base_unit
      FROM mara
      FOR ALL ENTRIES IN @it_requests
      WHERE matnr = @it_requests-material
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
        WITH UNIQUE KEY material batch,
      BEGIN OF ty_material_key,
        material TYPE mara-matnr,
      END OF ty_material_key,
      ty_material_keys TYPE SORTED TABLE OF ty_material_key
        WITH UNIQUE KEY material,
      BEGIN OF ty_material_unit,
        material  TYPE mara-matnr,
        base_unit TYPE mara-meins,
      END OF ty_material_unit,
      ty_material_units TYPE HASHED TABLE OF ty_material_unit
        WITH UNIQUE KEY material.
    DATA lt_plant_batches TYPE ty_plant_batches.
    DATA lt_global_batches TYPE ty_global_batches.
    DATA lt_material_keys TYPE ty_material_keys.
    DATA lt_material_units TYPE ty_material_units.
    DATA lt_valid_rows TYPE zif_so_stock_repository=>ty_stock_rows.

    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

    SELECT kdauf AS sales_document,
           kdpos AS item_number,
           matnr AS material,
           werks AS plant,
           lgort AS storage_location,
           charg AS batch,
           kalab AS quantity
      FROM mska
      FOR ALL ENTRIES IN @it_requests
      WHERE sobkz = 'E'
        AND kdauf = @it_requests-sales_document
        AND kdpos = @it_requests-item_number
        AND matnr = @it_requests-material
        AND werks = @it_requests-plant
      INTO CORRESPONDING FIELDS OF TABLE @rt_rows.

    IF rt_rows IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT rt_rows INTO DATA(ls_stock_candidate).
      INSERT VALUE #( material = ls_stock_candidate-material )
        INTO TABLE lt_material_keys.
    ENDLOOP.

    SELECT matnr AS material,
           meins AS base_unit
      FROM mara
      FOR ALL ENTRIES IN @lt_material_keys
      WHERE matnr = @lt_material_keys-material
      INTO TABLE @lt_material_units.

    LOOP AT rt_rows INTO DATA(ls_stock_row).
      READ TABLE lt_material_units INTO DATA(ls_material_unit)
        WITH TABLE KEY material = ls_stock_row-material.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      ls_stock_row-base_unit = ls_material_unit-base_unit.
      APPEND ls_stock_row TO lt_valid_rows.
    ENDLOOP.
    rt_rows = lt_valid_rows.

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
