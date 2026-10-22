CLASS zcl_project_stock_repository DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_project_stock_repository.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_wbs_mapping,
        wbs_number  TYPE prps-pspnr,
        wbs_element TYPE zif_project_stock_repository=>ty_wbs_element,
      END OF ty_wbs_mapping.
    TYPES ty_wbs_mappings TYPE HASHED TABLE OF ty_wbs_mapping
      WITH UNIQUE KEY wbs_element.
    TYPES ty_wbs_number_mappings TYPE HASHED TABLE OF ty_wbs_mapping
      WITH UNIQUE KEY wbs_number.
    METHODS read_wbs_mappings
      IMPORTING
        it_wbs_elements    TYPE zif_project_stock_repository=>ty_wbs_elements
      RETURNING
        VALUE(rt_mappings) TYPE ty_wbs_mappings.
ENDCLASS.

CLASS zcl_project_stock_repository IMPLEMENTATION.

  METHOD read_wbs_mappings.
    TYPES:
      BEGIN OF ty_wbs_key,
        wbs_element TYPE zif_project_stock_repository=>ty_wbs_element,
      END OF ty_wbs_key,
      ty_wbs_keys TYPE SORTED TABLE OF ty_wbs_key
        WITH UNIQUE KEY wbs_element.
    DATA lt_wbs_keys TYPE ty_wbs_keys.

    LOOP AT it_wbs_elements INTO DATA(lv_wbs_element).
      INSERT VALUE #( wbs_element = lv_wbs_element )
        INTO TABLE lt_wbs_keys.
    ENDLOOP.

    IF lt_wbs_keys IS INITIAL.
      RETURN.
    ENDIF.

    SELECT pspnr AS wbs_number,
           posid AS wbs_element
      FROM prps
      FOR ALL ENTRIES IN @lt_wbs_keys
      WHERE posid = @lt_wbs_keys-wbs_element
      INTO TABLE @rt_mappings.
  ENDMETHOD.

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
    TYPES:
      BEGIN OF ty_stock_key,
        material    TYPE mspr-matnr,
        plant       TYPE mspr-werks,
        wbs_number  TYPE mspr-pspnr,
        wbs_element TYPE zif_project_stock_repository=>ty_wbs_element,
      END OF ty_stock_key,
      ty_stock_keys TYPE SORTED TABLE OF ty_stock_key
        WITH UNIQUE KEY material plant wbs_number.
    DATA lt_batch_stocks TYPE HASHED TABLE OF ty_batch_stock
      WITH UNIQUE KEY material plant batch.
    DATA lt_global_batches TYPE HASHED TABLE OF ty_global_batch
      WITH UNIQUE KEY material batch.
    DATA lt_wbs_elements TYPE zif_project_stock_repository=>ty_wbs_elements.
    DATA lt_wbs_mappings TYPE ty_wbs_mappings.
    DATA lt_stock_keys TYPE ty_stock_keys.
    DATA lt_mspr_rows TYPE STANDARD TABLE OF mspr WITH EMPTY KEY.

    IF it_keys IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_keys INTO DATA(ls_requested_key).
      APPEND ls_requested_key-wbs_element TO lt_wbs_elements.
    ENDLOOP.
    lt_wbs_mappings = read_wbs_mappings(
      it_wbs_elements = lt_wbs_elements ).

    LOOP AT it_keys INTO ls_requested_key.
      READ TABLE lt_wbs_mappings INTO DATA(ls_wbs_mapping)
        WITH TABLE KEY wbs_element = ls_requested_key-wbs_element.
      IF sy-subrc = 0.
        INSERT VALUE #(
          material    = ls_requested_key-material
          plant       = ls_requested_key-plant
          wbs_number  = ls_wbs_mapping-wbs_number
          wbs_element = ls_wbs_mapping-wbs_element )
          INTO TABLE lt_stock_keys.
      ENDIF.
    ENDLOOP.

    IF lt_stock_keys IS INITIAL.
      RETURN.
    ENDIF.

    SELECT matnr,
           werks,
           pspnr,
           lgort,
           charg,
           prlab
      FROM mspr
      FOR ALL ENTRIES IN @lt_stock_keys
      WHERE matnr = @lt_stock_keys-material
        AND werks = @lt_stock_keys-plant
        AND pspnr = @lt_stock_keys-wbs_number
        AND sobkz = 'Q'
        AND prlab > 0
      INTO CORRESPONDING FIELDS OF TABLE @lt_mspr_rows.

    LOOP AT lt_mspr_rows INTO DATA(ls_mspr_row).
      READ TABLE lt_stock_keys INTO DATA(ls_stock_key)
        WITH TABLE KEY material = ls_mspr_row-matnr
                       plant = ls_mspr_row-werks
                       wbs_number = ls_mspr_row-pspnr.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      APPEND VALUE #(
        material              = ls_mspr_row-matnr
        plant                 = ls_mspr_row-werks
        wbs_element           = ls_stock_key-wbs_element
        storage_location      = ls_mspr_row-lgort
        batch                 = ls_mspr_row-charg
        unrestricted_quantity = ls_mspr_row-prlab )
        TO rt_stocks.
    ENDLOOP.

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
    DATA lt_wbs_mappings TYPE ty_wbs_mappings.
    DATA lt_wbs_number_mappings TYPE ty_wbs_number_mappings.
    DATA lt_mspr_rows TYPE STANDARD TABLE OF mspr WITH EMPTY KEY.

    IF it_wbs_elements IS INITIAL.
      RETURN.
    ENDIF.

    lt_wbs_mappings = read_wbs_mappings(
      it_wbs_elements = it_wbs_elements ).
    IF lt_wbs_mappings IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT lt_wbs_mappings INTO DATA(ls_wbs_mapping_by_number).
      INSERT ls_wbs_mapping_by_number INTO TABLE lt_wbs_number_mappings.
    ENDLOOP.

    SELECT matnr,
           werks,
           pspnr,
           lgort,
           charg,
           prlab
      FROM mspr
      FOR ALL ENTRIES IN @lt_wbs_number_mappings
      WHERE pspnr = @lt_wbs_number_mappings-wbs_number
        AND sobkz = 'Q'
        AND prlab > 0
      INTO CORRESPONDING FIELDS OF TABLE @lt_mspr_rows.

    LOOP AT lt_mspr_rows INTO DATA(ls_mspr_row).
      READ TABLE lt_wbs_number_mappings INTO DATA(ls_wbs_mapping)
        WITH TABLE KEY wbs_number = ls_mspr_row-pspnr.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      APPEND VALUE #(
        material              = ls_mspr_row-matnr
        plant                 = ls_mspr_row-werks
        wbs_element           = ls_wbs_mapping-wbs_element
        storage_location      = ls_mspr_row-lgort
        batch                 = ls_mspr_row-charg
        unrestricted_quantity = ls_mspr_row-prlab )
        TO rt_stocks.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_project_stock_repository~read_project_reservations.
    TYPES:
      BEGIN OF ty_reservation_key,
        material    TYPE resb-matnr,
        plant       TYPE resb-werks,
        wbs_number  TYPE resb-pspel,
        wbs_element TYPE zif_project_stock_repository=>ty_wbs_element,
      END OF ty_reservation_key,
      ty_reservation_keys TYPE SORTED TABLE OF ty_reservation_key
        WITH UNIQUE KEY material plant wbs_number.
    DATA lt_wbs_elements TYPE zif_project_stock_repository=>ty_wbs_elements.
    DATA lt_wbs_mappings TYPE ty_wbs_mappings.
    DATA lt_reservation_keys TYPE ty_reservation_keys.
    DATA lt_resb_rows TYPE STANDARD TABLE OF resb WITH EMPTY KEY.
    DATA lv_open_quantity TYPE resb-bdmng.
    DATA lv_initial_required_date TYPE resb-bdter.

    IF it_keys IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_keys INTO DATA(ls_requested_key).
      APPEND ls_requested_key-wbs_element TO lt_wbs_elements.
    ENDLOOP.
    lt_wbs_mappings = read_wbs_mappings(
      it_wbs_elements = lt_wbs_elements ).

    LOOP AT it_keys INTO ls_requested_key.
      READ TABLE lt_wbs_mappings INTO DATA(ls_wbs_mapping)
        WITH TABLE KEY wbs_element = ls_requested_key-wbs_element.
      IF sy-subrc = 0.
        INSERT VALUE #(
          material    = ls_requested_key-material
          plant       = ls_requested_key-plant
          wbs_number  = ls_wbs_mapping-wbs_number
          wbs_element = ls_wbs_mapping-wbs_element )
          INTO TABLE lt_reservation_keys.
      ENDIF.
    ENDLOOP.

    IF lt_reservation_keys IS INITIAL.
      RETURN.
    ENDIF.

    SELECT rsnum,
           rspos,
           matnr,
           werks,
           pspel,
           lgort,
           charg,
           bdter,
           meins,
           erfme,
           bdmng,
           enmng
      FROM resb
      FOR ALL ENTRIES IN @lt_reservation_keys
      WHERE matnr = @lt_reservation_keys-material
        AND werks = @lt_reservation_keys-plant
        AND pspel = @lt_reservation_keys-wbs_number
        AND sobkz = 'Q'
        AND xloek = @space
        AND kzear = @space
        AND ( @iv_required_through_date = @lv_initial_required_date
          OR bdter = @lv_initial_required_date
          OR bdter <= @iv_required_through_date )
      INTO CORRESPONDING FIELDS OF TABLE @lt_resb_rows.

    LOOP AT lt_resb_rows INTO DATA(ls_resb_row).
      READ TABLE lt_reservation_keys INTO DATA(ls_reservation_key)
        WITH TABLE KEY material = ls_resb_row-matnr
                       plant = ls_resb_row-werks
                       wbs_number = ls_resb_row-pspel.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      lv_open_quantity = zcl_stock_avail_qty_calc=>calculate_open_res_qty(
        iv_required_quantity  = ls_resb_row-bdmng
        iv_withdrawn_quantity = ls_resb_row-enmng ).
      IF lv_open_quantity <= 0.
        CONTINUE.
      ENDIF.

      APPEND VALUE #(
        reservation_number = ls_resb_row-rsnum
        reservation_item   = ls_resb_row-rspos
        material           = ls_resb_row-matnr
        plant              = ls_resb_row-werks
        wbs_element        = ls_reservation_key-wbs_element
        storage_location   = ls_resb_row-lgort
        batch              = ls_resb_row-charg
        required_date      = ls_resb_row-bdter
        unit               = ls_resb_row-meins
        entry_unit         = ls_resb_row-erfme
        required_quantity  = ls_resb_row-bdmng
        withdrawn_quantity = ls_resb_row-enmng
        open_quantity      = lv_open_quantity )
        TO rt_reservations.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_project_stock_repository~read_project_reservations_wbs.
    DATA lt_wbs_mappings TYPE ty_wbs_mappings.
    DATA lt_wbs_number_mappings TYPE ty_wbs_number_mappings.
    DATA lt_resb_rows TYPE STANDARD TABLE OF resb WITH EMPTY KEY.
    DATA lv_open_quantity TYPE resb-bdmng.
    DATA lv_initial_required_date TYPE resb-bdter.

    IF it_wbs_elements IS INITIAL.
      RETURN.
    ENDIF.

    lt_wbs_mappings = read_wbs_mappings(
      it_wbs_elements = it_wbs_elements ).
    IF lt_wbs_mappings IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT lt_wbs_mappings INTO DATA(ls_wbs_mapping_by_number).
      INSERT ls_wbs_mapping_by_number INTO TABLE lt_wbs_number_mappings.
    ENDLOOP.

    SELECT rsnum,
           rspos,
           matnr,
           werks,
           pspel,
           lgort,
           charg,
           bdter,
           meins,
           erfme,
           bdmng,
           enmng
      FROM resb
      FOR ALL ENTRIES IN @lt_wbs_number_mappings
      WHERE pspel = @lt_wbs_number_mappings-wbs_number
        AND sobkz = 'Q'
        AND xloek = @space
        AND kzear = @space
        AND ( @iv_required_through_date = @lv_initial_required_date
          OR bdter = @lv_initial_required_date
          OR bdter <= @iv_required_through_date )
      INTO CORRESPONDING FIELDS OF TABLE @lt_resb_rows.

    LOOP AT lt_resb_rows INTO DATA(ls_resb_row).
      READ TABLE lt_wbs_number_mappings INTO DATA(ls_wbs_mapping)
        WITH TABLE KEY wbs_number = ls_resb_row-pspel.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      lv_open_quantity = zcl_stock_avail_qty_calc=>calculate_open_res_qty(
        iv_required_quantity  = ls_resb_row-bdmng
        iv_withdrawn_quantity = ls_resb_row-enmng ).
      IF lv_open_quantity <= 0.
        CONTINUE.
      ENDIF.

      APPEND VALUE #(
        reservation_number = ls_resb_row-rsnum
        reservation_item   = ls_resb_row-rspos
        material           = ls_resb_row-matnr
        plant              = ls_resb_row-werks
        wbs_element        = ls_wbs_mapping-wbs_element
        storage_location   = ls_resb_row-lgort
        batch              = ls_resb_row-charg
        required_date      = ls_resb_row-bdter
        unit               = ls_resb_row-meins
        entry_unit         = ls_resb_row-erfme
        required_quantity  = ls_resb_row-bdmng
        withdrawn_quantity = ls_resb_row-enmng
        open_quantity      = lv_open_quantity )
        TO rt_reservations.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_project_stock_repository~read_project_resv_items_wbs.
    DATA lt_wbs_mappings TYPE ty_wbs_mappings.
    DATA lt_wbs_number_mappings TYPE ty_wbs_number_mappings.
    DATA lt_resb_rows TYPE STANDARD TABLE OF resb WITH EMPTY KEY.

    IF it_wbs_elements IS INITIAL.
      RETURN.
    ENDIF.

    lt_wbs_mappings = read_wbs_mappings(
      it_wbs_elements = it_wbs_elements ).
    IF lt_wbs_mappings IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT lt_wbs_mappings INTO DATA(ls_wbs_mapping_by_number).
      INSERT ls_wbs_mapping_by_number INTO TABLE lt_wbs_number_mappings.
    ENDLOOP.

    SELECT rsnum,
           rspos,
           matnr,
           werks,
           pspel,
           lgort,
           charg,
           bdter,
           meins,
           erfme,
           bdmng,
           enmng,
           kzear
      FROM resb
      FOR ALL ENTRIES IN @lt_wbs_number_mappings
      WHERE pspel = @lt_wbs_number_mappings-wbs_number
        AND sobkz = 'Q'
        AND xloek = @space
      INTO CORRESPONDING FIELDS OF TABLE @lt_resb_rows.

    LOOP AT lt_resb_rows INTO DATA(ls_resb_row).
      READ TABLE lt_wbs_number_mappings INTO DATA(ls_wbs_mapping)
        WITH TABLE KEY wbs_number = ls_resb_row-pspel.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      APPEND VALUE #(
        reservation_number = ls_resb_row-rsnum
        reservation_item   = ls_resb_row-rspos
        material           = ls_resb_row-matnr
        plant              = ls_resb_row-werks
        wbs_element        = ls_wbs_mapping-wbs_element
        storage_location   = ls_resb_row-lgort
        batch              = ls_resb_row-charg
        required_date      = ls_resb_row-bdter
        unit               = ls_resb_row-meins
        entry_unit         = ls_resb_row-erfme
        required_quantity  = ls_resb_row-bdmng
        withdrawn_quantity = ls_resb_row-enmng
        is_final_issue     = ls_resb_row-kzear )
        TO rt_reservations.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
