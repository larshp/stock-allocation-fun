CLASS zcl_purchase_order_service DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_requests TYPE STANDARD TABLE OF
      zif_purchase_order_api=>ty_request WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_order_read,
        purchase_order_number TYPE
          zif_purchase_order_api=>ty_purchase_order_number,
        read_result           TYPE
          zif_purchase_order_api=>ty_read_result,
      END OF ty_order_read.
    TYPES ty_order_read_results TYPE STANDARD TABLE OF ty_order_read
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_suggestion_po_control,
        suggestion_index  TYPE i,
        purchasing_unit   TYPE eina-meins,
        order_to_base_num TYPE eina-umrez,
        order_to_base_den TYPE eina-umren,
      END OF ty_suggestion_po_control.
    TYPES ty_suggestion_po_controls TYPE STANDARD TABLE OF
      ty_suggestion_po_control WITH EMPTY KEY.
    TYPES ty_suggestion_indexes TYPE STANDARD TABLE OF i WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_supplier_suggestion_group,
        vendor             TYPE eina-lifnr,
        purchasing_org     TYPE eine-ekorg,
        suggestion_indexes TYPE ty_suggestion_indexes,
      END OF ty_supplier_suggestion_group.
    TYPES ty_supplier_suggestion_groups TYPE STANDARD TABLE OF
      ty_supplier_suggestion_group WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_selected_requisition_item,
        requisition_number TYPE eban-banfn,
        vendor             TYPE zif_purchase_order_api=>ty_vendor,
        purchasing_org     TYPE zif_purchase_order_api=>ty_purchasing_org,
        item               TYPE
          zif_purchase_requisition_api=>ty_requisition_item,
      END OF ty_selected_requisition_item.
    TYPES ty_selected_requisition_items TYPE STANDARD TABLE OF
      ty_selected_requisition_item WITH EMPTY KEY.
    TYPES ty_requisition_item_indexes TYPE STANDARD TABLE OF i
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_requisition_supplier_group,
        vendor         TYPE zif_purchase_order_api=>ty_vendor,
        purchasing_org TYPE zif_purchase_order_api=>ty_purchasing_org,
        item_indexes   TYPE ty_requisition_item_indexes,
      END OF ty_requisition_supplier_group.
    TYPES ty_requisition_supplier_groups TYPE STANDARD TABLE OF
      ty_requisition_supplier_group WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_requisition_reference,
        requisition_number TYPE eban-banfn,
        requisition_item   TYPE eban-bnfpo,
      END OF ty_requisition_reference.
    TYPES ty_write_results TYPE STANDARD TABLE OF
      zif_purchase_order_api=>ty_write_result WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_order_item_change,
        purchase_order_number TYPE
          zif_purchase_order_api=>ty_purchase_order_number,
        item_numbers          TYPE zif_purchase_order_api=>ty_item_numbers,
      END OF ty_order_item_change.
    TYPES ty_order_item_changes TYPE STANDARD TABLE OF
      ty_order_item_change WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_order_qty_change,
        purchase_order_number TYPE
          zif_purchase_order_api=>ty_purchase_order_number,
        item_changes          TYPE
          zif_purchase_order_api=>ty_item_quantity_changes,
      END OF ty_order_qty_change.
    TYPES ty_order_qty_changes TYPE STANDARD TABLE OF ty_order_qty_change
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_base_qty_change,
        item_number   TYPE zif_purchase_order_api=>ty_item_number,
        base_quantity TYPE mard-labst,
      END OF ty_base_qty_change.
    TYPES ty_base_qty_changes TYPE STANDARD TABLE OF ty_base_qty_change
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_order_base_qty_change,
        purchase_order_number TYPE
          zif_purchase_order_api=>ty_purchase_order_number,
        item_changes          TYPE ty_base_qty_changes,
      END OF ty_order_base_qty_change.
    TYPES ty_order_base_qty_changes TYPE STANDARD TABLE OF
      ty_order_base_qty_change WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_order_schedule_change,
        purchase_order_number TYPE
          zif_purchase_order_api=>ty_purchase_order_number,
        schedule_changes      TYPE
          zif_purchase_order_api=>ty_schedule_changes,
      END OF ty_order_schedule_change.
    TYPES ty_order_schedule_changes TYPE STANDARD TABLE OF
      ty_order_schedule_change WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_base_schedule_change,
        item_number          TYPE zif_purchase_order_api=>ty_item_number,
        schedule_line        TYPE zif_purchase_order_api=>ty_schedule_line_number,
        change_quantity      TYPE abap_bool,
        base_quantity        TYPE mard-labst,
        change_delivery_date TYPE abap_bool,
        delivery_date        TYPE d,
      END OF ty_base_schedule_change.
    TYPES ty_base_schedule_changes TYPE STANDARD TABLE OF
      ty_base_schedule_change WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_order_base_schedule_change,
        purchase_order_number TYPE
          zif_purchase_order_api=>ty_purchase_order_number,
        schedule_changes      TYPE ty_base_schedule_changes,
      END OF ty_order_base_schedule_change.
    TYPES ty_order_base_schedule_changes TYPE STANDARD TABLE OF
      ty_order_base_schedule_change WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_bulk_write_result,
        order_results      TYPE ty_write_results,
        successful_count   TYPE i,
        failed_count       TYPE i,
        skipped_count      TYPE i,
        stopped_on_failure TYPE abap_bool,
        is_successful      TYPE abap_bool,
        is_test_run        TYPE abap_bool,
        is_committed       TYPE abap_bool,
      END OF ty_bulk_write_result.
    TYPES:
      BEGIN OF ty_atomic_write_result,
        order_results TYPE ty_write_results,
        commit_result TYPE zif_purchase_order_api=>ty_commit_result,
        is_successful TYPE abap_bool,
        is_test_run   TYPE abap_bool,
        is_committed  TYPE abap_bool,
      END OF ty_atomic_write_result.

    METHODS constructor
      IMPORTING
        io_api           TYPE REF TO zif_purchase_order_api
        io_uom_converter TYPE REF TO zif_material_uom_converter OPTIONAL.

    METHODS create_order
      IMPORTING
        is_request       TYPE zif_purchase_order_api=>ty_request
      RETURNING
        VALUE(rs_result) TYPE zif_purchase_order_api=>ty_write_result
      RAISING
        zcx_invalid_stock_request.

    METHODS create_from_suggestions
      IMPORTING
        is_header              TYPE zif_purchase_order_api=>ty_request
        it_suggestions         TYPE
          zcl_prod_comp_service=>ty_comp_replenishments
        it_purchasing_controls TYPE ty_suggestion_po_controls OPTIONAL
      RETURNING
        VALUE(rs_result)       TYPE zif_purchase_order_api=>ty_write_result
      RAISING
        zcx_invalid_stock_request.

    METHODS prepare_from_suggestions
      IMPORTING
        is_header              TYPE zif_purchase_order_api=>ty_request
        it_suggestions         TYPE
          zcl_prod_comp_service=>ty_comp_replenishments
        it_purchasing_controls TYPE ty_suggestion_po_controls OPTIONAL
      RETURNING
        VALUE(rs_request)      TYPE zif_purchase_order_api=>ty_request
      RAISING
        zcx_invalid_stock_request.

    METHODS create_from_requisition_items
      IMPORTING
        is_header             TYPE zif_purchase_order_api=>ty_request
        iv_requisition_number TYPE eban-banfn
        it_requisition_items  TYPE zif_purchase_requisition_api=>ty_requisition_items
      RETURNING
        VALUE(rs_result)      TYPE zif_purchase_order_api=>ty_write_result
      RAISING
        zcx_invalid_stock_request.

    METHODS prepare_from_requisition_items
      IMPORTING
        is_header             TYPE zif_purchase_order_api=>ty_request
        iv_requisition_number TYPE eban-banfn
        it_requisition_items  TYPE zif_purchase_requisition_api=>ty_requisition_items
      RETURNING
        VALUE(rs_request)     TYPE zif_purchase_order_api=>ty_request
      RAISING
        zcx_invalid_stock_request.

    METHODS create_from_requisitions_bulk
      IMPORTING
        is_header          TYPE zif_purchase_order_api=>ty_request
        it_selected_items  TYPE ty_selected_requisition_items
        iv_stop_on_failure TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)   TYPE ty_bulk_write_result
      RAISING
        zcx_invalid_stock_request.

    METHODS create_requisitions_atomic
      IMPORTING
        is_header         TYPE zif_purchase_order_api=>ty_request
        it_selected_items TYPE ty_selected_requisition_items
      RETURNING
        VALUE(rs_result)  TYPE ty_atomic_write_result
      RAISING
        zcx_invalid_stock_request.

    METHODS prepare_from_requisitions
      IMPORTING
        is_header          TYPE zif_purchase_order_api=>ty_request
        it_selected_items  TYPE ty_selected_requisition_items
      RETURNING
        VALUE(rt_requests) TYPE ty_requests
      RAISING
        zcx_invalid_stock_request.

    METHODS create_from_suggestions_bulk
      IMPORTING
        is_header              TYPE zif_purchase_order_api=>ty_request
        it_suggestions         TYPE
          zcl_prod_comp_service=>ty_comp_replenishments
        it_purchasing_controls TYPE ty_suggestion_po_controls OPTIONAL
        iv_stop_on_failure     TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)       TYPE ty_bulk_write_result
      RAISING
        zcx_invalid_stock_request.

    METHODS create_from_suggestions_atomic
      IMPORTING
        is_header              TYPE zif_purchase_order_api=>ty_request
        it_suggestions         TYPE
          zcl_prod_comp_service=>ty_comp_replenishments
        it_purchasing_controls TYPE ty_suggestion_po_controls OPTIONAL
      RETURNING
        VALUE(rs_result)       TYPE ty_atomic_write_result
      RAISING
        zcx_invalid_stock_request.

    METHODS prepare_from_suggestions_bulk
      IMPORTING
        is_header              TYPE zif_purchase_order_api=>ty_request
        it_suggestions         TYPE
          zcl_prod_comp_service=>ty_comp_replenishments
        it_purchasing_controls TYPE ty_suggestion_po_controls OPTIONAL
      RETURNING
        VALUE(rt_requests)     TYPE ty_requests
      RAISING
        zcx_invalid_stock_request.

    METHODS read_order
      IMPORTING
        iv_purchase_order_number TYPE
          zif_purchase_order_api=>ty_purchase_order_number
      RETURNING
        VALUE(rs_result)         TYPE zif_purchase_order_api=>ty_read_result
      RAISING
        zcx_invalid_stock_request.

    METHODS read_orders
      IMPORTING
        it_purchase_order_numbers TYPE
          zif_purchase_order_api=>ty_purchase_order_numbers
      RETURNING
        VALUE(rt_results)         TYPE ty_order_read_results
      RAISING
        zcx_invalid_stock_request.

    METHODS create_orders_bulk
      IMPORTING
        it_requests        TYPE ty_requests
        iv_stop_on_failure TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)   TYPE ty_bulk_write_result
      RAISING
        zcx_invalid_stock_request.

    METHODS create_orders_atomic
      IMPORTING
        it_requests      TYPE ty_requests
      RETURNING
        VALUE(rs_result) TYPE ty_atomic_write_result
      RAISING
        zcx_invalid_stock_request.

    METHODS delete_order_items
      IMPORTING
        iv_purchase_order_number TYPE
          zif_purchase_order_api=>ty_purchase_order_number
        it_item_numbers          TYPE
          zif_purchase_order_api=>ty_item_numbers
        iv_test_run              TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)         TYPE zif_purchase_order_api=>ty_write_result
      RAISING
        zcx_invalid_stock_request.

    METHODS delete_orders_items_bulk
      IMPORTING
        it_deletions       TYPE ty_order_item_changes
        iv_test_run        TYPE abap_bool DEFAULT abap_false
        iv_stop_on_failure TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)   TYPE ty_bulk_write_result
      RAISING
        zcx_invalid_stock_request.

    METHODS delete_orders_items_atomic
      IMPORTING
        it_deletions     TYPE ty_order_item_changes
        iv_test_run      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE ty_atomic_write_result
      RAISING
        zcx_invalid_stock_request.

    METHODS mark_delivery_complete
      IMPORTING
        iv_purchase_order_number TYPE
          zif_purchase_order_api=>ty_purchase_order_number
        it_item_numbers          TYPE
          zif_purchase_order_api=>ty_item_numbers
        iv_test_run              TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)         TYPE zif_purchase_order_api=>ty_write_result
      RAISING
        zcx_invalid_stock_request.

    METHODS mark_delivery_complete_bulk
      IMPORTING
        it_changes         TYPE ty_order_item_changes
        iv_test_run        TYPE abap_bool DEFAULT abap_false
        iv_stop_on_failure TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)   TYPE ty_bulk_write_result
      RAISING
        zcx_invalid_stock_request.

    METHODS mark_delivery_complete_atomic
      IMPORTING
        it_changes       TYPE ty_order_item_changes
        iv_test_run      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE ty_atomic_write_result
      RAISING
        zcx_invalid_stock_request.

    METHODS change_item_quantities
      IMPORTING
        iv_purchase_order_number TYPE
          zif_purchase_order_api=>ty_purchase_order_number
        it_item_changes          TYPE
          zif_purchase_order_api=>ty_item_quantity_changes
        iv_test_run              TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)         TYPE zif_purchase_order_api=>ty_write_result
      RAISING
        zcx_invalid_stock_request.

    METHODS change_item_quantities_bulk
      IMPORTING
        it_changes         TYPE ty_order_qty_changes
        iv_test_run        TYPE abap_bool DEFAULT abap_false
        iv_stop_on_failure TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)   TYPE ty_bulk_write_result
      RAISING
        zcx_invalid_stock_request.

    METHODS change_item_quantities_atomic
      IMPORTING
        it_changes       TYPE ty_order_qty_changes
        iv_test_run      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE ty_atomic_write_result
      RAISING
        zcx_invalid_stock_request.

    METHODS change_qty_from_base
      IMPORTING
        iv_purchase_order_number TYPE
          zif_purchase_order_api=>ty_purchase_order_number
        it_item_changes          TYPE ty_base_qty_changes
        iv_test_run              TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)         TYPE zif_purchase_order_api=>ty_write_result
      RAISING
        zcx_invalid_stock_request.

    METHODS change_qty_from_base_bulk
      IMPORTING
        it_changes         TYPE ty_order_base_qty_changes
        iv_test_run        TYPE abap_bool DEFAULT abap_false
        iv_stop_on_failure TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)   TYPE ty_bulk_write_result
      RAISING
        zcx_invalid_stock_request.

    METHODS change_qty_from_base_atomic
      IMPORTING
        it_changes       TYPE ty_order_base_qty_changes
        iv_test_run      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE ty_atomic_write_result
      RAISING
        zcx_invalid_stock_request.

    METHODS change_order_schedules
      IMPORTING
        iv_purchase_order_number TYPE
          zif_purchase_order_api=>ty_purchase_order_number
        it_schedule_changes      TYPE
          zif_purchase_order_api=>ty_schedule_changes
        iv_test_run              TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)         TYPE zif_purchase_order_api=>ty_write_result
      RAISING
        zcx_invalid_stock_request.

    METHODS change_order_schedules_bulk
      IMPORTING
        it_changes         TYPE ty_order_schedule_changes
        iv_test_run        TYPE abap_bool DEFAULT abap_false
        iv_stop_on_failure TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)   TYPE ty_bulk_write_result
      RAISING
        zcx_invalid_stock_request.

    METHODS change_order_schedules_atomic
      IMPORTING
        it_changes       TYPE ty_order_schedule_changes
        iv_test_run      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE ty_atomic_write_result
      RAISING
        zcx_invalid_stock_request.

    METHODS change_base_schedules
      IMPORTING
        iv_purchase_order_number TYPE
          zif_purchase_order_api=>ty_purchase_order_number
        it_schedule_changes      TYPE ty_base_schedule_changes
        iv_test_run              TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)         TYPE zif_purchase_order_api=>ty_write_result
      RAISING
        zcx_invalid_stock_request.

    METHODS change_base_schedules_bulk
      IMPORTING
        it_changes         TYPE ty_order_base_schedule_changes
        iv_test_run        TYPE abap_bool DEFAULT abap_false
        iv_stop_on_failure TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)   TYPE ty_bulk_write_result
      RAISING
        zcx_invalid_stock_request.

    METHODS change_base_schedules_atomic
      IMPORTING
        it_changes       TYPE ty_order_base_schedule_changes
        iv_test_run      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE ty_atomic_write_result
      RAISING
        zcx_invalid_stock_request.

  PRIVATE SECTION.
    METHODS build_suggestion_requests
      IMPORTING
        is_header              TYPE zif_purchase_order_api=>ty_request
        it_suggestions         TYPE
          zcl_prod_comp_service=>ty_comp_replenishments
        it_purchasing_controls TYPE ty_suggestion_po_controls
      RETURNING
        VALUE(rt_requests)     TYPE ty_requests
      RAISING
        zcx_invalid_stock_request.

    METHODS build_suggestion_order_request
      IMPORTING
        is_header              TYPE zif_purchase_order_api=>ty_request
        it_suggestions         TYPE
          zcl_prod_comp_service=>ty_comp_replenishments
        it_suggestion_indexes  TYPE ty_suggestion_indexes
        it_purchasing_controls TYPE ty_suggestion_po_controls
      RETURNING
        VALUE(rs_request)      TYPE zif_purchase_order_api=>ty_request
      RAISING
        zcx_invalid_stock_request.

    METHODS build_requisition_order_item
      IMPORTING
        is_header        TYPE zif_purchase_order_api=>ty_request
        is_selected_item TYPE ty_selected_requisition_item
        iv_item_number   TYPE zif_purchase_order_api=>ty_item_number
      RETURNING
        VALUE(rs_item)   TYPE zif_purchase_order_api=>ty_item
      RAISING
        zcx_invalid_stock_request.

    METHODS build_pr_order_requests
      IMPORTING
        is_header          TYPE zif_purchase_order_api=>ty_request
        it_selected_items  TYPE ty_selected_requisition_items
      RETURNING
        VALUE(rt_requests) TYPE ty_requests
      RAISING
        zcx_invalid_stock_request.

    METHODS complete_atomic_write
      IMPORTING
        is_result        TYPE ty_atomic_write_result
        iv_has_failure   TYPE abap_bool
      RETURNING
        VALUE(rs_result) TYPE ty_atomic_write_result.

    METHODS update_order_items_atomic
      IMPORTING
        it_changes                TYPE ty_order_item_changes
        iv_mark_delivery_complete TYPE abap_bool
        iv_test_run               TYPE abap_bool
      RETURNING
        VALUE(rs_result)          TYPE ty_atomic_write_result
      RAISING
        zcx_invalid_stock_request.

    METHODS finish_atomic_po_changes
      IMPORTING
        is_result        TYPE ty_atomic_write_result
        iv_has_failure   TYPE abap_bool
        iv_test_run      TYPE abap_bool
      RETURNING
        VALUE(rs_result) TYPE ty_atomic_write_result.

    METHODS validate_request
      IMPORTING
        is_request TYPE zif_purchase_order_api=>ty_request
      RAISING
        zcx_invalid_stock_request.

    METHODS validate_test_run
      IMPORTING
        iv_test_run TYPE abap_bool
      RAISING
        zcx_invalid_stock_request.

    METHODS validate_item_change
      IMPORTING
        iv_purchase_order_number TYPE
          zif_purchase_order_api=>ty_purchase_order_number
        it_item_numbers          TYPE
          zif_purchase_order_api=>ty_item_numbers
      RAISING
        zcx_invalid_stock_request.

    METHODS validate_schedule_changes
      IMPORTING
        iv_purchase_order_number TYPE
          zif_purchase_order_api=>ty_purchase_order_number
        it_schedule_changes      TYPE
          zif_purchase_order_api=>ty_schedule_changes
      RAISING
        zcx_invalid_stock_request.

    METHODS validate_item_quantity_changes
      IMPORTING
        iv_purchase_order_number TYPE
          zif_purchase_order_api=>ty_purchase_order_number
        it_item_changes          TYPE
          zif_purchase_order_api=>ty_item_quantity_changes
      RAISING
        zcx_invalid_stock_request.

    METHODS convert_base_quantity_changes
      IMPORTING
        iv_purchase_order_number TYPE
          zif_purchase_order_api=>ty_purchase_order_number
        it_item_changes          TYPE ty_base_qty_changes
      RETURNING
        VALUE(rt_item_changes)   TYPE
          zif_purchase_order_api=>ty_item_quantity_changes
      RAISING
        zcx_invalid_stock_request.

    METHODS convert_base_schedule_changes
      IMPORTING
        iv_purchase_order_number   TYPE
          zif_purchase_order_api=>ty_purchase_order_number
        it_schedule_changes        TYPE ty_base_schedule_changes
      RETURNING
        VALUE(rt_schedule_changes) TYPE
          zif_purchase_order_api=>ty_schedule_changes
      RAISING
        zcx_invalid_stock_request.

    METHODS complete_write
      IMPORTING
        is_result        TYPE zif_purchase_order_api=>ty_write_result
        iv_test_run      TYPE abap_bool
      RETURNING
        VALUE(rs_result) TYPE zif_purchase_order_api=>ty_write_result.

    METHODS finalize_bulk_write
      IMPORTING
        is_result        TYPE ty_bulk_write_result
      RETURNING
        VALUE(rs_result) TYPE ty_bulk_write_result.

    METHODS validate_stop_on_failure
      IMPORTING
        iv_stop_on_failure TYPE abap_bool
      RAISING
        zcx_invalid_stock_request.

    DATA mo_api TYPE REF TO zif_purchase_order_api.
    DATA mo_uom_converter TYPE REF TO zif_material_uom_converter.
ENDCLASS.

CLASS zcl_purchase_order_service IMPLEMENTATION.

  METHOD constructor.
    mo_api = io_api.
    IF io_uom_converter IS BOUND.
      mo_uom_converter = io_uom_converter.
    ELSE.
      mo_uom_converter = NEW zcl_material_uom_converter(
        io_repository = NEW zcl_material_uom_repository( ) ).
    ENDIF.
  ENDMETHOD.

  METHOD create_order.
    validate_request( is_request = is_request ).

    DATA(ls_write_result) = mo_api->create_order( is_request ).
    IF ls_write_result-submitted_items IS INITIAL.
      ls_write_result-submitted_items = is_request-items.
    ENDIF.
    rs_result = complete_write(
      is_result   = ls_write_result
      iv_test_run = is_request-is_test_run ).
  ENDMETHOD.

  METHOD prepare_from_suggestions.
    DATA lt_suggestion_indexes TYPE ty_suggestion_indexes.

    IF it_suggestions IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    DO lines( it_suggestions ) TIMES.
      APPEND sy-index TO lt_suggestion_indexes.
    ENDDO.

    rs_request = build_suggestion_order_request(
      is_header              = is_header
      it_suggestions         = it_suggestions
      it_suggestion_indexes  = lt_suggestion_indexes
      it_purchasing_controls = it_purchasing_controls ).
  ENDMETHOD.

  METHOD create_from_suggestions.
    DATA(ls_request) = prepare_from_suggestions(
      is_header              = is_header
      it_suggestions         = it_suggestions
      it_purchasing_controls = it_purchasing_controls ).
    IF ls_request-items IS INITIAL.
      rs_result-is_successful = abap_true.
      rs_result-is_test_run = is_header-is_test_run.
      APPEND VALUE #(
        type    = 'S'
        message = 'No positive replenishment suggestions to order' )
        TO rs_result-messages.
      RETURN.
    ENDIF.

    rs_result = create_order( is_request = ls_request ).
  ENDMETHOD.

  METHOD prepare_from_requisition_items.
    DATA ls_request TYPE zif_purchase_order_api=>ty_request.
    DATA lv_item_number TYPE n LENGTH 5.
    DATA lt_seen_requisition_items TYPE HASHED TABLE OF eban-bnfpo
      WITH UNIQUE KEY table_line.

    IF iv_requisition_number IS INITIAL
        OR it_requisition_items IS INITIAL
        OR is_header-items IS NOT INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    ls_request = is_header.
    CLEAR ls_request-items.
    LOOP AT it_requisition_items INTO DATA(ls_requisition_item).
      INSERT ls_requisition_item-item_number
        INTO TABLE lt_seen_requisition_items.
      IF ls_requisition_item-item_number IS INITIAL OR sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      ADD 10 TO lv_item_number.
      DATA(ls_selected_item) = VALUE ty_selected_requisition_item(
        requisition_number = iv_requisition_number
        vendor             = is_header-vendor
        purchasing_org     = is_header-purchasing_org
        item               = ls_requisition_item ).
      APPEND build_requisition_order_item(
        is_header        = is_header
        is_selected_item = ls_selected_item
        iv_item_number   = lv_item_number ) TO ls_request-items.
    ENDLOOP.

    validate_request( is_request = ls_request ).
    rs_request = ls_request.
  ENDMETHOD.

  METHOD create_from_requisition_items.
    DATA(ls_request) = prepare_from_requisition_items(
      is_header             = is_header
      iv_requisition_number = iv_requisition_number
      it_requisition_items  = it_requisition_items ).
    rs_result = create_order( is_request = ls_request ).
  ENDMETHOD.

  METHOD create_from_requisitions_bulk.
    validate_stop_on_failure(
      iv_stop_on_failure = iv_stop_on_failure ).
    DATA(lt_requests) = prepare_from_requisitions(
      is_header         = is_header
      it_selected_items = it_selected_items ).
    rs_result = create_orders_bulk(
      it_requests        = lt_requests
      iv_stop_on_failure = iv_stop_on_failure ).
  ENDMETHOD.

  METHOD create_requisitions_atomic.
    DATA(lt_requests) = prepare_from_requisitions(
      is_header         = is_header
      it_selected_items = it_selected_items ).
    rs_result = create_orders_atomic( it_requests = lt_requests ).
  ENDMETHOD.

  METHOD prepare_from_requisitions.
    rt_requests = build_pr_order_requests(
      is_header         = is_header
      it_selected_items = it_selected_items ).
  ENDMETHOD.

  METHOD build_pr_order_requests.
    DATA lt_groups TYPE ty_requisition_supplier_groups.
    DATA lv_item_index TYPE i.
    DATA lv_group_index TYPE i.
    DATA lv_item_number TYPE n LENGTH 5.
    DATA lt_seen_requisition_refs TYPE HASHED TABLE OF ty_requisition_reference
      WITH UNIQUE KEY requisition_number requisition_item.

    IF is_header-document_type IS INITIAL
        OR is_header-company_code IS INITIAL
        OR is_header-purchasing_group IS INITIAL
        OR is_header-document_date IS INITIAL
        OR is_header-vendor IS NOT INITIAL
        OR is_header-purchasing_org IS NOT INITIAL
        OR is_header-items IS NOT INITIAL
        OR it_selected_items IS INITIAL
        OR ( is_header-is_test_run <> abap_true
          AND is_header-is_test_run <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT it_selected_items INTO DATA(ls_selected_item).
      lv_item_index = sy-tabix.
      IF ls_selected_item-requisition_number IS INITIAL
          OR ls_selected_item-vendor IS INITIAL
          OR ls_selected_item-purchasing_org IS INITIAL
          OR ls_selected_item-item-item_number IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT VALUE #(
        requisition_number = ls_selected_item-requisition_number
        requisition_item   = ls_selected_item-item-item_number )
        INTO TABLE lt_seen_requisition_refs.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      READ TABLE lt_groups TRANSPORTING NO FIELDS
        WITH KEY vendor = ls_selected_item-vendor
          purchasing_org = ls_selected_item-purchasing_org.
      IF sy-subrc = 0.
        lv_group_index = sy-tabix.
      ELSE.
        APPEND VALUE #(
          vendor         = ls_selected_item-vendor
          purchasing_org = ls_selected_item-purchasing_org ) TO lt_groups.
        lv_group_index = lines( lt_groups ).
      ENDIF.
      READ TABLE lt_groups INDEX lv_group_index
        ASSIGNING FIELD-SYMBOL(<ls_group>).
      APPEND lv_item_index TO <ls_group>-item_indexes.
    ENDLOOP.

    LOOP AT lt_groups INTO DATA(ls_group).
      DATA(ls_group_request) = is_header.
      ls_group_request-vendor = ls_group-vendor.
      ls_group_request-purchasing_org = ls_group-purchasing_org.
      CLEAR ls_group_request-items.
      CLEAR lv_item_number.
      LOOP AT ls_group-item_indexes INTO lv_item_index.
        READ TABLE it_selected_items INDEX lv_item_index
          INTO ls_selected_item.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        ADD 10 TO lv_item_number.
        APPEND build_requisition_order_item(
          is_header        = ls_group_request
          is_selected_item = ls_selected_item
          iv_item_number   = lv_item_number ) TO ls_group_request-items.
      ENDLOOP.
      validate_request( is_request = ls_group_request ).
      APPEND ls_group_request TO rt_requests.
    ENDLOOP.
  ENDMETHOD.

  METHOD build_requisition_order_item.
    DATA lv_remaining_quantity TYPE mard-labst.
    DATA lv_source_request_id TYPE c LENGTH 30.

    IF is_selected_item-requisition_number IS INITIAL
        OR is_selected_item-vendor IS INITIAL
        OR is_selected_item-purchasing_org IS INITIAL
        OR is_selected_item-vendor <> is_header-vendor
        OR is_selected_item-purchasing_org <> is_header-purchasing_org
        OR is_selected_item-item-item_number IS INITIAL
        OR is_selected_item-item-deletion_indicator IS NOT INITIAL
        OR is_selected_item-item-is_closed = abap_true
        OR is_selected_item-item-material IS INITIAL
        OR is_selected_item-item-plant IS INITIAL
        OR is_selected_item-item-unit IS INITIAL
        OR is_selected_item-item-delivery_date IS INITIAL
        OR is_selected_item-item-quantity <= 0
        OR is_selected_item-item-ordered_quantity < 0
        OR is_selected_item-item-ordered_quantity
          > is_selected_item-item-quantity
        OR ( is_selected_item-item-source_vendor IS NOT INITIAL
          AND is_selected_item-item-source_vendor
            <> is_selected_item-vendor )
        OR ( is_selected_item-item-purchasing_org IS NOT INITIAL
          AND is_selected_item-item-purchasing_org
            <> is_selected_item-purchasing_org ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    lv_remaining_quantity = is_selected_item-item-quantity
      - is_selected_item-item-ordered_quantity.
    IF lv_remaining_quantity <= 0.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    CONCATENATE is_selected_item-requisition_number
      is_selected_item-item-item_number
      INTO lv_source_request_id SEPARATED BY '/'.
    rs_item = VALUE #(
      item_number          = iv_item_number
      source_request_id    = lv_source_request_id
      purchase_requisition = is_selected_item-requisition_number
      requisition_item     = is_selected_item-item-item_number
      material             = is_selected_item-item-material
      plant                = is_selected_item-item-plant
      storage_location     = is_selected_item-item-storage_location
      quantity             = lv_remaining_quantity
      unit                 = is_selected_item-item-unit
      delivery_date        = is_selected_item-item-delivery_date ).
  ENDMETHOD.

  METHOD create_from_suggestions_bulk.
    validate_stop_on_failure(
      iv_stop_on_failure = iv_stop_on_failure ).
    DATA(lt_requests) = prepare_from_suggestions_bulk(
      is_header              = is_header
      it_suggestions         = it_suggestions
      it_purchasing_controls = it_purchasing_controls ).

    IF lt_requests IS INITIAL.
      rs_result-is_successful = abap_true.
      rs_result-is_test_run = is_header-is_test_run.
      APPEND VALUE #(
        is_successful = abap_true
        is_test_run   = is_header-is_test_run
        messages      = VALUE #( (
          type    = 'S'
          message = 'No positive replenishment suggestions to order' ) ) )
        TO rs_result-order_results.
      RETURN.
    ENDIF.

    rs_result = create_orders_bulk(
      it_requests        = lt_requests
      iv_stop_on_failure = iv_stop_on_failure ).
  ENDMETHOD.

  METHOD create_from_suggestions_atomic.
    DATA(lt_requests) = prepare_from_suggestions_bulk(
      is_header              = is_header
      it_suggestions         = it_suggestions
      it_purchasing_controls = it_purchasing_controls ).

    IF lt_requests IS INITIAL.
      rs_result-is_successful = abap_true.
      rs_result-is_test_run = is_header-is_test_run.
      APPEND VALUE #(
        is_successful = abap_true
        is_test_run   = is_header-is_test_run
        messages      = VALUE #( (
          type    = 'S'
          message = 'No positive replenishment suggestions to order' ) ) )
        TO rs_result-order_results.
      RETURN.
    ENDIF.

    rs_result = create_orders_atomic( it_requests = lt_requests ).
  ENDMETHOD.

  METHOD prepare_from_suggestions_bulk.
    rt_requests = build_suggestion_requests(
      is_header              = is_header
      it_suggestions         = it_suggestions
      it_purchasing_controls = it_purchasing_controls ).
  ENDMETHOD.

  METHOD build_suggestion_requests.
    DATA lt_groups TYPE ty_supplier_suggestion_groups.
    DATA lt_requests TYPE ty_requests.
    DATA lt_seen_controls TYPE HASHED TABLE OF ty_suggestion_po_control
      WITH UNIQUE KEY suggestion_index.
    DATA lv_suggestion_index TYPE i.
    DATA lv_group_index TYPE i.

    IF is_header-document_type IS INITIAL
        OR is_header-company_code IS INITIAL
        OR is_header-purchasing_group IS INITIAL
        OR is_header-document_date IS INITIAL
        OR is_header-vendor IS NOT INITIAL
        OR is_header-purchasing_org IS NOT INITIAL
        OR is_header-items IS NOT INITIAL
        OR it_suggestions IS INITIAL
        OR ( is_header-is_test_run <> abap_true
          AND is_header-is_test_run <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT it_purchasing_controls INTO DATA(ls_control).
      IF ls_control-suggestion_index <= 0
          OR ls_control-suggestion_index > lines( it_suggestions )
          OR ls_control-purchasing_unit IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      READ TABLE it_suggestions
        INDEX ls_control-suggestion_index
        INTO DATA(ls_control_suggestion).
      IF sy-subrc <> 0
          OR ls_control_suggestion-suggested_base_quantity <= 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_control INTO TABLE lt_seen_controls.
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
          OR zcl_date_validation=>is_valid_gregorian_date(
            iv_date = ls_suggestion-required_date ) <> abap_true
          OR ls_suggestion-suggested_base_quantity < 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      IF ls_suggestion-suggested_base_quantity = 0.
        CONTINUE.
      ENDIF.
      IF ls_suggestion-source_vendor IS INITIAL
          OR ls_suggestion-source_purchasing_org IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      READ TABLE lt_groups TRANSPORTING NO FIELDS
        WITH KEY vendor = ls_suggestion-source_vendor
          purchasing_org = ls_suggestion-source_purchasing_org.
      IF sy-subrc = 0.
        lv_group_index = sy-tabix.
      ELSE.
        APPEND VALUE #(
          vendor         = ls_suggestion-source_vendor
          purchasing_org = ls_suggestion-source_purchasing_org )
          TO lt_groups.
        lv_group_index = lines( lt_groups ).
      ENDIF.

      READ TABLE lt_groups INDEX lv_group_index
        ASSIGNING FIELD-SYMBOL(<ls_group>).
      APPEND lv_suggestion_index TO <ls_group>-suggestion_indexes.
    ENDLOOP.

    IF lt_groups IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT lt_groups INTO DATA(ls_group).
      DATA lt_group_suggestions TYPE
        zcl_prod_comp_service=>ty_comp_replenishments.
      DATA lt_group_indexes TYPE ty_suggestion_indexes.
      DATA lt_group_controls TYPE ty_suggestion_po_controls.
      CLEAR: lt_group_suggestions, lt_group_indexes, lt_group_controls.
      LOOP AT ls_group-suggestion_indexes INTO lv_suggestion_index.
        READ TABLE it_suggestions INDEX lv_suggestion_index
          INTO ls_suggestion.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        APPEND ls_suggestion TO lt_group_suggestions.
        APPEND lv_suggestion_index TO lt_group_indexes.
        LOOP AT it_purchasing_controls INTO ls_control
            WHERE suggestion_index = lv_suggestion_index.
          APPEND ls_control TO lt_group_controls.
        ENDLOOP.
      ENDLOOP.

      DATA(ls_group_header) = is_header.
      ls_group_header-vendor = ls_group-vendor.
      ls_group_header-purchasing_org = ls_group-purchasing_org.
      DATA(ls_group_request) = build_suggestion_order_request(
        is_header              = ls_group_header
        it_suggestions         = lt_group_suggestions
        it_suggestion_indexes  = lt_group_indexes
        it_purchasing_controls = lt_group_controls ).
      APPEND ls_group_request TO lt_requests.
    ENDLOOP.

    rt_requests = lt_requests.
  ENDMETHOD.

  METHOD build_suggestion_order_request.
    DATA lv_item_number TYPE n LENGTH 5.
    DATA lv_suggestion_index TYPE i.
    DATA lv_item_unit TYPE eina-meins.
    DATA lv_order_unit_numerator TYPE eina-umrez.
    DATA lv_order_unit_denominator TYPE eina-umren.
    DATA lv_item_quantity TYPE mard-labst.
    DATA lv_control_position TYPE i.
    DATA lt_controls TYPE HASHED TABLE OF ty_suggestion_po_control
      WITH UNIQUE KEY suggestion_index.
    DATA lt_seen_suggestion_indexes TYPE HASHED TABLE OF i
      WITH UNIQUE KEY table_line.

    IF is_header-document_type IS INITIAL
        OR is_header-company_code IS INITIAL
        OR is_header-purchasing_org IS INITIAL
        OR is_header-purchasing_group IS INITIAL
        OR is_header-vendor IS INITIAL
        OR is_header-document_date IS INITIAL
        OR zcl_date_validation=>is_valid_gregorian_date(
          iv_date = is_header-document_date ) <> abap_true
        OR is_header-items IS NOT INITIAL
        OR it_suggestions IS INITIAL
        OR lines( it_suggestions ) <> lines( it_suggestion_indexes )
        OR ( is_header-is_test_run <> abap_true
          AND is_header-is_test_run <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT it_suggestion_indexes INTO DATA(lv_index).
      IF lv_index <= 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT lv_index INTO TABLE lt_seen_suggestion_indexes.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT it_purchasing_controls INTO DATA(ls_control).
      IF ls_control-suggestion_index <= 0
          OR ls_control-purchasing_unit IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      READ TABLE lt_seen_suggestion_indexes
        WITH TABLE KEY table_line = ls_control-suggestion_index
        TRANSPORTING NO FIELDS.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      CLEAR lv_control_position.
      LOOP AT it_suggestion_indexes INTO lv_index.
        IF lv_index = ls_control-suggestion_index.
          lv_control_position = sy-tabix.
          EXIT.
        ENDIF.
      ENDLOOP.
      READ TABLE it_suggestions
        INDEX lv_control_position
        INTO DATA(ls_control_suggestion).
      IF sy-subrc <> 0
          OR ls_control_suggestion-suggested_base_quantity <= 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_control INTO TABLE lt_controls.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    rs_request = is_header.
    CLEAR rs_request-items.
    LOOP AT it_suggestions INTO DATA(ls_suggestion).
      lv_suggestion_index = it_suggestion_indexes[ sy-tabix ].
      IF ls_suggestion-material IS INITIAL
          OR ls_suggestion-plant IS INITIAL
          OR ls_suggestion-base_unit IS INITIAL
          OR ls_suggestion-required_date IS INITIAL
          OR zcl_date_validation=>is_valid_gregorian_date(
            iv_date = ls_suggestion-required_date ) <> abap_true
          OR ls_suggestion-suggested_base_quantity < 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      IF ls_suggestion-suggested_base_quantity = 0.
        CONTINUE.
      ENDIF.

      IF ls_suggestion-procurement_type <> 'F'
          OR ls_suggestion-special_procurement_key IS NOT INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      IF ls_suggestion-source_vendor <> is_header-vendor.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      IF ls_suggestion-source_purchasing_org <> is_header-purchasing_org.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      IF ( ls_suggestion-source_info_record IS INITIAL
            AND ls_suggestion-source_agreement IS INITIAL
            AND ls_suggestion-source_agreement_item IS INITIAL )
          OR ( ls_suggestion-source_info_record IS NOT INITIAL
            AND ( ls_suggestion-source_agreement IS NOT INITIAL
              OR ls_suggestion-source_agreement_item IS NOT INITIAL ) )
          OR ( ls_suggestion-source_agreement IS INITIAL
            AND ls_suggestion-source_agreement_item IS NOT INITIAL )
          OR ( ls_suggestion-source_agreement IS NOT INITIAL
            AND ls_suggestion-source_agreement_item IS INITIAL ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      lv_item_unit = ls_suggestion-base_unit.
      lv_order_unit_numerator = 1.
      lv_order_unit_denominator = 1.
      READ TABLE lt_controls
        INTO ls_control
        WITH TABLE KEY suggestion_index = lv_suggestion_index.
      IF sy-subrc = 0.
        lv_item_unit = ls_control-purchasing_unit.
        IF lv_item_unit = ls_suggestion-base_unit.
          IF ( ls_control-order_to_base_num IS NOT INITIAL
                AND ls_control-order_to_base_num <> 1 )
              OR ( ls_control-order_to_base_den IS NOT INITIAL
                AND ls_control-order_to_base_den <> 1 ).
            RAISE EXCEPTION TYPE zcx_invalid_stock_request.
          ENDIF.
        ELSE.
          IF ls_control-order_to_base_num <= 0
              OR ls_control-order_to_base_den <= 0.
            RAISE EXCEPTION TYPE zcx_invalid_stock_request.
          ENDIF.
          lv_order_unit_numerator = ls_control-order_to_base_num.
          lv_order_unit_denominator = ls_control-order_to_base_den.
        ENDIF.
      ENDIF.

      TRY.
          lv_item_quantity = CONV mard-labst(
            CONV decfloat34( ls_suggestion-suggested_base_quantity )
            * CONV decfloat34( lv_order_unit_denominator )
            / CONV decfloat34( lv_order_unit_numerator ) ).
        CATCH cx_sy_conversion_overflow.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDTRY.
      IF lv_item_quantity <= 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      ADD 10 TO lv_item_number.
      APPEND VALUE #(
        item_number           = lv_item_number
        source_request_id     = CONV string( lv_suggestion_index )
        material              = ls_suggestion-material
        plant                 = ls_suggestion-plant
        quantity              = lv_item_quantity
        unit                  = lv_item_unit
        delivery_date         = ls_suggestion-required_date
        source_info_record    = ls_suggestion-source_info_record
        source_agreement      = ls_suggestion-source_agreement
        source_agreement_item = ls_suggestion-source_agreement_item )
        TO rs_request-items.
    ENDLOOP.
  ENDMETHOD.

  METHOD read_order.
    IF iv_purchase_order_number IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    rs_result = mo_api->read_order(
      iv_purchase_order_number = iv_purchase_order_number ).
    IF rs_result-purchase_order_number IS NOT INITIAL
        AND rs_result-purchase_order_number <> iv_purchase_order_number.
      APPEND VALUE #(
        type    = 'E'
        message = 'Purchase order read returned a different document' )
        TO rs_result-messages.
      rs_result-is_successful = abap_false.
      RETURN.
    ENDIF.
    IF rs_result-header-purchase_order_number IS NOT INITIAL
        AND rs_result-header-purchase_order_number <> iv_purchase_order_number.
      APPEND VALUE #(
        type    = 'E'
        message = 'Purchase order header read returned another document' )
        TO rs_result-messages.
      rs_result-is_successful = abap_false.
      RETURN.
    ENDIF.
    rs_result-purchase_order_number = iv_purchase_order_number.
    rs_result-header-purchase_order_number = iv_purchase_order_number.

    DATA(lv_has_error_message) = abap_false.
    LOOP AT rs_result-messages INTO DATA(ls_message).
      IF ls_message-type = 'A'
          OR ls_message-type = 'E'
          OR ls_message-type = 'X'.
        lv_has_error_message = abap_true.
      ENDIF.
    ENDLOOP.
    IF lv_has_error_message = abap_true.
      rs_result-is_successful = abap_false.
    ELSEIF rs_result-is_successful = abap_false.
      APPEND VALUE #(
        type    = 'E'
        message = 'Purchase order read failed without an error message' )
        TO rs_result-messages.
    ENDIF.
  ENDMETHOD.

  METHOD read_orders.
    DATA lt_seen_purchase_orders TYPE HASHED TABLE OF
      zif_purchase_order_api=>ty_purchase_order_number
      WITH UNIQUE KEY table_line.

    IF it_purchase_order_numbers IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT it_purchase_order_numbers INTO DATA(lv_purchase_order_number).
      INSERT lv_purchase_order_number INTO TABLE lt_seen_purchase_orders.
      IF lv_purchase_order_number IS INITIAL OR sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT it_purchase_order_numbers INTO lv_purchase_order_number.
      DATA(ls_read_result) = read_order(
        iv_purchase_order_number = lv_purchase_order_number ).
      APPEND VALUE #(
        purchase_order_number = lv_purchase_order_number
        read_result           = ls_read_result )
        TO rt_results.
    ENDLOOP.
  ENDMETHOD.

  METHOD create_orders_atomic.
    DATA lv_has_failure TYPE abap_bool.

    IF it_requests IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    DATA(lv_test_run) = it_requests[ 1 ]-is_test_run.
    LOOP AT it_requests INTO DATA(ls_request).
      validate_request( is_request = ls_request ).
      IF ls_request-is_test_run <> lv_test_run.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    rs_result-is_test_run = lv_test_run.
    LOOP AT it_requests INTO ls_request.
      DATA(ls_write_result) = mo_api->create_order( ls_request ).
      IF ls_write_result-submitted_items IS INITIAL.
        ls_write_result-submitted_items = ls_request-items.
      ENDIF.
      ls_write_result-is_test_run = lv_test_run.
      ls_write_result-is_committed = abap_false.

      DATA(lv_order_failed) = xsdbool(
        ls_write_result-is_successful = abap_false ).
      DATA(lv_has_error_message) = abap_false.
      LOOP AT ls_write_result-messages INTO DATA(ls_message).
        IF ls_message-type = 'A'
            OR ls_message-type = 'E'
            OR ls_message-type = 'X'.
          lv_order_failed = abap_true.
          lv_has_error_message = abap_true.
        ENDIF.
      ENDLOOP.
      IF lv_test_run = abap_false
          AND ls_write_result-purchase_order_number IS INITIAL.
        lv_order_failed = abap_true.
        APPEND VALUE #(
          type    = 'E'
          message = 'Purchase order creation returned no document number' )
          TO ls_write_result-messages.
        lv_has_error_message = abap_true.
      ENDIF.

      IF lv_order_failed = abap_true.
        IF lv_has_error_message = abap_false.
          APPEND VALUE #(
            type    = 'E'
            message = 'Purchase order creation failed without an error message' )
            TO ls_write_result-messages.
        ENDIF.
        ls_write_result-is_successful = abap_false.
        lv_has_failure = abap_true.
      ELSE.
        ls_write_result-is_successful = abap_true.
      ENDIF.

      APPEND ls_write_result TO rs_result-order_results.
    ENDLOOP.

    rs_result = complete_atomic_write(
      is_result      = rs_result
      iv_has_failure = lv_has_failure ).
  ENDMETHOD.

  METHOD create_orders_bulk.
    validate_stop_on_failure(
      iv_stop_on_failure = iv_stop_on_failure ).
    IF it_requests IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    DATA(lv_test_run) = it_requests[ 1 ]-is_test_run.
    LOOP AT it_requests INTO DATA(ls_request).
      validate_request( is_request = ls_request ).
      IF ls_request-is_test_run <> lv_test_run.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    rs_result-is_successful = abap_true.
    rs_result-is_test_run = lv_test_run.
    LOOP AT it_requests INTO ls_request.
      DATA(ls_write_result) = create_order(
        is_request = ls_request ).
      APPEND ls_write_result TO rs_result-order_results.
      IF ls_write_result-is_successful = abap_false.
        IF iv_stop_on_failure = abap_true.
          rs_result-stopped_on_failure = abap_true.
          EXIT.
        ENDIF.
      ENDIF.
    ENDLOOP.

    IF rs_result-stopped_on_failure = abap_true.
      DATA(lv_next_request_index) = lines( rs_result-order_results ) + 1.
      LOOP AT it_requests INTO ls_request FROM lv_next_request_index.
        APPEND VALUE #(
          submitted_items = ls_request-items
          is_test_run     = ls_request-is_test_run
          is_skipped      = abap_true ) TO rs_result-order_results.
      ENDLOOP.
    ENDIF.

    rs_result = finalize_bulk_write( is_result = rs_result ).
  ENDMETHOD.

  METHOD complete_atomic_write.
    rs_result = is_result.
    LOOP AT rs_result-order_results
        ASSIGNING FIELD-SYMBOL(<ls_write_result>).
      <ls_write_result>-is_attempted = abap_true.
      <ls_write_result>-is_test_run = rs_result-is_test_run.
      <ls_write_result>-is_committed = abap_false.
    ENDLOOP.

    IF iv_has_failure = abap_true.
      mo_api->rollback( ).
      LOOP AT rs_result-order_results ASSIGNING <ls_write_result>.
        <ls_write_result>-is_successful = abap_false.
        CLEAR <ls_write_result>-purchase_order_number.
      ENDLOOP.
      RETURN.
    ENDIF.

    IF rs_result-is_test_run = abap_true.
      rs_result-is_successful = abap_true.
      LOOP AT rs_result-order_results ASSIGNING <ls_write_result>.
        <ls_write_result>-is_successful = abap_true.
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
      mo_api->rollback( ).
      IF rs_result-commit_result-message IS INITIAL.
        rs_result-commit_result-message = VALUE #(
          type    = 'E'
          message = 'Purchase order commit failed without an error message' ).
      ENDIF.
      LOOP AT rs_result-order_results ASSIGNING <ls_write_result>.
        <ls_write_result>-is_successful = abap_false.
        CLEAR <ls_write_result>-purchase_order_number.
      ENDLOOP.
      RETURN.
    ENDIF.

    rs_result-is_successful = abap_true.
    rs_result-is_committed = abap_true.
    LOOP AT rs_result-order_results ASSIGNING <ls_write_result>.
      <ls_write_result>-is_successful = abap_true.
      <ls_write_result>-is_committed = abap_true.
    ENDLOOP.
  ENDMETHOD.

  METHOD finish_atomic_po_changes.
    rs_result = is_result.
    LOOP AT rs_result-order_results
        ASSIGNING FIELD-SYMBOL(<ls_write_result>).
      <ls_write_result>-is_attempted = abap_true.
      <ls_write_result>-is_test_run = iv_test_run.
      <ls_write_result>-is_committed = abap_false.
    ENDLOOP.

    IF iv_test_run = abap_true.
      rs_result-is_test_run = abap_true.
      rs_result-is_committed = abap_false.
      rs_result-is_successful = xsdbool( iv_has_failure = abap_false ).
      RETURN.
    ENDIF.

    IF iv_has_failure = abap_true.
      mo_api->rollback( ).
      LOOP AT rs_result-order_results ASSIGNING <ls_write_result>.
        <ls_write_result>-is_successful = abap_false.
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
      mo_api->rollback( ).
      IF rs_result-commit_result-message-message IS INITIAL.
        rs_result-commit_result-message = VALUE #(
          type    = 'E'
          message = 'Purchase order change commit failed without an error message' ).
      ENDIF.
      LOOP AT rs_result-order_results ASSIGNING <ls_write_result>.
        <ls_write_result>-is_successful = abap_false.
      ENDLOOP.
      RETURN.
    ENDIF.

    rs_result-is_successful = abap_true.
    rs_result-is_committed = abap_true.
    LOOP AT rs_result-order_results ASSIGNING <ls_write_result>.
      <ls_write_result>-is_successful = abap_true.
      <ls_write_result>-is_committed = abap_true.
    ENDLOOP.
  ENDMETHOD.

  METHOD delete_order_items.
    validate_test_run( iv_test_run = iv_test_run ).
    validate_item_change(
      iv_purchase_order_number = iv_purchase_order_number
      it_item_numbers          = it_item_numbers ).

    DATA(ls_write_result) = mo_api->mark_items_for_deletion(
      iv_purchase_order_number = iv_purchase_order_number
      it_item_numbers          = it_item_numbers
      iv_test_run              = iv_test_run ).
    ls_write_result-purchase_order_number = iv_purchase_order_number.
    ls_write_result-submitted_item_numbers = it_item_numbers.
    rs_result = complete_write(
      is_result   = ls_write_result
      iv_test_run = iv_test_run ).
    rs_result-purchase_order_number = iv_purchase_order_number.
  ENDMETHOD.

  METHOD delete_orders_items_bulk.
    validate_test_run( iv_test_run = iv_test_run ).
    validate_stop_on_failure(
      iv_stop_on_failure = iv_stop_on_failure ).
    DATA lt_seen_purchase_orders TYPE HASHED TABLE OF
      zif_purchase_order_api=>ty_purchase_order_number
      WITH UNIQUE KEY table_line.

    IF it_deletions IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT it_deletions INTO DATA(ls_deletion).
      INSERT ls_deletion-purchase_order_number
        INTO TABLE lt_seen_purchase_orders.
      IF ls_deletion-purchase_order_number IS INITIAL
          OR sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      validate_item_change(
        iv_purchase_order_number = ls_deletion-purchase_order_number
        it_item_numbers          = ls_deletion-item_numbers ).
    ENDLOOP.

    rs_result-is_successful = abap_true.
    rs_result-is_test_run = iv_test_run.
    LOOP AT it_deletions INTO ls_deletion.
      DATA(ls_write_result) = delete_order_items(
        iv_purchase_order_number = ls_deletion-purchase_order_number
        it_item_numbers          = ls_deletion-item_numbers
        iv_test_run              = iv_test_run ).
      APPEND ls_write_result TO rs_result-order_results.
      IF ls_write_result-is_successful = abap_false.
        IF iv_stop_on_failure = abap_true.
          rs_result-stopped_on_failure = abap_true.
          EXIT.
        ENDIF.
      ENDIF.
    ENDLOOP.

    IF rs_result-stopped_on_failure = abap_true.
      DATA(lv_next_deletion_index) = lines( rs_result-order_results ) + 1.
      LOOP AT it_deletions INTO ls_deletion FROM lv_next_deletion_index.
        APPEND VALUE #(
          purchase_order_number  = ls_deletion-purchase_order_number
          submitted_item_numbers = ls_deletion-item_numbers
          is_test_run            = iv_test_run
          is_skipped             = abap_true ) TO rs_result-order_results.
      ENDLOOP.
    ENDIF.
    rs_result = finalize_bulk_write( is_result = rs_result ).
  ENDMETHOD.

  METHOD delete_orders_items_atomic.
    validate_test_run( iv_test_run = iv_test_run ).
    rs_result = update_order_items_atomic(
      it_changes                = it_deletions
      iv_mark_delivery_complete = abap_false
      iv_test_run               = iv_test_run ).
  ENDMETHOD.

  METHOD mark_delivery_complete.
    validate_test_run( iv_test_run = iv_test_run ).
    validate_item_change(
      iv_purchase_order_number = iv_purchase_order_number
      it_item_numbers          = it_item_numbers ).

    DATA(ls_write_result) = mo_api->mark_items_delivery_complete(
      iv_purchase_order_number = iv_purchase_order_number
      it_item_numbers          = it_item_numbers
      iv_test_run              = iv_test_run ).
    ls_write_result-purchase_order_number = iv_purchase_order_number.
    ls_write_result-submitted_item_numbers = it_item_numbers.
    rs_result = complete_write(
      is_result   = ls_write_result
      iv_test_run = iv_test_run ).
    rs_result-purchase_order_number = iv_purchase_order_number.
  ENDMETHOD.

  METHOD mark_delivery_complete_bulk.
    validate_test_run( iv_test_run = iv_test_run ).
    validate_stop_on_failure(
      iv_stop_on_failure = iv_stop_on_failure ).
    DATA lt_seen_purchase_orders TYPE HASHED TABLE OF
      zif_purchase_order_api=>ty_purchase_order_number
      WITH UNIQUE KEY table_line.

    IF it_changes IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT it_changes INTO DATA(ls_change).
      INSERT ls_change-purchase_order_number
        INTO TABLE lt_seen_purchase_orders.
      IF ls_change-purchase_order_number IS INITIAL OR sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      validate_item_change(
        iv_purchase_order_number = ls_change-purchase_order_number
        it_item_numbers          = ls_change-item_numbers ).
    ENDLOOP.

    rs_result-is_successful = abap_true.
    rs_result-is_test_run = iv_test_run.
    LOOP AT it_changes INTO ls_change.
      DATA(ls_write_result) = mark_delivery_complete(
        iv_purchase_order_number = ls_change-purchase_order_number
        it_item_numbers          = ls_change-item_numbers
        iv_test_run              = iv_test_run ).
      APPEND ls_write_result TO rs_result-order_results.
      IF ls_write_result-is_successful = abap_false.
        IF iv_stop_on_failure = abap_true.
          rs_result-stopped_on_failure = abap_true.
          EXIT.
        ENDIF.
      ENDIF.
    ENDLOOP.

    IF rs_result-stopped_on_failure = abap_true.
      DATA(lv_next_change_index) = lines( rs_result-order_results ) + 1.
      LOOP AT it_changes INTO ls_change FROM lv_next_change_index.
        APPEND VALUE #(
          purchase_order_number  = ls_change-purchase_order_number
          submitted_item_numbers = ls_change-item_numbers
          is_test_run            = iv_test_run
          is_skipped             = abap_true ) TO rs_result-order_results.
      ENDLOOP.
    ENDIF.
    rs_result = finalize_bulk_write( is_result = rs_result ).
  ENDMETHOD.

  METHOD mark_delivery_complete_atomic.
    validate_test_run( iv_test_run = iv_test_run ).
    rs_result = update_order_items_atomic(
      it_changes                = it_changes
      iv_mark_delivery_complete = abap_true
      iv_test_run               = iv_test_run ).
  ENDMETHOD.

  METHOD update_order_items_atomic.
    validate_test_run( iv_test_run = iv_test_run ).
    DATA lt_seen_purchase_orders TYPE HASHED TABLE OF
      zif_purchase_order_api=>ty_purchase_order_number
      WITH UNIQUE KEY table_line.
    DATA ls_write_result TYPE zif_purchase_order_api=>ty_write_result.
    DATA lv_has_failure TYPE abap_bool.

    IF it_changes IS INITIAL
        OR ( iv_mark_delivery_complete <> abap_true
          AND iv_mark_delivery_complete <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT it_changes INTO DATA(ls_change).
      INSERT ls_change-purchase_order_number
        INTO TABLE lt_seen_purchase_orders.
      IF ls_change-purchase_order_number IS INITIAL OR sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      validate_item_change(
        iv_purchase_order_number = ls_change-purchase_order_number
        it_item_numbers          = ls_change-item_numbers ).
    ENDLOOP.

    rs_result-is_test_run = iv_test_run.
    LOOP AT it_changes INTO ls_change.
      IF iv_mark_delivery_complete = abap_true.
        ls_write_result = mo_api->mark_items_delivery_complete(
          iv_purchase_order_number = ls_change-purchase_order_number
          it_item_numbers          = ls_change-item_numbers
          iv_test_run              = iv_test_run ).
      ELSE.
        ls_write_result = mo_api->mark_items_for_deletion(
          iv_purchase_order_number = ls_change-purchase_order_number
          it_item_numbers          = ls_change-item_numbers
          iv_test_run              = iv_test_run ).
      ENDIF.
      ls_write_result-purchase_order_number = ls_change-purchase_order_number.
      ls_write_result-submitted_item_numbers = ls_change-item_numbers.
      ls_write_result-is_test_run = iv_test_run.
      ls_write_result-is_committed = abap_false.

      DATA(lv_order_failed) = xsdbool(
        ls_write_result-is_successful = abap_false ).
      DATA(lv_has_error_message) = abap_false.
      LOOP AT ls_write_result-messages INTO DATA(ls_message).
        IF ls_message-type = 'A'
            OR ls_message-type = 'E'
            OR ls_message-type = 'X'.
          lv_order_failed = abap_true.
          lv_has_error_message = abap_true.
        ENDIF.
      ENDLOOP.
      IF lv_order_failed = abap_true.
        IF lv_has_error_message = abap_false.
          APPEND VALUE #(
            type    = 'E'
            message = 'Purchase order item change failed without an error message' )
            TO ls_write_result-messages.
        ENDIF.
        ls_write_result-is_successful = abap_false.
        lv_has_failure = abap_true.
      ELSE.
        ls_write_result-is_successful = abap_true.
      ENDIF.

      APPEND ls_write_result TO rs_result-order_results.
    ENDLOOP.

    rs_result = finish_atomic_po_changes(
      is_result      = rs_result
      iv_has_failure = lv_has_failure
      iv_test_run    = iv_test_run ).
  ENDMETHOD.

  METHOD change_order_schedules.
    validate_test_run( iv_test_run = iv_test_run ).
    validate_schedule_changes(
      iv_purchase_order_number = iv_purchase_order_number
      it_schedule_changes      = it_schedule_changes ).

    DATA(ls_write_result) = mo_api->change_schedules(
      iv_purchase_order_number = iv_purchase_order_number
      it_schedule_changes      = it_schedule_changes
      iv_test_run              = iv_test_run ).
    ls_write_result-purchase_order_number = iv_purchase_order_number.
    IF ls_write_result-submitted_schedules IS INITIAL.
      ls_write_result-submitted_schedules = it_schedule_changes.
    ENDIF.
    rs_result = complete_write(
      is_result   = ls_write_result
      iv_test_run = iv_test_run ).
    rs_result-purchase_order_number = iv_purchase_order_number.
  ENDMETHOD.

  METHOD change_order_schedules_bulk.
    validate_test_run( iv_test_run = iv_test_run ).
    validate_stop_on_failure(
      iv_stop_on_failure = iv_stop_on_failure ).
    DATA lt_seen_purchase_orders TYPE HASHED TABLE OF
      zif_purchase_order_api=>ty_purchase_order_number
      WITH UNIQUE KEY table_line.

    IF it_changes IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT it_changes INTO DATA(ls_change).
      INSERT ls_change-purchase_order_number
        INTO TABLE lt_seen_purchase_orders.
      IF ls_change-purchase_order_number IS INITIAL OR sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      validate_schedule_changes(
        iv_purchase_order_number = ls_change-purchase_order_number
        it_schedule_changes      = ls_change-schedule_changes ).
    ENDLOOP.

    rs_result-is_successful = abap_true.
    rs_result-is_test_run = iv_test_run.
    LOOP AT it_changes INTO ls_change.
      DATA(ls_write_result) = change_order_schedules(
        iv_purchase_order_number = ls_change-purchase_order_number
        it_schedule_changes      = ls_change-schedule_changes
        iv_test_run              = iv_test_run ).
      APPEND ls_write_result TO rs_result-order_results.
      IF ls_write_result-is_successful = abap_false.
        IF iv_stop_on_failure = abap_true.
          rs_result-stopped_on_failure = abap_true.
          EXIT.
        ENDIF.
      ENDIF.
    ENDLOOP.

    IF rs_result-stopped_on_failure = abap_true.
      DATA(lv_next_change_index) = lines( rs_result-order_results ) + 1.
      LOOP AT it_changes INTO ls_change FROM lv_next_change_index.
        APPEND VALUE #(
          purchase_order_number = ls_change-purchase_order_number
          submitted_schedules   = ls_change-schedule_changes
          is_test_run           = iv_test_run
          is_skipped            = abap_true ) TO rs_result-order_results.
      ENDLOOP.
    ENDIF.
    rs_result = finalize_bulk_write( is_result = rs_result ).
  ENDMETHOD.

  METHOD change_order_schedules_atomic.
    validate_test_run( iv_test_run = iv_test_run ).
    DATA lt_seen_purchase_orders TYPE HASHED TABLE OF
      zif_purchase_order_api=>ty_purchase_order_number
      WITH UNIQUE KEY table_line.
    DATA lv_has_failure TYPE abap_bool.

    IF it_changes IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT it_changes INTO DATA(ls_change).
      INSERT ls_change-purchase_order_number
        INTO TABLE lt_seen_purchase_orders.
      IF ls_change-purchase_order_number IS INITIAL OR sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      validate_schedule_changes(
        iv_purchase_order_number = ls_change-purchase_order_number
        it_schedule_changes      = ls_change-schedule_changes ).
    ENDLOOP.

    rs_result-is_test_run = iv_test_run.
    LOOP AT it_changes INTO ls_change.
      DATA(ls_write_result) = mo_api->change_schedules(
        iv_purchase_order_number = ls_change-purchase_order_number
        it_schedule_changes      = ls_change-schedule_changes
        iv_test_run              = iv_test_run ).
      ls_write_result-purchase_order_number = ls_change-purchase_order_number.
      IF ls_write_result-submitted_schedules IS INITIAL.
        ls_write_result-submitted_schedules = ls_change-schedule_changes.
      ENDIF.
      ls_write_result-is_test_run = iv_test_run.
      ls_write_result-is_committed = abap_false.

      DATA(lv_order_failed) = xsdbool(
        ls_write_result-is_successful = abap_false ).
      DATA(lv_has_error_message) = abap_false.
      LOOP AT ls_write_result-messages INTO DATA(ls_message).
        IF ls_message-type = 'A'
            OR ls_message-type = 'E'
            OR ls_message-type = 'X'.
          lv_order_failed = abap_true.
          lv_has_error_message = abap_true.
        ENDIF.
      ENDLOOP.
      IF lv_order_failed = abap_true.
        IF lv_has_error_message = abap_false.
          APPEND VALUE #(
            type    = 'E'
            message = 'Purchase order schedule change failed without an error message' )
            TO ls_write_result-messages.
        ENDIF.
        ls_write_result-is_successful = abap_false.
        lv_has_failure = abap_true.
      ELSE.
        ls_write_result-is_successful = abap_true.
      ENDIF.

      APPEND ls_write_result TO rs_result-order_results.
    ENDLOOP.

    rs_result = finish_atomic_po_changes(
      is_result      = rs_result
      iv_has_failure = lv_has_failure
      iv_test_run    = iv_test_run ).
  ENDMETHOD.

  METHOD change_base_schedules.
    validate_test_run( iv_test_run = iv_test_run ).
    DATA(lt_order_unit_changes) = convert_base_schedule_changes(
      iv_purchase_order_number = iv_purchase_order_number
      it_schedule_changes      = it_schedule_changes ).
    rs_result = change_order_schedules(
      iv_purchase_order_number = iv_purchase_order_number
      it_schedule_changes      = lt_order_unit_changes
      iv_test_run              = iv_test_run ).
  ENDMETHOD.

  METHOD change_base_schedules_bulk.
    validate_test_run( iv_test_run = iv_test_run ).
    validate_stop_on_failure(
      iv_stop_on_failure = iv_stop_on_failure ).
    DATA lt_seen_purchase_orders TYPE HASHED TABLE OF
      zif_purchase_order_api=>ty_purchase_order_number
      WITH UNIQUE KEY table_line.
    DATA lt_order_schedule_changes TYPE ty_order_schedule_changes.

    IF it_changes IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT it_changes INTO DATA(ls_change).
      INSERT ls_change-purchase_order_number
        INTO TABLE lt_seen_purchase_orders.
      IF ls_change-purchase_order_number IS INITIAL
          OR sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      DATA(lt_schedule_changes) = convert_base_schedule_changes(
        iv_purchase_order_number = ls_change-purchase_order_number
        it_schedule_changes      = ls_change-schedule_changes ).
      APPEND VALUE #(
        purchase_order_number = ls_change-purchase_order_number
        schedule_changes      = lt_schedule_changes )
        TO lt_order_schedule_changes.
    ENDLOOP.

    rs_result = change_order_schedules_bulk(
      it_changes         = lt_order_schedule_changes
      iv_test_run        = iv_test_run
      iv_stop_on_failure = iv_stop_on_failure ).
  ENDMETHOD.

  METHOD change_base_schedules_atomic.
    validate_test_run( iv_test_run = iv_test_run ).
    DATA lt_seen_purchase_orders TYPE HASHED TABLE OF
      zif_purchase_order_api=>ty_purchase_order_number
      WITH UNIQUE KEY table_line.
    DATA lt_order_schedule_changes TYPE ty_order_schedule_changes.

    IF it_changes IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT it_changes INTO DATA(ls_change).
      INSERT ls_change-purchase_order_number
        INTO TABLE lt_seen_purchase_orders.
      IF ls_change-purchase_order_number IS INITIAL
          OR sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      DATA(lt_schedule_changes) = convert_base_schedule_changes(
        iv_purchase_order_number = ls_change-purchase_order_number
        it_schedule_changes      = ls_change-schedule_changes ).
      APPEND VALUE #(
        purchase_order_number = ls_change-purchase_order_number
        schedule_changes      = lt_schedule_changes )
        TO lt_order_schedule_changes.
    ENDLOOP.

    rs_result = change_order_schedules_atomic(
      it_changes  = lt_order_schedule_changes
      iv_test_run = iv_test_run ).
  ENDMETHOD.

  METHOD change_item_quantities.
    validate_test_run( iv_test_run = iv_test_run ).
    validate_item_quantity_changes(
      iv_purchase_order_number = iv_purchase_order_number
      it_item_changes          = it_item_changes ).

    DATA(ls_write_result) = mo_api->change_item_quantities(
      iv_purchase_order_number = iv_purchase_order_number
      it_item_changes          = it_item_changes
      iv_test_run              = iv_test_run ).
    ls_write_result-purchase_order_number = iv_purchase_order_number.
    IF ls_write_result-submitted_item_quantities IS INITIAL.
      ls_write_result-submitted_item_quantities = it_item_changes.
    ENDIF.
    rs_result = complete_write(
      is_result   = ls_write_result
      iv_test_run = iv_test_run ).
    rs_result-purchase_order_number = iv_purchase_order_number.
  ENDMETHOD.

  METHOD change_item_quantities_bulk.
    validate_test_run( iv_test_run = iv_test_run ).
    validate_stop_on_failure(
      iv_stop_on_failure = iv_stop_on_failure ).
    DATA lt_seen_purchase_orders TYPE HASHED TABLE OF
      zif_purchase_order_api=>ty_purchase_order_number
      WITH UNIQUE KEY table_line.

    IF it_changes IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT it_changes INTO DATA(ls_change).
      INSERT ls_change-purchase_order_number
        INTO TABLE lt_seen_purchase_orders.
      IF ls_change-purchase_order_number IS INITIAL
          OR sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      validate_item_quantity_changes(
        iv_purchase_order_number = ls_change-purchase_order_number
        it_item_changes          = ls_change-item_changes ).
    ENDLOOP.

    rs_result-is_successful = abap_true.
    rs_result-is_test_run = iv_test_run.
    LOOP AT it_changes INTO ls_change.
      DATA(ls_write_result) = change_item_quantities(
        iv_purchase_order_number = ls_change-purchase_order_number
        it_item_changes          = ls_change-item_changes
        iv_test_run              = iv_test_run ).
      APPEND ls_write_result TO rs_result-order_results.
      IF ls_write_result-is_successful = abap_false.
        IF iv_stop_on_failure = abap_true.
          rs_result-stopped_on_failure = abap_true.
          EXIT.
        ENDIF.
      ENDIF.
    ENDLOOP.

    IF rs_result-stopped_on_failure = abap_true.
      DATA(lv_next_change_index) = lines( rs_result-order_results ) + 1.
      LOOP AT it_changes INTO ls_change FROM lv_next_change_index.
        APPEND VALUE #(
          purchase_order_number     = ls_change-purchase_order_number
          submitted_item_quantities = ls_change-item_changes
          is_test_run               = iv_test_run
          is_skipped                = abap_true ) TO rs_result-order_results.
      ENDLOOP.
    ENDIF.
    rs_result = finalize_bulk_write( is_result = rs_result ).
  ENDMETHOD.

  METHOD change_item_quantities_atomic.
    validate_test_run( iv_test_run = iv_test_run ).
    DATA lt_seen_purchase_orders TYPE HASHED TABLE OF
      zif_purchase_order_api=>ty_purchase_order_number
      WITH UNIQUE KEY table_line.
    DATA lv_has_failure TYPE abap_bool.

    IF it_changes IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT it_changes INTO DATA(ls_change).
      INSERT ls_change-purchase_order_number
        INTO TABLE lt_seen_purchase_orders.
      IF ls_change-purchase_order_number IS INITIAL
          OR sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      validate_item_quantity_changes(
        iv_purchase_order_number = ls_change-purchase_order_number
        it_item_changes          = ls_change-item_changes ).
    ENDLOOP.

    rs_result-is_test_run = iv_test_run.
    LOOP AT it_changes INTO ls_change.
      DATA(ls_write_result) = mo_api->change_item_quantities(
        iv_purchase_order_number = ls_change-purchase_order_number
        it_item_changes          = ls_change-item_changes
        iv_test_run              = iv_test_run ).
      ls_write_result-purchase_order_number =
        ls_change-purchase_order_number.
      IF ls_write_result-submitted_item_quantities IS INITIAL.
        ls_write_result-submitted_item_quantities = ls_change-item_changes.
      ENDIF.
      ls_write_result-is_test_run = iv_test_run.
      ls_write_result-is_committed = abap_false.

      DATA(lv_order_failed) = xsdbool(
        ls_write_result-is_successful = abap_false ).
      DATA(lv_has_error_message) = abap_false.
      LOOP AT ls_write_result-messages INTO DATA(ls_message).
        IF ls_message-type = 'A'
            OR ls_message-type = 'E'
            OR ls_message-type = 'X'.
          lv_order_failed = abap_true.
          lv_has_error_message = abap_true.
        ENDIF.
      ENDLOOP.
      IF lv_order_failed = abap_true.
        IF lv_has_error_message = abap_false.
          APPEND VALUE #(
            type    = 'E'
            message = 'Purchase order item quantity change failed without an error message' )
            TO ls_write_result-messages.
        ENDIF.
        ls_write_result-is_successful = abap_false.
        lv_has_failure = abap_true.
      ELSE.
        ls_write_result-is_successful = abap_true.
      ENDIF.
      APPEND ls_write_result TO rs_result-order_results.
    ENDLOOP.

    rs_result = finish_atomic_po_changes(
      is_result      = rs_result
      iv_has_failure = lv_has_failure
      iv_test_run    = iv_test_run ).
  ENDMETHOD.

  METHOD change_qty_from_base.
    validate_test_run( iv_test_run = iv_test_run ).
    DATA(lt_order_unit_changes) = convert_base_quantity_changes(
      iv_purchase_order_number = iv_purchase_order_number
      it_item_changes          = it_item_changes ).
    rs_result = change_item_quantities(
      iv_purchase_order_number = iv_purchase_order_number
      it_item_changes          = lt_order_unit_changes
      iv_test_run              = iv_test_run ).
  ENDMETHOD.

  METHOD change_qty_from_base_bulk.
    validate_test_run( iv_test_run = iv_test_run ).
    validate_stop_on_failure(
      iv_stop_on_failure = iv_stop_on_failure ).
    DATA lt_seen_purchase_orders TYPE HASHED TABLE OF
      zif_purchase_order_api=>ty_purchase_order_number
      WITH UNIQUE KEY table_line.
    DATA lt_order_qty_changes TYPE ty_order_qty_changes.

    IF it_changes IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT it_changes INTO DATA(ls_change).
      INSERT ls_change-purchase_order_number
        INTO TABLE lt_seen_purchase_orders.
      IF ls_change-purchase_order_number IS INITIAL
          OR sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      DATA(lt_item_changes) = convert_base_quantity_changes(
        iv_purchase_order_number = ls_change-purchase_order_number
        it_item_changes          = ls_change-item_changes ).
      APPEND VALUE #(
        purchase_order_number = ls_change-purchase_order_number
        item_changes          = lt_item_changes )
        TO lt_order_qty_changes.
    ENDLOOP.

    rs_result = change_item_quantities_bulk(
      it_changes         = lt_order_qty_changes
      iv_test_run        = iv_test_run
      iv_stop_on_failure = iv_stop_on_failure ).
  ENDMETHOD.

  METHOD change_qty_from_base_atomic.
    validate_test_run( iv_test_run = iv_test_run ).
    DATA lt_seen_purchase_orders TYPE HASHED TABLE OF
      zif_purchase_order_api=>ty_purchase_order_number
      WITH UNIQUE KEY table_line.
    DATA lt_order_qty_changes TYPE ty_order_qty_changes.

    IF it_changes IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT it_changes INTO DATA(ls_change).
      INSERT ls_change-purchase_order_number
        INTO TABLE lt_seen_purchase_orders.
      IF ls_change-purchase_order_number IS INITIAL
          OR sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      DATA(lt_item_changes) = convert_base_quantity_changes(
        iv_purchase_order_number = ls_change-purchase_order_number
        it_item_changes          = ls_change-item_changes ).
      APPEND VALUE #(
        purchase_order_number = ls_change-purchase_order_number
        item_changes          = lt_item_changes )
        TO lt_order_qty_changes.
    ENDLOOP.

    rs_result = change_item_quantities_atomic(
      it_changes  = lt_order_qty_changes
      iv_test_run = iv_test_run ).
  ENDMETHOD.

  METHOD validate_request.
    TYPES ty_seen_item_number TYPE
      zif_purchase_order_api=>ty_item_number.
    DATA lt_seen_item_numbers TYPE HASHED TABLE OF ty_seen_item_number
      WITH UNIQUE KEY table_line.

    IF is_request-document_type IS INITIAL
        OR is_request-company_code IS INITIAL
        OR is_request-purchasing_org IS INITIAL
        OR is_request-purchasing_group IS INITIAL
        OR is_request-vendor IS INITIAL
        OR is_request-document_date IS INITIAL
        OR zcl_date_validation=>is_valid_gregorian_date(
          iv_date = is_request-document_date ) <> abap_true
        OR is_request-items IS INITIAL
        OR ( is_request-is_test_run <> abap_true
          AND is_request-is_test_run <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT is_request-items INTO DATA(ls_item).
      INSERT ls_item-item_number INTO TABLE lt_seen_item_numbers.
      IF ls_item-item_number IS INITIAL
          OR sy-subrc <> 0
          OR ls_item-material IS INITIAL
          OR ls_item-plant IS INITIAL
          OR ls_item-quantity <= 0
          OR ls_item-unit IS INITIAL
          OR zcl_date_validation=>is_valid_gregorian_date(
            iv_date = ls_item-delivery_date ) <> abap_true.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      IF ls_item-purchase_requisition IS INITIAL
          AND ls_item-requisition_item IS NOT INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      IF ls_item-purchase_requisition IS NOT INITIAL
          AND ( ls_item-requisition_item IS INITIAL
            OR ls_item-source_info_record IS NOT INITIAL
            OR ls_item-source_agreement IS NOT INITIAL
            OR ls_item-source_agreement_item IS NOT INITIAL ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      IF ls_item-purchase_requisition IS INITIAL
          AND ( ls_item-source_info_record IS INITIAL
            AND ls_item-source_agreement IS INITIAL
            AND ls_item-source_agreement_item IS INITIAL )
          OR ( ls_item-source_info_record IS NOT INITIAL
            AND ( ls_item-source_agreement IS NOT INITIAL
              OR ls_item-source_agreement_item IS NOT INITIAL ) )
          OR ( ls_item-source_agreement IS INITIAL
            AND ls_item-source_agreement_item IS NOT INITIAL )
          OR ( ls_item-source_agreement IS NOT INITIAL
            AND ls_item-source_agreement_item IS INITIAL ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validate_test_run.
    IF iv_test_run <> abap_true
        AND iv_test_run <> abap_false.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
  ENDMETHOD.

  METHOD validate_stop_on_failure.
    IF iv_stop_on_failure <> abap_true
        AND iv_stop_on_failure <> abap_false.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
  ENDMETHOD.

  METHOD finalize_bulk_write.
    rs_result = is_result.
    CLEAR: rs_result-successful_count,
      rs_result-failed_count,
      rs_result-skipped_count,
      rs_result-is_committed.
    rs_result-is_successful = abap_true.

    LOOP AT rs_result-order_results
        ASSIGNING FIELD-SYMBOL(<ls_write_result>).
      IF <ls_write_result>-is_skipped = abap_true.
        ADD 1 TO rs_result-skipped_count.
      ELSEIF <ls_write_result>-is_attempted = abap_true.
        IF <ls_write_result>-is_successful = abap_true.
          ADD 1 TO rs_result-successful_count.
          IF <ls_write_result>-is_committed = abap_true.
            rs_result-is_committed = abap_true.
          ENDIF.
        ELSE.
          ADD 1 TO rs_result-failed_count.
          rs_result-is_successful = abap_false.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validate_item_change.
    DATA lt_seen_item_numbers TYPE HASHED TABLE OF
      zif_purchase_order_api=>ty_item_number
      WITH UNIQUE KEY table_line.

    IF iv_purchase_order_number IS INITIAL OR it_item_numbers IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT it_item_numbers INTO DATA(lv_item_number).
      INSERT lv_item_number INTO TABLE lt_seen_item_numbers.
      IF lv_item_number IS INITIAL OR sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validate_schedule_changes.
    TYPES:
      BEGIN OF ty_schedule_key,
        item_number   TYPE zif_purchase_order_api=>ty_item_number,
        schedule_line TYPE zif_purchase_order_api=>ty_schedule_line_number,
      END OF ty_schedule_key.
    DATA lt_seen_schedule_keys TYPE HASHED TABLE OF ty_schedule_key
      WITH UNIQUE KEY item_number schedule_line.

    IF iv_purchase_order_number IS INITIAL OR it_schedule_changes IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT it_schedule_changes INTO DATA(ls_schedule_change).
      INSERT VALUE #(
        item_number   = ls_schedule_change-item_number
        schedule_line = ls_schedule_change-schedule_line )
        INTO TABLE lt_seen_schedule_keys.
      IF ls_schedule_change-item_number IS INITIAL
          OR ls_schedule_change-schedule_line IS INITIAL
          OR sy-subrc <> 0
          OR ( ls_schedule_change-change_quantity <> abap_true
            AND ls_schedule_change-change_quantity <> abap_false )
          OR ( ls_schedule_change-change_delivery_date <> abap_true
            AND ls_schedule_change-change_delivery_date <> abap_false )
          OR ( ls_schedule_change-change_quantity = abap_false
            AND ls_schedule_change-change_delivery_date = abap_false )
          OR ( ls_schedule_change-change_quantity = abap_true
            AND ls_schedule_change-quantity <= 0 )
          OR ( ls_schedule_change-change_quantity = abap_false
            AND ls_schedule_change-quantity IS NOT INITIAL )
          OR ( ls_schedule_change-change_delivery_date = abap_true
            AND ( ls_schedule_change-delivery_date IS INITIAL
              OR zcl_date_validation=>is_valid_gregorian_date(
                iv_date = ls_schedule_change-delivery_date ) <> abap_true ) )
          OR ( ls_schedule_change-change_delivery_date = abap_false
            AND ls_schedule_change-delivery_date IS NOT INITIAL ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validate_item_quantity_changes.
    DATA lt_seen_item_numbers TYPE HASHED TABLE OF
      zif_purchase_order_api=>ty_item_number
      WITH UNIQUE KEY table_line.

    IF iv_purchase_order_number IS INITIAL OR it_item_changes IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT it_item_changes INTO DATA(ls_item_change).
      INSERT ls_item_change-item_number INTO TABLE lt_seen_item_numbers.
      IF ls_item_change-item_number IS INITIAL
          OR sy-subrc <> 0
          OR ls_item_change-quantity <= 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD convert_base_quantity_changes.
    DATA lt_seen_item_numbers TYPE HASHED TABLE OF
      zif_purchase_order_api=>ty_item_number
      WITH UNIQUE KEY table_line.

    IF iv_purchase_order_number IS INITIAL OR it_item_changes IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT it_item_changes INTO DATA(ls_base_change).
      INSERT ls_base_change-item_number INTO TABLE lt_seen_item_numbers.
      IF ls_base_change-item_number IS INITIAL
          OR sy-subrc <> 0
          OR ls_base_change-base_quantity <= 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    DATA(ls_order_read) = read_order(
      iv_purchase_order_number = iv_purchase_order_number ).
    IF ls_order_read-is_successful <> abap_true.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT it_item_changes INTO ls_base_change.
      READ TABLE ls_order_read-items INTO DATA(ls_order_item)
        WITH KEY item_number = ls_base_change-item_number.
      IF sy-subrc <> 0
          OR ls_order_item-material IS INITIAL
          OR ls_order_item-unit IS INITIAL
          OR ls_order_item-is_deleted = abap_true
          OR ls_order_item-delivery_complete = abap_true.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      DATA(ls_conversion) = mo_uom_converter->convert_from_base(
        iv_material      = ls_order_item-material
        iv_base_quantity = ls_base_change-base_quantity
        iv_target_unit   = ls_order_item-unit ).
      IF ls_conversion-is_successful <> abap_true
          OR ls_conversion-alternative_quantity <= 0
          OR ls_conversion-alternative_unit <> ls_order_item-unit.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      APPEND VALUE #(
        item_number = ls_base_change-item_number
        quantity    = ls_conversion-alternative_quantity )
        TO rt_item_changes.
    ENDLOOP.
  ENDMETHOD.

  METHOD convert_base_schedule_changes.
    DATA lv_has_quantity_change TYPE abap_bool.

    IF iv_purchase_order_number IS INITIAL OR it_schedule_changes IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT it_schedule_changes INTO DATA(ls_base_change).
      IF ( ls_base_change-change_quantity = abap_true
          AND ls_base_change-base_quantity <= 0 )
          OR ( ls_base_change-change_quantity = abap_false
            AND ls_base_change-base_quantity IS NOT INITIAL ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      IF ls_base_change-change_quantity = abap_true.
        lv_has_quantity_change = abap_true.
      ENDIF.
      APPEND VALUE #(
        item_number          = ls_base_change-item_number
        schedule_line        = ls_base_change-schedule_line
        change_quantity      = ls_base_change-change_quantity
        quantity             = COND #( WHEN ls_base_change-change_quantity
          = abap_true THEN 1 )
        change_delivery_date = ls_base_change-change_delivery_date
        delivery_date        = ls_base_change-delivery_date )
        TO rt_schedule_changes.
    ENDLOOP.

    validate_schedule_changes(
      iv_purchase_order_number = iv_purchase_order_number
      it_schedule_changes      = rt_schedule_changes ).
    IF lv_has_quantity_change = abap_false.
      RETURN.
    ENDIF.

    DATA(ls_order_read) = read_order(
      iv_purchase_order_number = iv_purchase_order_number ).
    IF ls_order_read-is_successful <> abap_true.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT it_schedule_changes INTO ls_base_change.
      IF ls_base_change-change_quantity = abap_false.
        CONTINUE.
      ENDIF.

      READ TABLE ls_order_read-items INTO DATA(ls_order_item)
        WITH KEY item_number = ls_base_change-item_number.
      IF sy-subrc <> 0
          OR ls_order_item-material IS INITIAL
          OR ls_order_item-unit IS INITIAL
          OR ls_order_item-is_deleted = abap_true
          OR ls_order_item-delivery_complete = abap_true.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      DATA(ls_conversion) = mo_uom_converter->convert_from_base(
        iv_material      = ls_order_item-material
        iv_base_quantity = ls_base_change-base_quantity
        iv_target_unit   = ls_order_item-unit ).
      IF ls_conversion-is_successful <> abap_true
          OR ls_conversion-alternative_quantity <= 0
          OR ls_conversion-alternative_unit <> ls_order_item-unit.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      READ TABLE rt_schedule_changes ASSIGNING
        FIELD-SYMBOL(<ls_schedule_change>)
        WITH KEY item_number = ls_base_change-item_number
                 schedule_line = ls_base_change-schedule_line.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      <ls_schedule_change>-quantity =
        ls_conversion-alternative_quantity.
    ENDLOOP.
  ENDMETHOD.

  METHOD complete_write.
    rs_result = is_result.
    rs_result-is_test_run = iv_test_run.
    rs_result-is_attempted = abap_true.
    rs_result-is_committed = abap_false.

    DATA(lv_has_error_message) = abap_false.
    LOOP AT rs_result-messages INTO DATA(ls_message).
      IF ls_message-type = 'A'
          OR ls_message-type = 'E'
          OR ls_message-type = 'X'.
        lv_has_error_message = abap_true.
      ENDIF.
    ENDLOOP.

    IF rs_result-is_successful = abap_false
        OR lv_has_error_message = abap_true.
      IF lv_has_error_message = abap_false.
        APPEND VALUE #(
          type    = 'E'
          message = 'Purchase order write failed without an error message' )
          TO rs_result-messages.
      ENDIF.
      IF iv_test_run <> abap_true.
        mo_api->rollback( ).
      ENDIF.
      rs_result-is_successful = abap_false.
      CLEAR rs_result-purchase_order_number.
      RETURN.
    ENDIF.

    IF iv_test_run = abap_true.
      rs_result-is_successful = abap_true.
      RETURN.
    ENDIF.

    IF rs_result-purchase_order_number IS INITIAL.
      mo_api->rollback( ).
      APPEND VALUE #(
        type    = 'E'
        message = 'Purchase order write returned no document number' )
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
      ELSE.
        APPEND VALUE #(
          type    = 'E'
          message = 'Purchase order commit failed without an error message' )
          TO rs_result-messages.
      ENDIF.
      rs_result-is_successful = abap_false.
      CLEAR rs_result-purchase_order_number.
      RETURN.
    ENDIF.

    rs_result-is_successful = abap_true.
    rs_result-is_committed = abap_true.
  ENDMETHOD.

ENDCLASS.
