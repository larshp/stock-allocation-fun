CLASS zcl_order_sink_sap DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_order_sink.
  PRIVATE SECTION.
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
ENDCLASS.

CLASS zcl_order_sink_sap IMPLEMENTATION.
  METHOD zif_order_sink~change_schedule_quantity.
    DATA ls_header_x TYPE ty_header_x.
    DATA ls_schedule TYPE ty_schedule.
    DATA ls_schedule_x TYPE ty_schedule_x.
    DATA lt_schedule TYPE tt_schedule.
    DATA lt_schedule_x TYPE tt_schedule_x.
    DATA lt_return TYPE tt_return.
    DATA lv_bapi_subrc TYPE sy-subrc.
    DATA lv_bapi_error TYPE abap_bool.
    DATA lv_bapi_message TYPE c LENGTH 220.
    DATA lo_error TYPE REF TO zcx_stock_allocation.
    FIELD-SYMBOLS <ls_return> TYPE ty_return.

    IF iv_sales_document IS INITIAL
        OR iv_sales_item IS INITIAL
        OR iv_schedule_line IS INITIAL
        OR iv_quantity <= 0.
      RAISE EXCEPTION TYPE zcx_stock_allocation.
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
        return           = lt_return.
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
      CREATE OBJECT lo_error.
      lo_error->message = lv_bapi_message.
      RAISE EXCEPTION lo_error.
    ENDIF.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = abap_true.
    IF sy-subrc <> 0.
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      RAISE EXCEPTION TYPE zcx_stock_allocation.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
