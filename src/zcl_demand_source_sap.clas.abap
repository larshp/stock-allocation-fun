CLASS zcl_demand_source_sap DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_demand_source.
  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_priority,
        sales_order TYPE zif_stock_allocation=>ty_sales_order,
        sales_item  TYPE zif_stock_allocation=>ty_sales_item,
        priority    TYPE zif_stock_allocation=>ty_priority,
      END OF ty_priority.
    TYPES tt_priorities TYPE HASHED TABLE OF ty_priority
      WITH UNIQUE KEY sales_order sales_item.
ENDCLASS.

CLASS zcl_demand_source_sap IMPLEMENTATION.
  METHOD zif_demand_source~get_open_demands.
    SELECT vbeln, posnr, etenr, mbdat, omeng
      FROM vbbe
      WHERE matnr = @iv_material
        AND werks = @iv_plant
        AND lgort = @iv_storage_location
        AND omeng > 0
      INTO TABLE @DATA(lt_requirements).
    IF lt_requirements IS INITIAL.
      RETURN.
    ENDIF.

    DATA lt_priorities TYPE tt_priorities.
    SELECT vbeln AS sales_order,
           posnr AS sales_item,
           priority
      FROM zstockprio
      FOR ALL ENTRIES IN @lt_requirements
      WHERE matnr = @iv_material
        AND werks = @iv_plant
        AND lgort = @iv_storage_location
        AND vbeln = @lt_requirements-vbeln
        AND posnr = @lt_requirements-posnr
      INTO TABLE @lt_priorities.

    LOOP AT lt_requirements INTO DATA(ls_requirement).
      DATA(lv_priority) = CONV zif_stock_allocation=>ty_priority( 0 ).
      READ TABLE lt_priorities INTO DATA(ls_priority)
        WITH TABLE KEY sales_order = ls_requirement-vbeln
                       sales_item = ls_requirement-posnr.
      IF sy-subrc = 0.
        lv_priority = ls_priority-priority.
      ENDIF.

      APPEND VALUE #(
        sales_order = ls_requirement-vbeln
        sales_item = ls_requirement-posnr
        schedule_line = ls_requirement-etenr
        delivery_date = ls_requirement-mbdat
        priority = lv_priority
        requested_qty = ls_requirement-omeng ) TO rt_demands.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
