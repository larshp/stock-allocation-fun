CLASS zcl_bapi_prod_order_api DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_prod_order_api.

    TYPES ty_detail_returns TYPE STANDARD TABLE OF bapi_order_return
      WITH EMPTY KEY.
    TYPES ty_operation_detail_returns TYPE STANDARD TABLE OF
      bapi_order_return WITH EMPTY KEY.
    TYPES ty_confirmation_create_detail_returns TYPE STANDARD TABLE OF
      bapi_coru_return WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_change_parameters,
        orderdata  TYPE bapi_pp_order_change,
        orderdatax TYPE bapi_pp_order_changex,
      END OF ty_change_parameters.

    CLASS-METHODS map_create_order_request
      IMPORTING
        is_request          TYPE zif_prod_order_api=>ty_create_order_request
      RETURNING
        VALUE(rs_orderdata) TYPE bapi_pp_order_create.

    CLASS-METHODS map_create_order_result
      IMPORTING
        is_request       TYPE zif_prod_order_api=>ty_create_order_request
        iv_order_number  TYPE bapi_order_key-order_number
        is_return        TYPE bapiret2
      RETURNING
        VALUE(rs_result) TYPE zif_prod_order_api=>ty_order_result.

    CLASS-METHODS map_release_result
      IMPORTING
        it_production_orders TYPE zif_prod_order_api=>ty_order_numbers
        it_detail_returns    TYPE ty_detail_returns
        is_return            TYPE bapiret2
      RETURNING
        VALUE(rs_result)     TYPE zif_prod_order_api=>ty_release_result.

    CLASS-METHODS map_operation_release_result
      IMPORTING
        it_operations     TYPE zif_prod_order_api=>ty_operation_keys
        it_detail_returns TYPE ty_operation_detail_returns
        is_return         TYPE bapiret2
      RETURNING
        VALUE(rs_result)  TYPE
          zif_prod_order_api=>ty_operation_release_result.

    CLASS-METHODS map_confirmation_cancel_result
      IMPORTING
        is_request       TYPE
          zif_prod_order_api=>ty_confirmation_cancel_request
        is_return        TYPE bapiret2
      RETURNING
        VALUE(rs_result) TYPE
          zif_prod_order_api=>ty_confirmation_cancel_result.

    CLASS-METHODS map_confirmation_create_result
      IMPORTING
        is_request        TYPE
          zif_prod_order_api=>ty_confirmation_create_request
        it_detail_returns TYPE ty_confirmation_create_detail_returns
        is_return         TYPE bapiret1
      RETURNING
        VALUE(rs_result)  TYPE
          zif_prod_order_api=>ty_confirmation_create_result.

    CLASS-METHODS map_completion_result
      IMPORTING
        iv_production_order TYPE zif_prod_order_api=>ty_order_number
        is_return           TYPE bapiret2
      RETURNING
        VALUE(rs_result)    TYPE zif_prod_order_api=>ty_order_result.

    CLASS-METHODS map_deletion_flag_result
      IMPORTING
        iv_production_order TYPE zif_prod_order_api=>ty_order_number
        is_return           TYPE bapiret2
      RETURNING
        VALUE(rs_result)    TYPE zif_prod_order_api=>ty_order_result.

    CLASS-METHODS map_close_result
      IMPORTING
        iv_production_order TYPE zif_prod_order_api=>ty_order_number
        is_return           TYPE bapiret2
      RETURNING
        VALUE(rs_result)    TYPE zif_prod_order_api=>ty_order_result.

    CLASS-METHODS map_deletion_indicator_result
      IMPORTING
        iv_production_order TYPE zif_prod_order_api=>ty_order_number
        is_return           TYPE bapiret2
      RETURNING
        VALUE(rs_result)    TYPE zif_prod_order_api=>ty_order_result.

    CLASS-METHODS map_change_result
      IMPORTING
        iv_production_order TYPE zif_prod_order_api=>ty_order_number
        is_return           TYPE bapiret2
      RETURNING
        VALUE(rs_result)    TYPE zif_prod_order_api=>ty_order_result.

    CLASS-METHODS map_change_request
      IMPORTING
        is_request           TYPE zif_prod_order_api=>ty_change_request
      RETURNING
        VALUE(rs_parameters) TYPE ty_change_parameters.
ENDCLASS.

CLASS zcl_bapi_prod_order_api IMPLEMENTATION.

  METHOD map_create_order_request.
    rs_orderdata-order_number = is_request-order_number.
    rs_orderdata-material = is_request-material.
    rs_orderdata-plant = is_request-plant.
    rs_orderdata-planning_plant = is_request-planning_plant.
    rs_orderdata-order_type = is_request-order_type.
    rs_orderdata-basic_start_date = is_request-basic_start_date.
    rs_orderdata-basic_end_date = is_request-basic_finish_date.
    rs_orderdata-quantity = is_request-quantity.
    rs_orderdata-quantity_uom = is_request-quantity_uom.
  ENDMETHOD.

  METHOD map_create_order_result.
    rs_result-production_order = iv_order_number.
    IF rs_result-production_order IS INITIAL.
      rs_result-production_order = is_request-order_number.
    ENDIF.
    rs_result-message-type = is_return-type.
    rs_result-message-message = is_return-message.
    rs_result-is_successful = abap_true.
    IF is_return-type = 'A'
        OR is_return-type = 'E'
        OR is_return-type = 'X'.
      rs_result-is_successful = abap_false.
    ENDIF.
    IF rs_result-is_successful = abap_true
        AND rs_result-production_order IS INITIAL.
      rs_result-is_successful = abap_false.
      rs_result-message-type = 'E'.
      rs_result-message-message = 'Production order number was not returned'.
    ENDIF.
  ENDMETHOD.

  METHOD zif_prod_order_api~create_order.
    DATA ls_return TYPE bapiret2.
    DATA lv_order_number TYPE bapi_order_key-order_number.
    DATA ls_orderdata TYPE bapi_pp_order_create.

    ls_orderdata = map_create_order_request(
      is_request = is_request ).
    CALL FUNCTION 'BAPI_PRODORD_CREATE'
      EXPORTING
        orderdata    = ls_orderdata
      IMPORTING
        return       = ls_return
        order_number = lv_order_number.

    rs_result = map_create_order_result(
      is_request      = is_request
      iv_order_number = lv_order_number
      is_return       = ls_return ).
  ENDMETHOD.

  METHOD zif_prod_order_api~release_orders.
    DATA lt_orders TYPE STANDARD TABLE OF bapi_order_key WITH EMPTY KEY.
    DATA lt_application_log TYPE STANDARD TABLE OF
      bapi_order_application_log WITH EMPTY KEY.
    DATA lt_detail_returns TYPE ty_detail_returns.
    DATA ls_return TYPE bapiret2.

    LOOP AT it_production_orders INTO DATA(lv_production_order).
      APPEND VALUE #( order_number = lv_production_order ) TO lt_orders.
    ENDLOOP.

    CALL FUNCTION 'BAPI_PRODORD_RELEASE'
      EXPORTING
        release_control = iv_release_control
      IMPORTING
        return          = ls_return
      TABLES
        orders          = lt_orders
        application_log = lt_application_log
        detail_return   = lt_detail_returns.

    rs_result = map_release_result(
      it_production_orders = it_production_orders
      it_detail_returns    = lt_detail_returns
      is_return            = ls_return ).
  ENDMETHOD.

  METHOD zif_prod_order_api~release_operations.
    DATA lt_operations TYPE STANDARD TABLE OF
      bapi_order_operation_key WITH EMPTY KEY.
    DATA lt_application_log TYPE STANDARD TABLE OF
      bapi_order_application_log WITH EMPTY KEY.
    DATA lt_detail_returns TYPE ty_operation_detail_returns.
    DATA ls_return TYPE bapiret2.

    LOOP AT it_operations INTO DATA(ls_operation).
      APPEND VALUE #(
        order_number     = ls_operation-production_order
        operation_number = ls_operation-operation_number )
        TO lt_operations.
    ENDLOOP.

    CALL FUNCTION 'BAPI_PRODORD_RELEASE_OPERATION'
      EXPORTING
        release_control = iv_release_control
      IMPORTING
        return          = ls_return
      TABLES
        operations      = lt_operations
        application_log = lt_application_log
        detail_return   = lt_detail_returns.

    rs_result = map_operation_release_result(
      it_operations     = it_operations
      it_detail_returns = lt_detail_returns
      is_return         = ls_return ).
  ENDMETHOD.

  METHOD zif_prod_order_api~cancel_confirmation.
    DATA ls_return TYPE bapiret2.

    CALL FUNCTION 'BAPI_PRODORDCONF_CANCEL'
      EXPORTING
        confirmation        = is_request-confirmation
        confirmationcounter = is_request-confirmation_counter
        postg_date          = is_request-posting_date
      IMPORTING
        return              = ls_return.

    rs_result = map_confirmation_cancel_result(
      is_request = is_request
      is_return  = ls_return ).
  ENDMETHOD.

  METHOD zif_prod_order_api~create_confirmation.
    DATA ls_return TYPE bapiret1.
    DATA ls_commit_return TYPE bapiret2.
    DATA ls_timeticket TYPE bapi_pp_timeticket.
    DATA lt_timetickets TYPE STANDARD TABLE OF bapi_pp_timeticket
      WITH EMPTY KEY.
    DATA lt_detail_returns TYPE ty_confirmation_create_detail_returns.

    ls_timeticket-orderid = is_request-production_order.
    ls_timeticket-operation = is_request-operation_number.
    ls_timeticket-sequence = is_request-operation_sequence.
    ls_timeticket-postg_date = is_request-posting_date.
    ls_timeticket-yield = is_request-yield_quantity.
    ls_timeticket-scrap = is_request-scrap_quantity.
    ls_timeticket-rework = is_request-rework_quantity.
    ls_timeticket-conf_quan_unit_iso = is_request-quantity_unit_iso.
    ls_timeticket-fin_conf = is_request-final_confirmation.
    IF is_request-clear_reservations = abap_true.
      ls_timeticket-clear_res = abap_true.
    ENDIF.
    APPEND ls_timeticket TO lt_timetickets.

    CALL FUNCTION 'BAPI_PRODORDCONF_CREATE_TT'
      IMPORTING
        return        = ls_return
      TABLES
        timetickets   = lt_timetickets
        detail_return = lt_detail_returns.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait   = abap_true
      IMPORTING
        return = ls_commit_return.

    rs_result-commit_result-message-type = ls_commit_return-type.
    rs_result-commit_result-message-message = ls_commit_return-message.
    rs_result-commit_result-is_successful = abap_true.
    IF ls_commit_return-type = 'A'
        OR ls_commit_return-type = 'E'
        OR ls_commit_return-type = 'X'.
      rs_result-commit_result-is_successful = abap_false.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    ENDIF.

    DATA(ls_create_result) = map_confirmation_create_result(
      is_request        = is_request
      it_detail_returns = lt_detail_returns
      is_return         = ls_return ).
    rs_result-production_order = ls_create_result-production_order.
    rs_result-operation_number = ls_create_result-operation_number.
    rs_result-operation_sequence = ls_create_result-operation_sequence.
    rs_result-confirmation = ls_create_result-confirmation.
    rs_result-confirmation_counter = ls_create_result-confirmation_counter.
    rs_result-message = ls_create_result-message.
    rs_result-is_successful = ls_create_result-is_successful.
  ENDMETHOD.

  METHOD zif_prod_order_api~change_order.
    DATA ls_return TYPE bapiret2.
    DATA(ls_parameters) = map_change_request( is_request = is_request ).

    CALL FUNCTION 'BAPI_PRODORD_CHANGE'
      EXPORTING
        number     = is_request-production_order
        orderdata  = ls_parameters-orderdata
        orderdatax = ls_parameters-orderdatax
      IMPORTING
        return     = ls_return.

    rs_result = map_change_result(
      iv_production_order = is_request-production_order
      is_return           = ls_return ).
  ENDMETHOD.

  METHOD zif_prod_order_api~complete_technically.
    DATA ls_return TYPE bapiret2.

    CALL FUNCTION 'BAPI_PRODORD_COMPLETE_TECH'
      EXPORTING
        number = iv_production_order
      IMPORTING
        return = ls_return.

    rs_result = map_completion_result(
      iv_production_order = iv_production_order
      is_return           = ls_return ).
  ENDMETHOD.

  METHOD map_completion_result.
    rs_result-production_order = iv_production_order.
    rs_result-message-type = is_return-type.
    rs_result-message-message = is_return-message.
    rs_result-is_successful = abap_true.
    IF is_return-type = 'A'
        OR is_return-type = 'E'
        OR is_return-type = 'X'.
      rs_result-is_successful = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD zif_prod_order_api~set_deletion_flag.
    DATA ls_return TYPE bapiret2.

    CALL FUNCTION 'BAPI_PRODORD_SET_DELETION_FLAG'
      EXPORTING
        number = iv_production_order
      IMPORTING
        return = ls_return.

    rs_result = map_deletion_flag_result(
      iv_production_order = iv_production_order
      is_return           = ls_return ).
  ENDMETHOD.

  METHOD map_deletion_flag_result.
    rs_result-production_order = iv_production_order.
    rs_result-message-type = is_return-type.
    rs_result-message-message = is_return-message.
    rs_result-is_successful = abap_true.
    IF is_return-type = 'A'
        OR is_return-type = 'E'
        OR is_return-type = 'X'.
      rs_result-is_successful = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD zif_prod_order_api~close_order.
    DATA ls_return TYPE bapiret2.

    CALL FUNCTION 'BAPI_PRODORD_CLOSE'
      EXPORTING
        number = iv_production_order
      IMPORTING
        return = ls_return.

    rs_result = map_close_result(
      iv_production_order = iv_production_order
      is_return           = ls_return ).
  ENDMETHOD.

  METHOD map_close_result.
    rs_result-production_order = iv_production_order.
    rs_result-message-type = is_return-type.
    rs_result-message-message = is_return-message.
    rs_result-is_successful = abap_true.
    IF is_return-type = 'A'
        OR is_return-type = 'E'
        OR is_return-type = 'X'.
      rs_result-is_successful = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD zif_prod_order_api~set_deletion_indicator.
    DATA ls_return TYPE bapiret2.

    CALL FUNCTION 'BAPI_PRODORD_SET_DEL_INDICATOR'
      EXPORTING
        number = iv_production_order
      IMPORTING
        return = ls_return.

    rs_result = map_deletion_indicator_result(
      iv_production_order = iv_production_order
      is_return           = ls_return ).
  ENDMETHOD.

  METHOD map_deletion_indicator_result.
    rs_result-production_order = iv_production_order.
    rs_result-message-type = is_return-type.
    rs_result-message-message = is_return-message.
    rs_result-is_successful = abap_true.
    IF is_return-type = 'A'
        OR is_return-type = 'E'
        OR is_return-type = 'X'.
      rs_result-is_successful = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD map_change_result.
    rs_result-production_order = iv_production_order.
    rs_result-message-type = is_return-type.
    rs_result-message-message = is_return-message.
    rs_result-is_successful = abap_true.
    IF is_return-type = 'A'
        OR is_return-type = 'E'
        OR is_return-type = 'X'.
      rs_result-is_successful = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD map_confirmation_cancel_result.
    rs_result-confirmation = is_request-confirmation.
    rs_result-confirmation_counter = is_request-confirmation_counter.
    rs_result-message-type = is_return-type.
    rs_result-message-message = is_return-message.
    rs_result-is_successful = abap_true.
    IF is_return-type = 'A'
        OR is_return-type = 'E'
        OR is_return-type = 'X'.
      rs_result-is_successful = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD map_confirmation_create_result.
    DATA ls_detail_return TYPE bapi_coru_return.
    DATA lv_detail_found TYPE abap_bool.

    rs_result-production_order = is_request-production_order.
    rs_result-operation_number = is_request-operation_number.
    rs_result-operation_sequence = is_request-operation_sequence.

    LOOP AT it_detail_returns INTO ls_detail_return.
      IF ls_detail_return-row = 1.
        lv_detail_found = abap_true.
        EXIT.
      ENDIF.
    ENDLOOP.
    IF lv_detail_found = abap_false.
      READ TABLE it_detail_returns INTO ls_detail_return INDEX 1.
      IF sy-subrc = 0.
        lv_detail_found = abap_true.
      ENDIF.
    ENDIF.

    rs_result-is_successful = abap_true.
    IF is_return-type = 'A'
        OR is_return-type = 'E'
        OR is_return-type = 'X'.
      rs_result-is_successful = abap_false.
      rs_result-message-type = is_return-type.
      rs_result-message-message = is_return-message.
    ENDIF.

    IF lv_detail_found = abap_true.
      rs_result-confirmation = ls_detail_return-conf_no.
      rs_result-confirmation_counter = ls_detail_return-conf_cnt.
      IF rs_result-message-message IS INITIAL.
        rs_result-message-type = ls_detail_return-type.
        rs_result-message-message = ls_detail_return-message.
      ENDIF.
      IF ls_detail_return-type = 'A'
          OR ls_detail_return-type = 'E'
          OR ls_detail_return-type = 'X'.
        rs_result-is_successful = abap_false.
        rs_result-message-type = ls_detail_return-type.
        rs_result-message-message = ls_detail_return-message.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD map_change_request.
    IF is_request-change_quantity = abap_true.
      rs_parameters-orderdata-quantity = is_request-quantity.
      rs_parameters-orderdata-quantity_uom = is_request-quantity_uom.
      rs_parameters-orderdatax-quantity = abap_true.
      rs_parameters-orderdatax-quantity_uom = abap_true.
    ENDIF.
    IF is_request-change_start_date = abap_true.
      rs_parameters-orderdata-basic_start_date =
        is_request-basic_start_date.
      rs_parameters-orderdatax-basic_start_date = abap_true.
    ENDIF.
    IF is_request-change_finish_date = abap_true.
      rs_parameters-orderdata-basic_end_date =
        is_request-basic_finish_date.
      rs_parameters-orderdatax-basic_end_date = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD map_release_result.
    DATA lv_global_error TYPE abap_bool.

    rs_result-is_successful = abap_true.

    LOOP AT it_production_orders INTO DATA(lv_production_order).
      APPEND VALUE #(
        production_order = lv_production_order
        is_successful    = abap_true ) TO rs_result-orders.
    ENDLOOP.

    IF is_return-type = 'A'
        OR is_return-type = 'E'
        OR is_return-type = 'X'.
      lv_global_error = abap_true.
      rs_result-is_successful = abap_false.
      LOOP AT rs_result-orders ASSIGNING FIELD-SYMBOL(<ls_order_result>).
        <ls_order_result>-is_successful = abap_false.
        <ls_order_result>-message-type = is_return-type.
        <ls_order_result>-message-message = is_return-message.
      ENDLOOP.
    ENDIF.

    LOOP AT it_detail_returns INTO DATA(ls_detail_return).
      READ TABLE rs_result-orders ASSIGNING <ls_order_result>
        WITH KEY production_order = ls_detail_return-order_number.
      IF sy-subrc <> 0.
        IF ls_detail_return-type = 'A'
            OR ls_detail_return-type = 'E'
            OR ls_detail_return-type = 'X'.
          rs_result-is_successful = abap_false.
          LOOP AT rs_result-orders ASSIGNING <ls_order_result>.
            <ls_order_result>-is_successful = abap_false.
            IF <ls_order_result>-message-message IS INITIAL.
              <ls_order_result>-message-type = ls_detail_return-type.
              <ls_order_result>-message-message = ls_detail_return-message.
            ENDIF.
          ENDLOOP.
        ENDIF.
        CONTINUE.
      ENDIF.

      IF lv_global_error = abap_false
          OR ls_detail_return-type = 'A'
          OR ls_detail_return-type = 'E'
          OR ls_detail_return-type = 'X'.
        <ls_order_result>-message-type = ls_detail_return-type.
        <ls_order_result>-message-message = ls_detail_return-message.
      ENDIF.
      IF ls_detail_return-type = 'A'
          OR ls_detail_return-type = 'E'
          OR ls_detail_return-type = 'X'.
        rs_result-is_successful = abap_false.
        <ls_order_result>-is_successful = abap_false.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD map_operation_release_result.
    DATA lv_global_error TYPE abap_bool.

    rs_result-is_successful = abap_true.
    LOOP AT it_operations INTO DATA(ls_operation).
      APPEND VALUE #(
        production_order = ls_operation-production_order
        operation_number = ls_operation-operation_number
        is_successful    = abap_true ) TO rs_result-operations.
    ENDLOOP.

    IF is_return-type = 'A'
        OR is_return-type = 'E'
        OR is_return-type = 'X'.
      lv_global_error = abap_true.
      rs_result-is_successful = abap_false.
      LOOP AT rs_result-operations ASSIGNING
          FIELD-SYMBOL(<ls_operation_result>).
        <ls_operation_result>-is_successful = abap_false.
        <ls_operation_result>-message-type = is_return-type.
        <ls_operation_result>-message-message = is_return-message.
      ENDLOOP.
    ENDIF.

    LOOP AT it_detail_returns INTO DATA(ls_detail_return).
      READ TABLE rs_result-operations ASSIGNING <ls_operation_result>
        WITH KEY production_order = ls_detail_return-order_number
          operation_number = ls_detail_return-operation_number.
      IF sy-subrc <> 0.
        IF ls_detail_return-type = 'A'
            OR ls_detail_return-type = 'E'
            OR ls_detail_return-type = 'X'.
          rs_result-is_successful = abap_false.
          LOOP AT rs_result-operations ASSIGNING <ls_operation_result>.
            <ls_operation_result>-is_successful = abap_false.
            IF <ls_operation_result>-message-message IS INITIAL.
              <ls_operation_result>-message-type = ls_detail_return-type.
              <ls_operation_result>-message-message =
                ls_detail_return-message.
            ENDIF.
          ENDLOOP.
        ENDIF.
        CONTINUE.
      ENDIF.

      IF lv_global_error = abap_false
          OR ls_detail_return-type = 'A'
          OR ls_detail_return-type = 'E'
          OR ls_detail_return-type = 'X'.
        <ls_operation_result>-message-type = ls_detail_return-type.
        <ls_operation_result>-message-message = ls_detail_return-message.
      ENDIF.
      IF ls_detail_return-type = 'A'
          OR ls_detail_return-type = 'E'
          OR ls_detail_return-type = 'X'.
        rs_result-is_successful = abap_false.
        <ls_operation_result>-is_successful = abap_false.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_prod_order_api~commit.
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

  METHOD zif_prod_order_api~rollback.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
  ENDMETHOD.

ENDCLASS.
