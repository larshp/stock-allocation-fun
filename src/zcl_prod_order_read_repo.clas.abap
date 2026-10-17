CLASS zcl_prod_order_read_repo DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_prod_order_read_repo.
ENDCLASS.

CLASS zcl_prod_order_read_repo IMPLEMENTATION.

  METHOD zif_prod_order_read_repo~read_orders.
    TYPES:
      BEGIN OF ty_order_item_data,
        aufnr TYPE afpo-aufnr,
        posnr TYPE afpo-posnr,
        matnr TYPE afpo-matnr,
        werks TYPE afpo-werks,
        amein TYPE afpo-amein,
        meins TYPE afpo-meins,
        psmng TYPE afpo-psmng,
        wemng TYPE afpo-wemng,
        umrez TYPE afpo-umrez,
        umren TYPE afpo-umren,
        wepos TYPE afpo-wepos,
        xloek TYPE afpo-xloek,
        elikz TYPE afpo-elikz,
      END OF ty_order_item_data,
      ty_order_item_rows TYPE STANDARD TABLE OF ty_order_item_data
        WITH EMPTY KEY,
      BEGIN OF ty_order_header_data,
        aufnr TYPE afko-aufnr,
        gstrp TYPE afko-gstrp,
        gltrp TYPE afko-gltrp,
      END OF ty_order_header_data,
      ty_order_header_rows TYPE HASHED TABLE OF ty_order_header_data
        WITH UNIQUE KEY aufnr,
      BEGIN OF ty_order_control_data,
        aufnr TYPE aufk-aufnr,
        autyp TYPE aufk-autyp,
        phas1 TYPE aufk-phas1,
        phas2 TYPE aufk-phas2,
        phas3 TYPE aufk-phas3,
        loekz TYPE aufk-loekz,
      END OF ty_order_control_data,
      ty_order_control_rows TYPE HASHED TABLE OF ty_order_control_data
        WITH UNIQUE KEY aufnr.
    DATA lt_afpo TYPE ty_order_item_rows.
    DATA lt_afko TYPE ty_order_header_rows.
    DATA lt_aufk TYPE ty_order_control_rows.
    DATA ls_order_item TYPE zif_prod_order_read_repo=>ty_order_item.

    IF it_production_orders IS INITIAL.
      RETURN.
    ENDIF.

    SELECT aufnr,
           posnr,
           matnr,
           werks,
           amein,
           meins,
           psmng,
           wemng,
           umrez,
           umren,
           wepos,
           xloek,
           elikz
      FROM afpo
      FOR ALL ENTRIES IN @it_production_orders
      WHERE aufnr = @it_production_orders-table_line
      INTO CORRESPONDING FIELDS OF TABLE @lt_afpo.

    IF lt_afpo IS INITIAL.
      RETURN.
    ENDIF.

    SELECT aufnr,
           gstrp,
           gltrp
      FROM afko
      FOR ALL ENTRIES IN @lt_afpo
      WHERE aufnr = @lt_afpo-aufnr
      INTO CORRESPONDING FIELDS OF TABLE @lt_afko.

    SELECT aufnr,
           autyp,
           phas1,
           phas2,
           phas3,
           loekz
      FROM aufk
      FOR ALL ENTRIES IN @lt_afpo
      WHERE aufnr = @lt_afpo-aufnr
        AND ( autyp = '10' OR autyp = '40' )
      INTO CORRESPONDING FIELDS OF TABLE @lt_aufk.

    LOOP AT lt_afpo INTO DATA(ls_afpo).
      READ TABLE lt_afko INTO DATA(ls_afko)
        WITH TABLE KEY aufnr = ls_afpo-aufnr.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      READ TABLE lt_aufk INTO DATA(ls_aufk)
        WITH TABLE KEY aufnr = ls_afpo-aufnr.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      CLEAR ls_order_item.
      ls_order_item-production_order = ls_afpo-aufnr.
      ls_order_item-production_item = ls_afpo-posnr.
      ls_order_item-order_category = ls_aufk-autyp.
      ls_order_item-material = ls_afpo-matnr.
      ls_order_item-plant = ls_afpo-werks.
      ls_order_item-order_unit = ls_afpo-amein.
      ls_order_item-base_unit = ls_afpo-meins.
      ls_order_item-basic_start_date = ls_afko-gstrp.
      ls_order_item-basic_finish_date = ls_afko-gltrp.
      ls_order_item-order_quantity = ls_afpo-psmng.
      ls_order_item-received_quantity = ls_afpo-wemng.
      ls_order_item-order_to_base_numerator = ls_afpo-umrez.
      ls_order_item-order_to_base_denominator = ls_afpo-umren.
      ls_order_item-phase_1_indicator = ls_aufk-phas1.
      ls_order_item-phase_2_indicator = ls_aufk-phas2.
      ls_order_item-phase_3_indicator = ls_aufk-phas3.
      ls_order_item-order_deletion_indicator = ls_aufk-loekz.
      ls_order_item-receipt_expected = ls_afpo-wepos.
      ls_order_item-item_deletion_indicator = ls_afpo-xloek.
      ls_order_item-delivery_complete = ls_afpo-elikz.
      APPEND ls_order_item TO rt_order_items.
    ENDLOOP.

    SORT rt_order_items BY production_order production_item.
  ENDMETHOD.

  METHOD zif_prod_order_read_repo~read_order_statuses.
    TYPES:
      BEGIN OF ty_order_status_header,
        aufnr TYPE aufk-aufnr,
        objnr TYPE aufk-objnr,
        stsma TYPE aufk-stsma,
      END OF ty_order_status_header,
      ty_order_status_headers TYPE HASHED TABLE OF ty_order_status_header
        WITH UNIQUE KEY aufnr,
      BEGIN OF ty_active_order_status,
        objnr TYPE jest-objnr,
        stat  TYPE jest-stat,
      END OF ty_active_order_status,
      ty_active_order_statuses TYPE SORTED TABLE OF
        ty_active_order_status WITH NON-UNIQUE KEY objnr.
    DATA lt_order_headers TYPE ty_order_status_headers.
    DATA lt_active_statuses TYPE ty_active_order_statuses.
    DATA lv_active TYPE jest-inact.

    IF it_production_orders IS INITIAL.
      RETURN.
    ENDIF.

    SELECT aufnr,
           objnr,
           stsma
      FROM aufk
      FOR ALL ENTRIES IN @it_production_orders
      WHERE aufnr = @it_production_orders-table_line
        AND ( autyp = '10' OR autyp = '40' )
      INTO CORRESPONDING FIELDS OF TABLE @lt_order_headers.

    IF lt_order_headers IS INITIAL.
      RETURN.
    ENDIF.

    SELECT objnr,
           stat
      FROM jest
      FOR ALL ENTRIES IN @lt_order_headers
      WHERE objnr = @lt_order_headers-objnr
        AND inact = @lv_active
      INTO CORRESPONDING FIELDS OF TABLE @lt_active_statuses.

    LOOP AT lt_order_headers INTO DATA(ls_order_header).
      LOOP AT lt_active_statuses INTO DATA(ls_active_status)
          WHERE objnr = ls_order_header-objnr.
        APPEND VALUE #(
          production_order = ls_order_header-aufnr
          status_profile   = ls_order_header-stsma
          status_code      = ls_active_status-stat ) TO rt_statuses.
      ENDLOOP.
    ENDLOOP.

    IF rt_statuses IS INITIAL.
      RETURN.
    ENDIF.

    TYPES:
      BEGIN OF ty_system_status_text,
        status_code       TYPE tj02t-istat,
        status_short_name TYPE tj02t-txt04,
        status_name       TYPE tj02t-txt30,
      END OF ty_system_status_text.
    TYPES ty_system_status_texts TYPE HASHED TABLE OF
      ty_system_status_text WITH UNIQUE KEY status_code.
    TYPES:
      BEGIN OF ty_user_status_text,
        status_profile    TYPE tj30t-stsma,
        status_code       TYPE tj30t-estat,
        status_short_name TYPE tj30t-txt04,
        status_name       TYPE tj30t-txt30,
      END OF ty_user_status_text.
    TYPES ty_user_status_texts TYPE HASHED TABLE OF
      ty_user_status_text WITH UNIQUE KEY status_profile status_code.
    DATA lt_system_texts TYPE ty_system_status_texts.
    DATA lt_user_texts TYPE ty_user_status_texts.

    SELECT istat AS status_code,
           txt04 AS status_short_name,
           txt30 AS status_name
      FROM tj02t
      FOR ALL ENTRIES IN @rt_statuses
      WHERE istat = @rt_statuses-status_code
        AND spras = @sy-langu
      INTO TABLE @lt_system_texts.

    SELECT stsma AS status_profile,
           estat AS status_code,
           txt04 AS status_short_name,
           txt30 AS status_name
      FROM tj30t
      FOR ALL ENTRIES IN @rt_statuses
      WHERE stsma = @rt_statuses-status_profile
        AND estat = @rt_statuses-status_code
        AND spras = @sy-langu
      INTO TABLE @lt_user_texts.

    LOOP AT rt_statuses ASSIGNING FIELD-SYMBOL(<ls_status>).
      IF <ls_status>-status_code(1) = 'E'.
        <ls_status>-is_user_status = abap_true.
        READ TABLE lt_user_texts INTO DATA(ls_user_text)
          WITH TABLE KEY
            status_profile = <ls_status>-status_profile
            status_code = <ls_status>-status_code.
        IF sy-subrc = 0.
          <ls_status>-status_short_name =
            ls_user_text-status_short_name.
          <ls_status>-status_name = ls_user_text-status_name.
        ENDIF.
      ELSE.
        READ TABLE lt_system_texts INTO DATA(ls_system_text)
          WITH TABLE KEY status_code = <ls_status>-status_code.
        IF sy-subrc = 0.
          <ls_status>-status_short_name =
            ls_system_text-status_short_name.
          <ls_status>-status_name = ls_system_text-status_name.
        ENDIF.
      ENDIF.
    ENDLOOP.

    SORT rt_statuses BY production_order status_code.
  ENDMETHOD.

  METHOD zif_prod_order_read_repo~read_confirmations.
    TYPES:
      BEGIN OF ty_confirmation_data,
        aufnr TYPE afru-aufnr,
        aufpl TYPE afru-aufpl,
        aplzl TYPE afru-aplzl,
        rueck TYPE afru-rueck,
        rmzhl TYPE afru-rmzhl,
        budat TYPE afru-budat,
        lmnga TYPE afru-lmnga,
        rmnga TYPE afru-rmnga,
        xmnga TYPE afru-xmnga,
        meinh TYPE afru-meinh,
        aueru TYPE afru-aueru,
        stokz TYPE afru-stokz,
      END OF ty_confirmation_data,
      ty_confirmation_rows TYPE STANDARD TABLE OF ty_confirmation_data
        WITH EMPTY KEY,
      BEGIN OF ty_operation_confirmation_key,
        aufpl TYPE afvc-aufpl,
        aplzl TYPE afvc-aplzl,
        vornr TYPE afvc-vornr,
        plnfl TYPE afvc-plnfl,
      END OF ty_operation_confirmation_key,
      ty_operation_confirmation_keys TYPE HASHED TABLE OF
        ty_operation_confirmation_key WITH UNIQUE KEY aufpl aplzl,
      BEGIN OF ty_confirmation_order_key,
        aufnr TYPE aufk-aufnr,
        autyp TYPE aufk-autyp,
      END OF ty_confirmation_order_key,
      ty_confirmation_order_keys TYPE HASHED TABLE OF
        ty_confirmation_order_key WITH UNIQUE KEY aufnr.
    DATA lt_afru TYPE ty_confirmation_rows.
    DATA lt_afvc TYPE ty_operation_confirmation_keys.
    DATA lt_aufk TYPE ty_confirmation_order_keys.
    DATA ls_confirmation TYPE
      zif_prod_order_read_repo=>ty_order_confirmation.

    IF it_production_orders IS INITIAL.
      RETURN.
    ENDIF.

    SELECT aufnr,
           aufpl,
           aplzl,
           rueck,
           rmzhl,
           budat,
           lmnga,
           rmnga,
           xmnga,
           meinh,
           aueru,
           stokz
      FROM afru
      FOR ALL ENTRIES IN @it_production_orders
      WHERE aufnr = @it_production_orders-table_line
      INTO CORRESPONDING FIELDS OF TABLE @lt_afru.

    IF lt_afru IS INITIAL.
      RETURN.
    ENDIF.

    SELECT aufnr,
           autyp
      FROM aufk
      FOR ALL ENTRIES IN @lt_afru
      WHERE aufnr = @lt_afru-aufnr
        AND ( autyp = '10' OR autyp = '40' )
      INTO CORRESPONDING FIELDS OF TABLE @lt_aufk.

    SELECT aufpl,
           aplzl,
           vornr,
           plnfl
      FROM afvc
      FOR ALL ENTRIES IN @lt_afru
      WHERE aufpl = @lt_afru-aufpl
        AND aplzl = @lt_afru-aplzl
      INTO CORRESPONDING FIELDS OF TABLE @lt_afvc.

    LOOP AT lt_afru INTO DATA(ls_afru).
      READ TABLE lt_aufk INTO DATA(ls_aufk)
        WITH TABLE KEY aufnr = ls_afru-aufnr.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      READ TABLE lt_afvc INTO DATA(ls_afvc)
        WITH TABLE KEY aufpl = ls_afru-aufpl aplzl = ls_afru-aplzl.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      CLEAR ls_confirmation.
      ls_confirmation-production_order = ls_afru-aufnr.
      ls_confirmation-operation_number = ls_afvc-vornr.
      ls_confirmation-operation_sequence = ls_afvc-plnfl.
      ls_confirmation-confirmation = ls_afru-rueck.
      ls_confirmation-confirmation_counter = ls_afru-rmzhl.
      ls_confirmation-posting_date = ls_afru-budat.
      ls_confirmation-yield_quantity = ls_afru-lmnga.
      ls_confirmation-rework_quantity = ls_afru-rmnga.
      ls_confirmation-scrap_quantity = ls_afru-xmnga.
      ls_confirmation-quantity_unit = ls_afru-meinh.
      ls_confirmation-is_final = ls_afru-aueru.
      ls_confirmation-is_reversed = ls_afru-stokz.
      APPEND ls_confirmation TO rt_confirmations.
    ENDLOOP.

    SORT rt_confirmations BY production_order posting_date DESCENDING
      confirmation DESCENDING confirmation_counter DESCENDING.
  ENDMETHOD.

  METHOD zif_prod_order_read_repo~read_operations.
    TYPES:
      BEGIN OF ty_operation_order,
        aufnr TYPE aufk-aufnr,
        autyp TYPE aufk-autyp,
      END OF ty_operation_order,
      ty_operation_orders TYPE HASHED TABLE OF ty_operation_order
        WITH UNIQUE KEY aufnr,
      BEGIN OF ty_order_routing,
        aufnr TYPE afko-aufnr,
        aufpl TYPE afko-aufpl,
      END OF ty_order_routing,
      ty_order_routings TYPE SORTED TABLE OF ty_order_routing
        WITH NON-UNIQUE KEY aufpl,
      BEGIN OF ty_operation_data,
        aufpl TYPE afvc-aufpl,
        aplzl TYPE afvc-aplzl,
        plnfl TYPE afvc-plnfl,
        vornr TYPE afvc-vornr,
        uvorn TYPE afvc-uvorn,
        ltxa1 TYPE afvc-ltxa1,
        steus TYPE afvc-steus,
      END OF ty_operation_data,
      ty_operation_rows TYPE STANDARD TABLE OF ty_operation_data
        WITH EMPTY KEY.
    DATA lt_aufk TYPE ty_operation_orders.
    DATA lt_afko TYPE ty_order_routings.
    DATA lt_afvc TYPE ty_operation_rows.
    DATA ls_operation TYPE zif_prod_order_read_repo=>ty_order_operation.

    IF it_production_orders IS INITIAL.
      RETURN.
    ENDIF.

    SELECT aufnr,
           autyp
      FROM aufk
      FOR ALL ENTRIES IN @it_production_orders
      WHERE aufnr = @it_production_orders-table_line
        AND ( autyp = '10' OR autyp = '40' )
      INTO CORRESPONDING FIELDS OF TABLE @lt_aufk.

    IF lt_aufk IS INITIAL.
      RETURN.
    ENDIF.

    SELECT aufnr,
           aufpl
      FROM afko
      FOR ALL ENTRIES IN @lt_aufk
      WHERE aufnr = @lt_aufk-aufnr
      INTO CORRESPONDING FIELDS OF TABLE @lt_afko.

    IF lt_afko IS INITIAL.
      RETURN.
    ENDIF.

    SELECT aufpl,
           aplzl,
           plnfl,
           vornr,
           uvorn,
           ltxa1,
           steus
      FROM afvc
      FOR ALL ENTRIES IN @lt_afko
      WHERE aufpl = @lt_afko-aufpl
      INTO CORRESPONDING FIELDS OF TABLE @lt_afvc.

    LOOP AT lt_afvc INTO DATA(ls_afvc).
      LOOP AT lt_afko INTO DATA(ls_afko)
          WHERE aufpl = ls_afvc-aufpl.
        READ TABLE lt_aufk TRANSPORTING NO FIELDS
          WITH TABLE KEY aufnr = ls_afko-aufnr.
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.

        CLEAR ls_operation.
        ls_operation-production_order = ls_afko-aufnr.
        ls_operation-operation_counter = ls_afvc-aplzl.
        ls_operation-operation_sequence = ls_afvc-plnfl.
        ls_operation-operation_number = ls_afvc-vornr.
        ls_operation-suboperation_number = ls_afvc-uvorn.
        ls_operation-operation_description = ls_afvc-ltxa1.
        ls_operation-control_key = ls_afvc-steus.
        APPEND ls_operation TO rt_operations.
      ENDLOOP.
    ENDLOOP.

    SORT rt_operations BY production_order operation_sequence
      operation_number suboperation_number operation_counter.
  ENDMETHOD.

ENDCLASS.
