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
      CREATE OBJECT mo_authority TYPE zcl_stock_alloc_auth_sap.
    ENDIF.
  ENDMETHOD.

  METHOD zif_stock_reservation~reserve.
    DATA ls_header TYPE ty_header.
    DATA ls_item TYPE ty_item.
    DATA lt_items TYPE tt_items.
    DATA lt_return TYPE tt_return.
    DATA ls_commit_return TYPE ty_return.
    DATA ls_rollback_return TYPE ty_return.
    DATA lv_reservation TYPE c LENGTH 10.
    DATA lv_bapi_subrc TYPE sy-subrc.
    DATA lv_commit_subrc TYPE sy-subrc.
    DATA lv_rollback_subrc TYPE sy-subrc.
    DATA lv_bapi_error TYPE abap_bool.
    DATA lv_commit_error TYPE abap_bool.
    DATA lv_rollback_error TYPE abap_bool.
    DATA lv_bapi_message TYPE c LENGTH 220.
    DATA lv_commit_message TYPE c LENGTH 220.
    DATA lv_unit TYPE zif_stock_allocation=>ty_unit.
    DATA lo_error TYPE REF TO zcx_stock_allocation.
    FIELD-SYMBOLS <ls_return> TYPE ty_return.

    lv_unit = to_upper( iv_unit ).
    IF iv_material IS INITIAL
        OR iv_plant IS INITIAL
        OR iv_storage_location IS INITIAL
        OR iv_movement_type IS INITIAL
        OR strlen( iv_movement_type ) <> zif_stock_allocation=>c_movement_type_length
        OR iv_movement_type CN '0123456789'
        OR iv_movement_type = zif_stock_allocation=>c_zero_movement_type
        OR lv_unit IS INITIAL
        OR iv_required_date IS INITIAL
        OR zcl_allocation_date_sap=>is_valid_or_initial(
          iv_required_date ) <> abap_true
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
    ls_item-entry_uom = lv_unit.
    ls_item-req_date = iv_required_date.
    APPEND ls_item TO lt_items.

    CALL FUNCTION 'BAPI_RESERVATION_CREATE1'
      EXPORTING
        reservationheader = ls_header
      IMPORTING
        reservation       = lv_reservation
      TABLES
        reservationitems  = lt_items
        return            = lt_return
      EXCEPTIONS
        OTHERS            = 1.
    lv_bapi_subrc = sy-subrc.
    LOOP AT lt_return ASSIGNING <ls_return>.
      IF <ls_return>-type IS NOT INITIAL
          AND <ls_return>-type <> 'S'
          AND <ls_return>-type <> 'I'
          AND <ls_return>-type <> 'W'
          AND <ls_return>-type <> 'E'
          AND <ls_return>-type <> 'A'
          AND <ls_return>-type <> 'X'.
        lv_bapi_error = abap_true.
        IF lv_bapi_message IS INITIAL.
          lv_bapi_message = 'Reservation BAPI returned invalid status'.
        ENDIF.
      ELSEIF <ls_return>-type = 'A'
          OR <ls_return>-type = 'E'
          OR <ls_return>-type = 'X'.
        lv_bapi_error = abap_true.
        IF lv_bapi_message IS INITIAL.
          lv_bapi_message = <ls_return>-message.
        ENDIF.
      ENDIF.
    ENDLOOP.
    IF lv_reservation IS NOT INITIAL
        AND ( strlen( lv_reservation ) <> zif_stock_allocation=>c_sap_document_length
          OR lv_reservation CN '0123456789'
          OR lv_reservation = '0000000000' )
        AND lv_bapi_message IS INITIAL.
      lv_bapi_message = 'Reservation document returned by SAP is invalid'.
    ENDIF.
    IF lv_bapi_error = abap_true
        OR lv_bapi_subrc <> 0
        OR lv_reservation IS INITIAL
        OR strlen( lv_reservation ) <> zif_stock_allocation=>c_sap_document_length
        OR lv_reservation CN '0123456789'
        OR lv_reservation = '0000000000'.
      CLEAR: ls_rollback_return,
             lv_rollback_error.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'
        IMPORTING
          return = ls_rollback_return
        EXCEPTIONS
          OTHERS = 1.
      lv_rollback_subrc = sy-subrc.
      IF ls_rollback_return-type IS NOT INITIAL
          AND ls_rollback_return-type <> 'S'
          AND ls_rollback_return-type <> 'I'
          AND ls_rollback_return-type <> 'W'
          AND ls_rollback_return-type <> 'E'
          AND ls_rollback_return-type <> 'A'
          AND ls_rollback_return-type <> 'X'.
        lv_rollback_error = abap_true.
      ELSEIF ls_rollback_return-type = 'E'
          OR ls_rollback_return-type = 'A'
          OR ls_rollback_return-type = 'X'.
        lv_rollback_error = abap_true.
      ENDIF.
      IF lv_rollback_subrc <> 0.
        lv_rollback_error = abap_true.
      ENDIF.
      IF lv_bapi_message IS INITIAL.
        lv_bapi_message = 'Reservation creation failed'.
      ENDIF.
      IF lv_rollback_error = abap_true.
        IF ls_rollback_return-message IS INITIAL.
          CONCATENATE lv_bapi_message
                      'Transaction rollback failed'
                 INTO lv_bapi_message SEPARATED BY '; '.
        ELSE.
          CONCATENATE lv_bapi_message
                      'Transaction rollback failed:'
                 INTO lv_bapi_message SEPARATED BY '; '.
          CONCATENATE lv_bapi_message
                      ls_rollback_return-message
                 INTO lv_bapi_message SEPARATED BY space.
        ENDIF.
      ENDIF.
      CREATE OBJECT lo_error.
      lo_error->message = lv_bapi_message.
      RAISE EXCEPTION lo_error.
    ENDIF.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait   = abap_true
      IMPORTING
        return = ls_commit_return
      EXCEPTIONS
        OTHERS = 1.
    lv_commit_subrc = sy-subrc.
    IF ls_commit_return-type IS NOT INITIAL
        AND ls_commit_return-type <> 'S'
        AND ls_commit_return-type <> 'I'
        AND ls_commit_return-type <> 'W'
        AND ls_commit_return-type <> 'E'
        AND ls_commit_return-type <> 'A'
        AND ls_commit_return-type <> 'X'.
      lv_commit_error = abap_true.
      lv_commit_message = 'Reservation commit returned invalid status'.
    ELSEIF ls_commit_return-type = 'E'
        OR ls_commit_return-type = 'A'
        OR ls_commit_return-type = 'X'.
      lv_commit_error = abap_true.
      lv_commit_message = ls_commit_return-message.
    ENDIF.
    IF lv_commit_subrc <> 0.
      lv_commit_error = abap_true.
    ENDIF.
    IF lv_commit_error = abap_true.
      CLEAR: ls_rollback_return,
             lv_rollback_error.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'
        IMPORTING
          return = ls_rollback_return
        EXCEPTIONS
          OTHERS = 1.
      lv_rollback_subrc = sy-subrc.
      IF ls_rollback_return-type IS NOT INITIAL
          AND ls_rollback_return-type <> 'S'
          AND ls_rollback_return-type <> 'I'
          AND ls_rollback_return-type <> 'W'
          AND ls_rollback_return-type <> 'E'
          AND ls_rollback_return-type <> 'A'
          AND ls_rollback_return-type <> 'X'.
        lv_rollback_error = abap_true.
      ELSEIF ls_rollback_return-type = 'E'
          OR ls_rollback_return-type = 'A'
          OR ls_rollback_return-type = 'X'.
        lv_rollback_error = abap_true.
      ENDIF.
      IF lv_rollback_subrc <> 0.
        lv_rollback_error = abap_true.
      ENDIF.
      CREATE OBJECT lo_error.
      IF lv_commit_message IS INITIAL.
        lv_commit_message = 'Reservation commit failed'.
      ENDIF.
      lo_error->message = lv_commit_message.
      IF lv_rollback_error = abap_true.
        IF ls_rollback_return-message IS INITIAL.
          CONCATENATE lo_error->message
                      'Transaction rollback failed'
                 INTO lo_error->message SEPARATED BY '; '.
        ELSE.
          CONCATENATE lo_error->message
                      'Transaction rollback failed:'
                 INTO lo_error->message SEPARATED BY '; '.
          CONCATENATE lo_error->message
                      ls_rollback_return-message
                 INTO lo_error->message SEPARATED BY space.
        ENDIF.
      ENDIF.
      RAISE EXCEPTION lo_error.
    ENDIF.
    rv_document = lv_reservation.
  ENDMETHOD.

  METHOD zif_stock_reservation~cancel.
    DATA lt_return TYPE tt_return.
    DATA ls_commit_return TYPE ty_return.
    DATA ls_rollback_return TYPE ty_return.
    DATA lv_document TYPE c LENGTH 10.
    DATA lv_bapi_subrc TYPE sy-subrc.
    DATA lv_commit_subrc TYPE sy-subrc.
    DATA lv_rollback_subrc TYPE sy-subrc.
    DATA lv_bapi_error TYPE abap_bool.
    DATA lv_commit_error TYPE abap_bool.
    DATA lv_rollback_error TYPE abap_bool.
    DATA lv_bapi_message TYPE c LENGTH 220.
    DATA lv_commit_message TYPE c LENGTH 220.
    DATA lo_error TYPE REF TO zcx_stock_allocation.
    FIELD-SYMBOLS <ls_return> TYPE ty_return.

    IF iv_document IS INITIAL
        OR iv_plant IS INITIAL
        OR iv_movement_type IS INITIAL
        OR strlen( iv_movement_type ) <> zif_stock_allocation=>c_movement_type_length
        OR iv_movement_type CN '0123456789'
        OR iv_movement_type = zif_stock_allocation=>c_zero_movement_type.
      raise_error( iv_message = 'Reservation document is required' ).
    ENDIF.
    IF strlen( iv_document )
          <> zif_stock_allocation=>c_sap_document_length.
      raise_error( iv_message = 'Reservation document is invalid' ).
    ENDIF.
    lv_document = iv_document.
    IF lv_document CN '0123456789'
        OR lv_document = '0000000000'.
      raise_error( iv_message = 'Reservation document is invalid' ).
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

    CALL FUNCTION 'BAPI_RESERVATION_DELETE'
      EXPORTING
        reservation = lv_document
      TABLES
        return      = lt_return
      EXCEPTIONS
        OTHERS      = 1.
    lv_bapi_subrc = sy-subrc.
    LOOP AT lt_return ASSIGNING <ls_return>.
      IF <ls_return>-type IS NOT INITIAL
          AND <ls_return>-type <> 'S'
          AND <ls_return>-type <> 'I'
          AND <ls_return>-type <> 'W'
          AND <ls_return>-type <> 'E'
          AND <ls_return>-type <> 'A'
          AND <ls_return>-type <> 'X'.
        lv_bapi_error = abap_true.
        IF lv_bapi_message IS INITIAL.
          lv_bapi_message = 'Reservation BAPI returned invalid status'.
        ENDIF.
      ELSEIF <ls_return>-type = 'A'
          OR <ls_return>-type = 'E'
          OR <ls_return>-type = 'X'.
        lv_bapi_error = abap_true.
        IF lv_bapi_message IS INITIAL.
          lv_bapi_message = <ls_return>-message.
        ENDIF.
      ENDIF.
    ENDLOOP.
    IF lv_bapi_error = abap_true OR lv_bapi_subrc <> 0.
      CLEAR: ls_rollback_return,
             lv_rollback_error.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'
        IMPORTING
          return = ls_rollback_return
        EXCEPTIONS
          OTHERS = 1.
      lv_rollback_subrc = sy-subrc.
      IF ls_rollback_return-type IS NOT INITIAL
          AND ls_rollback_return-type <> 'S'
          AND ls_rollback_return-type <> 'I'
          AND ls_rollback_return-type <> 'W'
          AND ls_rollback_return-type <> 'E'
          AND ls_rollback_return-type <> 'A'
          AND ls_rollback_return-type <> 'X'.
        lv_rollback_error = abap_true.
      ELSEIF ls_rollback_return-type = 'E'
          OR ls_rollback_return-type = 'A'
          OR ls_rollback_return-type = 'X'.
        lv_rollback_error = abap_true.
      ENDIF.
      IF lv_rollback_subrc <> 0.
        lv_rollback_error = abap_true.
      ENDIF.
      IF lv_bapi_message IS INITIAL.
        lv_bapi_message = 'Reservation cancellation failed'.
      ENDIF.
      IF lv_rollback_error = abap_true.
        IF ls_rollback_return-message IS INITIAL.
          CONCATENATE lv_bapi_message
                      'Transaction rollback failed'
                 INTO lv_bapi_message SEPARATED BY '; '.
        ELSE.
          CONCATENATE lv_bapi_message
                      'Transaction rollback failed:'
                 INTO lv_bapi_message SEPARATED BY '; '.
          CONCATENATE lv_bapi_message
                      ls_rollback_return-message
                 INTO lv_bapi_message SEPARATED BY space.
        ENDIF.
      ENDIF.
      CREATE OBJECT lo_error.
      lo_error->message = lv_bapi_message.
      RAISE EXCEPTION lo_error.
    ENDIF.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait   = abap_true
      IMPORTING
        return = ls_commit_return
      EXCEPTIONS
        OTHERS = 1.
    lv_commit_subrc = sy-subrc.
    IF ls_commit_return-type IS NOT INITIAL
        AND ls_commit_return-type <> 'S'
        AND ls_commit_return-type <> 'I'
        AND ls_commit_return-type <> 'W'
        AND ls_commit_return-type <> 'E'
        AND ls_commit_return-type <> 'A'
        AND ls_commit_return-type <> 'X'.
      lv_commit_error = abap_true.
      lv_commit_message = 'Reservation cancellation commit returned invalid status'.
    ELSEIF ls_commit_return-type = 'E'
        OR ls_commit_return-type = 'A'
        OR ls_commit_return-type = 'X'.
      lv_commit_error = abap_true.
      lv_commit_message = ls_commit_return-message.
    ENDIF.
    IF lv_commit_subrc <> 0.
      lv_commit_error = abap_true.
    ENDIF.
    IF lv_commit_error = abap_true.
      CLEAR: ls_rollback_return,
             lv_rollback_error.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'
        IMPORTING
          return = ls_rollback_return
        EXCEPTIONS
          OTHERS = 1.
      lv_rollback_subrc = sy-subrc.
      IF ls_rollback_return-type IS NOT INITIAL
          AND ls_rollback_return-type <> 'S'
          AND ls_rollback_return-type <> 'I'
          AND ls_rollback_return-type <> 'W'
          AND ls_rollback_return-type <> 'E'
          AND ls_rollback_return-type <> 'A'
          AND ls_rollback_return-type <> 'X'.
        lv_rollback_error = abap_true.
      ELSEIF ls_rollback_return-type = 'E'
          OR ls_rollback_return-type = 'A'
          OR ls_rollback_return-type = 'X'.
        lv_rollback_error = abap_true.
      ENDIF.
      IF lv_rollback_subrc <> 0.
        lv_rollback_error = abap_true.
      ENDIF.
      CREATE OBJECT lo_error.
      IF lv_commit_message IS INITIAL.
        lv_commit_message = 'Reservation cancellation commit failed'.
      ENDIF.
      lo_error->message = lv_commit_message.
      IF lv_rollback_error = abap_true.
        IF ls_rollback_return-message IS INITIAL.
          CONCATENATE lo_error->message
                      'Transaction rollback failed'
                 INTO lo_error->message SEPARATED BY '; '.
        ELSE.
          CONCATENATE lo_error->message
                      'Transaction rollback failed:'
                 INTO lo_error->message SEPARATED BY '; '.
          CONCATENATE lo_error->message
                      ls_rollback_return-message
                 INTO lo_error->message SEPARATED BY space.
        ENDIF.
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
