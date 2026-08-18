CLASS zcl_reservation_gateway_sap DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_reservation_gateway.

  PRIVATE SECTION.
    TYPES ty_bapi_messages TYPE STANDARD TABLE OF bapiret2 WITH EMPTY KEY.
    TYPES ty_bapi_items TYPE STANDARD TABLE OF bapi2093_res_item
      WITH EMPTY KEY.

    METHODS map_messages
      IMPORTING
        it_messages        TYPE ty_bapi_messages
      RETURNING
        VALUE(rt_messages) TYPE zif_reservation_gateway=>ty_messages.
ENDCLASS.

CLASS zcl_reservation_gateway_sap IMPLEMENTATION.
  METHOD zif_reservation_gateway~create_reservation.
    DATA(ls_header) = VALUE bapi2093_res_head(
      res_date    = sy-datum
      move_type   = is_request-movement_type
      plant       = is_request-plant
      costcenter  = is_request-cost_center
      orderid     = is_request-order_id
      wbs_element = is_request-wbs_element
      sales_ord   = is_request-sales_order
      s_ord_item  = is_request-sales_order_item
      asset_no    = is_request-asset_number
      sub_number  = is_request-asset_subnumber
      network     = is_request-network_id
      activity    = is_request-network_activity ).
    DATA(lt_items) = VALUE ty_bapi_items(
      ( material  = is_request-material
        plant     = is_request-plant
        stge_loc  = is_request-storage_location
        req_date  = is_request-requirement_date
        entry_qnt = is_request-quantity
        entry_uom = is_request-unit_of_measure ) ).
    DATA lt_return TYPE ty_bapi_messages.

    CALL FUNCTION 'BAPI_RESERVATION_CREATE1'
      EXPORTING
        reservation_header = ls_header
      IMPORTING
        reservation        = ev_document_id
      TABLES
        reservation_items  = lt_items
        return             = lt_return.

    et_messages = map_messages( lt_return ).
  ENDMETHOD.

  METHOD zif_reservation_gateway~commit.
    DATA ls_return TYPE bapiret2.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait   = abap_true
      IMPORTING
        return = ls_return.

    IF ls_return-type IS NOT INITIAL.
      rt_messages = VALUE #(
        ( type    = ls_return-type
          message = ls_return-message ) ).
    ENDIF.
  ENDMETHOD.

  METHOD zif_reservation_gateway~rollback.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
  ENDMETHOD.

  METHOD map_messages.
    rt_messages = VALUE #(
      FOR ls_message IN it_messages
      ( type    = ls_message-type
        message = ls_message-message ) ).
  ENDMETHOD.
ENDCLASS.
