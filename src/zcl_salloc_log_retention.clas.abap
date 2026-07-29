CLASS zcl_salloc_log_retention DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        io_transaction TYPE REF TO zif_salloc_transaction
        io_authorization TYPE REF TO zif_salloc_authorization
        io_logger TYPE REF TO zif_salloc_logger.
    METHODS run
      IMPORTING
        iv_plant TYPE zif_salloc_types=>ty_plant
        iv_before TYPE timestampl
        iv_simulate TYPE abap_bool DEFAULT abap_true
      RETURNING
        VALUE(rv_affected) TYPE i
      RAISING
        zcx_salloc_invalid
        zcx_salloc_integration.
  PRIVATE SECTION.
    DATA mo_transaction TYPE REF TO zif_salloc_transaction.
    DATA mo_authorization TYPE REF TO zif_salloc_authorization.
    DATA mo_logger TYPE REF TO zif_salloc_logger.
ENDCLASS.

CLASS zcl_salloc_log_retention IMPLEMENTATION.
  METHOD constructor.
    mo_transaction = io_transaction.
    mo_authorization = io_authorization.
    mo_logger = io_logger.
  ENDMETHOD.

  METHOD run.
    IF iv_plant IS INITIAL OR iv_before IS INITIAL.
      RAISE EXCEPTION TYPE zcx_salloc_invalid
        EXPORTING iv_reason = `Plant and cutoff timestamp are required`.
    ENDIF.

    DATA activity TYPE zif_salloc_types=>ty_activity.
    IF iv_simulate = abap_true.
      activity = '03'.
    ELSE.
      activity = '02'.
    ENDIF.
    mo_authorization->check_authorization(
      iv_plant = iv_plant
      iv_activity = activity ).

    DATA transaction_started TYPE abap_bool.
    TRY.
        SELECT COUNT( * )
          FROM zsalloc_log
          WHERE werks = @iv_plant
            AND created_at < @iv_before
          INTO @rv_affected.

        IF iv_simulate = abap_true OR rv_affected = 0.
          RETURN.
        ENDIF.

        mo_transaction->begin( ).
        transaction_started = abap_true.
        DELETE FROM zsalloc_log
          WHERE werks = @iv_plant
            AND created_at < @iv_before.
        rv_affected = sy-dbcnt.
        DATA deleted_quantity TYPE zif_salloc_types=>ty_quantity.
        deleted_quantity = rv_affected.
        mo_logger->log(
          iv_event = 'LOG_RETENTION'
          iv_material = ''
          iv_plant = iv_plant
          iv_quantity = deleted_quantity ).
        mo_transaction->commit( ).
      CATCH zcx_salloc_integration INTO DATA(integration_error).
        IF transaction_started = abap_true.
          mo_transaction->rollback( ).
        ENDIF.
        RAISE EXCEPTION integration_error.
      CATCH cx_sy_open_sql_db INTO DATA(db_error).
        IF transaction_started = abap_true.
          mo_transaction->rollback( ).
        ENDIF.
        RAISE EXCEPTION TYPE zcx_salloc_integration
          EXPORTING
            iv_operation = `LOG_RETENTION`
            iv_reason = db_error->get_text( ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
