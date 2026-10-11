CLASS zcl_bapi_planned_order_api DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_planned_order_api.

    TYPES:
      BEGIN OF ty_change_data,
        headerdata  TYPE bapiplaf_i2,
        headerdatax TYPE bapiplaf_i2x,
      END OF ty_change_data.

    CLASS-METHODS map_request
      IMPORTING
        is_request       TYPE zif_planned_order_api=>ty_request
      RETURNING
        VALUE(rs_header) TYPE bapiplaf_i1.

    CLASS-METHODS map_change_request
      IMPORTING
        is_request            TYPE zif_planned_order_api=>ty_change_request
      RETURNING
        VALUE(rs_change_data) TYPE ty_change_data.
ENDCLASS.

CLASS zcl_bapi_planned_order_api IMPLEMENTATION.

  METHOD zif_planned_order_api~create_order.
    DATA ls_header_data TYPE bapiplaf_i1.
    DATA lv_planned_order TYPE plaf-plnum.
    DATA ls_return TYPE bapireturn1.

    ls_header_data = map_request( is_request ).

    CALL FUNCTION 'BAPI_PLANNEDORDER_CREATE'
      EXPORTING
        headerdata   = ls_header_data
      IMPORTING
        plannedorder = lv_planned_order
        return       = ls_return.

    rs_result-planned_order = lv_planned_order.
    rs_result-message-type = ls_return-type.
    rs_result-message-message = ls_return-message.
    rs_result-is_successful = abap_true.

    IF ls_return-type = 'A'
        OR ls_return-type = 'E'
        OR ls_return-type = 'X'
        OR lv_planned_order IS INITIAL.
      rs_result-is_successful = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD map_request.
    rs_header-material = is_request-material.
    rs_header-plan_plant = is_request-plant.
    rs_header-total_plord_qty = is_request-quantity.
    rs_header-order_finish_date = is_request-planned_end_date.
  ENDMETHOD.

  METHOD map_change_request.
    IF is_request-change_quantity = abap_true.
      rs_change_data-headerdata-total_plord_qty = is_request-quantity.
      rs_change_data-headerdatax-total_plord_qty = abap_true.
    ENDIF.
    IF is_request-change_end_date = abap_true.
      rs_change_data-headerdata-order_finish_date =
        is_request-planned_end_date.
      rs_change_data-headerdatax-order_finish_date = abap_true.
    ENDIF.
    IF is_request-change_start_date = abap_true.
      rs_change_data-headerdata-order_start_date =
        is_request-planned_start_date.
      rs_change_data-headerdatax-order_start_date = abap_true.
    ENDIF.
    IF is_request-change_fixed_indicator = abap_true.
      rs_change_data-headerdata-firming_ind =
        is_request-fixed_indicator.
      rs_change_data-headerdatax-firming_ind = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD zif_planned_order_api~change_order.
    DATA ls_change_data TYPE ty_change_data.
    DATA ls_return TYPE bapireturn1.

    ls_change_data = map_change_request( is_request ).

    CALL FUNCTION 'BAPI_PLANNEDORDER_CHANGE'
      EXPORTING
        plannedorder = is_request-planned_order
        headerdata   = ls_change_data-headerdata
        headerdatax  = ls_change_data-headerdatax
      IMPORTING
        return       = ls_return.

    rs_result-planned_order = is_request-planned_order.
    rs_result-message-type = ls_return-type.
    rs_result-message-message = ls_return-message.
    rs_result-is_successful = abap_true.

    IF ls_return-type = 'A'
        OR ls_return-type = 'E'
        OR ls_return-type = 'X'.
      rs_result-is_successful = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD zif_planned_order_api~delete_order.
    DATA ls_return TYPE bapireturn1.

    CALL FUNCTION 'BAPI_PLANNEDORDER_DELETE'
      EXPORTING
        plannedorder = iv_planned_order
      IMPORTING
        return       = ls_return.

    rs_result-planned_order = iv_planned_order.
    rs_result-message-type = ls_return-type.
    rs_result-message-message = ls_return-message.
    rs_result-is_successful = abap_true.

    IF ls_return-type = 'A'
        OR ls_return-type = 'E'
        OR ls_return-type = 'X'.
      rs_result-is_successful = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD zif_planned_order_api~convert_order.
    DATA lv_production_order TYPE aufk-aufnr.
    DATA ls_return TYPE bapiret2.

    CALL FUNCTION 'BAPI_PRODORD_CREATE_FROM_PLORD'
      EXPORTING
        planned_order    = iv_planned_order
      IMPORTING
        production_order = lv_production_order
        return           = ls_return.

    rs_result-planned_order = iv_planned_order.
    rs_result-production_order = lv_production_order.
    rs_result-message-type = ls_return-type.
    rs_result-message-message = ls_return-message.
    rs_result-is_successful = abap_true.

    IF ls_return-type = 'A'
        OR ls_return-type = 'E'
        OR ls_return-type = 'X'
        OR lv_production_order IS INITIAL.
      rs_result-is_successful = abap_false.
      CLEAR rs_result-production_order.
    ENDIF.
  ENDMETHOD.

  METHOD zif_planned_order_api~commit.
    DATA ls_return TYPE bapiret2.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait   = abap_true
      IMPORTING
        return = ls_return.

    rs_result-message-type = ls_return-type.
    rs_result-message-message = ls_return-message.
    rs_result-is_successful = abap_true.

    IF ls_return-type = 'A'
        OR ls_return-type = 'E'
        OR ls_return-type = 'X'.
      rs_result-is_successful = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD zif_planned_order_api~rollback.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
  ENDMETHOD.

ENDCLASS.
