CLASS zcl_stock_reservation_sap DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_stock_reservation.
  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_header,
        move_type TYPE c LENGTH 3,
        res_date  TYPE d,
      END OF ty_header.
    TYPES:
      BEGIN OF ty_item,
        material  TYPE zif_stock_allocation=>ty_material,
        plant     TYPE zif_stock_allocation=>ty_plant,
        store_loc TYPE zif_stock_allocation=>ty_storage_location,
        quantity  TYPE zif_stock_allocation=>ty_quantity,
        base_uom  TYPE zif_stock_allocation=>ty_unit,
        req_date  TYPE d,
      END OF ty_item.
    TYPES tt_items TYPE STANDARD TABLE OF ty_item WITH EMPTY KEY.
ENDCLASS.

CLASS zcl_stock_reservation_sap IMPLEMENTATION.
  METHOD zif_stock_reservation~reserve.
    DATA ls_header TYPE ty_header.
    DATA ls_item TYPE ty_item.
    DATA lt_items TYPE tt_items.
    DATA lv_reservation TYPE zif_stock_allocation=>ty_order_id.

    IF iv_material IS INITIAL
        OR iv_plant IS INITIAL
        OR iv_storage_location IS INITIAL
        OR iv_movement_type IS INITIAL
        OR iv_unit IS INITIAL
        OR iv_quantity <= 0.
      RAISE EXCEPTION TYPE zcx_stock_allocation.
    ENDIF.

    ls_header-move_type = iv_movement_type.
    ls_header-res_date = sy-datum.
    ls_item-material = iv_material.
    ls_item-plant = iv_plant.
    ls_item-store_loc = iv_storage_location.
    ls_item-quantity = iv_quantity.
    ls_item-base_uom = iv_unit.
    ls_item-req_date = sy-datum.
    APPEND ls_item TO lt_items.

    CALL FUNCTION 'BAPI_RESERVATION_CREATE1'
      EXPORTING
        reservationheader = ls_header
      IMPORTING
        reservation       = lv_reservation
      TABLES
        reservationitems  = lt_items.
    IF sy-subrc <> 0 OR lv_reservation IS INITIAL.
      RAISE EXCEPTION TYPE zcx_stock_allocation.
    ENDIF.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = abap_true.
    IF sy-subrc <> 0.
      RAISE EXCEPTION TYPE zcx_stock_allocation.
    ENDIF.
    rv_document = lv_reservation.
  ENDMETHOD.
ENDCLASS.
