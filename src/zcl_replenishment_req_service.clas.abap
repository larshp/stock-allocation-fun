CLASS zcl_replenishment_req_service DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_requisition_type TYPE
      zif_purchase_requisition_api=>ty_requisition_type.
    TYPES ty_purchasing_group TYPE
      zif_purchase_requisition_api=>ty_purchasing_group.
    TYPES ty_purchasing_org TYPE
      zif_purchase_requisition_api=>ty_purchasing_org.
    TYPES:
      BEGIN OF ty_project_stock_shortfall,
        request_id    TYPE c LENGTH 30,
        wbs_element   TYPE c LENGTH 24,
        material      TYPE mard-matnr,
        plant         TYPE mard-werks,
        quantity      TYPE mard-labst,
        unit          TYPE mara-meins,
        delivery_date TYPE d,
      END OF ty_project_stock_shortfall.
    TYPES ty_project_stock_shortfalls TYPE STANDARD TABLE OF
      ty_project_stock_shortfall WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_suggestion_purchasing_control,
        source_suggestion_index TYPE i,
        purchasing_group        TYPE ty_purchasing_group,
        purchasing_org          TYPE ty_purchasing_org,
        purchasing_unit         TYPE eina-meins,
        order_to_base_num       TYPE eina-umrez,
        order_to_base_den       TYPE eina-umren,
      END OF ty_suggestion_purchasing_control.
    TYPES ty_suggestion_purchasing_controls TYPE STANDARD TABLE OF
      ty_suggestion_purchasing_control WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_quota_requisition_split,
        source_suggestion_index TYPE i,
        split                   TYPE zcl_repl_source_service=>ty_quota_split,
      END OF ty_quota_requisition_split.
    TYPES ty_quota_requisition_splits TYPE STANDARD TABLE OF
      ty_quota_requisition_split WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_requisition_delete_request,
        requisition_number TYPE zif_purchase_requisition_api=>ty_requisition_number,
        item_numbers       TYPE zif_purchase_requisition_api=>ty_requisition_item_numbers,
      END OF ty_requisition_delete_request.
    TYPES ty_requisition_delete_requests TYPE STANDARD TABLE OF
      ty_requisition_delete_request WITH EMPTY KEY.
    TYPES ty_delete_results TYPE STANDARD TABLE OF
      zif_purchase_requisition_api=>ty_result WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_atomic_delete_result,
        requisition_results TYPE ty_delete_results,
        commit_result       TYPE zif_purchase_requisition_api=>ty_commit_result,
        is_successful       TYPE abap_bool,
        is_test_run         TYPE abap_bool,
        is_committed        TYPE abap_bool,
        is_rolled_back      TYPE abap_bool,
      END OF ty_atomic_delete_result.
    TYPES:
      BEGIN OF ty_bulk_delete_result,
        requisition_results TYPE ty_delete_results,
        is_successful       TYPE abap_bool,
        is_test_run         TYPE abap_bool,
      END OF ty_bulk_delete_result.
    TYPES:
      BEGIN OF ty_requisition_create_request,
        requisition_type TYPE ty_requisition_type,
        items            TYPE zif_purchase_requisition_api=>ty_items,
      END OF ty_requisition_create_request.
    TYPES ty_requisition_create_requests TYPE STANDARD TABLE OF
      ty_requisition_create_request WITH EMPTY KEY.
    TYPES ty_create_results TYPE STANDARD TABLE OF
      zif_purchase_requisition_api=>ty_result WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_atomic_create_result,
        requisition_results TYPE ty_create_results,
        commit_result       TYPE zif_purchase_requisition_api=>ty_commit_result,
        is_successful       TYPE abap_bool,
        is_test_run         TYPE abap_bool,
        is_committed        TYPE abap_bool,
        is_rolled_back      TYPE abap_bool,
      END OF ty_atomic_create_result.
    TYPES:
      BEGIN OF ty_bulk_create_result,
        requisition_results TYPE ty_create_results,
        is_successful       TYPE abap_bool,
        is_test_run         TYPE abap_bool,
      END OF ty_bulk_create_result.
    TYPES:
      BEGIN OF ty_pr_update_request,
        requisition_number TYPE zif_purchase_requisition_api=>ty_requisition_number,
        item_updates       TYPE zif_purchase_requisition_api=>ty_item_updates,
      END OF ty_pr_update_request.
    TYPES ty_pr_update_requests TYPE STANDARD TABLE OF
      ty_pr_update_request WITH EMPTY KEY.
    TYPES ty_pr_update_results TYPE STANDARD TABLE OF
      zif_purchase_requisition_api=>ty_result WITH EMPTY KEY.
    TYPES ty_pr_read_results TYPE STANDARD TABLE OF
      zif_purchase_requisition_api=>ty_result WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_pr_bulk_read_result,
        requisition_results TYPE ty_pr_read_results,
        is_successful       TYPE abap_bool,
      END OF ty_pr_bulk_read_result.
    TYPES:
      BEGIN OF ty_pr_bulk_update_result,
        requisition_results TYPE ty_pr_update_results,
        commit_result       TYPE zif_purchase_requisition_api=>ty_commit_result,
        is_successful       TYPE abap_bool,
        is_test_run         TYPE abap_bool,
        is_committed        TYPE abap_bool,
        is_rolled_back      TYPE abap_bool,
      END OF ty_pr_bulk_update_result.

    METHODS constructor
      IMPORTING
        io_api TYPE REF TO zif_purchase_requisition_api.

    METHODS read_pr_items
      IMPORTING
        iv_requisition_number TYPE zif_purchase_requisition_api=>ty_requisition_number
      RETURNING
        VALUE(rs_result)      TYPE zif_purchase_requisition_api=>ty_result
      RAISING
        zcx_invalid_stock_request.

    METHODS read_pr_items_bulk
      IMPORTING
        it_requisition_numbers TYPE zif_purchase_requisition_api=>ty_requisition_numbers
      RETURNING
        VALUE(rs_result)       TYPE ty_pr_bulk_read_result
      RAISING
        zcx_invalid_stock_request.

    METHODS delete_all_pr_items
      IMPORTING
        iv_requisition_number TYPE zif_purchase_requisition_api=>ty_requisition_number
        iv_test_run           TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)      TYPE zif_purchase_requisition_api=>ty_result
      RAISING
        zcx_invalid_stock_request.

    METHODS delete_all_pr_items_bulk
      IMPORTING
        it_requisition_numbers TYPE zif_purchase_requisition_api=>ty_requisition_numbers
        iv_test_run            TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)       TYPE ty_bulk_delete_result
      RAISING
        zcx_invalid_stock_request.

    METHODS mark_pr_items_deleted
      IMPORTING
        iv_requisition_number TYPE zif_purchase_requisition_api=>ty_requisition_number
        it_item_numbers       TYPE zif_purchase_requisition_api=>ty_requisition_item_numbers
        iv_test_run           TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)      TYPE zif_purchase_requisition_api=>ty_result
      RAISING
        zcx_invalid_stock_request.

    METHODS update_pr_items
      IMPORTING
        iv_requisition_number TYPE zif_purchase_requisition_api=>ty_requisition_number
        it_item_updates       TYPE zif_purchase_requisition_api=>ty_item_updates
        iv_test_run           TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)      TYPE zif_purchase_requisition_api=>ty_result
      RAISING
        zcx_invalid_stock_request.

    METHODS update_pr_items_bulk
      IMPORTING
        it_requests      TYPE ty_pr_update_requests
        iv_test_run      TYPE abap_bool DEFAULT abap_false
        iv_atomic        TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE ty_pr_bulk_update_result
      RAISING
        zcx_invalid_stock_request.

    METHODS delete_pr_items_atomic
      IMPORTING
        it_requests      TYPE ty_requisition_delete_requests
        iv_test_run      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE ty_atomic_delete_result
      RAISING
        zcx_invalid_stock_request.

    METHODS delete_pr_items_bulk
      IMPORTING
        it_requests      TYPE ty_requisition_delete_requests
        iv_test_run      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE ty_bulk_delete_result
      RAISING
        zcx_invalid_stock_request.

    METHODS create_requisitions_atomic
      IMPORTING
        it_requests      TYPE ty_requisition_create_requests
        iv_test_run      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE ty_atomic_create_result
      RAISING
        zcx_invalid_stock_request.

    METHODS create_requisitions_bulk
      IMPORTING
        it_requests      TYPE ty_requisition_create_requests
        iv_test_run      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE ty_bulk_create_result
      RAISING
        zcx_invalid_stock_request.

    METHODS create_from_suggestions
      IMPORTING
        it_suggestions         TYPE zcl_prod_comp_service=>ty_comp_replenishments
        iv_requisition_type    TYPE ty_requisition_type DEFAULT 'NB'
        iv_purchasing_group    TYPE ty_purchasing_group OPTIONAL
        iv_purchasing_org      TYPE ty_purchasing_org OPTIONAL
        it_purchasing_controls TYPE ty_suggestion_purchasing_controls
          OPTIONAL
        iv_test_run            TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)       TYPE zif_purchase_requisition_api=>ty_result
      RAISING
        zcx_invalid_stock_request.

    METHODS create_from_proj_shortfalls
      IMPORTING
        it_shortfalls       TYPE ty_project_stock_shortfalls
        iv_requisition_type TYPE ty_requisition_type DEFAULT 'NB'
        iv_purchasing_group TYPE ty_purchasing_group OPTIONAL
        iv_purchasing_org   TYPE ty_purchasing_org OPTIONAL
        iv_test_run         TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)    TYPE zif_purchase_requisition_api=>ty_result
      RAISING
        zcx_invalid_stock_request.

    METHODS prepare_from_suggestions
      IMPORTING
        it_suggestions         TYPE zcl_prod_comp_service=>ty_comp_replenishments
        iv_requisition_type    TYPE ty_requisition_type DEFAULT 'NB'
        iv_purchasing_group    TYPE ty_purchasing_group OPTIONAL
        iv_purchasing_org      TYPE ty_purchasing_org OPTIONAL
        it_purchasing_controls TYPE ty_suggestion_purchasing_controls
          OPTIONAL
      RETURNING
        VALUE(rs_request)      TYPE zif_purchase_requisition_api=>ty_request
      RAISING
        zcx_invalid_stock_request.

    METHODS create_from_selected_sources
      IMPORTING
        it_suggestions             TYPE zcl_prod_comp_service=>ty_comp_replenishments
        it_selected_source_options TYPE zcl_repl_source_service=>ty_suggestion_source_options
        iv_requisition_type        TYPE ty_requisition_type DEFAULT 'NB'
        iv_purchasing_group        TYPE ty_purchasing_group OPTIONAL
        iv_purchasing_org          TYPE ty_purchasing_org OPTIONAL
        it_purchasing_controls     TYPE ty_suggestion_purchasing_controls
          OPTIONAL
        iv_test_run                TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)           TYPE zif_purchase_requisition_api=>ty_result
      RAISING
        zcx_invalid_stock_request.

    METHODS prepare_from_selected_sources
      IMPORTING
        it_suggestions             TYPE zcl_prod_comp_service=>ty_comp_replenishments
        it_selected_source_options TYPE zcl_repl_source_service=>ty_suggestion_source_options
        iv_requisition_type        TYPE ty_requisition_type DEFAULT 'NB'
        iv_purchasing_group        TYPE ty_purchasing_group OPTIONAL
        iv_purchasing_org          TYPE ty_purchasing_org OPTIONAL
        it_purchasing_controls     TYPE ty_suggestion_purchasing_controls
          OPTIONAL
      RETURNING
        VALUE(rs_request)          TYPE zif_purchase_requisition_api=>ty_request
      RAISING
        zcx_invalid_stock_request.

    METHODS create_from_quota_splits
      IMPORTING
        it_suggestions         TYPE zcl_prod_comp_service=>ty_comp_replenishments
        it_splits              TYPE ty_quota_requisition_splits
        iv_requisition_type    TYPE ty_requisition_type DEFAULT 'NB'
        iv_purchasing_group    TYPE ty_purchasing_group OPTIONAL
        iv_purchasing_org      TYPE ty_purchasing_org OPTIONAL
        it_purchasing_controls TYPE ty_suggestion_purchasing_controls
          OPTIONAL
        iv_test_run            TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)       TYPE zif_purchase_requisition_api=>ty_result
      RAISING
        zcx_invalid_stock_request.

    METHODS prepare_from_quota_splits
      IMPORTING
        it_suggestions         TYPE zcl_prod_comp_service=>ty_comp_replenishments
        it_splits              TYPE ty_quota_requisition_splits
        iv_requisition_type    TYPE ty_requisition_type DEFAULT 'NB'
        iv_purchasing_group    TYPE ty_purchasing_group OPTIONAL
        iv_purchasing_org      TYPE ty_purchasing_org OPTIONAL
        it_purchasing_controls TYPE ty_suggestion_purchasing_controls
          OPTIONAL
      RETURNING
        VALUE(rs_request)      TYPE zif_purchase_requisition_api=>ty_request
      RAISING
        zcx_invalid_stock_request.

  PRIVATE SECTION.
    METHODS convert_to_purchasing_unit
      IMPORTING
        iv_base_quantity   TYPE mard-labst
        iv_numerator       TYPE eina-umrez
        iv_denominator     TYPE eina-umren
      RETURNING
        VALUE(rv_quantity) TYPE mard-labst
      RAISING
        zcx_invalid_stock_request.

    METHODS complete_write
      IMPORTING
        is_request       TYPE zif_purchase_requisition_api=>ty_request
        is_result        TYPE zif_purchase_requisition_api=>ty_result
      RETURNING
        VALUE(rs_result) TYPE zif_purchase_requisition_api=>ty_result.

    METHODS submit_prepared_request
      IMPORTING
        is_request       TYPE zif_purchase_requisition_api=>ty_request
        iv_test_run      TYPE abap_bool
      RETURNING
        VALUE(rs_result) TYPE zif_purchase_requisition_api=>ty_result
      RAISING
        zcx_invalid_stock_request.

    METHODS validate_delete_requests
      IMPORTING
        it_requests TYPE ty_requisition_delete_requests
        iv_test_run TYPE abap_bool
      RAISING
        zcx_invalid_stock_request.

    METHODS validate_create_requests
      IMPORTING
        it_requests TYPE ty_requisition_create_requests
        iv_test_run TYPE abap_bool
      RAISING
        zcx_invalid_stock_request.

    METHODS validate_pr_item_updates
      IMPORTING
        iv_requisition_number TYPE zif_purchase_requisition_api=>ty_requisition_number
        it_item_updates       TYPE zif_purchase_requisition_api=>ty_item_updates
        iv_test_run           TYPE abap_bool
      RAISING
        zcx_invalid_stock_request.

    METHODS validate_pr_update_requests
      IMPORTING
        it_requests TYPE ty_pr_update_requests
        iv_test_run TYPE abap_bool
        iv_atomic   TYPE abap_bool
      RAISING
        zcx_invalid_stock_request.

    DATA mo_api TYPE REF TO zif_purchase_requisition_api.
ENDCLASS.

CLASS zcl_replenishment_req_service IMPLEMENTATION.

  METHOD constructor.
    mo_api = io_api.
  ENDMETHOD.

  METHOD read_pr_items.
    IF iv_requisition_number IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    rs_result = mo_api->read_items(
      iv_requisition_number = iv_requisition_number ).
    rs_result-requisition_number = iv_requisition_number.
  ENDMETHOD.

  METHOD read_pr_items_bulk.
    TYPES ty_requisition_number TYPE
      zif_purchase_requisition_api=>ty_requisition_number.
    DATA lt_seen_requisitions TYPE HASHED TABLE OF ty_requisition_number
      WITH UNIQUE KEY table_line.

    LOOP AT it_requisition_numbers INTO DATA(lv_requisition_number).
      INSERT lv_requisition_number INTO TABLE lt_seen_requisitions.
      IF lv_requisition_number IS INITIAL OR sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    rs_result-is_successful = abap_true.
    LOOP AT it_requisition_numbers INTO lv_requisition_number.
      DATA(ls_read_result) = read_pr_items(
        iv_requisition_number = lv_requisition_number ).
      APPEND ls_read_result TO rs_result-requisition_results.
      IF ls_read_result-is_successful = abap_false.
        rs_result-is_successful = abap_false.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD delete_all_pr_items.
    DATA ls_read_result TYPE zif_purchase_requisition_api=>ty_result.
    DATA lt_item_numbers TYPE zif_purchase_requisition_api=>ty_requisition_item_numbers.
    DATA lt_delete_messages TYPE zif_purchase_requisition_api=>ty_messages.

    IF iv_requisition_number IS INITIAL
        OR ( iv_test_run <> abap_true AND iv_test_run <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    ls_read_result = read_pr_items(
      iv_requisition_number = iv_requisition_number ).
    IF ls_read_result-is_successful = abap_false.
      rs_result = ls_read_result.
      rs_result-is_test_run = iv_test_run.
      RETURN.
    ENDIF.

    LOOP AT ls_read_result-requisition_items INTO DATA(ls_requisition_item).
      IF ls_requisition_item-deletion_indicator IS INITIAL.
        APPEND ls_requisition_item-item_number TO lt_item_numbers.
      ENDIF.
    ENDLOOP.

    IF lt_item_numbers IS INITIAL.
      rs_result = ls_read_result.
      rs_result-is_test_run = iv_test_run.
      rs_result-is_successful = abap_true.
      RETURN.
    ENDIF.

    rs_result = mark_pr_items_deleted(
      iv_requisition_number = iv_requisition_number
      it_item_numbers       = lt_item_numbers
      iv_test_run           = iv_test_run ).
    lt_delete_messages = rs_result-messages.
    rs_result-requisition_items = ls_read_result-requisition_items.
    rs_result-messages = ls_read_result-messages.
    APPEND LINES OF lt_delete_messages TO rs_result-messages.
  ENDMETHOD.

  METHOD delete_all_pr_items_bulk.
    TYPES ty_requisition_number TYPE
      zif_purchase_requisition_api=>ty_requisition_number.
    DATA lt_seen_requisitions TYPE HASHED TABLE OF ty_requisition_number
      WITH UNIQUE KEY table_line.

    IF it_requisition_numbers IS INITIAL
        OR ( iv_test_run <> abap_true AND iv_test_run <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT it_requisition_numbers INTO DATA(lv_requisition_number).
      INSERT lv_requisition_number INTO TABLE lt_seen_requisitions.
      IF lv_requisition_number IS INITIAL OR sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    rs_result-is_successful = abap_true.
    rs_result-is_test_run = iv_test_run.
    LOOP AT it_requisition_numbers INTO lv_requisition_number.
      DATA(ls_delete_result) = delete_all_pr_items(
        iv_requisition_number = lv_requisition_number
        iv_test_run           = iv_test_run ).
      APPEND ls_delete_result TO rs_result-requisition_results.
      IF ls_delete_result-is_successful = abap_false.
        rs_result-is_successful = abap_false.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD mark_pr_items_deleted.
    TYPES ty_item_number TYPE
      zif_purchase_requisition_api=>ty_requisition_item_number.
    DATA lt_seen_item_numbers TYPE HASHED TABLE OF ty_item_number
      WITH UNIQUE KEY table_line.
    DATA ls_request TYPE zif_purchase_requisition_api=>ty_request.

    IF iv_requisition_number IS INITIAL
        OR it_item_numbers IS INITIAL
        OR ( iv_test_run <> abap_true AND iv_test_run <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    ls_request-is_test_run = iv_test_run.
    LOOP AT it_item_numbers INTO DATA(lv_item_number).
      INSERT lv_item_number INTO TABLE lt_seen_item_numbers.
      IF lv_item_number IS INITIAL OR sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      APPEND VALUE #(
        item_number = lv_item_number ) TO ls_request-items.
    ENDLOOP.

    DATA(ls_write_result) = mo_api->mark_items_deleted(
      iv_requisition_number = iv_requisition_number
      it_item_numbers       = it_item_numbers
      iv_test_run           = iv_test_run ).
    ls_write_result-requisition_number = iv_requisition_number.
    ls_write_result-submitted_item_numbers = it_item_numbers.
    rs_result = complete_write(
      is_request = ls_request
      is_result  = ls_write_result ).
  ENDMETHOD.

  METHOD update_pr_items.
    DATA ls_request TYPE zif_purchase_requisition_api=>ty_request.

    validate_pr_item_updates(
      iv_requisition_number = iv_requisition_number
      it_item_updates       = it_item_updates
      iv_test_run           = iv_test_run ).

    ls_request-is_test_run = iv_test_run.
    LOOP AT it_item_updates INTO DATA(ls_item_update).
      APPEND VALUE #(
        item_number = ls_item_update-item_number ) TO ls_request-items.
    ENDLOOP.

    DATA(ls_write_result) = mo_api->change_items(
      iv_requisition_number = iv_requisition_number
      it_item_updates       = it_item_updates
      iv_test_run           = iv_test_run ).
    ls_write_result-requisition_number = iv_requisition_number.
    ls_write_result-submitted_item_updates = it_item_updates.
    rs_result = complete_write(
      is_request = ls_request
      is_result  = ls_write_result ).
  ENDMETHOD.

  METHOD update_pr_items_bulk.
    DATA lv_request_index TYPE i.
    DATA lv_pending_index TYPE i.
    DATA lv_has_failure TYPE abap_bool.

    validate_pr_update_requests(
      it_requests = it_requests
      iv_test_run = iv_test_run
      iv_atomic   = iv_atomic ).

    rs_result-is_test_run = iv_test_run.
    IF iv_atomic = abap_false.
      rs_result-is_successful = abap_true.
      LOOP AT it_requests INTO DATA(ls_update_request).
        DATA(ls_item_result) = update_pr_items(
          iv_requisition_number = ls_update_request-requisition_number
          it_item_updates       = ls_update_request-item_updates
          iv_test_run           = iv_test_run ).
        APPEND ls_item_result TO rs_result-requisition_results.
        IF ls_item_result-is_successful = abap_false.
          rs_result-is_successful = abap_false.
        ENDIF.
      ENDLOOP.
      IF rs_result-is_successful = abap_true
          AND iv_test_run = abap_false.
        rs_result-is_committed = abap_true.
      ENDIF.
      RETURN.
    ENDIF.

    LOOP AT it_requests INTO ls_update_request.
      lv_request_index = sy-tabix.
      DATA(ls_atomic_item_result) = mo_api->change_items(
        iv_requisition_number = ls_update_request-requisition_number
        it_item_updates       = ls_update_request-item_updates
        iv_test_run           = iv_test_run ).
      ls_atomic_item_result-requisition_number =
        ls_update_request-requisition_number.
      ls_atomic_item_result-submitted_item_updates =
        ls_update_request-item_updates.
      ls_atomic_item_result-is_test_run = iv_test_run.
      ls_atomic_item_result-is_committed = abap_false.
      ls_atomic_item_result-bapi_was_called = abap_true.

      DATA(lv_has_error_message) = abap_false.
      LOOP AT ls_atomic_item_result-messages
          ASSIGNING FIELD-SYMBOL(<ls_update_message>).
        IF ( <ls_update_message>-parameter = 'PRITEM'
            OR <ls_update_message>-parameter = 'PRITEMX' )
            AND <ls_update_message>-row > 0.
          READ TABLE ls_update_request-item_updates
            INDEX CONV i( <ls_update_message>-row )
            INTO DATA(ls_message_update).
          IF sy-subrc = 0.
            <ls_update_message>-item_number = ls_message_update-item_number.
          ENDIF.
        ENDIF.
        IF <ls_update_message>-type = 'A'
            OR <ls_update_message>-type = 'E'
            OR <ls_update_message>-type = 'X'.
          lv_has_failure = abap_true.
          lv_has_error_message = abap_true.
        ENDIF.
      ENDLOOP.
      IF ls_atomic_item_result-is_successful = abap_false.
        lv_has_failure = abap_true.
        IF lv_has_error_message = abap_false.
          APPEND VALUE #(
            type    = 'E'
            message = 'Purchase requisition item update failed without an error message' )
            TO ls_atomic_item_result-messages.
        ENDIF.
      ENDIF.
      ls_atomic_item_result-is_successful = xsdbool(
        lv_has_failure = abap_false ).
      APPEND ls_atomic_item_result TO rs_result-requisition_results.

      IF lv_has_failure = abap_true.
        lv_pending_index = lv_request_index + 1.
        LOOP AT it_requests INTO DATA(ls_pending_request)
            FROM lv_pending_index.
          APPEND VALUE #(
            requisition_number     = ls_pending_request-requisition_number
            submitted_item_updates = ls_pending_request-item_updates
            is_test_run            = iv_test_run
            messages               = VALUE #(
              ( type    = 'I'
                message = 'Not attempted because an earlier requisition failed' ) ) )
            TO rs_result-requisition_results.
        ENDLOOP.
        LOOP AT rs_result-requisition_results
            ASSIGNING FIELD-SYMBOL(<ls_update_result>).
          <ls_update_result>-is_successful = abap_false.
          <ls_update_result>-is_committed = abap_false.
        ENDLOOP.
        mo_api->rollback( ).
        rs_result-is_rolled_back = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.

    IF iv_test_run = abap_true.
      rs_result-is_successful = abap_true.
      LOOP AT rs_result-requisition_results
          ASSIGNING <ls_update_result>.
        <ls_update_result>-is_successful = abap_true.
      ENDLOOP.
      RETURN.
    ENDIF.

    rs_result-commit_result = mo_api->commit( ).
    DATA(lv_commit_failed) = xsdbool(
      rs_result-commit_result-is_successful = abap_false ).
    IF rs_result-commit_result-message-type = 'A'
        OR rs_result-commit_result-message-type = 'E'
        OR rs_result-commit_result-message-type = 'X'.
      lv_commit_failed = abap_true.
    ENDIF.
    IF lv_commit_failed = abap_true.
      IF rs_result-commit_result-message-message IS INITIAL.
        rs_result-commit_result-message-type = 'E'.
        rs_result-commit_result-message-message =
          'Purchase requisition item update commit failed'.
      ENDIF.
      LOOP AT rs_result-requisition_results
          ASSIGNING <ls_update_result>.
        <ls_update_result>-is_successful = abap_false.
        <ls_update_result>-is_committed = abap_false.
      ENDLOOP.
      mo_api->rollback( ).
      rs_result-is_rolled_back = abap_true.
      RETURN.
    ENDIF.

    rs_result-is_successful = abap_true.
    rs_result-is_committed = abap_true.
    LOOP AT rs_result-requisition_results
        ASSIGNING <ls_update_result>.
      <ls_update_result>-is_successful = abap_true.
      <ls_update_result>-is_committed = abap_true.
    ENDLOOP.
  ENDMETHOD.

  METHOD delete_pr_items_atomic.
    DATA lv_request_index TYPE i.
    DATA lv_pending_index TYPE i.
    DATA lv_has_failure TYPE abap_bool.

    validate_delete_requests(
      it_requests = it_requests
      iv_test_run = iv_test_run ).

    rs_result-is_test_run = iv_test_run.
    LOOP AT it_requests INTO DATA(ls_delete_request).
      lv_request_index = sy-tabix.
      DATA(ls_item_result) = mo_api->mark_items_deleted(
        iv_requisition_number = ls_delete_request-requisition_number
        it_item_numbers       = ls_delete_request-item_numbers
        iv_test_run           = iv_test_run ).
      ls_item_result-requisition_number =
        ls_delete_request-requisition_number.
      ls_item_result-submitted_item_numbers =
        ls_delete_request-item_numbers.
      ls_item_result-is_test_run = iv_test_run.
      ls_item_result-is_committed = abap_false.
      ls_item_result-bapi_was_called = abap_true.

      DATA(lv_has_error_message) = abap_false.
      LOOP AT ls_item_result-messages ASSIGNING FIELD-SYMBOL(<ls_message>).
        IF ( <ls_message>-parameter = 'PRITEM'
            OR <ls_message>-parameter = 'PRITEMX' )
            AND <ls_message>-row > 0.
          READ TABLE ls_delete_request-item_numbers
            INDEX CONV i( <ls_message>-row )
            INTO <ls_message>-item_number.
        ENDIF.
        IF <ls_message>-type = 'A'
            OR <ls_message>-type = 'E'
            OR <ls_message>-type = 'X'.
          lv_has_failure = abap_true.
          lv_has_error_message = abap_true.
        ENDIF.
      ENDLOOP.
      IF ls_item_result-is_successful = abap_false.
        lv_has_failure = abap_true.
        IF lv_has_error_message = abap_false.
          APPEND VALUE #(
            type    = 'E'
            message = 'Purchase requisition item deletion failed without an error message' )
            TO ls_item_result-messages.
        ENDIF.
      ENDIF.
      ls_item_result-is_successful = xsdbool( lv_has_failure = abap_false ).
      APPEND ls_item_result TO rs_result-requisition_results.

      IF lv_has_failure = abap_true.
        lv_pending_index = lv_request_index + 1.
        LOOP AT it_requests INTO DATA(ls_pending_request)
            FROM lv_pending_index.
          APPEND VALUE #(
            requisition_number     = ls_pending_request-requisition_number
            submitted_item_numbers = ls_pending_request-item_numbers
            is_test_run            = iv_test_run
            messages               = VALUE #(
              ( type    = 'I'
                message = 'Not attempted because an earlier requisition failed' ) ) )
            TO rs_result-requisition_results.
        ENDLOOP.
        LOOP AT rs_result-requisition_results
            ASSIGNING FIELD-SYMBOL(<ls_delete_result>).
          <ls_delete_result>-is_successful = abap_false.
          <ls_delete_result>-is_committed = abap_false.
        ENDLOOP.
        mo_api->rollback( ).
        rs_result-is_rolled_back = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.

    IF iv_test_run = abap_true.
      rs_result-is_successful = abap_true.
      LOOP AT rs_result-requisition_results
          ASSIGNING <ls_delete_result>.
        <ls_delete_result>-is_successful = abap_true.
      ENDLOOP.
      RETURN.
    ENDIF.

    rs_result-commit_result = mo_api->commit( ).
    DATA(lv_commit_failed) = xsdbool(
      rs_result-commit_result-is_successful = abap_false ).
    IF rs_result-commit_result-message-type = 'A'
        OR rs_result-commit_result-message-type = 'E'
        OR rs_result-commit_result-message-type = 'X'.
      lv_commit_failed = abap_true.
    ENDIF.
    IF lv_commit_failed = abap_true.
      IF rs_result-commit_result-message-message IS INITIAL.
        rs_result-commit_result-message-type = 'E'.
        rs_result-commit_result-message-message =
          'Purchase requisition deletion commit failed'.
      ENDIF.
      LOOP AT rs_result-requisition_results
          ASSIGNING <ls_delete_result>.
        <ls_delete_result>-is_successful = abap_false.
        <ls_delete_result>-is_committed = abap_false.
      ENDLOOP.
      mo_api->rollback( ).
      rs_result-is_rolled_back = abap_true.
      RETURN.
    ENDIF.

    rs_result-is_successful = abap_true.
    rs_result-is_committed = abap_true.
    LOOP AT rs_result-requisition_results
        ASSIGNING <ls_delete_result>.
      <ls_delete_result>-is_successful = abap_true.
      <ls_delete_result>-is_committed = abap_true.
    ENDLOOP.
  ENDMETHOD.

  METHOD delete_pr_items_bulk.
    validate_delete_requests(
      it_requests = it_requests
      iv_test_run = iv_test_run ).

    rs_result-is_test_run = iv_test_run.
    rs_result-is_successful = abap_true.
    LOOP AT it_requests INTO DATA(ls_delete_request).
      DATA ls_request TYPE zif_purchase_requisition_api=>ty_request.
      CLEAR ls_request.
      ls_request-is_test_run = iv_test_run.
      LOOP AT ls_delete_request-item_numbers INTO DATA(lv_item_number).
        APPEND VALUE #(
          item_number = lv_item_number ) TO ls_request-items.
      ENDLOOP.

      DATA(ls_write_result) = mo_api->mark_items_deleted(
        iv_requisition_number = ls_delete_request-requisition_number
        it_item_numbers       = ls_delete_request-item_numbers
        iv_test_run           = iv_test_run ).
      ls_write_result-requisition_number =
        ls_delete_request-requisition_number.
      ls_write_result-submitted_item_numbers =
        ls_delete_request-item_numbers.
      DATA(ls_result) = complete_write(
        is_request = ls_request
        is_result  = ls_write_result ).
      APPEND ls_result TO rs_result-requisition_results.
      IF ls_result-is_successful = abap_false.
        rs_result-is_successful = abap_false.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD create_requisitions_atomic.
    DATA lv_request_index TYPE i.
    DATA lv_pending_index TYPE i.
    DATA lv_has_failure TYPE abap_bool.

    validate_create_requests(
      it_requests = it_requests
      iv_test_run = iv_test_run ).

    rs_result-is_test_run = iv_test_run.
    LOOP AT it_requests INTO DATA(ls_create_request).
      lv_request_index = sy-tabix.
      DATA(ls_request) = VALUE zif_purchase_requisition_api=>ty_request(
        requisition_type = ls_create_request-requisition_type
        is_test_run      = iv_test_run
        items            = ls_create_request-items ).
      DATA(ls_create_result) = mo_api->create_requisition(
        is_request = ls_request ).
      ls_create_result-submitted_items = ls_request-items.
      ls_create_result-is_test_run = iv_test_run.
      ls_create_result-is_committed = abap_false.
      ls_create_result-bapi_was_called = abap_true.

      DATA(lv_has_error_message) = abap_false.
      LOOP AT ls_create_result-messages
          ASSIGNING FIELD-SYMBOL(<ls_create_message>).
        IF ( <ls_create_message>-parameter = 'PRITEM'
            OR <ls_create_message>-parameter = 'PRITEMX' )
            AND <ls_create_message>-row > 0.
          READ TABLE ls_request-items
            INDEX CONV i( <ls_create_message>-row )
            INTO DATA(ls_item_message).
          IF sy-subrc = 0.
            <ls_create_message>-item_number = ls_item_message-item_number.
            <ls_create_message>-source_suggestion_index =
              ls_item_message-source_suggestion_index.
          ENDIF.
        ENDIF.
        IF <ls_create_message>-type = 'A'
            OR <ls_create_message>-type = 'E'
            OR <ls_create_message>-type = 'X'.
          lv_has_failure = abap_true.
          lv_has_error_message = abap_true.
        ENDIF.
      ENDLOOP.
      IF ls_create_result-is_successful = abap_false.
        lv_has_failure = abap_true.
        IF lv_has_error_message = abap_false.
          APPEND VALUE #(
            type    = 'E'
            message = 'Purchase requisition create failed without an error message' )
            TO ls_create_result-messages.
        ENDIF.
      ENDIF.
      IF lv_has_failure = abap_false
          AND iv_test_run = abap_false
          AND ls_create_result-requisition_number IS INITIAL.
        lv_has_failure = abap_true.
        APPEND VALUE #(
          type    = 'E'
          message = 'Purchase requisition create returned no document number' )
          TO ls_create_result-messages.
      ENDIF.
      ls_create_result-is_successful = xsdbool( lv_has_failure = abap_false ).
      APPEND ls_create_result TO rs_result-requisition_results.

      IF lv_has_failure = abap_true.
        lv_pending_index = lv_request_index + 1.
        LOOP AT it_requests INTO DATA(ls_pending_request)
            FROM lv_pending_index.
          APPEND VALUE #(
            submitted_items = ls_pending_request-items
            is_test_run     = iv_test_run
            messages        = VALUE #(
              ( type    = 'I'
                message = 'Not attempted because an earlier requisition failed' ) ) )
            TO rs_result-requisition_results.
        ENDLOOP.
        LOOP AT rs_result-requisition_results
            ASSIGNING FIELD-SYMBOL(<ls_create_result_row>).
          CLEAR <ls_create_result_row>-requisition_number.
          <ls_create_result_row>-is_successful = abap_false.
          <ls_create_result_row>-is_committed = abap_false.
        ENDLOOP.
        mo_api->rollback( ).
        rs_result-is_rolled_back = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.

    IF iv_test_run = abap_true.
      rs_result-is_successful = abap_true.
      LOOP AT rs_result-requisition_results
          ASSIGNING <ls_create_result_row>.
        <ls_create_result_row>-is_successful = abap_true.
      ENDLOOP.
      RETURN.
    ENDIF.

    rs_result-commit_result = mo_api->commit( ).
    DATA(lv_commit_failed) = xsdbool(
      rs_result-commit_result-is_successful = abap_false ).
    IF rs_result-commit_result-message-type = 'A'
        OR rs_result-commit_result-message-type = 'E'
        OR rs_result-commit_result-message-type = 'X'.
      lv_commit_failed = abap_true.
    ENDIF.
    IF lv_commit_failed = abap_true.
      IF rs_result-commit_result-message-message IS INITIAL.
        rs_result-commit_result-message-type = 'E'.
        rs_result-commit_result-message-message =
          'Purchase requisition create commit failed'.
      ENDIF.
      LOOP AT rs_result-requisition_results
          ASSIGNING <ls_create_result_row>.
        CLEAR <ls_create_result_row>-requisition_number.
        <ls_create_result_row>-is_successful = abap_false.
        <ls_create_result_row>-is_committed = abap_false.
      ENDLOOP.
      mo_api->rollback( ).
      rs_result-is_rolled_back = abap_true.
      RETURN.
    ENDIF.

    rs_result-is_successful = abap_true.
    rs_result-is_committed = abap_true.
    LOOP AT rs_result-requisition_results
        ASSIGNING <ls_create_result_row>.
      <ls_create_result_row>-is_successful = abap_true.
      <ls_create_result_row>-is_committed = abap_true.
    ENDLOOP.
  ENDMETHOD.

  METHOD create_requisitions_bulk.
    validate_create_requests(
      it_requests = it_requests
      iv_test_run = iv_test_run ).

    rs_result-is_test_run = iv_test_run.
    rs_result-is_successful = abap_true.
    LOOP AT it_requests INTO DATA(ls_create_request).
      DATA(ls_request) = VALUE zif_purchase_requisition_api=>ty_request(
        requisition_type = ls_create_request-requisition_type
        is_test_run      = iv_test_run
        items            = ls_create_request-items ).
      DATA(ls_write_result) = mo_api->create_requisition(
        is_request = ls_request ).
      ls_write_result-submitted_items = ls_request-items.
      ls_write_result-is_test_run = iv_test_run.
      DATA(ls_result) = complete_write(
        is_request = ls_request
        is_result  = ls_write_result ).
      APPEND ls_result TO rs_result-requisition_results.
      IF ls_result-is_successful = abap_false.
        rs_result-is_successful = abap_false.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD prepare_from_suggestions.
    IF iv_requisition_type IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    DATA ls_request TYPE zif_purchase_requisition_api=>ty_request.
    DATA lv_item_number TYPE n LENGTH 5.
    DATA lv_receipt_count TYPE i.
    DATA lv_receipt_item_quantity TYPE mard-labst.
    DATA lv_suggestion_index TYPE i.
    DATA lv_item_purchasing_group TYPE ty_purchasing_group.
    DATA lv_item_purchasing_org TYPE ty_purchasing_org.
    DATA lv_item_unit TYPE eina-meins.
    DATA lv_order_unit_numerator TYPE eina-umrez.
    DATA lv_order_unit_denominator TYPE eina-umren.
    DATA lv_item_quantity TYPE mard-labst.
    DATA lt_purchasing_controls TYPE HASHED TABLE OF
      ty_suggestion_purchasing_control
      WITH UNIQUE KEY source_suggestion_index.
    ls_request-requisition_type = iv_requisition_type.

    LOOP AT it_purchasing_controls INTO DATA(ls_purchasing_control).
      IF ls_purchasing_control-source_suggestion_index <= 0
          OR ls_purchasing_control-source_suggestion_index
            > lines( it_suggestions )
          OR ( ls_purchasing_control-purchasing_group IS INITIAL
            AND ls_purchasing_control-purchasing_org IS INITIAL
            AND ls_purchasing_control-purchasing_unit IS INITIAL )
          OR ( ls_purchasing_control-purchasing_unit IS INITIAL
            AND ( ls_purchasing_control-order_to_base_num
                IS NOT INITIAL
              OR ls_purchasing_control-order_to_base_den
                IS NOT INITIAL ) ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      READ TABLE it_suggestions
        INDEX ls_purchasing_control-source_suggestion_index
        INTO DATA(ls_control_suggestion).
      IF sy-subrc <> 0
          OR ls_control_suggestion-suggested_base_quantity <= 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_purchasing_control INTO TABLE lt_purchasing_controls.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT it_suggestions INTO DATA(ls_suggestion).
      lv_suggestion_index = sy-tabix.
      IF ls_suggestion-material IS INITIAL
          OR ls_suggestion-plant IS INITIAL
          OR ls_suggestion-base_unit IS INITIAL
          OR ls_suggestion-required_date IS INITIAL
          OR ls_suggestion-suggested_base_quantity < 0
          OR ls_suggestion-suggested_receipt_count < 0
          OR ls_suggestion-final_receipt_base_quantity < 0
          OR ls_suggestion-maximum_base_quantity < 0
          OR ls_suggestion-fixed_base_quantity < 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      IF ls_suggestion-source_vendor IS NOT INITIAL
          OR ls_suggestion-source_purchasing_org IS NOT INITIAL
          OR ls_suggestion-source_info_record IS NOT INITIAL
          OR ls_suggestion-source_category IS NOT INITIAL
          OR ls_suggestion-source_agreement IS NOT INITIAL
          OR ls_suggestion-source_agreement_item IS NOT INITIAL.
        IF ls_suggestion-source_agreement IS NOT INITIAL
            OR ls_suggestion-source_agreement_item IS NOT INITIAL.
          IF ls_suggestion-source_agreement IS INITIAL
              OR ls_suggestion-source_agreement_item IS INITIAL
              OR ls_suggestion-source_vendor IS INITIAL
              OR ls_suggestion-source_purchasing_org IS INITIAL
              OR ls_suggestion-source_info_record IS NOT INITIAL
              OR ls_suggestion-source_category IS NOT INITIAL.
            RAISE EXCEPTION TYPE zcx_invalid_stock_request.
          ENDIF.
        ELSEIF ls_suggestion-source_vendor IS INITIAL
            OR ls_suggestion-source_purchasing_org IS INITIAL
            OR ls_suggestion-source_info_record IS INITIAL
            OR ls_suggestion-source_category IS INITIAL.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
      ENDIF.
      IF ls_suggestion-suggested_base_quantity = 0.
        IF ls_suggestion-suggested_receipt_count <> 0
            OR ls_suggestion-final_receipt_base_quantity <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        CONTINUE.
      ENDIF.
      lv_item_purchasing_group = iv_purchasing_group.
      lv_item_purchasing_org = iv_purchasing_org.
      lv_item_unit = ls_suggestion-base_unit.
      lv_order_unit_numerator = 1.
      lv_order_unit_denominator = 1.
      IF ls_suggestion-source_purchasing_org IS NOT INITIAL.
        lv_item_purchasing_org =
          ls_suggestion-source_purchasing_org.
      ENDIF.
      READ TABLE lt_purchasing_controls
        INTO ls_purchasing_control
        WITH TABLE KEY source_suggestion_index = lv_suggestion_index.
      IF sy-subrc = 0.
        IF ls_purchasing_control-purchasing_group IS NOT INITIAL.
          lv_item_purchasing_group =
            ls_purchasing_control-purchasing_group.
        ENDIF.
        IF ls_purchasing_control-purchasing_org IS NOT INITIAL.
          lv_item_purchasing_org = ls_purchasing_control-purchasing_org.
        ENDIF.
        IF ls_purchasing_control-purchasing_unit IS NOT INITIAL.
          lv_item_unit = ls_purchasing_control-purchasing_unit.
          IF lv_item_unit = ls_suggestion-base_unit.
            IF ( ls_purchasing_control-order_to_base_num
                  IS NOT INITIAL
                AND ls_purchasing_control-order_to_base_num
                  <> 1 )
                OR ( ls_purchasing_control-order_to_base_den
                  IS NOT INITIAL
                AND ls_purchasing_control-order_to_base_den
                  <> 1 ).
              RAISE EXCEPTION TYPE zcx_invalid_stock_request.
            ENDIF.
          ELSE.
            IF ls_purchasing_control-order_to_base_num <= 0
                OR ls_purchasing_control-order_to_base_den
                  <= 0.
              RAISE EXCEPTION TYPE zcx_invalid_stock_request.
            ENDIF.
            lv_order_unit_numerator =
              ls_purchasing_control-order_to_base_num.
            lv_order_unit_denominator =
              ls_purchasing_control-order_to_base_den.
          ENDIF.
        ENDIF.
      ENDIF.
      IF ls_suggestion-procurement_type <> 'F'
          OR ls_suggestion-special_procurement_key IS NOT INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      IF ls_suggestion-suggested_receipt_count <= 0
          OR ls_suggestion-suggested_receipt_count > 9999
          OR ls_suggestion-final_receipt_base_quantity <= 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      lv_receipt_count = CONV i(
        ls_suggestion-suggested_receipt_count ).
      IF lv_receipt_count > 9999 - lines( ls_request-items ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      IF lv_receipt_count = 1.
        IF ls_suggestion-final_receipt_base_quantity
            <> ls_suggestion-suggested_base_quantity.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        lv_receipt_item_quantity =
          ls_suggestion-final_receipt_base_quantity.
      ELSEIF ls_suggestion-fixed_base_quantity > 0.
        IF ls_suggestion-rounding_profile IS INITIAL.
          IF ls_suggestion-final_receipt_base_quantity
                <> ls_suggestion-fixed_base_quantity
              OR ls_suggestion-suggested_base_quantity
                <> ls_suggestion-fixed_base_quantity * lv_receipt_count.
            RAISE EXCEPTION TYPE zcx_invalid_stock_request.
          ENDIF.
        ELSEIF ls_suggestion-suggested_base_quantity
              <> ls_suggestion-final_receipt_base_quantity
                * lv_receipt_count.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        lv_receipt_item_quantity =
          ls_suggestion-final_receipt_base_quantity.
      ELSEIF ls_suggestion-maximum_base_quantity > 0.
        IF ls_suggestion-final_receipt_base_quantity
              > ls_suggestion-maximum_base_quantity
            OR ls_suggestion-suggested_base_quantity
              <> ls_suggestion-maximum_base_quantity
                * ( lv_receipt_count - 1 )
                + ls_suggestion-final_receipt_base_quantity.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        lv_receipt_item_quantity = ls_suggestion-maximum_base_quantity.
      ELSE.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      DO lv_receipt_count TIMES.
        ADD 10 TO lv_item_number.
        IF sy-index = lv_receipt_count.
          lv_receipt_item_quantity =
            ls_suggestion-final_receipt_base_quantity.
        ENDIF.
        lv_item_quantity = convert_to_purchasing_unit(
          iv_base_quantity = lv_receipt_item_quantity
          iv_numerator     = lv_order_unit_numerator
          iv_denominator   = lv_order_unit_denominator ).
        APPEND VALUE #(
          item_number             = lv_item_number
          source_suggestion_index = lv_suggestion_index
          material                = ls_suggestion-material
          plant                   = ls_suggestion-plant
          quantity                = lv_item_quantity
          unit                    = lv_item_unit
          delivery_date           = ls_suggestion-required_date
          purchasing_group        = lv_item_purchasing_group
          purchasing_org          = lv_item_purchasing_org
          source_vendor           = ls_suggestion-source_vendor
          source_info_record      = ls_suggestion-source_info_record
          source_agreement        = ls_suggestion-source_agreement
          source_agreement_item   = ls_suggestion-source_agreement_item )
          TO ls_request-items.
      ENDDO.
    ENDLOOP.

    rs_request = ls_request.
  ENDMETHOD.

  METHOD submit_prepared_request.
    IF iv_test_run <> abap_true AND iv_test_run <> abap_false.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    DATA(ls_request) = is_request.
    ls_request-is_test_run = iv_test_run.
    IF ls_request-items IS INITIAL.
      rs_result-is_successful = abap_true.
      rs_result-is_test_run = iv_test_run.
      APPEND VALUE #(
        type    = 'S'
        message = 'No positive replenishment suggestions to requisition' )
        TO rs_result-messages.
      RETURN.
    ENDIF.

    rs_result = complete_write(
      is_request = ls_request
      is_result  = mo_api->create_requisition( ls_request ) ).
    rs_result-submitted_items = ls_request-items.
  ENDMETHOD.

  METHOD create_from_suggestions.
    DATA(ls_request) = prepare_from_suggestions(
      it_suggestions         = it_suggestions
      iv_requisition_type    = iv_requisition_type
      iv_purchasing_group    = iv_purchasing_group
      iv_purchasing_org      = iv_purchasing_org
      it_purchasing_controls = it_purchasing_controls ).
    rs_result = submit_prepared_request(
      is_request  = ls_request
      iv_test_run = iv_test_run ).
  ENDMETHOD.

  METHOD create_from_proj_shortfalls.
    TYPES ty_request_id TYPE c LENGTH 30.
    DATA lt_seen_request_ids TYPE HASHED TABLE OF ty_request_id
      WITH UNIQUE KEY table_line.
    DATA ls_request TYPE zif_purchase_requisition_api=>ty_request.
    DATA lv_item_number TYPE n LENGTH 5.

    IF iv_requisition_type IS INITIAL
        OR ( iv_test_run <> abap_true AND iv_test_run <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    ls_request-requisition_type = iv_requisition_type.

    LOOP AT it_shortfalls INTO DATA(ls_shortfall).
      INSERT ls_shortfall-request_id INTO TABLE lt_seen_request_ids.
      IF ls_shortfall-request_id IS INITIAL
          OR sy-subrc <> 0
          OR ls_shortfall-wbs_element IS INITIAL
          OR ls_shortfall-material IS INITIAL
          OR ls_shortfall-plant IS INITIAL
          OR ls_shortfall-quantity <= 0
          OR ls_shortfall-unit IS INITIAL
          OR ls_shortfall-delivery_date IS INITIAL
          OR lv_item_number >= 99990.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      ADD 10 TO lv_item_number.
      APPEND VALUE #(
        item_number                 = lv_item_number
        material                    = ls_shortfall-material
        plant                       = ls_shortfall-plant
        quantity                    = ls_shortfall-quantity
        unit                        = ls_shortfall-unit
        delivery_date               = ls_shortfall-delivery_date
        purchasing_group            = iv_purchasing_group
        purchasing_org              = iv_purchasing_org
        account_assignment_category = 'Q'
        wbs_element                 = ls_shortfall-wbs_element )
        TO ls_request-items.
    ENDLOOP.

    IF ls_request-items IS NOT INITIAL.
      validate_create_requests(
        it_requests = VALUE #(
          ( requisition_type = iv_requisition_type
            items            = ls_request-items ) )
        iv_test_run = iv_test_run ).
    ENDIF.

    rs_result = submit_prepared_request(
      is_request  = ls_request
      iv_test_run = iv_test_run ).
  ENDMETHOD.

  METHOD prepare_from_selected_sources.
    DATA lt_purchasing_controls TYPE ty_suggestion_purchasing_controls.
    lt_purchasing_controls = it_purchasing_controls.
    DATA(lt_selected_suggestions) =
      zcl_repl_source_service=>apply_selected_source_options(
        it_suggestions = it_suggestions
        it_options     = it_selected_source_options ).

    LOOP AT it_selected_source_options INTO DATA(ls_option).
      IF ls_option-source_kind <>
          zcl_repl_source_service=>c_suggestion_source_pir
          OR ls_option-pir_candidate-purchase_order_unit IS INITIAL.
        CONTINUE.
      ENDIF.
      READ TABLE lt_purchasing_controls ASSIGNING
        FIELD-SYMBOL(<ls_purchasing_control>)
        WITH KEY source_suggestion_index = ls_option-suggestion_index.
      IF sy-subrc <> 0.
        APPEND VALUE #(
          source_suggestion_index = ls_option-suggestion_index )
          TO lt_purchasing_controls.
        READ TABLE lt_purchasing_controls ASSIGNING <ls_purchasing_control>
          INDEX lines( lt_purchasing_controls ).
      ENDIF.
      IF <ls_purchasing_control>-purchasing_unit IS INITIAL.
        <ls_purchasing_control>-purchasing_unit =
          ls_option-pir_candidate-purchase_order_unit.
        <ls_purchasing_control>-order_to_base_num =
          ls_option-pir_candidate-order_to_base_num.
        <ls_purchasing_control>-order_to_base_den =
          ls_option-pir_candidate-order_to_base_den.
      ELSEIF <ls_purchasing_control>-purchasing_unit
          = ls_option-pir_candidate-purchase_order_unit
          AND <ls_purchasing_control>-order_to_base_num
            IS INITIAL
          AND <ls_purchasing_control>-order_to_base_den
            IS INITIAL.
        <ls_purchasing_control>-order_to_base_num =
          ls_option-pir_candidate-order_to_base_num.
        <ls_purchasing_control>-order_to_base_den =
          ls_option-pir_candidate-order_to_base_den.
      ENDIF.
    ENDLOOP.

    rs_request = prepare_from_suggestions(
      it_suggestions         = lt_selected_suggestions
      iv_requisition_type    = iv_requisition_type
      iv_purchasing_group    = iv_purchasing_group
      iv_purchasing_org      = iv_purchasing_org
      it_purchasing_controls = lt_purchasing_controls ).
  ENDMETHOD.

  METHOD create_from_selected_sources.
    DATA(ls_request) = prepare_from_selected_sources(
      it_suggestions             = it_suggestions
      it_selected_source_options = it_selected_source_options
      iv_requisition_type        = iv_requisition_type
      iv_purchasing_group        = iv_purchasing_group
      iv_purchasing_org          = iv_purchasing_org
      it_purchasing_controls     = it_purchasing_controls ).
    rs_result = submit_prepared_request(
      is_request  = ls_request
      iv_test_run = iv_test_run ).
  ENDMETHOD.

  METHOD prepare_from_quota_splits.
    TYPES:
      BEGIN OF ty_split_key,
        source_suggestion_index TYPE i,
        split_sequence          TYPE i,
      END OF ty_split_key.
    TYPES:
      BEGIN OF ty_split_total,
        source_suggestion_index TYPE i,
        allocated_quantity      TYPE decfloat34,
        proposal_quantity       TYPE decfloat34,
      END OF ty_split_total.
    TYPES ty_control_index TYPE i.
    TYPES:
      BEGIN OF ty_index_map,
        expanded_index          TYPE i,
        source_suggestion_index TYPE i,
      END OF ty_index_map.
    DATA lt_seen_split_keys TYPE HASHED TABLE OF ty_split_key
      WITH UNIQUE KEY source_suggestion_index split_sequence.
    DATA lt_split_totals TYPE HASHED TABLE OF ty_split_total
      WITH UNIQUE KEY source_suggestion_index.
    DATA lt_seen_control_indexes TYPE HASHED TABLE OF ty_control_index
      WITH UNIQUE KEY table_line.
    DATA lt_index_map TYPE HASHED TABLE OF ty_index_map
      WITH UNIQUE KEY expanded_index.
    DATA lt_expanded_suggestions TYPE
      zcl_prod_comp_service=>ty_comp_replenishments.
    DATA lt_source_options TYPE
      zcl_repl_source_service=>ty_suggestion_source_options.
    DATA lt_expanded_controls TYPE ty_suggestion_purchasing_controls.
    DATA lt_sorted_splits TYPE ty_quota_requisition_splits.

    IF iv_requisition_type IS INITIAL OR it_splits IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT it_purchasing_controls INTO DATA(ls_control).
      IF ls_control-source_suggestion_index <= 0
          OR ls_control-source_suggestion_index > lines( it_suggestions )
          OR ( ls_control-purchasing_group IS INITIAL
            AND ls_control-purchasing_org IS INITIAL
            AND ls_control-purchasing_unit IS INITIAL )
          OR ( ls_control-purchasing_unit IS INITIAL
            AND ( ls_control-order_to_base_num IS NOT INITIAL
              OR ls_control-order_to_base_den IS NOT INITIAL ) ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_control-source_suggestion_index
        INTO TABLE lt_seen_control_indexes.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    lt_sorted_splits = it_splits.
    SORT lt_sorted_splits BY source_suggestion_index split-split_sequence.
    LOOP AT lt_sorted_splits INTO DATA(ls_selected_split).
      IF ls_selected_split-source_suggestion_index <= 0
          OR ls_selected_split-source_suggestion_index
            > lines( it_suggestions )
          OR ls_selected_split-split-split_sequence <= 0
          OR ls_selected_split-split-allocated_quantity <= 0
          OR ls_selected_split-split-proposal_quantity
            < ls_selected_split-split-allocated_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT VALUE #(
        source_suggestion_index =
          ls_selected_split-source_suggestion_index
        split_sequence          = ls_selected_split-split-split_sequence )
        INTO TABLE lt_seen_split_keys.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      READ TABLE it_suggestions INDEX
        ls_selected_split-source_suggestion_index INTO DATA(ls_source).
      DATA(ls_candidate) = ls_selected_split-split-candidate.
      IF sy-subrc <> 0
          OR ls_source-material IS INITIAL
          OR ls_source-plant IS INITIAL
          OR ls_source-base_unit IS INITIAL
          OR ls_source-required_date IS INITIAL
          OR ls_source-suggested_base_quantity <= 0
          OR ls_source-procurement_type <> 'F'
          OR ls_source-special_procurement_key IS NOT INITIAL
          OR ls_candidate-request_index <= 0
          OR ls_candidate-candidate_rank <= 0
          OR ls_candidate-material <> ls_source-material
          OR ls_candidate-plant <> ls_source-plant
          OR ls_candidate-base_unit <> ls_source-base_unit
          OR ls_candidate-delivery_date <> ls_source-required_date
          OR ls_candidate-purchasing_org IS INITIAL
          OR ls_candidate-vendor IS INITIAL
          OR ls_candidate-info_record IS INITIAL
          OR ls_candidate-source_category <> '0'
          OR ls_candidate-is_quota_assigned <> abap_true
          OR ls_candidate-quota_number IS INITIAL
          OR ls_candidate-quota_item IS INITIAL
          OR ls_candidate-quota_value <= 0
          OR ( ls_candidate-purchase_order_unit IS NOT INITIAL
            AND ls_candidate-purchase_order_unit <> ls_source-base_unit
            AND ( ls_candidate-order_to_base_num <= 0
              OR ls_candidate-order_to_base_den <= 0 ) ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      TRY.
          DATA(lv_proposal_quantity) = CONV mard-labst(
            ls_selected_split-split-proposal_quantity ).
        CATCH cx_sy_conversion_overflow.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDTRY.
      IF lv_proposal_quantity <= 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      READ TABLE lt_split_totals ASSIGNING FIELD-SYMBOL(<ls_split_total>)
        WITH TABLE KEY source_suggestion_index =
          ls_selected_split-source_suggestion_index.
      IF sy-subrc = 0.
        <ls_split_total>-allocated_quantity =
          <ls_split_total>-allocated_quantity
            + ls_selected_split-split-allocated_quantity.
        <ls_split_total>-proposal_quantity =
          <ls_split_total>-proposal_quantity
            + lv_proposal_quantity.
      ELSE.
        INSERT VALUE #(
          source_suggestion_index =
            ls_selected_split-source_suggestion_index
          allocated_quantity      =
            ls_selected_split-split-allocated_quantity
          proposal_quantity       = lv_proposal_quantity )
          INTO TABLE lt_split_totals.
      ENDIF.

      DATA(ls_expanded_suggestion) = ls_source.
      ls_expanded_suggestion-suggested_base_quantity =
        lv_proposal_quantity.
      ls_expanded_suggestion-suggested_receipt_count = 1.
      ls_expanded_suggestion-final_receipt_base_quantity =
        lv_proposal_quantity.
      CLEAR:
        ls_expanded_suggestion-minimum_base_quantity,
        ls_expanded_suggestion-maximum_base_quantity,
        ls_expanded_suggestion-fixed_base_quantity,
        ls_expanded_suggestion-order_multiple_base_quantity,
        ls_expanded_suggestion-rounding_profile,
        ls_expanded_suggestion-rounding_surplus_base_quantity.
      APPEND ls_expanded_suggestion TO lt_expanded_suggestions.

      DATA(lv_expanded_index) = lines( lt_expanded_suggestions ).
      ls_candidate-request_index = lv_expanded_index.
      INSERT VALUE #(
        expanded_index          = lv_expanded_index
        source_suggestion_index =
          ls_selected_split-source_suggestion_index )
        INTO TABLE lt_index_map.
      APPEND VALUE #(
        suggestion_index = lv_expanded_index
        source_kind      = zcl_repl_source_service=>c_suggestion_source_pir
        candidate_rank   = ls_candidate-candidate_rank
        pir_candidate    = ls_candidate ) TO lt_source_options.

      READ TABLE it_purchasing_controls INTO ls_control
        WITH KEY source_suggestion_index =
          ls_selected_split-source_suggestion_index.
      IF sy-subrc = 0.
        ls_control-source_suggestion_index = lv_expanded_index.
        APPEND ls_control TO lt_expanded_controls.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_split_totals INTO DATA(ls_split_total).
      READ TABLE it_suggestions INDEX
        ls_split_total-source_suggestion_index INTO ls_source.
      IF sy-subrc <> 0
          OR ls_split_total-allocated_quantity <>
            CONV decfloat34( ls_source-suggested_base_quantity )
          OR ls_split_total-proposal_quantity <
            ls_split_total-allocated_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.
    LOOP AT it_purchasing_controls INTO ls_control.
      READ TABLE lt_split_totals TRANSPORTING NO FIELDS
        WITH TABLE KEY source_suggestion_index =
          ls_control-source_suggestion_index.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    rs_request = prepare_from_selected_sources(
      it_suggestions             = lt_expanded_suggestions
      it_selected_source_options = lt_source_options
      iv_requisition_type        = iv_requisition_type
      iv_purchasing_group        = iv_purchasing_group
      iv_purchasing_org          = iv_purchasing_org
      it_purchasing_controls     = lt_expanded_controls ).

    LOOP AT rs_request-items ASSIGNING FIELD-SYMBOL(<ls_item>).
      READ TABLE lt_index_map INTO DATA(ls_index_map)
        WITH TABLE KEY expanded_index =
          <ls_item>-source_suggestion_index.
      IF sy-subrc = 0.
        <ls_item>-source_suggestion_index =
          ls_index_map-source_suggestion_index.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD create_from_quota_splits.
    DATA(ls_request) = prepare_from_quota_splits(
      it_suggestions         = it_suggestions
      it_splits              = it_splits
      iv_requisition_type    = iv_requisition_type
      iv_purchasing_group    = iv_purchasing_group
      iv_purchasing_org      = iv_purchasing_org
      it_purchasing_controls = it_purchasing_controls ).
    rs_result = submit_prepared_request(
      is_request  = ls_request
      iv_test_run = iv_test_run ).
  ENDMETHOD.

  METHOD convert_to_purchasing_unit.
    IF iv_numerator <= 0 OR iv_denominator <= 0.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    TRY.
        rv_quantity = CONV mard-labst(
          CONV decfloat34( iv_base_quantity )
          * CONV decfloat34( iv_denominator )
          / CONV decfloat34( iv_numerator ) ).
      CATCH cx_sy_conversion_overflow.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDTRY.
    IF iv_base_quantity <> 0 AND rv_quantity IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
  ENDMETHOD.

  METHOD validate_delete_requests.
    TYPES ty_requisition_number TYPE
      zif_purchase_requisition_api=>ty_requisition_number.
    TYPES ty_item_number TYPE
      zif_purchase_requisition_api=>ty_requisition_item_number.
    DATA lt_seen_requisitions TYPE HASHED TABLE OF ty_requisition_number
      WITH UNIQUE KEY table_line.
    DATA lt_seen_items TYPE HASHED TABLE OF ty_item_number
      WITH UNIQUE KEY table_line.

    IF it_requests IS INITIAL
        OR ( iv_test_run <> abap_true AND iv_test_run <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT it_requests INTO DATA(ls_delete_request).
      IF ls_delete_request-requisition_number IS INITIAL
          OR ls_delete_request-item_numbers IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_delete_request-requisition_number
        INTO TABLE lt_seen_requisitions.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      CLEAR lt_seen_items.
      LOOP AT ls_delete_request-item_numbers INTO DATA(lv_item_number).
        INSERT lv_item_number INTO TABLE lt_seen_items.
        IF lv_item_number IS INITIAL OR sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD validate_create_requests.
    TYPES ty_requisition_item_number TYPE
      zif_purchase_requisition_api=>ty_requisition_item_number.
    DATA lt_seen_item_numbers TYPE HASHED TABLE OF
      ty_requisition_item_number WITH UNIQUE KEY table_line.

    IF it_requests IS INITIAL
        OR ( iv_test_run <> abap_true AND iv_test_run <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT it_requests INTO DATA(ls_create_request).
      IF ls_create_request-requisition_type IS INITIAL
          OR ls_create_request-items IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      CLEAR lt_seen_item_numbers.
      LOOP AT ls_create_request-items INTO DATA(ls_item).
        IF ls_item-item_number IS INITIAL
            OR ls_item-material IS INITIAL
            OR ls_item-plant IS INITIAL
            OR ls_item-quantity <= 0
            OR ls_item-unit IS INITIAL
            OR ls_item-delivery_date IS INITIAL
            OR ls_item-source_suggestion_index < 0.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        IF ( ls_item-account_assignment_category IS INITIAL
              AND ls_item-wbs_element IS NOT INITIAL )
            OR ( ls_item-account_assignment_category = 'Q'
              AND ls_item-wbs_element IS INITIAL )
            OR ( ls_item-account_assignment_category IS NOT INITIAL
              AND ls_item-account_assignment_category <> 'Q' ).
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        INSERT ls_item-item_number INTO TABLE lt_seen_item_numbers.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        IF ( ls_item-source_agreement IS INITIAL
              AND ls_item-source_agreement_item IS NOT INITIAL )
            OR ( ls_item-source_agreement IS NOT INITIAL
              AND ls_item-source_agreement_item IS INITIAL )
            OR ( ls_item-source_agreement IS NOT INITIAL
              AND ( ls_item-source_vendor IS INITIAL
                OR ls_item-purchasing_org IS INITIAL
                OR ls_item-source_info_record IS NOT INITIAL ) )
            OR ( ls_item-source_info_record IS NOT INITIAL
              AND ( ls_item-source_vendor IS INITIAL
                OR ls_item-purchasing_org IS INITIAL ) ).
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD validate_pr_item_updates.
    TYPES ty_item_number TYPE
      zif_purchase_requisition_api=>ty_requisition_item_number.
    DATA lt_seen_item_numbers TYPE HASHED TABLE OF ty_item_number
      WITH UNIQUE KEY table_line.

    IF iv_requisition_number IS INITIAL
        OR it_item_updates IS INITIAL
        OR ( iv_test_run <> abap_true AND iv_test_run <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT it_item_updates INTO DATA(ls_item_update).
      INSERT ls_item_update-item_number INTO TABLE lt_seen_item_numbers.
      IF ls_item_update-item_number IS INITIAL
          OR sy-subrc <> 0
          OR ( ls_item_update-change_quantity <> abap_true
            AND ls_item_update-change_quantity <> abap_false )
          OR ( ls_item_update-change_delivery_date <> abap_true
            AND ls_item_update-change_delivery_date <> abap_false )
          OR ( ls_item_update-change_purchasing_group <> abap_true
            AND ls_item_update-change_purchasing_group <> abap_false )
          OR ( ls_item_update-change_purchasing_org <> abap_true
            AND ls_item_update-change_purchasing_org <> abap_false )
          OR ( ls_item_update-change_source_vendor <> abap_true
            AND ls_item_update-change_source_vendor <> abap_false )
          OR ( ls_item_update-change_source_info_record <> abap_true
            AND ls_item_update-change_source_info_record <> abap_false )
          OR ( ls_item_update-change_source_agreement <> abap_true
            AND ls_item_update-change_source_agreement <> abap_false )
          OR ( ls_item_update-change_source_agreement_item <> abap_true
            AND ls_item_update-change_source_agreement_item <> abap_false )
          OR ( ls_item_update-change_quantity = abap_false
            AND ls_item_update-change_delivery_date = abap_false
            AND ls_item_update-change_purchasing_group = abap_false
            AND ls_item_update-change_purchasing_org = abap_false
            AND ls_item_update-change_source_vendor = abap_false
            AND ls_item_update-change_source_info_record = abap_false
            AND ls_item_update-change_source_agreement = abap_false
            AND ls_item_update-change_source_agreement_item = abap_false )
          OR ( ls_item_update-change_quantity = abap_true
            AND ls_item_update-quantity <= 0 )
          OR ( ls_item_update-change_quantity = abap_false
            AND ls_item_update-quantity <> 0 )
          OR ( ls_item_update-change_delivery_date = abap_true
            AND ls_item_update-delivery_date IS INITIAL )
          OR ( ls_item_update-change_delivery_date = abap_false
            AND ls_item_update-delivery_date IS NOT INITIAL )
          OR ( ls_item_update-change_purchasing_group = abap_false
            AND ls_item_update-purchasing_group IS NOT INITIAL )
          OR ( ls_item_update-change_purchasing_org = abap_false
            AND ls_item_update-purchasing_org IS NOT INITIAL )
          OR ( ls_item_update-change_source_vendor = abap_false
            AND ls_item_update-source_vendor IS NOT INITIAL )
          OR ( ls_item_update-change_source_info_record = abap_false
            AND ls_item_update-source_info_record IS NOT INITIAL )
          OR ( ls_item_update-change_source_agreement = abap_false
            AND ls_item_update-source_agreement IS NOT INITIAL )
          OR ( ls_item_update-change_source_agreement_item = abap_false
            AND ls_item_update-source_agreement_item IS NOT INITIAL ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validate_pr_update_requests.
    TYPES ty_requisition_number TYPE
      zif_purchase_requisition_api=>ty_requisition_number.
    DATA lt_seen_requisitions TYPE HASHED TABLE OF ty_requisition_number
      WITH UNIQUE KEY table_line.

    IF it_requests IS INITIAL
        OR ( iv_test_run <> abap_true AND iv_test_run <> abap_false )
        OR ( iv_atomic <> abap_true AND iv_atomic <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT it_requests INTO DATA(ls_update_request).
      INSERT ls_update_request-requisition_number
        INTO TABLE lt_seen_requisitions.
      IF ls_update_request-requisition_number IS INITIAL
          OR sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      validate_pr_item_updates(
        iv_requisition_number = ls_update_request-requisition_number
        it_item_updates       = ls_update_request-item_updates
        iv_test_run           = iv_test_run ).
    ENDLOOP.
  ENDMETHOD.

  METHOD complete_write.
    rs_result = is_result.
    rs_result-is_test_run = is_request-is_test_run.
    rs_result-bapi_was_called = abap_true.
    rs_result-is_committed = abap_false.
    LOOP AT rs_result-messages ASSIGNING FIELD-SYMBOL(<ls_message>).
      IF ( <ls_message>-parameter = 'PRITEM'
          OR <ls_message>-parameter = 'PRITEMX' )
          AND <ls_message>-row > 0.
        READ TABLE is_request-items
          INDEX CONV i( <ls_message>-row )
          INTO DATA(ls_item_message).
        IF sy-subrc = 0.
          <ls_message>-item_number = ls_item_message-item_number.
          <ls_message>-source_suggestion_index =
            ls_item_message-source_suggestion_index.
        ENDIF.
      ENDIF.
      IF <ls_message>-type = 'A'
          OR <ls_message>-type = 'E'
          OR <ls_message>-type = 'X'.
        mo_api->rollback( ).
        rs_result-is_successful = abap_false.
        RETURN.
      ENDIF.
    ENDLOOP.

    IF rs_result-is_successful = abap_false.
      mo_api->rollback( ).
      APPEND VALUE #(
        type    = 'E'
        message = 'Purchase requisition write failed without an error message' )
        TO rs_result-messages.
      RETURN.
    ENDIF.

    IF is_request-is_test_run = abap_true.
      rs_result-is_successful = abap_true.
      RETURN.
    ENDIF.

    IF rs_result-requisition_number IS INITIAL.
      mo_api->rollback( ).
      APPEND VALUE #(
        type    = 'E'
        message = 'Purchase requisition write returned no document number' )
        TO rs_result-messages.
      rs_result-is_successful = abap_false.
      RETURN.
    ENDIF.

    DATA(ls_commit_result) = mo_api->commit( ).
    DATA(lv_commit_failed) = xsdbool(
      ls_commit_result-is_successful = abap_false ).
    IF ls_commit_result-message-type = 'A'
        OR ls_commit_result-message-type = 'E'
        OR ls_commit_result-message-type = 'X'.
      lv_commit_failed = abap_true.
    ENDIF.
    IF lv_commit_failed = abap_true.
      mo_api->rollback( ).
      IF ls_commit_result-message IS NOT INITIAL.
        APPEND ls_commit_result-message TO rs_result-messages.
      ENDIF.
      IF ls_commit_result-message-type <> 'A'
          AND ls_commit_result-message-type <> 'E'
          AND ls_commit_result-message-type <> 'X'.
        APPEND VALUE #(
          type    = 'E'
          message = 'Purchase requisition write commit failed' )
          TO rs_result-messages.
      ENDIF.
      rs_result-is_successful = abap_false.
      RETURN.
    ENDIF.

    rs_result-is_successful = abap_true.
    rs_result-is_committed = abap_true.
  ENDMETHOD.

ENDCLASS.
