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

    METHODS has_error
      IMPORTING
        it_messages         TYPE zif_reservation_gateway=>ty_messages
      RETURNING
        VALUE(rv_has_error) TYPE abap_bool.
ENDCLASS.

CLASS zcl_reservation_gateway_sap IMPLEMENTATION.
  METHOD zif_reservation_gateway~create_reservation.
    CLEAR: ev_document_id, et_messages.
    IF zcl_allocation_persistence=>reservation_request_is_valid(
        is_request ) = abap_false.
      et_messages = VALUE #(
        ( type    = 'E'
          message = 'Reservation request is invalid' ) ).
      RETURN.
    ENDIF.

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
    IF has_error( et_messages ) = abap_true.
      CLEAR ev_document_id.
      RETURN.
    ENDIF.
    IF zcl_allocation_persistence=>document_id_is_valid(
        ev_document_id ) = abap_false.
      CLEAR ev_document_id.
      APPEND VALUE #(
        type    = 'E'
        message = 'Reservation API returned invalid document ID' )
        TO et_messages.
    ENDIF.
  ENDMETHOD.

  METHOD zif_reservation_gateway~commit.
    DATA ls_return TYPE bapiret2.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait   = abap_true
      IMPORTING
        return = ls_return.

    IF ls_return-type IS NOT INITIAL
        OR ls_return-message IS NOT INITIAL.
      rt_messages = map_messages( VALUE #( ( ls_return ) ) ).
    ENDIF.
  ENDMETHOD.

  METHOD zif_reservation_gateway~rollback.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
  ENDMETHOD.

  METHOD map_messages.
    LOOP AT it_messages INTO DATA(ls_message).
      IF ls_message-type = 'S'
          OR ls_message-type = 'I'
          OR ls_message-type = 'W'
          OR ls_message-type = 'E'
          OR ls_message-type = 'A'
          OR ls_message-type = 'X'.
        APPEND VALUE #(
          type    = ls_message-type
          message = ls_message-message ) TO rt_messages.
      ELSE.
        APPEND VALUE #(
          type    = 'E'
          message = 'Reservation API returned invalid message type' )
          TO rt_messages.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD has_error.
    rv_has_error = xsdbool(
      line_exists( it_messages[ type = 'E' ] )
      OR line_exists( it_messages[ type = 'A' ] )
      OR line_exists( it_messages[ type = 'X' ] ) ).
  ENDMETHOD.
ENDCLASS.
