CLASS zcl_salloc_logger_sap DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_salloc_logger.
ENDCLASS.
CLASS zcl_salloc_logger_sap IMPLEMENTATION.
  METHOD zif_salloc_logger~log.
    TRY.
        DATA log_row TYPE zsalloc_log.
        log_row-mandt = sy-mandt.
        log_row-log_id = cl_system_uuid=>create_uuid_c32_static( ).
        GET TIME STAMP FIELD log_row-created_at.
        log_row-created_by = sy-uname.
        log_row-event = iv_event.
        log_row-matnr = iv_material.
        log_row-werks = iv_plant.
        log_row-order_id = iv_order_id.
        log_row-quantity = iv_quantity.
        INSERT zsalloc_log FROM @log_row.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_salloc_integration
            EXPORTING iv_operation = `LOG` iv_reason = `Audit insert failed`.
        ENDIF.
      CATCH cx_uuid_error cx_sy_open_sql_db INTO DATA(error).
        RAISE EXCEPTION TYPE zcx_salloc_integration
          EXPORTING iv_operation = `LOG` iv_reason = error->get_text( ).
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
