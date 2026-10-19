CLASS zcl_so_stock_service DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_requests TYPE zif_so_stock_repository=>ty_requests.
    TYPES ty_item_requests TYPE zif_so_stock_repository=>ty_item_requests.
    TYPES:
      BEGIN OF ty_stock_unit_request,
        request_id               TYPE c LENGTH 30,
        sales_document           TYPE vbap-vbeln,
        item_number              TYPE vbap-posnr,
        requested_unit           TYPE mara-meins,
        reservation_through_date TYPE d,
      END OF ty_stock_unit_request.
    TYPES ty_stock_unit_requests TYPE STANDARD TABLE OF
      ty_stock_unit_request WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_result,
        request_id               TYPE c LENGTH 30,
        sales_document           TYPE vbap-vbeln,
        item_number              TYPE vbap-posnr,
        material                 TYPE mara-matnr,
        plant                    TYPE marc-werks,
        reservation_through_date TYPE d,
        base_unit                TYPE mara-meins,
        unrestricted_qty         TYPE mska-kalab,
        reserved_quantity        TYPE resb-bdmng,
        available_quantity       TYPE mska-kalab,
        stock_balances           TYPE zif_so_stock_repository=>ty_stock_rows,
        open_reservations        TYPE zif_so_stock_repository=>ty_reservation_rows,
      END OF ty_result.
    TYPES ty_results TYPE STANDARD TABLE OF ty_result WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_stock_unit_result,
        request_id                 TYPE c LENGTH 30,
        sales_document             TYPE vbap-vbeln,
        item_number                TYPE vbap-posnr,
        material                   TYPE mara-matnr,
        plant                      TYPE marc-werks,
        requested_unit             TYPE mara-meins,
        base_unit                  TYPE mara-meins,
        unrestricted_base_quantity TYPE mska-kalab,
        unrestricted_quantity      TYPE mska-kalab,
        reserved_base_quantity     TYPE resb-bdmng,
        reserved_quantity          TYPE resb-bdmng,
        available_base_quantity    TYPE mska-kalab,
        available_quantity         TYPE mska-kalab,
        stock_snapshot             TYPE ty_result,
      END OF ty_stock_unit_result.
    TYPES ty_stock_unit_results TYPE STANDARD TABLE OF
      ty_stock_unit_result WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_issue_request,
        request_id               TYPE c LENGTH 30,
        sales_document           TYPE vbap-vbeln,
        item_number              TYPE vbap-posnr,
        requested_quantity       TYPE mska-kalab,
        reservation_through_date TYPE d,
        required_date            TYPE d,
        priority                 TYPE i,
      END OF ty_issue_request.
    TYPES ty_issue_requests TYPE STANDARD TABLE OF ty_issue_request
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_issue_result,
        request_id         TYPE c LENGTH 30,
        sales_document     TYPE vbap-vbeln,
        item_number        TYPE vbap-posnr,
        material           TYPE mara-matnr,
        plant              TYPE marc-werks,
        base_unit          TYPE mara-meins,
        requested_quantity TYPE mska-kalab,
        available_quantity TYPE mska-kalab,
        covered_quantity   TYPE mska-kalab,
        shortfall_quantity TYPE mska-kalab,
        is_sufficient      TYPE abap_bool,
        stock_snapshot     TYPE ty_result,
        required_date      TYPE d,
        priority           TYPE i,
      END OF ty_issue_result.
    TYPES ty_issue_results TYPE STANDARD TABLE OF ty_issue_result
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_issue_unit_request,
        request_id               TYPE c LENGTH 30,
        sales_document           TYPE vbap-vbeln,
        item_number              TYPE vbap-posnr,
        requested_quantity       TYPE mska-kalab,
        requested_unit           TYPE mara-meins,
        reservation_through_date TYPE d,
        required_date            TYPE d,
        priority                 TYPE i,
      END OF ty_issue_unit_request.
    TYPES ty_issue_unit_requests TYPE STANDARD TABLE OF
      ty_issue_unit_request WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_issue_unit_result,
        request_id              TYPE c LENGTH 30,
        sales_document          TYPE vbap-vbeln,
        item_number             TYPE vbap-posnr,
        material                TYPE mara-matnr,
        plant                   TYPE marc-werks,
        requested_quantity      TYPE mska-kalab,
        requested_unit          TYPE mara-meins,
        requested_base_quantity TYPE mska-kalab,
        available_quantity      TYPE mska-kalab,
        available_base_quantity TYPE mska-kalab,
        covered_quantity        TYPE mska-kalab,
        covered_base_quantity   TYPE mska-kalab,
        shortfall_quantity      TYPE mska-kalab,
        shortfall_base_quantity TYPE mska-kalab,
        base_unit               TYPE mara-meins,
        is_sufficient           TYPE abap_bool,
        stock_snapshot          TYPE ty_result,
        required_date           TYPE d,
        priority                TYPE i,
      END OF ty_issue_unit_result.
    TYPES ty_issue_unit_results TYPE STANDARD TABLE OF
      ty_issue_unit_result WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_fefo_issue_request,
        request_id               TYPE c LENGTH 30,
        sales_document           TYPE vbap-vbeln,
        item_number              TYPE vbap-posnr,
        batch                    TYPE mchb-charg,
        requested_quantity       TYPE mska-kalab,
        reservation_through_date TYPE d,
        required_date            TYPE d,
        priority                 TYPE i,
        storage_location         TYPE mard-lgort,
        minimum_shelf_life_days  TYPE i,
        require_known_expiry     TYPE abap_bool,
        allow_undated_batches    TYPE abap_bool,
        require_full_quantity    TYPE abap_bool,
        allow_location_fallback  TYPE abap_bool,
      END OF ty_fefo_issue_request.
    TYPES ty_fefo_issue_requests TYPE STANDARD TABLE OF
      ty_fefo_issue_request WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_fefo_issue_unit_request,
        request_id               TYPE c LENGTH 30,
        sales_document           TYPE vbap-vbeln,
        item_number              TYPE vbap-posnr,
        batch                    TYPE mchb-charg,
        requested_quantity       TYPE mska-kalab,
        requested_unit           TYPE mara-meins,
        reservation_through_date TYPE d,
        required_date            TYPE d,
        priority                 TYPE i,
        storage_location         TYPE mard-lgort,
        minimum_shelf_life_days  TYPE i,
        require_known_expiry     TYPE abap_bool,
        allow_undated_batches    TYPE abap_bool,
        require_full_quantity    TYPE abap_bool,
        allow_location_fallback  TYPE abap_bool,
      END OF ty_fefo_issue_unit_request.
    TYPES ty_fefo_issue_unit_requests TYPE STANDARD TABLE OF
      ty_fefo_issue_unit_request WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_fefo_request_location,
        request_id       TYPE c LENGTH 30,
        storage_location TYPE mard-lgort,
      END OF ty_fefo_request_location.
    TYPES ty_fefo_request_locations TYPE STANDARD TABLE OF
      ty_fefo_request_location WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_fefo_request_location_priority,
        request_id       TYPE c LENGTH 30,
        storage_location TYPE mard-lgort,
        priority_rank    TYPE i,
      END OF ty_fefo_request_location_priority.
    TYPES ty_fefo_request_location_priorities TYPE STANDARD TABLE OF
      ty_fefo_request_location_priority WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_fefo_issue_summary,
        request_id                TYPE c LENGTH 30,
        sales_document            TYPE vbap-vbeln,
        item_number               TYPE vbap-posnr,
        reservation_through_date  TYPE d,
        material                  TYPE mara-matnr,
        plant                     TYPE marc-werks,
        requested_quantity        TYPE mska-kalab,
        requested_unit            TYPE mara-meins,
        requested_base_quantity   TYPE mska-kalab,
        available_quantity        TYPE mska-kalab,
        available_base_quantity   TYPE mska-kalab,
        covered_quantity          TYPE mska-kalab,
        covered_base_quantity     TYPE mska-kalab,
        shortfall_quantity        TYPE mska-kalab,
        shortfall_base_quantity   TYPE mska-kalab,
        base_unit                 TYPE mara-meins,
        as_of_date                TYPE d,
        minimum_shelf_life_days   TYPE i,
        include_undated_batches   TYPE abap_bool,
        require_known_expiry      TYPE abap_bool,
        allow_undated_batches     TYPE abap_bool,
        is_sufficient             TYPE abap_bool,
        stock_snapshot            TYPE ty_result,
        required_date             TYPE d,
        priority                  TYPE i,
        selected_storage_location TYPE mard-lgort,
        allow_location_fallback   TYPE abap_bool,
      END OF ty_fefo_issue_summary.
    TYPES ty_fefo_issue_summaries TYPE STANDARD TABLE OF
      ty_fefo_issue_summary WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_fefo_issue_batch_allocation,
        request_id                TYPE c LENGTH 30,
        sales_document            TYPE vbap-vbeln,
        item_number               TYPE vbap-posnr,
        material                  TYPE mara-matnr,
        plant                     TYPE marc-werks,
        storage_location          TYPE mard-lgort,
        batch                     TYPE mchb-charg,
        expiration_date           TYPE mcha-vfdat,
        as_of_date                TYPE d,
        minimum_shelf_life_days   TYPE i,
        include_undated_batches   TYPE abap_bool,
        require_known_expiry      TYPE abap_bool,
        allow_undated_batches     TYPE abap_bool,
        base_unit                 TYPE mara-meins,
        allocated_base_quantity   TYPE mska-kalab,
        requested_unit            TYPE mara-meins,
        allocated_quantity        TYPE mska-kalab,
        required_date             TYPE d,
        priority                  TYPE i,
        selected_storage_location TYPE mard-lgort,
        allow_location_fallback   TYPE abap_bool,
      END OF ty_fefo_issue_batch_allocation.
    TYPES ty_fefo_issue_batch_allocations TYPE STANDARD TABLE OF
      ty_fefo_issue_batch_allocation WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_fefo_issue_result,
        allocations        TYPE ty_fefo_issue_summaries,
        batch_allocations  TYPE ty_fefo_issue_batch_allocations,
        location_allowlist TYPE STANDARD TABLE OF mard-lgort WITH EMPTY KEY,
        request_locations  TYPE ty_fefo_request_locations,
      END OF ty_fefo_issue_result.

    METHODS constructor
      IMPORTING
        io_repository     TYPE REF TO zif_so_stock_repository
        io_uom_converter  TYPE REF TO zif_material_uom_converter OPTIONAL
        io_uom_repository TYPE REF TO zif_material_uom_repository OPTIONAL.

    METHODS read_stock
      IMPORTING
        iv_sales_document           TYPE vbap-vbeln
        iv_item_number              TYPE vbap-posnr
        iv_material                 TYPE mara-matnr
        iv_plant                    TYPE marc-werks
        iv_reservation_through_date TYPE d OPTIONAL
      RETURNING
        VALUE(rs_result)            TYPE ty_result
      RAISING
        zcx_invalid_stock_request.

    METHODS read_sales_order_item
      IMPORTING
        iv_sales_document           TYPE vbap-vbeln
        iv_item_number              TYPE vbap-posnr
        iv_reservation_through_date TYPE d OPTIONAL
      RETURNING
        VALUE(rs_result)            TYPE ty_result
      RAISING
        zcx_invalid_stock_request.

    METHODS read_sales_order_items_bulk
      IMPORTING
        it_item_requests  TYPE ty_item_requests
      RETURNING
        VALUE(rt_results) TYPE ty_results
      RAISING
        zcx_invalid_stock_request.

    METHODS read_stock_in_unit
      IMPORTING
        iv_sales_document           TYPE vbap-vbeln
        iv_item_number              TYPE vbap-posnr
        iv_requested_unit           TYPE mara-meins
        iv_reservation_through_date TYPE d OPTIONAL
      RETURNING
        VALUE(rs_result)            TYPE ty_stock_unit_result
      RAISING
        zcx_invalid_stock_request.

    METHODS read_stock_bulk_in_unit
      IMPORTING
        it_requests       TYPE ty_stock_unit_requests
      RETURNING
        VALUE(rt_results) TYPE ty_stock_unit_results
      RAISING
        zcx_invalid_stock_request.

    METHODS read_stock_bulk
      IMPORTING
        it_requests       TYPE ty_requests
      RETURNING
        VALUE(rt_results) TYPE ty_results
      RAISING
        zcx_invalid_stock_request.

    METHODS preview_issue_demands
      IMPORTING
        it_requests               TYPE ty_issue_requests
        iv_require_full_quantity  TYPE abap_bool DEFAULT abap_false
        iv_prioritize_by_date     TYPE abap_bool DEFAULT abap_false
        iv_prioritize_by_priority TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rt_results)         TYPE ty_issue_results
      RAISING
        zcx_invalid_stock_request.

    METHODS preview_issue_demands_in_unit
      IMPORTING
        it_requests               TYPE ty_issue_unit_requests
        iv_require_full_quantity  TYPE abap_bool DEFAULT abap_false
        iv_prioritize_by_date     TYPE abap_bool DEFAULT abap_false
        iv_prioritize_by_priority TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rt_results)         TYPE ty_issue_unit_results
      RAISING
        zcx_invalid_stock_request.

    METHODS preview_issue_demands_by_fefo
      IMPORTING
        it_requests                    TYPE ty_fefo_issue_requests
        iv_as_of_date                  TYPE d DEFAULT sy-datum
        iv_min_days                    TYPE i DEFAULT 0
        iv_include_undated_batches     TYPE abap_bool DEFAULT abap_true
        iv_require_full_quantity       TYPE abap_bool DEFAULT abap_false
        iv_prioritize_by_date          TYPE abap_bool DEFAULT abap_false
        iv_prioritize_by_priority      TYPE abap_bool DEFAULT abap_false
        it_storage_location_priority   TYPE
          zcl_stock_service=>ty_storage_locations OPTIONAL
        it_request_location_priorities TYPE
          ty_fefo_request_location_priorities OPTIONAL
        it_location_allowlist          TYPE
          zcl_stock_service=>ty_storage_locations OPTIONAL
        it_request_locations           TYPE ty_fefo_request_locations OPTIONAL
      RETURNING
        VALUE(rs_result)               TYPE ty_fefo_issue_result
      RAISING
        zcx_invalid_stock_request.

    METHODS preview_issue_fefo_uom
      IMPORTING
        it_requests                    TYPE ty_fefo_issue_unit_requests
        iv_as_of_date                  TYPE d DEFAULT sy-datum
        iv_min_days                    TYPE i DEFAULT 0
        iv_include_undated_batches     TYPE abap_bool DEFAULT abap_true
        iv_require_full_quantity       TYPE abap_bool DEFAULT abap_false
        iv_prioritize_by_date          TYPE abap_bool DEFAULT abap_false
        iv_prioritize_by_priority      TYPE abap_bool DEFAULT abap_false
        it_storage_location_priority   TYPE
          zcl_stock_service=>ty_storage_locations OPTIONAL
        it_request_location_priorities TYPE
          ty_fefo_request_location_priorities OPTIONAL
        it_location_allowlist          TYPE
          zcl_stock_service=>ty_storage_locations OPTIONAL
        it_request_locations           TYPE ty_fefo_request_locations OPTIONAL
      RETURNING
        VALUE(rs_result)               TYPE ty_fefo_issue_result
      RAISING
        zcx_invalid_stock_request.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_fefo_issue_internal_request,
        request_id                TYPE c LENGTH 30,
        sales_document            TYPE vbap-vbeln,
        item_number               TYPE vbap-posnr,
        selected_batch            TYPE mchb-charg,
        selected_storage_location TYPE mard-lgort,
        required_date             TYPE d,
        priority                  TYPE i,
        requested_quantity        TYPE mska-kalab,
        requested_unit            TYPE mara-meins,
        is_unit_quantity          TYPE abap_bool,
        reservation_through_date  TYPE d,
        minimum_shelf_life_days   TYPE i,
        require_known_expiry      TYPE abap_bool,
        allow_undated_batches     TYPE abap_bool,
        require_full_quantity     TYPE abap_bool,
        allow_location_fallback   TYPE abap_bool,
      END OF ty_fefo_issue_internal_request.
    TYPES ty_fefo_issue_internal_requests TYPE STANDARD TABLE OF
      ty_fefo_issue_internal_request WITH EMPTY KEY.

    METHODS preview_issue_fefo_int
      IMPORTING
        it_requests                    TYPE ty_fefo_issue_internal_requests
        iv_as_of_date                  TYPE d
        iv_min_days                    TYPE i
        iv_include_undated_batches     TYPE abap_bool
        iv_require_full_quantity       TYPE abap_bool
        iv_prioritize_by_date          TYPE abap_bool
        iv_prioritize_by_priority      TYPE abap_bool
        it_storage_location_priority   TYPE
          zcl_stock_service=>ty_storage_locations
        it_request_location_priorities TYPE
          ty_fefo_request_location_priorities
        it_location_allowlist          TYPE
          zcl_stock_service=>ty_storage_locations
        it_request_locations           TYPE ty_fefo_request_locations
      RETURNING
        VALUE(rs_result)               TYPE ty_fefo_issue_result
      RAISING
        zcx_invalid_stock_request.

    DATA mo_repository TYPE REF TO zif_so_stock_repository.
    DATA mo_uom_converter TYPE REF TO zif_material_uom_converter.
ENDCLASS.

CLASS zcl_so_stock_service IMPLEMENTATION.

  METHOD constructor.
    mo_repository = io_repository.
    mo_uom_converter = io_uom_converter.
    IF mo_uom_converter IS NOT BOUND.
      DATA(lo_uom_repository) = io_uom_repository.
      IF lo_uom_repository IS NOT BOUND.
        lo_uom_repository = NEW zcl_material_uom_repository( ).
      ENDIF.
      mo_uom_converter = NEW zcl_material_uom_converter(
        io_repository = lo_uom_repository ).
    ENDIF.
  ENDMETHOD.

  METHOD read_stock.
    DATA(lt_results) = me->read_stock_bulk(
      VALUE ty_requests(
        ( request_id               = 'SINGLE'
          sales_document           = iv_sales_document
          item_number              = iv_item_number
          material                 = iv_material
          plant                    = iv_plant
          reservation_through_date = iv_reservation_through_date ) ) ).
    READ TABLE lt_results INTO rs_result INDEX 1.
  ENDMETHOD.

  METHOD read_sales_order_item.
    DATA(lt_results) = me->read_sales_order_items_bulk(
      VALUE ty_item_requests(
        ( request_id               = 'SINGLE'
          sales_document           = iv_sales_document
          item_number              = iv_item_number
          reservation_through_date = iv_reservation_through_date ) ) ).
    READ TABLE lt_results INTO rs_result INDEX 1.
  ENDMETHOD.

  METHOD read_stock_in_unit.
    DATA(lt_results) = me->read_stock_bulk_in_unit(
      VALUE ty_stock_unit_requests(
        ( request_id               = 'SINGLE'
          sales_document           = iv_sales_document
          item_number              = iv_item_number
          requested_unit           = iv_requested_unit
          reservation_through_date = iv_reservation_through_date ) ) ).
    READ TABLE lt_results INTO rs_result INDEX 1.
  ENDMETHOD.

  METHOD read_stock_bulk_in_unit.
    TYPES ty_request_id TYPE c LENGTH 30.
    TYPES:
      BEGIN OF ty_item_key,
        sales_document           TYPE vbap-vbeln,
        item_number              TYPE vbap-posnr,
        reservation_through_date TYPE d,
      END OF ty_item_key.
    TYPES ty_seen_ids TYPE HASHED TABLE OF ty_request_id
      WITH UNIQUE KEY table_line.
    TYPES ty_seen_items TYPE HASHED TABLE OF ty_item_key
      WITH UNIQUE KEY sales_document item_number
        reservation_through_date.
    DATA lt_seen_ids TYPE ty_seen_ids.
    DATA lt_seen_items TYPE ty_seen_items.
    DATA lt_item_requests TYPE ty_item_requests.
    DATA lt_stock_results TYPE ty_results.

    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-request_id IS INITIAL
          OR ls_request-sales_document IS INITIAL
          OR ls_request-item_number IS INITIAL
          OR ls_request-requested_unit IS INITIAL
          OR ( ls_request-reservation_through_date IS NOT INITIAL
            AND zcl_date_validation=>is_valid_gregorian_date(
              ls_request-reservation_through_date ) <> abap_true ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request-request_id INTO TABLE lt_seen_ids.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      READ TABLE lt_seen_items TRANSPORTING NO FIELDS
        WITH TABLE KEY sales_document = ls_request-sales_document
                       item_number = ls_request-item_number
                       reservation_through_date =
                         ls_request-reservation_through_date.
      IF sy-subrc = 0.
        CONTINUE.
      ENDIF.

      INSERT VALUE #(
        sales_document           = ls_request-sales_document
        item_number              = ls_request-item_number
        reservation_through_date =
          ls_request-reservation_through_date ) INTO TABLE lt_seen_items.
      APPEND VALUE #(
        request_id               = ls_request-request_id
        sales_document           = ls_request-sales_document
        item_number              = ls_request-item_number
        reservation_through_date =
          ls_request-reservation_through_date ) TO lt_item_requests.
    ENDLOOP.

    lt_stock_results = me->read_sales_order_items_bulk( lt_item_requests ).
    IF lines( lt_stock_results ) <> lines( lt_item_requests ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT it_requests INTO ls_request.
      READ TABLE lt_stock_results INTO DATA(ls_stock_result)
        WITH KEY sales_document = ls_request-sales_document
                 item_number = ls_request-item_number
                 reservation_through_date =
                   ls_request-reservation_through_date.
      IF sy-subrc <> 0
          OR ls_stock_result-sales_document <> ls_request-sales_document
          OR ls_stock_result-item_number <> ls_request-item_number
          OR ls_stock_result-reservation_through_date
            <> ls_request-reservation_through_date.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      DATA(ls_unrestricted) = mo_uom_converter->convert_from_base(
        iv_material      = ls_stock_result-material
        iv_base_quantity = ls_stock_result-unrestricted_qty
        iv_target_unit   = ls_request-requested_unit ).
      DATA(ls_reserved) = mo_uom_converter->convert_from_base(
        iv_material      = ls_stock_result-material
        iv_base_quantity = ls_stock_result-reserved_quantity
        iv_target_unit   = ls_request-requested_unit ).
      DATA(ls_available) = mo_uom_converter->convert_from_base(
        iv_material      = ls_stock_result-material
        iv_base_quantity = ls_stock_result-available_quantity
        iv_target_unit   = ls_request-requested_unit ).
      IF ls_unrestricted-is_successful <> abap_true
          OR ls_reserved-is_successful <> abap_true
          OR ls_available-is_successful <> abap_true
          OR ls_unrestricted-base_unit <> ls_stock_result-base_unit
          OR ls_reserved-base_unit <> ls_stock_result-base_unit
          OR ls_available-base_unit <> ls_stock_result-base_unit.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      DATA(ls_request_snapshot) = ls_stock_result.
      ls_request_snapshot-request_id = ls_request-request_id.
      APPEND VALUE #(
        request_id                 = ls_request-request_id
        sales_document             = ls_stock_result-sales_document
        item_number                = ls_stock_result-item_number
        material                   = ls_stock_result-material
        plant                      = ls_stock_result-plant
        requested_unit             = ls_request-requested_unit
        base_unit                  = ls_stock_result-base_unit
        unrestricted_base_quantity = ls_stock_result-unrestricted_qty
        unrestricted_quantity      =
          ls_unrestricted-alternative_quantity
        reserved_base_quantity     = ls_stock_result-reserved_quantity
        reserved_quantity          = ls_reserved-alternative_quantity
        available_base_quantity    = ls_stock_result-available_quantity
        available_quantity         = ls_available-alternative_quantity
        stock_snapshot             = ls_request_snapshot ) TO rt_results.
    ENDLOOP.
  ENDMETHOD.

  METHOD read_sales_order_items_bulk.
    TYPES ty_request_id TYPE c LENGTH 30.
    TYPES:
      BEGIN OF ty_item_key,
        sales_document TYPE vbap-vbeln,
        item_number    TYPE vbap-posnr,
      END OF ty_item_key.
    TYPES ty_item_keys TYPE HASHED TABLE OF ty_item_key
      WITH UNIQUE KEY sales_document item_number.
    TYPES ty_seen_ids TYPE HASHED TABLE OF ty_request_id
      WITH UNIQUE KEY table_line.
    TYPES ty_mapped_items TYPE HASHED TABLE OF
      zif_so_stock_repository=>ty_order_item
      WITH UNIQUE KEY sales_document item_number.
    DATA lt_item_keys TYPE ty_item_keys.
    DATA lt_seen_ids TYPE ty_seen_ids.
    DATA lt_mapped_items TYPE ty_mapped_items.
    DATA lt_order_items TYPE zif_so_stock_repository=>ty_order_items.
    DATA lt_stock_requests TYPE ty_requests.

    IF it_item_requests IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_item_requests INTO DATA(ls_item_request).
      IF ls_item_request-request_id IS INITIAL
          OR ls_item_request-sales_document IS INITIAL
          OR ls_item_request-item_number IS INITIAL
          OR ( ls_item_request-reservation_through_date IS NOT INITIAL
            AND zcl_date_validation=>is_valid_gregorian_date(
              ls_item_request-reservation_through_date ) <> abap_true ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_item_request-request_id INTO TABLE lt_seen_ids.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT VALUE #(
        sales_document = ls_item_request-sales_document
        item_number    = ls_item_request-item_number ) INTO TABLE lt_item_keys.
    ENDLOOP.

    lt_order_items = mo_repository->read_order_items_bulk(
      it_item_requests = it_item_requests ).

    LOOP AT lt_order_items INTO DATA(ls_order_item).
      IF ls_order_item-sales_document IS INITIAL
          OR ls_order_item-item_number IS INITIAL
          OR ls_order_item-material IS INITIAL
          OR ls_order_item-plant IS INITIAL
          OR NOT line_exists( lt_item_keys[
            sales_document = ls_order_item-sales_document
            item_number    = ls_order_item-item_number ] ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_order_item INTO TABLE lt_mapped_items.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT it_item_requests INTO ls_item_request.
      IF NOT line_exists( lt_mapped_items[
          sales_document = ls_item_request-sales_document
          item_number    = ls_item_request-item_number ] ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      DATA(ls_mapped_item) = lt_mapped_items[
        sales_document = ls_item_request-sales_document
        item_number    = ls_item_request-item_number ].
      APPEND VALUE #(
        request_id               = ls_item_request-request_id
        sales_document           = ls_mapped_item-sales_document
        item_number              = ls_mapped_item-item_number
        material                 = ls_mapped_item-material
        plant                    = ls_mapped_item-plant
        reservation_through_date =
          ls_item_request-reservation_through_date ) TO lt_stock_requests.
    ENDLOOP.

    rt_results = me->read_stock_bulk( lt_stock_requests ).
  ENDMETHOD.

  METHOD read_stock_bulk.
    TYPES ty_request_id TYPE c LENGTH 30.
    TYPES:
      BEGIN OF ty_request_key,
        sales_document TYPE vbap-vbeln,
        item_number    TYPE vbap-posnr,
        material       TYPE mara-matnr,
        plant          TYPE marc-werks,
      END OF ty_request_key.
    TYPES ty_request_keys TYPE HASHED TABLE OF ty_request_key
      WITH UNIQUE KEY sales_document item_number material plant.
    TYPES ty_seen_ids TYPE HASHED TABLE OF ty_request_id
      WITH UNIQUE KEY table_line.
    TYPES ty_seen_materials TYPE HASHED TABLE OF mara-matnr
      WITH UNIQUE KEY table_line.
    DATA lt_request_keys TYPE ty_request_keys.
    DATA lt_seen_ids TYPE ty_seen_ids.
    DATA lt_seen_materials TYPE ty_seen_materials.
    DATA lt_base_units TYPE zif_so_stock_repository=>ty_material_units.
    DATA lt_stock TYPE zif_so_stock_repository=>ty_stock_rows.
    DATA lt_reservations TYPE zif_so_stock_repository=>ty_reservation_rows.
    DATA lv_unrestricted_total TYPE decfloat34.
    DATA lv_reserved_total TYPE decfloat34.

    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-request_id IS INITIAL
          OR ls_request-sales_document IS INITIAL
          OR ls_request-item_number IS INITIAL
          OR ls_request-material IS INITIAL
          OR ls_request-plant IS INITIAL
          OR ( ls_request-reservation_through_date IS NOT INITIAL
            AND zcl_date_validation=>is_valid_gregorian_date(
              ls_request-reservation_through_date ) <> abap_true ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request-request_id INTO TABLE lt_seen_ids.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT VALUE #(
        sales_document = ls_request-sales_document
        item_number    = ls_request-item_number
        material       = ls_request-material
        plant          = ls_request-plant ) INTO TABLE lt_request_keys.
    ENDLOOP.

    lt_base_units = mo_repository->read_base_units_bulk(
      it_requests = it_requests ).
    lt_stock = mo_repository->read_stock_bulk(
      it_requests = it_requests ).
    lt_reservations = mo_repository->read_reservations_bulk(
      it_requests = it_requests ).

    LOOP AT lt_base_units INTO DATA(ls_base_unit).
      IF ls_base_unit-material IS INITIAL OR ls_base_unit-base_unit IS INITIAL
          OR NOT line_exists( it_requests[ material = ls_base_unit-material ] ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_base_unit-material INTO TABLE lt_seen_materials.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_request_keys INTO DATA(ls_request_key).
      IF NOT line_exists( lt_base_units[
          material = ls_request_key-material ] ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_stock INTO DATA(ls_stock).
      IF NOT line_exists( lt_request_keys[
          sales_document = ls_stock-sales_document
          item_number    = ls_stock-item_number
          material       = ls_stock-material
          plant          = ls_stock-plant ] )
          OR ls_stock-base_unit IS INITIAL
          OR ls_stock-base_unit <> lt_base_units[
            material = ls_stock-material ]-base_unit
          OR ( ls_stock-expiration_date IS NOT INITIAL
            AND zcl_date_validation=>is_valid_gregorian_date(
              ls_stock-expiration_date ) <> abap_true ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_reservations INTO DATA(ls_reservation).
      IF NOT line_exists( lt_request_keys[
          sales_document = ls_reservation-sales_document
          item_number    = ls_reservation-item_number
          material       = ls_reservation-material
          plant          = ls_reservation-plant ] )
          OR ls_reservation-base_unit IS INITIAL
          OR ls_reservation-base_unit <> lt_base_units[
            material = ls_reservation-material ]-base_unit
          OR ls_reservation-required_quantity < 0
          OR ls_reservation-withdrawn_quantity < 0
          OR ls_reservation-withdrawn_quantity
            > ls_reservation-required_quantity
          OR ( ls_reservation-required_date IS NOT INITIAL
            AND zcl_date_validation=>is_valid_gregorian_date(
              ls_reservation-required_date ) <> abap_true ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    DATA(lo_quantity_calculator) = NEW zcl_stock_avail_qty_calc( ).
    LOOP AT it_requests INTO ls_request.
      DATA(ls_result) = VALUE ty_result(
        request_id               = ls_request-request_id
        sales_document           = ls_request-sales_document
        item_number              = ls_request-item_number
        material                 = ls_request-material
        plant                    = ls_request-plant
        reservation_through_date = ls_request-reservation_through_date
        base_unit                = lt_base_units[
          material = ls_request-material ]-base_unit ).
      CLEAR: lv_unrestricted_total, lv_reserved_total.

      LOOP AT lt_stock INTO ls_stock
          WHERE sales_document = ls_request-sales_document
            AND item_number = ls_request-item_number
            AND material = ls_request-material
            AND plant = ls_request-plant.
        lv_unrestricted_total += CONV decfloat34( ls_stock-quantity ).
        APPEND ls_stock TO ls_result-stock_balances.
      ENDLOOP.

      LOOP AT lt_reservations INTO ls_reservation
          WHERE sales_document = ls_request-sales_document
            AND item_number = ls_request-item_number
            AND material = ls_request-material
            AND plant = ls_request-plant.
        IF ls_reservation-required_quantity
            > ls_reservation-withdrawn_quantity.
          DATA(ls_open_reservation) = ls_reservation.
          ls_open_reservation-open_quantity =
            zcl_stock_avail_qty_calc=>calculate_open_res_qty(
              iv_required_quantity  = ls_reservation-required_quantity
              iv_withdrawn_quantity = ls_reservation-withdrawn_quantity ).
          IF ls_request-reservation_through_date IS INITIAL
              OR ls_reservation-required_date IS INITIAL
              OR ls_reservation-required_date
                <= ls_request-reservation_through_date.
            lv_reserved_total += CONV decfloat34(
              ls_open_reservation-open_quantity ).
          ENDIF.
          APPEND ls_open_reservation TO ls_result-open_reservations.
        ENDIF.
      ENDLOOP.

      TRY.
          ls_result-unrestricted_qty = CONV mska-kalab(
            lv_unrestricted_total ).
          ls_result-reserved_quantity = CONV resb-bdmng(
            lv_reserved_total ).
        CATCH cx_sy_conversion_overflow.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDTRY.

      ls_result-available_quantity = lo_quantity_calculator->calculate(
        iv_unrestricted_quantity = ls_result-unrestricted_qty
        iv_reserved_quantity     = ls_result-reserved_quantity ).
      APPEND ls_result TO rt_results.
    ENDLOOP.
  ENDMETHOD.

  METHOD preview_issue_demands.
    TYPES ty_request_id TYPE c LENGTH 30.
    TYPES:
      BEGIN OF ty_item_key,
        sales_document           TYPE vbap-vbeln,
        item_number              TYPE vbap-posnr,
        reservation_through_date TYPE d,
      END OF ty_item_key.
    TYPES ty_seen_ids TYPE HASHED TABLE OF ty_request_id
      WITH UNIQUE KEY table_line.
    TYPES ty_seen_items TYPE HASHED TABLE OF ty_item_key
      WITH UNIQUE KEY sales_document item_number
        reservation_through_date.
    TYPES:
      BEGIN OF ty_item_remaining,
        sales_document           TYPE vbap-vbeln,
        item_number              TYPE vbap-posnr,
        reservation_through_date TYPE d,
        remaining_quantity       TYPE mska-kalab,
      END OF ty_item_remaining.
    TYPES ty_item_remainings TYPE HASHED TABLE OF ty_item_remaining
      WITH UNIQUE KEY sales_document item_number
        reservation_through_date.
    DATA lt_seen_ids TYPE ty_seen_ids.
    DATA lt_seen_items TYPE ty_seen_items.
    DATA lt_item_remaining TYPE ty_item_remainings.
    DATA lt_item_requests TYPE ty_item_requests.
    DATA lt_stock_results TYPE ty_results.
    DATA lt_ordered_requests TYPE ty_issue_requests.
    DATA lt_ordered_results TYPE ty_issue_results.

    IF ( iv_require_full_quantity <> abap_true
          AND iv_require_full_quantity <> abap_false )
        OR ( iv_prioritize_by_date <> abap_true
          AND iv_prioritize_by_date <> abap_false )
        OR ( iv_prioritize_by_priority <> abap_true
          AND iv_prioritize_by_priority <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

    lt_ordered_requests = it_requests.
    IF iv_prioritize_by_date = abap_true.
      LOOP AT lt_ordered_requests INTO DATA(ls_dated_request).
        IF ls_dated_request-required_date IS INITIAL
            OR zcl_date_validation=>is_valid_gregorian_date(
              ls_dated_request-required_date ) <> abap_true.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
      ENDLOOP.
      SORT lt_ordered_requests STABLE BY required_date ASCENDING
        priority DESCENDING.
    ELSEIF iv_prioritize_by_priority = abap_true.
      SORT lt_ordered_requests STABLE BY priority DESCENDING.
    ENDIF.

    LOOP AT lt_ordered_requests INTO DATA(ls_request).
      IF ls_request-request_id IS INITIAL
          OR ls_request-sales_document IS INITIAL
          OR ls_request-item_number IS INITIAL
          OR ls_request-requested_quantity <= 0
          OR ( ls_request-required_date IS NOT INITIAL
            AND zcl_date_validation=>is_valid_gregorian_date(
              ls_request-required_date ) <> abap_true )
          OR ( ls_request-reservation_through_date IS NOT INITIAL
            AND zcl_date_validation=>is_valid_gregorian_date(
              ls_request-reservation_through_date ) <> abap_true ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request-request_id INTO TABLE lt_seen_ids.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      READ TABLE lt_seen_items TRANSPORTING NO FIELDS
        WITH TABLE KEY sales_document = ls_request-sales_document
                       item_number = ls_request-item_number
                       reservation_through_date =
                         ls_request-reservation_through_date.
      IF sy-subrc = 0.
        CONTINUE.
      ENDIF.
      INSERT VALUE #(
        sales_document           = ls_request-sales_document
        item_number              = ls_request-item_number
        reservation_through_date =
          ls_request-reservation_through_date ) INTO TABLE lt_seen_items.
      APPEND VALUE #(
        request_id               = ls_request-request_id
        sales_document           = ls_request-sales_document
        item_number              = ls_request-item_number
        reservation_through_date =
          ls_request-reservation_through_date ) TO lt_item_requests.
    ENDLOOP.

    lt_stock_results = me->read_sales_order_items_bulk( lt_item_requests ).
    IF lines( lt_stock_results ) <> lines( lt_item_requests ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT lt_stock_results INTO DATA(ls_snapshot).
      INSERT VALUE #(
        sales_document           = ls_snapshot-sales_document
        item_number              = ls_snapshot-item_number
        reservation_through_date =
          ls_snapshot-reservation_through_date
        remaining_quantity       = ls_snapshot-available_quantity )
        INTO TABLE lt_item_remaining.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_ordered_requests INTO ls_request.
      READ TABLE lt_stock_results INTO DATA(ls_stock_result)
        WITH KEY sales_document = ls_request-sales_document
                 item_number = ls_request-item_number
                 reservation_through_date =
                   ls_request-reservation_through_date.
      IF sy-subrc <> 0
          OR ls_stock_result-sales_document <> ls_request-sales_document
          OR ls_stock_result-item_number <> ls_request-item_number
          OR ls_stock_result-reservation_through_date
            <> ls_request-reservation_through_date.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      READ TABLE lt_item_remaining ASSIGNING FIELD-SYMBOL(<ls_remaining>)
        WITH TABLE KEY sales_document = ls_request-sales_document
                       item_number = ls_request-item_number
                       reservation_through_date =
                         ls_request-reservation_through_date.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      DATA(lv_available_quantity) = <ls_remaining>-remaining_quantity.
      DATA(lv_covered_quantity) = lv_available_quantity.
      IF lv_covered_quantity > ls_request-requested_quantity.
        lv_covered_quantity = ls_request-requested_quantity.
      ENDIF.
      IF iv_require_full_quantity = abap_true
          AND lv_covered_quantity < ls_request-requested_quantity.
        CLEAR lv_covered_quantity.
      ENDIF.
      <ls_remaining>-remaining_quantity -= lv_covered_quantity.
      DATA(lv_shortfall_quantity) = ls_request-requested_quantity
        - lv_covered_quantity.
      DATA(ls_request_snapshot) = ls_stock_result.
      ls_request_snapshot-request_id = ls_request-request_id.
      APPEND VALUE #(
        request_id         = ls_request-request_id
        sales_document     = ls_stock_result-sales_document
        item_number        = ls_stock_result-item_number
        required_date      = ls_request-required_date
        priority           = ls_request-priority
        material           = ls_stock_result-material
        plant              = ls_stock_result-plant
        base_unit          = ls_stock_result-base_unit
        requested_quantity = ls_request-requested_quantity
        available_quantity = lv_available_quantity
        covered_quantity   = lv_covered_quantity
        shortfall_quantity = lv_shortfall_quantity
        is_sufficient      = COND abap_bool(
          WHEN lv_shortfall_quantity = 0 THEN abap_true
          ELSE abap_false )
        stock_snapshot     = ls_request_snapshot ) TO rt_results.
    ENDLOOP.

    IF iv_prioritize_by_date = abap_true
        OR iv_prioritize_by_priority = abap_true.
      lt_ordered_results = rt_results.
      CLEAR rt_results.
      LOOP AT it_requests INTO ls_request.
        READ TABLE lt_ordered_results INTO DATA(ls_ordered_result)
          WITH KEY request_id = ls_request-request_id.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        APPEND ls_ordered_result TO rt_results.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD preview_issue_demands_in_unit.
    TYPES ty_request_id TYPE c LENGTH 30.
    TYPES:
      BEGIN OF ty_item_key,
        sales_document           TYPE vbap-vbeln,
        item_number              TYPE vbap-posnr,
        reservation_through_date TYPE d,
      END OF ty_item_key.
    TYPES ty_seen_ids TYPE HASHED TABLE OF ty_request_id
      WITH UNIQUE KEY table_line.
    TYPES ty_seen_items TYPE HASHED TABLE OF ty_item_key
      WITH UNIQUE KEY sales_document item_number
        reservation_through_date.
    TYPES:
      BEGIN OF ty_item_remaining,
        sales_document           TYPE vbap-vbeln,
        item_number              TYPE vbap-posnr,
        reservation_through_date TYPE d,
        remaining_quantity       TYPE mska-kalab,
      END OF ty_item_remaining.
    TYPES ty_item_remainings TYPE HASHED TABLE OF ty_item_remaining
      WITH UNIQUE KEY sales_document item_number
        reservation_through_date.
    DATA lt_seen_ids TYPE ty_seen_ids.
    DATA lt_seen_items TYPE ty_seen_items.
    DATA lt_item_remaining TYPE ty_item_remainings.
    DATA lt_item_requests TYPE ty_item_requests.
    DATA lt_stock_results TYPE ty_results.
    DATA lt_ordered_requests TYPE ty_issue_unit_requests.
    DATA lt_ordered_results TYPE ty_issue_unit_results.

    IF ( iv_require_full_quantity <> abap_true
          AND iv_require_full_quantity <> abap_false )
        OR ( iv_prioritize_by_date <> abap_true
          AND iv_prioritize_by_date <> abap_false )
        OR ( iv_prioritize_by_priority <> abap_true
          AND iv_prioritize_by_priority <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

    lt_ordered_requests = it_requests.
    IF iv_prioritize_by_date = abap_true.
      LOOP AT lt_ordered_requests INTO DATA(ls_dated_request).
        IF ls_dated_request-required_date IS INITIAL
            OR zcl_date_validation=>is_valid_gregorian_date(
              ls_dated_request-required_date ) <> abap_true.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
      ENDLOOP.
      SORT lt_ordered_requests STABLE BY required_date ASCENDING
        priority DESCENDING.
    ELSEIF iv_prioritize_by_priority = abap_true.
      SORT lt_ordered_requests STABLE BY priority DESCENDING.
    ENDIF.

    LOOP AT lt_ordered_requests INTO DATA(ls_request).
      IF ls_request-request_id IS INITIAL
          OR ls_request-sales_document IS INITIAL
          OR ls_request-item_number IS INITIAL
          OR ls_request-requested_quantity <= 0
          OR ls_request-requested_unit IS INITIAL
          OR ( ls_request-required_date IS NOT INITIAL
            AND zcl_date_validation=>is_valid_gregorian_date(
              ls_request-required_date ) <> abap_true )
          OR ( ls_request-reservation_through_date IS NOT INITIAL
            AND zcl_date_validation=>is_valid_gregorian_date(
              ls_request-reservation_through_date ) <> abap_true ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request-request_id INTO TABLE lt_seen_ids.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      READ TABLE lt_seen_items TRANSPORTING NO FIELDS
        WITH TABLE KEY sales_document = ls_request-sales_document
                       item_number = ls_request-item_number
                       reservation_through_date =
                         ls_request-reservation_through_date.
      IF sy-subrc = 0.
        CONTINUE.
      ENDIF.
      INSERT VALUE #(
        sales_document           = ls_request-sales_document
        item_number              = ls_request-item_number
        reservation_through_date =
          ls_request-reservation_through_date ) INTO TABLE lt_seen_items.
      APPEND VALUE #(
        request_id               = ls_request-request_id
        sales_document           = ls_request-sales_document
        item_number              = ls_request-item_number
        reservation_through_date =
          ls_request-reservation_through_date ) TO lt_item_requests.
    ENDLOOP.

    lt_stock_results = me->read_sales_order_items_bulk( lt_item_requests ).
    IF lines( lt_stock_results ) <> lines( lt_item_requests ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT lt_stock_results INTO DATA(ls_snapshot).
      INSERT VALUE #(
        sales_document           = ls_snapshot-sales_document
        item_number              = ls_snapshot-item_number
        reservation_through_date =
          ls_snapshot-reservation_through_date
        remaining_quantity       = ls_snapshot-available_quantity )
        INTO TABLE lt_item_remaining.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_ordered_requests INTO ls_request.
      READ TABLE lt_stock_results INTO DATA(ls_stock_result)
        WITH KEY sales_document = ls_request-sales_document
                 item_number = ls_request-item_number
                 reservation_through_date =
                   ls_request-reservation_through_date.
      IF sy-subrc <> 0
          OR ls_stock_result-sales_document <> ls_request-sales_document
          OR ls_stock_result-item_number <> ls_request-item_number
          OR ls_stock_result-reservation_through_date
            <> ls_request-reservation_through_date.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      DATA(ls_requested) = mo_uom_converter->convert_material_unit(
        iv_material    = ls_stock_result-material
        iv_quantity    = ls_request-requested_quantity
        iv_source_unit = ls_request-requested_unit ).
      IF ls_requested-is_successful <> abap_true
          OR ls_requested-base_quantity <= 0
          OR ls_requested-base_unit <> ls_stock_result-base_unit.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      READ TABLE lt_item_remaining ASSIGNING FIELD-SYMBOL(<ls_remaining>)
        WITH TABLE KEY sales_document = ls_request-sales_document
                       item_number = ls_request-item_number
                       reservation_through_date =
                         ls_request-reservation_through_date.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      DATA(lv_available_base_quantity) =
        <ls_remaining>-remaining_quantity.
      DATA lv_covered_base_quantity TYPE mard-labst.
      lv_covered_base_quantity = lv_available_base_quantity.
      IF lv_covered_base_quantity > ls_requested-base_quantity.
        lv_covered_base_quantity = ls_requested-base_quantity.
      ENDIF.
      IF iv_require_full_quantity = abap_true
          AND lv_covered_base_quantity < ls_requested-base_quantity.
        CLEAR lv_covered_base_quantity.
      ENDIF.
      <ls_remaining>-remaining_quantity -= lv_covered_base_quantity.
      DATA lv_shortfall_base_quantity TYPE mard-labst.
      lv_shortfall_base_quantity = CONV mard-labst(
        ls_requested-base_quantity - lv_covered_base_quantity ).
      DATA(ls_available_unit) = mo_uom_converter->convert_from_base(
        iv_material      = ls_stock_result-material
        iv_base_quantity = lv_available_base_quantity
        iv_target_unit   = ls_request-requested_unit ).
      DATA(ls_covered_unit) = mo_uom_converter->convert_from_base(
        iv_material      = ls_stock_result-material
        iv_base_quantity = lv_covered_base_quantity
        iv_target_unit   = ls_request-requested_unit ).
      DATA(ls_shortfall_unit) = mo_uom_converter->convert_from_base(
        iv_material      = ls_stock_result-material
        iv_base_quantity = lv_shortfall_base_quantity
        iv_target_unit   = ls_request-requested_unit ).
      IF ls_available_unit-is_successful <> abap_true
          OR ls_covered_unit-is_successful <> abap_true
          OR ls_shortfall_unit-is_successful <> abap_true
          OR ls_available_unit-base_unit <> ls_stock_result-base_unit
          OR ls_covered_unit-base_unit <> ls_stock_result-base_unit
          OR ls_shortfall_unit-base_unit <> ls_stock_result-base_unit.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      DATA(ls_request_snapshot) = ls_stock_result.
      ls_request_snapshot-request_id = ls_request-request_id.
      APPEND VALUE #(
        request_id              = ls_request-request_id
        sales_document          = ls_stock_result-sales_document
        item_number             = ls_stock_result-item_number
        required_date           = ls_request-required_date
        priority                = ls_request-priority
        material                = ls_stock_result-material
        plant                   = ls_stock_result-plant
        requested_quantity      = ls_request-requested_quantity
        requested_unit          = ls_request-requested_unit
        requested_base_quantity = ls_requested-base_quantity
        available_quantity      = ls_available_unit-alternative_quantity
        available_base_quantity = lv_available_base_quantity
        covered_quantity        = ls_covered_unit-alternative_quantity
        covered_base_quantity   = lv_covered_base_quantity
        shortfall_quantity      = ls_shortfall_unit-alternative_quantity
        shortfall_base_quantity = lv_shortfall_base_quantity
        base_unit               = ls_stock_result-base_unit
        is_sufficient           = COND abap_bool(
          WHEN lv_shortfall_base_quantity = 0 THEN abap_true
          ELSE abap_false )
        stock_snapshot          = ls_request_snapshot ) TO rt_results.
    ENDLOOP.

    IF iv_prioritize_by_date = abap_true
        OR iv_prioritize_by_priority = abap_true.
      lt_ordered_results = rt_results.
      CLEAR rt_results.
      LOOP AT it_requests INTO ls_request.
        READ TABLE lt_ordered_results INTO DATA(ls_ordered_result)
          WITH KEY request_id = ls_request-request_id.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        APPEND ls_ordered_result TO rt_results.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD preview_issue_demands_by_fefo.
    DATA lt_requests TYPE ty_fefo_issue_internal_requests.

    LOOP AT it_requests INTO DATA(ls_request).
      APPEND VALUE #(
        request_id                = ls_request-request_id
        sales_document            = ls_request-sales_document
        item_number               = ls_request-item_number
        selected_batch            = ls_request-batch
        selected_storage_location = ls_request-storage_location
        required_date             = ls_request-required_date
        priority                  = ls_request-priority
        minimum_shelf_life_days   = ls_request-minimum_shelf_life_days
        require_known_expiry      = ls_request-require_known_expiry
        allow_undated_batches     = ls_request-allow_undated_batches
        require_full_quantity     = ls_request-require_full_quantity
        allow_location_fallback   = ls_request-allow_location_fallback
        requested_quantity        = ls_request-requested_quantity
        is_unit_quantity          = abap_false
        reservation_through_date  =
          ls_request-reservation_through_date ) TO lt_requests.
    ENDLOOP.

    rs_result = preview_issue_fefo_int(
      it_requests                    = lt_requests
      iv_as_of_date                  = iv_as_of_date
      iv_min_days                    = iv_min_days
      iv_include_undated_batches     = iv_include_undated_batches
      iv_require_full_quantity       = iv_require_full_quantity
      iv_prioritize_by_date          = iv_prioritize_by_date
      iv_prioritize_by_priority      = iv_prioritize_by_priority
      it_storage_location_priority   = it_storage_location_priority
      it_request_location_priorities = it_request_location_priorities
      it_location_allowlist          = it_location_allowlist
      it_request_locations           = it_request_locations ).
  ENDMETHOD.

  METHOD preview_issue_fefo_uom.
    DATA lt_requests TYPE ty_fefo_issue_internal_requests.

    LOOP AT it_requests INTO DATA(ls_request).
      APPEND VALUE #(
        request_id                = ls_request-request_id
        sales_document            = ls_request-sales_document
        item_number               = ls_request-item_number
        selected_batch            = ls_request-batch
        selected_storage_location = ls_request-storage_location
        required_date             = ls_request-required_date
        priority                  = ls_request-priority
        minimum_shelf_life_days   = ls_request-minimum_shelf_life_days
        require_known_expiry      = ls_request-require_known_expiry
        allow_undated_batches     = ls_request-allow_undated_batches
        require_full_quantity     = ls_request-require_full_quantity
        allow_location_fallback   = ls_request-allow_location_fallback
        requested_quantity        = ls_request-requested_quantity
        requested_unit            = ls_request-requested_unit
        is_unit_quantity          = abap_true
        reservation_through_date  =
          ls_request-reservation_through_date ) TO lt_requests.
    ENDLOOP.

    rs_result = preview_issue_fefo_int(
      it_requests                    = lt_requests
      iv_as_of_date                  = iv_as_of_date
      iv_min_days                    = iv_min_days
      iv_include_undated_batches     = iv_include_undated_batches
      iv_require_full_quantity       = iv_require_full_quantity
      iv_prioritize_by_date          = iv_prioritize_by_date
      iv_prioritize_by_priority      = iv_prioritize_by_priority
      it_storage_location_priority   = it_storage_location_priority
      it_request_location_priorities = it_request_location_priorities
      it_location_allowlist          = it_location_allowlist
      it_request_locations           = it_request_locations ).
  ENDMETHOD.

  METHOD preview_issue_fefo_int.
    TYPES ty_request_id TYPE c LENGTH 30.
    TYPES:
      BEGIN OF ty_item_key,
        sales_document           TYPE vbap-vbeln,
        item_number              TYPE vbap-posnr,
        reservation_through_date TYPE d,
      END OF ty_item_key.
    TYPES ty_item_keys TYPE HASHED TABLE OF ty_item_key
      WITH UNIQUE KEY sales_document item_number
        reservation_through_date.
    TYPES:
      BEGIN OF ty_balance_key,
        sales_document           TYPE vbap-vbeln,
        item_number              TYPE vbap-posnr,
        reservation_through_date TYPE d,
        storage_location         TYPE mard-lgort,
        batch                    TYPE mchb-charg,
      END OF ty_balance_key.
    TYPES ty_balance_keys TYPE HASHED TABLE OF ty_balance_key
      WITH UNIQUE KEY sales_document item_number
        reservation_through_date storage_location batch.
    TYPES:
      BEGIN OF ty_balance,
        sales_document           TYPE vbap-vbeln,
        item_number              TYPE vbap-posnr,
        reservation_through_date TYPE d,
        material                 TYPE mara-matnr,
        plant                    TYPE marc-werks,
        storage_location         TYPE mard-lgort,
        batch                    TYPE mchb-charg,
        expiration_date          TYPE mcha-vfdat,
        sort_expiration_date     TYPE d,
        base_unit                TYPE mara-meins,
        remaining_quantity       TYPE mska-kalab,
      END OF ty_balance.
    TYPES ty_balances TYPE STANDARD TABLE OF ty_balance WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_allocation_order,
        balance_index           TYPE i,
        sort_expiration_date    TYPE d,
        batch                   TYPE mchb-charg,
        location_priority_group TYPE i,
        location_priority       TYPE i,
        storage_location        TYPE mard-lgort,
      END OF ty_allocation_order.
    TYPES ty_allocation_orders TYPE STANDARD TABLE OF ty_allocation_order
      WITH EMPTY KEY.
    TYPES ty_request_ids TYPE HASHED TABLE OF ty_request_id
      WITH UNIQUE KEY table_line.
    DATA lt_request_locations TYPE SORTED TABLE OF
      ty_fefo_request_location WITH UNIQUE KEY request_id storage_location.
    DATA lt_request_location_priorities TYPE SORTED TABLE OF
      ty_fefo_request_location_priority
      WITH UNIQUE KEY request_id storage_location.
    DATA lt_request_priority_ids TYPE ty_request_ids.
    DATA lt_scoped_request_ids TYPE ty_request_ids.
    DATA lt_item_keys TYPE ty_item_keys.
    DATA lt_balance_keys TYPE ty_balance_keys.
    DATA lt_balances TYPE ty_balances.
    DATA lt_allocation_orders TYPE ty_allocation_orders.
    DATA lt_allowed_storage_locations TYPE SORTED TABLE OF mard-lgort
      WITH UNIQUE KEY table_line.
    DATA lt_seen_priority_locations TYPE HASHED TABLE OF mard-lgort
      WITH UNIQUE KEY table_line.
    DATA lt_request_ids TYPE ty_request_ids.
    DATA lt_item_requests TYPE ty_item_requests.
    DATA lt_stock_results TYPE ty_results.
    DATA lt_ordered_requests TYPE ty_fefo_issue_internal_requests.
    DATA lt_ordered_allocations TYPE ty_fefo_issue_summaries.
    DATA lt_ordered_batch_allocations TYPE ty_fefo_issue_batch_allocations.
    DATA lo_batch_eligibility TYPE REF TO zcl_stock_batch_eligibility.
    DATA lv_reservation_remaining TYPE resb-bdmng.
    DATA lv_eligible_quantity TYPE mska-kalab.
    DATA lv_excess_quantity TYPE mska-kalab.
    DATA lv_requested_base_quantity TYPE mska-kalab.
    DATA lv_available_base_quantity TYPE mska-kalab.
    DATA lv_covered_base_quantity TYPE mska-kalab.
    DATA lv_shortfall_base_quantity TYPE mska-kalab.
    DATA lv_remaining_quantity TYPE mska-kalab.
    DATA lv_take_quantity TYPE mska-kalab.
    DATA lv_source_unit TYPE mara-meins.
    DATA lv_reservation_pass TYPE i.
    DATA lv_request_as_of_date TYPE d.
    DATA lv_request_min_days TYPE i.
    DATA lv_request_include_undated TYPE abap_bool.
    DATA lv_location_priority_group TYPE i.
    DATA lv_location_priority TYPE i.
    DATA lv_balance_index TYPE i.
    FIELD-SYMBOLS <ls_balance> TYPE ty_balance.

    IF iv_as_of_date IS INITIAL
        OR zcl_date_validation=>is_valid_gregorian_date(
          iv_as_of_date ) <> abap_true
        OR iv_min_days < 0
        OR ( iv_include_undated_batches <> abap_true
          AND iv_include_undated_batches <> abap_false )
        OR ( iv_require_full_quantity <> abap_true
          AND iv_require_full_quantity <> abap_false )
        OR ( iv_prioritize_by_date <> abap_true
          AND iv_prioritize_by_date <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    IF iv_prioritize_by_priority <> abap_true
        AND iv_prioritize_by_priority <> abap_false.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT it_location_allowlist
        INTO DATA(lv_allowed_storage_location).
      IF lv_allowed_storage_location IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT lv_allowed_storage_location
        INTO TABLE lt_allowed_storage_locations.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT it_storage_location_priority
        INTO DATA(lv_priority_storage_location).
      IF lv_priority_storage_location IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT lv_priority_storage_location
        INTO TABLE lt_seen_priority_locations.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    lt_ordered_requests = it_requests.
    IF iv_prioritize_by_date = abap_true.
      LOOP AT lt_ordered_requests INTO DATA(ls_dated_request).
        IF ls_dated_request-required_date IS INITIAL
            OR zcl_date_validation=>is_valid_gregorian_date(
              ls_dated_request-required_date ) <> abap_true.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
      ENDLOOP.
      SORT lt_ordered_requests STABLE BY required_date ASCENDING
        priority DESCENDING.
    ELSEIF iv_prioritize_by_priority = abap_true.
      SORT lt_ordered_requests STABLE BY priority DESCENDING.
    ENDIF.

    LOOP AT lt_ordered_requests INTO DATA(ls_policy_request).
      IF ( ls_policy_request-require_known_expiry <> abap_true
            AND ls_policy_request-require_known_expiry <> abap_false )
          OR ( ls_policy_request-allow_undated_batches <> abap_true
            AND ls_policy_request-allow_undated_batches <> abap_false )
          OR ( ls_policy_request-require_known_expiry = abap_true
            AND ls_policy_request-allow_undated_batches = abap_true ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    lo_batch_eligibility = NEW zcl_stock_batch_eligibility( ).
    LOOP AT lt_ordered_requests INTO DATA(ls_request).
      IF ls_request-request_id IS INITIAL
          OR ls_request-sales_document IS INITIAL
          OR ls_request-item_number IS INITIAL
          OR ls_request-requested_quantity <= 0
          OR ls_request-minimum_shelf_life_days < 0
          OR ( ls_request-require_known_expiry <> abap_true
            AND ls_request-require_known_expiry <> abap_false )
          OR ( ls_request-allow_undated_batches <> abap_true
            AND ls_request-allow_undated_batches <> abap_false )
          OR ( ls_request-require_known_expiry = abap_true
            AND ls_request-allow_undated_batches = abap_true )
          OR ( ls_request-allow_location_fallback <> abap_true
            AND ls_request-allow_location_fallback <> abap_false )
          OR ( ls_request-require_full_quantity <> abap_true
            AND ls_request-require_full_quantity <> abap_false )
          OR ( ls_request-allow_location_fallback = abap_true
            AND ls_request-selected_storage_location IS INITIAL )
          OR ( ls_request-selected_storage_location IS NOT INITIAL
            AND it_location_allowlist IS NOT INITIAL
            AND NOT line_exists( lt_allowed_storage_locations[
              table_line = ls_request-selected_storage_location ] ) )
          OR ( ls_request-required_date IS NOT INITIAL
            AND zcl_date_validation=>is_valid_gregorian_date(
              ls_request-required_date ) <> abap_true )
          OR ( ls_request-is_unit_quantity <> abap_true
            AND ls_request-is_unit_quantity <> abap_false )
          OR ( ls_request-is_unit_quantity = abap_true
            AND ls_request-requested_unit IS INITIAL )
          OR ( ls_request-reservation_through_date IS NOT INITIAL
            AND zcl_date_validation=>is_valid_gregorian_date(
              ls_request-reservation_through_date ) <> abap_true ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request-request_id INTO TABLE lt_request_ids.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      READ TABLE lt_item_keys TRANSPORTING NO FIELDS
        WITH TABLE KEY sales_document = ls_request-sales_document
                       item_number = ls_request-item_number
                       reservation_through_date =
                         ls_request-reservation_through_date.
      IF sy-subrc = 0.
        CONTINUE.
      ENDIF.
      INSERT VALUE #(
        sales_document           = ls_request-sales_document
        item_number              = ls_request-item_number
        reservation_through_date =
          ls_request-reservation_through_date ) INTO TABLE lt_item_keys.
      APPEND VALUE #(
        request_id               = ls_request-request_id
        sales_document           = ls_request-sales_document
        item_number              = ls_request-item_number
        reservation_through_date =
          ls_request-reservation_through_date ) TO lt_item_requests.
    ENDLOOP.

    LOOP AT it_request_location_priorities
        INTO DATA(ls_request_location_priority).
      IF ls_request_location_priority-request_id IS INITIAL
          OR ls_request_location_priority-storage_location IS INITIAL
          OR ls_request_location_priority-priority_rank <= 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      READ TABLE lt_request_ids TRANSPORTING NO FIELDS
        WITH TABLE KEY table_line =
          ls_request_location_priority-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request_location_priority
        INTO TABLE lt_request_location_priorities.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request_location_priority-request_id
        INTO TABLE lt_request_priority_ids.
    ENDLOOP.

    LOOP AT it_request_locations INTO DATA(ls_request_location).
      IF ls_request_location-request_id IS INITIAL
          OR ls_request_location-storage_location IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      READ TABLE lt_request_ids TRANSPORTING NO FIELDS
        WITH TABLE KEY table_line = ls_request_location-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request_location INTO TABLE lt_request_locations.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request_location-request_id INTO TABLE lt_scoped_request_ids.
    ENDLOOP.

    LOOP AT lt_ordered_requests INTO ls_request.
      IF line_exists( lt_scoped_request_ids[
          table_line = ls_request-request_id ] )
          AND ls_request-selected_storage_location IS NOT INITIAL
          AND NOT line_exists( lt_request_locations[
            request_id = ls_request-request_id
            storage_location = ls_request-selected_storage_location ] ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_allowed_storage_locations
        INTO lv_allowed_storage_location.
      APPEND lv_allowed_storage_location TO rs_result-location_allowlist.
    ENDLOOP.
    LOOP AT lt_request_locations INTO ls_request_location.
      APPEND ls_request_location TO rs_result-request_locations.
    ENDLOOP.

    IF lt_item_requests IS INITIAL.
      RETURN.
    ENDIF.

    lt_stock_results = me->read_sales_order_items_bulk( lt_item_requests ).
    IF lines( lt_stock_results ) <> lines( lt_item_requests ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT lt_stock_results INTO DATA(ls_stock_result).
      LOOP AT ls_stock_result-stock_balances
          INTO DATA(ls_stock_balance).
        IF ls_stock_balance-quantity < 0
            OR ( ls_stock_balance-expiration_date IS NOT INITIAL
              AND zcl_date_validation=>is_valid_gregorian_date(
                ls_stock_balance-expiration_date ) <> abap_true )
            OR ls_stock_balance-base_unit <> ls_stock_result-base_unit
            OR ls_stock_balance-sales_document
              <> ls_stock_result-sales_document
            OR ls_stock_balance-item_number <> ls_stock_result-item_number
            OR ls_stock_balance-material <> ls_stock_result-material
            OR ls_stock_balance-plant <> ls_stock_result-plant.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        INSERT VALUE #(
          sales_document           = ls_stock_result-sales_document
          item_number              = ls_stock_result-item_number
          reservation_through_date =
            ls_stock_result-reservation_through_date
          storage_location         = ls_stock_balance-storage_location
          batch                    = ls_stock_balance-batch )
          INTO TABLE lt_balance_keys.
        IF sy-subrc <> 0.
          READ TABLE lt_balances ASSIGNING <ls_balance>
            WITH KEY sales_document = ls_stock_result-sales_document
                     item_number = ls_stock_result-item_number
                     reservation_through_date =
                       ls_stock_result-reservation_through_date
                     storage_location =
                       ls_stock_balance-storage_location
                     batch = ls_stock_balance-batch.
          IF sy-subrc <> 0.
            RAISE EXCEPTION TYPE zcx_invalid_stock_request.
          ENDIF.
          IF <ls_balance>-expiration_date <> ls_stock_balance-expiration_date
              OR <ls_balance>-base_unit <> ls_stock_result-base_unit.
            RAISE EXCEPTION TYPE zcx_invalid_stock_request.
          ENDIF.
          <ls_balance>-remaining_quantity =
            <ls_balance>-remaining_quantity + ls_stock_balance-quantity.
          CONTINUE.
        ENDIF.

        DATA(lv_sort_expiration_date) = ls_stock_balance-expiration_date.
        IF lv_sort_expiration_date IS INITIAL.
          lv_sort_expiration_date = '99991231'.
        ENDIF.
        APPEND VALUE #(
          sales_document           = ls_stock_result-sales_document
          item_number              = ls_stock_result-item_number
          reservation_through_date =
            ls_stock_result-reservation_through_date
          material                 = ls_stock_result-material
          plant                    = ls_stock_result-plant
          storage_location         = ls_stock_balance-storage_location
          batch                    = ls_stock_balance-batch
          expiration_date          = ls_stock_balance-expiration_date
          sort_expiration_date     = lv_sort_expiration_date
          base_unit                = ls_stock_result-base_unit
          remaining_quantity       = ls_stock_balance-quantity )
          TO lt_balances.
      ENDLOOP.
    ENDLOOP.
    SORT lt_balances BY sales_document item_number
      reservation_through_date sort_expiration_date batch
      storage_location.

    LOOP AT lt_stock_results INTO ls_stock_result.
      LOOP AT ls_stock_result-open_reservations
          INTO DATA(ls_reservation).
        IF ls_stock_result-reservation_through_date IS NOT INITIAL
            AND ls_reservation-required_date IS NOT INITIAL
            AND ls_reservation-required_date
              > ls_stock_result-reservation_through_date.
          CONTINUE.
        ENDIF.
        lv_reservation_remaining = ls_reservation-open_quantity.
        DO 2 TIMES.
          lv_reservation_pass = sy-index.
          LOOP AT lt_balances ASSIGNING <ls_balance>
              WHERE sales_document = ls_stock_result-sales_document
                AND item_number = ls_stock_result-item_number
                AND reservation_through_date =
                  ls_stock_result-reservation_through_date.
            IF lv_reservation_remaining <= 0.
              EXIT.
            ENDIF.
            IF ls_reservation-storage_location IS NOT INITIAL
                AND <ls_balance>-storage_location
                  <> ls_reservation-storage_location.
              CONTINUE.
            ENDIF.
            IF ls_reservation-batch IS NOT INITIAL
                AND <ls_balance>-batch <> ls_reservation-batch.
              CONTINUE.
            ENDIF.
            DATA(lv_is_eligible) = lo_batch_eligibility->is_eligible(
              iv_expiration_date         = <ls_balance>-expiration_date
              iv_as_of_date              = iv_as_of_date
              iv_min_days                = iv_min_days
              iv_include_undated_batches =
                iv_include_undated_batches ).
            IF ( lv_reservation_pass = 1
                AND lv_is_eligible <> abap_true )
                OR ( lv_reservation_pass = 2
                  AND lv_is_eligible = abap_true )
                OR <ls_balance>-remaining_quantity <= 0.
              CONTINUE.
            ENDIF.

            lv_take_quantity = lv_reservation_remaining.
            IF lv_take_quantity > <ls_balance>-remaining_quantity.
              lv_take_quantity = <ls_balance>-remaining_quantity.
            ENDIF.
            <ls_balance>-remaining_quantity =
              <ls_balance>-remaining_quantity - lv_take_quantity.
            lv_reservation_remaining =
              lv_reservation_remaining - lv_take_quantity.
          ENDLOOP.
          IF lv_reservation_remaining <= 0.
            EXIT.
          ENDIF.
        ENDDO.
      ENDLOOP.

      CLEAR lv_eligible_quantity.
      LOOP AT lt_balances ASSIGNING <ls_balance>
          WHERE sales_document = ls_stock_result-sales_document
            AND item_number = ls_stock_result-item_number
            AND reservation_through_date =
              ls_stock_result-reservation_through_date.
        IF lo_batch_eligibility->is_eligible(
            iv_expiration_date         = <ls_balance>-expiration_date
            iv_as_of_date              = iv_as_of_date
            iv_min_days                = iv_min_days
            iv_include_undated_batches =
              iv_include_undated_batches ) = abap_true.
          lv_eligible_quantity = lv_eligible_quantity
            + <ls_balance>-remaining_quantity.
        ENDIF.
      ENDLOOP.
      lv_excess_quantity = lv_eligible_quantity
        - ls_stock_result-available_quantity.
      IF lv_excess_quantity > 0.
        LOOP AT lt_balances ASSIGNING <ls_balance>
            WHERE sales_document = ls_stock_result-sales_document
              AND item_number = ls_stock_result-item_number
              AND reservation_through_date =
                ls_stock_result-reservation_through_date.
          IF lv_excess_quantity <= 0.
            EXIT.
          ENDIF.
          IF lo_batch_eligibility->is_eligible(
              iv_expiration_date         = <ls_balance>-expiration_date
              iv_as_of_date              = iv_as_of_date
              iv_min_days                = iv_min_days
              iv_include_undated_batches =
                iv_include_undated_batches ) <> abap_true
              OR <ls_balance>-remaining_quantity <= 0.
            CONTINUE.
          ENDIF.
          lv_take_quantity = lv_excess_quantity.
          IF lv_take_quantity > <ls_balance>-remaining_quantity.
            lv_take_quantity = <ls_balance>-remaining_quantity.
          ENDIF.
          <ls_balance>-remaining_quantity =
            <ls_balance>-remaining_quantity - lv_take_quantity.
          lv_excess_quantity = lv_excess_quantity - lv_take_quantity.
        ENDLOOP.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_ordered_requests INTO ls_request.
      READ TABLE lt_stock_results INTO ls_stock_result
        WITH KEY sales_document = ls_request-sales_document
                 item_number = ls_request-item_number
                 reservation_through_date =
                   ls_request-reservation_through_date.
      IF sy-subrc <> 0
          OR ls_stock_result-sales_document <> ls_request-sales_document
          OR ls_stock_result-item_number <> ls_request-item_number
          OR ls_stock_result-reservation_through_date
            <> ls_request-reservation_through_date.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      lv_request_as_of_date = iv_as_of_date.
      IF ls_request-required_date > lv_request_as_of_date.
        lv_request_as_of_date = ls_request-required_date.
      ENDIF.
      lv_request_min_days = iv_min_days.
      IF ls_request-minimum_shelf_life_days > lv_request_min_days.
        lv_request_min_days = ls_request-minimum_shelf_life_days.
      ENDIF.
      lv_request_include_undated = iv_include_undated_batches.
      IF ls_request-allow_undated_batches = abap_true.
        lv_request_include_undated = abap_true.
      ENDIF.
      IF ls_request-require_known_expiry = abap_true.
        lv_request_include_undated = abap_false.
      ENDIF.

      lv_source_unit = ls_stock_result-base_unit.
      lv_requested_base_quantity = ls_request-requested_quantity.
      IF ls_request-is_unit_quantity = abap_true.
        lv_source_unit = ls_request-requested_unit.
        DATA(ls_request_conversion) =
          mo_uom_converter->convert_material_unit(
            iv_material    = ls_stock_result-material
            iv_quantity    = ls_request-requested_quantity
            iv_source_unit = ls_request-requested_unit ).
        IF ls_request_conversion-is_successful <> abap_true
            OR ls_request_conversion-base_unit
              <> ls_stock_result-base_unit
            OR ls_request_conversion-base_quantity <= 0.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        lv_requested_base_quantity =
          ls_request_conversion-base_quantity.
      ENDIF.

      CLEAR lv_available_base_quantity.
      LOOP AT lt_balances ASSIGNING <ls_balance>
          WHERE sales_document = ls_request-sales_document
            AND item_number = ls_request-item_number
            AND reservation_through_date =
              ls_request-reservation_through_date.
        IF ls_request-selected_batch IS NOT INITIAL
            AND <ls_balance>-batch <> ls_request-selected_batch.
          CONTINUE.
        ENDIF.
        IF ls_request-selected_storage_location IS NOT INITIAL
            AND ls_request-allow_location_fallback <> abap_true
            AND <ls_balance>-storage_location
              <> ls_request-selected_storage_location.
          CONTINUE.
        ENDIF.
        IF it_location_allowlist IS NOT INITIAL
            AND NOT line_exists( lt_allowed_storage_locations[
              table_line = <ls_balance>-storage_location ] ).
          CONTINUE.
        ENDIF.
        IF line_exists( lt_scoped_request_ids[
            table_line = ls_request-request_id ] )
            AND NOT line_exists( lt_request_locations[
              request_id = ls_request-request_id
              storage_location = <ls_balance>-storage_location ] ).
          CONTINUE.
        ENDIF.
        IF lo_batch_eligibility->is_eligible(
            iv_expiration_date         = <ls_balance>-expiration_date
            iv_as_of_date              = lv_request_as_of_date
            iv_min_days                = lv_request_min_days
            iv_include_undated_batches =
              lv_request_include_undated ) = abap_true.
          lv_available_base_quantity = lv_available_base_quantity
            + <ls_balance>-remaining_quantity.
        ENDIF.
      ENDLOOP.

      CLEAR lt_allocation_orders.
      LOOP AT lt_balances ASSIGNING <ls_balance>
          WHERE sales_document = ls_request-sales_document
            AND item_number = ls_request-item_number
            AND reservation_through_date =
              ls_request-reservation_through_date.
        IF ls_request-selected_batch IS NOT INITIAL
            AND <ls_balance>-batch <> ls_request-selected_batch.
          CONTINUE.
        ENDIF.
        IF ls_request-selected_storage_location IS NOT INITIAL
            AND ls_request-allow_location_fallback <> abap_true
            AND <ls_balance>-storage_location
              <> ls_request-selected_storage_location.
          CONTINUE.
        ENDIF.
        IF it_location_allowlist IS NOT INITIAL
            AND NOT line_exists( lt_allowed_storage_locations[
              table_line = <ls_balance>-storage_location ] ).
          CONTINUE.
        ENDIF.
        IF line_exists( lt_scoped_request_ids[
            table_line = ls_request-request_id ] )
            AND NOT line_exists( lt_request_locations[
              request_id = ls_request-request_id
              storage_location = <ls_balance>-storage_location ] ).
          CONTINUE.
        ENDIF.
        IF <ls_balance>-remaining_quantity <= 0
            OR lo_batch_eligibility->is_eligible(
              iv_expiration_date         = <ls_balance>-expiration_date
              iv_as_of_date              = lv_request_as_of_date
              iv_min_days                = lv_request_min_days
              iv_include_undated_batches =
                lv_request_include_undated ) <> abap_true.
          CONTINUE.
        ENDIF.
        lv_balance_index = sy-tabix.
        CLEAR: lv_location_priority_group, lv_location_priority.
        READ TABLE lt_request_priority_ids TRANSPORTING NO FIELDS
          WITH TABLE KEY table_line = ls_request-request_id.
        IF sy-subrc = 0.
          IF ls_request-allow_location_fallback = abap_true
              AND <ls_balance>-storage_location
                = ls_request-selected_storage_location.
            lv_location_priority = 0.
          ELSE.
            READ TABLE lt_request_location_priorities
              INTO DATA(ls_location_priority)
              WITH TABLE KEY request_id = ls_request-request_id
                             storage_location =
                               <ls_balance>-storage_location.
            IF sy-subrc = 0.
              lv_location_priority = ls_location_priority-priority_rank.
            ELSE.
              lv_location_priority_group = 1.
            ENDIF.
          ENDIF.
        ELSEIF it_storage_location_priority IS INITIAL.
          lv_location_priority = 0.
          IF ls_request-allow_location_fallback = abap_true
              AND <ls_balance>-storage_location
                <> ls_request-selected_storage_location.
            lv_location_priority = 1.
          ENDIF.
        ELSE.
          lv_location_priority = lines(
            it_storage_location_priority ) + 1.
          READ TABLE it_storage_location_priority
            TRANSPORTING NO FIELDS
            WITH KEY table_line = <ls_balance>-storage_location.
          IF sy-subrc = 0.
            lv_location_priority = sy-tabix.
          ENDIF.
          IF ls_request-allow_location_fallback = abap_true
              AND <ls_balance>-storage_location
                = ls_request-selected_storage_location.
            lv_location_priority = 0.
          ENDIF.
        ENDIF.
        APPEND VALUE #(
          balance_index           = lv_balance_index
          sort_expiration_date    = <ls_balance>-sort_expiration_date
          batch                   = <ls_balance>-batch
          location_priority_group = lv_location_priority_group
          location_priority       = lv_location_priority
          storage_location        = <ls_balance>-storage_location )
          TO lt_allocation_orders.
      ENDLOOP.
      SORT lt_allocation_orders STABLE BY sort_expiration_date batch
        location_priority_group location_priority storage_location.

      IF ( iv_require_full_quantity = abap_true
          OR ls_request-require_full_quantity = abap_true )
          AND lv_available_base_quantity < lv_requested_base_quantity.
        lv_remaining_quantity = lv_requested_base_quantity.
      ELSE.
        lv_remaining_quantity = lv_requested_base_quantity.
        LOOP AT lt_allocation_orders INTO DATA(ls_allocation_order).
          IF lv_remaining_quantity <= 0.
            EXIT.
          ENDIF.
          READ TABLE lt_balances ASSIGNING <ls_balance>
            INDEX ls_allocation_order-balance_index.
          IF sy-subrc <> 0.
            RAISE EXCEPTION TYPE zcx_invalid_stock_request.
          ENDIF.
          IF ls_request-selected_batch IS NOT INITIAL
              AND <ls_balance>-batch <> ls_request-selected_batch.
            CONTINUE.
          ENDIF.
          IF ls_request-selected_storage_location IS NOT INITIAL
              AND ls_request-allow_location_fallback <> abap_true
              AND <ls_balance>-storage_location
                <> ls_request-selected_storage_location.
            CONTINUE.
          ENDIF.
          IF it_location_allowlist IS NOT INITIAL
              AND NOT line_exists( lt_allowed_storage_locations[
                table_line = <ls_balance>-storage_location ] ).
            CONTINUE.
          ENDIF.
          IF line_exists( lt_scoped_request_ids[
              table_line = ls_request-request_id ] )
              AND NOT line_exists( lt_request_locations[
                request_id = ls_request-request_id
                storage_location = <ls_balance>-storage_location ] ).
            CONTINUE.
          ENDIF.
          IF lo_batch_eligibility->is_eligible(
              iv_expiration_date         = <ls_balance>-expiration_date
              iv_as_of_date              = lv_request_as_of_date
              iv_min_days                = lv_request_min_days
              iv_include_undated_batches =
                lv_request_include_undated ) <> abap_true
              OR <ls_balance>-remaining_quantity <= 0.
            CONTINUE.
          ENDIF.
          lv_take_quantity = lv_remaining_quantity.
          IF lv_take_quantity > <ls_balance>-remaining_quantity.
            lv_take_quantity = <ls_balance>-remaining_quantity.
          ENDIF.

          DATA(lv_allocated_quantity) = lv_take_quantity.
          IF ls_request-is_unit_quantity = abap_true.
            DATA(ls_allocation_conversion) =
              mo_uom_converter->convert_from_base(
                iv_material      = ls_stock_result-material
                iv_base_quantity = lv_take_quantity
                iv_target_unit   = lv_source_unit ).
            IF ls_allocation_conversion-is_successful <> abap_true
                OR ls_allocation_conversion-base_unit
                  <> ls_stock_result-base_unit.
              RAISE EXCEPTION TYPE zcx_invalid_stock_request.
            ENDIF.
            lv_allocated_quantity =
              ls_allocation_conversion-alternative_quantity.
          ENDIF.
          APPEND VALUE #(
            request_id                = ls_request-request_id
            sales_document            = ls_request-sales_document
            item_number               = ls_request-item_number
            material                  = ls_stock_result-material
            plant                     = ls_stock_result-plant
            storage_location          = <ls_balance>-storage_location
            batch                     = <ls_balance>-batch
            expiration_date           = <ls_balance>-expiration_date
            required_date             = ls_request-required_date
            priority                  = ls_request-priority
            selected_storage_location =
              ls_request-selected_storage_location
            allow_location_fallback   =
              ls_request-allow_location_fallback
            as_of_date                = lv_request_as_of_date
            minimum_shelf_life_days   = lv_request_min_days
            include_undated_batches   = lv_request_include_undated
            require_known_expiry      = ls_request-require_known_expiry
            allow_undated_batches     = ls_request-allow_undated_batches
            base_unit                 = ls_stock_result-base_unit
            allocated_base_quantity   = lv_take_quantity
            requested_unit            = lv_source_unit
            allocated_quantity        = lv_allocated_quantity )
            TO rs_result-batch_allocations.
          <ls_balance>-remaining_quantity =
            <ls_balance>-remaining_quantity - lv_take_quantity.
          lv_remaining_quantity = lv_remaining_quantity - lv_take_quantity.
        ENDLOOP.
      ENDIF.

      lv_covered_base_quantity = lv_requested_base_quantity
        - lv_remaining_quantity.
      lv_shortfall_base_quantity = lv_remaining_quantity.
      DATA(lv_available_quantity) = lv_available_base_quantity.
      DATA(lv_covered_quantity) = lv_covered_base_quantity.
      DATA(lv_shortfall_quantity) = lv_shortfall_base_quantity.
      IF ls_request-is_unit_quantity = abap_true.
        DATA(ls_available_conversion) =
          mo_uom_converter->convert_from_base(
            iv_material      = ls_stock_result-material
            iv_base_quantity = lv_available_base_quantity
            iv_target_unit   = lv_source_unit ).
        DATA(ls_covered_conversion) =
          mo_uom_converter->convert_from_base(
            iv_material      = ls_stock_result-material
            iv_base_quantity = lv_covered_base_quantity
            iv_target_unit   = lv_source_unit ).
        DATA(ls_shortfall_conversion) =
          mo_uom_converter->convert_from_base(
            iv_material      = ls_stock_result-material
            iv_base_quantity = lv_shortfall_base_quantity
            iv_target_unit   = lv_source_unit ).
        IF ls_available_conversion-is_successful <> abap_true
            OR ls_covered_conversion-is_successful <> abap_true
            OR ls_shortfall_conversion-is_successful <> abap_true
            OR ls_available_conversion-base_unit
              <> ls_stock_result-base_unit
            OR ls_covered_conversion-base_unit
              <> ls_stock_result-base_unit
            OR ls_shortfall_conversion-base_unit
              <> ls_stock_result-base_unit.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        lv_available_quantity =
          ls_available_conversion-alternative_quantity.
        lv_covered_quantity =
          ls_covered_conversion-alternative_quantity.
        lv_shortfall_quantity =
          ls_shortfall_conversion-alternative_quantity.
      ENDIF.

      DATA(ls_request_snapshot) = ls_stock_result.
      ls_request_snapshot-request_id = ls_request-request_id.
      APPEND VALUE #(
        request_id                = ls_request-request_id
        sales_document            = ls_request-sales_document
        item_number               = ls_request-item_number
        reservation_through_date  =
          ls_request-reservation_through_date
        required_date             = ls_request-required_date
        priority                  = ls_request-priority
        material                  = ls_stock_result-material
        plant                     = ls_stock_result-plant
        requested_quantity        = ls_request-requested_quantity
        requested_unit            = lv_source_unit
        requested_base_quantity   = lv_requested_base_quantity
        available_quantity        = lv_available_quantity
        available_base_quantity   = lv_available_base_quantity
        covered_quantity          = lv_covered_quantity
        covered_base_quantity     = lv_covered_base_quantity
        shortfall_quantity        = lv_shortfall_quantity
        shortfall_base_quantity   = lv_shortfall_base_quantity
        base_unit                 = ls_stock_result-base_unit
        as_of_date                = lv_request_as_of_date
        minimum_shelf_life_days   = lv_request_min_days
        include_undated_batches   = lv_request_include_undated
        require_known_expiry      = ls_request-require_known_expiry
        allow_undated_batches     = ls_request-allow_undated_batches
        is_sufficient             = xsdbool(
          lv_shortfall_base_quantity = 0 )
        stock_snapshot            = ls_request_snapshot
        selected_storage_location =
          ls_request-selected_storage_location
        allow_location_fallback   = ls_request-allow_location_fallback )
        TO rs_result-allocations.
    ENDLOOP.

    IF iv_prioritize_by_date = abap_true
        OR iv_prioritize_by_priority = abap_true.
      lt_ordered_allocations = rs_result-allocations.
      lt_ordered_batch_allocations = rs_result-batch_allocations.
      CLEAR: rs_result-allocations, rs_result-batch_allocations.
      LOOP AT it_requests INTO ls_request.
        READ TABLE lt_ordered_allocations INTO DATA(ls_ordered_allocation)
          WITH KEY request_id = ls_request-request_id.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        APPEND ls_ordered_allocation TO rs_result-allocations.
        LOOP AT lt_ordered_batch_allocations
            INTO DATA(ls_ordered_batch_allocation)
            WHERE request_id = ls_request-request_id.
          APPEND ls_ordered_batch_allocation
            TO rs_result-batch_allocations.
        ENDLOOP.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
