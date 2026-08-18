CLASS zcl_stock_movement_sap DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        io_authority TYPE REF TO zif_stock_movement_authority OPTIONAL.
    INTERFACES zif_stock_movement.
  PRIVATE SECTION.
    DATA mo_authority TYPE REF TO zif_stock_movement_authority.
    TYPES:
      BEGIN OF ty_header,
        pstng_date TYPE d,
        doc_date   TYPE d,
        header_txt TYPE c LENGTH 50,
      END OF ty_header.
    TYPES:
      BEGIN OF ty_code,
        gm_code TYPE c LENGTH 2,
      END OF ty_code.
    TYPES:
      BEGIN OF ty_item,
        material          TYPE c LENGTH 18,
        plant             TYPE c LENGTH 4,
        stge_loc          TYPE c LENGTH 4,
        move_type         TYPE c LENGTH 3,
        entry_qnt         TYPE p LENGTH 8 DECIMALS 3,
        entry_uom         TYPE c LENGTH 3,
        batch             TYPE c LENGTH 10,
        material_external TYPE c LENGTH 40,
      END OF ty_item.
    TYPES tt_items TYPE STANDARD TABLE OF ty_item WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_headret,
        mat_doc  TYPE c LENGTH 10,
        doc_year TYPE n LENGTH 4,
      END OF ty_headret.
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

CLASS zcl_stock_movement_sap IMPLEMENTATION.
  METHOD constructor.
    IF io_authority IS BOUND.
      mo_authority = io_authority.
    ELSE.
      CREATE OBJECT mo_authority TYPE zcl_stock_move_auth_sap.
    ENDIF.
  ENDMETHOD.

  METHOD zif_stock_movement~post_goods_issue.
    DATA ls_header TYPE ty_header.
    DATA ls_code TYPE ty_code.
    DATA ls_item TYPE ty_item.
    DATA ls_headret TYPE ty_headret.
    DATA lt_items TYPE tt_items.
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
        OR iv_quantity <= 0.
      raise_error( iv_message = 'Goods movement input is invalid' ).
    ENDIF.
    IF mo_authority IS BOUND.
      TRY.
          mo_authority->check(
            iv_plant            = iv_plant
            iv_storage_location = iv_storage_location
            iv_movement_type    = iv_movement_type ).
        CATCH zcx_stock_allocation INTO lo_error.
          IF lo_error->message IS INITIAL.
            lo_error->message = 'Goods movement authorization failed'.
          ENDIF.
          RAISE EXCEPTION lo_error.
      ENDTRY.
    ENDIF.

    ls_header-pstng_date = sy-datum.
    ls_header-doc_date = sy-datum.
    ls_code-gm_code = '03'.
    ls_item-material = iv_material.
    ls_item-material_external = iv_material.
    ls_item-plant = iv_plant.
    ls_item-stge_loc = iv_storage_location.
    ls_item-batch = iv_batch.
    ls_item-move_type = iv_movement_type.
    ls_item-entry_qnt = iv_quantity.
    ls_item-entry_uom = lv_unit.
    APPEND ls_item TO lt_items.

    CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
      EXPORTING
        goodsmvt_header  = ls_header
        goodsmvt_code    = ls_code
      IMPORTING
        goodsmvt_headret = ls_headret
      TABLES
        goodsmvt_item    = lt_items
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
          lv_bapi_message = 'Goods movement BAPI returned invalid status'.
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
    IF ls_headret-mat_doc IS NOT INITIAL
        AND ( strlen( ls_headret-mat_doc )
              <> zif_stock_allocation=>c_sap_document_length
          OR ls_headret-mat_doc CN '0123456789'
          OR ls_headret-mat_doc = '0000000000' )
        AND lv_bapi_message IS INITIAL.
      lv_bapi_message = 'Goods movement document returned by SAP is invalid'.
    ENDIF.
    IF ls_headret-doc_year IS NOT INITIAL
        AND ( strlen( ls_headret-doc_year )
              <> zif_stock_allocation=>c_fiscal_year_length
          OR ls_headret-doc_year CN '0123456789' )
        AND lv_bapi_message IS INITIAL.
      lv_bapi_message = 'Goods movement document year returned by SAP is invalid'.
    ENDIF.
    IF lv_bapi_error = abap_true
        OR lv_bapi_subrc <> 0
        OR ls_headret-mat_doc IS INITIAL
        OR strlen( ls_headret-mat_doc ) <> zif_stock_allocation=>c_sap_document_length
        OR ls_headret-mat_doc CN '0123456789'
        OR ls_headret-mat_doc = '0000000000'
        OR ls_headret-doc_year IS INITIAL
        OR strlen( ls_headret-doc_year ) <> zif_stock_allocation=>c_fiscal_year_length
        OR ls_headret-doc_year CN '0123456789'
        OR ls_headret-doc_year = '0000'.
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
        lv_bapi_message = 'Goods movement failed'.
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
      lv_commit_message = 'Goods movement commit returned invalid status'.
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
        lv_commit_message = 'Goods movement commit failed'.
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
    rs_document-number = ls_headret-mat_doc.
    rs_document-year = ls_headret-doc_year.
  ENDMETHOD.

  METHOD raise_error.
    DATA lo_error TYPE REF TO zcx_stock_allocation.
    CREATE OBJECT lo_error.
    lo_error->message = iv_message.
    RAISE EXCEPTION lo_error.
  ENDMETHOD.
ENDCLASS.
