CLASS zcl_order_sink_sap DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        io_authority TYPE REF TO zif_order_sink_authority OPTIONAL.
    INTERFACES zif_order_sink.
  PRIVATE SECTION.
    DATA mo_authority TYPE REF TO zif_order_sink_authority.
    TYPES:
      BEGIN OF ty_header_x,
        updateflag TYPE c LENGTH 1,
      END OF ty_header_x.
    TYPES:
      BEGIN OF ty_schedule,
        itm_number TYPE n LENGTH 6,
        sched_line TYPE n LENGTH 4,
        req_qty    TYPE p LENGTH 8 DECIMALS 3,
      END OF ty_schedule.
    TYPES tt_schedule TYPE STANDARD TABLE OF ty_schedule WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_schedule_x,
        itm_number TYPE n LENGTH 6,
        sched_line TYPE n LENGTH 4,
        updateflag TYPE c LENGTH 1,
        req_qty    TYPE c LENGTH 1,
      END OF ty_schedule_x.
    TYPES tt_schedule_x TYPE STANDARD TABLE OF ty_schedule_x WITH EMPTY KEY.
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

CLASS zcl_order_sink_sap IMPLEMENTATION.
  METHOD constructor.
    IF io_authority IS BOUND.
      mo_authority = io_authority.
    ELSE.
      CREATE OBJECT mo_authority TYPE zcl_order_sink_authority_sap.
    ENDIF.
  ENDMETHOD.

  METHOD zif_order_sink~change_schedule_quantity.
    DATA ls_header_x TYPE ty_header_x.
    DATA ls_schedule TYPE ty_schedule.
    DATA ls_schedule_x TYPE ty_schedule_x.
    DATA lt_schedule TYPE tt_schedule.
    DATA lt_schedule_x TYPE tt_schedule_x.
    DATA lt_return TYPE tt_return.
    DATA ls_commit_return TYPE ty_return.
    DATA ls_rollback_return TYPE ty_return.
    DATA lv_bapi_subrc TYPE sy-subrc.
    DATA lv_commit_subrc TYPE sy-subrc.
    DATA lv_rollback_subrc TYPE sy-subrc.
    DATA lv_bapi_error TYPE abap_bool.
    DATA lv_commit_error TYPE abap_bool.
    DATA lv_rollback_error TYPE abap_bool.
    DATA lv_bapi_message TYPE c LENGTH 220.
    DATA lv_commit_message TYPE c LENGTH 220.
    DATA lv_sales_document_type TYPE zif_stock_allocation=>ty_sales_document_type.
    DATA lo_error TYPE REF TO zcx_stock_allocation.
    FIELD-SYMBOLS <ls_return> TYPE ty_return.

    lv_sales_document_type = to_upper( iv_sales_document_type ).
    IF iv_sales_document IS INITIAL
        OR lv_sales_document_type IS INITIAL
        OR iv_sales_item IS INITIAL
        OR iv_schedule_line IS INITIAL
        OR strlen( iv_sales_document ) <> zif_stock_allocation=>c_sap_document_length
        OR iv_sales_document CN '0123456789'
        OR iv_sales_document = '0000000000'
        OR iv_sales_item CN '0123456789'
        OR iv_schedule_line CN '0123456789'
        OR iv_quantity <= 0.
      raise_error( iv_message = 'Sales-order change input is invalid' ).
    ENDIF.

    IF mo_authority IS BOUND.
      TRY.
          mo_authority->check(
            iv_sales_document_type = lv_sales_document_type ).
        CATCH zcx_stock_allocation INTO lo_error.
          IF lo_error->message IS INITIAL.
            lo_error->message = 'Sales-order change authorization failed'.
          ENDIF.
          RAISE EXCEPTION lo_error.
      ENDTRY.
    ENDIF.

    ls_header_x-updateflag = 'U'.
    ls_schedule-itm_number = iv_sales_item.
    ls_schedule-sched_line = iv_schedule_line.
    ls_schedule-req_qty = iv_quantity.
    APPEND ls_schedule TO lt_schedule.
    ls_schedule_x-itm_number = iv_sales_item.
    ls_schedule_x-sched_line = iv_schedule_line.
    ls_schedule_x-updateflag = 'U'.
    ls_schedule_x-req_qty = 'X'.
    APPEND ls_schedule_x TO lt_schedule_x.

    CALL FUNCTION 'BAPI_SALESORDER_CHANGE'
      EXPORTING
        salesdocument    = iv_sales_document
        order_header_inx = ls_header_x
      TABLES
        schedule_lines   = lt_schedule
        schedule_linesx  = lt_schedule_x
        return           = lt_return
      EXCEPTIONS
        OTHERS           = 1.
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
          lv_bapi_message = 'Sales-order change BAPI returned invalid status'.
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
        lv_bapi_message = 'Sales-order change failed'.
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
      lv_commit_message = 'Sales-order change commit returned invalid status'.
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
        lv_commit_message = 'Sales-order change commit failed'.
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
