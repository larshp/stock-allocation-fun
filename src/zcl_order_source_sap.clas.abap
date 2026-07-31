CLASS zcl_order_source_sap DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_order_source.
  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_schedule,
        order_id      TYPE c LENGTH 10,
        item_id       TYPE n LENGTH 6,
        schedule_line TYPE n LENGTH 4,
        requested_on  TYPE d,
        requested     TYPE p LENGTH 8 DECIMALS 3,
        confirmed     TYPE p LENGTH 8 DECIMALS 3,
      END OF ty_schedule.
    TYPES tt_schedule TYPE STANDARD TABLE OF ty_schedule WITH EMPTY KEY.
ENDCLASS.

CLASS zcl_order_source_sap IMPLEMENTATION.
  METHOD zif_order_source~get_open_demands.
    DATA lt_schedule TYPE tt_schedule.
    DATA ls_demand TYPE zif_stock_allocation=>ty_demand.
    FIELD-SYMBOLS <ls_schedule> TYPE ty_schedule.

    SELECT item~vbeln, item~posnr, schedule~etenr, schedule~edatu,
           schedule~wmeng, schedule~bmeng
      FROM vbap AS item
      INNER JOIN vbep AS schedule
        ON schedule~vbeln = item~vbeln
       AND schedule~posnr = item~posnr
      INTO TABLE @lt_schedule
      WHERE item~matnr = @iv_material
        AND item~werks = @iv_plant
        AND item~abgru = ''
        AND schedule~wmeng > schedule~bmeng.
    IF sy-subrc <> 0.
      CLEAR rt_demands.
      RETURN.
    ENDIF.

    LOOP AT lt_schedule ASSIGNING <ls_schedule>.
      CLEAR ls_demand.
      CONCATENATE <ls_schedule>-order_id
                  <ls_schedule>-item_id
                  <ls_schedule>-schedule_line
             INTO ls_demand-order_id.
      ls_demand-requested_on = <ls_schedule>-requested_on.
      ls_demand-requested = <ls_schedule>-requested - <ls_schedule>-confirmed.
      APPEND ls_demand TO rt_demands.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
