CLASS zcl_stock_reservation_sap DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        io_authority TYPE REF TO zif_stock_allocation_authority OPTIONAL.
    INTERFACES zif_stock_reservation.
  PRIVATE SECTION.
    DATA mo_authority TYPE REF TO zif_stock_allocation_authority.
    TYPES:
      BEGIN OF ty_header,
        res_date   TYPE d,
        created_by TYPE c LENGTH 12,
        move_type  TYPE c LENGTH 3,
      END OF ty_header.
    TYPES:
      BEGIN OF ty_item,
        material          TYPE c LENGTH 18,
        plant             TYPE c LENGTH 4,
        stge_loc          TYPE c LENGTH 4,
        batch             TYPE c LENGTH 10,
        val_type          TYPE c LENGTH 10,
        entry_qnt         TYPE p LENGTH 8 DECIMALS 3,
        entry_uom         TYPE c LENGTH 3,
        entry_uom_iso     TYPE c LENGTH 3,
        req_date          TYPE d,
        gl_account        TYPE c LENGTH 10,
        acct_man          TYPE c LENGTH 1,
        item_text         TYPE c LENGTH 50,
        gr_rcpt           TYPE c LENGTH 12,
        unload_pt         TYPE c LENGTH 25,
        fixed_quan        TYPE c LENGTH 1,
        movement          TYPE c LENGTH 1,
        cmmt_item         TYPE c LENGTH 24,
        funds_ctr         TYPE c LENGTH 16,
        fund              TYPE c LENGTH 10,
        movement_auto     TYPE c LENGTH 1,
        grant_nbr         TYPE c LENGTH 20,
        material_external TYPE c LENGTH 40,
        material_guid     TYPE c LENGTH 32,
        material_version  TYPE c LENGTH 10,
        prio_urgency      TYPE n LENGTH 2,
        prio_requirement  TYPE n LENGTH 3,
        budget_period     TYPE c LENGTH 10,
      END OF ty_item.
    TYPES tt_items TYPE STANDARD TABLE OF ty_item WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_return,
        type       TYPE c LENGTH 1,
        id         TYPE c LENGTH 20,
        number     TYPE n LENGTH 3,
        message    TYPE c LENGTH 220,
        log_no     TYPE c LENGTH 20,
        log_msg_no TYPE n LENGTH 6,
        message_v1 TYPE c LENGTH 50,
        message_v2 TYPE c LENGTH 50,
        message_v3 TYPE c LENGTH 50,
        message_v4 TYPE c LENGTH 50,
        parameter  TYPE c LENGTH 32,
        row        TYPE i,
        field      TYPE c LENGTH 30,
        system     TYPE c LENGTH 10,
    END OF ty_return.
    TYPES tt_return TYPE STANDARD TABLE OF ty_return WITH EMPTY KEY.
    METHODS raise_error
      IMPORTING
        iv_message TYPE zif_allocation_audit=>ty_message
      RAISING
        zcx_stock_allocation.
ENDCLASS.

CLASS zcl_stock_reservation_sap IMPLEMENTATION.
  METHOD constructor.
    IF io_authority IS BOUND.
      mo_authority = io_authority.
    ELSE.
      CREATE OBJECT mo_authority TYPE zcl_stock_allocation_authority_sap.
    ENDIF.
  ENDMETHOD.

  METHOD zif_stock_reservation~reserve.
    DATA ls_header TYPE ty_header.
    DATA ls_item TYPE ty_item.
    DATA lt_items TYPE tt_items.
    DATA lt_return TYPE tt_return.
    DATA lv_reservation TYPE zif_stock_allocation=>ty_order_id.
    DATA lv_bapi_subrc TYPE sy-subrc.
    DATA lv_rollback_subrc TYPE sy-subrc.
    DATA lv_bapi_error TYPE abap_bool.
    DATA lv_bapi_message TYPE c LENGTH 220.
    DATA lo_error TYPE REF TO zcx_stock_allocation.
    FIELD-SYMBOLS <ls_return> TYPE ty_return.

    IF iv_material IS INITIAL
        OR iv_plant IS INITIAL
        OR iv_storage_location IS INITIAL
        OR iv_movement_type IS INITIAL
        OR iv_unit IS INITIAL
        OR iv_required_date IS INITIAL
        OR iv_quantity <= 0.
      raise_error( iv_message = 'Reservation input is invalid' ).
    ENDIF.
    IF mo_authority IS BOUND.
      TRY.
          mo_authority->check(
            iv_plant         = iv_plant
            iv_movement_type = iv_movement_type ).
        CATCH zcx_stock_allocation INTO lo_error.
          IF lo_error->message IS INITIAL.
            lo_error->message = 'Reservation authorization failed'.
          ENDIF.
          RAISE EXCEPTION lo_error.
      ENDTRY.
    ENDIF.

    ls_header-move_type = iv_movement_type.
    ls_header-res_date = sy-datum.
    ls_header-created_by = sy-uname.
    ls_item-material = iv_material.
    ls_item-material_external = iv_material.
    ls_item-plant = iv_plant.
    ls_item-stge_loc = iv_storage_location.
    ls_item-batch = iv_batch.
    ls_item-entry_qnt = iv_quantity.
    ls_item-entry_uom = iv_unit.
    ls_item-req_date = iv_required_date.
    APPEND ls_item TO lt_items.

    CALL FUNCTION 'BAPI_RESERVATION_CREATE1'
      EXPORTING
        reservationheader = ls_header
      IMPORTING
        reservation       = lv_reservation
      TABLES
        reservationitems  = lt_items
        return            = lt_return.
    lv_bapi_subrc = sy-subrc.
    LOOP AT lt_return ASSIGNING <ls_return>.
      IF <ls_return>-type = 'A'
          OR <ls_return>-type = 'E'
          OR <ls_return>-type = 'X'.
        lv_bapi_error = abap_true.
        IF lv_bapi_message IS INITIAL.
          lv_bapi_message = <ls_return>-message.
        ENDIF.
      ENDIF.
    ENDLOOP.
    IF lv_bapi_error = abap_true
        OR lv_bapi_subrc <> 0
        OR lv_reservation IS INITIAL.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      lv_rollback_subrc = sy-subrc.
      IF lv_bapi_message IS INITIAL.
        lv_bapi_message = 'Reservation creation failed'.
      ENDIF.
      IF lv_rollback_subrc <> 0.
        CONCATENATE lv_bapi_message
                    'Transaction rollback failed'
               INTO lv_bapi_message SEPARATED BY '; '.
      ENDIF.
      CREATE OBJECT lo_error.
      lo_error->message = lv_bapi_message.
      RAISE EXCEPTION lo_error.
    ENDIF.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = abap_true.
    IF sy-subrc <> 0.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      lv_rollback_subrc = sy-subrc.
      CREATE OBJECT lo_error.
      lo_error->message = 'Reservation commit failed'.
      IF lv_rollback_subrc <> 0.
        CONCATENATE lo_error->message
                    'Transaction rollback failed'
               INTO lo_error->message SEPARATED BY '; '.
      ENDIF.
      RAISE EXCEPTION lo_error.
    ENDIF.
    rv_document = lv_reservation.
  ENDMETHOD.

  METHOD zif_stock_reservation~cancel.
    DATA lt_return TYPE tt_return.
    DATA lv_document TYPE c LENGTH 10.
    DATA lv_bapi_subrc TYPE sy-subrc.
    DATA lv_rollback_subrc TYPE sy-subrc.
    DATA lv_bapi_error TYPE abap_bool.
    DATA lv_bapi_message TYPE c LENGTH 220.
    DATA lo_error TYPE REF TO zcx_stock_allocation.
    FIELD-SYMBOLS <ls_return> TYPE ty_return.

    IF iv_document IS INITIAL
        OR iv_plant IS INITIAL
        OR iv_movement_type IS INITIAL.
      raise_error( iv_message = 'Reservation document is required' ).
    ENDIF.

    IF mo_authority IS BOUND.
      TRY.
          mo_authority->check_cancel(
            iv_plant         = iv_plant
            iv_movement_type = iv_movement_type ).
        CATCH zcx_stock_allocation INTO lo_error.
          IF lo_error->message IS INITIAL.
            lo_error->message = 'Reservation cancellation authorization failed'.
          ENDIF.
          RAISE EXCEPTION lo_error.
      ENDTRY.
    ENDIF.

    lv_document = iv_document.
    CALL FUNCTION 'BAPI_RESERVATION_DELETE'
      EXPORTING
        reservation = lv_document
      TABLES
        return      = lt_return.
    lv_bapi_subrc = sy-subrc.
    LOOP AT lt_return ASSIGNING <ls_return>.
      IF <ls_return>-type = 'A'
          OR <ls_return>-type = 'E'
          OR <ls_return>-type = 'X'.
        lv_bapi_error = abap_true.
        IF lv_bapi_message IS INITIAL.
          lv_bapi_message = <ls_return>-message.
        ENDIF.
      ENDIF.
    ENDLOOP.
    IF lv_bapi_error = abap_true OR lv_bapi_subrc <> 0.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      lv_rollback_subrc = sy-subrc.
      IF lv_bapi_message IS INITIAL.
        lv_bapi_message = 'Reservation cancellation failed'.
      ENDIF.
      IF lv_rollback_subrc <> 0.
        CONCATENATE lv_bapi_message
                    'Transaction rollback failed'
               INTO lv_bapi_message SEPARATED BY '; '.
      ENDIF.
      CREATE OBJECT lo_error.
      lo_error->message = lv_bapi_message.
      RAISE EXCEPTION lo_error.
    ENDIF.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = abap_true.
    IF sy-subrc <> 0.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      lv_rollback_subrc = sy-subrc.
      CREATE OBJECT lo_error.
      lo_error->message = 'Reservation cancellation commit failed'.
      IF lv_rollback_subrc <> 0.
        CONCATENATE lo_error->message
                    'Transaction rollback failed'
               INTO lo_error->message SEPARATED BY '; '.
      ENDIF.
      RAISE EXCEPTION lo_error.
    ENDIF.
  ENDMETHOD.

  METHOD raise_error.
    DATA lo_error TYPE REF TO zcx_stock_allocation.
    CREATE OBJECT lo_error.
    lo_error->message = iv_message.
    RAISE EXCEPTION lo_error.
  ENDMETHOD.
ENDCLASS.
