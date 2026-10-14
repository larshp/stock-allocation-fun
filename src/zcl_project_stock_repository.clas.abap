CLASS zcl_project_stock_repository DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_project_stock_repository.
ENDCLASS.

CLASS zcl_project_stock_repository IMPLEMENTATION.

  METHOD zif_project_stock_repository~read_project_stocks.
    TYPES:
      BEGIN OF ty_batch_stock,
        material        TYPE mcha-matnr,
        plant           TYPE mcha-werks,
        batch           TYPE mcha-charg,
        expiration_date TYPE mcha-vfdat,
      END OF ty_batch_stock.
    TYPES:
      BEGIN OF ty_global_batch,
        material        TYPE mch1-matnr,
        batch           TYPE mch1-charg,
        expiration_date TYPE mch1-vfdat,
      END OF ty_global_batch.
    DATA lt_batch_stocks TYPE HASHED TABLE OF ty_batch_stock
      WITH UNIQUE KEY material plant batch.
    DATA lt_global_batches TYPE HASHED TABLE OF ty_global_batch
      WITH UNIQUE KEY material batch.

    IF it_keys IS INITIAL.
      RETURN.
    ENDIF.

    SELECT stock~matnr AS material,
           stock~werks AS plant,
           wbs~posid AS wbs_element,
           stock~lgort AS storage_location,
           stock~charg AS batch,
           stock~prlab AS unrestricted_quantity
      FROM mspr AS stock
      INNER JOIN prps AS wbs
        ON wbs~pspnr = stock~pspnr
      FOR ALL ENTRIES IN @it_keys
      WHERE stock~matnr = @it_keys-material
        AND stock~werks = @it_keys-plant
        AND stock~sobkz = 'Q'
        AND wbs~posid = @it_keys-wbs_element
        AND stock~prlab > 0
      INTO CORRESPONDING FIELDS OF TABLE @rt_stocks.

    IF rt_stocks IS INITIAL.
      RETURN.
    ENDIF.

    SELECT matnr AS material,
           werks AS plant,
           charg AS batch,
           vfdat AS expiration_date
      FROM mcha
      FOR ALL ENTRIES IN @rt_stocks
      WHERE matnr = @rt_stocks-material
        AND werks = @rt_stocks-plant
        AND charg = @rt_stocks-batch
      INTO CORRESPONDING FIELDS OF TABLE @lt_batch_stocks.

    SELECT matnr AS material,
           charg AS batch,
           vfdat AS expiration_date
      FROM mch1
      FOR ALL ENTRIES IN @rt_stocks
      WHERE matnr = @rt_stocks-material
        AND charg = @rt_stocks-batch
      INTO CORRESPONDING FIELDS OF TABLE @lt_global_batches.

    LOOP AT rt_stocks ASSIGNING FIELD-SYMBOL(<ls_stock>).
      READ TABLE lt_batch_stocks INTO DATA(ls_batch_stock)
        WITH TABLE KEY material = <ls_stock>-material
                       plant = <ls_stock>-plant
                       batch = <ls_stock>-batch.
      IF sy-subrc = 0 AND ls_batch_stock-expiration_date IS NOT INITIAL.
        <ls_stock>-expiration_date = ls_batch_stock-expiration_date.
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

  METHOD zif_project_stock_repository~read_project_stocks_wbs.
    IF it_wbs_elements IS INITIAL.
      RETURN.
    ENDIF.

    SELECT stock~matnr AS material,
           stock~werks AS plant,
           wbs~posid AS wbs_element,
           stock~lgort AS storage_location,
           stock~charg AS batch,
           stock~prlab AS unrestricted_quantity
      FROM mspr AS stock
      INNER JOIN prps AS wbs
        ON wbs~pspnr = stock~pspnr
      FOR ALL ENTRIES IN @it_wbs_elements
      WHERE stock~sobkz = 'Q'
        AND stock~prlab > 0
        AND wbs~posid = @it_wbs_elements-table_line
      INTO CORRESPONDING FIELDS OF TABLE @rt_stocks.
  ENDMETHOD.

  METHOD zif_project_stock_repository~read_project_reservations.
    IF it_keys IS INITIAL.
      RETURN.
    ENDIF.

    SELECT reservation~matnr AS material,
           reservation~rsnum AS reservation_number,
           reservation~rspos AS reservation_item,
           reservation~werks AS plant,
           wbs~posid AS wbs_element,
           reservation~lgort AS storage_location,
           reservation~charg AS batch,
           reservation~bdter AS required_date,
           reservation~meins AS unit,
           reservation~erfme AS entry_unit,
           reservation~bdmng AS required_quantity,
           reservation~enmng AS withdrawn_quantity
      FROM resb AS reservation
      INNER JOIN prps AS wbs
        ON wbs~pspnr = reservation~pspel
      FOR ALL ENTRIES IN @it_keys
      WHERE reservation~matnr = @it_keys-material
        AND reservation~werks = @it_keys-plant
        AND reservation~sobkz = 'Q'
        AND reservation~xloek = @space
        AND reservation~kzear = @space
        AND reservation~bdmng > reservation~enmng
        AND wbs~posid = @it_keys-wbs_element
      INTO CORRESPONDING FIELDS OF TABLE @rt_reservations.

    LOOP AT rt_reservations ASSIGNING FIELD-SYMBOL(<ls_reservation>).
      <ls_reservation>-open_quantity =
        <ls_reservation>-required_quantity
        - <ls_reservation>-withdrawn_quantity.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_project_stock_repository~read_project_reservations_wbs.
    IF it_wbs_elements IS INITIAL.
      RETURN.
    ENDIF.

    SELECT reservation~rsnum AS reservation_number,
           reservation~rspos AS reservation_item,
           reservation~matnr AS material,
           reservation~werks AS plant,
           wbs~posid AS wbs_element,
           reservation~lgort AS storage_location,
           reservation~charg AS batch,
           reservation~bdter AS required_date,
           reservation~meins AS unit,
           reservation~erfme AS entry_unit,
           reservation~bdmng AS required_quantity,
           reservation~enmng AS withdrawn_quantity
      FROM resb AS reservation
      INNER JOIN prps AS wbs
        ON wbs~pspnr = reservation~pspel
      FOR ALL ENTRIES IN @it_wbs_elements
      WHERE reservation~sobkz = 'Q'
        AND reservation~xloek = @space
        AND reservation~kzear = @space
        AND reservation~bdmng > reservation~enmng
        AND wbs~posid = @it_wbs_elements-table_line
      INTO CORRESPONDING FIELDS OF TABLE @rt_reservations.

    LOOP AT rt_reservations ASSIGNING FIELD-SYMBOL(<ls_reservation>).
      <ls_reservation>-open_quantity =
        <ls_reservation>-required_quantity
        - <ls_reservation>-withdrawn_quantity.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_project_stock_repository~read_project_resv_items_wbs.
    IF it_wbs_elements IS INITIAL.
      RETURN.
    ENDIF.

    SELECT reservation~rsnum AS reservation_number,
           reservation~rspos AS reservation_item,
           reservation~matnr AS material,
           reservation~werks AS plant,
           wbs~posid AS wbs_element,
           reservation~lgort AS storage_location,
           reservation~charg AS batch,
           reservation~bdter AS required_date,
           reservation~meins AS unit,
           reservation~erfme AS entry_unit,
           reservation~bdmng AS required_quantity,
           reservation~enmng AS withdrawn_quantity,
           reservation~kzear AS is_final_issue
      FROM resb AS reservation
      INNER JOIN prps AS wbs
        ON wbs~pspnr = reservation~pspel
      FOR ALL ENTRIES IN @it_wbs_elements
      WHERE reservation~sobkz = 'Q'
        AND reservation~xloek = @space
        AND wbs~posid = @it_wbs_elements-table_line
      INTO CORRESPONDING FIELDS OF TABLE @rt_reservations.
  ENDMETHOD.

ENDCLASS.
