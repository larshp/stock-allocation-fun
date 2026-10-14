CLASS zcl_prod_order_read_repo DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_prod_order_read_repo.
ENDCLASS.

CLASS zcl_prod_order_read_repo IMPLEMENTATION.

  METHOD zif_prod_order_read_repo~read_orders.
    IF it_production_orders IS INITIAL.
      RETURN.
    ENDIF.

    SELECT afpo~aufnr AS production_order,
           afpo~posnr AS production_item,
           aufk~autyp AS order_category,
           afpo~matnr AS material,
           afpo~werks AS plant,
           afpo~amein AS order_unit,
           afpo~meins AS base_unit,
           afko~gstrp AS basic_start_date,
           afko~gltrp AS basic_finish_date,
           afpo~psmng AS order_quantity,
           afpo~wemng AS received_quantity,
           afpo~umrez AS order_to_base_numerator,
           afpo~umren AS order_to_base_denominator,
           aufk~phas1 AS phase_1_indicator,
           aufk~phas2 AS phase_2_indicator,
           aufk~phas3 AS phase_3_indicator,
           aufk~loekz AS order_deletion_indicator,
           afpo~wepos AS receipt_expected,
           afpo~xloek AS item_deletion_indicator,
           afpo~elikz AS delivery_complete
      FROM afpo
      INNER JOIN afko
        ON afko~aufnr = afpo~aufnr
      INNER JOIN aufk
        ON aufk~aufnr = afpo~aufnr
      FOR ALL ENTRIES IN @it_production_orders
      WHERE afpo~aufnr = @it_production_orders-table_line
        AND ( aufk~autyp = '10'
           OR aufk~autyp = '40' )
      INTO CORRESPONDING FIELDS OF TABLE @rt_order_items.

    SORT rt_order_items BY production_order production_item.
  ENDMETHOD.

  METHOD zif_prod_order_read_repo~read_order_statuses.
    IF it_production_orders IS INITIAL.
      RETURN.
    ENDIF.

    SELECT aufk~aufnr AS production_order,
           aufk~stsma AS status_profile,
           jest~stat AS status_code
      FROM aufk
      INNER JOIN jest
        ON jest~objnr = aufk~objnr
      FOR ALL ENTRIES IN @it_production_orders
      WHERE aufk~aufnr = @it_production_orders-table_line
        AND jest~inact = @space
        AND ( aufk~autyp = '10'
           OR aufk~autyp = '40' )
      INTO CORRESPONDING FIELDS OF TABLE @rt_statuses.

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
    IF it_production_orders IS INITIAL.
      RETURN.
    ENDIF.

    SELECT afru~aufnr AS production_order,
           afvc~vornr AS operation_number,
           afvc~plnfl AS operation_sequence,
           afru~rueck AS confirmation,
           afru~rmzhl AS confirmation_counter,
           afru~budat AS posting_date,
           afru~lmnga AS yield_quantity,
           afru~rmnga AS rework_quantity,
           afru~xmnga AS scrap_quantity,
           afru~meinh AS quantity_unit,
           afru~aueru AS is_final,
           afru~stokz AS is_reversed
      FROM afru
      INNER JOIN afvc
        ON afvc~aufpl = afru~aufpl
       AND afvc~aplzl = afru~aplzl
      INNER JOIN aufk
        ON aufk~aufnr = afru~aufnr
      FOR ALL ENTRIES IN @it_production_orders
      WHERE afru~aufnr = @it_production_orders-table_line
        AND ( aufk~autyp = '10'
           OR aufk~autyp = '40' )
      INTO CORRESPONDING FIELDS OF TABLE @rt_confirmations.

    SORT rt_confirmations BY production_order posting_date DESCENDING
      confirmation DESCENDING confirmation_counter DESCENDING.
  ENDMETHOD.

  METHOD zif_prod_order_read_repo~read_operations.
    IF it_production_orders IS INITIAL.
      RETURN.
    ENDIF.

    SELECT afko~aufnr AS production_order,
           afvc~aplzl AS operation_counter,
           afvc~plnfl AS operation_sequence,
           afvc~vornr AS operation_number,
           afvc~uvorn AS suboperation_number,
           afvc~ltxa1 AS operation_description,
           afvc~steus AS control_key
      FROM afko
      INNER JOIN afvc
        ON afvc~aufpl = afko~aufpl
      INNER JOIN aufk
        ON aufk~aufnr = afko~aufnr
      FOR ALL ENTRIES IN @it_production_orders
      WHERE afko~aufnr = @it_production_orders-table_line
        AND ( aufk~autyp = '10'
           OR aufk~autyp = '40' )
      INTO CORRESPONDING FIELDS OF TABLE @rt_operations.

    SORT rt_operations BY production_order operation_sequence
      operation_number suboperation_number operation_counter.
  ENDMETHOD.

ENDCLASS.
