CLASS zcl_sales_order_alloc_service DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_batch_selection,
        item_number      TYPE c LENGTH 6,
        schedule_line    TYPE c LENGTH 4,
        batch            TYPE mchb-charg,
        storage_location TYPE mard-lgort,
        allow_fallback   TYPE abap_bool,
      END OF ty_batch_selection.
    TYPES ty_batch_selections TYPE STANDARD TABLE OF ty_batch_selection
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_location_selection,
        item_number      TYPE c LENGTH 6,
        schedule_line    TYPE c LENGTH 4,
        storage_location TYPE mard-lgort,
        allow_fallback   TYPE abap_bool,
      END OF ty_location_selection.
    TYPES ty_location_selections TYPE STANDARD TABLE OF ty_location_selection
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_sales_unit_allocation,
        request_id              TYPE c LENGTH 30,
        sales_document          TYPE zif_sales_order_api=>ty_sales_document,
        item_number             TYPE c LENGTH 6,
        schedule_line           TYPE c LENGTH 4,
        material                TYPE mard-matnr,
        plant                   TYPE mard-werks,
        sales_unit              TYPE c LENGTH 3,
        base_unit               TYPE mara-meins,
        requested_quantity      TYPE mard-labst,
        requested_base_quantity TYPE mard-labst,
        available_quantity      TYPE mard-labst,
        available_base_quantity TYPE mard-labst,
        allocated_quantity      TYPE mard-labst,
        allocated_base_quantity TYPE mard-labst,
        shortfall_quantity      TYPE mard-labst,
        shortfall_base_quantity TYPE mard-labst,
      END OF ty_sales_unit_allocation.
    TYPES ty_sales_unit_allocations TYPE STANDARD TABLE OF
      ty_sales_unit_allocation WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_result,
        sales_document         TYPE zif_sales_order_api=>ty_sales_document,
        allocations            TYPE zcl_stock_service=>ty_allocations,
        storage_allocations    TYPE zcl_stock_service=>ty_storage_allocations,
        batch_allocations      TYPE zcl_stock_service=>ty_batch_allocations,
        sales_unit_allocations TYPE ty_sales_unit_allocations,
        messages               TYPE zif_sales_order_api=>ty_messages,
        is_successful          TYPE abap_bool,
      END OF ty_result.
    TYPES:
      BEGIN OF ty_reserve_result,
        sales_document         TYPE zif_sales_order_api=>ty_sales_document,
        allocations            TYPE zcl_stock_service=>ty_allocations,
        storage_allocations    TYPE zcl_stock_service=>ty_storage_allocations,
        batch_allocations      TYPE zcl_stock_service=>ty_batch_allocations,
        sales_unit_allocations TYPE ty_sales_unit_allocations,
        reservations           TYPE zif_so_reservation_api=>ty_reservations,
        messages               TYPE zif_sales_order_api=>ty_messages,
        is_successful          TYPE abap_bool,
      END OF ty_reserve_result.

    METHODS constructor
      IMPORTING
        io_sales_order_api  TYPE REF TO zif_sales_order_api
        io_stock_repository TYPE REF TO zif_stock_repository
        io_reservation_api  TYPE REF TO zif_so_reservation_api
          OPTIONAL.

    METHODS preview_order
      IMPORTING
        iv_sales_document       TYPE zif_sales_order_api=>ty_sales_document
        it_batch_selections     TYPE ty_batch_selections OPTIONAL
        it_location_selections  TYPE ty_location_selections OPTIONAL
        iv_use_fefo_batches     TYPE abap_bool DEFAULT abap_false
        iv_fefo_as_of_date      TYPE d DEFAULT sy-datum
        iv_fefo_min_days        TYPE i DEFAULT 0
        iv_prioritize_by_date   TYPE abap_bool DEFAULT abap_false
        iv_use_confirmed_qty    TYPE abap_bool DEFAULT abap_false
        iv_protect_safety_stock TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)        TYPE ty_result
      RAISING
        zcx_invalid_sales_order
        zcx_invalid_stock_request.

    METHODS reserve_order
      IMPORTING
        iv_sales_document          TYPE zif_sales_order_api=>ty_sales_document
        iv_test_run                TYPE abap_bool DEFAULT abap_false
        it_batch_selections        TYPE ty_batch_selections OPTIONAL
        iv_require_full_allocation TYPE abap_bool DEFAULT abap_false
        it_location_selections     TYPE ty_location_selections OPTIONAL
        iv_use_fefo_batches        TYPE abap_bool DEFAULT abap_false
        iv_fefo_as_of_date         TYPE d DEFAULT sy-datum
        iv_fefo_min_days           TYPE i DEFAULT 0
        iv_prioritize_by_date      TYPE abap_bool DEFAULT abap_false
        iv_use_confirmed_qty       TYPE abap_bool DEFAULT abap_false
        iv_protect_safety_stock    TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)           TYPE ty_reserve_result
      RAISING
        zcx_invalid_sales_order
        zcx_invalid_stock_request.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_prepared,
        order_items            TYPE zif_sales_order_api=>ty_items,
        allocations            TYPE zcl_stock_service=>ty_allocations,
        storage_allocations    TYPE zcl_stock_service=>ty_storage_allocations,
        batch_allocations      TYPE zcl_stock_service=>ty_batch_allocations,
        sales_unit_allocations TYPE ty_sales_unit_allocations,
        messages               TYPE zif_sales_order_api=>ty_messages,
        is_successful          TYPE abap_bool,
      END OF ty_prepared.
    TYPES:
      BEGIN OF ty_selection_key,
        item_number   TYPE c LENGTH 6,
        schedule_line TYPE c LENGTH 4,
      END OF ty_selection_key.
    TYPES ty_selection_keys TYPE HASHED TABLE OF ty_selection_key
      WITH UNIQUE KEY item_number schedule_line.
    TYPES:
      BEGIN OF ty_selection_item,
        item_number TYPE c LENGTH 6,
      END OF ty_selection_item.
    TYPES ty_selection_items TYPE HASHED TABLE OF ty_selection_item
      WITH UNIQUE KEY item_number.
    TYPES:
      BEGIN OF ty_selection_mode,
        item_number TYPE c LENGTH 6,
        mode        TYPE c LENGTH 1,
      END OF ty_selection_mode.
    TYPES ty_selection_modes TYPE HASHED TABLE OF ty_selection_mode
      WITH UNIQUE KEY item_number.
    TYPES:
      BEGIN OF ty_date_priority,
        missing_date   TYPE abap_bool,
        requested_date TYPE d,
        source_index   TYPE i,
      END OF ty_date_priority.
    TYPES ty_date_priorities TYPE STANDARD TABLE OF ty_date_priority
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_order_reservation_balance,
        material           TYPE mard-matnr,
        plant              TYPE mard-werks,
        item_number        TYPE c LENGTH 6,
        schedule_line      TYPE c LENGTH 4,
        requirement_date   TYPE d,
        remaining_quantity TYPE mard-labst,
      END OF ty_order_reservation_balance.
    TYPES ty_order_reservation_balances TYPE STANDARD TABLE OF
      ty_order_reservation_balance WITH EMPTY KEY.

    DATA mo_sales_order_service TYPE REF TO zcl_sales_order_service.
    DATA mo_stock_service TYPE REF TO zcl_stock_service.
    DATA mo_reservation_api TYPE REF TO zif_so_reservation_api.

    METHODS prepare_order_allocations
      IMPORTING
        iv_sales_document       TYPE zif_sales_order_api=>ty_sales_document
        it_batch_selections     TYPE ty_batch_selections OPTIONAL
        it_location_selections  TYPE ty_location_selections OPTIONAL
        iv_use_fefo_batches     TYPE abap_bool DEFAULT abap_false
        iv_fefo_as_of_date      TYPE d DEFAULT sy-datum
        iv_fefo_min_days        TYPE i DEFAULT 0
        iv_prioritize_by_date   TYPE abap_bool DEFAULT abap_false
        iv_use_confirmed_qty    TYPE abap_bool DEFAULT abap_false
        iv_protect_safety_stock TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_prepared)      TYPE ty_prepared
      RAISING
        zcx_invalid_sales_order
        zcx_invalid_stock_request.

    METHODS subtract_order_reservations
      IMPORTING
        it_reservations TYPE zif_stock_repository=>ty_sales_order_reservations
      CHANGING
        ct_order_items  TYPE zif_sales_order_api=>ty_items.

    METHODS build_sales_unit_allocations
      IMPORTING
        iv_sales_document     TYPE zif_sales_order_api=>ty_sales_document
        it_order_items        TYPE zif_sales_order_api=>ty_items
        it_allocations        TYPE zcl_stock_service=>ty_allocations
      RETURNING
        VALUE(rt_allocations) TYPE ty_sales_unit_allocations
      RAISING
        zcx_invalid_stock_request.

    METHODS convert_base_to_sales_unit
      IMPORTING
        iv_base_quantity   TYPE mard-labst
        iv_numerator       TYPE bapisdit-sales_qty1
        iv_denominator     TYPE bapisdit-sales_qty2
      RETURNING
        VALUE(rv_quantity) TYPE mard-labst.
ENDCLASS.

CLASS zcl_sales_order_alloc_service IMPLEMENTATION.

  METHOD constructor.
    mo_sales_order_service = NEW zcl_sales_order_service(
      io_api = io_sales_order_api ).
    mo_stock_service = NEW zcl_stock_service(
      io_stock_repository = io_stock_repository ).
    IF io_reservation_api IS BOUND.
      mo_reservation_api = io_reservation_api.
    ELSE.
      mo_reservation_api = NEW zcl_bapi_so_reservation_api( ).
    ENDIF.
  ENDMETHOD.

  METHOD preview_order.
    DATA ls_prepared TYPE ty_prepared.
    IF it_batch_selections IS SUPPLIED
        AND it_location_selections IS SUPPLIED.
      ls_prepared = prepare_order_allocations(
        iv_sales_document       = iv_sales_document
        it_batch_selections     = it_batch_selections
        it_location_selections  = it_location_selections
        iv_use_fefo_batches     = iv_use_fefo_batches
        iv_fefo_as_of_date      = iv_fefo_as_of_date
        iv_fefo_min_days        =
          iv_fefo_min_days
        iv_prioritize_by_date   = iv_prioritize_by_date
        iv_use_confirmed_qty    = iv_use_confirmed_qty
        iv_protect_safety_stock = iv_protect_safety_stock ).
    ELSEIF it_batch_selections IS SUPPLIED.
      ls_prepared = prepare_order_allocations(
        iv_sales_document       = iv_sales_document
        it_batch_selections     = it_batch_selections
        iv_use_fefo_batches     = iv_use_fefo_batches
        iv_fefo_as_of_date      = iv_fefo_as_of_date
        iv_fefo_min_days        =
          iv_fefo_min_days
        iv_prioritize_by_date   = iv_prioritize_by_date
        iv_use_confirmed_qty    = iv_use_confirmed_qty
        iv_protect_safety_stock = iv_protect_safety_stock ).
    ELSEIF it_location_selections IS SUPPLIED.
      ls_prepared = prepare_order_allocations(
        iv_sales_document       = iv_sales_document
        it_location_selections  = it_location_selections
        iv_use_fefo_batches     = iv_use_fefo_batches
        iv_fefo_as_of_date      = iv_fefo_as_of_date
        iv_fefo_min_days        =
          iv_fefo_min_days
        iv_prioritize_by_date   = iv_prioritize_by_date
        iv_use_confirmed_qty    = iv_use_confirmed_qty
        iv_protect_safety_stock = iv_protect_safety_stock ).
    ELSE.
      ls_prepared = prepare_order_allocations(
        iv_sales_document       = iv_sales_document
        iv_use_fefo_batches     = iv_use_fefo_batches
        iv_fefo_as_of_date      = iv_fefo_as_of_date
        iv_fefo_min_days        =
          iv_fefo_min_days
        iv_prioritize_by_date   = iv_prioritize_by_date
        iv_use_confirmed_qty    = iv_use_confirmed_qty
        iv_protect_safety_stock = iv_protect_safety_stock ).
    ENDIF.
    rs_result-sales_document = iv_sales_document.
    rs_result-allocations = ls_prepared-allocations.
    rs_result-storage_allocations = ls_prepared-storage_allocations.
    rs_result-batch_allocations = ls_prepared-batch_allocations.
    rs_result-sales_unit_allocations =
      ls_prepared-sales_unit_allocations.
    rs_result-messages = ls_prepared-messages.
    rs_result-is_successful = ls_prepared-is_successful.
  ENDMETHOD.

  METHOD reserve_order.
    DATA ls_prepared TYPE ty_prepared.
    IF it_batch_selections IS SUPPLIED
        AND it_location_selections IS SUPPLIED.
      ls_prepared = prepare_order_allocations(
        iv_sales_document       = iv_sales_document
        it_batch_selections     = it_batch_selections
        it_location_selections  = it_location_selections
        iv_use_fefo_batches     = iv_use_fefo_batches
        iv_fefo_as_of_date      = iv_fefo_as_of_date
        iv_fefo_min_days        =
          iv_fefo_min_days
        iv_prioritize_by_date   = iv_prioritize_by_date
        iv_use_confirmed_qty    = iv_use_confirmed_qty
        iv_protect_safety_stock = iv_protect_safety_stock ).
    ELSEIF it_batch_selections IS SUPPLIED.
      ls_prepared = prepare_order_allocations(
        iv_sales_document       = iv_sales_document
        it_batch_selections     = it_batch_selections
        iv_use_fefo_batches     = iv_use_fefo_batches
        iv_fefo_as_of_date      = iv_fefo_as_of_date
        iv_fefo_min_days        =
          iv_fefo_min_days
        iv_prioritize_by_date   = iv_prioritize_by_date
        iv_use_confirmed_qty    = iv_use_confirmed_qty
        iv_protect_safety_stock = iv_protect_safety_stock ).
    ELSEIF it_location_selections IS SUPPLIED.
      ls_prepared = prepare_order_allocations(
        iv_sales_document       = iv_sales_document
        it_location_selections  = it_location_selections
        iv_use_fefo_batches     = iv_use_fefo_batches
        iv_fefo_as_of_date      = iv_fefo_as_of_date
        iv_fefo_min_days        =
          iv_fefo_min_days
        iv_prioritize_by_date   = iv_prioritize_by_date
        iv_use_confirmed_qty    = iv_use_confirmed_qty
        iv_protect_safety_stock = iv_protect_safety_stock ).
    ELSE.
      ls_prepared = prepare_order_allocations(
        iv_sales_document       = iv_sales_document
        iv_use_fefo_batches     = iv_use_fefo_batches
        iv_fefo_as_of_date      = iv_fefo_as_of_date
        iv_fefo_min_days        =
          iv_fefo_min_days
        iv_prioritize_by_date   = iv_prioritize_by_date
        iv_use_confirmed_qty    = iv_use_confirmed_qty
        iv_protect_safety_stock = iv_protect_safety_stock ).
    ENDIF.
    rs_result-sales_document = iv_sales_document.
    rs_result-allocations = ls_prepared-allocations.
    rs_result-storage_allocations = ls_prepared-storage_allocations.
    rs_result-batch_allocations = ls_prepared-batch_allocations.
    rs_result-sales_unit_allocations =
      ls_prepared-sales_unit_allocations.
    rs_result-messages = ls_prepared-messages.

    IF ls_prepared-is_successful = abap_false.
      RETURN.
    ENDIF.

    IF iv_require_full_allocation = abap_true.
      LOOP AT ls_prepared-allocations INTO DATA(ls_checked_allocation)
        WHERE shortfall_quantity > 0.
        APPEND VALUE #(
          type    = 'E'
          message = 'Full allocation required; no reservations were created' )
          TO rs_result-messages.
        RETURN.
      ENDLOOP.
    ENDIF.

    DATA lt_requests TYPE zif_so_reservation_api=>ty_requests.
    LOOP AT ls_prepared-order_items INTO DATA(ls_order_item).
      IF ls_order_item-open_base_quantity <= 0.
        CONTINUE.
      ENDIF.

      DATA lv_request_id TYPE c LENGTH 30.
      CLEAR lv_request_id.
      IF ls_order_item-schedule_line IS INITIAL.
        CONCATENATE iv_sales_document ls_order_item-item_number
          INTO lv_request_id SEPARATED BY '/'.
      ELSE.
        CONCATENATE iv_sales_document ls_order_item-item_number
          ls_order_item-schedule_line
          INTO lv_request_id SEPARATED BY '/'.
      ENDIF.
      IF it_batch_selections IS SUPPLIED
          OR iv_use_fefo_batches = abap_true.
        LOOP AT ls_prepared-batch_allocations INTO DATA(ls_batch_allocation)
          WHERE request_id = lv_request_id.
          APPEND VALUE #(
            request_id       = lv_request_id
            sales_document   = iv_sales_document
            item_number      = ls_order_item-item_number
            material         = ls_order_item-material
            plant            = ls_order_item-plant
            storage_location = ls_batch_allocation-storage_location
            batch            = ls_batch_allocation-batch
            required_date    = ls_order_item-requested_date
            quantity         = ls_batch_allocation-allocated_quantity
            unit             = ls_order_item-base_unit ) TO lt_requests.
        ENDLOOP.
      ELSE.
        LOOP AT ls_prepared-storage_allocations INTO DATA(ls_storage_allocation)
          WHERE request_id = lv_request_id.
          APPEND VALUE #(
            request_id       = lv_request_id
            sales_document   = iv_sales_document
            item_number      = ls_order_item-item_number
            material         = ls_order_item-material
            plant            = ls_order_item-plant
            storage_location = ls_storage_allocation-storage_location
            required_date    = ls_order_item-requested_date
            quantity         = ls_storage_allocation-allocated_quantity
            unit             = ls_order_item-base_unit ) TO lt_requests.
        ENDLOOP.
      ENDIF.
    ENDLOOP.

    IF lt_requests IS INITIAL.
      rs_result-is_successful = abap_true.
      RETURN.
    ENDIF.

    DATA(ls_create_result) = mo_reservation_api->create_reservations(
      it_requests = lt_requests
      iv_test_run = iv_test_run ).
    APPEND LINES OF ls_create_result-messages TO rs_result-messages.
    rs_result-reservations = ls_create_result-reservations.

    IF ls_create_result-is_successful = abap_false.
      mo_reservation_api->rollback( ).
      CLEAR rs_result-reservations.
      RETURN.
    ENDIF.

    IF iv_test_run = abap_true.
      rs_result-is_successful = abap_true.
      RETURN.
    ENDIF.

    IF lines( rs_result-reservations ) <> lines( lt_requests ).
      mo_reservation_api->rollback( ).
      CLEAR rs_result-reservations.
      APPEND VALUE #(
        type    = 'E'
        message = 'Reservation API returned an incomplete reservation list' )
        TO rs_result-messages.
      RETURN.
    ENDIF.

    LOOP AT rs_result-reservations INTO DATA(ls_reservation).
      IF ls_reservation-reservation_number IS INITIAL.
        mo_reservation_api->rollback( ).
        CLEAR rs_result-reservations.
        APPEND VALUE #(
          type    = 'E'
          message = 'Reservation API did not return a reservation number' )
          TO rs_result-messages.
        RETURN.
      ENDIF.
    ENDLOOP.

    DATA(ls_commit_result) = mo_reservation_api->commit( ).
    IF ls_commit_result-is_successful = abap_false.
      mo_reservation_api->rollback( ).
      CLEAR rs_result-reservations.
      IF ls_commit_result-message-message IS NOT INITIAL.
        APPEND ls_commit_result-message TO rs_result-messages.
      ENDIF.
      RETURN.
    ENDIF.

    rs_result-is_successful = abap_true.
  ENDMETHOD.

  METHOD prepare_order_allocations.
    FIELD-SYMBOLS <ls_order_item> TYPE zif_sales_order_api=>ty_item.

    IF iv_sales_document IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_sales_order.
    ENDIF.

    IF iv_fefo_min_days < 0
        OR ( iv_fefo_min_days > 0
          AND iv_use_fefo_batches <> abap_true ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    IF it_batch_selections IS SUPPLIED
        AND it_location_selections IS SUPPLIED.
      APPEND VALUE #(
        type    = 'E'
        message = 'Choose batch selections or location selections, not both' )
        TO rs_prepared-messages.
      RETURN.
    ENDIF.

    IF iv_use_fefo_batches = abap_true
        AND it_batch_selections IS SUPPLIED.
      APPEND VALUE #(
        type    = 'E'
        message = 'Choose FEFO allocation or explicit batch selections' )
        TO rs_prepared-messages.
      RETURN.
    ENDIF.

    IF iv_use_fefo_batches = abap_true
        AND iv_fefo_as_of_date IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    DATA(ls_order_result) = mo_sales_order_service->read_order(
      iv_sales_document ).
    rs_prepared-order_items = ls_order_result-order-items.
    rs_prepared-messages = ls_order_result-messages.

    IF ls_order_result-is_successful = abap_false.
      RETURN.
    ENDIF.

    IF iv_use_confirmed_qty = abap_true.
      LOOP AT rs_prepared-order_items ASSIGNING <ls_order_item>.
        IF <ls_order_item>-open_base_quantity > 0
            AND ( <ls_order_item>-schedule_line IS INITIAL
              OR <ls_order_item>-has_confirmed_quantity <> abap_true ).
          APPEND VALUE #(
            type    = 'E'
            message = 'Confirmed-quantity mode requires schedule-line confirmation data' )
            TO rs_prepared-messages.
          RETURN.
        ENDIF.

        IF <ls_order_item>-has_confirmed_quantity = abap_true.
          IF <ls_order_item>-confirmed_quantity < 0
              OR <ls_order_item>-open_confirmed_quantity < 0
              OR <ls_order_item>-confirmed_base_quantity < 0
              OR <ls_order_item>-open_confirmed_base_quantity < 0.
            APPEND VALUE #(
              type    = 'E'
              message = 'Schedule line contains a negative confirmed quantity' )
              TO rs_prepared-messages.
            RETURN.
          ENDIF.

          IF <ls_order_item>-open_confirmed_quantity >
              <ls_order_item>-open_quantity.
            <ls_order_item>-open_confirmed_quantity =
              <ls_order_item>-open_quantity.
          ENDIF.
          IF <ls_order_item>-open_confirmed_base_quantity >
              <ls_order_item>-open_base_quantity.
            <ls_order_item>-open_confirmed_base_quantity =
              <ls_order_item>-open_base_quantity.
          ENDIF.

          <ls_order_item>-open_quantity =
            <ls_order_item>-open_confirmed_quantity.
          <ls_order_item>-open_base_quantity =
            <ls_order_item>-open_confirmed_base_quantity.
        ENDIF.
      ENDLOOP.
    ENDIF.

    DATA lt_demands TYPE zcl_stock_service=>ty_demands.
    DATA lt_batch_demands TYPE zcl_stock_service=>ty_batch_demands.
    DATA lt_fefo_demands TYPE zcl_stock_service=>ty_fefo_demands.
    DATA lt_seen_selections TYPE ty_selection_keys.
    DATA lt_open_selection_keys TYPE ty_selection_keys.
    DATA lt_open_selection_items TYPE ty_selection_items.
    DATA lt_selection_modes TYPE ty_selection_modes.
    DATA lt_date_priorities TYPE ty_date_priorities.
    DATA lt_prioritized_order_items TYPE zif_sales_order_api=>ty_items.
    DATA lv_fefo_location TYPE mard-lgort.
    DATA lv_fefo_fallback TYPE abap_bool.

    IF iv_prioritize_by_date = abap_true.
      LOOP AT rs_prepared-order_items INTO DATA(ls_priority_source).
        APPEND VALUE #(
          missing_date   = COND abap_bool(
            WHEN ls_priority_source-requested_date IS INITIAL
              THEN abap_true
            ELSE abap_false )
          requested_date = ls_priority_source-requested_date
          source_index   = sy-tabix )
          TO lt_date_priorities.
      ENDLOOP.
      SORT lt_date_priorities BY missing_date requested_date source_index.
      LOOP AT lt_date_priorities INTO DATA(ls_date_priority).
        READ TABLE rs_prepared-order_items
          INDEX ls_date_priority-source_index
          INTO DATA(ls_prioritized_order_item).
        IF sy-subrc = 0.
          APPEND ls_prioritized_order_item TO lt_prioritized_order_items.
        ENDIF.
      ENDLOOP.
      rs_prepared-order_items = lt_prioritized_order_items.
    ENDIF.

    LOOP AT rs_prepared-order_items INTO DATA(ls_validated_item)
      WHERE open_base_quantity > 0.
      IF ls_validated_item-material IS INITIAL
          OR ls_validated_item-plant IS INITIAL
          OR ls_validated_item-base_unit IS INITIAL
          OR ls_validated_item-item_number IS INITIAL.
        APPEND VALUE #(
          type    = 'E'
          message = 'Open order item lacks its number, material, plant, or base unit' )
          TO rs_prepared-messages.
        RETURN.
      ENDIF.

      IF ls_validated_item-schedule_line IS NOT INITIAL
          AND ls_validated_item-requested_date IS INITIAL.
        APPEND VALUE #(
          type    = 'E'
          message = 'Open schedule line lacks a requested date' )
          TO rs_prepared-messages.
        RETURN.
      ENDIF.

      IF ls_validated_item-entry_unit IS NOT INITIAL
          AND ls_validated_item-entry_unit <> ls_validated_item-base_unit
          AND ( ls_validated_item-sales_unit_numerator <= 0
            OR ls_validated_item-sales_unit_denominator <= 0 ).
        APPEND VALUE #(
          type    = 'E'
          message = 'Open order item lacks a valid sales unit conversion ratio' )
          TO rs_prepared-messages.
        RETURN.
      ENDIF.
    ENDLOOP.

    DATA(lt_order_reservations) =
      mo_stock_service->get_sales_order_reservations(
        iv_sales_document = iv_sales_document ).
    subtract_order_reservations(
      EXPORTING
        it_reservations = lt_order_reservations
      CHANGING
        ct_order_items  = rs_prepared-order_items ).

    IF it_batch_selections IS SUPPLIED.
      LOOP AT it_batch_selections INTO DATA(ls_batch_selection).
        IF ls_batch_selection-item_number IS INITIAL
            OR ls_batch_selection-batch IS INITIAL.
          APPEND VALUE #(
            type    = 'E'
            message = 'Batch selection requires an item number and batch' )
            TO rs_prepared-messages.
          RETURN.
        ENDIF.
        IF ls_batch_selection-allow_fallback = abap_true
            AND ls_batch_selection-storage_location IS INITIAL.
          APPEND VALUE #(
            type    = 'E'
            message = 'Batch fallback requires a preferred storage location' )
            TO rs_prepared-messages.
          RETURN.
        ENDIF.
        INSERT VALUE #(
          item_number   = ls_batch_selection-item_number
          schedule_line = ls_batch_selection-schedule_line )
          INTO TABLE lt_seen_selections.
        IF sy-subrc <> 0.
          APPEND VALUE #(
            type    = 'E'
            message = 'Batch selection repeats an order item and schedule line' )
            TO rs_prepared-messages.
          RETURN.
        ENDIF.

        DATA(lv_selection_mode) = COND #(
          WHEN ls_batch_selection-schedule_line IS INITIAL THEN 'W'
          ELSE 'S' ).
        READ TABLE lt_selection_modes INTO DATA(ls_selection_mode)
          WITH TABLE KEY item_number = ls_batch_selection-item_number.
        IF sy-subrc = 0 AND ls_selection_mode-mode <> lv_selection_mode.
          APPEND VALUE #(
            type    = 'E'
            message = 'Batch selection cannot mix item-wide and schedule-line choices' )
            TO rs_prepared-messages.
          RETURN.
        ELSEIF sy-subrc <> 0.
          INSERT VALUE #(
            item_number = ls_batch_selection-item_number
            mode        = lv_selection_mode )
            INTO TABLE lt_selection_modes.
        ENDIF.
      ENDLOOP.
    ENDIF.

    IF it_location_selections IS SUPPLIED.
      LOOP AT it_location_selections INTO DATA(ls_location_selection).
        IF ls_location_selection-item_number IS INITIAL
            OR ls_location_selection-storage_location IS INITIAL.
          APPEND VALUE #(
            type    = 'E'
            message = 'Location selection requires an item number and storage location' )
            TO rs_prepared-messages.
          RETURN.
        ENDIF.
        INSERT VALUE #(
          item_number   = ls_location_selection-item_number
          schedule_line = ls_location_selection-schedule_line )
          INTO TABLE lt_seen_selections.
        IF sy-subrc <> 0.
          APPEND VALUE #(
            type    = 'E'
            message = 'Location selection repeats an order item and schedule line' )
            TO rs_prepared-messages.
          RETURN.
        ENDIF.

        DATA(lv_location_mode) = COND #(
          WHEN ls_location_selection-schedule_line IS INITIAL THEN 'W'
          ELSE 'S' ).
        READ TABLE lt_selection_modes INTO ls_selection_mode
          WITH TABLE KEY item_number = ls_location_selection-item_number.
        IF sy-subrc = 0 AND ls_selection_mode-mode <> lv_location_mode.
          APPEND VALUE #(
            type    = 'E'
            message = 'Location selection cannot mix item-wide and schedule-line choices' )
            TO rs_prepared-messages.
          RETURN.
        ELSEIF sy-subrc <> 0.
          INSERT VALUE #(
            item_number = ls_location_selection-item_number
            mode        = lv_location_mode )
            INTO TABLE lt_selection_modes.
        ENDIF.
      ENDLOOP.
    ENDIF.

    LOOP AT rs_prepared-order_items INTO DATA(ls_order_item).
      IF ls_order_item-open_base_quantity <= 0.
        CONTINUE.
      ENDIF.

      INSERT VALUE #(
        item_number   = ls_order_item-item_number
        schedule_line = ls_order_item-schedule_line )
        INTO TABLE lt_open_selection_keys.
      INSERT VALUE #( item_number = ls_order_item-item_number )
        INTO TABLE lt_open_selection_items.

      IF ls_order_item-material IS INITIAL
          OR ls_order_item-plant IS INITIAL
          OR ls_order_item-base_unit IS INITIAL
          OR ls_order_item-item_number IS INITIAL.
        APPEND VALUE #(
          type    = 'E'
          message = 'Open order item lacks its number, material, plant, or base unit' )
          TO rs_prepared-messages.
        RETURN.
      ENDIF.

      IF ls_order_item-schedule_line IS NOT INITIAL
          AND ls_order_item-requested_date IS INITIAL.
        APPEND VALUE #(
          type    = 'E'
          message = 'Open schedule line lacks a requested date' )
          TO rs_prepared-messages.
        RETURN.
      ENDIF.

      DATA lv_request_id TYPE c LENGTH 30.
      CLEAR lv_request_id.
      IF ls_order_item-schedule_line IS INITIAL.
        CONCATENATE iv_sales_document ls_order_item-item_number
          INTO lv_request_id SEPARATED BY '/'.
      ELSE.
        CONCATENATE iv_sales_document ls_order_item-item_number
          ls_order_item-schedule_line
          INTO lv_request_id SEPARATED BY '/'.
      ENDIF.
      IF it_batch_selections IS SUPPLIED.
        READ TABLE it_batch_selections INTO ls_batch_selection
          WITH KEY item_number   = ls_order_item-item_number
                   schedule_line = ls_order_item-schedule_line.
        IF sy-subrc <> 0 AND ls_order_item-schedule_line IS NOT INITIAL.
          READ TABLE it_batch_selections INTO ls_batch_selection
            WITH KEY item_number   = ls_order_item-item_number
                     schedule_line = space.
        ENDIF.
        IF sy-subrc <> 0.
          APPEND VALUE #(
            type    = 'E'
            message = 'Batch selection is required for every open schedule line' )
            TO rs_prepared-messages.
          RETURN.
        ENDIF.
        APPEND VALUE #(
          request_id                  = lv_request_id
          material                    = ls_order_item-material
          plant                       = ls_order_item-plant
          batch                       = ls_batch_selection-batch
          storage_location            = ls_batch_selection-storage_location
          fallback_to_other_locations = ls_batch_selection-allow_fallback
          requested_quantity          = ls_order_item-open_base_quantity )
          TO lt_batch_demands.
      ELSEIF iv_use_fefo_batches = abap_true.
        CLEAR lv_fefo_location.
        CLEAR lv_fefo_fallback.
        IF it_location_selections IS SUPPLIED.
          READ TABLE it_location_selections INTO ls_location_selection
            WITH KEY item_number   = ls_order_item-item_number
                     schedule_line = ls_order_item-schedule_line.
          IF sy-subrc <> 0 AND ls_order_item-schedule_line IS NOT INITIAL.
            READ TABLE it_location_selections INTO ls_location_selection
              WITH KEY item_number   = ls_order_item-item_number
                       schedule_line = space.
          ENDIF.
          IF sy-subrc <> 0.
            APPEND VALUE #(
              type    = 'E'
              message = 'Location selection is required for every open schedule line' )
              TO rs_prepared-messages.
            RETURN.
          ENDIF.
          lv_fefo_location = ls_location_selection-storage_location.
          lv_fefo_fallback = ls_location_selection-allow_fallback.
        ENDIF.
        APPEND VALUE #(
          request_id                  = lv_request_id
          material                    = ls_order_item-material
          plant                       = ls_order_item-plant
          storage_location            = lv_fefo_location
          fallback_to_other_locations = lv_fefo_fallback
          requested_quantity          = ls_order_item-open_base_quantity )
          TO lt_fefo_demands.
      ELSEIF it_location_selections IS SUPPLIED.
        READ TABLE it_location_selections INTO ls_location_selection
          WITH KEY item_number   = ls_order_item-item_number
                   schedule_line = ls_order_item-schedule_line.
        IF sy-subrc <> 0 AND ls_order_item-schedule_line IS NOT INITIAL.
          READ TABLE it_location_selections INTO ls_location_selection
            WITH KEY item_number   = ls_order_item-item_number
                     schedule_line = space.
        ENDIF.
        IF sy-subrc <> 0.
          APPEND VALUE #(
            type    = 'E'
            message = 'Location selection is required for every open schedule line' )
            TO rs_prepared-messages.
          RETURN.
        ENDIF.
        APPEND VALUE #(
          request_id                  = lv_request_id
          material                    = ls_order_item-material
          plant                       = ls_order_item-plant
          storage_location            = ls_location_selection-storage_location
          fallback_to_other_locations = ls_location_selection-allow_fallback
          requested_quantity          = ls_order_item-open_base_quantity )
          TO lt_demands.
      ELSE.
        APPEND VALUE #(
          request_id         = lv_request_id
          material           = ls_order_item-material
          plant              = ls_order_item-plant
          requested_quantity = ls_order_item-open_base_quantity )
          TO lt_demands.
      ENDIF.
    ENDLOOP.

    IF it_batch_selections IS SUPPLIED.
      LOOP AT it_batch_selections INTO ls_batch_selection.
        IF ls_batch_selection-schedule_line IS INITIAL.
          READ TABLE lt_open_selection_items TRANSPORTING NO FIELDS
            WITH TABLE KEY item_number = ls_batch_selection-item_number.
        ELSE.
          READ TABLE lt_open_selection_keys TRANSPORTING NO FIELDS
            WITH TABLE KEY item_number = ls_batch_selection-item_number
                           schedule_line = ls_batch_selection-schedule_line.
        ENDIF.
        IF sy-subrc <> 0.
          APPEND VALUE #(
            type    = 'E'
            message = 'Batch selection contains an item or schedule line that is not open' )
            TO rs_prepared-messages.
          RETURN.
        ENDIF.
      ENDLOOP.
      DATA(ls_batch_result) = mo_stock_service->allocate_by_batch(
        it_demands              = lt_batch_demands
        iv_protect_safety_stock = iv_protect_safety_stock ).
      rs_prepared-allocations = ls_batch_result-allocations.
      rs_prepared-batch_allocations = ls_batch_result-batch_allocations.
    ELSEIF iv_use_fefo_batches = abap_true.
      IF it_location_selections IS SUPPLIED.
        LOOP AT it_location_selections INTO ls_location_selection.
          IF ls_location_selection-schedule_line IS INITIAL.
            READ TABLE lt_open_selection_items TRANSPORTING NO FIELDS
              WITH TABLE KEY item_number = ls_location_selection-item_number.
          ELSE.
            READ TABLE lt_open_selection_keys TRANSPORTING NO FIELDS
              WITH TABLE KEY item_number = ls_location_selection-item_number
                             schedule_line = ls_location_selection-schedule_line.
          ENDIF.
          IF sy-subrc <> 0.
            APPEND VALUE #(
              type    = 'E'
              message = 'Location selection contains an item or schedule line that is not open' )
              TO rs_prepared-messages.
            RETURN.
          ENDIF.
        ENDLOOP.
      ENDIF.
      DATA(ls_fefo_result) = mo_stock_service->allocate_by_expiry(
        it_demands              = lt_fefo_demands
        iv_as_of_date           = iv_fefo_as_of_date
        iv_min_days             =
          iv_fefo_min_days
        iv_protect_safety_stock = iv_protect_safety_stock ).
      rs_prepared-allocations = ls_fefo_result-allocations.
      rs_prepared-batch_allocations = ls_fefo_result-batch_allocations.
    ELSE.
      IF it_location_selections IS SUPPLIED.
        LOOP AT it_location_selections INTO ls_location_selection.
          IF ls_location_selection-schedule_line IS INITIAL.
            READ TABLE lt_open_selection_items TRANSPORTING NO FIELDS
              WITH TABLE KEY item_number = ls_location_selection-item_number.
          ELSE.
            READ TABLE lt_open_selection_keys TRANSPORTING NO FIELDS
              WITH TABLE KEY item_number = ls_location_selection-item_number
                             schedule_line = ls_location_selection-schedule_line.
          ENDIF.
          IF sy-subrc <> 0.
            APPEND VALUE #(
              type    = 'E'
              message = 'Location selection contains an item or schedule line that is not open' )
              TO rs_prepared-messages.
            RETURN.
          ENDIF.
        ENDLOOP.
      ENDIF.
      DATA(ls_location_result) =
        mo_stock_service->allocate_by_storage_location(
          it_demands              = lt_demands
          iv_protect_safety_stock = iv_protect_safety_stock ).
      rs_prepared-allocations = ls_location_result-allocations.
      rs_prepared-storage_allocations =
        ls_location_result-storage_allocations.
    ENDIF.
    rs_prepared-sales_unit_allocations = build_sales_unit_allocations(
      iv_sales_document = iv_sales_document
      it_order_items    = rs_prepared-order_items
      it_allocations    = rs_prepared-allocations ).
    rs_prepared-is_successful = abap_true.
  ENDMETHOD.

  METHOD subtract_order_reservations.
    DATA lt_reservation_balances TYPE ty_order_reservation_balances.
    DATA lv_remaining_quantity TYPE mard-labst.
    FIELD-SYMBOLS <ls_order_item> TYPE zif_sales_order_api=>ty_item.

    LOOP AT it_reservations INTO DATA(ls_reservation).
      APPEND VALUE #(
        material           = ls_reservation-material
        plant              = ls_reservation-plant
        item_number        = ls_reservation-item_number
        schedule_line      = ls_reservation-schedule_line
        requirement_date   = ls_reservation-requirement_date
        remaining_quantity = ls_reservation-open_quantity )
        TO lt_reservation_balances.
    ENDLOOP.

    LOOP AT lt_reservation_balances ASSIGNING FIELD-SYMBOL(<ls_reservation>)
      WHERE schedule_line IS NOT INITIAL
        AND remaining_quantity > 0.
      lv_remaining_quantity = <ls_reservation>-remaining_quantity.
      LOOP AT ct_order_items ASSIGNING <ls_order_item>
        WHERE item_number = <ls_reservation>-item_number
          AND material = <ls_reservation>-material
          AND plant = <ls_reservation>-plant
          AND schedule_line = <ls_reservation>-schedule_line.
        IF <ls_order_item>-open_base_quantity <= 0.
          CONTINUE.
        ENDIF.
        IF lv_remaining_quantity >= <ls_order_item>-open_base_quantity.
          lv_remaining_quantity = lv_remaining_quantity
            - <ls_order_item>-open_base_quantity.
          CLEAR <ls_order_item>-open_base_quantity.
        ELSE.
          <ls_order_item>-open_base_quantity =
            <ls_order_item>-open_base_quantity - lv_remaining_quantity.
          CLEAR lv_remaining_quantity.
        ENDIF.
      ENDLOOP.
      <ls_reservation>-remaining_quantity = lv_remaining_quantity.
    ENDLOOP.

    LOOP AT lt_reservation_balances ASSIGNING <ls_reservation>
      WHERE requirement_date IS NOT INITIAL
        AND remaining_quantity > 0.
      lv_remaining_quantity = <ls_reservation>-remaining_quantity.
      LOOP AT ct_order_items ASSIGNING <ls_order_item>
        WHERE item_number = <ls_reservation>-item_number
          AND material = <ls_reservation>-material
          AND plant = <ls_reservation>-plant
          AND requested_date = <ls_reservation>-requirement_date.
        IF <ls_order_item>-open_base_quantity <= 0.
          CONTINUE.
        ENDIF.
        IF lv_remaining_quantity >= <ls_order_item>-open_base_quantity.
          lv_remaining_quantity = lv_remaining_quantity
            - <ls_order_item>-open_base_quantity.
          CLEAR <ls_order_item>-open_base_quantity.
        ELSE.
          <ls_order_item>-open_base_quantity =
            <ls_order_item>-open_base_quantity - lv_remaining_quantity.
          CLEAR lv_remaining_quantity.
        ENDIF.
      ENDLOOP.
      <ls_reservation>-remaining_quantity = lv_remaining_quantity.
    ENDLOOP.

    LOOP AT lt_reservation_balances ASSIGNING <ls_reservation>
      WHERE remaining_quantity > 0.
      lv_remaining_quantity = <ls_reservation>-remaining_quantity.
      LOOP AT ct_order_items ASSIGNING <ls_order_item>
        WHERE item_number = <ls_reservation>-item_number
          AND material = <ls_reservation>-material
          AND plant = <ls_reservation>-plant.
        IF <ls_order_item>-open_base_quantity <= 0.
          CONTINUE.
        ENDIF.
        IF lv_remaining_quantity >= <ls_order_item>-open_base_quantity.
          lv_remaining_quantity = lv_remaining_quantity
            - <ls_order_item>-open_base_quantity.
          CLEAR <ls_order_item>-open_base_quantity.
        ELSE.
          <ls_order_item>-open_base_quantity =
            <ls_order_item>-open_base_quantity - lv_remaining_quantity.
          CLEAR lv_remaining_quantity.
        ENDIF.
      ENDLOOP.
      <ls_reservation>-remaining_quantity = lv_remaining_quantity.
    ENDLOOP.
  ENDMETHOD.

  METHOD build_sales_unit_allocations.
    DATA lv_request_id TYPE c LENGTH 30.
    DATA lv_item_found TYPE abap_bool.
    DATA lv_numerator TYPE bapisdit-sales_qty1.
    DATA lv_denominator TYPE bapisdit-sales_qty2.
    DATA ls_order_item TYPE zif_sales_order_api=>ty_item.

    LOOP AT it_allocations INTO DATA(ls_allocation).
      CLEAR lv_item_found.
      LOOP AT it_order_items INTO ls_order_item.
        CLEAR lv_request_id.
        IF ls_order_item-schedule_line IS INITIAL.
          CONCATENATE iv_sales_document ls_order_item-item_number
            INTO lv_request_id SEPARATED BY '/'.
        ELSE.
          CONCATENATE iv_sales_document ls_order_item-item_number
            ls_order_item-schedule_line
            INTO lv_request_id SEPARATED BY '/'.
        ENDIF.
        IF lv_request_id = ls_allocation-request_id.
          lv_item_found = abap_true.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF lv_item_found <> abap_true
          OR ls_order_item-entry_unit IS INITIAL.
        CONTINUE.
      ENDIF.

      IF ls_order_item-entry_unit = ls_order_item-base_unit.
        lv_numerator = 1.
        lv_denominator = 1.
      ELSE.
        lv_numerator = ls_order_item-sales_unit_numerator.
        lv_denominator = ls_order_item-sales_unit_denominator.
        IF lv_numerator <= 0 OR lv_denominator <= 0.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
      ENDIF.

      APPEND VALUE #(
        request_id              = ls_allocation-request_id
        sales_document          = iv_sales_document
        item_number             = ls_order_item-item_number
        schedule_line           = ls_order_item-schedule_line
        material                = ls_order_item-material
        plant                   = ls_order_item-plant
        sales_unit              = ls_order_item-entry_unit
        base_unit               = ls_order_item-base_unit
        requested_quantity      = convert_base_to_sales_unit(
          iv_base_quantity = ls_allocation-requested_quantity
          iv_numerator     = lv_numerator
          iv_denominator   = lv_denominator )
        requested_base_quantity = ls_allocation-requested_quantity
        available_quantity      = convert_base_to_sales_unit(
          iv_base_quantity = ls_allocation-available_quantity
          iv_numerator     = lv_numerator
          iv_denominator   = lv_denominator )
        available_base_quantity = ls_allocation-available_quantity
        allocated_quantity      = convert_base_to_sales_unit(
          iv_base_quantity = ls_allocation-allocated_quantity
          iv_numerator     = lv_numerator
          iv_denominator   = lv_denominator )
        allocated_base_quantity = ls_allocation-allocated_quantity
        shortfall_quantity      = convert_base_to_sales_unit(
          iv_base_quantity = ls_allocation-shortfall_quantity
          iv_numerator     = lv_numerator
          iv_denominator   = lv_denominator )
        shortfall_base_quantity = ls_allocation-shortfall_quantity )
        TO rt_allocations.
    ENDLOOP.
  ENDMETHOD.

  METHOD convert_base_to_sales_unit.
    rv_quantity = CONV mard-labst(
      CONV decfloat34( iv_base_quantity )
      * CONV decfloat34( iv_denominator )
      / CONV decfloat34( iv_numerator ) ).
  ENDMETHOD.

ENDCLASS.
