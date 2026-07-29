CLASS zcl_salloc_orders_sap DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_salloc_orders.
  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_sales_item,
        vbeln     TYPE c LENGTH 10,
        posnr     TYPE n LENGTH 6,
        etenr     TYPE n LENGTH 4,
        edatu     TYPE d,
        requested TYPE zif_salloc_types=>ty_quantity,
        confirmed TYPE zif_salloc_types=>ty_quantity,
      END OF ty_sales_item.
    TYPES tt_sales_items TYPE STANDARD TABLE OF ty_sales_item WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_existing,
        order_id TYPE zif_salloc_types=>ty_order_id,
        allocated TYPE zif_salloc_types=>ty_quantity,
      END OF ty_existing.
    TYPES tt_existing TYPE HASHED TABLE OF ty_existing
      WITH UNIQUE KEY order_id.
ENDCLASS.

CLASS zcl_salloc_orders_sap IMPLEMENTATION.
  METHOD zif_salloc_orders~get_open_demands.
    TRY.
        DATA sales_items TYPE tt_sales_items.
        SELECT b~vbeln,
               b~posnr,
               s~etenr,
               s~edatu,
               s~wmeng AS requested,
               s~bmeng AS confirmed
          FROM vbap AS b
          INNER JOIN vbep AS s
            ON s~vbeln = b~vbeln
           AND s~posnr = b~posnr
          WHERE b~matnr = @iv_material
            AND b~werks = @iv_plant
            AND s~wmeng > s~bmeng
          INTO CORRESPONDING FIELDS OF TABLE @sales_items.

        DATA existing TYPE tt_existing.
        SELECT order_id, allocated
          FROM zsalloc_order
          WHERE matnr = @iv_material
            AND werks = @iv_plant
          INTO TABLE @existing.

        LOOP AT sales_items ASSIGNING FIELD-SYMBOL(<sales_item>).
          DATA(demand) = VALUE zif_salloc_types=>ty_demand(
            requested_on = <sales_item>-edatu
            requested = <sales_item>-requested - <sales_item>-confirmed ).
          CONCATENATE <sales_item>-vbeln <sales_item>-posnr <sales_item>-etenr
            INTO demand-order_id.

          READ TABLE existing ASSIGNING FIELD-SYMBOL(<existing>)
            WITH TABLE KEY order_id = demand-order_id.
          IF sy-subrc = 0.
            demand-requested = demand-requested - <existing>-allocated.
          ENDIF.

          IF demand-requested > 0.
            APPEND demand TO rt_demands.
          ENDIF.
        ENDLOOP.
      CATCH cx_sy_open_sql_db INTO DATA(db_error).
        RAISE EXCEPTION TYPE zcx_salloc_integration
          EXPORTING
            iv_operation = `GET_OPEN_DEMANDS`
            iv_reason = db_error->get_text( ).
    ENDTRY.
  ENDMETHOD.

  METHOD zif_salloc_orders~save_allocations.
    TRY.
        DATA existing TYPE HASHED TABLE OF zsalloc_order
          WITH UNIQUE KEY order_id.
        SELECT *
          FROM zsalloc_order
          WHERE matnr = @iv_material
            AND werks = @iv_plant
          INTO TABLE @existing.

        DATA changed TYPE STANDARD TABLE OF zsalloc_order WITH EMPTY KEY.
        LOOP AT it_demands ASSIGNING FIELD-SYMBOL(<demand>).
          READ TABLE existing ASSIGNING FIELD-SYMBOL(<existing>)
            WITH TABLE KEY order_id = <demand>-order_id.
          IF sy-subrc = 0.
            DATA(order_row) = <existing>.
            order_row-requested = order_row-allocated + <demand>-requested.
            order_row-allocated = order_row-allocated + <demand>-allocated.
            order_row-shortage = <demand>-shortage.
            order_row-priority = <demand>-priority.
            order_row-requested_on = <demand>-requested_on.
          ELSE.
            order_row = VALUE #(
              mandt = sy-mandt
              order_id = <demand>-order_id
              matnr = iv_material
              werks = iv_plant
              requested = <demand>-requested
              allocated = <demand>-allocated
              shortage = <demand>-shortage
              priority = <demand>-priority
              requested_on = <demand>-requested_on ).
          ENDIF.
          APPEND order_row TO changed.
        ENDLOOP.

        IF changed IS NOT INITIAL.
          MODIFY zsalloc_order FROM TABLE @changed.
          IF sy-subrc <> 0.
            RAISE EXCEPTION TYPE zcx_salloc_integration
              EXPORTING
                iv_operation = `SAVE_ALLOCATIONS`
                iv_reason = `Order ledger update failed`.
          ENDIF.
        ENDIF.
      CATCH cx_sy_open_sql_db INTO DATA(db_error).
        RAISE EXCEPTION TYPE zcx_salloc_integration
          EXPORTING
            iv_operation = `SAVE_ALLOCATIONS`
            iv_reason = db_error->get_text( ).
    ENDTRY.
  ENDMETHOD.

  METHOD zif_salloc_orders~release_allocation.
    IF iv_quantity <= 0.
      RAISE EXCEPTION TYPE zcx_salloc_integration
        EXPORTING
          iv_operation = `RELEASE_ALLOCATION`
          iv_reason = `Release quantity must be positive`.
    ENDIF.

    TRY.
        SELECT SINGLE *
          FROM zsalloc_order
          WHERE order_id = @iv_order_id
            AND matnr = @iv_material
            AND werks = @iv_plant
          INTO @DATA(order_row).
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_salloc_integration
            EXPORTING
              iv_operation = `RELEASE_ALLOCATION`
              iv_reason = `Release exceeds order allocation`.
        ELSEIF order_row-allocated < iv_quantity.
          RAISE EXCEPTION TYPE zcx_salloc_integration
            EXPORTING
              iv_operation = `RELEASE_ALLOCATION`
              iv_reason = `Release exceeds order allocation`.
        ENDIF.

        DATA(previous_allocated) = order_row-allocated.
        order_row-allocated = order_row-allocated - iv_quantity.
        order_row-shortage = order_row-shortage + iv_quantity.
        UPDATE zsalloc_order
          SET allocated = @order_row-allocated,
              shortage = @order_row-shortage
          WHERE order_id = @iv_order_id
            AND matnr = @iv_material
            AND werks = @iv_plant
            AND allocated = @previous_allocated.
        IF sy-dbcnt <> 1.
          RAISE EXCEPTION TYPE zcx_salloc_integration
            EXPORTING
              iv_operation = `RELEASE_ALLOCATION`
              iv_reason = `Concurrent order allocation detected`.
        ENDIF.
      CATCH cx_sy_open_sql_db INTO DATA(db_error).
        RAISE EXCEPTION TYPE zcx_salloc_integration
          EXPORTING
            iv_operation = `RELEASE_ALLOCATION`
            iv_reason = db_error->get_text( ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
