CLASS zcl_stock_xfer_order_svc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS c_document_type TYPE zif_stock_transfer_order_api=>ty_document_type
      VALUE 'UB'.
    CONSTANTS c_item_category TYPE c LENGTH 1 VALUE 'U'.
    TYPES:
      BEGIN OF ty_source_order_result,
        supplying_plant TYPE mard-werks,
        result          TYPE zif_stock_transfer_order_api=>ty_result,
      END OF ty_source_order_result.
    TYPES ty_source_order_results TYPE STANDARD TABLE OF
      ty_source_order_result WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_multi_order_result,
        receiving_plant TYPE mard-werks,
        orders          TYPE ty_source_order_results,
        is_successful   TYPE abap_bool,
        is_test_run     TYPE abap_bool,
      END OF ty_multi_order_result.
    TYPES:
      BEGIN OF ty_receiving_location,
        receiving_plant       TYPE mard-werks,
        receiving_storage_loc TYPE mard-lgort,
      END OF ty_receiving_location.
    TYPES ty_receiving_locations TYPE STANDARD TABLE OF
      ty_receiving_location WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_plant_pair_order_result,
        supplying_plant TYPE mard-werks,
        receiving_plant TYPE mard-werks,
        result          TYPE zif_stock_transfer_order_api=>ty_result,
      END OF ty_plant_pair_order_result.
    TYPES ty_plant_pair_order_results TYPE STANDARD TABLE OF
      ty_plant_pair_order_result WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_plant_pairs_result,
        orders        TYPE ty_plant_pair_order_results,
        is_successful TYPE abap_bool,
        is_test_run   TYPE abap_bool,
      END OF ty_plant_pairs_result.
    TYPES:
      BEGIN OF ty_sto_deletion_result,
        order_result      TYPE zif_stock_transfer_order_api=>ty_result,
        deletion_messages TYPE zif_stock_transfer_order_api=>ty_messages,
        is_attempted      TYPE abap_bool,
        is_successful     TYPE abap_bool,
        is_test_run       TYPE abap_bool,
        is_deleted        TYPE abap_bool,
      END OF ty_sto_deletion_result.
    TYPES:
      BEGIN OF ty_sto_deletion_pair_result,
        supplying_plant TYPE mard-werks,
        receiving_plant TYPE mard-werks,
        deletion        TYPE ty_sto_deletion_result,
      END OF ty_sto_deletion_pair_result.
    TYPES ty_sto_deletion_pair_results TYPE STANDARD TABLE OF
      ty_sto_deletion_pair_result WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_sto_deletion_pairs_result,
        orders        TYPE ty_sto_deletion_pair_results,
        is_successful TYPE abap_bool,
        is_test_run   TYPE abap_bool,
      END OF ty_sto_deletion_pairs_result.
    TYPES:
      BEGIN OF ty_sto_delivery_completion_result,
        order_result        TYPE zif_stock_transfer_order_api=>ty_result,
        completion_messages TYPE zif_stock_transfer_order_api=>ty_messages,
        is_attempted        TYPE abap_bool,
        is_successful       TYPE abap_bool,
        is_test_run         TYPE abap_bool,
        is_completed        TYPE abap_bool,
      END OF ty_sto_delivery_completion_result.
    TYPES:
      BEGIN OF ty_sto_delivery_completion_pair,
        supplying_plant     TYPE mard-werks,
        receiving_plant     TYPE mard-werks,
        delivery_completion TYPE ty_sto_delivery_completion_result,
      END OF ty_sto_delivery_completion_pair.
    TYPES ty_sto_delivery_completion_pairs TYPE STANDARD TABLE OF
      ty_sto_delivery_completion_pair WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_sto_delivery_completions_result,
        orders        TYPE ty_sto_delivery_completion_pairs,
        is_successful TYPE abap_bool,
        is_test_run   TYPE abap_bool,
      END OF ty_sto_delivery_completions_result.

    METHODS constructor
      IMPORTING
        io_api TYPE REF TO zif_stock_transfer_order_api.

    METHODS create_from_allocation
      IMPORTING
        is_allocation            TYPE zcl_stock_service=>ty_unit_date_plant_result
        iv_supplying_plant       TYPE mard-werks
        iv_receiving_plant       TYPE mard-werks
        iv_receiving_storage_loc TYPE mard-lgort OPTIONAL
        iv_company_code          TYPE zif_stock_transfer_order_api=>ty_company_code
        iv_purchasing_org        TYPE zif_stock_transfer_order_api=>ty_purchasing_org
        iv_purchasing_group      TYPE zif_stock_transfer_order_api=>ty_purchasing_group
        iv_allow_partial         TYPE abap_bool DEFAULT abap_false
        iv_test_run              TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)         TYPE zif_stock_transfer_order_api=>ty_result
      RAISING
        zcx_invalid_stock_request.

    METHODS create_from_batch_allocation
      IMPORTING
        is_allocation            TYPE zcl_stock_service=>ty_unit_plant_batch_result
        iv_supplying_plant       TYPE mard-werks
        iv_receiving_plant       TYPE mard-werks
        iv_delivery_date         TYPE d
        iv_receiving_storage_loc TYPE mard-lgort OPTIONAL
        iv_company_code          TYPE zif_stock_transfer_order_api=>ty_company_code
        iv_purchasing_org        TYPE zif_stock_transfer_order_api=>ty_purchasing_org
        iv_purchasing_group      TYPE zif_stock_transfer_order_api=>ty_purchasing_group
        iv_allow_partial         TYPE abap_bool DEFAULT abap_false
        iv_test_run              TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)         TYPE zif_stock_transfer_order_api=>ty_result
      RAISING
        zcx_invalid_stock_request.

    METHODS create_from_source_plants
      IMPORTING
        is_allocation            TYPE zcl_stock_service=>ty_unit_date_plant_result
        iv_receiving_plant       TYPE mard-werks
        iv_receiving_storage_loc TYPE mard-lgort OPTIONAL
        iv_company_code          TYPE zif_stock_transfer_order_api=>ty_company_code
        iv_purchasing_org        TYPE zif_stock_transfer_order_api=>ty_purchasing_org
        iv_purchasing_group      TYPE zif_stock_transfer_order_api=>ty_purchasing_group
        iv_allow_partial         TYPE abap_bool DEFAULT abap_false
        iv_test_run              TYPE abap_bool DEFAULT abap_false
        iv_atomic                TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)         TYPE ty_multi_order_result
      RAISING
        zcx_invalid_stock_request.

    METHODS create_from_atp_source_plants
      IMPORTING
        is_allocation            TYPE zcl_stock_service=>ty_plant_date_atp_result
        iv_receiving_plant       TYPE mard-werks
        iv_receiving_storage_loc TYPE mard-lgort OPTIONAL
        iv_company_code          TYPE zif_stock_transfer_order_api=>ty_company_code
        iv_purchasing_org        TYPE zif_stock_transfer_order_api=>ty_purchasing_org
        iv_purchasing_group      TYPE zif_stock_transfer_order_api=>ty_purchasing_group
        iv_allow_partial         TYPE abap_bool DEFAULT abap_false
        iv_test_run              TYPE abap_bool DEFAULT abap_false
        iv_atomic                TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)         TYPE ty_multi_order_result
      RAISING
        zcx_invalid_stock_request.

    METHODS create_for_atp_plant_pairs
      IMPORTING
        is_allocation          TYPE zcl_stock_service=>ty_plant_date_atp_result
        it_receiving_locations TYPE ty_receiving_locations OPTIONAL
        iv_company_code        TYPE zif_stock_transfer_order_api=>ty_company_code
        iv_purchasing_org      TYPE zif_stock_transfer_order_api=>ty_purchasing_org
        iv_purchasing_group    TYPE zif_stock_transfer_order_api=>ty_purchasing_group
        iv_allow_partial       TYPE abap_bool DEFAULT abap_false
        iv_test_run            TYPE abap_bool DEFAULT abap_false
        iv_atomic              TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)       TYPE ty_plant_pairs_result
      RAISING
        zcx_invalid_stock_request.

    METHODS create_for_all_plant_pairs
      IMPORTING
        is_allocation          TYPE zcl_stock_service=>ty_unit_date_plant_result
        it_receiving_locations TYPE ty_receiving_locations OPTIONAL
        iv_company_code        TYPE zif_stock_transfer_order_api=>ty_company_code
        iv_purchasing_org      TYPE zif_stock_transfer_order_api=>ty_purchasing_org
        iv_purchasing_group    TYPE zif_stock_transfer_order_api=>ty_purchasing_group
        iv_allow_partial       TYPE abap_bool DEFAULT abap_false
        iv_test_run            TYPE abap_bool DEFAULT abap_false
        iv_atomic              TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)       TYPE ty_plant_pairs_result
      RAISING
        zcx_invalid_stock_request.

    METHODS create_date_loc_pairs
      IMPORTING
        is_allocation          TYPE zcl_stock_service=>ty_unit_date_plant_location_result
        it_receiving_locations TYPE ty_receiving_locations OPTIONAL
        iv_company_code        TYPE zif_stock_transfer_order_api=>ty_company_code
        iv_purchasing_org      TYPE zif_stock_transfer_order_api=>ty_purchasing_org
        iv_purchasing_group    TYPE zif_stock_transfer_order_api=>ty_purchasing_group
        iv_allow_partial       TYPE abap_bool DEFAULT abap_false
        iv_test_run            TYPE abap_bool DEFAULT abap_false
        iv_atomic              TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)       TYPE ty_plant_pairs_result
      RAISING
        zcx_invalid_stock_request.

    METHODS create_date_loc_atp_pairs
      IMPORTING
        is_allocation          TYPE zcl_stock_service=>ty_plant_date_loc_atp_result
        it_receiving_locations TYPE ty_receiving_locations OPTIONAL
        iv_company_code        TYPE zif_stock_transfer_order_api=>ty_company_code
        iv_purchasing_org      TYPE zif_stock_transfer_order_api=>ty_purchasing_org
        iv_purchasing_group    TYPE zif_stock_transfer_order_api=>ty_purchasing_group
        iv_allow_partial       TYPE abap_bool DEFAULT abap_false
        iv_test_run            TYPE abap_bool DEFAULT abap_false
        iv_atomic              TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)       TYPE ty_plant_pairs_result
      RAISING
        zcx_invalid_stock_request.

    METHODS create_for_batch_pairs
      IMPORTING
        is_allocation          TYPE zcl_stock_service=>ty_unit_plant_batch_result
        iv_delivery_date       TYPE d
        it_receiving_locations TYPE ty_receiving_locations OPTIONAL
        iv_company_code        TYPE zif_stock_transfer_order_api=>ty_company_code
        iv_purchasing_org      TYPE zif_stock_transfer_order_api=>ty_purchasing_org
        iv_purchasing_group    TYPE zif_stock_transfer_order_api=>ty_purchasing_group
        iv_allow_partial       TYPE abap_bool DEFAULT abap_false
        iv_test_run            TYPE abap_bool DEFAULT abap_false
        iv_atomic              TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)       TYPE ty_plant_pairs_result
      RAISING
        zcx_invalid_stock_request.

    METHODS create_for_atp_batch_pairs
      IMPORTING
        is_allocation          TYPE zcl_stock_service=>ty_plant_batch_atp_allocation_result
        iv_delivery_date       TYPE d
        it_receiving_locations TYPE ty_receiving_locations OPTIONAL
        iv_company_code        TYPE zif_stock_transfer_order_api=>ty_company_code
        iv_purchasing_org      TYPE zif_stock_transfer_order_api=>ty_purchasing_org
        iv_purchasing_group    TYPE zif_stock_transfer_order_api=>ty_purchasing_group
        iv_allow_partial       TYPE abap_bool DEFAULT abap_false
        iv_test_run            TYPE abap_bool DEFAULT abap_false
        iv_atomic              TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)       TYPE ty_plant_pairs_result
      RAISING
        zcx_invalid_stock_request.

    METHODS create_dated_batch_pairs
      IMPORTING
        is_allocation          TYPE zcl_stock_service=>ty_unit_date_plant_batch_result
        it_receiving_locations TYPE ty_receiving_locations OPTIONAL
        iv_company_code        TYPE zif_stock_transfer_order_api=>ty_company_code
        iv_purchasing_org      TYPE zif_stock_transfer_order_api=>ty_purchasing_org
        iv_purchasing_group    TYPE zif_stock_transfer_order_api=>ty_purchasing_group
        iv_allow_partial       TYPE abap_bool DEFAULT abap_false
        iv_test_run            TYPE abap_bool DEFAULT abap_false
        iv_atomic              TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)       TYPE ty_plant_pairs_result
      RAISING
        zcx_invalid_stock_request.

    METHODS create_dated_batch_atp_pairs
      IMPORTING
        is_allocation          TYPE zcl_stock_service=>ty_plant_date_batch_atp_result
        it_receiving_locations TYPE ty_receiving_locations OPTIONAL
        iv_company_code        TYPE zif_stock_transfer_order_api=>ty_company_code
        iv_purchasing_org      TYPE zif_stock_transfer_order_api=>ty_purchasing_org
        iv_purchasing_group    TYPE zif_stock_transfer_order_api=>ty_purchasing_group
        iv_allow_partial       TYPE abap_bool DEFAULT abap_false
        iv_test_run            TYPE abap_bool DEFAULT abap_false
        iv_atomic              TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)       TYPE ty_plant_pairs_result
      RAISING
        zcx_invalid_stock_request.

    METHODS create_for_fefo_pairs
      IMPORTING
        is_allocation          TYPE zcl_stock_service=>ty_unit_date_plant_fefo_result
        it_receiving_locations TYPE ty_receiving_locations OPTIONAL
        iv_company_code        TYPE zif_stock_transfer_order_api=>ty_company_code
        iv_purchasing_org      TYPE zif_stock_transfer_order_api=>ty_purchasing_org
        iv_purchasing_group    TYPE zif_stock_transfer_order_api=>ty_purchasing_group
        iv_allow_partial       TYPE abap_bool DEFAULT abap_false
        iv_test_run            TYPE abap_bool DEFAULT abap_false
        iv_atomic              TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)       TYPE ty_plant_pairs_result
      RAISING
        zcx_invalid_stock_request.

    METHODS create_for_atp_fefo_pairs
      IMPORTING
        is_allocation          TYPE zcl_stock_service=>ty_plant_fefo_date_atp_result
        it_receiving_locations TYPE ty_receiving_locations OPTIONAL
        iv_company_code        TYPE zif_stock_transfer_order_api=>ty_company_code
        iv_purchasing_org      TYPE zif_stock_transfer_order_api=>ty_purchasing_org
        iv_purchasing_group    TYPE zif_stock_transfer_order_api=>ty_purchasing_group
        iv_allow_partial       TYPE abap_bool DEFAULT abap_false
        iv_test_run            TYPE abap_bool DEFAULT abap_false
        iv_atomic              TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)       TYPE ty_plant_pairs_result
      RAISING
        zcx_invalid_stock_request.

    METHODS create_for_fefo_atp_pairs
      IMPORTING
        is_allocation          TYPE zcl_stock_service=>ty_plant_fefo_atp_allocation_result
        iv_delivery_date       TYPE d
        it_receiving_locations TYPE ty_receiving_locations OPTIONAL
        iv_company_code        TYPE zif_stock_transfer_order_api=>ty_company_code
        iv_purchasing_org      TYPE zif_stock_transfer_order_api=>ty_purchasing_org
        iv_purchasing_group    TYPE zif_stock_transfer_order_api=>ty_purchasing_group
        iv_allow_partial       TYPE abap_bool DEFAULT abap_false
        iv_test_run            TYPE abap_bool DEFAULT abap_false
        iv_atomic              TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)       TYPE ty_plant_pairs_result
      RAISING
        zcx_invalid_stock_request.

    METHODS mark_sto_for_deletion
      IMPORTING
        is_order         TYPE zif_stock_transfer_order_api=>ty_result
        iv_test_run      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE ty_sto_deletion_result
      RAISING
        zcx_invalid_stock_request.

    METHODS mark_sto_pairs_for_deletion
      IMPORTING
        is_orders        TYPE ty_plant_pairs_result
        iv_atomic        TYPE abap_bool DEFAULT abap_false
        iv_test_run      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE ty_sto_deletion_pairs_result
      RAISING
        zcx_invalid_stock_request.

    METHODS mark_sto_delivery_complete
      IMPORTING
        is_order         TYPE zif_stock_transfer_order_api=>ty_result
        iv_test_run      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE ty_sto_delivery_completion_result
      RAISING
        zcx_invalid_stock_request.

    METHODS mark_sto_pairs_deliv_complete
      IMPORTING
        is_orders        TYPE ty_plant_pairs_result
        iv_atomic        TYPE abap_bool DEFAULT abap_false
        iv_test_run      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE ty_sto_delivery_completions_result
      RAISING
        zcx_invalid_stock_request.

  PRIVATE SECTION.
    TYPES ty_source_plants TYPE STANDARD TABLE OF mard-werks WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_plant_pair,
        supplying_plant TYPE mard-werks,
        receiving_plant TYPE mard-werks,
      END OF ty_plant_pair.
    TYPES ty_plant_pairs TYPE STANDARD TABLE OF ty_plant_pair
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_prepared_order,
        supplying_plant TYPE mard-werks,
        request         TYPE zif_stock_transfer_order_api=>ty_request,
      END OF ty_prepared_order.
    TYPES ty_prepared_orders TYPE STANDARD TABLE OF ty_prepared_order
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_prepared_pair_order,
        supplying_plant TYPE mard-werks,
        receiving_plant TYPE mard-werks,
        request         TYPE zif_stock_transfer_order_api=>ty_request,
      END OF ty_prepared_pair_order.
    TYPES ty_prepared_pair_orders TYPE STANDARD TABLE OF
      ty_prepared_pair_order WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_prepared_deletion,
        result_index TYPE i,
        order_result TYPE zif_stock_transfer_order_api=>ty_result,
        item_numbers TYPE zif_stock_transfer_order_api=>ty_item_numbers,
      END OF ty_prepared_deletion.
    TYPES ty_prepared_deletions TYPE STANDARD TABLE OF
      ty_prepared_deletion WITH EMPTY KEY.
    TYPES ty_prepared_completions TYPE STANDARD TABLE OF
      ty_prepared_deletion WITH EMPTY KEY.

    METHODS build_request
      IMPORTING
        is_allocation            TYPE zcl_stock_service=>ty_unit_date_plant_result
        iv_supplying_plant       TYPE mard-werks
        iv_receiving_plant       TYPE mard-werks
        iv_receiving_storage_loc TYPE mard-lgort
        iv_company_code          TYPE zif_stock_transfer_order_api=>ty_company_code
        iv_purchasing_org        TYPE zif_stock_transfer_order_api=>ty_purchasing_org
        iv_purchasing_group      TYPE zif_stock_transfer_order_api=>ty_purchasing_group
        iv_allow_partial         TYPE abap_bool
        iv_test_run              TYPE abap_bool
      RETURNING
        VALUE(rs_request)        TYPE zif_stock_transfer_order_api=>ty_request
      RAISING
        zcx_invalid_stock_request.

    METHODS build_date_loc_request
      IMPORTING
        is_allocation            TYPE zcl_stock_service=>ty_unit_date_plant_location_result
        iv_supplying_plant       TYPE mard-werks
        iv_receiving_plant       TYPE mard-werks
        iv_receiving_storage_loc TYPE mard-lgort
        iv_company_code          TYPE zif_stock_transfer_order_api=>ty_company_code
        iv_purchasing_org        TYPE zif_stock_transfer_order_api=>ty_purchasing_org
        iv_purchasing_group      TYPE zif_stock_transfer_order_api=>ty_purchasing_group
        iv_allow_partial         TYPE abap_bool
        iv_test_run              TYPE abap_bool
      RETURNING
        VALUE(rs_request)        TYPE zif_stock_transfer_order_api=>ty_request
      RAISING
        zcx_invalid_stock_request.

    METHODS validate_delivery_date
      IMPORTING
        iv_date TYPE d
      RAISING
        zcx_invalid_stock_request.

    METHODS build_batch_request
      IMPORTING
        is_allocation            TYPE zcl_stock_service=>ty_unit_plant_batch_result
        iv_supplying_plant       TYPE mard-werks
        iv_receiving_plant       TYPE mard-werks
        iv_delivery_date         TYPE d
        iv_receiving_storage_loc TYPE mard-lgort
        iv_company_code          TYPE zif_stock_transfer_order_api=>ty_company_code
        iv_purchasing_org        TYPE zif_stock_transfer_order_api=>ty_purchasing_org
        iv_purchasing_group      TYPE zif_stock_transfer_order_api=>ty_purchasing_group
        iv_allow_partial         TYPE abap_bool
        iv_test_run              TYPE abap_bool
      RETURNING
        VALUE(rs_request)        TYPE zif_stock_transfer_order_api=>ty_request
      RAISING
        zcx_invalid_stock_request.

    METHODS build_fefo_request
      IMPORTING
        is_allocation            TYPE zcl_stock_service=>ty_unit_date_plant_fefo_result
        iv_supplying_plant       TYPE mard-werks
        iv_receiving_plant       TYPE mard-werks
        iv_receiving_storage_loc TYPE mard-lgort
        iv_company_code          TYPE zif_stock_transfer_order_api=>ty_company_code
        iv_purchasing_org        TYPE zif_stock_transfer_order_api=>ty_purchasing_org
        iv_purchasing_group      TYPE zif_stock_transfer_order_api=>ty_purchasing_group
        iv_allow_partial         TYPE abap_bool
        iv_test_run              TYPE abap_bool
      RETURNING
        VALUE(rs_request)        TYPE zif_stock_transfer_order_api=>ty_request
      RAISING
        zcx_invalid_stock_request.

    METHODS execute_pair_orders
      IMPORTING
        it_prepared_orders TYPE ty_prepared_pair_orders
        iv_test_run        TYPE abap_bool
        iv_atomic          TYPE abap_bool
      RETURNING
        VALUE(rs_result)   TYPE ty_plant_pairs_result.

    METHODS validate_atp_source_splits
      IMPORTING
        is_allocation      TYPE zcl_stock_service=>ty_plant_date_atp_result
        iv_receiving_plant TYPE mard-werks OPTIONAL
      RAISING
        zcx_invalid_stock_request.

    METHODS validate_fefo_atp
      IMPORTING
        is_allocation TYPE zcl_stock_service=>ty_plant_fefo_atp_allocation_result
      RAISING
        zcx_invalid_stock_request.

    METHODS validate_batch_pair_totals
      IMPORTING
        is_allocation TYPE zcl_stock_service=>ty_unit_plant_batch_result
      RAISING
        zcx_invalid_stock_request.

    METHODS validate_plant_pair_totals
      IMPORTING
        is_allocation TYPE zcl_stock_service=>ty_unit_date_plant_result
      RAISING
        zcx_invalid_stock_request.

    METHODS validate_date_loc_pair_totals
      IMPORTING
        is_allocation TYPE zcl_stock_service=>ty_unit_date_plant_location_result
      RAISING
        zcx_invalid_stock_request.

    METHODS validate_fefo_pair_totals
      IMPORTING
        is_allocation TYPE zcl_stock_service=>ty_unit_date_plant_fefo_result
      RAISING
        zcx_invalid_stock_request.

    METHODS validate_batch_atp
      IMPORTING
        is_allocation TYPE zcl_stock_service=>ty_plant_batch_atp_allocation_result
      RAISING
        zcx_invalid_stock_request.

    METHODS map_dated_batch_fefo
      IMPORTING
        is_allocation    TYPE zcl_stock_service=>ty_unit_date_plant_batch_result
      RETURNING
        VALUE(rs_result) TYPE zcl_stock_service=>ty_unit_date_plant_fefo_result.

    METHODS complete_write
      IMPORTING
        is_request       TYPE zif_stock_transfer_order_api=>ty_request
        is_result        TYPE zif_stock_transfer_order_api=>ty_result
        iv_defer_commit  TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE zif_stock_transfer_order_api=>ty_result.

    METHODS complete_deletion
      IMPORTING
        is_order         TYPE zif_stock_transfer_order_api=>ty_result
        it_item_numbers  TYPE zif_stock_transfer_order_api=>ty_item_numbers
        iv_defer_commit  TYPE abap_bool DEFAULT abap_false
        iv_test_run      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE ty_sto_deletion_result.

    METHODS complete_delivery_mark
      IMPORTING
        is_order         TYPE zif_stock_transfer_order_api=>ty_result
        it_item_numbers  TYPE zif_stock_transfer_order_api=>ty_item_numbers
        iv_defer_commit  TYPE abap_bool DEFAULT abap_false
        iv_test_run      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE ty_sto_delivery_completion_result.

    DATA mo_api TYPE REF TO zif_stock_transfer_order_api.
ENDCLASS.

CLASS zcl_stock_xfer_order_svc IMPLEMENTATION.

  METHOD constructor.
    mo_api = io_api.
  ENDMETHOD.

  METHOD create_from_allocation.
    validate_plant_pair_totals( is_allocation = is_allocation ).

    DATA(ls_request) = build_request(
      is_allocation            = is_allocation
      iv_supplying_plant       = iv_supplying_plant
      iv_receiving_plant       = iv_receiving_plant
      iv_receiving_storage_loc = iv_receiving_storage_loc
      iv_company_code          = iv_company_code
      iv_purchasing_org        = iv_purchasing_org
      iv_purchasing_group      = iv_purchasing_group
      iv_allow_partial         = iv_allow_partial
      iv_test_run              = iv_test_run ).

    rs_result = complete_write(
      is_request = ls_request
      is_result  = mo_api->create_order( ls_request ) ).
    rs_result-submitted_items = ls_request-items.
  ENDMETHOD.

  METHOD create_from_batch_allocation.
    validate_batch_pair_totals( is_allocation = is_allocation ).

    DATA(ls_request) = build_batch_request(
      is_allocation            = is_allocation
      iv_supplying_plant       = iv_supplying_plant
      iv_receiving_plant       = iv_receiving_plant
      iv_delivery_date         = iv_delivery_date
      iv_receiving_storage_loc = iv_receiving_storage_loc
      iv_company_code          = iv_company_code
      iv_purchasing_org        = iv_purchasing_org
      iv_purchasing_group      = iv_purchasing_group
      iv_allow_partial         = iv_allow_partial
      iv_test_run              = iv_test_run ).

    rs_result = complete_write(
      is_request = ls_request
      is_result  = mo_api->create_order( ls_request ) ).
    rs_result-submitted_items = ls_request-items.
  ENDMETHOD.

  METHOD create_from_source_plants.
    DATA lt_source_plants TYPE ty_source_plants.
    DATA lt_prepared_orders TYPE ty_prepared_orders.

    validate_plant_pair_totals( is_allocation = is_allocation ).

    IF iv_atomic <> abap_true AND iv_atomic <> abap_false.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT is_allocation-plant_allocations
        INTO DATA(ls_source_allocation).
      IF ls_source_allocation-allocation-target_plant
            <> iv_receiving_plant
          OR ls_source_allocation-allocation-allocated_quantity <= 0.
        CONTINUE.
      ENDIF.
      IF ls_source_allocation-allocation-source_plant IS INITIAL
          OR ls_source_allocation-allocation-source_plant
            = iv_receiving_plant.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      READ TABLE lt_source_plants
        WITH KEY table_line =
          ls_source_allocation-allocation-source_plant
        TRANSPORTING NO FIELDS.
      IF sy-subrc <> 0.
        APPEND ls_source_allocation-allocation-source_plant
          TO lt_source_plants.
      ENDIF.
    ENDLOOP.

    IF lt_source_plants IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT lt_source_plants INTO DATA(lv_supplying_plant).
      DATA(ls_request) = build_request(
        is_allocation            = is_allocation
        iv_supplying_plant       = lv_supplying_plant
        iv_receiving_plant       = iv_receiving_plant
        iv_receiving_storage_loc = iv_receiving_storage_loc
        iv_company_code          = iv_company_code
        iv_purchasing_org        = iv_purchasing_org
        iv_purchasing_group      = iv_purchasing_group
        iv_allow_partial         = iv_allow_partial
        iv_test_run              = iv_test_run ).
      APPEND VALUE #(
        supplying_plant = lv_supplying_plant
        request         = ls_request ) TO lt_prepared_orders.
    ENDLOOP.

    rs_result-receiving_plant = iv_receiving_plant.
    rs_result-is_test_run = iv_test_run.
    rs_result-is_successful = abap_true.
    LOOP AT lt_prepared_orders INTO DATA(ls_prepared_order).
      DATA(ls_order_result) = complete_write(
        is_request      = ls_prepared_order-request
        is_result       = mo_api->create_order(
          ls_prepared_order-request )
        iv_defer_commit = iv_atomic ).
      ls_order_result-submitted_items =
        ls_prepared_order-request-items.
      APPEND VALUE #(
        supplying_plant = ls_prepared_order-supplying_plant
        result          = ls_order_result ) TO rs_result-orders.
      IF ls_order_result-is_successful <> abap_true.
        rs_result-is_successful = abap_false.
        IF iv_atomic = abap_true.
          LOOP AT rs_result-orders ASSIGNING FIELD-SYMBOL(<ls_order_result>).
            <ls_order_result>-result-is_successful = abap_false.
            <ls_order_result>-result-is_committed = abap_false.
          ENDLOOP.
          EXIT.
        ENDIF.
      ENDIF.
    ENDLOOP.

    IF iv_atomic = abap_true
        AND rs_result-is_successful = abap_true
        AND iv_test_run = abap_false.
      DATA(ls_commit_result) = mo_api->commit( ).
      IF ls_commit_result-is_successful = abap_true.
        LOOP AT rs_result-orders ASSIGNING <ls_order_result>.
          <ls_order_result>-result-is_committed = abap_true.
        ENDLOOP.
      ELSE.
        mo_api->rollback( ).
        LOOP AT rs_result-orders ASSIGNING <ls_order_result>.
          <ls_order_result>-result-is_successful = abap_false.
          <ls_order_result>-result-is_committed = abap_false.
        ENDLOOP.
        READ TABLE rs_result-orders ASSIGNING <ls_order_result>
          INDEX lines( rs_result-orders ).
        IF sy-subrc = 0.
          APPEND ls_commit_result-message
            TO <ls_order_result>-result-messages.
        ENDIF.
        rs_result-is_successful = abap_false.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD create_from_atp_source_plants.
    IF iv_receiving_plant IS INITIAL
        OR ( iv_atomic <> abap_true
          AND iv_atomic <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    validate_atp_source_splits(
      is_allocation      = is_allocation
      iv_receiving_plant = iv_receiving_plant ).

    rs_result = create_from_source_plants(
      is_allocation            = is_allocation-local_estimate
      iv_receiving_plant       = iv_receiving_plant
      iv_receiving_storage_loc = iv_receiving_storage_loc
      iv_company_code          = iv_company_code
      iv_purchasing_org        = iv_purchasing_org
      iv_purchasing_group      = iv_purchasing_group
      iv_allow_partial         = iv_allow_partial
      iv_test_run              = iv_test_run
      iv_atomic                = iv_atomic ).
  ENDMETHOD.

  METHOD create_for_atp_plant_pairs.
    validate_atp_source_splits( is_allocation = is_allocation ).

    rs_result = create_for_all_plant_pairs(
      is_allocation          = is_allocation-local_estimate
      it_receiving_locations = it_receiving_locations
      iv_company_code        = iv_company_code
      iv_purchasing_org      = iv_purchasing_org
      iv_purchasing_group    = iv_purchasing_group
      iv_allow_partial       = iv_allow_partial
      iv_test_run            = iv_test_run
      iv_atomic              = iv_atomic ).
  ENDMETHOD.

  METHOD create_for_all_plant_pairs.
    DATA lt_plant_pairs TYPE ty_plant_pairs.
    DATA lt_prepared_orders TYPE ty_prepared_pair_orders.
    DATA lt_location_targets TYPE ty_source_plants.
    DATA lv_receiving_storage_loc TYPE mard-lgort.

    IF iv_company_code IS INITIAL
        OR iv_purchasing_org IS INITIAL
        OR iv_purchasing_group IS INITIAL
        OR ( iv_allow_partial <> abap_true
          AND iv_allow_partial <> abap_false )
        OR ( iv_test_run <> abap_true
          AND iv_test_run <> abap_false )
        OR ( iv_atomic <> abap_true
          AND iv_atomic <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    validate_plant_pair_totals( is_allocation = is_allocation ).

    IF iv_allow_partial = abap_false.
      LOOP AT is_allocation-allocations
          INTO DATA(ls_demand_allocation).
        IF ls_demand_allocation-allocation-shortfall_quantity > 0.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
      ENDLOOP.
    ENDIF.

    LOOP AT is_allocation-plant_allocations
        INTO DATA(ls_source_allocation).
      IF ls_source_allocation-allocation-allocated_quantity <= 0.
        CONTINUE.
      ENDIF.
      IF ls_source_allocation-allocation-source_plant IS INITIAL
          OR ls_source_allocation-allocation-target_plant IS INITIAL
          OR ls_source_allocation-allocation-source_plant
            = ls_source_allocation-allocation-target_plant.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      READ TABLE lt_plant_pairs
        WITH KEY supplying_plant =
            ls_source_allocation-allocation-source_plant
          receiving_plant =
            ls_source_allocation-allocation-target_plant
        TRANSPORTING NO FIELDS.
      IF sy-subrc <> 0.
        APPEND VALUE #(
          supplying_plant =
            ls_source_allocation-allocation-source_plant
          receiving_plant =
            ls_source_allocation-allocation-target_plant )
          TO lt_plant_pairs.
      ENDIF.
    ENDLOOP.

    IF lt_plant_pairs IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT it_receiving_locations
        INTO DATA(ls_receiving_location).
      IF ls_receiving_location-receiving_plant IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      READ TABLE lt_plant_pairs
        WITH KEY receiving_plant =
          ls_receiving_location-receiving_plant
        TRANSPORTING NO FIELDS.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      READ TABLE lt_location_targets
        WITH KEY table_line =
          ls_receiving_location-receiving_plant
        TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      APPEND ls_receiving_location-receiving_plant
        TO lt_location_targets.
    ENDLOOP.

    LOOP AT lt_plant_pairs INTO DATA(ls_plant_pair).
      CLEAR lv_receiving_storage_loc.
      READ TABLE it_receiving_locations
        INTO ls_receiving_location
        WITH KEY receiving_plant = ls_plant_pair-receiving_plant.
      IF sy-subrc = 0.
        lv_receiving_storage_loc =
          ls_receiving_location-receiving_storage_loc.
      ENDIF.

      DATA(ls_request) = build_request(
        is_allocation            = is_allocation
        iv_supplying_plant       = ls_plant_pair-supplying_plant
        iv_receiving_plant       = ls_plant_pair-receiving_plant
        iv_receiving_storage_loc = lv_receiving_storage_loc
        iv_company_code          = iv_company_code
        iv_purchasing_org        = iv_purchasing_org
        iv_purchasing_group      = iv_purchasing_group
        iv_allow_partial         = iv_allow_partial
        iv_test_run              = iv_test_run ).
      APPEND VALUE #(
        supplying_plant = ls_plant_pair-supplying_plant
        receiving_plant = ls_plant_pair-receiving_plant
        request         = ls_request ) TO lt_prepared_orders.
    ENDLOOP.

    rs_result = execute_pair_orders(
      it_prepared_orders = lt_prepared_orders
      iv_test_run        = iv_test_run
      iv_atomic          = iv_atomic ).
  ENDMETHOD.

  METHOD create_date_loc_pairs.
    DATA lt_plant_pairs TYPE ty_plant_pairs.
    DATA lt_prepared_orders TYPE ty_prepared_pair_orders.
    DATA lt_location_targets TYPE ty_source_plants.
    DATA lv_receiving_storage_loc TYPE mard-lgort.

    IF iv_company_code IS INITIAL
        OR iv_purchasing_org IS INITIAL
        OR iv_purchasing_group IS INITIAL
        OR ( iv_allow_partial <> abap_true
          AND iv_allow_partial <> abap_false )
        OR ( iv_test_run <> abap_true
          AND iv_test_run <> abap_false )
        OR ( iv_atomic <> abap_true
          AND iv_atomic <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    validate_date_loc_pair_totals( is_allocation = is_allocation ).
    IF iv_allow_partial = abap_false.
      LOOP AT is_allocation-allocations
          INTO DATA(ls_demand_allocation).
        IF ls_demand_allocation-allocation-shortfall_quantity > 0.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
      ENDLOOP.
    ENDIF.

    LOOP AT is_allocation-plant_allocations
        INTO DATA(ls_source_allocation).
      READ TABLE lt_plant_pairs
        WITH KEY supplying_plant =
            ls_source_allocation-allocation-source_plant
          receiving_plant =
            ls_source_allocation-allocation-target_plant
        TRANSPORTING NO FIELDS.
      IF sy-subrc <> 0.
        APPEND VALUE #(
          supplying_plant =
            ls_source_allocation-allocation-source_plant
          receiving_plant =
            ls_source_allocation-allocation-target_plant )
          TO lt_plant_pairs.
      ENDIF.
    ENDLOOP.
    IF lt_plant_pairs IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT it_receiving_locations
        INTO DATA(ls_receiving_location).
      IF ls_receiving_location-receiving_plant IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      READ TABLE lt_plant_pairs
        WITH KEY receiving_plant =
          ls_receiving_location-receiving_plant
        TRANSPORTING NO FIELDS.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      READ TABLE lt_location_targets
        WITH KEY table_line =
          ls_receiving_location-receiving_plant
        TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      APPEND ls_receiving_location-receiving_plant
        TO lt_location_targets.
    ENDLOOP.

    LOOP AT lt_plant_pairs INTO DATA(ls_plant_pair).
      CLEAR lv_receiving_storage_loc.
      READ TABLE it_receiving_locations
        INTO ls_receiving_location
        WITH KEY receiving_plant = ls_plant_pair-receiving_plant.
      IF sy-subrc = 0.
        lv_receiving_storage_loc =
          ls_receiving_location-receiving_storage_loc.
      ENDIF.

      DATA(ls_request) = build_date_loc_request(
        is_allocation            = is_allocation
        iv_supplying_plant       = ls_plant_pair-supplying_plant
        iv_receiving_plant       = ls_plant_pair-receiving_plant
        iv_receiving_storage_loc = lv_receiving_storage_loc
        iv_company_code          = iv_company_code
        iv_purchasing_org        = iv_purchasing_org
        iv_purchasing_group      = iv_purchasing_group
        iv_allow_partial         = iv_allow_partial
        iv_test_run              = iv_test_run ).
      APPEND VALUE #(
        supplying_plant = ls_plant_pair-supplying_plant
        receiving_plant = ls_plant_pair-receiving_plant
        request         = ls_request ) TO lt_prepared_orders.
    ENDLOOP.

    rs_result = execute_pair_orders(
      it_prepared_orders = lt_prepared_orders
      iv_test_run        = iv_test_run
      iv_atomic          = iv_atomic ).
  ENDMETHOD.

  METHOD create_date_loc_atp_pairs.
    DATA ls_plant_atp_allocation TYPE
      zcl_stock_service=>ty_plant_date_atp_result.

    ls_plant_atp_allocation-atp_checks = is_allocation-atp_checks.
    ls_plant_atp_allocation-local_estimate-allocations =
      CORRESPONDING #( is_allocation-local_estimate-allocations ).
    ls_plant_atp_allocation-local_estimate-plant_allocations =
      CORRESPONDING #( is_allocation-local_estimate-plant_allocations ).
    validate_atp_source_splits(
      is_allocation = ls_plant_atp_allocation ).

    rs_result = create_date_loc_pairs(
      is_allocation          = is_allocation-local_estimate
      it_receiving_locations = it_receiving_locations
      iv_company_code        = iv_company_code
      iv_purchasing_org      = iv_purchasing_org
      iv_purchasing_group    = iv_purchasing_group
      iv_allow_partial       = iv_allow_partial
      iv_test_run            = iv_test_run
      iv_atomic              = iv_atomic ).
  ENDMETHOD.

  METHOD create_for_batch_pairs.
    DATA lt_plant_pairs TYPE ty_plant_pairs.
    DATA lt_prepared_orders TYPE ty_prepared_pair_orders.
    DATA lt_location_targets TYPE ty_source_plants.
    DATA lv_receiving_storage_loc TYPE mard-lgort.

    IF iv_delivery_date IS INITIAL
        OR iv_company_code IS INITIAL
        OR iv_purchasing_org IS INITIAL
        OR iv_purchasing_group IS INITIAL
        OR ( iv_allow_partial <> abap_true
          AND iv_allow_partial <> abap_false )
        OR ( iv_test_run <> abap_true
          AND iv_test_run <> abap_false )
        OR ( iv_atomic <> abap_true
          AND iv_atomic <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    validate_batch_pair_totals( is_allocation = is_allocation ).

    IF iv_allow_partial = abap_false.
      LOOP AT is_allocation-allocations
          INTO DATA(ls_demand_allocation).
        IF ls_demand_allocation-shortfall_source_quantity > 0.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
      ENDLOOP.
    ENDIF.

    LOOP AT is_allocation-plant_allocations
        INTO DATA(ls_source_allocation).
      IF ls_source_allocation-allocation-allocated_quantity <= 0
          AND ls_source_allocation-allocated_source_quantity <= 0.
        CONTINUE.
      ENDIF.
      IF ls_source_allocation-allocation-source_plant IS INITIAL
          OR ls_source_allocation-allocation-target_plant IS INITIAL
          OR ls_source_allocation-allocation-source_plant
            = ls_source_allocation-allocation-target_plant.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      READ TABLE lt_plant_pairs
        WITH KEY supplying_plant =
            ls_source_allocation-allocation-source_plant
          receiving_plant =
            ls_source_allocation-allocation-target_plant
        TRANSPORTING NO FIELDS.
      IF sy-subrc <> 0.
        APPEND VALUE #(
          supplying_plant =
            ls_source_allocation-allocation-source_plant
          receiving_plant =
            ls_source_allocation-allocation-target_plant )
          TO lt_plant_pairs.
      ENDIF.
    ENDLOOP.

    IF lt_plant_pairs IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT it_receiving_locations
        INTO DATA(ls_receiving_location).
      IF ls_receiving_location-receiving_plant IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      READ TABLE lt_plant_pairs
        WITH KEY receiving_plant =
          ls_receiving_location-receiving_plant
        TRANSPORTING NO FIELDS.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      READ TABLE lt_location_targets
        WITH KEY table_line =
          ls_receiving_location-receiving_plant
        TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      APPEND ls_receiving_location-receiving_plant
        TO lt_location_targets.
    ENDLOOP.

    LOOP AT lt_plant_pairs INTO DATA(ls_plant_pair).
      CLEAR lv_receiving_storage_loc.
      READ TABLE it_receiving_locations
        INTO ls_receiving_location
        WITH KEY receiving_plant = ls_plant_pair-receiving_plant.
      IF sy-subrc = 0.
        lv_receiving_storage_loc =
          ls_receiving_location-receiving_storage_loc.
      ENDIF.

      DATA(ls_request) = build_batch_request(
        is_allocation            = is_allocation
        iv_supplying_plant       = ls_plant_pair-supplying_plant
        iv_receiving_plant       = ls_plant_pair-receiving_plant
        iv_delivery_date         = iv_delivery_date
        iv_receiving_storage_loc = lv_receiving_storage_loc
        iv_company_code          = iv_company_code
        iv_purchasing_org        = iv_purchasing_org
        iv_purchasing_group      = iv_purchasing_group
        iv_allow_partial         = iv_allow_partial
        iv_test_run              = iv_test_run ).
      APPEND VALUE #(
        supplying_plant = ls_plant_pair-supplying_plant
        receiving_plant = ls_plant_pair-receiving_plant
        request         = ls_request ) TO lt_prepared_orders.
    ENDLOOP.

    rs_result = execute_pair_orders(
      it_prepared_orders = lt_prepared_orders
      iv_test_run        = iv_test_run
      iv_atomic          = iv_atomic ).
  ENDMETHOD.

  METHOD create_for_atp_batch_pairs.
    IF iv_delivery_date IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    validate_batch_atp( is_allocation = is_allocation ).

    rs_result = create_for_batch_pairs(
      is_allocation          = is_allocation-local_estimate
      iv_delivery_date       = iv_delivery_date
      it_receiving_locations = it_receiving_locations
      iv_company_code        = iv_company_code
      iv_purchasing_org      = iv_purchasing_org
      iv_purchasing_group    = iv_purchasing_group
      iv_allow_partial       = iv_allow_partial
      iv_test_run            = iv_test_run
      iv_atomic              = iv_atomic ).
  ENDMETHOD.

  METHOD map_dated_batch_fefo.
    TYPES:
      BEGIN OF ty_batch_demand_group,
        request_id           TYPE c LENGTH 30,
        material             TYPE mard-matnr,
        target_plant         TYPE mard-werks,
        required_date        TYPE resb-bdter,
        priority             TYPE i,
        batch                TYPE mchb-charg,
        source_unit          TYPE mara-meins,
        base_unit            TYPE mara-meins,
        demand_base_quantity TYPE mard-labst,
        source_base_quantity TYPE mard-labst,
      END OF ty_batch_demand_group.
    TYPES ty_batch_demand_groups TYPE SORTED TABLE OF
      ty_batch_demand_group WITH UNIQUE KEY request_id.
    TYPES:
      BEGIN OF ty_batch_split_group,
        request_id              TYPE c LENGTH 30,
        material                TYPE mard-matnr,
        target_plant            TYPE mard-werks,
        source_plant            TYPE mard-werks,
        required_date           TYPE resb-bdter,
        priority                TYPE i,
        batch                   TYPE mchb-charg,
        source_unit             TYPE mara-meins,
        base_unit               TYPE mara-meins,
        allocated_base_quantity TYPE mard-labst,
        location_base_quantity  TYPE mard-labst,
      END OF ty_batch_split_group.
    TYPES ty_batch_split_groups TYPE SORTED TABLE OF
      ty_batch_split_group WITH UNIQUE KEY request_id material
        target_plant source_plant required_date priority batch.
    DATA lt_demand_groups TYPE ty_batch_demand_groups.
    DATA lt_split_groups TYPE ty_batch_split_groups.
    FIELD-SYMBOLS <ls_demand_group> TYPE ty_batch_demand_group.
    FIELD-SYMBOLS <ls_split_group> TYPE ty_batch_split_group.

    LOOP AT is_allocation-allocations INTO DATA(ls_batch_demand).
      IF ls_batch_demand-allocation-request_id IS INITIAL
          OR ls_batch_demand-allocation-material IS INITIAL
          OR ls_batch_demand-allocation-target_plant IS INITIAL
          OR ls_batch_demand-allocation-required_date IS INITIAL
          OR ls_batch_demand-allocation-batch IS INITIAL
          OR ls_batch_demand-source_unit IS INITIAL
          OR ls_batch_demand-base_unit IS INITIAL
          OR ls_batch_demand-allocation-allocated_quantity < 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT VALUE #(
        request_id           = ls_batch_demand-allocation-request_id
        material             = ls_batch_demand-allocation-material
        target_plant         = ls_batch_demand-allocation-target_plant
        required_date        = ls_batch_demand-allocation-required_date
        priority             = ls_batch_demand-allocation-priority
        batch                = ls_batch_demand-allocation-batch
        source_unit          = ls_batch_demand-source_unit
        base_unit            = ls_batch_demand-base_unit
        demand_base_quantity =
          ls_batch_demand-allocation-allocated_quantity )
        INTO TABLE lt_demand_groups.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT is_allocation-plant_allocations INTO DATA(ls_batch_source).
      IF ls_batch_source-allocation-request_id IS INITIAL
          OR ls_batch_source-allocation-material IS INITIAL
          OR ls_batch_source-allocation-target_plant IS INITIAL
          OR ls_batch_source-allocation-source_plant IS INITIAL
          OR ls_batch_source-allocation-source_plant =
            ls_batch_source-allocation-target_plant
          OR ls_batch_source-allocation-required_date IS INITIAL
          OR ls_batch_source-allocation-batch IS INITIAL
          OR ls_batch_source-source_unit IS INITIAL
          OR ls_batch_source-base_unit IS INITIAL
          OR ls_batch_source-allocation-allocated_quantity < 0
          OR ls_batch_source-allocated_source_quantity < 0
          OR ls_batch_source-allocation-available_quantity <
            ls_batch_source-allocation-allocated_quantity
          OR ls_batch_source-available_source_quantity <
            ls_batch_source-allocated_source_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      READ TABLE lt_demand_groups ASSIGNING <ls_demand_group>
        WITH TABLE KEY
          request_id = ls_batch_source-allocation-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      IF <ls_demand_group>-material <>
            ls_batch_source-allocation-material
          OR <ls_demand_group>-target_plant <>
            ls_batch_source-allocation-target_plant
          OR <ls_demand_group>-required_date <>
            ls_batch_source-allocation-required_date
          OR <ls_demand_group>-priority <>
            ls_batch_source-allocation-priority
          OR <ls_demand_group>-batch <>
            ls_batch_source-allocation-batch
          OR <ls_demand_group>-source_unit <>
            ls_batch_source-source_unit
          OR <ls_demand_group>-base_unit <>
            ls_batch_source-base_unit.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      <ls_demand_group>-source_base_quantity =
        <ls_demand_group>-source_base_quantity
        + ls_batch_source-allocation-allocated_quantity.

      READ TABLE lt_split_groups ASSIGNING <ls_split_group>
        WITH TABLE KEY
          request_id = ls_batch_source-allocation-request_id
          material = ls_batch_source-allocation-material
          target_plant = ls_batch_source-allocation-target_plant
          source_plant = ls_batch_source-allocation-source_plant
          required_date = ls_batch_source-allocation-required_date
          priority = ls_batch_source-allocation-priority
          batch = ls_batch_source-allocation-batch.
      IF sy-subrc = 0.
        IF <ls_split_group>-source_unit <> ls_batch_source-source_unit
            OR <ls_split_group>-base_unit <> ls_batch_source-base_unit.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        <ls_split_group>-allocated_base_quantity =
          <ls_split_group>-allocated_base_quantity
          + ls_batch_source-allocation-allocated_quantity.
      ELSE.
        INSERT VALUE #(
          request_id              = ls_batch_source-allocation-request_id
          material                = ls_batch_source-allocation-material
          target_plant            = ls_batch_source-allocation-target_plant
          source_plant            = ls_batch_source-allocation-source_plant
          required_date           = ls_batch_source-allocation-required_date
          priority                = ls_batch_source-allocation-priority
          batch                   = ls_batch_source-allocation-batch
          source_unit             = ls_batch_source-source_unit
          base_unit               = ls_batch_source-base_unit
          allocated_base_quantity =
            ls_batch_source-allocation-allocated_quantity )
          INTO TABLE lt_split_groups.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_demand_groups INTO DATA(ls_demand_group).
      IF ls_demand_group-demand_base_quantity <>
          ls_demand_group-source_base_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT is_allocation-location_allocations INTO DATA(ls_batch_location).
      IF ls_batch_location-allocation-allocated_quantity < 0
          OR ls_batch_location-allocated_source_quantity < 0
          OR ls_batch_location-allocation-available_quantity <
            ls_batch_location-allocation-allocated_quantity
          OR ls_batch_location-available_source_quantity <
            ls_batch_location-allocated_source_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      IF ls_batch_location-allocation-allocated_quantity = 0
          AND ls_batch_location-allocated_source_quantity = 0.
        CONTINUE.
      ENDIF.
      READ TABLE lt_split_groups ASSIGNING <ls_split_group>
        WITH TABLE KEY
          request_id = ls_batch_location-allocation-request_id
          material = ls_batch_location-allocation-material
          target_plant = ls_batch_location-allocation-target_plant
          source_plant = ls_batch_location-allocation-source_plant
          required_date = ls_batch_location-allocation-required_date
          priority = ls_batch_location-allocation-priority
          batch = ls_batch_location-allocation-batch.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      IF <ls_split_group>-source_unit <> ls_batch_location-source_unit
          OR <ls_split_group>-base_unit <> ls_batch_location-base_unit
          OR ls_batch_location-allocation-storage_location IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      <ls_split_group>-location_base_quantity =
        <ls_split_group>-location_base_quantity
        + ls_batch_location-allocation-allocated_quantity.
    ENDLOOP.

    LOOP AT lt_split_groups INTO DATA(ls_split_group).
      IF ls_split_group-allocated_base_quantity <>
          ls_split_group-location_base_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT is_allocation-allocations INTO ls_batch_demand.
      APPEND VALUE #(
        allocation                = CORRESPONDING #( ls_batch_demand-allocation )
        source_quantity           = ls_batch_demand-source_quantity
        source_unit               = ls_batch_demand-source_unit
        base_quantity             = ls_batch_demand-base_quantity
        base_unit                 = ls_batch_demand-base_unit
        available_source_quantity =
          ls_batch_demand-available_source_quantity
        allocated_source_quantity =
          ls_batch_demand-allocated_source_quantity
        shortfall_source_quantity =
          ls_batch_demand-shortfall_source_quantity )
        TO rs_result-allocations.
    ENDLOOP.

    LOOP AT is_allocation-plant_allocations INTO ls_batch_source.
      APPEND VALUE #(
        allocation                = CORRESPONDING #( ls_batch_source-allocation )
        source_unit               = ls_batch_source-source_unit
        base_unit                 = ls_batch_source-base_unit
        available_source_quantity =
          ls_batch_source-available_source_quantity
        allocated_source_quantity =
          ls_batch_source-allocated_source_quantity )
        TO rs_result-plant_allocations.
    ENDLOOP.

    LOOP AT is_allocation-location_allocations INTO ls_batch_location.
      APPEND VALUE #(
        allocation                = VALUE #(
          required_date = ls_batch_location-allocation-required_date
          priority      = ls_batch_location-allocation-priority
          allocation    = CORRESPONDING #( ls_batch_location-allocation ) )
        source_unit               = ls_batch_location-source_unit
        base_unit                 = ls_batch_location-base_unit
        available_source_quantity =
          ls_batch_location-available_source_quantity
        allocated_source_quantity =
          ls_batch_location-allocated_source_quantity )
        TO rs_result-batch_allocations.
    ENDLOOP.
  ENDMETHOD.

  METHOD create_dated_batch_pairs.
    DATA(ls_fefo_allocation) = map_dated_batch_fefo(
      is_allocation = is_allocation ).

    rs_result = create_for_fefo_pairs(
      is_allocation          = ls_fefo_allocation
      it_receiving_locations = it_receiving_locations
      iv_company_code        = iv_company_code
      iv_purchasing_org      = iv_purchasing_org
      iv_purchasing_group    = iv_purchasing_group
      iv_allow_partial       = iv_allow_partial
      iv_test_run            = iv_test_run
      iv_atomic              = iv_atomic ).
  ENDMETHOD.

  METHOD create_dated_batch_atp_pairs.
    TYPES:
      BEGIN OF ty_dated_batch_atp_group,
        material                  TYPE mard-matnr,
        source_plant              TYPE mard-werks,
        base_unit                 TYPE mara-meins,
        required_date             TYPE resb-bdter,
        allocated_base_quantity   TYPE mard-labst,
        cumulative_base_quantity  TYPE mard-labst,
        confirmed_base_quantity   TYPE mard-labst,
        unconfirmed_base_quantity TYPE mard-labst,
        atp_result                TYPE zif_material_availability_api=>ty_result,
      END OF ty_dated_batch_atp_group.
    TYPES ty_dated_batch_atp_groups TYPE SORTED TABLE OF
      ty_dated_batch_atp_group WITH UNIQUE KEY material source_plant
        base_unit required_date.
    DATA lt_groups TYPE ty_dated_batch_atp_groups.
    DATA ls_fefo_allocation TYPE
      zcl_stock_service=>ty_plant_fefo_date_atp_result.
    DATA lv_cumulative_quantity TYPE mard-labst.
    DATA lv_previous_material TYPE mard-matnr.
    DATA lv_previous_plant TYPE mard-werks.
    DATA lv_previous_unit TYPE mara-meins.
    DATA lv_match_count TYPE i.
    FIELD-SYMBOLS <ls_group> TYPE ty_dated_batch_atp_group.

    LOOP AT is_allocation-local_estimate-plant_allocations
        INTO DATA(ls_source_allocation).
      IF ls_source_allocation-allocation-allocated_quantity <= 0.
        IF ls_source_allocation-allocated_source_quantity > 0.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        CONTINUE.
      ENDIF.
      READ TABLE lt_groups ASSIGNING <ls_group>
        WITH TABLE KEY
          material = ls_source_allocation-allocation-material
          source_plant =
            ls_source_allocation-allocation-source_plant
          base_unit = ls_source_allocation-base_unit
          required_date =
            ls_source_allocation-allocation-required_date.
      IF sy-subrc = 0.
        <ls_group>-allocated_base_quantity =
          <ls_group>-allocated_base_quantity
          + ls_source_allocation-allocation-allocated_quantity.
      ELSE.
        INSERT VALUE #(
          material                = ls_source_allocation-allocation-material
          source_plant            =
            ls_source_allocation-allocation-source_plant
          base_unit               = ls_source_allocation-base_unit
          required_date           =
            ls_source_allocation-allocation-required_date
          allocated_base_quantity =
            ls_source_allocation-allocation-allocated_quantity )
          INTO TABLE lt_groups.
      ENDIF.
    ENDLOOP.

    IF lt_groups IS INITIAL
        OR lines( is_allocation-atp_checks ) <> lines( lt_groups ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT lt_groups ASSIGNING <ls_group>.
      IF sy-tabix = 1
          OR <ls_group>-material <> lv_previous_material
          OR <ls_group>-source_plant <> lv_previous_plant
          OR <ls_group>-base_unit <> lv_previous_unit.
        CLEAR lv_cumulative_quantity.
      ENDIF.
      lv_cumulative_quantity = lv_cumulative_quantity
        + <ls_group>-allocated_base_quantity.
      <ls_group>-cumulative_base_quantity = lv_cumulative_quantity.
      CLEAR lv_match_count.
      LOOP AT is_allocation-atp_checks INTO DATA(ls_atp_check)
        WHERE material = <ls_group>-material
          AND source_plant = <ls_group>-source_plant
          AND base_unit = <ls_group>-base_unit
          AND check_date = <ls_group>-required_date.
        ADD 1 TO lv_match_count.
        <ls_group>-confirmed_base_quantity =
          ls_atp_check-confirmed_base_quantity.
        <ls_group>-unconfirmed_base_quantity =
          ls_atp_check-unconfirmed_base_quantity.
        <ls_group>-atp_result = ls_atp_check-atp_result.
        IF ls_atp_check-allocated_base_quantity <>
              <ls_group>-allocated_base_quantity
            OR ls_atp_check-cumulative_base_quantity <>
              <ls_group>-cumulative_base_quantity
            OR ls_atp_check-confirmed_base_quantity
              + ls_atp_check-unconfirmed_base_quantity <>
                <ls_group>-cumulative_base_quantity
            OR ls_atp_check-confirmed_base_quantity <
              <ls_group>-cumulative_base_quantity
            OR ls_atp_check-atp_result-material <>
              <ls_group>-material
            OR ls_atp_check-atp_result-plant <>
              <ls_group>-source_plant
            OR ls_atp_check-atp_result-unit <>
              <ls_group>-base_unit
            OR ls_atp_check-atp_result-required_date <>
              <ls_group>-required_date
            OR ls_atp_check-atp_result-requested_quantity <>
              <ls_group>-cumulative_base_quantity
            OR ls_atp_check-atp_result-check_rule IS INITIAL
            OR ls_atp_check-atp_result-is_check_relevant <>
              abap_true.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
      ENDLOOP.
      IF lv_match_count <> 1
          OR <ls_group>-required_date IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      lv_previous_material = <ls_group>-material.
      lv_previous_plant = <ls_group>-source_plant.
      lv_previous_unit = <ls_group>-base_unit.
    ENDLOOP.

    ls_fefo_allocation-local_estimate = map_dated_batch_fefo(
      is_allocation = is_allocation-local_estimate ).

    LOOP AT is_allocation-local_estimate-plant_allocations
        INTO ls_source_allocation.
      IF ls_source_allocation-allocation-allocated_quantity <= 0.
        CONTINUE.
      ENDIF.

      READ TABLE lt_groups INTO DATA(ls_group)
        WITH TABLE KEY
          material = ls_source_allocation-allocation-material
          source_plant =
            ls_source_allocation-allocation-source_plant
          base_unit = ls_source_allocation-base_unit
          required_date =
            ls_source_allocation-allocation-required_date.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      APPEND VALUE #(
        request_id                = ls_source_allocation-allocation-request_id
        material                  = ls_source_allocation-allocation-material
        target_plant              = ls_source_allocation-allocation-target_plant
        source_plant              = ls_source_allocation-allocation-source_plant
        required_date             = ls_source_allocation-allocation-required_date
        base_unit                 = ls_source_allocation-base_unit
        allocated_base_quantity   =
          ls_source_allocation-allocation-allocated_quantity
        cumulative_base_quantity  =
          ls_group-cumulative_base_quantity
        confirmed_base_quantity   = ls_group-confirmed_base_quantity
        unconfirmed_base_quantity = ls_group-unconfirmed_base_quantity
        atp_result                = ls_group-atp_result )
        TO ls_fefo_allocation-atp_checks.
    ENDLOOP.

    rs_result = create_for_atp_fefo_pairs(
      is_allocation          = ls_fefo_allocation
      it_receiving_locations = it_receiving_locations
      iv_company_code        = iv_company_code
      iv_purchasing_org      = iv_purchasing_org
      iv_purchasing_group    = iv_purchasing_group
      iv_allow_partial       = iv_allow_partial
      iv_test_run            = iv_test_run
      iv_atomic              = iv_atomic ).
  ENDMETHOD.

  METHOD create_for_fefo_pairs.
    DATA lt_plant_pairs TYPE ty_plant_pairs.
    DATA lt_prepared_orders TYPE ty_prepared_pair_orders.
    DATA lt_location_targets TYPE ty_source_plants.
    DATA lv_receiving_storage_loc TYPE mard-lgort.

    validate_fefo_pair_totals( is_allocation = is_allocation ).

    IF iv_company_code IS INITIAL
        OR iv_purchasing_org IS INITIAL
        OR iv_purchasing_group IS INITIAL
        OR ( iv_allow_partial <> abap_true
          AND iv_allow_partial <> abap_false )
        OR ( iv_test_run <> abap_true
          AND iv_test_run <> abap_false )
        OR ( iv_atomic <> abap_true
          AND iv_atomic <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    IF iv_allow_partial = abap_false.
      LOOP AT is_allocation-allocations
          INTO DATA(ls_demand_allocation).
        IF ls_demand_allocation-shortfall_source_quantity > 0.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
      ENDLOOP.
    ENDIF.

    LOOP AT is_allocation-batch_allocations
        INTO DATA(ls_fefo_split).
      IF ls_fefo_split-allocation-allocation-allocated_quantity <= 0
          AND ls_fefo_split-allocated_source_quantity <= 0.
        CONTINUE.
      ENDIF.
      IF ls_fefo_split-allocation-allocation-source_plant IS INITIAL
          OR ls_fefo_split-allocation-allocation-target_plant IS INITIAL
          OR ls_fefo_split-allocation-allocation-source_plant
            = ls_fefo_split-allocation-allocation-target_plant.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      READ TABLE lt_plant_pairs
        WITH KEY supplying_plant =
            ls_fefo_split-allocation-allocation-source_plant
          receiving_plant =
            ls_fefo_split-allocation-allocation-target_plant
        TRANSPORTING NO FIELDS.
      IF sy-subrc <> 0.
        APPEND VALUE #(
          supplying_plant =
            ls_fefo_split-allocation-allocation-source_plant
          receiving_plant =
            ls_fefo_split-allocation-allocation-target_plant )
          TO lt_plant_pairs.
      ENDIF.
    ENDLOOP.

    IF lt_plant_pairs IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT it_receiving_locations
        INTO DATA(ls_receiving_location).
      IF ls_receiving_location-receiving_plant IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      READ TABLE lt_plant_pairs
        WITH KEY receiving_plant =
          ls_receiving_location-receiving_plant
        TRANSPORTING NO FIELDS.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      READ TABLE lt_location_targets
        WITH KEY table_line =
          ls_receiving_location-receiving_plant
        TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      APPEND ls_receiving_location-receiving_plant
        TO lt_location_targets.
    ENDLOOP.

    LOOP AT lt_plant_pairs INTO DATA(ls_plant_pair).
      CLEAR lv_receiving_storage_loc.
      READ TABLE it_receiving_locations
        INTO ls_receiving_location
        WITH KEY receiving_plant = ls_plant_pair-receiving_plant.
      IF sy-subrc = 0.
        lv_receiving_storage_loc =
          ls_receiving_location-receiving_storage_loc.
      ENDIF.

      DATA(ls_request) = build_fefo_request(
        is_allocation            = is_allocation
        iv_supplying_plant       = ls_plant_pair-supplying_plant
        iv_receiving_plant       = ls_plant_pair-receiving_plant
        iv_receiving_storage_loc = lv_receiving_storage_loc
        iv_company_code          = iv_company_code
        iv_purchasing_org        = iv_purchasing_org
        iv_purchasing_group      = iv_purchasing_group
        iv_allow_partial         = iv_allow_partial
        iv_test_run              = iv_test_run ).
      APPEND VALUE #(
        supplying_plant = ls_plant_pair-supplying_plant
        receiving_plant = ls_plant_pair-receiving_plant
        request         = ls_request ) TO lt_prepared_orders.
    ENDLOOP.

    rs_result = execute_pair_orders(
      it_prepared_orders = lt_prepared_orders
      iv_test_run        = iv_test_run
      iv_atomic          = iv_atomic ).
  ENDMETHOD.

  METHOD validate_fefo_pair_totals.
    TYPES:
      BEGIN OF ty_fefo_demand_group,
        request_id           TYPE c LENGTH 30,
        material             TYPE mard-matnr,
        target_plant         TYPE mard-werks,
        required_date        TYPE resb-bdter,
        priority             TYPE i,
        source_unit          TYPE mara-meins,
        base_unit            TYPE mara-meins,
        demand_base_quantity TYPE mard-labst,
        source_base_quantity TYPE mard-labst,
      END OF ty_fefo_demand_group.
    TYPES ty_fefo_demand_groups TYPE SORTED TABLE OF
      ty_fefo_demand_group WITH UNIQUE KEY request_id.
    TYPES:
      BEGIN OF ty_fefo_plant_group,
        request_id          TYPE c LENGTH 30,
        material            TYPE mard-matnr,
        target_plant        TYPE mard-werks,
        source_plant        TYPE mard-werks,
        required_date       TYPE resb-bdter,
        priority            TYPE i,
        source_unit         TYPE mara-meins,
        base_unit           TYPE mara-meins,
        plant_base_quantity TYPE mard-labst,
        batch_base_quantity TYPE mard-labst,
      END OF ty_fefo_plant_group.
    TYPES ty_fefo_plant_groups TYPE SORTED TABLE OF ty_fefo_plant_group
      WITH UNIQUE KEY request_id material target_plant source_plant
        required_date priority.
    DATA lt_demand_groups TYPE ty_fefo_demand_groups.
    DATA lt_plant_groups TYPE ty_fefo_plant_groups.
    FIELD-SYMBOLS <ls_demand_group> TYPE ty_fefo_demand_group.
    FIELD-SYMBOLS <ls_plant_group> TYPE ty_fefo_plant_group.

    LOOP AT is_allocation-allocations INTO DATA(ls_demand_allocation).
      IF ls_demand_allocation-allocation-request_id IS INITIAL
          OR ls_demand_allocation-allocation-material IS INITIAL
          OR ls_demand_allocation-allocation-target_plant IS INITIAL
          OR ls_demand_allocation-allocation-required_date IS INITIAL
          OR ls_demand_allocation-source_unit IS INITIAL
          OR ls_demand_allocation-base_unit IS INITIAL
          OR ls_demand_allocation-allocation-allocated_quantity < 0
          OR ls_demand_allocation-allocated_source_quantity < 0
          OR ls_demand_allocation-allocation-available_quantity <
            ls_demand_allocation-allocation-allocated_quantity
          OR ls_demand_allocation-available_source_quantity <
            ls_demand_allocation-allocated_source_quantity
          OR ( ls_demand_allocation-allocation-allocated_quantity > 0
            AND ls_demand_allocation-allocated_source_quantity <= 0 )
          OR ( ls_demand_allocation-allocation-allocated_quantity = 0
            AND ls_demand_allocation-allocated_source_quantity > 0 ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT VALUE #(
        request_id           = ls_demand_allocation-allocation-request_id
        material             = ls_demand_allocation-allocation-material
        target_plant         = ls_demand_allocation-allocation-target_plant
        required_date        = ls_demand_allocation-allocation-required_date
        priority             = ls_demand_allocation-allocation-priority
        source_unit          = ls_demand_allocation-source_unit
        base_unit            = ls_demand_allocation-base_unit
        demand_base_quantity =
          ls_demand_allocation-allocation-allocated_quantity )
        INTO TABLE lt_demand_groups.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT is_allocation-plant_allocations INTO DATA(ls_source_allocation).
      IF ls_source_allocation-allocation-request_id IS INITIAL
          OR ls_source_allocation-allocation-material IS INITIAL
          OR ls_source_allocation-allocation-target_plant IS INITIAL
          OR ls_source_allocation-allocation-source_plant IS INITIAL
          OR ls_source_allocation-allocation-source_plant =
            ls_source_allocation-allocation-target_plant
          OR ls_source_allocation-allocation-required_date IS INITIAL
          OR ls_source_allocation-source_unit IS INITIAL
          OR ls_source_allocation-base_unit IS INITIAL
          OR ls_source_allocation-allocation-allocated_quantity < 0
          OR ls_source_allocation-allocated_source_quantity < 0
          OR ls_source_allocation-allocation-available_quantity <
            ls_source_allocation-allocation-allocated_quantity
          OR ls_source_allocation-available_source_quantity <
            ls_source_allocation-allocated_source_quantity
          OR ( ls_source_allocation-allocation-allocated_quantity > 0
            AND ls_source_allocation-allocated_source_quantity <= 0 )
          OR ( ls_source_allocation-allocation-allocated_quantity = 0
            AND ls_source_allocation-allocated_source_quantity > 0 ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      READ TABLE lt_demand_groups ASSIGNING <ls_demand_group>
        WITH TABLE KEY
          request_id = ls_source_allocation-allocation-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      IF <ls_demand_group>-material <>
            ls_source_allocation-allocation-material
          OR <ls_demand_group>-target_plant <>
            ls_source_allocation-allocation-target_plant
          OR <ls_demand_group>-required_date <>
            ls_source_allocation-allocation-required_date
          OR <ls_demand_group>-priority <>
            ls_source_allocation-allocation-priority
          OR <ls_demand_group>-source_unit <>
            ls_source_allocation-source_unit
          OR <ls_demand_group>-base_unit <>
            ls_source_allocation-base_unit.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      <ls_demand_group>-source_base_quantity =
        <ls_demand_group>-source_base_quantity
        + ls_source_allocation-allocation-allocated_quantity.

      READ TABLE lt_plant_groups ASSIGNING <ls_plant_group>
        WITH TABLE KEY
          request_id = ls_source_allocation-allocation-request_id
          material = ls_source_allocation-allocation-material
          target_plant = ls_source_allocation-allocation-target_plant
          source_plant = ls_source_allocation-allocation-source_plant
          required_date =
            ls_source_allocation-allocation-required_date
          priority = ls_source_allocation-allocation-priority.
      IF sy-subrc = 0.
        IF <ls_plant_group>-source_unit <>
              ls_source_allocation-source_unit
            OR <ls_plant_group>-base_unit <>
              ls_source_allocation-base_unit.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        <ls_plant_group>-plant_base_quantity =
          <ls_plant_group>-plant_base_quantity
          + ls_source_allocation-allocation-allocated_quantity.
      ELSE.
        INSERT VALUE #(
          request_id          = ls_source_allocation-allocation-request_id
          material            = ls_source_allocation-allocation-material
          target_plant        = ls_source_allocation-allocation-target_plant
          source_plant        = ls_source_allocation-allocation-source_plant
          required_date       =
            ls_source_allocation-allocation-required_date
          priority            = ls_source_allocation-allocation-priority
          source_unit         = ls_source_allocation-source_unit
          base_unit           = ls_source_allocation-base_unit
          plant_base_quantity =
            ls_source_allocation-allocation-allocated_quantity )
          INTO TABLE lt_plant_groups.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_demand_groups INTO DATA(ls_demand_group).
      IF ls_demand_group-demand_base_quantity <>
          ls_demand_group-source_base_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT is_allocation-batch_allocations INTO DATA(ls_batch_split).
      IF ls_batch_split-allocation-allocation-allocated_quantity < 0
          OR ls_batch_split-allocated_source_quantity < 0
          OR ls_batch_split-allocation-allocation-available_quantity <
            ls_batch_split-allocation-allocation-allocated_quantity
          OR ls_batch_split-available_source_quantity <
            ls_batch_split-allocated_source_quantity
          OR ( ls_batch_split-allocation-allocation-allocated_quantity > 0
            AND ls_batch_split-allocated_source_quantity <= 0 )
          OR ( ls_batch_split-allocation-allocation-allocated_quantity = 0
            AND ls_batch_split-allocated_source_quantity > 0 ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      IF ls_batch_split-allocation-allocation-allocated_quantity = 0
          AND ls_batch_split-allocated_source_quantity = 0.
        CONTINUE.
      ENDIF.
      IF ls_batch_split-allocation-required_date IS INITIAL
          OR ls_batch_split-allocation-allocation-request_id IS INITIAL
          OR ls_batch_split-allocation-allocation-material IS INITIAL
          OR ls_batch_split-allocation-allocation-target_plant IS INITIAL
          OR ls_batch_split-allocation-allocation-source_plant IS INITIAL
          OR ls_batch_split-allocation-allocation-source_plant =
            ls_batch_split-allocation-allocation-target_plant
          OR ls_batch_split-allocation-allocation-batch IS INITIAL
          OR ls_batch_split-allocation-allocation-storage_location IS INITIAL
          OR ls_batch_split-source_unit IS INITIAL
          OR ls_batch_split-base_unit IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      READ TABLE lt_plant_groups ASSIGNING <ls_plant_group>
        WITH TABLE KEY
          request_id =
            ls_batch_split-allocation-allocation-request_id
          material = ls_batch_split-allocation-allocation-material
          target_plant =
            ls_batch_split-allocation-allocation-target_plant
          source_plant =
            ls_batch_split-allocation-allocation-source_plant
          required_date = ls_batch_split-allocation-required_date
          priority = ls_batch_split-allocation-priority.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      IF <ls_plant_group>-source_unit <> ls_batch_split-source_unit
          OR <ls_plant_group>-base_unit <> ls_batch_split-base_unit.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      <ls_plant_group>-batch_base_quantity =
        <ls_plant_group>-batch_base_quantity
        + ls_batch_split-allocation-allocation-allocated_quantity.
    ENDLOOP.

    LOOP AT lt_plant_groups INTO DATA(ls_plant_group).
      IF ls_plant_group-plant_base_quantity <>
          ls_plant_group-batch_base_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validate_plant_pair_totals.
    TYPES:
      BEGIN OF ty_plant_demand_group,
        request_id           TYPE c LENGTH 30,
        material             TYPE mard-matnr,
        target_plant         TYPE mard-werks,
        required_date        TYPE resb-bdter,
        priority             TYPE i,
        source_unit          TYPE mara-meins,
        base_unit            TYPE mara-meins,
        demand_base_quantity TYPE mard-labst,
        source_base_quantity TYPE mard-labst,
      END OF ty_plant_demand_group.
    TYPES ty_plant_demand_groups TYPE SORTED TABLE OF
      ty_plant_demand_group WITH UNIQUE KEY request_id.
    DATA lt_demand_groups TYPE ty_plant_demand_groups.
    FIELD-SYMBOLS <ls_demand_group> TYPE ty_plant_demand_group.

    LOOP AT is_allocation-allocations INTO DATA(ls_demand_allocation).
      IF ls_demand_allocation-allocation-request_id IS INITIAL
          OR ls_demand_allocation-allocation-material IS INITIAL
          OR ls_demand_allocation-allocation-target_plant IS INITIAL
          OR ls_demand_allocation-allocation-required_date IS INITIAL
          OR ls_demand_allocation-source_unit IS INITIAL
          OR ls_demand_allocation-base_unit IS INITIAL
          OR ls_demand_allocation-allocation-allocated_quantity < 0
          OR ls_demand_allocation-allocated_source_quantity < 0
          OR ls_demand_allocation-allocation-available_quantity <
            ls_demand_allocation-allocation-allocated_quantity
          OR ls_demand_allocation-available_source_quantity <
            ls_demand_allocation-allocated_source_quantity
          OR ( ls_demand_allocation-allocation-allocated_quantity > 0
            AND ls_demand_allocation-allocated_source_quantity <= 0 )
          OR ( ls_demand_allocation-allocation-allocated_quantity = 0
            AND ls_demand_allocation-allocated_source_quantity > 0 ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      INSERT VALUE #(
        request_id           = ls_demand_allocation-allocation-request_id
        material             = ls_demand_allocation-allocation-material
        target_plant         = ls_demand_allocation-allocation-target_plant
        required_date        = ls_demand_allocation-allocation-required_date
        priority             = ls_demand_allocation-allocation-priority
        source_unit          = ls_demand_allocation-source_unit
        base_unit            = ls_demand_allocation-base_unit
        demand_base_quantity =
          ls_demand_allocation-allocation-allocated_quantity )
        INTO TABLE lt_demand_groups.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT is_allocation-plant_allocations
        INTO DATA(ls_source_allocation).
      IF ls_source_allocation-allocation-request_id IS INITIAL
          OR ls_source_allocation-allocation-material IS INITIAL
          OR ls_source_allocation-allocation-target_plant IS INITIAL
          OR ls_source_allocation-allocation-source_plant IS INITIAL
          OR ls_source_allocation-allocation-source_plant =
            ls_source_allocation-allocation-target_plant
          OR ls_source_allocation-allocation-required_date IS INITIAL
          OR ls_source_allocation-source_unit IS INITIAL
          OR ls_source_allocation-base_unit IS INITIAL
          OR ls_source_allocation-allocation-allocated_quantity < 0
          OR ls_source_allocation-allocated_source_quantity < 0
          OR ls_source_allocation-allocation-available_quantity <
            ls_source_allocation-allocation-allocated_quantity
          OR ls_source_allocation-available_source_quantity <
            ls_source_allocation-allocated_source_quantity
          OR ( ls_source_allocation-allocation-allocated_quantity > 0
            AND ls_source_allocation-allocated_source_quantity <= 0 )
          OR ( ls_source_allocation-allocation-allocated_quantity = 0
            AND ls_source_allocation-allocated_source_quantity > 0 ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      READ TABLE lt_demand_groups ASSIGNING <ls_demand_group>
        WITH TABLE KEY
          request_id = ls_source_allocation-allocation-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      IF <ls_demand_group>-material <>
            ls_source_allocation-allocation-material
          OR <ls_demand_group>-target_plant <>
            ls_source_allocation-allocation-target_plant
          OR <ls_demand_group>-required_date <>
            ls_source_allocation-allocation-required_date
          OR <ls_demand_group>-priority <>
            ls_source_allocation-allocation-priority
          OR <ls_demand_group>-source_unit <>
            ls_source_allocation-source_unit
          OR <ls_demand_group>-base_unit <>
            ls_source_allocation-base_unit.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      <ls_demand_group>-source_base_quantity =
        <ls_demand_group>-source_base_quantity
        + ls_source_allocation-allocation-allocated_quantity.
    ENDLOOP.

    LOOP AT lt_demand_groups INTO DATA(ls_demand_group).
      IF ls_demand_group-demand_base_quantity <>
          ls_demand_group-source_base_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validate_batch_pair_totals.
    TYPES:
      BEGIN OF ty_batch_demand_group,
        request_id           TYPE c LENGTH 30,
        material             TYPE mard-matnr,
        target_plant         TYPE mard-werks,
        batch                TYPE mchb-charg,
        source_unit          TYPE mara-meins,
        base_unit            TYPE mara-meins,
        demand_base_quantity TYPE mard-labst,
        source_base_quantity TYPE mard-labst,
      END OF ty_batch_demand_group.
    TYPES ty_batch_demand_groups TYPE SORTED TABLE OF
      ty_batch_demand_group WITH UNIQUE KEY request_id.
    TYPES:
      BEGIN OF ty_batch_source_group,
        request_id             TYPE c LENGTH 30,
        material               TYPE mard-matnr,
        target_plant           TYPE mard-werks,
        source_plant           TYPE mard-werks,
        batch                  TYPE mchb-charg,
        source_unit            TYPE mara-meins,
        base_unit              TYPE mara-meins,
        plant_base_quantity    TYPE mard-labst,
        location_base_quantity TYPE mard-labst,
      END OF ty_batch_source_group.
    TYPES ty_batch_source_groups TYPE SORTED TABLE OF
      ty_batch_source_group WITH UNIQUE KEY request_id material
        target_plant source_plant batch.
    DATA lt_demand_groups TYPE ty_batch_demand_groups.
    DATA lt_source_groups TYPE ty_batch_source_groups.
    FIELD-SYMBOLS <ls_demand_group> TYPE ty_batch_demand_group.
    FIELD-SYMBOLS <ls_source_group> TYPE ty_batch_source_group.

    LOOP AT is_allocation-allocations INTO DATA(ls_demand_allocation).
      IF ls_demand_allocation-allocation-request_id IS INITIAL
          OR ls_demand_allocation-allocation-material IS INITIAL
          OR ls_demand_allocation-allocation-target_plant IS INITIAL
          OR ls_demand_allocation-allocation-batch IS INITIAL
          OR ls_demand_allocation-source_unit IS INITIAL
          OR ls_demand_allocation-base_unit IS INITIAL
          OR ls_demand_allocation-allocation-allocated_quantity < 0
          OR ls_demand_allocation-allocated_source_quantity < 0
          OR ls_demand_allocation-allocation-available_quantity <
            ls_demand_allocation-allocation-allocated_quantity
          OR ls_demand_allocation-available_source_quantity <
            ls_demand_allocation-allocated_source_quantity
          OR ( ls_demand_allocation-allocation-allocated_quantity > 0
            AND ls_demand_allocation-allocated_source_quantity <= 0 )
          OR ( ls_demand_allocation-allocation-allocated_quantity = 0
            AND ls_demand_allocation-allocated_source_quantity > 0 ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT VALUE #(
        request_id           = ls_demand_allocation-allocation-request_id
        material             = ls_demand_allocation-allocation-material
        target_plant         =
          ls_demand_allocation-allocation-target_plant
        batch                = ls_demand_allocation-allocation-batch
        source_unit          = ls_demand_allocation-source_unit
        base_unit            = ls_demand_allocation-base_unit
        demand_base_quantity =
          ls_demand_allocation-allocation-allocated_quantity )
        INTO TABLE lt_demand_groups.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT is_allocation-plant_allocations INTO DATA(ls_source_allocation).
      IF ls_source_allocation-allocation-request_id IS INITIAL
          OR ls_source_allocation-allocation-material IS INITIAL
          OR ls_source_allocation-allocation-target_plant IS INITIAL
          OR ls_source_allocation-allocation-source_plant IS INITIAL
          OR ls_source_allocation-allocation-source_plant =
            ls_source_allocation-allocation-target_plant
          OR ls_source_allocation-allocation-batch IS INITIAL
          OR ls_source_allocation-source_unit IS INITIAL
          OR ls_source_allocation-base_unit IS INITIAL
          OR ls_source_allocation-allocation-allocated_quantity < 0
          OR ls_source_allocation-allocated_source_quantity < 0
          OR ls_source_allocation-allocation-available_quantity <
            ls_source_allocation-allocation-allocated_quantity
          OR ls_source_allocation-available_source_quantity <
            ls_source_allocation-allocated_source_quantity
          OR ( ls_source_allocation-allocation-allocated_quantity > 0
            AND ls_source_allocation-allocated_source_quantity <= 0 )
          OR ( ls_source_allocation-allocation-allocated_quantity = 0
            AND ls_source_allocation-allocated_source_quantity > 0 ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      READ TABLE lt_demand_groups ASSIGNING <ls_demand_group>
        WITH TABLE KEY
          request_id = ls_source_allocation-allocation-request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      IF <ls_demand_group>-material <>
            ls_source_allocation-allocation-material
          OR <ls_demand_group>-target_plant <>
            ls_source_allocation-allocation-target_plant
          OR <ls_demand_group>-batch <>
            ls_source_allocation-allocation-batch
          OR <ls_demand_group>-source_unit <>
            ls_source_allocation-source_unit
          OR <ls_demand_group>-base_unit <>
            ls_source_allocation-base_unit.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      <ls_demand_group>-source_base_quantity =
        <ls_demand_group>-source_base_quantity
        + ls_source_allocation-allocation-allocated_quantity.

      READ TABLE lt_source_groups ASSIGNING <ls_source_group>
        WITH TABLE KEY
          request_id = ls_source_allocation-allocation-request_id
          material = ls_source_allocation-allocation-material
          target_plant =
            ls_source_allocation-allocation-target_plant
          source_plant =
            ls_source_allocation-allocation-source_plant
          batch = ls_source_allocation-allocation-batch.
      IF sy-subrc = 0.
        IF <ls_source_group>-source_unit <>
              ls_source_allocation-source_unit
            OR <ls_source_group>-base_unit <>
              ls_source_allocation-base_unit.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        <ls_source_group>-plant_base_quantity =
          <ls_source_group>-plant_base_quantity
          + ls_source_allocation-allocation-allocated_quantity.
      ELSE.
        INSERT VALUE #(
          request_id          = ls_source_allocation-allocation-request_id
          material            = ls_source_allocation-allocation-material
          target_plant        = ls_source_allocation-allocation-target_plant
          source_plant        = ls_source_allocation-allocation-source_plant
          batch               = ls_source_allocation-allocation-batch
          source_unit         = ls_source_allocation-source_unit
          base_unit           = ls_source_allocation-base_unit
          plant_base_quantity =
            ls_source_allocation-allocation-allocated_quantity )
          INTO TABLE lt_source_groups.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_demand_groups INTO DATA(ls_demand_group).
      IF ls_demand_group-demand_base_quantity <>
          ls_demand_group-source_base_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    IF is_allocation-location_allocations IS NOT INITIAL.
      LOOP AT is_allocation-location_allocations
          INTO DATA(ls_location_allocation).
        IF ls_location_allocation-allocation-allocated_quantity < 0
            OR ls_location_allocation-allocated_source_quantity < 0
            OR ls_location_allocation-allocation-available_quantity <
              ls_location_allocation-allocation-allocated_quantity
            OR ls_location_allocation-available_source_quantity <
              ls_location_allocation-allocated_source_quantity
            OR ( ls_location_allocation-allocation-allocated_quantity > 0
              AND ls_location_allocation-allocated_source_quantity <= 0 )
            OR ( ls_location_allocation-allocation-allocated_quantity = 0
              AND ls_location_allocation-allocated_source_quantity > 0 ).
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        IF ls_location_allocation-allocation-allocated_quantity = 0
            AND ls_location_allocation-allocated_source_quantity = 0.
          CONTINUE.
        ENDIF.
        IF ls_location_allocation-allocation-request_id IS INITIAL
            OR ls_location_allocation-allocation-material IS INITIAL
            OR ls_location_allocation-allocation-target_plant IS INITIAL
            OR ls_location_allocation-allocation-source_plant IS INITIAL
            OR ls_location_allocation-allocation-source_plant =
              ls_location_allocation-allocation-target_plant
            OR ls_location_allocation-allocation-storage_location IS INITIAL
            OR ls_location_allocation-allocation-batch IS INITIAL
            OR ls_location_allocation-source_unit IS INITIAL
            OR ls_location_allocation-base_unit IS INITIAL.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.

        READ TABLE lt_source_groups ASSIGNING <ls_source_group>
          WITH TABLE KEY
            request_id =
              ls_location_allocation-allocation-request_id
            material = ls_location_allocation-allocation-material
            target_plant =
              ls_location_allocation-allocation-target_plant
            source_plant =
              ls_location_allocation-allocation-source_plant
            batch = ls_location_allocation-allocation-batch.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        IF <ls_source_group>-source_unit <>
              ls_location_allocation-source_unit
            OR <ls_source_group>-base_unit <>
              ls_location_allocation-base_unit.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        <ls_source_group>-location_base_quantity =
          <ls_source_group>-location_base_quantity
          + ls_location_allocation-allocation-allocated_quantity.
      ENDLOOP.

      LOOP AT lt_source_groups INTO DATA(ls_source_group).
        IF ls_source_group-plant_base_quantity <>
            ls_source_group-location_base_quantity.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD mark_sto_for_deletion.
    DATA(ls_orders) = VALUE ty_plant_pairs_result(
      is_successful = abap_true
      is_test_run   = abap_false
      orders        = VALUE #( ( result = is_order ) ) ).
    DATA(ls_pairs_result) = mark_sto_pairs_for_deletion(
      is_orders   = ls_orders
      iv_test_run = iv_test_run ).
    rs_result = ls_pairs_result-orders[ 1 ]-deletion.
  ENDMETHOD.

  METHOD create_for_atp_fefo_pairs.
    DATA ls_plant_allocation TYPE
      zcl_stock_service=>ty_plant_date_atp_result.

    ls_plant_allocation-local_estimate-plant_allocations =
      is_allocation-local_estimate-plant_allocations.
    ls_plant_allocation-atp_checks = is_allocation-atp_checks.
    validate_atp_source_splits( is_allocation = ls_plant_allocation ).

    rs_result = create_for_fefo_pairs(
      is_allocation          = is_allocation-local_estimate
      it_receiving_locations = it_receiving_locations
      iv_company_code        = iv_company_code
      iv_purchasing_org      = iv_purchasing_org
      iv_purchasing_group    = iv_purchasing_group
      iv_allow_partial       = iv_allow_partial
      iv_test_run            = iv_test_run
      iv_atomic              = iv_atomic ).
  ENDMETHOD.

  METHOD create_for_fefo_atp_pairs.
    DATA ls_dated_allocation TYPE
      zcl_stock_service=>ty_unit_date_plant_fefo_result.

    IF iv_delivery_date IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    validate_fefo_atp( is_allocation = is_allocation ).

    LOOP AT is_allocation-local_estimate-allocations
        INTO DATA(ls_demand_allocation).
      DATA(ls_dated_demand) = VALUE
        zcl_stock_service=>ty_unit_date_plant_demand_allocation(
          allocation                = CORRESPONDING #( ls_demand_allocation-allocation )
          source_quantity           = ls_demand_allocation-source_quantity
          source_unit               = ls_demand_allocation-source_unit
          base_quantity             = ls_demand_allocation-base_quantity
          base_unit                 = ls_demand_allocation-base_unit
          available_source_quantity =
            ls_demand_allocation-available_source_quantity
          allocated_source_quantity =
            ls_demand_allocation-allocated_source_quantity
          shortfall_source_quantity =
            ls_demand_allocation-shortfall_source_quantity ).
      ls_dated_demand-allocation-required_date = iv_delivery_date.
      APPEND ls_dated_demand TO ls_dated_allocation-allocations.
    ENDLOOP.

    LOOP AT is_allocation-local_estimate-plant_allocations
        INTO DATA(ls_source_allocation).
      DATA(ls_dated_source) = VALUE
        zcl_stock_service=>ty_unit_date_plant_source_allocation(
          allocation                = CORRESPONDING #( ls_source_allocation-allocation )
          source_unit               = ls_source_allocation-source_unit
          base_unit                 = ls_source_allocation-base_unit
          available_source_quantity =
            ls_source_allocation-available_source_quantity
          allocated_source_quantity =
            ls_source_allocation-allocated_source_quantity ).
      ls_dated_source-allocation-required_date = iv_delivery_date.
      APPEND ls_dated_source TO ls_dated_allocation-plant_allocations.
    ENDLOOP.

    LOOP AT is_allocation-local_estimate-batch_allocations
        INTO DATA(ls_batch_allocation).
      DATA(ls_dated_batch) = VALUE
        zcl_stock_service=>ty_unit_date_plant_fefo_batch_split(
          source_unit               = ls_batch_allocation-source_unit
          base_unit                 = ls_batch_allocation-base_unit
          available_source_quantity =
            ls_batch_allocation-available_source_quantity
          allocated_source_quantity =
            ls_batch_allocation-allocated_source_quantity ).
      ls_dated_batch-allocation-allocation =
        CORRESPONDING #( ls_batch_allocation-allocation ).
      ls_dated_batch-allocation-required_date = iv_delivery_date.
      APPEND ls_dated_batch TO ls_dated_allocation-batch_allocations.
    ENDLOOP.

    rs_result = create_for_fefo_pairs(
      is_allocation          = ls_dated_allocation
      it_receiving_locations = it_receiving_locations
      iv_company_code        = iv_company_code
      iv_purchasing_org      = iv_purchasing_org
      iv_purchasing_group    = iv_purchasing_group
      iv_allow_partial       = iv_allow_partial
      iv_test_run            = iv_test_run
      iv_atomic              = iv_atomic ).
  ENDMETHOD.

  METHOD execute_pair_orders.
    rs_result-is_successful = abap_true.
    rs_result-is_test_run = iv_test_run.

    LOOP AT it_prepared_orders INTO DATA(ls_prepared_order).
      DATA(ls_order_result) = complete_write(
        is_request      = ls_prepared_order-request
        is_result       = mo_api->create_order(
          ls_prepared_order-request )
        iv_defer_commit = iv_atomic ).
      ls_order_result-submitted_items =
        ls_prepared_order-request-items.
      APPEND VALUE #(
        supplying_plant = ls_prepared_order-supplying_plant
        receiving_plant = ls_prepared_order-receiving_plant
        result          = ls_order_result ) TO rs_result-orders.
      IF ls_order_result-is_successful <> abap_true.
        rs_result-is_successful = abap_false.
        IF iv_atomic = abap_true.
          LOOP AT rs_result-orders
              ASSIGNING FIELD-SYMBOL(<ls_pair_result>).
            <ls_pair_result>-result-is_successful = abap_false.
            <ls_pair_result>-result-is_committed = abap_false.
          ENDLOOP.
          EXIT.
        ENDIF.
      ENDIF.
    ENDLOOP.

    IF iv_atomic = abap_true
        AND rs_result-is_successful = abap_true
        AND iv_test_run = abap_false.
      DATA(ls_commit_result) = mo_api->commit( ).
      IF ls_commit_result-is_successful = abap_true.
        LOOP AT rs_result-orders ASSIGNING <ls_pair_result>.
          <ls_pair_result>-result-is_committed = abap_true.
        ENDLOOP.
      ELSE.
        mo_api->rollback( ).
        LOOP AT rs_result-orders ASSIGNING <ls_pair_result>.
          <ls_pair_result>-result-is_successful = abap_false.
          <ls_pair_result>-result-is_committed = abap_false.
        ENDLOOP.
        READ TABLE rs_result-orders ASSIGNING <ls_pair_result>
          INDEX lines( rs_result-orders ).
        IF sy-subrc = 0.
          APPEND ls_commit_result-message
            TO <ls_pair_result>-result-messages.
        ENDIF.
        rs_result-is_successful = abap_false.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD validate_atp_source_splits.
    DATA lv_atp_match_count TYPE i.
    DATA ls_atp_check TYPE zcl_stock_service=>ty_plant_date_atp_check.

    IF is_allocation-atp_checks IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT is_allocation-local_estimate-plant_allocations
        INTO DATA(ls_source_allocation).
      IF ls_source_allocation-allocation-allocated_quantity <= 0
          OR ( iv_receiving_plant IS NOT INITIAL
            AND ls_source_allocation-allocation-target_plant <>
              iv_receiving_plant ).
        CONTINUE.
      ENDIF.

      CLEAR: lv_atp_match_count, ls_atp_check.
      LOOP AT is_allocation-atp_checks INTO DATA(ls_candidate_check).
        IF ls_candidate_check-request_id =
              ls_source_allocation-allocation-request_id
            AND ls_candidate_check-material =
              ls_source_allocation-allocation-material
            AND ls_candidate_check-target_plant =
              ls_source_allocation-allocation-target_plant
            AND ls_candidate_check-source_plant =
              ls_source_allocation-allocation-source_plant
            AND ls_candidate_check-required_date =
              ls_source_allocation-allocation-required_date.
          ADD 1 TO lv_atp_match_count.
          ls_atp_check = ls_candidate_check.
        ENDIF.
      ENDLOOP.

      IF lv_atp_match_count <> 1
          OR ls_atp_check-base_unit <>
            ls_source_allocation-base_unit
          OR ls_atp_check-allocated_base_quantity <>
            ls_source_allocation-allocation-allocated_quantity
          OR ls_atp_check-cumulative_base_quantity <
            ls_atp_check-allocated_base_quantity
          OR ls_atp_check-atp_result-material <>
            ls_atp_check-material
          OR ls_atp_check-atp_result-plant <>
            ls_atp_check-source_plant
          OR ls_atp_check-atp_result-unit <>
            ls_atp_check-base_unit
          OR ls_atp_check-atp_result-required_date <>
            ls_atp_check-required_date
          OR ls_atp_check-atp_result-requested_quantity <>
            ls_atp_check-cumulative_base_quantity
          OR ls_atp_check-atp_result-check_rule IS INITIAL
          OR ls_atp_check-atp_result-is_check_relevant <>
            abap_true
          OR ls_atp_check-confirmed_base_quantity <
            ls_atp_check-cumulative_base_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validate_fefo_atp.
    TYPES:
      BEGIN OF ty_fefo_atp_group,
        material      TYPE mard-matnr,
        source_plant  TYPE mard-werks,
        base_unit     TYPE mara-meins,
        allocated_qty TYPE mard-labst,
      END OF ty_fefo_atp_group.
    TYPES ty_fefo_atp_groups TYPE SORTED TABLE OF ty_fefo_atp_group
      WITH UNIQUE KEY material source_plant base_unit.
    DATA lt_groups TYPE ty_fefo_atp_groups.
    DATA lv_match_count TYPE i.
    DATA ls_atp_check TYPE zcl_stock_service=>ty_plant_atp_check.
    FIELD-SYMBOLS <ls_group> TYPE ty_fefo_atp_group.

    LOOP AT is_allocation-local_estimate-plant_allocations
        INTO DATA(ls_source_allocation).
      IF ls_source_allocation-allocation-allocated_quantity <= 0.
        CONTINUE.
      ENDIF.
      READ TABLE lt_groups ASSIGNING <ls_group>
        WITH TABLE KEY material =
            ls_source_allocation-allocation-material
          source_plant =
            ls_source_allocation-allocation-source_plant
          base_unit = ls_source_allocation-base_unit.
      IF sy-subrc = 0.
        <ls_group>-allocated_qty = <ls_group>-allocated_qty
          + ls_source_allocation-allocation-allocated_quantity.
      ELSE.
        INSERT VALUE #(
          material      = ls_source_allocation-allocation-material
          source_plant  =
            ls_source_allocation-allocation-source_plant
          base_unit     = ls_source_allocation-base_unit
          allocated_qty =
            ls_source_allocation-allocation-allocated_quantity )
          INTO TABLE lt_groups.
      ENDIF.
    ENDLOOP.

    IF lines( is_allocation-atp_checks ) <> lines( lt_groups ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT lt_groups INTO DATA(ls_group).
      CLEAR: lv_match_count, ls_atp_check.
      LOOP AT is_allocation-atp_checks INTO DATA(ls_candidate_check).
        IF ls_candidate_check-material = ls_group-material
            AND ls_candidate_check-source_plant = ls_group-source_plant
            AND ls_candidate_check-base_unit = ls_group-base_unit.
          ADD 1 TO lv_match_count.
          ls_atp_check = ls_candidate_check.
        ENDIF.
      ENDLOOP.

      IF lv_match_count <> 1
          OR ls_atp_check-check_date IS INITIAL
          OR ls_atp_check-allocated_base_quantity <>
            ls_group-allocated_qty
          OR ls_atp_check-confirmed_base_quantity <
            ls_group-allocated_qty
          OR ls_atp_check-confirmed_base_quantity
            + ls_atp_check-unconfirmed_base_quantity <>
              ls_group-allocated_qty
          OR ls_atp_check-atp_result-material <> ls_group-material
          OR ls_atp_check-atp_result-plant <> ls_group-source_plant
          OR ls_atp_check-atp_result-unit <> ls_group-base_unit
          OR ls_atp_check-atp_result-required_date <>
            ls_atp_check-check_date
          OR ls_atp_check-atp_result-requested_quantity <>
            ls_group-allocated_qty
          OR ls_atp_check-atp_result-check_rule IS INITIAL
          OR ls_atp_check-atp_result-is_check_relevant <> abap_true.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validate_batch_atp.
    TYPES:
      BEGIN OF ty_batch_atp_group,
        material      TYPE mard-matnr,
        source_plant  TYPE mard-werks,
        base_unit     TYPE mara-meins,
        allocated_qty TYPE mard-labst,
      END OF ty_batch_atp_group.
    TYPES ty_batch_atp_groups TYPE SORTED TABLE OF ty_batch_atp_group
      WITH UNIQUE KEY material source_plant base_unit.
    DATA lt_groups TYPE ty_batch_atp_groups.
    DATA lv_match_count TYPE i.
    DATA ls_atp_check TYPE zcl_stock_service=>ty_plant_atp_check.
    FIELD-SYMBOLS <ls_group> TYPE ty_batch_atp_group.

    LOOP AT is_allocation-local_estimate-plant_allocations
        INTO DATA(ls_source_allocation).
      IF ls_source_allocation-allocation-allocated_quantity <= 0.
        CONTINUE.
      ENDIF.
      READ TABLE lt_groups ASSIGNING <ls_group>
        WITH TABLE KEY material =
            ls_source_allocation-allocation-material
          source_plant =
            ls_source_allocation-allocation-source_plant
          base_unit = ls_source_allocation-base_unit.
      IF sy-subrc = 0.
        <ls_group>-allocated_qty = <ls_group>-allocated_qty
          + ls_source_allocation-allocation-allocated_quantity.
      ELSE.
        INSERT VALUE #(
          material      = ls_source_allocation-allocation-material
          source_plant  =
            ls_source_allocation-allocation-source_plant
          base_unit     = ls_source_allocation-base_unit
          allocated_qty =
            ls_source_allocation-allocation-allocated_quantity )
          INTO TABLE lt_groups.
      ENDIF.
    ENDLOOP.

    IF lines( is_allocation-atp_checks ) <> lines( lt_groups ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT lt_groups INTO DATA(ls_group).
      CLEAR: lv_match_count, ls_atp_check.
      LOOP AT is_allocation-atp_checks INTO DATA(ls_candidate_check).
        IF ls_candidate_check-material = ls_group-material
            AND ls_candidate_check-source_plant = ls_group-source_plant
            AND ls_candidate_check-base_unit = ls_group-base_unit.
          ADD 1 TO lv_match_count.
          ls_atp_check = ls_candidate_check.
        ENDIF.
      ENDLOOP.

      IF lv_match_count <> 1
          OR ls_atp_check-check_date IS INITIAL
          OR ls_atp_check-allocated_base_quantity <>
            ls_group-allocated_qty
          OR ls_atp_check-confirmed_base_quantity <
            ls_group-allocated_qty
          OR ls_atp_check-confirmed_base_quantity
            + ls_atp_check-unconfirmed_base_quantity <>
              ls_group-allocated_qty
          OR ls_atp_check-atp_result-material <> ls_group-material
          OR ls_atp_check-atp_result-plant <> ls_group-source_plant
          OR ls_atp_check-atp_result-unit <> ls_group-base_unit
          OR ls_atp_check-atp_result-required_date <>
            ls_atp_check-check_date
          OR ls_atp_check-atp_result-requested_quantity <>
            ls_group-allocated_qty
          OR ls_atp_check-atp_result-check_rule IS INITIAL
          OR ls_atp_check-atp_result-is_check_relevant <> abap_true.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD mark_sto_pairs_for_deletion.
    TYPES ty_seen_po TYPE eord-ebeln.
    DATA lt_seen_pos TYPE SORTED TABLE OF ty_seen_po
      WITH UNIQUE KEY table_line.
    DATA lt_prepared_deletions TYPE ty_prepared_deletions.
    DATA lt_item_numbers TYPE zif_stock_transfer_order_api=>ty_item_numbers.
    DATA lt_seen_items TYPE SORTED TABLE OF
      zif_stock_transfer_order_api=>ty_item_number
      WITH UNIQUE KEY table_line.

    IF is_orders-orders IS INITIAL
        OR is_orders-is_test_run <> abap_false
        OR ( is_orders-is_successful <> abap_true
          AND is_orders-is_successful <> abap_false )
        OR ( iv_atomic <> abap_true
          AND iv_atomic <> abap_false )
        OR ( iv_test_run <> abap_true
          AND iv_test_run <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    rs_result-is_successful = is_orders-is_successful.
    rs_result-is_test_run = iv_test_run.
    LOOP AT is_orders-orders INTO DATA(ls_order_pair).
      IF ( ls_order_pair-result-is_successful <> abap_true
          AND ls_order_pair-result-is_successful <> abap_false )
          OR ( ls_order_pair-result-is_test_run <> abap_true
            AND ls_order_pair-result-is_test_run <> abap_false )
          OR ( ls_order_pair-result-is_committed <> abap_true
            AND ls_order_pair-result-is_committed <> abap_false ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      APPEND VALUE #(
        supplying_plant = ls_order_pair-supplying_plant
        receiving_plant = ls_order_pair-receiving_plant
        deletion        = VALUE #(
          order_result = ls_order_pair-result
          is_test_run  = iv_test_run ) )
        TO rs_result-orders.

      IF ls_order_pair-result-is_successful <> abap_true
          OR ls_order_pair-result-is_committed <> abap_true
          OR ls_order_pair-result-is_test_run <> abap_false.
        rs_result-is_successful = abap_false.
        CONTINUE.
      ENDIF.
      IF ls_order_pair-result-purchase_order_number IS INITIAL
          OR ls_order_pair-result-submitted_items IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      CLEAR: lt_item_numbers, lt_seen_items.

      INSERT ls_order_pair-result-purchase_order_number INTO TABLE
        lt_seen_pos.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      LOOP AT ls_order_pair-result-submitted_items
          INTO DATA(ls_submitted_item).
        IF ls_submitted_item-item_number IS INITIAL.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        INSERT ls_submitted_item-item_number INTO TABLE lt_seen_items.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        APPEND ls_submitted_item-item_number TO lt_item_numbers.
      ENDLOOP.

      APPEND VALUE #(
        result_index = lines( rs_result-orders )
        order_result = ls_order_pair-result
        item_numbers = lt_item_numbers ) TO lt_prepared_deletions.
    ENDLOOP.

    IF iv_atomic = abap_true
        AND rs_result-is_successful <> abap_true.
      RETURN.
    ENDIF.

    LOOP AT lt_prepared_deletions INTO DATA(ls_prepared_deletion).
      DATA(ls_deletion_result) = complete_deletion(
        is_order        = ls_prepared_deletion-order_result
        it_item_numbers = ls_prepared_deletion-item_numbers
        iv_defer_commit = iv_atomic
        iv_test_run     = iv_test_run ).
      READ TABLE rs_result-orders ASSIGNING FIELD-SYMBOL(<ls_deletion_pair>)
        INDEX ls_prepared_deletion-result_index.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      <ls_deletion_pair>-deletion = ls_deletion_result.
      IF ls_deletion_result-is_successful <> abap_true.
        rs_result-is_successful = abap_false.
        IF iv_atomic = abap_true AND iv_test_run = abap_false.
          LOOP AT rs_result-orders ASSIGNING <ls_deletion_pair>.
            <ls_deletion_pair>-deletion-is_successful = abap_false.
            <ls_deletion_pair>-deletion-is_deleted = abap_false.
          ENDLOOP.
          EXIT.
        ENDIF.
      ENDIF.
    ENDLOOP.

    IF iv_atomic = abap_true
        AND iv_test_run = abap_false
        AND rs_result-is_successful = abap_true.
      DATA(ls_commit_result) = mo_api->commit( ).
      IF ls_commit_result-is_successful <> abap_true.
        mo_api->rollback( ).
        LOOP AT rs_result-orders ASSIGNING <ls_deletion_pair>.
          <ls_deletion_pair>-deletion-is_successful = abap_false.
          <ls_deletion_pair>-deletion-is_deleted = abap_false.
        ENDLOOP.
        READ TABLE rs_result-orders ASSIGNING <ls_deletion_pair>
          INDEX lines( rs_result-orders ).
        IF sy-subrc = 0.
          APPEND ls_commit_result-message
            TO <ls_deletion_pair>-deletion-deletion_messages.
        ENDIF.
        rs_result-is_successful = abap_false.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD mark_sto_delivery_complete.
    DATA(ls_orders) = VALUE ty_plant_pairs_result(
      is_successful = abap_true
      is_test_run   = abap_false
      orders        = VALUE #( ( result = is_order ) ) ).
    DATA(ls_pairs_result) = mark_sto_pairs_deliv_complete(
      is_orders   = ls_orders
      iv_test_run = iv_test_run ).
    rs_result = ls_pairs_result-orders[ 1 ]-delivery_completion.
  ENDMETHOD.

  METHOD mark_sto_pairs_deliv_complete.
    TYPES ty_seen_po TYPE eord-ebeln.
    DATA lt_seen_pos TYPE SORTED TABLE OF ty_seen_po
      WITH UNIQUE KEY table_line.
    DATA lt_prepared_completions TYPE ty_prepared_completions.
    DATA lt_item_numbers TYPE zif_stock_transfer_order_api=>ty_item_numbers.
    DATA lt_seen_items TYPE SORTED TABLE OF
      zif_stock_transfer_order_api=>ty_item_number
      WITH UNIQUE KEY table_line.

    IF is_orders-orders IS INITIAL
        OR is_orders-is_test_run <> abap_false
        OR ( is_orders-is_successful <> abap_true
          AND is_orders-is_successful <> abap_false )
        OR ( iv_atomic <> abap_true
          AND iv_atomic <> abap_false )
        OR ( iv_test_run <> abap_true
          AND iv_test_run <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    rs_result-is_successful = is_orders-is_successful.
    rs_result-is_test_run = iv_test_run.
    LOOP AT is_orders-orders INTO DATA(ls_order_pair).
      IF ( ls_order_pair-result-is_successful <> abap_true
          AND ls_order_pair-result-is_successful <> abap_false )
          OR ( ls_order_pair-result-is_test_run <> abap_true
            AND ls_order_pair-result-is_test_run <> abap_false )
          OR ( ls_order_pair-result-is_committed <> abap_true
            AND ls_order_pair-result-is_committed <> abap_false ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      APPEND VALUE #(
        supplying_plant     = ls_order_pair-supplying_plant
        receiving_plant     = ls_order_pair-receiving_plant
        delivery_completion = VALUE #(
          order_result = ls_order_pair-result
          is_test_run  = iv_test_run ) )
        TO rs_result-orders.

      IF ls_order_pair-result-is_successful <> abap_true
          OR ls_order_pair-result-is_committed <> abap_true
          OR ls_order_pair-result-is_test_run <> abap_false.
        rs_result-is_successful = abap_false.
        CONTINUE.
      ENDIF.
      IF ls_order_pair-result-purchase_order_number IS INITIAL
          OR ls_order_pair-result-submitted_items IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      CLEAR: lt_item_numbers, lt_seen_items.

      INSERT ls_order_pair-result-purchase_order_number INTO TABLE
        lt_seen_pos.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      LOOP AT ls_order_pair-result-submitted_items
          INTO DATA(ls_submitted_item).
        IF ls_submitted_item-item_number IS INITIAL.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        INSERT ls_submitted_item-item_number INTO TABLE lt_seen_items.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        APPEND ls_submitted_item-item_number TO lt_item_numbers.
      ENDLOOP.

      APPEND VALUE #(
        result_index = lines( rs_result-orders )
        order_result = ls_order_pair-result
        item_numbers = lt_item_numbers ) TO lt_prepared_completions.
    ENDLOOP.

    IF iv_atomic = abap_true
        AND rs_result-is_successful <> abap_true.
      RETURN.
    ENDIF.

    LOOP AT lt_prepared_completions INTO DATA(ls_prepared_completion).
      DATA(ls_completion_result) = complete_delivery_mark(
        is_order        = ls_prepared_completion-order_result
        it_item_numbers = ls_prepared_completion-item_numbers
        iv_defer_commit = iv_atomic
        iv_test_run     = iv_test_run ).
      READ TABLE rs_result-orders ASSIGNING
        FIELD-SYMBOL(<ls_completion_pair>)
        INDEX ls_prepared_completion-result_index.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      <ls_completion_pair>-delivery_completion = ls_completion_result.
      IF ls_completion_result-is_successful <> abap_true.
        rs_result-is_successful = abap_false.
        IF iv_atomic = abap_true AND iv_test_run = abap_false.
          LOOP AT rs_result-orders ASSIGNING <ls_completion_pair>.
            <ls_completion_pair>-delivery_completion-is_successful =
              abap_false.
            <ls_completion_pair>-delivery_completion-is_completed =
              abap_false.
          ENDLOOP.
          EXIT.
        ENDIF.
      ENDIF.
    ENDLOOP.

    IF iv_atomic = abap_true
        AND iv_test_run = abap_false
        AND rs_result-is_successful = abap_true.
      DATA(ls_commit_result) = mo_api->commit( ).
      IF ls_commit_result-is_successful <> abap_true.
        mo_api->rollback( ).
        LOOP AT rs_result-orders ASSIGNING <ls_completion_pair>.
          <ls_completion_pair>-delivery_completion-is_successful =
            abap_false.
          <ls_completion_pair>-delivery_completion-is_completed =
            abap_false.
        ENDLOOP.
        READ TABLE rs_result-orders ASSIGNING <ls_completion_pair>
          INDEX lines( rs_result-orders ).
        IF sy-subrc = 0.
          APPEND ls_commit_result-message TO
            <ls_completion_pair>-delivery_completion-completion_messages.
        ENDIF.
        rs_result-is_successful = abap_false.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD validate_delivery_date.
    IF zcl_date_validation=>is_valid_gregorian_date(
        iv_date = iv_date ) <> abap_true.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
  ENDMETHOD.

  METHOD build_request.
    TYPES ty_request_id TYPE c LENGTH 30.
    DATA lv_item_number TYPE n LENGTH 5.
    DATA lt_request_ids TYPE SORTED TABLE OF ty_request_id
      WITH UNIQUE KEY table_line.

    IF iv_supplying_plant IS INITIAL
        OR iv_receiving_plant IS INITIAL
        OR iv_supplying_plant = iv_receiving_plant
        OR iv_company_code IS INITIAL
        OR iv_purchasing_org IS INITIAL
        OR iv_purchasing_group IS INITIAL
        OR ( iv_allow_partial <> abap_true
          AND iv_allow_partial <> abap_false )
        OR ( iv_test_run <> abap_true AND iv_test_run <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    IF iv_allow_partial = abap_false.
      LOOP AT is_allocation-allocations
          INTO DATA(ls_demand_allocation).
        IF ls_demand_allocation-allocation-target_plant
              = iv_receiving_plant
            AND ls_demand_allocation-allocation-shortfall_quantity > 0.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
      ENDLOOP.
    ENDIF.

    rs_request-document_type = c_document_type.
    rs_request-company_code = iv_company_code.
    rs_request-purchasing_org = iv_purchasing_org.
    rs_request-purchasing_group = iv_purchasing_group.
    rs_request-is_test_run = iv_test_run.

    LOOP AT is_allocation-plant_allocations
        INTO DATA(ls_source_allocation).
      IF ls_source_allocation-allocation-source_plant
            <> iv_supplying_plant
          OR ls_source_allocation-allocation-target_plant
            <> iv_receiving_plant
          OR ls_source_allocation-allocation-allocated_quantity <= 0.
        CONTINUE.
      ENDIF.
      IF ls_source_allocation-allocation-request_id IS INITIAL
          OR ls_source_allocation-allocation-material IS INITIAL
          OR ls_source_allocation-allocation-required_date IS INITIAL
          OR ls_source_allocation-source_unit IS INITIAL
          OR ls_source_allocation-base_unit IS INITIAL
          OR ls_source_allocation-allocated_source_quantity <= 0
          OR ls_source_allocation-available_source_quantity
            < ls_source_allocation-allocated_source_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      validate_delivery_date(
        iv_date = ls_source_allocation-allocation-required_date ).
      INSERT ls_source_allocation-allocation-request_id
        INTO TABLE lt_request_ids.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      ADD 10 TO lv_item_number.
      APPEND VALUE #(
        item_number           = lv_item_number
        source_request_id     =
          ls_source_allocation-allocation-request_id
        material              = ls_source_allocation-allocation-material
        supplying_plant       =
          ls_source_allocation-allocation-source_plant
        receiving_plant       =
          ls_source_allocation-allocation-target_plant
        receiving_storage_loc = iv_receiving_storage_loc
        quantity              =
          ls_source_allocation-allocated_source_quantity
        unit                  = ls_source_allocation-source_unit
        delivery_date         =
          ls_source_allocation-allocation-required_date )
        TO rs_request-items.
    ENDLOOP.

    IF rs_request-items IS INITIAL
        OR lines( rs_request-items ) > 9999.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
  ENDMETHOD.

  METHOD build_date_loc_request.
    DATA lv_item_number TYPE n LENGTH 5.

    IF iv_supplying_plant IS INITIAL
        OR iv_receiving_plant IS INITIAL
        OR iv_supplying_plant = iv_receiving_plant
        OR iv_company_code IS INITIAL
        OR iv_purchasing_org IS INITIAL
        OR iv_purchasing_group IS INITIAL
        OR ( iv_allow_partial <> abap_true
          AND iv_allow_partial <> abap_false )
        OR ( iv_test_run <> abap_true
          AND iv_test_run <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    IF iv_allow_partial = abap_false.
      LOOP AT is_allocation-allocations
          INTO DATA(ls_demand_allocation).
        IF ls_demand_allocation-allocation-target_plant
              = iv_receiving_plant
            AND ls_demand_allocation-allocation-shortfall_quantity > 0.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
      ENDLOOP.
    ENDIF.

    rs_request-document_type = c_document_type.
    rs_request-company_code = iv_company_code.
    rs_request-purchasing_org = iv_purchasing_org.
    rs_request-purchasing_group = iv_purchasing_group.
    rs_request-is_test_run = iv_test_run.

    LOOP AT is_allocation-location_allocations
        INTO DATA(ls_location_split).
      IF ls_location_split-allocation-allocation-source_plant
            <> iv_supplying_plant
          OR ls_location_split-allocation-allocation-target_plant
            <> iv_receiving_plant.
        CONTINUE.
      ENDIF.
      IF ls_location_split-allocation-allocation-allocated_quantity <= 0
          OR ls_location_split-allocated_source_quantity <= 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      validate_delivery_date(
        iv_date = ls_location_split-allocation-required_date ).

      ADD 10 TO lv_item_number.
      APPEND VALUE #(
        item_number           = lv_item_number
        source_request_id     =
          ls_location_split-allocation-allocation-request_id
        material              =
          ls_location_split-allocation-allocation-material
        supplying_plant       =
          ls_location_split-allocation-allocation-source_plant
        supplying_storage_loc =
          ls_location_split-allocation-allocation-storage_location
        receiving_plant       =
          ls_location_split-allocation-allocation-target_plant
        receiving_storage_loc = iv_receiving_storage_loc
        quantity              =
          ls_location_split-allocation-allocation-allocated_quantity
        unit                  = ls_location_split-base_unit
        delivery_date         =
          ls_location_split-allocation-required_date )
        TO rs_request-items.
    ENDLOOP.

    IF rs_request-items IS INITIAL
        OR lines( rs_request-items ) > 9999.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
  ENDMETHOD.

  METHOD validate_date_loc_pair_totals.
    TYPES:
      BEGIN OF ty_source_location_group,
        request_id             TYPE c LENGTH 30,
        material               TYPE mard-matnr,
        target_plant           TYPE mard-werks,
        source_plant           TYPE mard-werks,
        required_date          TYPE resb-bdter,
        priority               TYPE i,
        source_unit            TYPE mara-meins,
        base_unit              TYPE mara-meins,
        plant_base_quantity    TYPE mard-labst,
        location_base_quantity TYPE mard-labst,
      END OF ty_source_location_group.
    TYPES ty_source_location_groups TYPE SORTED TABLE OF
      ty_source_location_group WITH UNIQUE KEY request_id source_plant.
    TYPES:
      BEGIN OF ty_location_split_key,
        request_id       TYPE c LENGTH 30,
        source_plant     TYPE mard-werks,
        storage_location TYPE mard-lgort,
      END OF ty_location_split_key.
    TYPES ty_location_split_keys TYPE SORTED TABLE OF ty_location_split_key
      WITH UNIQUE KEY request_id source_plant storage_location.
    DATA ls_plant_allocation TYPE
      zcl_stock_service=>ty_unit_date_plant_result.
    DATA lt_source_groups TYPE ty_source_location_groups.
    DATA lt_location_keys TYPE ty_location_split_keys.
    FIELD-SYMBOLS <ls_source_group> TYPE ty_source_location_group.

    ls_plant_allocation-allocations =
      CORRESPONDING #( is_allocation-allocations ).
    ls_plant_allocation-plant_allocations =
      CORRESPONDING #( is_allocation-plant_allocations ).
    validate_plant_pair_totals( is_allocation = ls_plant_allocation ).

    LOOP AT is_allocation-allocations INTO DATA(ls_demand_allocation).
      validate_delivery_date(
        iv_date = ls_demand_allocation-allocation-required_date ).
      IF ls_demand_allocation-base_quantity < 0
          OR ls_demand_allocation-allocation-requested_quantity < 0
          OR ls_demand_allocation-allocation-allocated_quantity < 0
          OR ls_demand_allocation-allocation-shortfall_quantity < 0
          OR ls_demand_allocation-base_quantity <>
            ls_demand_allocation-allocation-requested_quantity
          OR ls_demand_allocation-allocation-requested_quantity <>
            ls_demand_allocation-allocation-allocated_quantity
              + ls_demand_allocation-allocation-shortfall_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT is_allocation-plant_allocations
        INTO DATA(ls_plant_split).
      IF ls_plant_split-allocation-allocated_quantity <= 0
          OR ls_plant_split-allocated_source_quantity <= 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      validate_delivery_date(
        iv_date = ls_plant_split-allocation-required_date ).
      INSERT VALUE #(
        request_id          = ls_plant_split-allocation-request_id
        material            = ls_plant_split-allocation-material
        target_plant        = ls_plant_split-allocation-target_plant
        source_plant        = ls_plant_split-allocation-source_plant
        required_date       = ls_plant_split-allocation-required_date
        priority            = ls_plant_split-allocation-priority
        source_unit         = ls_plant_split-source_unit
        base_unit           = ls_plant_split-base_unit
        plant_base_quantity =
          ls_plant_split-allocation-allocated_quantity )
        INTO TABLE lt_source_groups.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT is_allocation-location_allocations
        INTO DATA(ls_location_split).
      IF ls_location_split-allocation-allocation-request_id IS INITIAL
          OR ls_location_split-allocation-allocation-material IS INITIAL
          OR ls_location_split-allocation-allocation-target_plant IS INITIAL
          OR ls_location_split-allocation-allocation-source_plant IS INITIAL
          OR ls_location_split-allocation-allocation-source_plant =
            ls_location_split-allocation-allocation-target_plant
          OR ls_location_split-allocation-required_date IS INITIAL
          OR ls_location_split-allocation-allocation-storage_location
            IS INITIAL
          OR ls_location_split-source_unit IS INITIAL
          OR ls_location_split-base_unit IS INITIAL
          OR ls_location_split-allocation-allocation-allocated_quantity <= 0
          OR ls_location_split-allocated_source_quantity <= 0
          OR ls_location_split-allocation-allocation-available_quantity <
            ls_location_split-allocation-allocation-allocated_quantity
          OR ls_location_split-available_source_quantity <
            ls_location_split-allocated_source_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      validate_delivery_date(
        iv_date = ls_location_split-allocation-required_date ).

      INSERT VALUE #(
        request_id       =
          ls_location_split-allocation-allocation-request_id
        source_plant     =
          ls_location_split-allocation-allocation-source_plant
        storage_location =
          ls_location_split-allocation-allocation-storage_location )
        INTO TABLE lt_location_keys.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      READ TABLE lt_source_groups ASSIGNING <ls_source_group>
        WITH TABLE KEY
          request_id =
            ls_location_split-allocation-allocation-request_id
          source_plant =
            ls_location_split-allocation-allocation-source_plant.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      IF <ls_source_group>-material <>
            ls_location_split-allocation-allocation-material
          OR <ls_source_group>-target_plant <>
            ls_location_split-allocation-allocation-target_plant
          OR <ls_source_group>-required_date <>
            ls_location_split-allocation-required_date
          OR <ls_source_group>-priority <>
            ls_location_split-allocation-priority
          OR <ls_source_group>-source_unit <>
            ls_location_split-source_unit
          OR <ls_source_group>-base_unit <>
            ls_location_split-base_unit.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      <ls_source_group>-location_base_quantity =
        <ls_source_group>-location_base_quantity
        + ls_location_split-allocation-allocation-allocated_quantity.
    ENDLOOP.

    LOOP AT lt_source_groups INTO DATA(ls_source_group).
      IF ls_source_group-plant_base_quantity <>
          ls_source_group-location_base_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD build_batch_request.
    TYPES:
      BEGIN OF ty_batch_item_key,
        request_id            TYPE c LENGTH 30,
        material              TYPE mard-matnr,
        batch                 TYPE mchb-charg,
        supplying_plant       TYPE mard-werks,
        supplying_storage_loc TYPE mard-lgort,
      END OF ty_batch_item_key,
      BEGIN OF ty_batch_item_source,
        request_id            TYPE c LENGTH 30,
        material              TYPE mard-matnr,
        batch                 TYPE mchb-charg,
        supplying_plant       TYPE mard-werks,
        supplying_storage_loc TYPE mard-lgort,
        available_quantity    TYPE mard-labst,
        allocated_quantity    TYPE mard-labst,
        source_unit           TYPE mara-meins,
      END OF ty_batch_item_source.
    DATA lv_item_number TYPE n LENGTH 5.
    DATA lt_batch_item_keys TYPE SORTED TABLE OF ty_batch_item_key
      WITH UNIQUE KEY request_id material batch supplying_plant
        supplying_storage_loc.
    DATA lt_batch_item_sources TYPE STANDARD TABLE OF ty_batch_item_source
      WITH EMPTY KEY.

    IF iv_supplying_plant IS INITIAL
        OR iv_receiving_plant IS INITIAL
        OR iv_supplying_plant = iv_receiving_plant
        OR iv_delivery_date IS INITIAL
        OR iv_company_code IS INITIAL
        OR iv_purchasing_org IS INITIAL
        OR iv_purchasing_group IS INITIAL
        OR ( iv_allow_partial <> abap_true
          AND iv_allow_partial <> abap_false )
        OR ( iv_test_run <> abap_true AND iv_test_run <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
    validate_delivery_date( iv_date = iv_delivery_date ).

    IF iv_allow_partial = abap_false.
      LOOP AT is_allocation-allocations
          INTO DATA(ls_demand_allocation).
        IF ls_demand_allocation-allocation-target_plant
              = iv_receiving_plant
            AND ls_demand_allocation-shortfall_source_quantity
              > 0.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
      ENDLOOP.
    ENDIF.

    rs_request-document_type = c_document_type.
    rs_request-company_code = iv_company_code.
    rs_request-purchasing_org = iv_purchasing_org.
    rs_request-purchasing_group = iv_purchasing_group.
    rs_request-is_test_run = iv_test_run.

    IF is_allocation-location_allocations IS INITIAL.
      LOOP AT is_allocation-plant_allocations
          INTO DATA(ls_source_allocation).
        IF ls_source_allocation-allocation-source_plant
              <> iv_supplying_plant
            OR ls_source_allocation-allocation-target_plant
              <> iv_receiving_plant
            OR ls_source_allocation-allocation-allocated_quantity <= 0
            OR ls_source_allocation-allocated_source_quantity <= 0.
          CONTINUE.
        ENDIF.
        APPEND VALUE #(
          request_id         = ls_source_allocation-allocation-request_id
          material           = ls_source_allocation-allocation-material
          batch              = ls_source_allocation-allocation-batch
          supplying_plant    =
            ls_source_allocation-allocation-source_plant
          available_quantity =
            ls_source_allocation-available_source_quantity
          allocated_quantity =
            ls_source_allocation-allocated_source_quantity
          source_unit        = ls_source_allocation-source_unit )
          TO lt_batch_item_sources.
      ENDLOOP.
    ELSE.
      LOOP AT is_allocation-location_allocations
          INTO DATA(ls_location_allocation).
        IF ls_location_allocation-allocation-source_plant
              <> iv_supplying_plant
            OR ls_location_allocation-allocation-target_plant
              <> iv_receiving_plant
            OR ls_location_allocation-allocation-allocated_quantity <= 0
            OR ls_location_allocation-allocated_source_quantity <= 0.
          CONTINUE.
        ENDIF.
        APPEND VALUE #(
          request_id            =
            ls_location_allocation-allocation-request_id
          material              =
            ls_location_allocation-allocation-material
          batch                 = ls_location_allocation-allocation-batch
          supplying_plant       =
            ls_location_allocation-allocation-source_plant
          supplying_storage_loc =
            ls_location_allocation-allocation-storage_location
          available_quantity    =
            ls_location_allocation-available_source_quantity
          allocated_quantity    =
            ls_location_allocation-allocated_source_quantity
          source_unit           = ls_location_allocation-source_unit )
          TO lt_batch_item_sources.
      ENDLOOP.
    ENDIF.

    LOOP AT lt_batch_item_sources INTO DATA(ls_item_source).
      IF ls_item_source-request_id IS INITIAL
          OR ls_item_source-material IS INITIAL
          OR ls_item_source-batch IS INITIAL
          OR ls_item_source-supplying_plant IS INITIAL
          OR ls_item_source-source_unit IS INITIAL
          OR ls_item_source-allocated_quantity <= 0
          OR ls_item_source-available_quantity <
            ls_item_source-allocated_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      INSERT VALUE #(
        request_id            = ls_item_source-request_id
        material              = ls_item_source-material
        batch                 = ls_item_source-batch
        supplying_plant       = ls_item_source-supplying_plant
        supplying_storage_loc = ls_item_source-supplying_storage_loc )
        INTO TABLE lt_batch_item_keys.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      ADD 10 TO lv_item_number.
      APPEND VALUE #(
        item_number           = lv_item_number
        source_request_id     = ls_item_source-request_id
        material              = ls_item_source-material
        batch                 = ls_item_source-batch
        supplying_plant       = ls_item_source-supplying_plant
        supplying_storage_loc = ls_item_source-supplying_storage_loc
        receiving_plant       = iv_receiving_plant
        receiving_storage_loc = iv_receiving_storage_loc
        quantity              = ls_item_source-allocated_quantity
        unit                  = ls_item_source-source_unit
        delivery_date         = iv_delivery_date )
        TO rs_request-items.
    ENDLOOP.

    IF rs_request-items IS INITIAL
        OR lines( rs_request-items ) > 9999.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
  ENDMETHOD.

  METHOD build_fefo_request.
    TYPES:
      BEGIN OF ty_fefo_item_key,
        request_id    TYPE c LENGTH 30,
        material      TYPE mard-matnr,
        batch         TYPE mchb-charg,
        storage_loc   TYPE mard-lgort,
        delivery_date TYPE d,
      END OF ty_fefo_item_key.
    DATA lv_item_number TYPE n LENGTH 5.
    DATA lt_fefo_item_keys TYPE SORTED TABLE OF ty_fefo_item_key
      WITH UNIQUE KEY request_id material batch storage_loc delivery_date.

    IF iv_supplying_plant IS INITIAL
        OR iv_receiving_plant IS INITIAL
        OR iv_supplying_plant = iv_receiving_plant
        OR iv_company_code IS INITIAL
        OR iv_purchasing_org IS INITIAL
        OR iv_purchasing_group IS INITIAL
        OR ( iv_allow_partial <> abap_true
          AND iv_allow_partial <> abap_false )
        OR ( iv_test_run <> abap_true AND iv_test_run <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    IF iv_allow_partial = abap_false.
      LOOP AT is_allocation-allocations
          INTO DATA(ls_demand_allocation).
        IF ls_demand_allocation-allocation-target_plant
              = iv_receiving_plant
            AND ls_demand_allocation-shortfall_source_quantity > 0.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
      ENDLOOP.
    ENDIF.

    rs_request-document_type = c_document_type.
    rs_request-company_code = iv_company_code.
    rs_request-purchasing_org = iv_purchasing_org.
    rs_request-purchasing_group = iv_purchasing_group.
    rs_request-is_test_run = iv_test_run.

    LOOP AT is_allocation-batch_allocations
        INTO DATA(ls_fefo_split).
      IF ls_fefo_split-allocation-allocation-source_plant
            <> iv_supplying_plant
          OR ls_fefo_split-allocation-allocation-target_plant
            <> iv_receiving_plant.
        CONTINUE.
      ENDIF.
      IF ls_fefo_split-allocation-allocation-allocated_quantity <= 0
          AND ls_fefo_split-allocated_source_quantity <= 0.
        CONTINUE.
      ENDIF.
      IF ls_fefo_split-allocation-allocation-request_id IS INITIAL
          OR ls_fefo_split-allocation-allocation-material IS INITIAL
          OR ls_fefo_split-allocation-allocation-batch IS INITIAL
          OR ls_fefo_split-allocation-allocation-storage_location IS INITIAL
          OR ls_fefo_split-allocation-required_date IS INITIAL
          OR ls_fefo_split-source_unit IS INITIAL
          OR ls_fefo_split-base_unit IS INITIAL
          OR ls_fefo_split-allocation-allocation-allocated_quantity <= 0
          OR ls_fefo_split-allocated_source_quantity <= 0
          OR ls_fefo_split-allocation-allocation-available_quantity
            < ls_fefo_split-allocation-allocation-allocated_quantity
          OR ls_fefo_split-available_source_quantity
            < ls_fefo_split-allocated_source_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      validate_delivery_date(
        iv_date = ls_fefo_split-allocation-required_date ).

      INSERT VALUE #(
        request_id    = ls_fefo_split-allocation-allocation-request_id
        material      = ls_fefo_split-allocation-allocation-material
        batch         = ls_fefo_split-allocation-allocation-batch
        storage_loc   =
          ls_fefo_split-allocation-allocation-storage_location
        delivery_date = ls_fefo_split-allocation-required_date )
        INTO TABLE lt_fefo_item_keys.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      ADD 10 TO lv_item_number.
      APPEND VALUE #(
        item_number           = lv_item_number
        source_request_id     =
          ls_fefo_split-allocation-allocation-request_id
        material              =
          ls_fefo_split-allocation-allocation-material
        batch                 =
          ls_fefo_split-allocation-allocation-batch
        supplying_plant       =
          ls_fefo_split-allocation-allocation-source_plant
        supplying_storage_loc =
          ls_fefo_split-allocation-allocation-storage_location
        receiving_plant       =
          ls_fefo_split-allocation-allocation-target_plant
        receiving_storage_loc = iv_receiving_storage_loc
        quantity              = ls_fefo_split-allocated_source_quantity
        unit                  = ls_fefo_split-source_unit
        delivery_date         =
          ls_fefo_split-allocation-required_date )
        TO rs_request-items.
    ENDLOOP.

    IF rs_request-items IS INITIAL
        OR lines( rs_request-items ) > 9999.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.
  ENDMETHOD.

  METHOD complete_write.
    rs_result = is_result.
    rs_result-is_test_run = is_request-is_test_run.
    rs_result-bapi_was_called = abap_true.
    rs_result-is_committed = abap_false.

    LOOP AT rs_result-messages ASSIGNING FIELD-SYMBOL(<ls_message>).
      IF ( <ls_message>-parameter = 'POITEM'
          OR <ls_message>-parameter = 'POITEMX' )
          AND <ls_message>-row > 0.
        READ TABLE is_request-items
          INDEX CONV i( <ls_message>-row )
          INTO DATA(ls_item_message).
        IF sy-subrc = 0.
          <ls_message>-item_number = ls_item_message-item_number.
          <ls_message>-source_request_id =
            ls_item_message-source_request_id.
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
      RETURN.
    ENDIF.
    IF is_request-is_test_run = abap_true.
      RETURN.
    ENDIF.
    IF iv_defer_commit = abap_true.
      RETURN.
    ENDIF.

    DATA(ls_commit_result) = mo_api->commit( ).
    IF ls_commit_result-is_successful <> abap_true.
      mo_api->rollback( ).
      APPEND ls_commit_result-message TO rs_result-messages.
      rs_result-is_successful = abap_false.
      RETURN.
    ENDIF.
    rs_result-is_committed = abap_true.
  ENDMETHOD.

  METHOD complete_deletion.
    rs_result-order_result = is_order.
    rs_result-is_attempted = abap_true.
    rs_result-is_test_run = iv_test_run.
    DATA(ls_change_result) = mo_api->mark_items_for_deletion(
      iv_purchase_order = is_order-purchase_order_number
      it_item_numbers   = it_item_numbers
      iv_test_run       = iv_test_run ).
    rs_result-deletion_messages = ls_change_result-messages.

    LOOP AT rs_result-deletion_messages
        ASSIGNING FIELD-SYMBOL(<ls_message>).
      IF ( <ls_message>-parameter = 'POITEM'
          OR <ls_message>-parameter = 'POITEMX' )
          AND <ls_message>-row > 0.
        READ TABLE is_order-submitted_items
          INDEX CONV i( <ls_message>-row )
          INTO DATA(ls_item_message).
        IF sy-subrc = 0.
          <ls_message>-item_number = ls_item_message-item_number.
          <ls_message>-source_request_id =
            ls_item_message-source_request_id.
        ENDIF.
      ENDIF.
      IF <ls_message>-type = 'A'
          OR <ls_message>-type = 'E'
          OR <ls_message>-type = 'X'.
        IF iv_test_run = abap_false.
          mo_api->rollback( ).
        ENDIF.
        RETURN.
      ENDIF.
    ENDLOOP.

    IF ls_change_result-is_successful <> abap_true.
      IF iv_test_run = abap_false.
        mo_api->rollback( ).
      ENDIF.
      RETURN.
    ENDIF.

    IF iv_test_run = abap_true.
      rs_result-is_successful = abap_true.
      RETURN.
    ENDIF.

    IF iv_defer_commit = abap_true.
      rs_result-is_successful = abap_true.
      rs_result-is_deleted = abap_true.
      RETURN.
    ENDIF.

    DATA(ls_commit_result) = mo_api->commit( ).
    IF ls_commit_result-is_successful <> abap_true.
      mo_api->rollback( ).
      APPEND ls_commit_result-message TO rs_result-deletion_messages.
      RETURN.
    ENDIF.
    rs_result-is_successful = abap_true.
    rs_result-is_deleted = abap_true.
  ENDMETHOD.

  METHOD complete_delivery_mark.
    rs_result-order_result = is_order.
    rs_result-is_attempted = abap_true.
    rs_result-is_test_run = iv_test_run.
    DATA(ls_change_result) = mo_api->mark_items_delivery_complete(
      iv_purchase_order = is_order-purchase_order_number
      it_item_numbers   = it_item_numbers
      iv_test_run       = iv_test_run ).
    rs_result-completion_messages = ls_change_result-messages.

    LOOP AT rs_result-completion_messages
        ASSIGNING FIELD-SYMBOL(<ls_message>).
      IF ( <ls_message>-parameter = 'POITEM'
          OR <ls_message>-parameter = 'POITEMX' )
          AND <ls_message>-row > 0.
        READ TABLE is_order-submitted_items
          INDEX CONV i( <ls_message>-row )
          INTO DATA(ls_item_message).
        IF sy-subrc = 0.
          <ls_message>-item_number = ls_item_message-item_number.
          <ls_message>-source_request_id =
            ls_item_message-source_request_id.
        ENDIF.
      ENDIF.
      IF <ls_message>-type = 'A'
          OR <ls_message>-type = 'E'
          OR <ls_message>-type = 'X'.
        IF iv_test_run = abap_false.
          mo_api->rollback( ).
        ENDIF.
        RETURN.
      ENDIF.
    ENDLOOP.

    IF ls_change_result-is_successful <> abap_true.
      IF iv_test_run = abap_false.
        mo_api->rollback( ).
      ENDIF.
      RETURN.
    ENDIF.

    IF iv_test_run = abap_true.
      rs_result-is_successful = abap_true.
      RETURN.
    ENDIF.

    IF iv_defer_commit = abap_true.
      rs_result-is_successful = abap_true.
      rs_result-is_completed = abap_true.
      RETURN.
    ENDIF.

    DATA(ls_commit_result) = mo_api->commit( ).
    IF ls_commit_result-is_successful <> abap_true.
      mo_api->rollback( ).
      APPEND ls_commit_result-message TO rs_result-completion_messages.
      RETURN.
    ENDIF.
    rs_result-is_successful = abap_true.
    rs_result-is_completed = abap_true.
  ENDMETHOD.

ENDCLASS.
