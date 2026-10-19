CLASS zcl_project_resv_service DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_result,
        reservation_number TYPE bapi2093_res_key-reserv_no,
        messages           TYPE zif_project_reservation_api=>ty_messages,
        is_successful      TYPE abap_bool,
        is_committed       TYPE abap_bool,
        is_test_run        TYPE abap_bool,
      END OF ty_result.
    TYPES:
      BEGIN OF ty_reserved_issue_item,
        reservation_item TYPE resb-rspos,
        quantity         TYPE mard-labst,
        unit             TYPE mara-meins,
        storage_location TYPE mard-lgort,
        batch            TYPE mchb-charg,
      END OF ty_reserved_issue_item.
    TYPES ty_reserved_issue_items TYPE STANDARD TABLE OF
      ty_reserved_issue_item WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_reserved_wbs_issue_request,
        wbs_element        TYPE zif_project_stock_repository=>ty_wbs_element,
        reservation_number TYPE
          zif_project_reservation_api=>ty_reservation_number,
        items              TYPE ty_reserved_issue_items,
      END OF ty_reserved_wbs_issue_request.
    TYPES ty_reserved_wbs_issue_requests TYPE STANDARD TABLE OF
      ty_reserved_wbs_issue_request WITH EMPTY KEY.
    TYPES ty_reserved_wbs_return_request TYPE
      ty_reserved_wbs_issue_request.
    TYPES ty_reserved_wbs_return_requests TYPE STANDARD TABLE OF
      ty_reserved_wbs_return_request WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_delete_result,
        reservation_number TYPE bapi2093_res_key-reserv_no,
        messages           TYPE zif_project_reservation_api=>ty_messages,
        is_successful      TYPE abap_bool,
        is_deleted         TYPE abap_bool,
        is_committed       TYPE abap_bool,
        is_test_run        TYPE abap_bool,
        was_rolled_back    TYPE abap_bool,
      END OF ty_delete_result.
    TYPES:
      BEGIN OF ty_bulk_delete_item,
        reservation_number TYPE bapi2093_res_key-reserv_no,
        messages           TYPE zif_project_reservation_api=>ty_messages,
        is_successful      TYPE abap_bool,
        is_deleted         TYPE abap_bool,
        is_committed       TYPE abap_bool,
        was_rolled_back    TYPE abap_bool,
        is_skipped         TYPE abap_bool,
      END OF ty_bulk_delete_item.
    TYPES ty_bulk_delete_items TYPE STANDARD TABLE OF ty_bulk_delete_item
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_bulk_delete_result,
        items              TYPE ty_bulk_delete_items,
        successful_count   TYPE i,
        failed_count       TYPE i,
        skipped_count      TYPE i,
        stopped_on_failure TYPE abap_bool,
        is_successful      TYPE abap_bool,
        is_test_run        TYPE abap_bool,
        is_committed       TYPE abap_bool,
      END OF ty_bulk_delete_result.
    TYPES:
      BEGIN OF ty_atomic_delete_result,
        items            TYPE ty_bulk_delete_items,
        messages         TYPE zif_project_reservation_api=>ty_messages,
        successful_count TYPE i,
        failed_count     TYPE i,
        is_successful    TYPE abap_bool,
        is_committed     TYPE abap_bool,
        is_test_run      TYPE abap_bool,
        was_rolled_back  TYPE abap_bool,
      END OF ty_atomic_delete_result.
    TYPES:
      BEGIN OF ty_item_delete_result,
        wbs_element        TYPE zif_project_stock_repository=>ty_wbs_element,
        reservation_number TYPE
          zif_project_reservation_api=>ty_reservation_number,
        item_numbers       TYPE
          zif_project_reservation_api=>ty_reservation_item_numbers,
        messages           TYPE zif_project_reservation_api=>ty_messages,
        is_successful      TYPE abap_bool,
        is_deleted         TYPE abap_bool,
        is_committed       TYPE abap_bool,
        is_test_run        TYPE abap_bool,
        was_rolled_back    TYPE abap_bool,
        is_skipped         TYPE abap_bool,
      END OF ty_item_delete_result.
    TYPES ty_item_delete_results TYPE STANDARD TABLE OF
      ty_item_delete_result WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_item_delete_request,
        wbs_element        TYPE zif_project_stock_repository=>ty_wbs_element,
        reservation_number TYPE
          zif_project_reservation_api=>ty_reservation_number,
        item_numbers       TYPE
          zif_project_reservation_api=>ty_reservation_item_numbers,
      END OF ty_item_delete_request.
    TYPES ty_item_delete_requests TYPE STANDARD TABLE OF
      ty_item_delete_request WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_bulk_item_delete_result,
        items              TYPE ty_item_delete_results,
        successful_count   TYPE i,
        failed_count       TYPE i,
        skipped_count      TYPE i,
        stopped_on_failure TYPE abap_bool,
        is_successful      TYPE abap_bool,
        is_test_run        TYPE abap_bool,
        is_committed       TYPE abap_bool,
      END OF ty_bulk_item_delete_result.
    TYPES:
      BEGIN OF ty_atomic_item_delete_result,
        items            TYPE ty_item_delete_results,
        messages         TYPE zif_project_reservation_api=>ty_messages,
        successful_count TYPE i,
        failed_count     TYPE i,
        is_successful    TYPE abap_bool,
        is_committed     TYPE abap_bool,
        is_test_run      TYPE abap_bool,
        was_rolled_back  TYPE abap_bool,
      END OF ty_atomic_item_delete_result.
    TYPES:
      BEGIN OF ty_reschedule_result,
        wbs_element        TYPE zif_project_stock_repository=>ty_wbs_element,
        reservation_number TYPE
          zif_project_reservation_api=>ty_reservation_number,
        item_numbers       TYPE
          zif_project_reservation_api=>ty_reservation_item_numbers,
        required_date      TYPE d,
        messages           TYPE zif_project_reservation_api=>ty_messages,
        is_successful      TYPE abap_bool,
        is_rescheduled     TYPE abap_bool,
        is_committed       TYPE abap_bool,
        is_test_run        TYPE abap_bool,
        was_rolled_back    TYPE abap_bool,
        is_skipped         TYPE abap_bool,
      END OF ty_reschedule_result.
    TYPES ty_reschedule_results TYPE STANDARD TABLE OF
      ty_reschedule_result WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_reschedule_request,
        wbs_element        TYPE zif_project_stock_repository=>ty_wbs_element,
        reservation_number TYPE
          zif_project_reservation_api=>ty_reservation_number,
        item_numbers       TYPE
          zif_project_reservation_api=>ty_reservation_item_numbers,
        required_date      TYPE d,
      END OF ty_reschedule_request.
    TYPES ty_reschedule_requests TYPE STANDARD TABLE OF
      ty_reschedule_request WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_bulk_reschedule_result,
        items              TYPE ty_reschedule_results,
        successful_count   TYPE i,
        failed_count       TYPE i,
        skipped_count      TYPE i,
        stopped_on_failure TYPE abap_bool,
        is_successful      TYPE abap_bool,
        is_test_run        TYPE abap_bool,
        is_committed       TYPE abap_bool,
      END OF ty_bulk_reschedule_result.
    TYPES:
      BEGIN OF ty_atomic_reschedule_result,
        items            TYPE ty_reschedule_results,
        messages         TYPE zif_project_reservation_api=>ty_messages,
        successful_count TYPE i,
        failed_count     TYPE i,
        is_successful    TYPE abap_bool,
        is_committed     TYPE abap_bool,
        is_test_run      TYPE abap_bool,
        was_rolled_back  TYPE abap_bool,
      END OF ty_atomic_reschedule_result.
    TYPES:
      BEGIN OF ty_requested_item_quantity,
        item_number       TYPE
          zif_project_reservation_api=>ty_reservation_item_number,
        required_quantity TYPE bapi2093_res_item-entry_qnt,
        unit              TYPE resb-meins,
      END OF ty_requested_item_quantity.
    TYPES ty_requested_item_quantities TYPE STANDARD TABLE OF
      ty_requested_item_quantity WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_quantity_change_result,
        wbs_element        TYPE zif_project_stock_repository=>ty_wbs_element,
        reservation_number TYPE
          zif_project_reservation_api=>ty_reservation_number,
        item_quantities    TYPE ty_requested_item_quantities,
        messages           TYPE zif_project_reservation_api=>ty_messages,
        is_successful      TYPE abap_bool,
        is_changed         TYPE abap_bool,
        is_committed       TYPE abap_bool,
        is_test_run        TYPE abap_bool,
        was_rolled_back    TYPE abap_bool,
        is_skipped         TYPE abap_bool,
      END OF ty_quantity_change_result.
    TYPES ty_quantity_change_results TYPE STANDARD TABLE OF
      ty_quantity_change_result WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_quantity_change_request,
        wbs_element        TYPE zif_project_stock_repository=>ty_wbs_element,
        reservation_number TYPE
          zif_project_reservation_api=>ty_reservation_number,
        item_quantities    TYPE ty_requested_item_quantities,
      END OF ty_quantity_change_request.
    TYPES ty_quantity_change_requests TYPE STANDARD TABLE OF
      ty_quantity_change_request WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_bulk_quantity_change_result,
        items              TYPE ty_quantity_change_results,
        successful_count   TYPE i,
        failed_count       TYPE i,
        skipped_count      TYPE i,
        stopped_on_failure TYPE abap_bool,
        is_successful      TYPE abap_bool,
        is_test_run        TYPE abap_bool,
        is_committed       TYPE abap_bool,
      END OF ty_bulk_quantity_change_result.
    TYPES:
      BEGIN OF ty_atomic_qty_result,
        items            TYPE ty_quantity_change_results,
        messages         TYPE zif_project_reservation_api=>ty_messages,
        successful_count TYPE i,
        failed_count     TYPE i,
        is_successful    TYPE abap_bool,
        is_committed     TYPE abap_bool,
        is_test_run      TYPE abap_bool,
        was_rolled_back  TYPE abap_bool,
      END OF ty_atomic_qty_result.
    TYPES:
      BEGIN OF ty_final_issue_result,
        wbs_element        TYPE zif_project_stock_repository=>ty_wbs_element,
        reservation_number TYPE
          zif_project_reservation_api=>ty_reservation_number,
        item_numbers       TYPE
          zif_project_reservation_api=>ty_reservation_item_numbers,
        messages           TYPE zif_project_reservation_api=>ty_messages,
        is_successful      TYPE abap_bool,
        is_finalized       TYPE abap_bool,
        is_reset           TYPE abap_bool,
        is_committed       TYPE abap_bool,
        is_test_run        TYPE abap_bool,
        was_rolled_back    TYPE abap_bool,
        is_skipped         TYPE abap_bool,
      END OF ty_final_issue_result.
    TYPES ty_final_issue_results TYPE STANDARD TABLE OF
      ty_final_issue_result WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_final_issue_request,
        wbs_element        TYPE zif_project_stock_repository=>ty_wbs_element,
        reservation_number TYPE
          zif_project_reservation_api=>ty_reservation_number,
        item_numbers       TYPE
          zif_project_reservation_api=>ty_reservation_item_numbers,
      END OF ty_final_issue_request.
    TYPES ty_final_issue_requests TYPE STANDARD TABLE OF
      ty_final_issue_request WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_bulk_final_issue_result,
        items              TYPE ty_final_issue_results,
        successful_count   TYPE i,
        failed_count       TYPE i,
        skipped_count      TYPE i,
        stopped_on_failure TYPE abap_bool,
        is_successful      TYPE abap_bool,
        is_test_run        TYPE abap_bool,
        is_committed       TYPE abap_bool,
      END OF ty_bulk_final_issue_result.
    TYPES:
      BEGIN OF ty_atomic_final_result,
        items            TYPE ty_final_issue_results,
        messages         TYPE zif_project_reservation_api=>ty_messages,
        successful_count TYPE i,
        failed_count     TYPE i,
        is_successful    TYPE abap_bool,
        is_committed     TYPE abap_bool,
        is_test_run      TYPE abap_bool,
        was_rolled_back  TYPE abap_bool,
      END OF ty_atomic_final_result.
    TYPES:
      BEGIN OF ty_stock_change_result,
        wbs_element        TYPE zif_project_stock_repository=>ty_wbs_element,
        reservation_number TYPE
          zif_project_reservation_api=>ty_reservation_number,
        item_changes       TYPE
          zif_project_reservation_api=>ty_item_stock_changes,
        messages           TYPE zif_project_reservation_api=>ty_messages,
        is_successful      TYPE abap_bool,
        is_changed         TYPE abap_bool,
        is_committed       TYPE abap_bool,
        is_test_run        TYPE abap_bool,
        was_rolled_back    TYPE abap_bool,
        is_skipped         TYPE abap_bool,
      END OF ty_stock_change_result.
    TYPES ty_stock_change_results TYPE STANDARD TABLE OF
      ty_stock_change_result WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_stock_change_request,
        wbs_element        TYPE zif_project_stock_repository=>ty_wbs_element,
        reservation_number TYPE
          zif_project_reservation_api=>ty_reservation_number,
        item_changes       TYPE
          zif_project_reservation_api=>ty_item_stock_changes,
      END OF ty_stock_change_request.
    TYPES ty_stock_change_requests TYPE STANDARD TABLE OF
      ty_stock_change_request WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_bulk_stock_change_result,
        items              TYPE ty_stock_change_results,
        successful_count   TYPE i,
        failed_count       TYPE i,
        skipped_count      TYPE i,
        stopped_on_failure TYPE abap_bool,
        is_successful      TYPE abap_bool,
        is_test_run        TYPE abap_bool,
        is_committed       TYPE abap_bool,
      END OF ty_bulk_stock_change_result.
    TYPES:
      BEGIN OF ty_atomic_stock_change_result,
        items            TYPE ty_stock_change_results,
        messages         TYPE zif_project_reservation_api=>ty_messages,
        successful_count TYPE i,
        failed_count     TYPE i,
        is_successful    TYPE abap_bool,
        is_committed     TYPE abap_bool,
        is_test_run      TYPE abap_bool,
        was_rolled_back  TYPE abap_bool,
      END OF ty_atomic_stock_change_result.
    TYPES:
      BEGIN OF ty_wbs_reservation,
        wbs_element        TYPE zif_project_stock_repository=>ty_wbs_element,
        reservation_number TYPE bapi2093_res_key-reserv_no,
        required_date      TYPE d,
        messages           TYPE zif_project_reservation_api=>ty_messages,
        is_successful      TYPE abap_bool,
        is_committed       TYPE abap_bool,
        is_skipped         TYPE abap_bool,
        is_test_run        TYPE abap_bool,
        was_rolled_back    TYPE abap_bool,
      END OF ty_wbs_reservation.
    TYPES ty_wbs_reservations TYPE STANDARD TABLE OF
      ty_wbs_reservation WITH EMPTY KEY.
    TYPES ty_wbs_reservation_requests TYPE STANDARD TABLE OF
      zif_project_reservation_api=>ty_request WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_wbs_required_date,
        wbs_element   TYPE zif_project_stock_repository=>ty_wbs_element,
        required_date TYPE d,
      END OF ty_wbs_required_date.
    TYPES ty_wbs_required_dates TYPE STANDARD TABLE OF
      ty_wbs_required_date WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_allocation_result,
        reservations       TYPE ty_wbs_reservations,
        successful_count   TYPE i,
        failed_count       TYPE i,
        skipped_count      TYPE i,
        messages           TYPE zif_project_reservation_api=>ty_messages,
        is_successful      TYPE abap_bool,
        stopped_on_failure TYPE abap_bool,
        is_committed       TYPE abap_bool,
        is_test_run        TYPE abap_bool,
        was_rolled_back    TYPE abap_bool,
      END OF ty_allocation_result.
    TYPES:
      BEGIN OF ty_fefo_reservation_result,
        preview     TYPE zcl_project_stock_service=>ty_result,
        reservation TYPE ty_allocation_result,
      END OF ty_fefo_reservation_result.
    TYPES:
      BEGIN OF ty_prio_fefo_resv_result,
        preview     TYPE
          zcl_project_stock_service=>ty_priority_fefo_result,
        reservation TYPE ty_allocation_result,
      END OF ty_prio_fefo_resv_result.
    TYPES:
      BEGIN OF ty_prio_location_resv_result,
        preview     TYPE
          zcl_project_stock_service=>ty_priority_location_result,
        reservation TYPE ty_allocation_result,
      END OF ty_prio_location_resv_result.
    TYPES:
      BEGIN OF ty_dated_fefo_reservation_result,
        preview     TYPE zcl_project_stock_service=>ty_dated_fefo_result,
        reservation TYPE ty_allocation_result,
      END OF ty_dated_fefo_reservation_result.
    TYPES:
      BEGIN OF ty_dated_location_reservation_result,
        preview     TYPE zcl_project_stock_service=>ty_dated_location_result,
        reservation TYPE ty_allocation_result,
      END OF ty_dated_location_reservation_result.
    TYPES:
      BEGIN OF ty_location_reservation_result,
        preview     TYPE zcl_project_stock_service=>ty_location_result,
        reservation TYPE ty_allocation_result,
      END OF ty_location_reservation_result.

    METHODS constructor
      IMPORTING
        io_api                   TYPE REF TO zif_project_reservation_api OPTIONAL
        io_project_stock_service TYPE REF TO zcl_project_stock_service
          OPTIONAL
        io_issue_service         TYPE REF TO zcl_reservation_issue_service
          OPTIONAL
        io_uom_converter         TYPE REF TO zif_material_uom_converter OPTIONAL
        io_uom_repository        TYPE REF TO zif_material_uom_repository
          OPTIONAL.

    METHODS reserve_for_wbs
      IMPORTING
        is_request       TYPE zif_project_reservation_api=>ty_request
        iv_test_run      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE ty_result
      RAISING
        zcx_invalid_reservation.

    METHODS reserve_wbs_bulk
      IMPORTING
        it_requests        TYPE ty_wbs_reservation_requests
        iv_test_run        TYPE abap_bool DEFAULT abap_false
        iv_atomic          TYPE abap_bool DEFAULT abap_false
        iv_stop_on_failure TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)   TYPE ty_allocation_result
      RAISING
        zcx_invalid_reservation.

    METHODS issue_reserved_wbs_items
      IMPORTING
        iv_wbs_element        TYPE
          zif_project_stock_repository=>ty_wbs_element
        iv_reservation_number TYPE
          zif_project_reservation_api=>ty_reservation_number
        is_header             TYPE zif_goods_movement_api=>ty_header
        it_items              TYPE ty_reserved_issue_items
        iv_test_run           TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)      TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_reservation
        zcx_invalid_goods_movement.

    METHODS issue_reserved_wbs_items_bulk
      IMPORTING
        it_requests        TYPE ty_reserved_wbs_issue_requests
        is_header          TYPE zif_goods_movement_api=>ty_header
        iv_test_run        TYPE abap_bool DEFAULT abap_false
        iv_stop_on_failure TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)   TYPE
          zcl_reservation_issue_service=>ty_bulk_issue_result
      RAISING
        zcx_invalid_reservation
        zcx_invalid_goods_movement.

    METHODS return_reserved_wbs_items
      IMPORTING
        iv_wbs_element        TYPE
          zif_project_stock_repository=>ty_wbs_element
        iv_reservation_number TYPE
          zif_project_reservation_api=>ty_reservation_number
        is_header             TYPE zif_goods_movement_api=>ty_header
        it_items              TYPE ty_reserved_issue_items
        iv_test_run           TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)      TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_reservation
        zcx_invalid_goods_movement.

    METHODS return_reserved_wbs_items_bulk
      IMPORTING
        it_requests        TYPE ty_reserved_wbs_return_requests
        is_header          TYPE zif_goods_movement_api=>ty_header
        iv_test_run        TYPE abap_bool DEFAULT abap_false
        iv_stop_on_failure TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)   TYPE
          zcl_reservation_issue_service=>ty_bulk_issue_result
      RAISING
        zcx_invalid_reservation
        zcx_invalid_goods_movement.

    METHODS issue_reserved_wbs_atomic
      IMPORTING
        it_requests      TYPE ty_reserved_wbs_issue_requests
        is_header        TYPE zif_goods_movement_api=>ty_header
        iv_test_run      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE
          zcl_reservation_issue_service=>ty_atomic_issue_result
      RAISING
        zcx_invalid_reservation
        zcx_invalid_goods_movement.

    METHODS return_reserved_wbs_atomic
      IMPORTING
        it_requests      TYPE ty_reserved_wbs_return_requests
        is_header        TYPE zif_goods_movement_api=>ty_header
        iv_test_run      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE
          zcl_reservation_issue_service=>ty_atomic_issue_result
      RAISING
        zcx_invalid_reservation
        zcx_invalid_goods_movement.

    METHODS delete_reservation
      IMPORTING
        iv_reservation_number TYPE
          zif_project_reservation_api=>ty_reservation_number
        iv_test_run           TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)      TYPE ty_delete_result
      RAISING
        zcx_invalid_reservation.

    METHODS delete_reservations_bulk
      IMPORTING
        it_reservation_numbers TYPE
          zif_project_reservation_api=>ty_reservation_numbers
        iv_test_run            TYPE abap_bool DEFAULT abap_false
        iv_stop_on_failure     TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)       TYPE ty_bulk_delete_result
      RAISING
        zcx_invalid_reservation.

    METHODS delete_reservations_atomic
      IMPORTING
        it_reservation_numbers TYPE
          zif_project_reservation_api=>ty_reservation_numbers
        iv_test_run            TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)       TYPE ty_atomic_delete_result
      RAISING
        zcx_invalid_reservation.

    METHODS delete_reservation_items
      IMPORTING
        iv_wbs_element        TYPE
          zif_project_stock_repository=>ty_wbs_element
        iv_reservation_number TYPE
          zif_project_reservation_api=>ty_reservation_number
        it_item_numbers       TYPE
          zif_project_reservation_api=>ty_reservation_item_numbers
        iv_test_run           TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)      TYPE ty_item_delete_result
      RAISING
        zcx_invalid_reservation.

    METHODS delete_reservation_items_bulk
      IMPORTING
        it_requests        TYPE ty_item_delete_requests
        iv_test_run        TYPE abap_bool DEFAULT abap_false
        iv_stop_on_failure TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)   TYPE ty_bulk_item_delete_result
      RAISING
        zcx_invalid_reservation.

    METHODS delete_resv_items_atomic
      IMPORTING
        it_requests      TYPE ty_item_delete_requests
        iv_test_run      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE ty_atomic_item_delete_result
      RAISING
        zcx_invalid_reservation.

    METHODS reschedule_reservation_items
      IMPORTING
        iv_wbs_element        TYPE
          zif_project_stock_repository=>ty_wbs_element
        iv_reservation_number TYPE
          zif_project_reservation_api=>ty_reservation_number
        it_item_numbers       TYPE
          zif_project_reservation_api=>ty_reservation_item_numbers
        iv_required_date      TYPE d
        iv_test_run           TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)      TYPE ty_reschedule_result
      RAISING
        zcx_invalid_reservation.

    METHODS reschedule_items_bulk
      IMPORTING
        it_requests        TYPE ty_reschedule_requests
        iv_test_run        TYPE abap_bool DEFAULT abap_false
        iv_stop_on_failure TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)   TYPE ty_bulk_reschedule_result
      RAISING
        zcx_invalid_reservation.

    METHODS reschedule_items_atomic
      IMPORTING
        it_requests      TYPE ty_reschedule_requests
        iv_test_run      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE ty_atomic_reschedule_result
      RAISING
        zcx_invalid_reservation.

    METHODS change_reservation_item_qty
      IMPORTING
        iv_wbs_element        TYPE
          zif_project_stock_repository=>ty_wbs_element
        iv_reservation_number TYPE
          zif_project_reservation_api=>ty_reservation_number
        it_item_quantities    TYPE ty_requested_item_quantities
        iv_test_run           TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)      TYPE ty_quantity_change_result
      RAISING
        zcx_invalid_reservation.

    METHODS change_reservation_qty_bulk
      IMPORTING
        it_requests        TYPE ty_quantity_change_requests
        iv_test_run        TYPE abap_bool DEFAULT abap_false
        iv_stop_on_failure TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)   TYPE ty_bulk_quantity_change_result
      RAISING
        zcx_invalid_reservation.

    METHODS change_resv_qty_atomic
      IMPORTING
        it_requests      TYPE ty_quantity_change_requests
        iv_test_run      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE ty_atomic_qty_result
      RAISING
        zcx_invalid_reservation.

    METHODS mark_reservation_items_final
      IMPORTING
        iv_wbs_element        TYPE
          zif_project_stock_repository=>ty_wbs_element
        iv_reservation_number TYPE
          zif_project_reservation_api=>ty_reservation_number
        it_item_numbers       TYPE
          zif_project_reservation_api=>ty_reservation_item_numbers
        iv_test_run           TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)      TYPE ty_final_issue_result
      RAISING
        zcx_invalid_reservation.

    METHODS mark_reservation_final_bulk
      IMPORTING
        it_requests        TYPE ty_final_issue_requests
        iv_test_run        TYPE abap_bool DEFAULT abap_false
        iv_stop_on_failure TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)   TYPE ty_bulk_final_issue_result
      RAISING
        zcx_invalid_reservation.

    METHODS reset_reservation_items_final
      IMPORTING
        iv_wbs_element        TYPE
          zif_project_stock_repository=>ty_wbs_element
        iv_reservation_number TYPE
          zif_project_reservation_api=>ty_reservation_number
        it_item_numbers       TYPE
          zif_project_reservation_api=>ty_reservation_item_numbers
        iv_test_run           TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)      TYPE ty_final_issue_result
      RAISING
        zcx_invalid_reservation.

    METHODS reset_reservation_final_bulk
      IMPORTING
        it_requests        TYPE ty_final_issue_requests
        iv_test_run        TYPE abap_bool DEFAULT abap_false
        iv_stop_on_failure TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)   TYPE ty_bulk_final_issue_result
      RAISING
        zcx_invalid_reservation.

    METHODS set_resv_final_atomic
      IMPORTING
        it_requests      TYPE ty_final_issue_requests
        iv_final_issue   TYPE abap_bool
        iv_test_run      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE ty_atomic_final_result
      RAISING
        zcx_invalid_reservation.

    METHODS change_reservation_item_stock
      IMPORTING
        iv_wbs_element        TYPE
          zif_project_stock_repository=>ty_wbs_element
        iv_reservation_number TYPE
          zif_project_reservation_api=>ty_reservation_number
        it_item_changes       TYPE
          zif_project_reservation_api=>ty_item_stock_changes
        iv_test_run           TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)      TYPE ty_stock_change_result
      RAISING
        zcx_invalid_reservation.

    METHODS change_reservation_stock_bulk
      IMPORTING
        it_requests        TYPE ty_stock_change_requests
        iv_test_run        TYPE abap_bool DEFAULT abap_false
        iv_stop_on_failure TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)   TYPE ty_bulk_stock_change_result
      RAISING
        zcx_invalid_reservation.

    METHODS change_resv_stock_atomic
      IMPORTING
        it_requests      TYPE ty_stock_change_requests
        iv_test_run      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE ty_atomic_stock_change_result
      RAISING
        zcx_invalid_reservation.

    METHODS reserve_batch_allocation
      IMPORTING
        is_allocation              TYPE zcl_project_stock_service=>ty_result
        iv_required_date           TYPE d OPTIONAL
        it_wbs_required_dates      TYPE ty_wbs_required_dates OPTIONAL
        iv_minimum_shelf_life_days TYPE i DEFAULT 0
        iv_test_run                TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation TYPE abap_bool DEFAULT abap_true
        iv_atomic                  TYPE abap_bool DEFAULT abap_false
        iv_stop_on_failure         TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)           TYPE ty_allocation_result
      RAISING
        zcx_invalid_reservation.

    METHODS reserve_location_allocation
      IMPORTING
        is_allocation              TYPE zcl_project_stock_service=>ty_location_result
        iv_required_date           TYPE d OPTIONAL
        it_wbs_required_dates      TYPE ty_wbs_required_dates OPTIONAL
        iv_test_run                TYPE abap_bool DEFAULT abap_false
        iv_require_full_allocation TYPE abap_bool DEFAULT abap_true
        iv_atomic                  TYPE abap_bool DEFAULT abap_false
        iv_stop_on_failure         TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)           TYPE ty_allocation_result
      RAISING
        zcx_invalid_reservation.

    METHODS reserve_wbs_fefo
      IMPORTING
        it_demands                     TYPE zcl_project_stock_service=>ty_demands
        it_storage_location_priority   TYPE
          zcl_stock_service=>ty_storage_locations OPTIONAL
        it_request_location_priorities TYPE
          zcl_stock_service=>ty_request_location_priorities OPTIONAL
        it_allowed_storage_locations   TYPE
          zcl_stock_service=>ty_storage_locations OPTIONAL
        it_request_locations           TYPE
          zcl_project_stock_service=>ty_request_locations OPTIONAL
        iv_as_of_date                  TYPE d DEFAULT sy-datum
        iv_minimum_shelf_life_days     TYPE i DEFAULT 0
        iv_include_undated_batches     TYPE abap_bool DEFAULT abap_true
        iv_require_full_quantity       TYPE abap_bool DEFAULT abap_true
        iv_reservation_through_date    TYPE d OPTIONAL
        iv_required_date               TYPE d OPTIONAL
        it_wbs_required_dates          TYPE ty_wbs_required_dates OPTIONAL
        iv_test_run                    TYPE abap_bool DEFAULT abap_false
        iv_atomic                      TYPE abap_bool DEFAULT abap_false
        iv_stop_on_failure             TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)               TYPE ty_fefo_reservation_result
      RAISING
        zcx_invalid_stock_request
        zcx_invalid_reservation.

    METHODS reserve_wbs_fefo_priority
      IMPORTING
        it_demands                     TYPE
          zcl_project_stock_service=>ty_priority_fefo_demands
        it_storage_location_priority   TYPE
          zcl_stock_service=>ty_storage_locations OPTIONAL
        it_request_location_priorities TYPE
          zcl_stock_service=>ty_request_location_priorities OPTIONAL
        it_allowed_storage_locations   TYPE
          zcl_stock_service=>ty_storage_locations OPTIONAL
        it_request_locations           TYPE
          zcl_project_stock_service=>ty_request_locations OPTIONAL
        iv_as_of_date                  TYPE d DEFAULT sy-datum
        iv_minimum_shelf_life_days     TYPE i DEFAULT 0
        iv_include_undated_batches     TYPE abap_bool DEFAULT abap_true
        iv_require_full_quantity       TYPE abap_bool DEFAULT abap_true
        iv_reservation_through_date    TYPE d OPTIONAL
        iv_required_date               TYPE d OPTIONAL
        it_wbs_required_dates          TYPE ty_wbs_required_dates OPTIONAL
        iv_test_run                    TYPE abap_bool DEFAULT abap_false
        iv_atomic                      TYPE abap_bool DEFAULT abap_false
        iv_stop_on_failure             TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)               TYPE ty_prio_fefo_resv_result
      RAISING
        zcx_invalid_stock_request
        zcx_invalid_reservation.

    METHODS reserve_wbs_fefo_by_date
      IMPORTING
        it_demands                     TYPE zcl_project_stock_service=>ty_dated_fefo_demands
        it_storage_location_priority   TYPE
          zcl_stock_service=>ty_storage_locations OPTIONAL
        it_request_location_priorities TYPE
          zcl_stock_service=>ty_request_location_priorities OPTIONAL
        it_allowed_storage_locations   TYPE
          zcl_stock_service=>ty_storage_locations OPTIONAL
        it_request_locations           TYPE
          zcl_project_stock_service=>ty_request_locations OPTIONAL
        iv_as_of_date                  TYPE d DEFAULT sy-datum
        iv_minimum_shelf_life_days     TYPE i DEFAULT 0
        iv_include_undated_batches     TYPE abap_bool DEFAULT abap_true
        iv_require_full_quantity       TYPE abap_bool DEFAULT abap_true
        iv_reservation_through_date    TYPE d OPTIONAL
        iv_test_run                    TYPE abap_bool DEFAULT abap_false
        iv_atomic                      TYPE abap_bool DEFAULT abap_false
        iv_stop_on_failure             TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)               TYPE ty_dated_fefo_reservation_result
      RAISING
        zcx_invalid_stock_request
        zcx_invalid_reservation.

    METHODS reserve_wbs_by_location_date
      IMPORTING
        it_demands                     TYPE zcl_project_stock_service=>ty_dated_location_demands
        it_storage_location_priority   TYPE
          zcl_stock_service=>ty_storage_locations OPTIONAL
        it_request_location_priorities TYPE
          zcl_stock_service=>ty_request_location_priorities OPTIONAL
        it_allowed_storage_locations   TYPE
          zcl_stock_service=>ty_storage_locations OPTIONAL
        it_request_locations           TYPE
          zcl_project_stock_service=>ty_request_locations OPTIONAL
        iv_require_full_quantity       TYPE abap_bool DEFAULT abap_true
        iv_reservation_through_date    TYPE d OPTIONAL
        iv_test_run                    TYPE abap_bool DEFAULT abap_false
        iv_atomic                      TYPE abap_bool DEFAULT abap_false
        iv_stop_on_failure             TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)               TYPE ty_dated_location_reservation_result
      RAISING
        zcx_invalid_stock_request
        zcx_invalid_reservation.

    METHODS reserve_wbs_by_location
      IMPORTING
        it_demands                   TYPE zcl_project_stock_service=>ty_demands
        it_storage_location_priority TYPE
          zcl_stock_service=>ty_storage_locations OPTIONAL
        it_allowed_storage_locations TYPE
          zcl_stock_service=>ty_storage_locations OPTIONAL
        it_request_locations         TYPE
          zcl_project_stock_service=>ty_request_locations OPTIONAL
        iv_require_full_quantity     TYPE abap_bool DEFAULT abap_true
        iv_reservation_through_date  TYPE d OPTIONAL
        iv_required_date             TYPE d OPTIONAL
        it_wbs_required_dates        TYPE ty_wbs_required_dates OPTIONAL
        iv_test_run                  TYPE abap_bool DEFAULT abap_false
        iv_atomic                    TYPE abap_bool DEFAULT abap_false
        iv_stop_on_failure           TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)             TYPE ty_location_reservation_result
      RAISING
        zcx_invalid_stock_request
        zcx_invalid_reservation.

    METHODS reserve_wbs_location_priority
      IMPORTING
        it_demands                     TYPE
          zcl_project_stock_service=>ty_priority_location_demands
        it_storage_location_priority   TYPE
          zcl_stock_service=>ty_storage_locations OPTIONAL
        it_request_location_priorities TYPE
          zcl_stock_service=>ty_request_location_priorities OPTIONAL
        it_allowed_storage_locations   TYPE
          zcl_stock_service=>ty_storage_locations OPTIONAL
        it_request_locations           TYPE
          zcl_project_stock_service=>ty_request_locations OPTIONAL
        iv_require_full_quantity       TYPE abap_bool DEFAULT abap_true
        iv_reservation_through_date    TYPE d OPTIONAL
        iv_required_date               TYPE d OPTIONAL
        it_wbs_required_dates          TYPE ty_wbs_required_dates OPTIONAL
        iv_test_run                    TYPE abap_bool DEFAULT abap_false
        iv_atomic                      TYPE abap_bool DEFAULT abap_false
        iv_stop_on_failure             TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)               TYPE ty_prio_location_resv_result
      RAISING
        zcx_invalid_stock_request
        zcx_invalid_reservation.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_item_key,
        material         TYPE mard-matnr,
        plant            TYPE mard-werks,
        storage_location TYPE mard-lgort,
        batch            TYPE mchb-charg,
      END OF ty_item_key,
      ty_item_keys TYPE HASHED TABLE OF ty_item_key
        WITH UNIQUE KEY material plant storage_location batch,
      BEGIN OF ty_assignment,
        request_id  TYPE c LENGTH 30,
        wbs_element TYPE zif_project_stock_repository=>ty_wbs_element,
      END OF ty_assignment,
      ty_assignments TYPE HASHED TABLE OF ty_assignment
        WITH UNIQUE KEY request_id,
      BEGIN OF ty_request_required_date,
        request_id    TYPE c LENGTH 30,
        required_date TYPE d,
      END OF ty_request_required_date,
      ty_request_required_dates TYPE HASHED TABLE OF
        ty_request_required_date WITH UNIQUE KEY request_id,
      BEGIN OF ty_allocation_summary,
        request_id TYPE c LENGTH 30,
        allocation TYPE zcl_stock_service=>ty_unit_allocation_summary,
      END OF ty_allocation_summary,
      ty_allocation_summaries TYPE HASHED TABLE OF ty_allocation_summary
        WITH UNIQUE KEY request_id,
      BEGIN OF ty_allocated_total,
        request_id TYPE c LENGTH 30,
        quantity   TYPE decfloat34,
      END OF ty_allocated_total,
      ty_allocated_totals TYPE HASHED TABLE OF ty_allocated_total
        WITH UNIQUE KEY request_id,
      BEGIN OF ty_allocation_split,
        request_id              TYPE c LENGTH 30,
        material                TYPE mard-matnr,
        plant                   TYPE mard-werks,
        storage_location        TYPE mard-lgort,
        batch                   TYPE mchb-charg,
        expiration_date         TYPE mcha-vfdat,
        minimum_shelf_life_days TYPE i,
        require_known_expiry    TYPE abap_bool,
        allow_undated_batches   TYPE abap_bool,
        quantity                TYPE mard-labst,
        base_unit               TYPE mara-meins,
      END OF ty_allocation_split,
      ty_allocation_splits TYPE STANDARD TABLE OF
        ty_allocation_split WITH EMPTY KEY,
      BEGIN OF ty_allocated_item,
        wbs_element      TYPE zif_project_stock_repository=>ty_wbs_element,
        required_date    TYPE d,
        material         TYPE mard-matnr,
        plant            TYPE mard-werks,
        storage_location TYPE mard-lgort,
        batch            TYPE mchb-charg,
        quantity         TYPE decfloat34,
        unit             TYPE mara-meins,
      END OF ty_allocated_item,
      ty_allocated_items TYPE HASHED TABLE OF ty_allocated_item
        WITH UNIQUE KEY wbs_element required_date material plant
          storage_location batch,
      ty_ordered_allocated_items TYPE STANDARD TABLE OF ty_allocated_item
        WITH EMPTY KEY,
      BEGIN OF ty_reservation_group,
        wbs_element   TYPE zif_project_stock_repository=>ty_wbs_element,
        required_date TYPE d,
        items         TYPE zif_project_reservation_api=>ty_items,
      END OF ty_reservation_group,
      ty_reservation_groups TYPE STANDARD TABLE OF ty_reservation_group
        WITH EMPTY KEY.

    DATA mo_api TYPE REF TO zif_project_reservation_api.
    DATA mo_project_stock_service TYPE REF TO zcl_project_stock_service.
    DATA mo_issue_service TYPE REF TO zcl_reservation_issue_service.
    DATA mo_uom_converter TYPE REF TO zif_material_uom_converter.

    METHODS prepare_reserved_wbs_movements
      IMPORTING
        it_requests     TYPE ty_reserved_wbs_issue_requests
        iv_test_run     TYPE abap_bool
        iv_is_reversal  TYPE abap_bool
      RETURNING
        VALUE(rt_items) TYPE
          zcl_reservation_issue_service=>ty_issue_requests_in_unit
      RAISING
        zcx_invalid_reservation.

    METHODS reserve_allocation
      IMPORTING
        it_allocations             TYPE zcl_stock_service=>ty_unit_allocation_summaries
        it_wbs_assignments         TYPE zcl_project_stock_service=>ty_wbs_assignments
        it_splits                  TYPE ty_allocation_splits
        iv_required_date           TYPE d OPTIONAL
        it_wbs_required_dates      TYPE ty_wbs_required_dates OPTIONAL
        it_request_required_dates  TYPE ty_request_required_dates OPTIONAL
        iv_minimum_shelf_life_days TYPE i DEFAULT 0
        iv_include_undated_batches TYPE abap_bool DEFAULT abap_true
        iv_test_run                TYPE abap_bool
        iv_require_full_allocation TYPE abap_bool
        iv_require_batch           TYPE abap_bool
        iv_atomic                  TYPE abap_bool
        iv_stop_on_failure         TYPE abap_bool
      RETURNING
        VALUE(rs_result)           TYPE ty_allocation_result
      RAISING
        zcx_invalid_reservation.

    METHODS same_unit_allocation_summaries
      IMPORTING
        it_expected    TYPE zcl_stock_service=>ty_unit_allocation_summaries
        it_actual      TYPE zcl_stock_service=>ty_unit_allocation_summaries
      RETURNING
        VALUE(rv_same) TYPE abap_bool.

    METHODS same_allocation_splits
      IMPORTING
        it_expected    TYPE ty_allocation_splits
        it_actual      TYPE ty_allocation_splits
      RETURNING
        VALUE(rv_same) TYPE abap_bool.

    METHODS validate_required_date
      IMPORTING
        iv_required_date TYPE d
      RAISING
        zcx_invalid_reservation.

    METHODS validate_wbs_date_inputs
      IMPORTING
        it_demands            TYPE zcl_project_stock_service=>ty_demands
        iv_required_date      TYPE d
        it_wbs_required_dates TYPE ty_wbs_required_dates
      RAISING
        zcx_invalid_reservation.
ENDCLASS.

CLASS zcl_project_resv_service IMPLEMENTATION.

  METHOD constructor.
    mo_api = io_api.
    IF mo_api IS NOT BOUND.
      mo_api = NEW zcl_bapi_project_reservation( ).
    ENDIF.

    mo_project_stock_service = io_project_stock_service.
    IF mo_project_stock_service IS NOT BOUND.
      mo_project_stock_service = NEW zcl_project_stock_service( ).
    ENDIF.

    mo_issue_service = io_issue_service.
    IF mo_issue_service IS NOT BOUND.
      mo_issue_service = NEW zcl_reservation_issue_service(
        io_uom_repository = io_uom_repository ).
    ENDIF.

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

  METHOD reserve_for_wbs.
    DATA lt_seen_items TYPE ty_item_keys.
    DATA ls_api_request TYPE zif_project_reservation_api=>ty_request.

    IF is_request-wbs_element IS INITIAL
        OR is_request-items IS INITIAL
        OR ( iv_test_run <> abap_true AND iv_test_run <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_reservation.
    ENDIF.
    validate_required_date(
      iv_required_date = is_request-required_date ).

    ls_api_request-wbs_element = is_request-wbs_element.
    ls_api_request-required_date = is_request-required_date.

    LOOP AT is_request-items INTO DATA(ls_item).
      IF ls_item-material IS INITIAL
          OR ls_item-plant IS INITIAL
          OR ls_item-quantity <= 0
          OR ls_item-unit IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.

      INSERT VALUE #(
        material         = ls_item-material
        plant            = ls_item-plant
        storage_location = ls_item-storage_location
        batch            = ls_item-batch ) INTO TABLE lt_seen_items.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.

      DATA(ls_conversion) = mo_uom_converter->convert_material_unit(
        iv_material    = ls_item-material
        iv_quantity    = ls_item-quantity
        iv_source_unit = ls_item-unit ).
      IF ls_conversion-is_successful <> abap_true
          OR ls_conversion-base_unit IS INITIAL
          OR ls_conversion-base_quantity <= 0.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.

      APPEND VALUE #(
        material         = ls_item-material
        plant            = ls_item-plant
        storage_location = ls_item-storage_location
        batch            = ls_item-batch
        quantity         = ls_conversion-base_quantity
        unit             = ls_conversion-base_unit )
        TO ls_api_request-items.
    ENDLOOP.

    rs_result-is_test_run = iv_test_run.
    DATA(ls_create_result) = mo_api->create_reservation(
      is_request  = ls_api_request
      iv_test_run = iv_test_run ).
    rs_result-reservation_number = ls_create_result-reservation_number.
    APPEND LINES OF ls_create_result-messages TO rs_result-messages.
    IF ls_create_result-is_successful <> abap_true
        OR line_exists( ls_create_result-messages[ type = 'A' ] )
        OR line_exists( ls_create_result-messages[ type = 'E' ] )
        OR line_exists( ls_create_result-messages[ type = 'X' ] ).
      IF iv_test_run = abap_false.
        mo_api->rollback( ).
      ENDIF.
      CLEAR rs_result-reservation_number.
      RETURN.
    ENDIF.

    IF iv_test_run = abap_true.
      rs_result-is_successful = abap_true.
      RETURN.
    ENDIF.

    IF rs_result-reservation_number IS INITIAL.
      mo_api->rollback( ).
      APPEND VALUE #(
        type    = 'E'
        message = 'Reservation API returned no reservation number' )
        TO rs_result-messages.
      RETURN.
    ENDIF.

    DATA(ls_commit_result) = mo_api->commit( ).
    IF ls_commit_result-is_successful <> abap_true
        OR ls_commit_result-message-type = 'A'
        OR ls_commit_result-message-type = 'E'
        OR ls_commit_result-message-type = 'X'.
      mo_api->rollback( ).
      CLEAR rs_result-reservation_number.
      IF ls_commit_result-message-type IS NOT INITIAL
          OR ls_commit_result-message-message IS NOT INITIAL.
        APPEND ls_commit_result-message TO rs_result-messages.
      ELSE.
        APPEND VALUE #(
          type    = 'E'
          message = 'Reservation commit failed' ) TO rs_result-messages.
      ENDIF.
      RETURN.
    ENDIF.

    rs_result-is_successful = abap_true.
    rs_result-is_committed = abap_true.
  ENDMETHOD.

  METHOD reserve_wbs_bulk.
    TYPES:
      BEGIN OF ty_wbs_key,
        wbs_element TYPE zif_project_stock_repository=>ty_wbs_element,
      END OF ty_wbs_key,
      ty_wbs_keys TYPE HASHED TABLE OF ty_wbs_key
        WITH UNIQUE KEY wbs_element,
      ty_seen_reservation TYPE
        zif_project_reservation_api=>ty_reservation_number.
    DATA lt_prepared_requests TYPE ty_wbs_reservation_requests.
    DATA lt_seen_wbs TYPE ty_wbs_keys.
    DATA lt_seen_reservations TYPE HASHED TABLE OF ty_seen_reservation
      WITH UNIQUE KEY table_line.
    DATA lv_has_failure TYPE abap_bool.
    DATA lv_has_error_message TYPE abap_bool.
    DATA lv_stop_processing TYPE abap_bool.
    FIELD-SYMBOLS <ls_reservation> TYPE ty_wbs_reservation.

    IF ( iv_test_run <> abap_true AND iv_test_run <> abap_false )
        OR ( iv_atomic <> abap_true AND iv_atomic <> abap_false )
        OR ( iv_stop_on_failure <> abap_true
          AND iv_stop_on_failure <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_reservation.
    ENDIF.

    rs_result-is_test_run = iv_test_run.
    rs_result-is_successful = abap_true.
    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-wbs_element IS INITIAL OR ls_request-items IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
      INSERT VALUE #( wbs_element = ls_request-wbs_element )
        INTO TABLE lt_seen_wbs.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
      validate_required_date( iv_required_date = ls_request-required_date ).

      DATA lt_seen_items TYPE ty_item_keys.
      DATA ls_api_request TYPE zif_project_reservation_api=>ty_request.
      CLEAR lt_seen_items.
      ls_api_request-wbs_element = ls_request-wbs_element.
      ls_api_request-required_date = ls_request-required_date.
      LOOP AT ls_request-items INTO DATA(ls_item).
        IF ls_item-material IS INITIAL
            OR ls_item-plant IS INITIAL
            OR ls_item-quantity <= 0
            OR ls_item-unit IS INITIAL.
          RAISE EXCEPTION TYPE zcx_invalid_reservation.
        ENDIF.

        INSERT VALUE #(
          material         = ls_item-material
          plant            = ls_item-plant
          storage_location = ls_item-storage_location
          batch            = ls_item-batch ) INTO TABLE lt_seen_items.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_reservation.
        ENDIF.

        DATA(ls_conversion) = mo_uom_converter->convert_material_unit(
          iv_material    = ls_item-material
          iv_quantity    = ls_item-quantity
          iv_source_unit = ls_item-unit ).
        IF ls_conversion-is_successful <> abap_true
            OR ls_conversion-base_unit IS INITIAL
            OR ls_conversion-base_quantity <= 0.
          RAISE EXCEPTION TYPE zcx_invalid_reservation.
        ENDIF.

        APPEND VALUE #(
          material         = ls_item-material
          plant            = ls_item-plant
          storage_location = ls_item-storage_location
          batch            = ls_item-batch
          quantity         = ls_conversion-base_quantity
          unit             = ls_conversion-base_unit )
          TO ls_api_request-items.
      ENDLOOP.
      APPEND ls_api_request TO lt_prepared_requests.
    ENDLOOP.

    LOOP AT lt_prepared_requests INTO ls_api_request.
      APPEND INITIAL LINE TO rs_result-reservations
        ASSIGNING <ls_reservation>.
      <ls_reservation>-wbs_element = ls_api_request-wbs_element.
      <ls_reservation>-required_date = ls_api_request-required_date.
      <ls_reservation>-is_test_run = iv_test_run.
      IF lv_stop_processing = abap_true.
        <ls_reservation>-is_skipped = abap_true.
        CONTINUE.
      ENDIF.

      CLEAR lv_has_error_message.
      DATA(ls_create_result) = mo_api->create_reservation(
        is_request  = ls_api_request
        iv_test_run = iv_test_run ).
      <ls_reservation>-reservation_number =
        ls_create_result-reservation_number.
      <ls_reservation>-messages = ls_create_result-messages.
      <ls_reservation>-is_successful = ls_create_result-is_successful.
      LOOP AT <ls_reservation>-messages INTO DATA(ls_create_message).
        IF ls_create_message-type = 'A'
            OR ls_create_message-type = 'E'
            OR ls_create_message-type = 'X'.
          <ls_reservation>-is_successful = abap_false.
          lv_has_error_message = abap_true.
        ENDIF.
      ENDLOOP.

      IF <ls_reservation>-is_successful = abap_true
          AND iv_test_run = abap_false.
        IF <ls_reservation>-reservation_number IS INITIAL.
          <ls_reservation>-is_successful = abap_false.
          lv_has_error_message = abap_true.
          APPEND VALUE #(
            type    = 'E'
            message = 'Reservation API returned no reservation number' )
            TO <ls_reservation>-messages.
        ELSE.
          INSERT <ls_reservation>-reservation_number
            INTO TABLE lt_seen_reservations.
          IF sy-subrc <> 0.
            <ls_reservation>-is_successful = abap_false.
            lv_has_error_message = abap_true.
            APPEND VALUE #(
              type    = 'E'
              message = 'Reservation API returned a duplicate reservation number' )
              TO <ls_reservation>-messages.
          ENDIF.
        ENDIF.
      ENDIF.

      IF <ls_reservation>-is_successful <> abap_true.
        CLEAR <ls_reservation>-reservation_number.
        IF lv_has_error_message = abap_false.
          APPEND VALUE #(
            type    = 'E'
            message = 'Project reservation creation failed' )
            TO <ls_reservation>-messages.
        ENDIF.
        lv_has_failure = abap_true.
        IF iv_test_run = abap_false AND iv_atomic = abap_false.
          mo_api->rollback( ).
          <ls_reservation>-was_rolled_back = abap_true.
        ENDIF.
        IF iv_stop_on_failure = abap_true.
          lv_stop_processing = abap_true.
          rs_result-stopped_on_failure = abap_true.
        ENDIF.
        CONTINUE.
      ENDIF.

      IF iv_test_run = abap_true OR iv_atomic = abap_true.
        CONTINUE.
      ENDIF.

      DATA(ls_commit_result) = mo_api->commit( ).
      DATA(lv_commit_failed) = xsdbool(
        ls_commit_result-is_successful = abap_false
        OR ls_commit_result-message-type = 'A'
        OR ls_commit_result-message-type = 'E'
        OR ls_commit_result-message-type = 'X' ).
      IF lv_commit_failed = abap_true.
        mo_api->rollback( ).
        CLEAR <ls_reservation>-reservation_number.
        <ls_reservation>-is_successful = abap_false.
        <ls_reservation>-was_rolled_back = abap_true.
        IF ( ls_commit_result-message-type = 'A'
            OR ls_commit_result-message-type = 'E'
            OR ls_commit_result-message-type = 'X' )
            AND ls_commit_result-message-message IS NOT INITIAL.
          APPEND ls_commit_result-message TO <ls_reservation>-messages.
        ELSE.
          APPEND VALUE #(
            type    = 'E'
            message = 'Project reservation commit failed' )
            TO <ls_reservation>-messages.
        ENDIF.
        lv_has_failure = abap_true.
        IF iv_stop_on_failure = abap_true.
          lv_stop_processing = abap_true.
          rs_result-stopped_on_failure = abap_true.
        ENDIF.
      ELSE.
        <ls_reservation>-is_committed = abap_true.
      ENDIF.
    ENDLOOP.

    IF iv_atomic = abap_true AND iv_test_run = abap_false.
      IF lv_has_failure = abap_true.
        mo_api->rollback( ).
        rs_result-is_successful = abap_false.
        rs_result-was_rolled_back = abap_true.
        LOOP AT rs_result-reservations ASSIGNING <ls_reservation>.
          CLEAR <ls_reservation>-reservation_number.
          <ls_reservation>-is_successful = abap_false.
          <ls_reservation>-is_committed = abap_false.
          IF <ls_reservation>-is_skipped = abap_true.
            rs_result-skipped_count = rs_result-skipped_count + 1.
            CLEAR <ls_reservation>-was_rolled_back.
          ELSE.
            rs_result-failed_count = rs_result-failed_count + 1.
            <ls_reservation>-was_rolled_back = abap_true.
          ENDIF.
        ENDLOOP.
      ELSE.
        DATA(ls_atomic_commit_result) = mo_api->commit( ).
        DATA(lv_atomic_commit_failed) = xsdbool(
          ls_atomic_commit_result-is_successful = abap_false
          OR ls_atomic_commit_result-message-type = 'A'
          OR ls_atomic_commit_result-message-type = 'E'
          OR ls_atomic_commit_result-message-type = 'X' ).
        IF lv_atomic_commit_failed = abap_true.
          mo_api->rollback( ).
          rs_result-is_successful = abap_false.
          rs_result-failed_count = lines( rs_result-reservations ).
          rs_result-was_rolled_back = abap_true.
          IF ( ls_atomic_commit_result-message-type = 'A'
              OR ls_atomic_commit_result-message-type = 'E'
              OR ls_atomic_commit_result-message-type = 'X' )
              AND ls_atomic_commit_result-message-message IS NOT INITIAL.
            APPEND ls_atomic_commit_result-message TO rs_result-messages.
          ELSE.
            APPEND VALUE #(
              type    = 'E'
              message = 'Atomic project reservation commit failed' )
              TO rs_result-messages.
          ENDIF.
          LOOP AT rs_result-reservations ASSIGNING <ls_reservation>.
            CLEAR <ls_reservation>-reservation_number.
            <ls_reservation>-is_successful = abap_false.
            <ls_reservation>-is_committed = abap_false.
            <ls_reservation>-was_rolled_back = abap_true.
          ENDLOOP.
        ELSE.
          rs_result-is_successful = abap_true.
          rs_result-is_committed = abap_true.
          rs_result-successful_count = lines( rs_result-reservations ).
          LOOP AT rs_result-reservations ASSIGNING <ls_reservation>.
            <ls_reservation>-is_successful = abap_true.
            <ls_reservation>-is_committed = abap_true.
          ENDLOOP.
        ENDIF.
      ENDIF.
    ELSE.
      LOOP AT rs_result-reservations ASSIGNING <ls_reservation>.
        IF <ls_reservation>-is_committed = abap_true.
          rs_result-is_committed = abap_true.
        ENDIF.
        IF <ls_reservation>-is_skipped = abap_true.
          rs_result-skipped_count = rs_result-skipped_count + 1.
        ELSEIF <ls_reservation>-is_successful = abap_true.
          ADD 1 TO rs_result-successful_count.
        ELSE.
          ADD 1 TO rs_result-failed_count.
        ENDIF.
      ENDLOOP.
      rs_result-is_successful = xsdbool( rs_result-failed_count = 0 ).
      IF iv_test_run = abap_false AND rs_result-is_successful = abap_true
          AND rs_result-reservations IS NOT INITIAL.
        rs_result-is_committed = abap_true.
      ENDIF.
    ENDIF.

    LOOP AT rs_result-reservations INTO DATA(ls_result_row).
      APPEND LINES OF ls_result_row-messages TO rs_result-messages.
    ENDLOOP.
  ENDMETHOD.

  METHOD issue_reserved_wbs_items.
    DATA lt_requests TYPE ty_reserved_wbs_issue_requests.
    APPEND VALUE #(
      wbs_element        = iv_wbs_element
      reservation_number = iv_reservation_number
      items              = it_items ) TO lt_requests.
    DATA(lt_issue_requests) = prepare_reserved_wbs_movements(
      it_requests    = lt_requests
      iv_test_run    = iv_test_run
      iv_is_reversal = abap_false ).

    rs_result = mo_issue_service->post_goods_issue_in_unit(
      is_header   = is_header
      it_requests = lt_issue_requests
      iv_test_run = iv_test_run ).
  ENDMETHOD.

  METHOD issue_reserved_wbs_items_bulk.
    IF iv_stop_on_failure <> abap_true
        AND iv_stop_on_failure <> abap_false.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    DATA(lt_issue_requests) = prepare_reserved_wbs_movements(
      it_requests    = it_requests
      iv_test_run    = iv_test_run
      iv_is_reversal = abap_false ).

    rs_result = mo_issue_service->post_goods_issue_bulk_unit(
      is_header          = is_header
      it_requests        = lt_issue_requests
      iv_test_run        = iv_test_run
      iv_stop_on_failure = iv_stop_on_failure ).
  ENDMETHOD.

  METHOD return_reserved_wbs_items.
    DATA lt_requests TYPE ty_reserved_wbs_issue_requests.
    APPEND VALUE #(
      wbs_element        = iv_wbs_element
      reservation_number = iv_reservation_number
      items              = it_items ) TO lt_requests.
    DATA(lt_issue_requests) = prepare_reserved_wbs_movements(
      it_requests    = lt_requests
      iv_test_run    = iv_test_run
      iv_is_reversal = abap_true ).

    rs_result = mo_issue_service->post_goods_issue_rev_in_unit(
      is_header   = is_header
      it_requests = lt_issue_requests
      iv_test_run = iv_test_run ).
  ENDMETHOD.

  METHOD return_reserved_wbs_items_bulk.
    IF iv_stop_on_failure <> abap_true
        AND iv_stop_on_failure <> abap_false.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    DATA(lt_issue_requests) = prepare_reserved_wbs_movements(
      it_requests    = it_requests
      iv_test_run    = iv_test_run
      iv_is_reversal = abap_true ).

    rs_result = mo_issue_service->post_goods_issue_rev_bulk_unit(
      is_header          = is_header
      it_requests        = lt_issue_requests
      iv_test_run        = iv_test_run
      iv_stop_on_failure = iv_stop_on_failure ).
  ENDMETHOD.

  METHOD issue_reserved_wbs_atomic.
    DATA(lt_issue_requests) = prepare_reserved_wbs_movements(
      it_requests    = it_requests
      iv_test_run    = iv_test_run
      iv_is_reversal = abap_false ).

    rs_result = mo_issue_service->post_goods_issue_atomic_unit(
      is_header   = is_header
      it_requests = lt_issue_requests
      iv_test_run = iv_test_run ).
  ENDMETHOD.

  METHOD return_reserved_wbs_atomic.
    DATA(lt_issue_requests) = prepare_reserved_wbs_movements(
      it_requests    = it_requests
      iv_test_run    = iv_test_run
      iv_is_reversal = abap_true ).

    rs_result = mo_issue_service->post_goods_issue_rev_atomic(
      is_header   = is_header
      it_requests = lt_issue_requests
      iv_test_run = iv_test_run ).
  ENDMETHOD.

  METHOD prepare_reserved_wbs_movements.
    TYPES:
      BEGIN OF ty_issue_item_key,
        reservation_number TYPE resb-rsnum,
        reservation_item   TYPE resb-rspos,
      END OF ty_issue_item_key.
    TYPES ty_issue_item_keys TYPE HASHED TABLE OF ty_issue_item_key
      WITH UNIQUE KEY reservation_number reservation_item.
    DATA lt_seen_reservations TYPE HASHED TABLE OF resb-rsnum
      WITH UNIQUE KEY table_line.
    DATA lt_seen_wbs_elements TYPE HASHED TABLE OF
      zif_project_stock_repository=>ty_wbs_element
      WITH UNIQUE KEY table_line.
    DATA lt_seen_items TYPE ty_issue_item_keys.
    DATA lt_wbs_elements TYPE
      zif_project_stock_repository=>ty_wbs_elements.
    DATA lt_project_items TYPE zcl_project_stock_service=>ty_reservation_items.

    IF it_requests IS INITIAL
        OR ( iv_test_run <> abap_true AND iv_test_run <> abap_false )
        OR ( iv_is_reversal <> abap_true
          AND iv_is_reversal <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_reservation.
    ENDIF.

    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-wbs_element IS INITIAL
          OR ls_request-reservation_number IS INITIAL
          OR ls_request-items IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
      INSERT ls_request-reservation_number INTO TABLE lt_seen_reservations.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
      INSERT ls_request-wbs_element INTO TABLE lt_seen_wbs_elements.
      IF sy-subrc = 0.
        APPEND ls_request-wbs_element TO lt_wbs_elements.
      ENDIF.

      LOOP AT ls_request-items INTO DATA(ls_item).
        IF ls_item-reservation_item IS INITIAL
            OR ls_item-quantity <= 0
            OR ls_item-unit IS INITIAL.
          RAISE EXCEPTION TYPE zcx_invalid_reservation.
        ENDIF.
        INSERT VALUE #(
          reservation_number = ls_request-reservation_number
          reservation_item   = ls_item-reservation_item )
          INTO TABLE lt_seen_items.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_reservation.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    TRY.
        lt_project_items = mo_project_stock_service->read_reservation_items(
          it_wbs_elements = lt_wbs_elements ).
      CATCH zcx_invalid_stock_request.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
    ENDTRY.

    LOOP AT it_requests INTO ls_request.
      LOOP AT ls_request-items INTO ls_item.
        READ TABLE lt_project_items INTO DATA(ls_project_item)
          WITH KEY reservation_number = ls_request-reservation_number
                   reservation_item   = ls_item-reservation_item
                   wbs_element        = ls_request-wbs_element.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_reservation.
        ENDIF.
        IF iv_is_reversal = abap_true.
          IF ls_project_item-withdrawn_quantity <= 0.
            RAISE EXCEPTION TYPE zcx_invalid_reservation.
          ENDIF.
        ELSEIF ls_project_item-is_final_issue = abap_true
            OR ls_project_item-open_quantity <= 0.
          RAISE EXCEPTION TYPE zcx_invalid_reservation.
        ENDIF.
        IF ls_item-storage_location IS NOT INITIAL
            AND ls_project_item-storage_location IS NOT INITIAL
            AND ls_item-storage_location
              <> ls_project_item-storage_location.
          RAISE EXCEPTION TYPE zcx_invalid_reservation.
        ENDIF.
        IF ls_item-batch IS NOT INITIAL
            AND ls_project_item-batch IS NOT INITIAL
            AND ls_item-batch <> ls_project_item-batch.
          RAISE EXCEPTION TYPE zcx_invalid_reservation.
        ENDIF.

        APPEND VALUE #(
          reservation_number = ls_request-reservation_number
          reservation_item   = ls_item-reservation_item
          quantity           = ls_item-quantity
          unit               = ls_item-unit
          storage_location   = ls_item-storage_location
          batch              = ls_item-batch )
          TO rt_items.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD delete_reservation.
    IF iv_reservation_number IS INITIAL
        OR ( iv_test_run <> abap_true AND iv_test_run <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_reservation.
    ENDIF.

    rs_result-reservation_number = iv_reservation_number.
    rs_result-is_test_run = iv_test_run.
    DATA(ls_api_result) = mo_api->delete_reservation(
      iv_reservation_number = iv_reservation_number
      iv_test_run           = iv_test_run ).
    rs_result-messages = ls_api_result-messages.
    rs_result-is_successful = ls_api_result-is_successful.
    LOOP AT rs_result-messages INTO DATA(ls_message).
      IF ls_message-type = 'A'
          OR ls_message-type = 'E'
          OR ls_message-type = 'X'.
        rs_result-is_successful = abap_false.
      ENDIF.
    ENDLOOP.

    IF rs_result-is_successful <> abap_true.
      IF iv_test_run = abap_false.
        mo_api->rollback( ).
        rs_result-was_rolled_back = abap_true.
      ENDIF.
      RETURN.
    ENDIF.

    IF iv_test_run = abap_true.
      RETURN.
    ENDIF.

    DATA(ls_commit_result) = mo_api->commit( ).
    IF ls_commit_result-is_successful <> abap_true
        OR ls_commit_result-message-type = 'A'
        OR ls_commit_result-message-type = 'E'
        OR ls_commit_result-message-type = 'X'.
      mo_api->rollback( ).
      rs_result-is_successful = abap_false.
      rs_result-was_rolled_back = abap_true.
      IF ls_commit_result-message-message IS NOT INITIAL.
        APPEND ls_commit_result-message TO rs_result-messages.
      ELSE.
        APPEND VALUE #(
          type    = 'E'
          message = 'Reservation deletion commit failed; deletion was rolled back' )
          TO rs_result-messages.
      ENDIF.
      RETURN.
    ENDIF.

    rs_result-is_deleted = abap_true.
    rs_result-is_committed = abap_true.
  ENDMETHOD.

  METHOD delete_reservations_bulk.
    TYPES ty_seen_reservation TYPE
      zif_project_reservation_api=>ty_reservation_number.
    DATA lt_seen_reservations TYPE HASHED TABLE OF ty_seen_reservation
      WITH UNIQUE KEY table_line.
    DATA lv_stop_processing TYPE abap_bool.
    FIELD-SYMBOLS <ls_item> TYPE ty_bulk_delete_item.

    IF ( iv_test_run <> abap_true AND iv_test_run <> abap_false )
        OR ( iv_stop_on_failure <> abap_true
          AND iv_stop_on_failure <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_reservation.
    ENDIF.

    rs_result-is_successful = abap_true.
    rs_result-is_test_run = iv_test_run.
    LOOP AT it_reservation_numbers INTO DATA(lv_reservation_number).
      INSERT lv_reservation_number INTO TABLE lt_seen_reservations.
      IF lv_reservation_number IS INITIAL OR sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
    ENDLOOP.

    LOOP AT it_reservation_numbers INTO lv_reservation_number.
      APPEND INITIAL LINE TO rs_result-items ASSIGNING <ls_item>.
      <ls_item>-reservation_number = lv_reservation_number.
      IF lv_stop_processing = abap_true.
        <ls_item>-is_skipped = abap_true.
        rs_result-skipped_count = rs_result-skipped_count + 1.
        CONTINUE.
      ENDIF.

      DATA(ls_delete_result) = delete_reservation(
        iv_reservation_number = lv_reservation_number
        iv_test_run           = iv_test_run ).
      <ls_item>-reservation_number = ls_delete_result-reservation_number.
      <ls_item>-messages = ls_delete_result-messages.
      <ls_item>-is_successful = ls_delete_result-is_successful.
      <ls_item>-is_deleted = ls_delete_result-is_deleted.
      <ls_item>-is_committed = ls_delete_result-is_committed.
      <ls_item>-was_rolled_back = ls_delete_result-was_rolled_back.
      IF ls_delete_result-is_committed = abap_true.
        rs_result-is_committed = abap_true.
      ENDIF.
      IF ls_delete_result-is_successful = abap_true.
        rs_result-successful_count = rs_result-successful_count + 1.
      ELSE.
        rs_result-failed_count = rs_result-failed_count + 1.
        IF iv_stop_on_failure = abap_true.
          lv_stop_processing = abap_true.
          rs_result-stopped_on_failure = abap_true.
        ENDIF.
      ENDIF.
    ENDLOOP.

    rs_result-is_successful = xsdbool( rs_result-failed_count = 0 ).
  ENDMETHOD.

  METHOD delete_reservations_atomic.
    TYPES ty_seen_reservation TYPE
      zif_project_reservation_api=>ty_reservation_number.
    DATA lt_seen_reservations TYPE HASHED TABLE OF ty_seen_reservation
      WITH UNIQUE KEY table_line.
    DATA lv_has_failure TYPE abap_bool.
    DATA lv_has_error_message TYPE abap_bool.
    FIELD-SYMBOLS <ls_result> TYPE ty_bulk_delete_item.

    IF it_reservation_numbers IS INITIAL
        OR ( iv_test_run <> abap_true AND iv_test_run <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_reservation.
    ENDIF.

    LOOP AT it_reservation_numbers INTO DATA(lv_reservation_number).
      INSERT lv_reservation_number INTO TABLE lt_seen_reservations.
      IF lv_reservation_number IS INITIAL OR sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
    ENDLOOP.

    rs_result-is_successful = abap_true.
    rs_result-is_test_run = iv_test_run.
    LOOP AT it_reservation_numbers INTO lv_reservation_number.
      APPEND INITIAL LINE TO rs_result-items ASSIGNING <ls_result>.
      <ls_result>-reservation_number = lv_reservation_number.

      DATA(ls_api_result) = mo_api->delete_reservation(
        iv_reservation_number = lv_reservation_number
        iv_test_run           = iv_test_run ).
      <ls_result>-messages = ls_api_result-messages.
      <ls_result>-is_successful = ls_api_result-is_successful.
      CLEAR lv_has_error_message.
      LOOP AT <ls_result>-messages INTO DATA(ls_message).
        IF ls_message-type = 'A'
            OR ls_message-type = 'E'
            OR ls_message-type = 'X'.
          <ls_result>-is_successful = abap_false.
          lv_has_error_message = abap_true.
        ENDIF.
      ENDLOOP.
      IF <ls_result>-is_successful <> abap_true.
        IF lv_has_error_message = abap_false.
          APPEND VALUE #(
            type    = 'E'
            message = 'Reservation deletion failed without an error message' )
            TO <ls_result>-messages.
        ENDIF.
        lv_has_failure = abap_true.
      ENDIF.
    ENDLOOP.

    IF iv_test_run = abap_true.
      LOOP AT rs_result-items ASSIGNING <ls_result>.
        IF <ls_result>-is_successful = abap_true.
          rs_result-successful_count = rs_result-successful_count + 1.
        ELSE.
          rs_result-failed_count = rs_result-failed_count + 1.
          rs_result-is_successful = abap_false.
        ENDIF.
      ENDLOOP.
      RETURN.
    ENDIF.

    IF lv_has_failure = abap_true.
      mo_api->rollback( ).
      rs_result-is_successful = abap_false.
      rs_result-failed_count = lines( rs_result-items ).
      rs_result-was_rolled_back = abap_true.
      LOOP AT rs_result-items ASSIGNING <ls_result>.
        <ls_result>-is_successful = abap_false.
        <ls_result>-is_deleted = abap_false.
        <ls_result>-is_committed = abap_false.
        <ls_result>-was_rolled_back = abap_true.
      ENDLOOP.
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
      rs_result-is_successful = abap_false.
      rs_result-failed_count = lines( rs_result-items ).
      rs_result-was_rolled_back = abap_true.
      IF ls_commit_result-message-message IS NOT INITIAL.
        APPEND ls_commit_result-message TO rs_result-messages.
      ELSE.
        APPEND VALUE #(
          type    = 'E'
          message = 'Atomic reservation deletion commit failed' )
          TO rs_result-messages.
      ENDIF.
      LOOP AT rs_result-items ASSIGNING <ls_result>.
        <ls_result>-is_successful = abap_false.
        <ls_result>-is_deleted = abap_false.
        <ls_result>-is_committed = abap_false.
        <ls_result>-was_rolled_back = abap_true.
      ENDLOOP.
      RETURN.
    ENDIF.

    rs_result-is_successful = abap_true.
    rs_result-is_committed = abap_true.
    rs_result-successful_count = lines( rs_result-items ).
    LOOP AT rs_result-items ASSIGNING <ls_result>.
      <ls_result>-is_successful = abap_true.
      <ls_result>-is_deleted = abap_true.
      <ls_result>-is_committed = abap_true.
    ENDLOOP.
  ENDMETHOD.

  METHOD delete_reservation_items.
    TYPES ty_seen_item TYPE resb-rspos.
    DATA lt_seen_items TYPE HASHED TABLE OF ty_seen_item
      WITH UNIQUE KEY table_line.
    DATA lt_open_reservations TYPE
      zcl_project_stock_service=>ty_open_reservations.

    IF iv_wbs_element IS INITIAL
        OR iv_reservation_number IS INITIAL
        OR it_item_numbers IS INITIAL
        OR ( iv_test_run <> abap_true AND iv_test_run <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_reservation.
    ENDIF.

    rs_result-wbs_element = iv_wbs_element.
    rs_result-reservation_number = iv_reservation_number.
    rs_result-item_numbers = it_item_numbers.
    rs_result-is_test_run = iv_test_run.
    LOOP AT it_item_numbers INTO DATA(lv_item_number).
      INSERT lv_item_number INTO TABLE lt_seen_items.
      IF lv_item_number IS INITIAL OR sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
    ENDLOOP.

    TRY.
        lt_open_reservations =
          mo_project_stock_service->read_open_reservations(
            it_wbs_elements = VALUE #( ( iv_wbs_element ) ) ).
      CATCH zcx_invalid_stock_request.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
    ENDTRY.

    LOOP AT it_item_numbers INTO lv_item_number.
      READ TABLE lt_open_reservations TRANSPORTING NO FIELDS
        WITH KEY reservation_number = iv_reservation_number
                 reservation_item   = lv_item_number
                 wbs_element        = iv_wbs_element.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
    ENDLOOP.

    rs_result-is_successful = abap_true.
    IF iv_test_run = abap_true.
      RETURN.
    ENDIF.

    DATA(ls_api_result) = mo_api->delete_reservation_items(
      iv_reservation_number = iv_reservation_number
      it_item_numbers       = it_item_numbers ).
    rs_result-messages = ls_api_result-messages.
    rs_result-is_successful = ls_api_result-is_successful.
    LOOP AT rs_result-messages INTO DATA(ls_message).
      IF ls_message-type = 'A'
          OR ls_message-type = 'E'
          OR ls_message-type = 'X'.
        rs_result-is_successful = abap_false.
      ENDIF.
    ENDLOOP.

    IF rs_result-is_successful <> abap_true.
      mo_api->rollback( ).
      rs_result-was_rolled_back = abap_true.
      RETURN.
    ENDIF.

    DATA(ls_commit_result) = mo_api->commit( ).
    IF ls_commit_result-is_successful <> abap_true
        OR ls_commit_result-message-type = 'A'
        OR ls_commit_result-message-type = 'E'
        OR ls_commit_result-message-type = 'X'.
      mo_api->rollback( ).
      rs_result-is_successful = abap_false.
      rs_result-was_rolled_back = abap_true.
      IF ls_commit_result-message-message IS NOT INITIAL.
        APPEND ls_commit_result-message TO rs_result-messages.
      ELSE.
        APPEND VALUE #(
          type    = 'E'
          message = 'Reservation item deletion commit failed' )
          TO rs_result-messages.
      ENDIF.
      RETURN.
    ENDIF.

    rs_result-is_deleted = abap_true.
    rs_result-is_committed = abap_true.
  ENDMETHOD.

  METHOD delete_reservation_items_bulk.
    TYPES ty_seen_reservation TYPE
      zif_project_reservation_api=>ty_reservation_number.
    TYPES ty_seen_item TYPE resb-rspos.
    DATA lt_seen_reservations TYPE HASHED TABLE OF ty_seen_reservation
      WITH UNIQUE KEY table_line.
    DATA lt_seen_items TYPE HASHED TABLE OF ty_seen_item
      WITH UNIQUE KEY table_line.
    DATA lv_stop_processing TYPE abap_bool.
    FIELD-SYMBOLS <ls_result> TYPE ty_item_delete_result.

    IF ( iv_test_run <> abap_true AND iv_test_run <> abap_false )
        OR ( iv_stop_on_failure <> abap_true
          AND iv_stop_on_failure <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_reservation.
    ENDIF.

    rs_result-is_successful = abap_true.
    rs_result-is_test_run = iv_test_run.
    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-wbs_element IS INITIAL
          OR ls_request-reservation_number IS INITIAL
          OR ls_request-item_numbers IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
      INSERT ls_request-reservation_number INTO TABLE lt_seen_reservations.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.

      CLEAR lt_seen_items.
      LOOP AT ls_request-item_numbers INTO DATA(lv_item_number).
        INSERT lv_item_number INTO TABLE lt_seen_items.
        IF lv_item_number IS INITIAL OR sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_reservation.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    LOOP AT it_requests INTO ls_request.
      APPEND INITIAL LINE TO rs_result-items ASSIGNING <ls_result>.
      <ls_result>-wbs_element = ls_request-wbs_element.
      <ls_result>-reservation_number = ls_request-reservation_number.
      <ls_result>-item_numbers = ls_request-item_numbers.
      <ls_result>-is_test_run = iv_test_run.

      IF lv_stop_processing = abap_true.
        <ls_result>-is_skipped = abap_true.
        rs_result-skipped_count = rs_result-skipped_count + 1.
        CONTINUE.
      ENDIF.

      TRY.
          <ls_result> = delete_reservation_items(
            iv_wbs_element        = ls_request-wbs_element
            iv_reservation_number = ls_request-reservation_number
            it_item_numbers       = ls_request-item_numbers
            iv_test_run           = iv_test_run ).
        CATCH zcx_invalid_reservation.
          <ls_result>-wbs_element = ls_request-wbs_element.
          <ls_result>-reservation_number = ls_request-reservation_number.
          <ls_result>-item_numbers = ls_request-item_numbers.
          <ls_result>-is_test_run = iv_test_run.
          <ls_result>-messages = VALUE #(
            ( type    = 'E'
              message = 'Reservation items are not open under this WBS and reservation' ) ).
      ENDTRY.

      IF <ls_result>-is_committed = abap_true.
        rs_result-is_committed = abap_true.
      ENDIF.
      IF <ls_result>-is_successful = abap_true.
        rs_result-successful_count = rs_result-successful_count + 1.
      ELSE.
        rs_result-failed_count = rs_result-failed_count + 1.
        rs_result-is_successful = abap_false.
        IF iv_stop_on_failure = abap_true.
          lv_stop_processing = abap_true.
          rs_result-stopped_on_failure = abap_true.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD delete_resv_items_atomic.
    TYPES ty_seen_reservation TYPE
      zif_project_reservation_api=>ty_reservation_number.
    TYPES ty_seen_item TYPE resb-rspos.
    DATA lt_seen_reservations TYPE HASHED TABLE OF ty_seen_reservation
      WITH UNIQUE KEY table_line.
    DATA lt_seen_items TYPE HASHED TABLE OF ty_seen_item
      WITH UNIQUE KEY table_line.
    DATA lt_seen_wbs_elements TYPE HASHED TABLE OF
      zif_project_stock_repository=>ty_wbs_element
      WITH UNIQUE KEY table_line.
    DATA lt_wbs_elements TYPE zif_project_stock_repository=>ty_wbs_elements.
    DATA lt_open_reservations TYPE
      zcl_project_stock_service=>ty_open_reservations.
    DATA lv_has_failure TYPE abap_bool.
    DATA lv_has_error_message TYPE abap_bool.
    FIELD-SYMBOLS <ls_result> TYPE ty_item_delete_result.

    IF it_requests IS INITIAL
        OR ( iv_test_run <> abap_true AND iv_test_run <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_reservation.
    ENDIF.

    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-wbs_element IS INITIAL
          OR ls_request-reservation_number IS INITIAL
          OR ls_request-item_numbers IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.

      INSERT ls_request-reservation_number INTO TABLE lt_seen_reservations.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.

      INSERT ls_request-wbs_element INTO TABLE lt_seen_wbs_elements.
      IF sy-subrc = 0.
        APPEND ls_request-wbs_element TO lt_wbs_elements.
      ENDIF.

      CLEAR lt_seen_items.
      LOOP AT ls_request-item_numbers INTO DATA(lv_item_number).
        INSERT lv_item_number INTO TABLE lt_seen_items.
        IF lv_item_number IS INITIAL OR sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_reservation.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    TRY.
        lt_open_reservations =
          mo_project_stock_service->read_open_reservations(
            it_wbs_elements = lt_wbs_elements ).
      CATCH zcx_invalid_stock_request.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
    ENDTRY.

    LOOP AT it_requests INTO ls_request.
      LOOP AT ls_request-item_numbers INTO lv_item_number.
        READ TABLE lt_open_reservations TRANSPORTING NO FIELDS
          WITH KEY reservation_number = ls_request-reservation_number
                   reservation_item   = lv_item_number
                   wbs_element        = ls_request-wbs_element.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_reservation.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    rs_result-is_successful = abap_true.
    rs_result-is_test_run = iv_test_run.
    LOOP AT it_requests INTO ls_request.
      APPEND INITIAL LINE TO rs_result-items ASSIGNING <ls_result>.
      <ls_result>-wbs_element = ls_request-wbs_element.
      <ls_result>-reservation_number = ls_request-reservation_number.
      <ls_result>-item_numbers = ls_request-item_numbers.
      <ls_result>-is_test_run = iv_test_run.

      IF iv_test_run = abap_true.
        <ls_result>-is_successful = abap_true.
        CONTINUE.
      ENDIF.

      DATA(ls_api_result) = mo_api->delete_reservation_items(
        iv_reservation_number = ls_request-reservation_number
        it_item_numbers       = ls_request-item_numbers ).
      <ls_result>-messages = ls_api_result-messages.
      <ls_result>-is_successful = ls_api_result-is_successful.
      CLEAR lv_has_error_message.
      LOOP AT <ls_result>-messages INTO DATA(ls_message).
        IF ls_message-type = 'A'
            OR ls_message-type = 'E'
            OR ls_message-type = 'X'.
          <ls_result>-is_successful = abap_false.
          lv_has_error_message = abap_true.
        ENDIF.
      ENDLOOP.
      IF <ls_result>-is_successful <> abap_true.
        IF lv_has_error_message = abap_false.
          APPEND VALUE #(
            type    = 'E'
            message = 'Reservation item deletion failed without an error message' )
            TO <ls_result>-messages.
        ENDIF.
        lv_has_failure = abap_true.
      ENDIF.
    ENDLOOP.

    IF iv_test_run = abap_true.
      rs_result-successful_count = lines( rs_result-items ).
      RETURN.
    ENDIF.

    IF lv_has_failure = abap_true.
      mo_api->rollback( ).
      rs_result-is_successful = abap_false.
      rs_result-failed_count = lines( rs_result-items ).
      rs_result-was_rolled_back = abap_true.
      LOOP AT rs_result-items ASSIGNING <ls_result>.
        <ls_result>-is_successful = abap_false.
        <ls_result>-is_deleted = abap_false.
        <ls_result>-is_committed = abap_false.
        <ls_result>-was_rolled_back = abap_true.
      ENDLOOP.
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
      rs_result-is_successful = abap_false.
      rs_result-failed_count = lines( rs_result-items ).
      rs_result-was_rolled_back = abap_true.
      IF ls_commit_result-message-message IS NOT INITIAL.
        APPEND ls_commit_result-message TO rs_result-messages.
      ELSE.
        APPEND VALUE #(
          type    = 'E'
          message = 'Atomic reservation item deletion commit failed' )
          TO rs_result-messages.
      ENDIF.
      LOOP AT rs_result-items ASSIGNING <ls_result>.
        <ls_result>-is_successful = abap_false.
        <ls_result>-is_deleted = abap_false.
        <ls_result>-is_committed = abap_false.
        <ls_result>-was_rolled_back = abap_true.
      ENDLOOP.
      RETURN.
    ENDIF.

    rs_result-is_successful = abap_true.
    rs_result-is_committed = abap_true.
    rs_result-successful_count = lines( rs_result-items ).
    LOOP AT rs_result-items ASSIGNING <ls_result>.
      <ls_result>-is_successful = abap_true.
      <ls_result>-is_deleted = abap_true.
      <ls_result>-is_committed = abap_true.
    ENDLOOP.
  ENDMETHOD.

  METHOD reschedule_reservation_items.
    TYPES ty_seen_item TYPE resb-rspos.
    DATA lt_seen_items TYPE HASHED TABLE OF ty_seen_item
      WITH UNIQUE KEY table_line.
    DATA lt_open_reservations TYPE
      zcl_project_stock_service=>ty_open_reservations.

    IF iv_wbs_element IS INITIAL
        OR iv_reservation_number IS INITIAL
        OR it_item_numbers IS INITIAL
        OR ( iv_test_run <> abap_true AND iv_test_run <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_reservation.
    ENDIF.
    validate_required_date( iv_required_date = iv_required_date ).

    rs_result-wbs_element = iv_wbs_element.
    rs_result-reservation_number = iv_reservation_number.
    rs_result-item_numbers = it_item_numbers.
    rs_result-required_date = iv_required_date.
    rs_result-is_test_run = iv_test_run.
    LOOP AT it_item_numbers INTO DATA(lv_item_number).
      INSERT lv_item_number INTO TABLE lt_seen_items.
      IF lv_item_number IS INITIAL OR sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
    ENDLOOP.

    TRY.
        lt_open_reservations =
          mo_project_stock_service->read_open_reservations(
            it_wbs_elements = VALUE #( ( iv_wbs_element ) ) ).
      CATCH zcx_invalid_stock_request.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
    ENDTRY.

    LOOP AT it_item_numbers INTO lv_item_number.
      READ TABLE lt_open_reservations TRANSPORTING NO FIELDS
        WITH KEY reservation_number = iv_reservation_number
                 reservation_item   = lv_item_number
                 wbs_element        = iv_wbs_element.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
    ENDLOOP.

    rs_result-is_successful = abap_true.
    IF iv_test_run = abap_true.
      RETURN.
    ENDIF.

    DATA(ls_api_result) = mo_api->change_reservation_item_dates(
      iv_reservation_number = iv_reservation_number
      it_item_numbers       = it_item_numbers
      iv_required_date      = iv_required_date ).
    rs_result-messages = ls_api_result-messages.
    rs_result-is_successful = ls_api_result-is_successful.
    LOOP AT rs_result-messages INTO DATA(ls_message).
      IF ls_message-type = 'A'
          OR ls_message-type = 'E'
          OR ls_message-type = 'X'.
        rs_result-is_successful = abap_false.
      ENDIF.
    ENDLOOP.

    IF rs_result-is_successful <> abap_true.
      mo_api->rollback( ).
      rs_result-was_rolled_back = abap_true.
      RETURN.
    ENDIF.

    DATA(ls_commit_result) = mo_api->commit( ).
    IF ls_commit_result-is_successful <> abap_true
        OR ls_commit_result-message-type = 'A'
        OR ls_commit_result-message-type = 'E'
        OR ls_commit_result-message-type = 'X'.
      mo_api->rollback( ).
      rs_result-is_successful = abap_false.
      rs_result-was_rolled_back = abap_true.
      IF ls_commit_result-message-message IS NOT INITIAL.
        APPEND ls_commit_result-message TO rs_result-messages.
      ELSE.
        APPEND VALUE #(
          type    = 'E'
          message = 'Reservation item reschedule commit failed' )
          TO rs_result-messages.
      ENDIF.
      RETURN.
    ENDIF.

    rs_result-is_rescheduled = abap_true.
    rs_result-is_committed = abap_true.
  ENDMETHOD.

  METHOD reschedule_items_bulk.
    TYPES ty_seen_reservation TYPE
      zif_project_reservation_api=>ty_reservation_number.
    TYPES ty_seen_item TYPE resb-rspos.
    DATA lt_seen_reservations TYPE HASHED TABLE OF ty_seen_reservation
      WITH UNIQUE KEY table_line.
    DATA lt_seen_items TYPE HASHED TABLE OF ty_seen_item
      WITH UNIQUE KEY table_line.
    DATA lv_stop_processing TYPE abap_bool.
    FIELD-SYMBOLS <ls_result> TYPE ty_reschedule_result.

    IF ( iv_test_run <> abap_true AND iv_test_run <> abap_false )
        OR ( iv_stop_on_failure <> abap_true
          AND iv_stop_on_failure <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_reservation.
    ENDIF.

    rs_result-is_successful = abap_true.
    rs_result-is_test_run = iv_test_run.
    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-wbs_element IS INITIAL
          OR ls_request-reservation_number IS INITIAL
          OR ls_request-item_numbers IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
      validate_required_date(
        iv_required_date = ls_request-required_date ).
      INSERT ls_request-reservation_number INTO TABLE lt_seen_reservations.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.

      CLEAR lt_seen_items.
      LOOP AT ls_request-item_numbers INTO DATA(lv_item_number).
        INSERT lv_item_number INTO TABLE lt_seen_items.
        IF lv_item_number IS INITIAL OR sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_reservation.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    LOOP AT it_requests INTO ls_request.
      APPEND INITIAL LINE TO rs_result-items ASSIGNING <ls_result>.
      <ls_result>-wbs_element = ls_request-wbs_element.
      <ls_result>-reservation_number = ls_request-reservation_number.
      <ls_result>-item_numbers = ls_request-item_numbers.
      <ls_result>-required_date = ls_request-required_date.
      <ls_result>-is_test_run = iv_test_run.

      IF lv_stop_processing = abap_true.
        <ls_result>-is_skipped = abap_true.
        rs_result-skipped_count = rs_result-skipped_count + 1.
        CONTINUE.
      ENDIF.

      TRY.
          <ls_result> = reschedule_reservation_items(
            iv_wbs_element        = ls_request-wbs_element
            iv_reservation_number = ls_request-reservation_number
            it_item_numbers       = ls_request-item_numbers
            iv_required_date      = ls_request-required_date
            iv_test_run           = iv_test_run ).
        CATCH zcx_invalid_reservation.
          <ls_result>-wbs_element = ls_request-wbs_element.
          <ls_result>-reservation_number = ls_request-reservation_number.
          <ls_result>-item_numbers = ls_request-item_numbers.
          <ls_result>-required_date = ls_request-required_date.
          <ls_result>-is_test_run = iv_test_run.
          <ls_result>-messages = VALUE #(
            ( type    = 'E'
              message = 'Reservation items are not open under this WBS and reservation' ) ).
      ENDTRY.

      IF <ls_result>-is_committed = abap_true.
        rs_result-is_committed = abap_true.
      ENDIF.
      IF <ls_result>-is_successful = abap_true.
        rs_result-successful_count = rs_result-successful_count + 1.
      ELSE.
        rs_result-failed_count = rs_result-failed_count + 1.
        rs_result-is_successful = abap_false.
        IF iv_stop_on_failure = abap_true.
          lv_stop_processing = abap_true.
          rs_result-stopped_on_failure = abap_true.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD reschedule_items_atomic.
    TYPES ty_seen_reservation TYPE
      zif_project_reservation_api=>ty_reservation_number.
    TYPES ty_seen_item TYPE resb-rspos.
    DATA lt_seen_reservations TYPE HASHED TABLE OF ty_seen_reservation
      WITH UNIQUE KEY table_line.
    DATA lt_seen_items TYPE HASHED TABLE OF ty_seen_item
      WITH UNIQUE KEY table_line.
    DATA lt_seen_wbs_elements TYPE HASHED TABLE OF
      zif_project_stock_repository=>ty_wbs_element
      WITH UNIQUE KEY table_line.
    DATA lt_wbs_elements TYPE zif_project_stock_repository=>ty_wbs_elements.
    DATA lt_open_reservations TYPE
      zcl_project_stock_service=>ty_open_reservations.
    DATA lv_has_failure TYPE abap_bool.
    DATA lv_has_error_message TYPE abap_bool.
    FIELD-SYMBOLS <ls_result> TYPE ty_reschedule_result.

    IF it_requests IS INITIAL
        OR ( iv_test_run <> abap_true AND iv_test_run <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_reservation.
    ENDIF.

    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-wbs_element IS INITIAL
          OR ls_request-reservation_number IS INITIAL
          OR ls_request-item_numbers IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
      validate_required_date(
        iv_required_date = ls_request-required_date ).

      INSERT ls_request-reservation_number INTO TABLE lt_seen_reservations.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.

      INSERT ls_request-wbs_element INTO TABLE lt_seen_wbs_elements.
      IF sy-subrc = 0.
        APPEND ls_request-wbs_element TO lt_wbs_elements.
      ENDIF.

      CLEAR lt_seen_items.
      LOOP AT ls_request-item_numbers INTO DATA(lv_item_number).
        INSERT lv_item_number INTO TABLE lt_seen_items.
        IF lv_item_number IS INITIAL OR sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_reservation.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    TRY.
        lt_open_reservations =
          mo_project_stock_service->read_open_reservations(
            it_wbs_elements = lt_wbs_elements ).
      CATCH zcx_invalid_stock_request.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
    ENDTRY.

    LOOP AT it_requests INTO ls_request.
      LOOP AT ls_request-item_numbers INTO lv_item_number.
        READ TABLE lt_open_reservations TRANSPORTING NO FIELDS
          WITH KEY reservation_number = ls_request-reservation_number
                   reservation_item   = lv_item_number
                   wbs_element        = ls_request-wbs_element.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_reservation.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    rs_result-is_successful = abap_true.
    rs_result-is_test_run = iv_test_run.
    LOOP AT it_requests INTO ls_request.
      APPEND INITIAL LINE TO rs_result-items ASSIGNING <ls_result>.
      <ls_result>-wbs_element = ls_request-wbs_element.
      <ls_result>-reservation_number = ls_request-reservation_number.
      <ls_result>-item_numbers = ls_request-item_numbers.
      <ls_result>-required_date = ls_request-required_date.
      <ls_result>-is_test_run = iv_test_run.

      IF iv_test_run = abap_true.
        <ls_result>-is_successful = abap_true.
        CONTINUE.
      ENDIF.

      DATA(ls_api_result) = mo_api->change_reservation_item_dates(
        iv_reservation_number = ls_request-reservation_number
        it_item_numbers       = ls_request-item_numbers
        iv_required_date      = ls_request-required_date ).
      <ls_result>-messages = ls_api_result-messages.
      <ls_result>-is_successful = ls_api_result-is_successful.
      CLEAR lv_has_error_message.
      LOOP AT <ls_result>-messages INTO DATA(ls_message).
        IF ls_message-type = 'A'
            OR ls_message-type = 'E'
            OR ls_message-type = 'X'.
          <ls_result>-is_successful = abap_false.
          lv_has_error_message = abap_true.
        ENDIF.
      ENDLOOP.
      IF <ls_result>-is_successful <> abap_true.
        IF lv_has_error_message = abap_false.
          APPEND VALUE #(
            type    = 'E'
            message = 'Reservation reschedule failed without an error message' )
            TO <ls_result>-messages.
        ENDIF.
        lv_has_failure = abap_true.
      ENDIF.
    ENDLOOP.

    IF iv_test_run = abap_true.
      rs_result-successful_count = lines( rs_result-items ).
      RETURN.
    ENDIF.

    IF lv_has_failure = abap_true.
      mo_api->rollback( ).
      rs_result-is_successful = abap_false.
      rs_result-failed_count = lines( rs_result-items ).
      rs_result-was_rolled_back = abap_true.
      LOOP AT rs_result-items ASSIGNING <ls_result>.
        <ls_result>-is_successful = abap_false.
        <ls_result>-is_rescheduled = abap_false.
        <ls_result>-is_committed = abap_false.
        <ls_result>-was_rolled_back = abap_true.
      ENDLOOP.
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
      rs_result-is_successful = abap_false.
      rs_result-failed_count = lines( rs_result-items ).
      rs_result-was_rolled_back = abap_true.
      IF ls_commit_result-message-message IS NOT INITIAL.
        APPEND ls_commit_result-message TO rs_result-messages.
      ELSE.
        APPEND VALUE #(
          type    = 'E'
          message = 'Atomic reservation reschedule commit failed' )
          TO rs_result-messages.
      ENDIF.
      LOOP AT rs_result-items ASSIGNING <ls_result>.
        <ls_result>-is_successful = abap_false.
        <ls_result>-is_rescheduled = abap_false.
        <ls_result>-is_committed = abap_false.
        <ls_result>-was_rolled_back = abap_true.
      ENDLOOP.
      RETURN.
    ENDIF.

    rs_result-is_successful = abap_true.
    rs_result-is_committed = abap_true.
    rs_result-successful_count = lines( rs_result-items ).
    LOOP AT rs_result-items ASSIGNING <ls_result>.
      <ls_result>-is_successful = abap_true.
      <ls_result>-is_rescheduled = abap_true.
      <ls_result>-is_committed = abap_true.
    ENDLOOP.
  ENDMETHOD.

  METHOD change_reservation_item_qty.
    TYPES ty_seen_item TYPE resb-rspos.
    DATA lt_seen_items TYPE HASHED TABLE OF ty_seen_item
      WITH UNIQUE KEY table_line.
    DATA lt_open_reservations TYPE
      zcl_project_stock_service=>ty_open_reservations.
    DATA lt_api_item_quantities TYPE
      zif_project_reservation_api=>ty_item_quantity_changes.

    IF iv_wbs_element IS INITIAL
        OR iv_reservation_number IS INITIAL
        OR it_item_quantities IS INITIAL
        OR ( iv_test_run <> abap_true AND iv_test_run <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_reservation.
    ENDIF.

    rs_result-wbs_element = iv_wbs_element.
    rs_result-reservation_number = iv_reservation_number.
    rs_result-item_quantities = it_item_quantities.
    rs_result-is_test_run = iv_test_run.
    LOOP AT it_item_quantities INTO DATA(ls_requested_quantity).
      INSERT ls_requested_quantity-item_number INTO TABLE lt_seen_items.
      IF ls_requested_quantity-item_number IS INITIAL
          OR ls_requested_quantity-required_quantity <= 0
          OR ls_requested_quantity-unit IS INITIAL
          OR sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
    ENDLOOP.

    TRY.
        lt_open_reservations =
          mo_project_stock_service->read_open_reservations(
            it_wbs_elements = VALUE #( ( iv_wbs_element ) ) ).
      CATCH zcx_invalid_stock_request.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
    ENDTRY.

    LOOP AT it_item_quantities INTO ls_requested_quantity.
      READ TABLE lt_open_reservations INTO DATA(ls_open_reservation)
        WITH KEY reservation_number = iv_reservation_number
                 reservation_item   = ls_requested_quantity-item_number
                 wbs_element        = iv_wbs_element.
      IF sy-subrc <> 0
          OR ls_open_reservation-entry_unit <> ls_requested_quantity-unit.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
      DATA(ls_quantity_conversion) = mo_uom_converter->convert_material_unit(
        iv_material    = ls_open_reservation-material
        iv_quantity    = ls_requested_quantity-required_quantity
        iv_source_unit = ls_requested_quantity-unit ).
      IF ls_quantity_conversion-is_successful <> abap_true
          OR ls_quantity_conversion-base_unit <> ls_open_reservation-unit
          OR ls_quantity_conversion-base_quantity
            <= ls_open_reservation-withdrawn_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
      APPEND VALUE #(
        item_number       = ls_requested_quantity-item_number
        required_quantity = ls_requested_quantity-required_quantity )
        TO lt_api_item_quantities.
    ENDLOOP.

    rs_result-is_successful = abap_true.
    IF iv_test_run = abap_true.
      RETURN.
    ENDIF.

    DATA(ls_api_result) = mo_api->change_reservation_qty(
      iv_reservation_number = iv_reservation_number
      it_item_quantities    = lt_api_item_quantities ).
    rs_result-messages = ls_api_result-messages.
    rs_result-is_successful = ls_api_result-is_successful.
    LOOP AT rs_result-messages INTO DATA(ls_message).
      IF ls_message-type = 'A'
          OR ls_message-type = 'E'
          OR ls_message-type = 'X'.
        rs_result-is_successful = abap_false.
      ENDIF.
    ENDLOOP.

    IF rs_result-is_successful <> abap_true.
      mo_api->rollback( ).
      rs_result-was_rolled_back = abap_true.
      RETURN.
    ENDIF.

    DATA(ls_commit_result) = mo_api->commit( ).
    IF ls_commit_result-is_successful <> abap_true
        OR ls_commit_result-message-type = 'A'
        OR ls_commit_result-message-type = 'E'
        OR ls_commit_result-message-type = 'X'.
      mo_api->rollback( ).
      rs_result-is_successful = abap_false.
      rs_result-was_rolled_back = abap_true.
      IF ls_commit_result-message-message IS NOT INITIAL.
        APPEND ls_commit_result-message TO rs_result-messages.
      ELSE.
        APPEND VALUE #(
          type    = 'E'
          message = 'Reservation item quantity commit failed' )
          TO rs_result-messages.
      ENDIF.
      RETURN.
    ENDIF.

    rs_result-is_changed = abap_true.
    rs_result-is_committed = abap_true.
  ENDMETHOD.

  METHOD change_reservation_qty_bulk.
    TYPES ty_seen_reservation TYPE
      zif_project_reservation_api=>ty_reservation_number.
    TYPES ty_seen_item TYPE resb-rspos.
    DATA lt_seen_reservations TYPE HASHED TABLE OF ty_seen_reservation
      WITH UNIQUE KEY table_line.
    DATA lt_seen_items TYPE HASHED TABLE OF ty_seen_item
      WITH UNIQUE KEY table_line.
    DATA lv_stop_processing TYPE abap_bool.
    FIELD-SYMBOLS <ls_result> TYPE ty_quantity_change_result.

    IF ( iv_test_run <> abap_true AND iv_test_run <> abap_false )
        OR ( iv_stop_on_failure <> abap_true
          AND iv_stop_on_failure <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_reservation.
    ENDIF.

    rs_result-is_successful = abap_true.
    rs_result-is_test_run = iv_test_run.
    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-wbs_element IS INITIAL
          OR ls_request-reservation_number IS INITIAL
          OR ls_request-item_quantities IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
      INSERT ls_request-reservation_number INTO TABLE lt_seen_reservations.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.

      CLEAR lt_seen_items.
      LOOP AT ls_request-item_quantities INTO DATA(ls_item_quantity).
        INSERT ls_item_quantity-item_number INTO TABLE lt_seen_items.
        IF ls_item_quantity-item_number IS INITIAL
            OR ls_item_quantity-required_quantity <= 0
            OR ls_item_quantity-unit IS INITIAL
            OR sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_reservation.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    LOOP AT it_requests INTO ls_request.
      APPEND INITIAL LINE TO rs_result-items ASSIGNING <ls_result>.
      <ls_result>-wbs_element = ls_request-wbs_element.
      <ls_result>-reservation_number = ls_request-reservation_number.
      <ls_result>-item_quantities = ls_request-item_quantities.
      <ls_result>-is_test_run = iv_test_run.

      IF lv_stop_processing = abap_true.
        <ls_result>-is_skipped = abap_true.
        rs_result-skipped_count = rs_result-skipped_count + 1.
        CONTINUE.
      ENDIF.

      TRY.
          <ls_result> = change_reservation_item_qty(
            iv_wbs_element        = ls_request-wbs_element
            iv_reservation_number = ls_request-reservation_number
            it_item_quantities    = ls_request-item_quantities
            iv_test_run           = iv_test_run ).
        CATCH zcx_invalid_reservation.
          <ls_result>-wbs_element = ls_request-wbs_element.
          <ls_result>-reservation_number = ls_request-reservation_number.
          <ls_result>-item_quantities = ls_request-item_quantities.
          <ls_result>-is_test_run = iv_test_run.
          <ls_result>-messages = VALUE #(
            ( type    = 'E'
              message = 'Reservation items or quantities are invalid for this WBS' ) ).
      ENDTRY.

      IF <ls_result>-is_committed = abap_true.
        rs_result-is_committed = abap_true.
      ENDIF.
      IF <ls_result>-is_successful = abap_true.
        rs_result-successful_count = rs_result-successful_count + 1.
      ELSE.
        rs_result-failed_count = rs_result-failed_count + 1.
        rs_result-is_successful = abap_false.
        IF iv_stop_on_failure = abap_true.
          lv_stop_processing = abap_true.
          rs_result-stopped_on_failure = abap_true.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD change_resv_qty_atomic.
    TYPES ty_seen_reservation TYPE
      zif_project_reservation_api=>ty_reservation_number.
    TYPES ty_seen_item TYPE resb-rspos.
    DATA lt_seen_reservations TYPE HASHED TABLE OF ty_seen_reservation
      WITH UNIQUE KEY table_line.
    DATA lt_seen_items TYPE HASHED TABLE OF ty_seen_item
      WITH UNIQUE KEY table_line.
    DATA lt_seen_wbs_elements TYPE HASHED TABLE OF
      zif_project_stock_repository=>ty_wbs_element
      WITH UNIQUE KEY table_line.
    DATA lt_wbs_elements TYPE zif_project_stock_repository=>ty_wbs_elements.
    DATA lt_open_reservations TYPE
      zcl_project_stock_service=>ty_open_reservations.
    DATA lt_api_item_quantities TYPE
      zif_project_reservation_api=>ty_item_quantity_changes.
    DATA lv_has_failure TYPE abap_bool.
    DATA lv_has_error_message TYPE abap_bool.
    FIELD-SYMBOLS <ls_result> TYPE ty_quantity_change_result.

    IF it_requests IS INITIAL
        OR ( iv_test_run <> abap_true AND iv_test_run <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_reservation.
    ENDIF.

    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-wbs_element IS INITIAL
          OR ls_request-reservation_number IS INITIAL
          OR ls_request-item_quantities IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.

      INSERT ls_request-reservation_number INTO TABLE lt_seen_reservations.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.

      INSERT ls_request-wbs_element INTO TABLE lt_seen_wbs_elements.
      IF sy-subrc = 0.
        APPEND ls_request-wbs_element TO lt_wbs_elements.
      ENDIF.

      CLEAR lt_seen_items.
      LOOP AT ls_request-item_quantities INTO DATA(ls_item_quantity).
        INSERT ls_item_quantity-item_number INTO TABLE lt_seen_items.
        IF ls_item_quantity-item_number IS INITIAL
            OR ls_item_quantity-required_quantity <= 0
            OR ls_item_quantity-unit IS INITIAL
            OR sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_reservation.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    TRY.
        lt_open_reservations =
          mo_project_stock_service->read_open_reservations(
            it_wbs_elements = lt_wbs_elements ).
      CATCH zcx_invalid_stock_request.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
    ENDTRY.

    LOOP AT it_requests INTO ls_request.
      LOOP AT ls_request-item_quantities INTO ls_item_quantity.
        READ TABLE lt_open_reservations INTO DATA(ls_open_reservation)
          WITH KEY reservation_number = ls_request-reservation_number
                   reservation_item   = ls_item_quantity-item_number
                   wbs_element        = ls_request-wbs_element.
        IF sy-subrc <> 0
            OR ls_open_reservation-entry_unit <> ls_item_quantity-unit.
          RAISE EXCEPTION TYPE zcx_invalid_reservation.
        ENDIF.

        DATA(ls_quantity_conversion) = mo_uom_converter->convert_material_unit(
          iv_material    = ls_open_reservation-material
          iv_quantity    = ls_item_quantity-required_quantity
          iv_source_unit = ls_item_quantity-unit ).
        IF ls_quantity_conversion-is_successful <> abap_true
            OR ls_quantity_conversion-base_unit <> ls_open_reservation-unit
            OR ls_quantity_conversion-base_quantity
              <= ls_open_reservation-withdrawn_quantity.
          RAISE EXCEPTION TYPE zcx_invalid_reservation.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    rs_result-is_successful = abap_true.
    rs_result-is_test_run = iv_test_run.
    LOOP AT it_requests INTO ls_request.
      APPEND INITIAL LINE TO rs_result-items ASSIGNING <ls_result>.
      <ls_result>-wbs_element = ls_request-wbs_element.
      <ls_result>-reservation_number = ls_request-reservation_number.
      <ls_result>-item_quantities = ls_request-item_quantities.
      <ls_result>-is_test_run = iv_test_run.

      IF iv_test_run = abap_true.
        <ls_result>-is_successful = abap_true.
        CONTINUE.
      ENDIF.

      CLEAR lt_api_item_quantities.
      LOOP AT ls_request-item_quantities INTO DATA(ls_requested_item).
        APPEND VALUE #(
          item_number       = ls_requested_item-item_number
          required_quantity = ls_requested_item-required_quantity )
          TO lt_api_item_quantities.
      ENDLOOP.
      DATA(ls_api_result) = mo_api->change_reservation_qty(
        iv_reservation_number = ls_request-reservation_number
        it_item_quantities    = lt_api_item_quantities ).
      <ls_result>-messages = ls_api_result-messages.
      <ls_result>-is_successful = ls_api_result-is_successful.
      CLEAR lv_has_error_message.
      LOOP AT <ls_result>-messages INTO DATA(ls_message).
        IF ls_message-type = 'A'
            OR ls_message-type = 'E'
            OR ls_message-type = 'X'.
          <ls_result>-is_successful = abap_false.
          lv_has_error_message = abap_true.
        ENDIF.
      ENDLOOP.
      IF <ls_result>-is_successful <> abap_true.
        IF lv_has_error_message = abap_false.
          APPEND VALUE #(
            type    = 'E'
            message = 'Reservation quantity change failed without an error message' )
            TO <ls_result>-messages.
        ENDIF.
        lv_has_failure = abap_true.
      ENDIF.
    ENDLOOP.

    IF iv_test_run = abap_true.
      rs_result-successful_count = lines( rs_result-items ).
      RETURN.
    ENDIF.

    IF lv_has_failure = abap_true.
      mo_api->rollback( ).
      rs_result-is_successful = abap_false.
      rs_result-failed_count = lines( rs_result-items ).
      rs_result-was_rolled_back = abap_true.
      LOOP AT rs_result-items ASSIGNING <ls_result>.
        <ls_result>-is_successful = abap_false.
        <ls_result>-is_changed = abap_false.
        <ls_result>-is_committed = abap_false.
        <ls_result>-was_rolled_back = abap_true.
      ENDLOOP.
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
      rs_result-is_successful = abap_false.
      rs_result-failed_count = lines( rs_result-items ).
      rs_result-was_rolled_back = abap_true.
      IF ls_commit_result-message-message IS NOT INITIAL.
        APPEND ls_commit_result-message TO rs_result-messages.
      ELSE.
        APPEND VALUE #(
          type    = 'E'
          message = 'Atomic reservation quantity change commit failed' )
          TO rs_result-messages.
      ENDIF.
      LOOP AT rs_result-items ASSIGNING <ls_result>.
        <ls_result>-is_successful = abap_false.
        <ls_result>-is_changed = abap_false.
        <ls_result>-is_committed = abap_false.
        <ls_result>-was_rolled_back = abap_true.
      ENDLOOP.
      RETURN.
    ENDIF.

    rs_result-is_successful = abap_true.
    rs_result-is_committed = abap_true.
    rs_result-successful_count = lines( rs_result-items ).
    LOOP AT rs_result-items ASSIGNING <ls_result>.
      <ls_result>-is_successful = abap_true.
      <ls_result>-is_changed = abap_true.
      <ls_result>-is_committed = abap_true.
    ENDLOOP.
  ENDMETHOD.

  METHOD mark_reservation_items_final.
    TYPES ty_seen_item TYPE resb-rspos.
    DATA lt_seen_items TYPE HASHED TABLE OF ty_seen_item
      WITH UNIQUE KEY table_line.
    DATA lt_open_reservations TYPE
      zcl_project_stock_service=>ty_open_reservations.

    IF iv_wbs_element IS INITIAL
        OR iv_reservation_number IS INITIAL
        OR it_item_numbers IS INITIAL
        OR ( iv_test_run <> abap_true AND iv_test_run <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_reservation.
    ENDIF.

    rs_result-wbs_element = iv_wbs_element.
    rs_result-reservation_number = iv_reservation_number.
    rs_result-item_numbers = it_item_numbers.
    rs_result-is_test_run = iv_test_run.
    LOOP AT it_item_numbers INTO DATA(lv_item_number).
      INSERT lv_item_number INTO TABLE lt_seen_items.
      IF lv_item_number IS INITIAL OR sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
    ENDLOOP.

    TRY.
        lt_open_reservations =
          mo_project_stock_service->read_open_reservations(
            it_wbs_elements = VALUE #( ( iv_wbs_element ) ) ).
      CATCH zcx_invalid_stock_request.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
    ENDTRY.

    LOOP AT it_item_numbers INTO lv_item_number.
      READ TABLE lt_open_reservations TRANSPORTING NO FIELDS
        WITH KEY reservation_number = iv_reservation_number
                 reservation_item   = lv_item_number
                 wbs_element        = iv_wbs_element.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
    ENDLOOP.

    rs_result-is_successful = abap_true.
    IF iv_test_run = abap_true.
      RETURN.
    ENDIF.

    DATA(ls_api_result) = mo_api->set_items_final_issue(
      iv_reservation_number = iv_reservation_number
      it_item_numbers       = it_item_numbers
      iv_final_issue        = abap_true ).
    rs_result-messages = ls_api_result-messages.
    rs_result-is_successful = ls_api_result-is_successful.
    LOOP AT rs_result-messages INTO DATA(ls_message).
      IF ls_message-type = 'A'
          OR ls_message-type = 'E'
          OR ls_message-type = 'X'.
        rs_result-is_successful = abap_false.
      ENDIF.
    ENDLOOP.

    IF rs_result-is_successful <> abap_true.
      mo_api->rollback( ).
      rs_result-was_rolled_back = abap_true.
      RETURN.
    ENDIF.

    DATA(ls_commit_result) = mo_api->commit( ).
    IF ls_commit_result-is_successful <> abap_true
        OR ls_commit_result-message-type = 'A'
        OR ls_commit_result-message-type = 'E'
        OR ls_commit_result-message-type = 'X'.
      mo_api->rollback( ).
      rs_result-is_successful = abap_false.
      rs_result-was_rolled_back = abap_true.
      IF ls_commit_result-message-message IS NOT INITIAL.
        APPEND ls_commit_result-message TO rs_result-messages.
      ELSE.
        APPEND VALUE #(
          type    = 'E'
          message = 'Final issue update commit failed' )
          TO rs_result-messages.
      ENDIF.
      RETURN.
    ENDIF.

    rs_result-is_finalized = abap_true.
    rs_result-is_committed = abap_true.
  ENDMETHOD.

  METHOD mark_reservation_final_bulk.
    TYPES ty_seen_reservation TYPE
      zif_project_reservation_api=>ty_reservation_number.
    TYPES ty_seen_item TYPE resb-rspos.
    DATA lt_seen_reservations TYPE HASHED TABLE OF ty_seen_reservation
      WITH UNIQUE KEY table_line.
    DATA lt_seen_items TYPE HASHED TABLE OF ty_seen_item
      WITH UNIQUE KEY table_line.
    DATA lv_stop_processing TYPE abap_bool.
    FIELD-SYMBOLS <ls_result> TYPE ty_final_issue_result.

    IF ( iv_test_run <> abap_true AND iv_test_run <> abap_false )
        OR ( iv_stop_on_failure <> abap_true
          AND iv_stop_on_failure <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_reservation.
    ENDIF.

    rs_result-is_successful = abap_true.
    rs_result-is_test_run = iv_test_run.
    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-wbs_element IS INITIAL
          OR ls_request-reservation_number IS INITIAL
          OR ls_request-item_numbers IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
      INSERT ls_request-reservation_number INTO TABLE lt_seen_reservations.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.

      CLEAR lt_seen_items.
      LOOP AT ls_request-item_numbers INTO DATA(lv_item_number).
        INSERT lv_item_number INTO TABLE lt_seen_items.
        IF lv_item_number IS INITIAL OR sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_reservation.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    LOOP AT it_requests INTO ls_request.
      APPEND INITIAL LINE TO rs_result-items ASSIGNING <ls_result>.
      <ls_result>-wbs_element = ls_request-wbs_element.
      <ls_result>-reservation_number = ls_request-reservation_number.
      <ls_result>-item_numbers = ls_request-item_numbers.
      <ls_result>-is_test_run = iv_test_run.

      IF lv_stop_processing = abap_true.
        <ls_result>-is_skipped = abap_true.
        rs_result-skipped_count = rs_result-skipped_count + 1.
        CONTINUE.
      ENDIF.

      TRY.
          <ls_result> = mark_reservation_items_final(
            iv_wbs_element        = ls_request-wbs_element
            iv_reservation_number = ls_request-reservation_number
            it_item_numbers       = ls_request-item_numbers
            iv_test_run           = iv_test_run ).
        CATCH zcx_invalid_reservation.
          <ls_result>-wbs_element = ls_request-wbs_element.
          <ls_result>-reservation_number = ls_request-reservation_number.
          <ls_result>-item_numbers = ls_request-item_numbers.
          <ls_result>-is_test_run = iv_test_run.
          <ls_result>-messages = VALUE #(
            ( type    = 'E'
              message = 'Reservation items are not open under this WBS and reservation' ) ).
      ENDTRY.

      IF <ls_result>-is_committed = abap_true.
        rs_result-is_committed = abap_true.
      ENDIF.
      IF <ls_result>-is_successful = abap_true.
        rs_result-successful_count = rs_result-successful_count + 1.
      ELSE.
        rs_result-failed_count = rs_result-failed_count + 1.
        rs_result-is_successful = abap_false.
        IF iv_stop_on_failure = abap_true.
          lv_stop_processing = abap_true.
          rs_result-stopped_on_failure = abap_true.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD reset_reservation_items_final.
    TYPES ty_seen_item TYPE resb-rspos.
    DATA lt_seen_items TYPE HASHED TABLE OF ty_seen_item
      WITH UNIQUE KEY table_line.
    DATA lt_reservation_items TYPE
      zcl_project_stock_service=>ty_reservation_items.

    IF iv_wbs_element IS INITIAL
        OR iv_reservation_number IS INITIAL
        OR it_item_numbers IS INITIAL
        OR ( iv_test_run <> abap_true AND iv_test_run <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_reservation.
    ENDIF.

    rs_result-wbs_element = iv_wbs_element.
    rs_result-reservation_number = iv_reservation_number.
    rs_result-item_numbers = it_item_numbers.
    rs_result-is_test_run = iv_test_run.
    LOOP AT it_item_numbers INTO DATA(lv_item_number).
      INSERT lv_item_number INTO TABLE lt_seen_items.
      IF lv_item_number IS INITIAL OR sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
    ENDLOOP.

    TRY.
        lt_reservation_items =
          mo_project_stock_service->read_reservation_items(
            it_wbs_elements = VALUE #( ( iv_wbs_element ) ) ).
      CATCH zcx_invalid_stock_request.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
    ENDTRY.

    LOOP AT it_item_numbers INTO lv_item_number.
      READ TABLE lt_reservation_items TRANSPORTING NO FIELDS
        WITH KEY reservation_number = iv_reservation_number
                 reservation_item   = lv_item_number
                 wbs_element        = iv_wbs_element
                 is_final_issue     = abap_true.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
    ENDLOOP.

    rs_result-is_successful = abap_true.
    IF iv_test_run = abap_true.
      RETURN.
    ENDIF.

    DATA(ls_api_result) = mo_api->set_items_final_issue(
      iv_reservation_number = iv_reservation_number
      it_item_numbers       = it_item_numbers
      iv_final_issue        = abap_false ).
    rs_result-messages = ls_api_result-messages.
    rs_result-is_successful = ls_api_result-is_successful.
    LOOP AT rs_result-messages INTO DATA(ls_message).
      IF ls_message-type = 'A'
          OR ls_message-type = 'E'
          OR ls_message-type = 'X'.
        rs_result-is_successful = abap_false.
      ENDIF.
    ENDLOOP.

    IF rs_result-is_successful <> abap_true.
      mo_api->rollback( ).
      rs_result-was_rolled_back = abap_true.
      RETURN.
    ENDIF.

    DATA(ls_commit_result) = mo_api->commit( ).
    IF ls_commit_result-is_successful <> abap_true
        OR ls_commit_result-message-type = 'A'
        OR ls_commit_result-message-type = 'E'
        OR ls_commit_result-message-type = 'X'.
      mo_api->rollback( ).
      rs_result-is_successful = abap_false.
      rs_result-was_rolled_back = abap_true.
      IF ls_commit_result-message-message IS NOT INITIAL.
        APPEND ls_commit_result-message TO rs_result-messages.
      ELSE.
        APPEND VALUE #(
          type    = 'E'
          message = 'Final issue reset commit failed' )
          TO rs_result-messages.
      ENDIF.
      RETURN.
    ENDIF.

    rs_result-is_reset = abap_true.
    rs_result-is_committed = abap_true.
  ENDMETHOD.

  METHOD reset_reservation_final_bulk.
    TYPES ty_seen_reservation TYPE
      zif_project_reservation_api=>ty_reservation_number.
    TYPES ty_seen_item TYPE resb-rspos.
    DATA lt_seen_reservations TYPE HASHED TABLE OF ty_seen_reservation
      WITH UNIQUE KEY table_line.
    DATA lt_seen_items TYPE HASHED TABLE OF ty_seen_item
      WITH UNIQUE KEY table_line.
    DATA lv_stop_processing TYPE abap_bool.
    FIELD-SYMBOLS <ls_result> TYPE ty_final_issue_result.

    IF ( iv_test_run <> abap_true AND iv_test_run <> abap_false )
        OR ( iv_stop_on_failure <> abap_true
          AND iv_stop_on_failure <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_reservation.
    ENDIF.

    rs_result-is_successful = abap_true.
    rs_result-is_test_run = iv_test_run.
    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-wbs_element IS INITIAL
          OR ls_request-reservation_number IS INITIAL
          OR ls_request-item_numbers IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
      INSERT ls_request-reservation_number INTO TABLE lt_seen_reservations.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.

      CLEAR lt_seen_items.
      LOOP AT ls_request-item_numbers INTO DATA(lv_item_number).
        INSERT lv_item_number INTO TABLE lt_seen_items.
        IF lv_item_number IS INITIAL OR sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_reservation.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    LOOP AT it_requests INTO ls_request.
      APPEND INITIAL LINE TO rs_result-items ASSIGNING <ls_result>.
      <ls_result>-wbs_element = ls_request-wbs_element.
      <ls_result>-reservation_number = ls_request-reservation_number.
      <ls_result>-item_numbers = ls_request-item_numbers.
      <ls_result>-is_test_run = iv_test_run.

      IF lv_stop_processing = abap_true.
        <ls_result>-is_skipped = abap_true.
        rs_result-skipped_count = rs_result-skipped_count + 1.
        CONTINUE.
      ENDIF.

      TRY.
          <ls_result> = reset_reservation_items_final(
            iv_wbs_element        = ls_request-wbs_element
            iv_reservation_number = ls_request-reservation_number
            it_item_numbers       = ls_request-item_numbers
            iv_test_run           = iv_test_run ).
        CATCH zcx_invalid_reservation.
          <ls_result>-wbs_element = ls_request-wbs_element.
          <ls_result>-reservation_number = ls_request-reservation_number.
          <ls_result>-item_numbers = ls_request-item_numbers.
          <ls_result>-is_test_run = iv_test_run.
          <ls_result>-messages = VALUE #(
            ( type    = 'E'
              message = 'Reservation items are not final under this WBS and reservation' ) ).
      ENDTRY.

      IF <ls_result>-is_committed = abap_true.
        rs_result-is_committed = abap_true.
      ENDIF.
      IF <ls_result>-is_successful = abap_true.
        rs_result-successful_count = rs_result-successful_count + 1.
      ELSE.
        rs_result-failed_count = rs_result-failed_count + 1.
        rs_result-is_successful = abap_false.
        IF iv_stop_on_failure = abap_true.
          lv_stop_processing = abap_true.
          rs_result-stopped_on_failure = abap_true.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD set_resv_final_atomic.
    TYPES ty_seen_reservation TYPE
      zif_project_reservation_api=>ty_reservation_number.
    TYPES ty_seen_item TYPE resb-rspos.
    DATA lt_seen_reservations TYPE HASHED TABLE OF ty_seen_reservation
      WITH UNIQUE KEY table_line.
    DATA lt_seen_items TYPE HASHED TABLE OF ty_seen_item
      WITH UNIQUE KEY table_line.
    DATA lt_seen_wbs_elements TYPE HASHED TABLE OF
      zif_project_stock_repository=>ty_wbs_element
      WITH UNIQUE KEY table_line.
    DATA lt_wbs_elements TYPE zif_project_stock_repository=>ty_wbs_elements.
    DATA lt_open_reservations TYPE
      zcl_project_stock_service=>ty_open_reservations.
    DATA lt_reservation_items TYPE
      zcl_project_stock_service=>ty_reservation_items.
    DATA lv_has_failure TYPE abap_bool.
    DATA lv_has_error_message TYPE abap_bool.
    FIELD-SYMBOLS <ls_result> TYPE ty_final_issue_result.

    IF it_requests IS INITIAL
        OR ( iv_final_issue <> abap_true
          AND iv_final_issue <> abap_false )
        OR ( iv_test_run <> abap_true AND iv_test_run <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_reservation.
    ENDIF.

    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-wbs_element IS INITIAL
          OR ls_request-reservation_number IS INITIAL
          OR ls_request-item_numbers IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.

      INSERT ls_request-reservation_number INTO TABLE lt_seen_reservations.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.

      INSERT ls_request-wbs_element INTO TABLE lt_seen_wbs_elements.
      IF sy-subrc = 0.
        APPEND ls_request-wbs_element TO lt_wbs_elements.
      ENDIF.

      CLEAR lt_seen_items.
      LOOP AT ls_request-item_numbers INTO DATA(lv_item_number).
        INSERT lv_item_number INTO TABLE lt_seen_items.
        IF lv_item_number IS INITIAL OR sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_reservation.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    TRY.
        IF iv_final_issue = abap_true.
          lt_open_reservations =
            mo_project_stock_service->read_open_reservations(
              it_wbs_elements = lt_wbs_elements ).
        ELSE.
          lt_reservation_items =
            mo_project_stock_service->read_reservation_items(
              it_wbs_elements = lt_wbs_elements ).
        ENDIF.
      CATCH zcx_invalid_stock_request.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
    ENDTRY.

    LOOP AT it_requests INTO ls_request.
      LOOP AT ls_request-item_numbers INTO lv_item_number.
        IF iv_final_issue = abap_true.
          READ TABLE lt_open_reservations TRANSPORTING NO FIELDS
            WITH KEY reservation_number = ls_request-reservation_number
                     reservation_item   = lv_item_number
                     wbs_element        = ls_request-wbs_element.
        ELSE.
          READ TABLE lt_reservation_items TRANSPORTING NO FIELDS
            WITH KEY reservation_number = ls_request-reservation_number
                     reservation_item   = lv_item_number
                     wbs_element        = ls_request-wbs_element
                     is_final_issue     = abap_true.
        ENDIF.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_reservation.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    rs_result-is_successful = abap_true.
    rs_result-is_test_run = iv_test_run.
    LOOP AT it_requests INTO ls_request.
      APPEND INITIAL LINE TO rs_result-items ASSIGNING <ls_result>.
      <ls_result>-wbs_element = ls_request-wbs_element.
      <ls_result>-reservation_number = ls_request-reservation_number.
      <ls_result>-item_numbers = ls_request-item_numbers.
      <ls_result>-is_test_run = iv_test_run.

      IF iv_test_run = abap_true.
        <ls_result>-is_successful = abap_true.
        CONTINUE.
      ENDIF.

      DATA(ls_api_result) = mo_api->set_items_final_issue(
        iv_reservation_number = ls_request-reservation_number
        it_item_numbers       = ls_request-item_numbers
        iv_final_issue        = iv_final_issue ).
      <ls_result>-messages = ls_api_result-messages.
      <ls_result>-is_successful = ls_api_result-is_successful.
      CLEAR lv_has_error_message.
      LOOP AT <ls_result>-messages INTO DATA(ls_message).
        IF ls_message-type = 'A'
            OR ls_message-type = 'E'
            OR ls_message-type = 'X'.
          <ls_result>-is_successful = abap_false.
          lv_has_error_message = abap_true.
        ENDIF.
      ENDLOOP.
      IF <ls_result>-is_successful <> abap_true.
        IF lv_has_error_message = abap_false.
          APPEND VALUE #(
            type    = 'E'
            message = 'Reservation final-issue update failed without an error message' )
            TO <ls_result>-messages.
        ENDIF.
        lv_has_failure = abap_true.
      ENDIF.
    ENDLOOP.

    IF iv_test_run = abap_true.
      rs_result-successful_count = lines( rs_result-items ).
      RETURN.
    ENDIF.

    IF lv_has_failure = abap_true.
      mo_api->rollback( ).
      rs_result-is_successful = abap_false.
      rs_result-failed_count = lines( rs_result-items ).
      rs_result-was_rolled_back = abap_true.
      LOOP AT rs_result-items ASSIGNING <ls_result>.
        <ls_result>-is_successful = abap_false.
        <ls_result>-is_finalized = abap_false.
        <ls_result>-is_reset = abap_false.
        <ls_result>-is_committed = abap_false.
        <ls_result>-was_rolled_back = abap_true.
      ENDLOOP.
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
      rs_result-is_successful = abap_false.
      rs_result-failed_count = lines( rs_result-items ).
      rs_result-was_rolled_back = abap_true.
      IF ls_commit_result-message-message IS NOT INITIAL.
        APPEND ls_commit_result-message TO rs_result-messages.
      ELSE.
        APPEND VALUE #(
          type    = 'E'
          message = 'Atomic reservation final-issue commit failed' )
          TO rs_result-messages.
      ENDIF.
      LOOP AT rs_result-items ASSIGNING <ls_result>.
        <ls_result>-is_successful = abap_false.
        <ls_result>-is_finalized = abap_false.
        <ls_result>-is_reset = abap_false.
        <ls_result>-is_committed = abap_false.
        <ls_result>-was_rolled_back = abap_true.
      ENDLOOP.
      RETURN.
    ENDIF.

    rs_result-is_successful = abap_true.
    rs_result-is_committed = abap_true.
    rs_result-successful_count = lines( rs_result-items ).
    LOOP AT rs_result-items ASSIGNING <ls_result>.
      <ls_result>-is_successful = abap_true.
      <ls_result>-is_finalized = iv_final_issue.
      <ls_result>-is_reset = xsdbool( iv_final_issue = abap_false ).
      <ls_result>-is_committed = abap_true.
    ENDLOOP.
  ENDMETHOD.

  METHOD change_reservation_item_stock.
    TYPES ty_seen_item TYPE resb-rspos.
    DATA lt_seen_items TYPE HASHED TABLE OF ty_seen_item
      WITH UNIQUE KEY table_line.
    DATA lt_open_reservations TYPE
      zcl_project_stock_service=>ty_open_reservations.

    IF iv_wbs_element IS INITIAL
        OR iv_reservation_number IS INITIAL
        OR it_item_changes IS INITIAL
        OR ( iv_test_run <> abap_true AND iv_test_run <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_reservation.
    ENDIF.

    rs_result-wbs_element = iv_wbs_element.
    rs_result-reservation_number = iv_reservation_number.
    rs_result-item_changes = it_item_changes.
    rs_result-is_test_run = iv_test_run.
    LOOP AT it_item_changes INTO DATA(ls_item_change).
      INSERT ls_item_change-item_number INTO TABLE lt_seen_items.
      IF ls_item_change-item_number IS INITIAL
          OR ( ls_item_change-change_storage_location <> abap_true
            AND ls_item_change-change_storage_location <> abap_false )
          OR ( ls_item_change-change_batch <> abap_true
            AND ls_item_change-change_batch <> abap_false )
          OR ( ls_item_change-change_storage_location = abap_false
            AND ls_item_change-change_batch = abap_false )
          OR sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
    ENDLOOP.

    TRY.
        lt_open_reservations =
          mo_project_stock_service->read_open_reservations(
            it_wbs_elements = VALUE #( ( iv_wbs_element ) ) ).
      CATCH zcx_invalid_stock_request.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
    ENDTRY.

    LOOP AT it_item_changes INTO ls_item_change.
      READ TABLE lt_open_reservations TRANSPORTING NO FIELDS
        WITH KEY reservation_number = iv_reservation_number
                 reservation_item   = ls_item_change-item_number
                 wbs_element        = iv_wbs_element.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
    ENDLOOP.

    rs_result-is_successful = abap_true.
    IF iv_test_run = abap_true.
      RETURN.
    ENDIF.

    DATA(ls_api_result) = mo_api->change_reservation_stock(
      iv_reservation_number = iv_reservation_number
      it_item_changes       = it_item_changes ).
    rs_result-messages = ls_api_result-messages.
    rs_result-is_successful = ls_api_result-is_successful.
    LOOP AT rs_result-messages INTO DATA(ls_message).
      IF ls_message-type = 'A'
          OR ls_message-type = 'E'
          OR ls_message-type = 'X'.
        rs_result-is_successful = abap_false.
      ENDIF.
    ENDLOOP.

    IF rs_result-is_successful <> abap_true.
      mo_api->rollback( ).
      rs_result-was_rolled_back = abap_true.
      RETURN.
    ENDIF.

    DATA(ls_commit_result) = mo_api->commit( ).
    IF ls_commit_result-is_successful <> abap_true
        OR ls_commit_result-message-type = 'A'
        OR ls_commit_result-message-type = 'E'
        OR ls_commit_result-message-type = 'X'.
      mo_api->rollback( ).
      rs_result-is_successful = abap_false.
      rs_result-was_rolled_back = abap_true.
      IF ls_commit_result-message-message IS NOT INITIAL.
        APPEND ls_commit_result-message TO rs_result-messages.
      ELSE.
        APPEND VALUE #(
          type    = 'E'
          message = 'Reservation item stock change commit failed' )
          TO rs_result-messages.
      ENDIF.
      RETURN.
    ENDIF.

    rs_result-is_changed = abap_true.
    rs_result-is_committed = abap_true.
  ENDMETHOD.

  METHOD change_reservation_stock_bulk.
    TYPES ty_seen_reservation TYPE
      zif_project_reservation_api=>ty_reservation_number.
    TYPES ty_seen_item TYPE resb-rspos.
    DATA lt_seen_reservations TYPE HASHED TABLE OF ty_seen_reservation
      WITH UNIQUE KEY table_line.
    DATA lt_seen_items TYPE HASHED TABLE OF ty_seen_item
      WITH UNIQUE KEY table_line.
    DATA lv_stop_processing TYPE abap_bool.
    FIELD-SYMBOLS <ls_result> TYPE ty_stock_change_result.

    IF ( iv_test_run <> abap_true AND iv_test_run <> abap_false )
        OR ( iv_stop_on_failure <> abap_true
          AND iv_stop_on_failure <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_reservation.
    ENDIF.

    rs_result-is_successful = abap_true.
    rs_result-is_test_run = iv_test_run.
    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-wbs_element IS INITIAL
          OR ls_request-reservation_number IS INITIAL
          OR ls_request-item_changes IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
      INSERT ls_request-reservation_number INTO TABLE lt_seen_reservations.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.

      CLEAR lt_seen_items.
      LOOP AT ls_request-item_changes INTO DATA(ls_item_change).
        INSERT ls_item_change-item_number INTO TABLE lt_seen_items.
        IF ls_item_change-item_number IS INITIAL
            OR ( ls_item_change-change_storage_location <> abap_true
              AND ls_item_change-change_storage_location <> abap_false )
            OR ( ls_item_change-change_batch <> abap_true
              AND ls_item_change-change_batch <> abap_false )
            OR ( ls_item_change-change_storage_location = abap_false
              AND ls_item_change-change_batch = abap_false )
            OR sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_reservation.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    LOOP AT it_requests INTO ls_request.
      APPEND INITIAL LINE TO rs_result-items ASSIGNING <ls_result>.
      <ls_result>-wbs_element = ls_request-wbs_element.
      <ls_result>-reservation_number = ls_request-reservation_number.
      <ls_result>-item_changes = ls_request-item_changes.
      <ls_result>-is_test_run = iv_test_run.

      IF lv_stop_processing = abap_true.
        <ls_result>-is_skipped = abap_true.
        rs_result-skipped_count = rs_result-skipped_count + 1.
        CONTINUE.
      ENDIF.

      TRY.
          <ls_result> = change_reservation_item_stock(
            iv_wbs_element        = ls_request-wbs_element
            iv_reservation_number = ls_request-reservation_number
            it_item_changes       = ls_request-item_changes
            iv_test_run           = iv_test_run ).
        CATCH zcx_invalid_reservation.
          <ls_result>-wbs_element = ls_request-wbs_element.
          <ls_result>-reservation_number = ls_request-reservation_number.
          <ls_result>-item_changes = ls_request-item_changes.
          <ls_result>-is_test_run = iv_test_run.
          <ls_result>-messages = VALUE #(
            ( type    = 'E'
              message = 'Reservation items are not open under this WBS and reservation' ) ).
      ENDTRY.

      IF <ls_result>-is_committed = abap_true.
        rs_result-is_committed = abap_true.
      ENDIF.
      IF <ls_result>-is_successful = abap_true.
        rs_result-successful_count = rs_result-successful_count + 1.
      ELSE.
        rs_result-failed_count = rs_result-failed_count + 1.
        rs_result-is_successful = abap_false.
        IF iv_stop_on_failure = abap_true.
          lv_stop_processing = abap_true.
          rs_result-stopped_on_failure = abap_true.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD change_resv_stock_atomic.
    TYPES ty_seen_reservation TYPE
      zif_project_reservation_api=>ty_reservation_number.
    TYPES ty_seen_item TYPE resb-rspos.
    DATA lt_seen_reservations TYPE HASHED TABLE OF ty_seen_reservation
      WITH UNIQUE KEY table_line.
    DATA lt_seen_items TYPE HASHED TABLE OF ty_seen_item
      WITH UNIQUE KEY table_line.
    DATA lt_seen_wbs_elements TYPE HASHED TABLE OF
      zif_project_stock_repository=>ty_wbs_element
      WITH UNIQUE KEY table_line.
    DATA lt_wbs_elements TYPE zif_project_stock_repository=>ty_wbs_elements.
    DATA lt_open_reservations TYPE
      zcl_project_stock_service=>ty_open_reservations.
    DATA lv_has_failure TYPE abap_bool.
    DATA lv_has_error_message TYPE abap_bool.
    FIELD-SYMBOLS <ls_result> TYPE ty_stock_change_result.

    IF it_requests IS INITIAL
        OR ( iv_test_run <> abap_true AND iv_test_run <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_reservation.
    ENDIF.

    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-wbs_element IS INITIAL
          OR ls_request-reservation_number IS INITIAL
          OR ls_request-item_changes IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.

      INSERT ls_request-reservation_number INTO TABLE lt_seen_reservations.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.

      INSERT ls_request-wbs_element INTO TABLE lt_seen_wbs_elements.
      IF sy-subrc = 0.
        APPEND ls_request-wbs_element TO lt_wbs_elements.
      ENDIF.

      CLEAR lt_seen_items.
      LOOP AT ls_request-item_changes INTO DATA(ls_item_change).
        INSERT ls_item_change-item_number INTO TABLE lt_seen_items.
        IF ls_item_change-item_number IS INITIAL
            OR ( ls_item_change-change_storage_location <> abap_true
              AND ls_item_change-change_storage_location <> abap_false )
            OR ( ls_item_change-change_batch <> abap_true
              AND ls_item_change-change_batch <> abap_false )
            OR ( ls_item_change-change_storage_location = abap_false
              AND ls_item_change-change_batch = abap_false )
            OR sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_reservation.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    TRY.
        lt_open_reservations =
          mo_project_stock_service->read_open_reservations(
            it_wbs_elements = lt_wbs_elements ).
      CATCH zcx_invalid_stock_request.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
    ENDTRY.

    LOOP AT it_requests INTO ls_request.
      LOOP AT ls_request-item_changes INTO ls_item_change.
        READ TABLE lt_open_reservations TRANSPORTING NO FIELDS
          WITH KEY reservation_number = ls_request-reservation_number
                   reservation_item   = ls_item_change-item_number
                   wbs_element        = ls_request-wbs_element.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_reservation.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

    rs_result-is_successful = abap_true.
    rs_result-is_test_run = iv_test_run.
    LOOP AT it_requests INTO ls_request.
      APPEND VALUE #(
        wbs_element        = ls_request-wbs_element
        reservation_number = ls_request-reservation_number
        item_changes       = ls_request-item_changes
        is_test_run        = iv_test_run
        is_successful      = abap_true ) TO rs_result-items.
    ENDLOOP.

    IF iv_test_run = abap_true.
      rs_result-successful_count = lines( rs_result-items ).
      RETURN.
    ENDIF.

    LOOP AT it_requests INTO ls_request.
      READ TABLE rs_result-items INDEX sy-tabix ASSIGNING <ls_result>.
      DATA(ls_api_result) = mo_api->change_reservation_stock(
        iv_reservation_number = ls_request-reservation_number
        it_item_changes       = ls_request-item_changes ).
      <ls_result>-messages = ls_api_result-messages.
      <ls_result>-is_successful = ls_api_result-is_successful.
      CLEAR lv_has_error_message.
      LOOP AT <ls_result>-messages INTO DATA(ls_message).
        IF ls_message-type = 'A'
            OR ls_message-type = 'E'
            OR ls_message-type = 'X'.
          <ls_result>-is_successful = abap_false.
          lv_has_error_message = abap_true.
        ENDIF.
      ENDLOOP.
      IF <ls_result>-is_successful <> abap_true.
        IF lv_has_error_message = abap_false.
          APPEND VALUE #(
            type    = 'E'
            message = 'Reservation stock change failed without an error message' )
            TO <ls_result>-messages.
        ENDIF.
        lv_has_failure = abap_true.
      ENDIF.
    ENDLOOP.

    IF lv_has_failure = abap_true.
      mo_api->rollback( ).
      rs_result-is_successful = abap_false.
      rs_result-failed_count = lines( rs_result-items ).
      rs_result-was_rolled_back = abap_true.
      LOOP AT rs_result-items ASSIGNING <ls_result>.
        <ls_result>-is_successful = abap_false.
        <ls_result>-is_changed = abap_false.
        <ls_result>-is_committed = abap_false.
        <ls_result>-was_rolled_back = abap_true.
      ENDLOOP.
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
      rs_result-is_successful = abap_false.
      rs_result-failed_count = lines( rs_result-items ).
      rs_result-was_rolled_back = abap_true.
      IF ls_commit_result-message-message IS NOT INITIAL.
        APPEND ls_commit_result-message TO rs_result-messages.
      ELSE.
        APPEND VALUE #(
          type    = 'E'
          message = 'Atomic reservation stock change commit failed' )
          TO rs_result-messages.
      ENDIF.
      LOOP AT rs_result-items ASSIGNING <ls_result>.
        <ls_result>-is_successful = abap_false.
        <ls_result>-is_changed = abap_false.
        <ls_result>-is_committed = abap_false.
        <ls_result>-was_rolled_back = abap_true.
      ENDLOOP.
      RETURN.
    ENDIF.

    rs_result-is_successful = abap_true.
    rs_result-is_committed = abap_true.
    rs_result-successful_count = lines( rs_result-items ).
    LOOP AT rs_result-items ASSIGNING <ls_result>.
      <ls_result>-is_successful = abap_true.
      <ls_result>-is_changed = abap_true.
      <ls_result>-is_committed = abap_true.
    ENDLOOP.
  ENDMETHOD.

  METHOD reserve_batch_allocation.
    DATA lt_splits TYPE ty_allocation_splits.

    IF iv_stop_on_failure <> abap_true
        AND iv_stop_on_failure <> abap_false.
      RAISE EXCEPTION TYPE zcx_invalid_reservation.
    ENDIF.


    LOOP AT is_allocation-allocation-batch_allocations
      INTO DATA(ls_batch_split).
      APPEND VALUE #(
        request_id              = ls_batch_split-batch_allocation-request_id
        material                = ls_batch_split-batch_allocation-material
        plant                   = ls_batch_split-batch_allocation-plant
        storage_location        = ls_batch_split-batch_allocation-storage_location
        batch                   = ls_batch_split-batch_allocation-batch
        expiration_date         =
          ls_batch_split-batch_allocation-expiration_date
        minimum_shelf_life_days =
          ls_batch_split-batch_allocation-minimum_shelf_life_days
        require_known_expiry    =
          ls_batch_split-batch_allocation-require_known_expiry
        allow_undated_batches   =
          ls_batch_split-batch_allocation-allow_undated_batches
        quantity                = ls_batch_split-batch_allocation-allocated_quantity
        base_unit               = ls_batch_split-base_unit ) TO lt_splits.
    ENDLOOP.

    rs_result = reserve_allocation(
      it_allocations             = is_allocation-allocation-allocations
      it_wbs_assignments         = is_allocation-wbs_assignments
      it_splits                  = lt_splits
      iv_required_date           = iv_required_date
      it_wbs_required_dates      = it_wbs_required_dates
      iv_minimum_shelf_life_days = iv_minimum_shelf_life_days
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_allocation
      iv_require_batch           = abap_true
      iv_atomic                  = iv_atomic
      iv_stop_on_failure         = iv_stop_on_failure ).
  ENDMETHOD.

  METHOD reserve_location_allocation.
    DATA lt_splits TYPE ty_allocation_splits.

    IF iv_stop_on_failure <> abap_true
        AND iv_stop_on_failure <> abap_false.
      RAISE EXCEPTION TYPE zcx_invalid_reservation.
    ENDIF.


    LOOP AT is_allocation-allocation-storage_allocations
      INTO DATA(ls_location_split).
      APPEND VALUE #(
        request_id       =
          ls_location_split-storage_allocation-request_id
        material         =
          ls_location_split-storage_allocation-material
        plant            =
          ls_location_split-storage_allocation-plant
        storage_location =
          ls_location_split-storage_allocation-storage_location
        quantity         =
          ls_location_split-storage_allocation-allocated_quantity
        base_unit        = ls_location_split-base_unit ) TO lt_splits.
    ENDLOOP.

    rs_result = reserve_allocation(
      it_allocations             = is_allocation-allocation-allocations
      it_wbs_assignments         = is_allocation-wbs_assignments
      it_splits                  = lt_splits
      iv_required_date           = iv_required_date
      it_wbs_required_dates      = it_wbs_required_dates
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_allocation
      iv_require_batch           = abap_false
      iv_atomic                  = iv_atomic
      iv_stop_on_failure         = iv_stop_on_failure ).
  ENDMETHOD.

  METHOD reserve_wbs_fefo.
    DATA lt_fefo_demands TYPE zcl_project_stock_service=>ty_demands.
    DATA lt_splits TYPE ty_allocation_splits.
    DATA lt_rechecked_splits TYPE ty_allocation_splits.
    DATA lv_include_undated_batches TYPE abap_bool.

    IF ( iv_test_run <> abap_true AND iv_test_run <> abap_false )
        OR ( iv_require_full_quantity <> abap_true
          AND iv_require_full_quantity <> abap_false )
        OR ( iv_atomic <> abap_true AND iv_atomic <> abap_false )
        OR ( iv_stop_on_failure <> abap_true
          AND iv_stop_on_failure <> abap_false )
        OR ( iv_include_undated_batches <> abap_true
          AND iv_include_undated_batches <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_reservation.
    ENDIF.
    validate_wbs_date_inputs(
      it_demands            = it_demands
      iv_required_date      = iv_required_date
      it_wbs_required_dates = it_wbs_required_dates ).

    LOOP AT it_demands INTO DATA(ls_fefo_demand).
      DATA(lv_required_date_for_demand) = iv_required_date.
      IF it_wbs_required_dates IS NOT INITIAL.
        READ TABLE it_wbs_required_dates INTO DATA(ls_wbs_date_for_demand)
          WITH KEY wbs_element = ls_fefo_demand-wbs_element.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_reservation.
        ENDIF.
        lv_required_date_for_demand =
          ls_wbs_date_for_demand-required_date.
      ENDIF.

      DATA(lv_fefo_as_of_date) = ls_fefo_demand-fefo_as_of_date.
      IF lv_required_date_for_demand > lv_fefo_as_of_date.
        lv_fefo_as_of_date = lv_required_date_for_demand.
      ENDIF.
      APPEND VALUE #( BASE ls_fefo_demand
        fefo_as_of_date = lv_fefo_as_of_date ) TO lt_fefo_demands.
    ENDLOOP.

    lv_include_undated_batches = iv_include_undated_batches.
    IF iv_minimum_shelf_life_days > 0.
      lv_include_undated_batches = abap_false.
    ENDIF.

    rs_result-preview = mo_project_stock_service->preview_fefo(
      it_demands                     = lt_fefo_demands
      it_storage_location_priority   = it_storage_location_priority
      it_request_location_priorities = it_request_location_priorities
      it_allowed_storage_locations   = it_allowed_storage_locations
      it_request_locations           = it_request_locations
      iv_as_of_date                  = iv_as_of_date
      iv_minimum_shelf_life_days     = iv_minimum_shelf_life_days
      iv_include_undated_batches     = lv_include_undated_batches
      iv_require_full_quantity       = iv_require_full_quantity
      iv_reservation_through_date    = iv_reservation_through_date ).

    IF iv_require_full_quantity = abap_true.
      LOOP AT rs_result-preview-allocation-allocations INTO
        DATA(ls_preview_allocation).
        IF ls_preview_allocation-allocation-shortfall_quantity > 0.
          ADD 1 TO rs_result-reservation-failed_count.
        ENDIF.
      ENDLOOP.
      IF rs_result-reservation-failed_count > 0.
        rs_result-reservation-is_test_run = iv_test_run.
        APPEND VALUE #(
          type    = 'E'
          message = 'FEFO preview has a shortfall; no reservation was created' )
          TO rs_result-reservation-messages.
        RETURN.
      ENDIF.
    ENDIF.

    LOOP AT rs_result-preview-allocation-batch_allocations
      INTO DATA(ls_selected_batch).
      APPEND VALUE #(
        request_id              =
          ls_selected_batch-batch_allocation-request_id
        material                = ls_selected_batch-batch_allocation-material
        plant                   = ls_selected_batch-batch_allocation-plant
        storage_location        =
          ls_selected_batch-batch_allocation-storage_location
        batch                   = ls_selected_batch-batch_allocation-batch
        expiration_date         =
          ls_selected_batch-batch_allocation-expiration_date
        minimum_shelf_life_days =
          ls_selected_batch-batch_allocation-minimum_shelf_life_days
        require_known_expiry    =
          ls_selected_batch-batch_allocation-require_known_expiry
        allow_undated_batches   =
          ls_selected_batch-batch_allocation-allow_undated_batches
        quantity                =
          ls_selected_batch-batch_allocation-allocated_quantity
        base_unit               = ls_selected_batch-base_unit ) TO lt_splits.
    ENDLOOP.

    DATA(ls_rechecked_fefo) = mo_project_stock_service->preview_fefo(
      it_demands                     = lt_fefo_demands
      it_storage_location_priority   = it_storage_location_priority
      it_request_location_priorities = it_request_location_priorities
      it_allowed_storage_locations   = it_allowed_storage_locations
      it_request_locations           = it_request_locations
      iv_as_of_date                  = iv_as_of_date
      iv_minimum_shelf_life_days     = iv_minimum_shelf_life_days
      iv_include_undated_batches     = lv_include_undated_batches
      iv_require_full_quantity       = iv_require_full_quantity
      iv_reservation_through_date    = iv_reservation_through_date ).
    LOOP AT ls_rechecked_fefo-allocation-batch_allocations
      INTO DATA(ls_rechecked_batch).
      APPEND VALUE #(
        request_id              =
          ls_rechecked_batch-batch_allocation-request_id
        material                = ls_rechecked_batch-batch_allocation-material
        plant                   = ls_rechecked_batch-batch_allocation-plant
        storage_location        =
          ls_rechecked_batch-batch_allocation-storage_location
        batch                   = ls_rechecked_batch-batch_allocation-batch
        expiration_date         =
          ls_rechecked_batch-batch_allocation-expiration_date
        minimum_shelf_life_days =
          ls_rechecked_batch-batch_allocation-minimum_shelf_life_days
        require_known_expiry    =
          ls_rechecked_batch-batch_allocation-require_known_expiry
        allow_undated_batches   =
          ls_rechecked_batch-batch_allocation-allow_undated_batches
        quantity                =
          ls_rechecked_batch-batch_allocation-allocated_quantity
        base_unit               = ls_rechecked_batch-base_unit )
        TO lt_rechecked_splits.
    ENDLOOP.

    IF same_allocation_splits(
        it_expected = lt_splits
        it_actual   = lt_rechecked_splits ) <> abap_true
        OR same_unit_allocation_summaries(
          it_expected = rs_result-preview-allocation-allocations
          it_actual   = ls_rechecked_fefo-allocation-allocations )
          <> abap_true.
      rs_result-reservation-is_successful = abap_false.
      rs_result-reservation-is_test_run = iv_test_run.
      rs_result-reservation-failed_count = 1.
      APPEND VALUE #(
        type    = 'E'
        message = 'FEFO allocation changed after preview; no reservation was created' )
        TO rs_result-reservation-messages.
      RETURN.
    ENDIF.

    rs_result-reservation = reserve_allocation(
      it_allocations             =
        rs_result-preview-allocation-allocations
      it_wbs_assignments         = rs_result-preview-wbs_assignments
      it_splits                  = lt_splits
      iv_required_date           = iv_required_date
      it_wbs_required_dates      = it_wbs_required_dates
      iv_minimum_shelf_life_days = iv_minimum_shelf_life_days
      iv_include_undated_batches = lv_include_undated_batches
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_quantity
      iv_require_batch           = abap_true
      iv_atomic                  = iv_atomic
      iv_stop_on_failure         = iv_stop_on_failure ).
  ENDMETHOD.

  METHOD reserve_wbs_fefo_priority.
    TYPES:
      BEGIN OF ty_reservation_context,
        internal_request_id TYPE c LENGTH 30,
        request_id          TYPE c LENGTH 30,
        wbs_element         TYPE zif_project_stock_repository=>ty_wbs_element,
        priority            TYPE i,
      END OF ty_reservation_context,
      ty_reservation_contexts TYPE STANDARD TABLE OF
        ty_reservation_context WITH EMPTY KEY.
    DATA lt_contexts TYPE ty_reservation_contexts.
    DATA lt_priority_demands TYPE
      zcl_project_stock_service=>ty_priority_fefo_demands.
    DATA lt_int_loc_prios TYPE
      zcl_stock_service=>ty_request_location_priorities.
    DATA lt_int_request_locations TYPE
      zcl_project_stock_service=>ty_request_locations.
    DATA lt_seen_location_priorities TYPE HASHED TABLE OF
      zcl_stock_service=>ty_request_location_priority
      WITH UNIQUE KEY request_id storage_location.
    DATA lt_validation_demands TYPE zcl_project_stock_service=>ty_demands.
    DATA lt_allocations TYPE zcl_stock_service=>ty_unit_allocation_summaries.
    DATA lt_rechecked_allocations TYPE
      zcl_stock_service=>ty_unit_allocation_summaries.
    DATA lt_assignments TYPE zcl_project_stock_service=>ty_wbs_assignments.
    DATA lt_splits TYPE ty_allocation_splits.
    DATA lt_rechecked_splits TYPE ty_allocation_splits.
    DATA lv_include_undated_batches TYPE abap_bool.
    DATA lv_internal_index TYPE i.
    DATA lv_internal_request_id TYPE c LENGTH 30.

    IF ( iv_test_run <> abap_true AND iv_test_run <> abap_false )
        OR ( iv_require_full_quantity <> abap_true
          AND iv_require_full_quantity <> abap_false )
        OR ( iv_atomic <> abap_true AND iv_atomic <> abap_false )
        OR ( iv_stop_on_failure <> abap_true
          AND iv_stop_on_failure <> abap_false )
        OR ( iv_include_undated_batches <> abap_true
          AND iv_include_undated_batches <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_reservation.
    ENDIF.

    LOOP AT it_demands INTO DATA(ls_demand).
      IF ls_demand-request_id IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      IF ls_demand-fefo_as_of_date IS NOT INITIAL
          AND zcl_date_validation=>is_valid_gregorian_date(
            iv_date = ls_demand-fefo_as_of_date ) <> abap_true.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      DATA(lv_required_date_for_demand) = iv_required_date.
      IF it_wbs_required_dates IS NOT INITIAL.
        READ TABLE it_wbs_required_dates
          INTO DATA(ls_wbs_date_for_demand)
          WITH KEY wbs_element = ls_demand-wbs_element.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_reservation.
        ENDIF.
        lv_required_date_for_demand =
          ls_wbs_date_for_demand-required_date.
      ENDIF.

      DATA(lv_fefo_as_of_date) = ls_demand-fefo_as_of_date.
      IF lv_required_date_for_demand > lv_fefo_as_of_date.
        lv_fefo_as_of_date = lv_required_date_for_demand.
      ENDIF.
      ADD 1 TO lv_internal_index.
      CLEAR lv_internal_request_id.
      lv_internal_request_id = lv_internal_index.
      APPEND VALUE #(
        request_id              = lv_internal_request_id
        priority                = ls_demand-priority
        wbs_element             = ls_demand-wbs_element
        material                = ls_demand-material
        plant                   = ls_demand-plant
        storage_location        = ls_demand-storage_location
        allow_location_fallback = ls_demand-allow_location_fallback
        batch                   = ls_demand-batch
        requested_quantity      = ls_demand-requested_quantity
        require_full_quantity   = ls_demand-require_full_quantity
        unit                    = ls_demand-unit
        fefo_as_of_date         = lv_fefo_as_of_date
        minimum_shelf_life_days =
          ls_demand-minimum_shelf_life_days
        require_known_expiry    = ls_demand-require_known_expiry
        allow_undated_batches   = ls_demand-allow_undated_batches )
        TO lt_priority_demands.
      APPEND VALUE #(
        request_id              = ls_demand-request_id
        wbs_element             = ls_demand-wbs_element
        material                = ls_demand-material
        plant                   = ls_demand-plant
        storage_location        = ls_demand-storage_location
        allow_location_fallback = ls_demand-allow_location_fallback
        batch                   = ls_demand-batch
        requested_quantity      = ls_demand-requested_quantity
        require_full_quantity   = ls_demand-require_full_quantity
        unit                    = ls_demand-unit
        require_known_expiry    = ls_demand-require_known_expiry
        allow_undated_batches   = ls_demand-allow_undated_batches )
        TO lt_validation_demands.
      APPEND VALUE #(
        internal_request_id = lv_internal_request_id
        request_id          = ls_demand-request_id
        wbs_element         = ls_demand-wbs_element
        priority            = ls_demand-priority )
        TO lt_contexts.
    ENDLOOP.

    validate_wbs_date_inputs(
      it_demands            = lt_validation_demands
      iv_required_date      = iv_required_date
      it_wbs_required_dates = it_wbs_required_dates ).

    LOOP AT it_request_location_priorities
        INTO DATA(ls_request_location_priority).
      IF ls_request_location_priority-request_id IS INITIAL
          OR ls_request_location_priority-storage_location IS INITIAL
          OR ls_request_location_priority-priority_rank <= 0
          OR NOT line_exists( lt_contexts[
            request_id = ls_request_location_priority-request_id ] ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request_location_priority
        INTO TABLE lt_seen_location_priorities.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_contexts INTO DATA(ls_rank_context).
      LOOP AT it_request_location_priorities
          INTO ls_request_location_priority
          WHERE request_id = ls_rank_context-request_id.
        APPEND VALUE #(
          request_id       = ls_rank_context-internal_request_id
          storage_location =
            ls_request_location_priority-storage_location
          priority_rank    =
            ls_request_location_priority-priority_rank )
          TO lt_int_loc_prios.
      ENDLOOP.
    ENDLOOP.

    lv_include_undated_batches = iv_include_undated_batches.
    IF iv_minimum_shelf_life_days > 0.
      lv_include_undated_batches = abap_false.
    ENDIF.

    LOOP AT it_request_locations INTO DATA(ls_request_location).
      IF ls_request_location-request_id IS INITIAL
          OR ls_request_location-storage_location IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
      DATA(lv_scope_found) = abap_false.
      LOOP AT lt_contexts INTO DATA(ls_location_scope_context)
          WHERE request_id = ls_request_location-request_id.
        APPEND VALUE #(
          request_id       =
            ls_location_scope_context-internal_request_id
          storage_location =
            ls_request_location-storage_location )
          TO lt_int_request_locations.
        lv_scope_found = abap_true.
      ENDLOOP.
      IF lv_scope_found <> abap_true.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
    ENDLOOP.

    DATA(ls_first_preview) = mo_project_stock_service->preview_fefo_priority(
      it_demands                     = lt_priority_demands
      it_storage_location_priority   = it_storage_location_priority
      it_request_location_priorities = lt_int_loc_prios
      it_allowed_storage_locations   = it_allowed_storage_locations
      it_request_locations           = lt_int_request_locations
      iv_as_of_date                  = iv_as_of_date
      iv_minimum_shelf_life_days     = iv_minimum_shelf_life_days
      iv_include_undated_batches     = lv_include_undated_batches
      iv_require_full_quantity       = iv_require_full_quantity
      iv_reservation_through_date    = iv_reservation_through_date ).
    rs_result-preview-request_locations = it_request_locations.

    LOOP AT lt_contexts INTO DATA(ls_context).
      READ TABLE ls_first_preview-allocations
          INTO DATA(ls_first_allocation)
        WITH KEY allocation-allocation-request_id =
          ls_context-internal_request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
      APPEND ls_first_allocation-allocation TO lt_allocations.
      ls_first_allocation-allocation-allocation-request_id =
        ls_context-request_id.
      APPEND VALUE #(
        allocation = ls_first_allocation-allocation
        priority   = ls_context-priority ) TO rs_result-preview-allocations.
      APPEND VALUE #(
        request_id  = ls_context-request_id
        wbs_element = ls_context-wbs_element
        priority    = ls_context-priority )
        TO rs_result-preview-wbs_assignments.
      APPEND VALUE #(
        request_id  = ls_context-internal_request_id
        wbs_element = ls_context-wbs_element ) TO lt_assignments.

      LOOP AT ls_first_preview-batch_allocations
          INTO DATA(ls_first_split)
          WHERE split-batch_allocation-request_id =
            ls_context-internal_request_id.
        APPEND VALUE #(
          request_id              =
            ls_first_split-split-batch_allocation-request_id
          material                =
            ls_first_split-split-batch_allocation-material
          plant                   =
            ls_first_split-split-batch_allocation-plant
          storage_location        =
            ls_first_split-split-batch_allocation-storage_location
          batch                   =
            ls_first_split-split-batch_allocation-batch
          expiration_date         =
            ls_first_split-split-batch_allocation-expiration_date
          minimum_shelf_life_days =
            ls_first_split-split-batch_allocation-minimum_shelf_life_days
          require_known_expiry    =
            ls_first_split-split-batch_allocation-require_known_expiry
          allow_undated_batches   =
            ls_first_split-split-batch_allocation-allow_undated_batches
          quantity                =
            ls_first_split-split-batch_allocation-allocated_quantity
          base_unit               = ls_first_split-split-base_unit )
          TO lt_splits.
        ls_first_split-split-batch_allocation-request_id =
          ls_context-request_id.
        APPEND ls_first_split TO rs_result-preview-batch_allocations.
      ENDLOOP.
    ENDLOOP.

    IF iv_require_full_quantity = abap_true.
      LOOP AT rs_result-preview-allocations
          INTO DATA(ls_preview_allocation).
        IF ls_preview_allocation-allocation-allocation-shortfall_quantity > 0.
          ADD 1 TO rs_result-reservation-failed_count.
        ENDIF.
      ENDLOOP.
      IF rs_result-reservation-failed_count > 0.
        rs_result-reservation-is_test_run = iv_test_run.
        APPEND VALUE #(
          type    = 'E'
          message = 'Priority FEFO preview has a shortfall; no reservation was created' )
          TO rs_result-reservation-messages.
        RETURN.
      ENDIF.
    ENDIF.

    DATA(ls_rechecked_preview) =
      mo_project_stock_service->preview_fefo_priority(
        it_demands                     = lt_priority_demands
        it_storage_location_priority   = it_storage_location_priority
        it_request_location_priorities = lt_int_loc_prios
        it_allowed_storage_locations   = it_allowed_storage_locations
        it_request_locations           = lt_int_request_locations
        iv_as_of_date                  = iv_as_of_date
        iv_minimum_shelf_life_days     = iv_minimum_shelf_life_days
        iv_include_undated_batches     = lv_include_undated_batches
        iv_require_full_quantity       = iv_require_full_quantity
        iv_reservation_through_date    = iv_reservation_through_date ).
    LOOP AT ls_rechecked_preview-allocations
        INTO DATA(ls_rechecked_allocation).
      APPEND ls_rechecked_allocation-allocation TO
        lt_rechecked_allocations.
    ENDLOOP.

    LOOP AT ls_rechecked_preview-batch_allocations
        INTO DATA(ls_rechecked_split).
      APPEND VALUE #(
        request_id              =
          ls_rechecked_split-split-batch_allocation-request_id
        material                =
          ls_rechecked_split-split-batch_allocation-material
        plant                   =
          ls_rechecked_split-split-batch_allocation-plant
        storage_location        =
          ls_rechecked_split-split-batch_allocation-storage_location
        batch                   =
          ls_rechecked_split-split-batch_allocation-batch
        expiration_date         =
          ls_rechecked_split-split-batch_allocation-expiration_date
        minimum_shelf_life_days =
          ls_rechecked_split-split-batch_allocation-minimum_shelf_life_days
        require_known_expiry    =
          ls_rechecked_split-split-batch_allocation-require_known_expiry
        allow_undated_batches   =
          ls_rechecked_split-split-batch_allocation-allow_undated_batches
        quantity                =
          ls_rechecked_split-split-batch_allocation-allocated_quantity
        base_unit               = ls_rechecked_split-split-base_unit )
        TO lt_rechecked_splits.
    ENDLOOP.

    IF same_allocation_splits(
        it_expected = lt_splits
        it_actual   = lt_rechecked_splits ) <> abap_true
        OR same_unit_allocation_summaries(
          it_expected = lt_allocations
          it_actual   = lt_rechecked_allocations ) <> abap_true.
      rs_result-reservation-is_successful = abap_false.
      rs_result-reservation-is_test_run = iv_test_run.
      rs_result-reservation-failed_count = 1.
      APPEND VALUE #(
        type    = 'E'
        message = 'Priority FEFO allocation changed after preview; no reservation was created' )
        TO rs_result-reservation-messages.
      RETURN.
    ENDIF.

    rs_result-reservation = reserve_allocation(
      it_allocations             = lt_allocations
      it_wbs_assignments         = lt_assignments
      it_splits                  = lt_splits
      iv_required_date           = iv_required_date
      it_wbs_required_dates      = it_wbs_required_dates
      iv_minimum_shelf_life_days = iv_minimum_shelf_life_days
      iv_include_undated_batches = lv_include_undated_batches
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_quantity
      iv_require_batch           = abap_true
      iv_atomic                  = iv_atomic
      iv_stop_on_failure         = iv_stop_on_failure ).
  ENDMETHOD.

  METHOD reserve_wbs_fefo_by_date.
    TYPES:
      BEGIN OF ty_dated_reservation_context,
        internal_request_id TYPE c LENGTH 30,
        request_id          TYPE c LENGTH 30,
        wbs_element         TYPE zif_project_stock_repository=>ty_wbs_element,
        required_date       TYPE d,
        priority            TYPE i,
      END OF ty_dated_reservation_context,
      ty_dated_reservation_contexts TYPE STANDARD TABLE OF
        ty_dated_reservation_context WITH EMPTY KEY.
    DATA lt_contexts TYPE ty_dated_reservation_contexts.
    DATA lt_internal_demands TYPE
      zcl_project_stock_service=>ty_dated_fefo_demands.
    DATA lt_int_loc_prios TYPE
      zcl_stock_service=>ty_request_location_priorities.
    DATA lt_int_request_locations TYPE
      zcl_project_stock_service=>ty_request_locations.
    DATA lt_seen_location_priorities TYPE HASHED TABLE OF
      zcl_stock_service=>ty_request_location_priority
      WITH UNIQUE KEY request_id storage_location.
    DATA lt_allocations TYPE zcl_stock_service=>ty_unit_allocation_summaries.
    DATA lt_rechecked_allocations TYPE
      zcl_stock_service=>ty_unit_allocation_summaries.
    DATA lt_assignments TYPE zcl_project_stock_service=>ty_wbs_assignments.
    DATA lt_splits TYPE ty_allocation_splits.
    DATA lt_rechecked_splits TYPE ty_allocation_splits.
    DATA lt_request_required_dates TYPE ty_request_required_dates.
    DATA lv_internal_index TYPE i.
    DATA lv_internal_request_id TYPE c LENGTH 30.

    IF ( iv_test_run <> abap_true AND iv_test_run <> abap_false )
        OR ( iv_require_full_quantity <> abap_true
          AND iv_require_full_quantity <> abap_false )
        OR ( iv_atomic <> abap_true AND iv_atomic <> abap_false )
        OR ( iv_stop_on_failure <> abap_true
          AND iv_stop_on_failure <> abap_false )
        OR ( iv_include_undated_batches <> abap_true
          AND iv_include_undated_batches <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_reservation.
    ENDIF.
    LOOP AT it_demands INTO DATA(ls_demand).
      IF ls_demand-request_id IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      IF ls_demand-wbs_element IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
      validate_required_date( iv_required_date = ls_demand-required_date ).
      ADD 1 TO lv_internal_index.
      CLEAR lv_internal_request_id.
      lv_internal_request_id = lv_internal_index.
      APPEND VALUE #(
        request_id              = lv_internal_request_id
        required_date           = ls_demand-required_date
        priority                = ls_demand-priority
        wbs_element             = ls_demand-wbs_element
        material                = ls_demand-material
        plant                   = ls_demand-plant
        storage_location        = ls_demand-storage_location
        allow_location_fallback = ls_demand-allow_location_fallback
        batch                   = ls_demand-batch
        requested_quantity      = ls_demand-requested_quantity
        require_full_quantity   = ls_demand-require_full_quantity
        unit                    = ls_demand-unit
        fefo_as_of_date         = ls_demand-fefo_as_of_date
        minimum_shelf_life_days = ls_demand-minimum_shelf_life_days
        require_known_expiry    = ls_demand-require_known_expiry
        allow_undated_batches   = ls_demand-allow_undated_batches )
        TO lt_internal_demands.
      INSERT VALUE #(
        request_id    = lv_internal_request_id
        required_date = ls_demand-required_date )
        INTO TABLE lt_request_required_dates.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
      APPEND VALUE #(
        internal_request_id = lv_internal_request_id
        request_id          = ls_demand-request_id
        wbs_element         = ls_demand-wbs_element
        required_date       = ls_demand-required_date
        priority            = ls_demand-priority ) TO lt_contexts.
    ENDLOOP.

    LOOP AT it_request_location_priorities
        INTO DATA(ls_request_location_priority).
      IF ls_request_location_priority-request_id IS INITIAL
          OR ls_request_location_priority-storage_location IS INITIAL
          OR ls_request_location_priority-priority_rank <= 0
          OR NOT line_exists( lt_contexts[
            request_id = ls_request_location_priority-request_id ] ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request_location_priority
        INTO TABLE lt_seen_location_priorities.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_contexts INTO DATA(ls_rank_context).
      LOOP AT it_request_location_priorities
          INTO ls_request_location_priority
          WHERE request_id = ls_rank_context-request_id.
        APPEND VALUE #(
          request_id       = ls_rank_context-internal_request_id
          storage_location =
            ls_request_location_priority-storage_location
          priority_rank    =
            ls_request_location_priority-priority_rank )
          TO lt_int_loc_prios.
      ENDLOOP.
    ENDLOOP.

    LOOP AT it_request_locations INTO DATA(ls_request_location).
      IF ls_request_location-request_id IS INITIAL
          OR ls_request_location-storage_location IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
      DATA(lv_scope_found) = abap_false.
      LOOP AT lt_contexts INTO DATA(ls_location_scope_context)
          WHERE request_id = ls_request_location-request_id.
        APPEND VALUE #(
          request_id       =
            ls_location_scope_context-internal_request_id
          storage_location =
            ls_request_location-storage_location )
          TO lt_int_request_locations.
        lv_scope_found = abap_true.
      ENDLOOP.
      IF lv_scope_found <> abap_true.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
    ENDLOOP.

    DATA(ls_first_preview) = mo_project_stock_service->preview_fefo_by_date(
      it_demands                     = lt_internal_demands
      it_storage_location_priority   = it_storage_location_priority
      it_request_location_priorities = lt_int_loc_prios
      it_allowed_storage_locations   = it_allowed_storage_locations
      it_request_locations           = lt_int_request_locations
      iv_as_of_date                  = iv_as_of_date
      iv_minimum_shelf_life_days     = iv_minimum_shelf_life_days
      iv_include_undated_batches     = iv_include_undated_batches
      iv_require_full_quantity       = iv_require_full_quantity
      iv_reservation_through_date    = iv_reservation_through_date ).
    rs_result-preview-request_locations = it_request_locations.

    LOOP AT lt_contexts INTO DATA(ls_context).
      READ TABLE ls_first_preview-allocations
          INTO DATA(ls_first_allocation)
        WITH KEY allocation-allocation-request_id =
          ls_context-internal_request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
      APPEND ls_first_allocation-allocation TO lt_allocations.
      ls_first_allocation-allocation-allocation-request_id =
        ls_context-request_id.
      APPEND VALUE #(
        allocation    = ls_first_allocation-allocation
        required_date = ls_context-required_date
        priority      = ls_context-priority ) TO rs_result-preview-allocations.
      APPEND VALUE #(
        request_id    = ls_context-request_id
        wbs_element   = ls_context-wbs_element
        required_date = ls_context-required_date
        priority      = ls_context-priority )
        TO rs_result-preview-wbs_assignments.
      APPEND VALUE #(
        request_id  = ls_context-internal_request_id
        wbs_element = ls_context-wbs_element ) TO lt_assignments.

      LOOP AT ls_first_preview-batch_allocations
          INTO DATA(ls_first_split)
          WHERE split-batch_allocation-request_id =
            ls_context-internal_request_id.
        APPEND VALUE #(
          request_id              =
            ls_first_split-split-batch_allocation-request_id
          material                =
            ls_first_split-split-batch_allocation-material
          plant                   =
            ls_first_split-split-batch_allocation-plant
          storage_location        =
            ls_first_split-split-batch_allocation-storage_location
          batch                   =
            ls_first_split-split-batch_allocation-batch
          expiration_date         =
            ls_first_split-split-batch_allocation-expiration_date
          minimum_shelf_life_days =
            ls_first_split-split-batch_allocation-minimum_shelf_life_days
          require_known_expiry    =
            ls_first_split-split-batch_allocation-require_known_expiry
          allow_undated_batches   =
            ls_first_split-split-batch_allocation-allow_undated_batches
          quantity                =
            ls_first_split-split-batch_allocation-allocated_quantity
          base_unit               = ls_first_split-split-base_unit )
          TO lt_splits.
        ls_first_split-split-batch_allocation-request_id =
          ls_context-request_id.
        APPEND ls_first_split TO rs_result-preview-batch_allocations.
      ENDLOOP.
    ENDLOOP.

    IF iv_require_full_quantity = abap_true.
      LOOP AT rs_result-preview-allocations INTO DATA(ls_preview_allocation).
        IF ls_preview_allocation-allocation-allocation-shortfall_quantity > 0.
          ADD 1 TO rs_result-reservation-failed_count.
        ENDIF.
      ENDLOOP.
      IF rs_result-reservation-failed_count > 0.
        rs_result-reservation-is_test_run = iv_test_run.
        APPEND VALUE #(
          type    = 'E'
          message = 'Dated FEFO preview has a shortfall; no reservation was created' )
          TO rs_result-reservation-messages.
        RETURN.
      ENDIF.
    ENDIF.

    DATA(ls_rechecked_fefo) = mo_project_stock_service->preview_fefo_by_date(
      it_demands                     = lt_internal_demands
      it_storage_location_priority   = it_storage_location_priority
      it_request_location_priorities = lt_int_loc_prios
      it_allowed_storage_locations   = it_allowed_storage_locations
      it_request_locations           = lt_int_request_locations
      iv_as_of_date                  = iv_as_of_date
      iv_minimum_shelf_life_days     = iv_minimum_shelf_life_days
      iv_include_undated_batches     = iv_include_undated_batches
      iv_require_full_quantity       = iv_require_full_quantity
      iv_reservation_through_date    = iv_reservation_through_date ).
    LOOP AT ls_rechecked_fefo-allocations
        INTO DATA(ls_rechecked_allocation).
      APPEND ls_rechecked_allocation-allocation TO
        lt_rechecked_allocations.
    ENDLOOP.

    LOOP AT ls_rechecked_fefo-batch_allocations INTO DATA(ls_rechecked_batch).
      APPEND VALUE #(
        request_id              =
          ls_rechecked_batch-split-batch_allocation-request_id
        material                =
          ls_rechecked_batch-split-batch_allocation-material
        plant                   =
          ls_rechecked_batch-split-batch_allocation-plant
        storage_location        =
          ls_rechecked_batch-split-batch_allocation-storage_location
        batch                   =
          ls_rechecked_batch-split-batch_allocation-batch
        expiration_date         =
          ls_rechecked_batch-split-batch_allocation-expiration_date
        minimum_shelf_life_days =
          ls_rechecked_batch-split-batch_allocation-minimum_shelf_life_days
        require_known_expiry    =
          ls_rechecked_batch-split-batch_allocation-require_known_expiry
        allow_undated_batches   =
          ls_rechecked_batch-split-batch_allocation-allow_undated_batches
        quantity                =
          ls_rechecked_batch-split-batch_allocation-allocated_quantity
        base_unit               = ls_rechecked_batch-split-base_unit )
        TO lt_rechecked_splits.
    ENDLOOP.

    IF same_allocation_splits(
        it_expected = lt_splits
        it_actual   = lt_rechecked_splits ) <> abap_true
        OR same_unit_allocation_summaries(
          it_expected = lt_allocations
          it_actual   = lt_rechecked_allocations ) <> abap_true.
      rs_result-reservation-is_successful = abap_false.
      rs_result-reservation-is_test_run = iv_test_run.
      rs_result-reservation-failed_count = 1.
      APPEND VALUE #(
        type    = 'E'
        message = 'Dated FEFO allocation changed after preview; no reservation was created' )
        TO rs_result-reservation-messages.
      RETURN.
    ENDIF.

    rs_result-reservation = reserve_allocation(
      it_allocations             = lt_allocations
      it_wbs_assignments         = lt_assignments
      it_splits                  = lt_splits
      it_request_required_dates  = lt_request_required_dates
      iv_minimum_shelf_life_days = iv_minimum_shelf_life_days
      iv_include_undated_batches = iv_include_undated_batches
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_quantity
      iv_require_batch           = abap_true
      iv_atomic                  = iv_atomic
      iv_stop_on_failure         = iv_stop_on_failure ).
  ENDMETHOD.
  METHOD reserve_wbs_by_location_date.
    TYPES:
      BEGIN OF ty_dated_reservation_context,
        internal_request_id TYPE c LENGTH 30,
        request_id          TYPE c LENGTH 30,
        wbs_element         TYPE zif_project_stock_repository=>ty_wbs_element,
        required_date       TYPE d,
        priority            TYPE i,
      END OF ty_dated_reservation_context,
      ty_dated_reservation_contexts TYPE STANDARD TABLE OF
        ty_dated_reservation_context WITH EMPTY KEY.
    DATA lt_contexts TYPE ty_dated_reservation_contexts.
    DATA lt_internal_demands TYPE
      zcl_project_stock_service=>ty_dated_location_demands.
    DATA lt_int_loc_prios TYPE
      zcl_stock_service=>ty_request_location_priorities.
    DATA lt_int_request_locations TYPE
      zcl_project_stock_service=>ty_request_locations.
    DATA lt_seen_location_priorities TYPE HASHED TABLE OF
      zcl_stock_service=>ty_request_location_priority
      WITH UNIQUE KEY request_id storage_location.
    DATA lt_allocations TYPE zcl_stock_service=>ty_unit_allocation_summaries.
    DATA lt_rechecked_allocations TYPE
      zcl_stock_service=>ty_unit_allocation_summaries.
    DATA lt_assignments TYPE zcl_project_stock_service=>ty_wbs_assignments.
    DATA lt_splits TYPE ty_allocation_splits.
    DATA lt_rechecked_splits TYPE ty_allocation_splits.
    DATA lt_request_required_dates TYPE ty_request_required_dates.
    DATA lv_internal_index TYPE i.
    DATA lv_internal_request_id TYPE c LENGTH 30.

    IF ( iv_test_run <> abap_true AND iv_test_run <> abap_false )
        OR ( iv_require_full_quantity <> abap_true
          AND iv_require_full_quantity <> abap_false )
        OR ( iv_atomic <> abap_true AND iv_atomic <> abap_false )
        OR ( iv_stop_on_failure <> abap_true
          AND iv_stop_on_failure <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_reservation.
    ENDIF.
    LOOP AT it_demands INTO DATA(ls_demand).
      IF ls_demand-request_id IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      IF ls_demand-wbs_element IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
      validate_required_date( iv_required_date = ls_demand-required_date ).
      ADD 1 TO lv_internal_index.
      CLEAR lv_internal_request_id.
      lv_internal_request_id = lv_internal_index.
      APPEND VALUE #(
        request_id              = lv_internal_request_id
        required_date           = ls_demand-required_date
        priority                = ls_demand-priority
        wbs_element             = ls_demand-wbs_element
        material                = ls_demand-material
        plant                   = ls_demand-plant
        storage_location        = ls_demand-storage_location
        allow_location_fallback = ls_demand-allow_location_fallback
        requested_quantity      = ls_demand-requested_quantity
        require_full_quantity   = ls_demand-require_full_quantity
        unit                    = ls_demand-unit )
        TO lt_internal_demands.
      INSERT VALUE #(
        request_id    = lv_internal_request_id
        required_date = ls_demand-required_date )
        INTO TABLE lt_request_required_dates.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
      APPEND VALUE #(
        internal_request_id = lv_internal_request_id
        request_id          = ls_demand-request_id
        wbs_element         = ls_demand-wbs_element
        required_date       = ls_demand-required_date
        priority            = ls_demand-priority ) TO lt_contexts.
    ENDLOOP.

    LOOP AT it_request_location_priorities
        INTO DATA(ls_request_location_priority).
      IF ls_request_location_priority-request_id IS INITIAL
          OR ls_request_location_priority-storage_location IS INITIAL
          OR ls_request_location_priority-priority_rank <= 0
          OR NOT line_exists( lt_contexts[
            request_id = ls_request_location_priority-request_id ] ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request_location_priority
        INTO TABLE lt_seen_location_priorities.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_contexts INTO DATA(ls_rank_context).
      LOOP AT it_request_location_priorities
          INTO ls_request_location_priority
          WHERE request_id = ls_rank_context-request_id.
        APPEND VALUE #(
          request_id       = ls_rank_context-internal_request_id
          storage_location =
            ls_request_location_priority-storage_location
          priority_rank    = ls_request_location_priority-priority_rank )
          TO lt_int_loc_prios.
      ENDLOOP.
    ENDLOOP.

    LOOP AT it_request_locations INTO DATA(ls_request_location).
      IF ls_request_location-request_id IS INITIAL
          OR ls_request_location-storage_location IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
      DATA(lv_scope_found) = abap_false.
      LOOP AT lt_contexts INTO DATA(ls_location_scope_context)
          WHERE request_id = ls_request_location-request_id.
        APPEND VALUE #(
          request_id       =
            ls_location_scope_context-internal_request_id
          storage_location =
            ls_request_location-storage_location )
          TO lt_int_request_locations.
        lv_scope_found = abap_true.
      ENDLOOP.
      IF lv_scope_found <> abap_true.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
    ENDLOOP.

    DATA(ls_first_preview) =
      mo_project_stock_service->preview_by_location_date(
      it_demands                     = lt_internal_demands
      it_storage_location_priority   = it_storage_location_priority
      it_request_location_priorities = lt_int_loc_prios
      it_allowed_storage_locations   = it_allowed_storage_locations
      it_request_locations           = lt_int_request_locations
      iv_require_full_quantity       = iv_require_full_quantity
      iv_reservation_through_date    = iv_reservation_through_date ).
    rs_result-preview-request_locations = it_request_locations.

    LOOP AT lt_contexts INTO DATA(ls_context).
      READ TABLE ls_first_preview-allocations
          INTO DATA(ls_first_allocation)
        WITH KEY allocation-allocation-request_id =
          ls_context-internal_request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
      APPEND ls_first_allocation-allocation TO lt_allocations.
      ls_first_allocation-allocation-allocation-request_id =
        ls_context-request_id.
      APPEND VALUE #(
        allocation    = ls_first_allocation-allocation
        required_date = ls_context-required_date
        priority      = ls_context-priority ) TO rs_result-preview-allocations.
      APPEND VALUE #(
        request_id    = ls_context-request_id
        wbs_element   = ls_context-wbs_element
        required_date = ls_context-required_date
        priority      = ls_context-priority )
        TO rs_result-preview-wbs_assignments.
      APPEND VALUE #(
        request_id  = ls_context-internal_request_id
        wbs_element = ls_context-wbs_element ) TO lt_assignments.

      LOOP AT ls_first_preview-storage_allocations
          INTO DATA(ls_first_split)
          WHERE split-storage_allocation-request_id =
            ls_context-internal_request_id.
        APPEND VALUE #(
          request_id       =
            ls_first_split-split-storage_allocation-request_id
          material         =
            ls_first_split-split-storage_allocation-material
          plant            =
            ls_first_split-split-storage_allocation-plant
          storage_location =
            ls_first_split-split-storage_allocation-storage_location
          quantity         =
            ls_first_split-split-storage_allocation-allocated_quantity
          base_unit        = ls_first_split-split-base_unit )
          TO lt_splits.
        ls_first_split-split-storage_allocation-request_id =
          ls_context-request_id.
        APPEND ls_first_split TO rs_result-preview-storage_allocations.
      ENDLOOP.
    ENDLOOP.

    IF iv_require_full_quantity = abap_true.
      LOOP AT rs_result-preview-allocations INTO DATA(ls_preview_allocation).
        IF ls_preview_allocation-allocation-allocation-shortfall_quantity > 0.
          ADD 1 TO rs_result-reservation-failed_count.
        ENDIF.
      ENDLOOP.
      IF rs_result-reservation-failed_count > 0.
        rs_result-reservation-is_test_run = iv_test_run.
        APPEND VALUE #(
          type    = 'E'
          message = 'Dated location preview has a shortfall; no reservation was created' )
          TO rs_result-reservation-messages.
        RETURN.
      ENDIF.
    ENDIF.

    DATA(ls_rechecked_location) =
      mo_project_stock_service->preview_by_location_date(
        it_demands                     = lt_internal_demands
        it_storage_location_priority   = it_storage_location_priority
        it_request_location_priorities = lt_int_loc_prios
        it_allowed_storage_locations   = it_allowed_storage_locations
        it_request_locations           = lt_int_request_locations
        iv_require_full_quantity       = iv_require_full_quantity
        iv_reservation_through_date    = iv_reservation_through_date ).
    LOOP AT ls_rechecked_location-allocations
        INTO DATA(ls_rechecked_allocation).
      APPEND ls_rechecked_allocation-allocation TO
        lt_rechecked_allocations.
    ENDLOOP.

    LOOP AT ls_rechecked_location-storage_allocations
        INTO DATA(ls_rechecked_location_split).
      DATA(ls_rechecked_split) = ls_rechecked_location_split-split.
      APPEND VALUE #(
        request_id       =
          ls_rechecked_split-storage_allocation-request_id
        material         =
          ls_rechecked_split-storage_allocation-material
        plant            =
          ls_rechecked_split-storage_allocation-plant
        storage_location =
          ls_rechecked_split-storage_allocation-storage_location
        quantity         =
          ls_rechecked_split-storage_allocation-allocated_quantity
        base_unit        = ls_rechecked_split-base_unit )
        TO lt_rechecked_splits.
    ENDLOOP.

    IF same_allocation_splits(
        it_expected = lt_splits
        it_actual   = lt_rechecked_splits ) <> abap_true
        OR same_unit_allocation_summaries(
          it_expected = lt_allocations
          it_actual   = lt_rechecked_allocations ) <> abap_true.
      rs_result-reservation-is_successful = abap_false.
      rs_result-reservation-is_test_run = iv_test_run.
      rs_result-reservation-failed_count = 1.
      APPEND VALUE #(
        type    = 'E'
        message = 'Dated location allocation changed after preview; no reservation was created' )
        TO rs_result-reservation-messages.
      RETURN.
    ENDIF.

    rs_result-reservation = reserve_allocation(
      it_allocations             = lt_allocations
      it_wbs_assignments         = lt_assignments
      it_splits                  = lt_splits
      it_request_required_dates  = lt_request_required_dates
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_quantity
      iv_require_batch           = abap_false
      iv_atomic                  = iv_atomic
      iv_stop_on_failure         = iv_stop_on_failure ).
  ENDMETHOD.
  METHOD reserve_wbs_by_location.
    DATA lt_splits TYPE ty_allocation_splits.
    DATA lt_rechecked_splits TYPE ty_allocation_splits.

    IF ( iv_test_run <> abap_true AND iv_test_run <> abap_false )
        OR ( iv_require_full_quantity <> abap_true
          AND iv_require_full_quantity <> abap_false )
        OR ( iv_atomic <> abap_true AND iv_atomic <> abap_false )
        OR ( iv_stop_on_failure <> abap_true
          AND iv_stop_on_failure <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_reservation.
    ENDIF.
    validate_wbs_date_inputs(
      it_demands            = it_demands
      iv_required_date      = iv_required_date
      it_wbs_required_dates = it_wbs_required_dates ).

    rs_result-preview = mo_project_stock_service->preview_by_location(
      it_demands                   = it_demands
      it_storage_location_priority = it_storage_location_priority
      it_allowed_storage_locations = it_allowed_storage_locations
      it_request_locations         = it_request_locations
      iv_require_full_quantity     = iv_require_full_quantity
      iv_reservation_through_date  = iv_reservation_through_date ).

    IF iv_require_full_quantity = abap_true.
      LOOP AT rs_result-preview-allocation-allocations INTO
        DATA(ls_preview_allocation).
        IF ls_preview_allocation-allocation-shortfall_quantity > 0.
          ADD 1 TO rs_result-reservation-failed_count.
        ENDIF.
      ENDLOOP.
      IF rs_result-reservation-failed_count > 0.
        rs_result-reservation-is_test_run = iv_test_run.
        APPEND VALUE #(
          type    = 'E'
          message = 'Location preview has a shortfall; no reservation was created' )
          TO rs_result-reservation-messages.
        RETURN.
      ENDIF.
    ENDIF.

    LOOP AT rs_result-preview-allocation-storage_allocations
      INTO DATA(ls_selected_location).
      APPEND VALUE #(
        request_id       =
          ls_selected_location-storage_allocation-request_id
        material         =
          ls_selected_location-storage_allocation-material
        plant            =
          ls_selected_location-storage_allocation-plant
        storage_location =
          ls_selected_location-storage_allocation-storage_location
        quantity         =
          ls_selected_location-storage_allocation-allocated_quantity
        base_unit        = ls_selected_location-base_unit ) TO lt_splits.
    ENDLOOP.

    DATA(ls_rechecked_location) =
      mo_project_stock_service->preview_by_location(
        it_demands                   = it_demands
        it_storage_location_priority = it_storage_location_priority
        it_allowed_storage_locations = it_allowed_storage_locations
        it_request_locations         = it_request_locations
        iv_require_full_quantity     = iv_require_full_quantity
        iv_reservation_through_date  = iv_reservation_through_date ).
    LOOP AT ls_rechecked_location-allocation-storage_allocations
      INTO DATA(ls_rechecked_storage).
      APPEND VALUE #(
        request_id       =
          ls_rechecked_storage-storage_allocation-request_id
        material         =
          ls_rechecked_storage-storage_allocation-material
        plant            =
          ls_rechecked_storage-storage_allocation-plant
        storage_location =
          ls_rechecked_storage-storage_allocation-storage_location
        quantity         =
          ls_rechecked_storage-storage_allocation-allocated_quantity
        base_unit        = ls_rechecked_storage-base_unit )
        TO lt_rechecked_splits.
    ENDLOOP.

    IF same_allocation_splits(
        it_expected = lt_splits
        it_actual   = lt_rechecked_splits ) <> abap_true
        OR same_unit_allocation_summaries(
          it_expected = rs_result-preview-allocation-allocations
          it_actual   = ls_rechecked_location-allocation-allocations )
          <> abap_true.
      rs_result-reservation-is_successful = abap_false.
      rs_result-reservation-is_test_run = iv_test_run.
      rs_result-reservation-failed_count = 1.
      APPEND VALUE #(
        type    = 'E'
        message = 'Location allocation changed after preview; no reservation was created' )
        TO rs_result-reservation-messages.
      RETURN.
    ENDIF.

    rs_result-reservation = reserve_allocation(
      it_allocations             =
        rs_result-preview-allocation-allocations
      it_wbs_assignments         = rs_result-preview-wbs_assignments
      it_splits                  = lt_splits
      iv_required_date           = iv_required_date
      it_wbs_required_dates      = it_wbs_required_dates
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_quantity
      iv_require_batch           = abap_false
      iv_atomic                  = iv_atomic
      iv_stop_on_failure         = iv_stop_on_failure ).
  ENDMETHOD.

  METHOD reserve_wbs_location_priority.
    TYPES:
      BEGIN OF ty_reservation_context,
        internal_request_id TYPE c LENGTH 30,
        request_id          TYPE c LENGTH 30,
        wbs_element         TYPE zif_project_stock_repository=>ty_wbs_element,
        priority            TYPE i,
      END OF ty_reservation_context,
      ty_reservation_contexts TYPE STANDARD TABLE OF
        ty_reservation_context WITH EMPTY KEY.
    DATA lt_contexts TYPE ty_reservation_contexts.
    DATA lt_priority_demands TYPE
      zcl_project_stock_service=>ty_priority_location_demands.
    DATA lt_validation_demands TYPE zcl_project_stock_service=>ty_demands.
    DATA lt_int_loc_prios TYPE
      zcl_stock_service=>ty_request_location_priorities.
    DATA lt_int_request_locations TYPE
      zcl_project_stock_service=>ty_request_locations.
    DATA lt_seen_location_priorities TYPE HASHED TABLE OF
      zcl_stock_service=>ty_request_location_priority
      WITH UNIQUE KEY request_id storage_location.
    DATA lt_allocations TYPE zcl_stock_service=>ty_unit_allocation_summaries.
    DATA lt_rechecked_allocations TYPE
      zcl_stock_service=>ty_unit_allocation_summaries.
    DATA lt_assignments TYPE zcl_project_stock_service=>ty_wbs_assignments.
    DATA lt_splits TYPE ty_allocation_splits.
    DATA lt_rechecked_splits TYPE ty_allocation_splits.
    DATA lv_internal_index TYPE i.
    DATA lv_internal_request_id TYPE c LENGTH 30.

    IF ( iv_test_run <> abap_true AND iv_test_run <> abap_false )
        OR ( iv_require_full_quantity <> abap_true
          AND iv_require_full_quantity <> abap_false )
        OR ( iv_atomic <> abap_true AND iv_atomic <> abap_false )
        OR ( iv_stop_on_failure <> abap_true
          AND iv_stop_on_failure <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_reservation.
    ENDIF.

    LOOP AT it_demands INTO DATA(ls_demand).
      IF ls_demand-request_id IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      ADD 1 TO lv_internal_index.
      CLEAR lv_internal_request_id.
      lv_internal_request_id = lv_internal_index.
      APPEND VALUE #(
        request_id              = lv_internal_request_id
        priority                = ls_demand-priority
        wbs_element             = ls_demand-wbs_element
        material                = ls_demand-material
        plant                   = ls_demand-plant
        storage_location        = ls_demand-storage_location
        allow_location_fallback = ls_demand-allow_location_fallback
        requested_quantity      = ls_demand-requested_quantity
        require_full_quantity   = ls_demand-require_full_quantity
        unit                    = ls_demand-unit )
        TO lt_priority_demands.
      APPEND VALUE #(
        request_id              = ls_demand-request_id
        wbs_element             = ls_demand-wbs_element
        material                = ls_demand-material
        plant                   = ls_demand-plant
        storage_location        = ls_demand-storage_location
        allow_location_fallback = ls_demand-allow_location_fallback
        requested_quantity      = ls_demand-requested_quantity
        require_full_quantity   = ls_demand-require_full_quantity
        unit                    = ls_demand-unit )
        TO lt_validation_demands.
      APPEND VALUE #(
        internal_request_id = lv_internal_request_id
        request_id          = ls_demand-request_id
        wbs_element         = ls_demand-wbs_element
        priority            = ls_demand-priority ) TO lt_contexts.
    ENDLOOP.

    validate_wbs_date_inputs(
      it_demands            = lt_validation_demands
      iv_required_date      = iv_required_date
      it_wbs_required_dates = it_wbs_required_dates ).

    LOOP AT it_request_location_priorities
        INTO DATA(ls_request_location_priority).
      IF ls_request_location_priority-request_id IS INITIAL
          OR ls_request_location_priority-storage_location IS INITIAL
          OR ls_request_location_priority-priority_rank <= 0
          OR NOT line_exists( lt_contexts[
            request_id = ls_request_location_priority-request_id ] ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_request_location_priority
        INTO TABLE lt_seen_location_priorities.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_contexts INTO DATA(ls_rank_context).
      LOOP AT it_request_location_priorities
          INTO ls_request_location_priority
          WHERE request_id = ls_rank_context-request_id.
        APPEND VALUE #(
          request_id       = ls_rank_context-internal_request_id
          storage_location =
            ls_request_location_priority-storage_location
          priority_rank    = ls_request_location_priority-priority_rank )
          TO lt_int_loc_prios.
      ENDLOOP.
    ENDLOOP.

    LOOP AT it_request_locations INTO DATA(ls_request_location).
      IF ls_request_location-request_id IS INITIAL
          OR ls_request_location-storage_location IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
      DATA(lv_scope_found) = abap_false.
      LOOP AT lt_contexts INTO DATA(ls_location_scope_context)
          WHERE request_id = ls_request_location-request_id.
        APPEND VALUE #(
          request_id       =
            ls_location_scope_context-internal_request_id
          storage_location =
            ls_request_location-storage_location )
          TO lt_int_request_locations.
        lv_scope_found = abap_true.
      ENDLOOP.
      IF lv_scope_found <> abap_true.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
    ENDLOOP.

    DATA(ls_first_preview) =
      mo_project_stock_service->preview_by_location_priority(
        it_demands                     = lt_priority_demands
        it_storage_location_priority   = it_storage_location_priority
        it_request_location_priorities = lt_int_loc_prios
        it_allowed_storage_locations   = it_allowed_storage_locations
        it_request_locations           = lt_int_request_locations
        iv_require_full_quantity       = iv_require_full_quantity
        iv_reservation_through_date    = iv_reservation_through_date ).
    rs_result-preview-request_locations = it_request_locations.

    LOOP AT lt_contexts INTO DATA(ls_context).
      READ TABLE ls_first_preview-allocations
          INTO DATA(ls_first_allocation)
        WITH KEY allocation-allocation-request_id =
          ls_context-internal_request_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
      APPEND ls_first_allocation-allocation TO lt_allocations.
      ls_first_allocation-allocation-allocation-request_id =
        ls_context-request_id.
      APPEND VALUE #(
        allocation = ls_first_allocation-allocation
        priority   = ls_context-priority ) TO rs_result-preview-allocations.
      APPEND VALUE #(
        request_id  = ls_context-request_id
        wbs_element = ls_context-wbs_element
        priority    = ls_context-priority )
        TO rs_result-preview-wbs_assignments.
      APPEND VALUE #(
        request_id  = ls_context-internal_request_id
        wbs_element = ls_context-wbs_element ) TO lt_assignments.

      LOOP AT ls_first_preview-storage_allocations
          INTO DATA(ls_first_split)
          WHERE split-storage_allocation-request_id =
            ls_context-internal_request_id.
        APPEND VALUE #(
          request_id       =
            ls_first_split-split-storage_allocation-request_id
          material         =
            ls_first_split-split-storage_allocation-material
          plant            =
            ls_first_split-split-storage_allocation-plant
          storage_location =
            ls_first_split-split-storage_allocation-storage_location
          quantity         =
            ls_first_split-split-storage_allocation-allocated_quantity
          base_unit        = ls_first_split-split-base_unit )
          TO lt_splits.
        ls_first_split-split-storage_allocation-request_id =
          ls_context-request_id.
        APPEND ls_first_split TO rs_result-preview-storage_allocations.
      ENDLOOP.
    ENDLOOP.

    IF iv_require_full_quantity = abap_true.
      LOOP AT rs_result-preview-allocations
          INTO DATA(ls_preview_allocation).
        IF ls_preview_allocation-allocation-allocation-shortfall_quantity > 0.
          ADD 1 TO rs_result-reservation-failed_count.
        ENDIF.
      ENDLOOP.
      IF rs_result-reservation-failed_count > 0.
        rs_result-reservation-is_test_run = iv_test_run.
        APPEND VALUE #(
          type    = 'E'
          message = 'Priority location preview has a shortfall; no reservation was created' )
          TO rs_result-reservation-messages.
        RETURN.
      ENDIF.
    ENDIF.

    DATA(ls_rechecked_preview) =
      mo_project_stock_service->preview_by_location_priority(
        it_demands                     = lt_priority_demands
        it_storage_location_priority   = it_storage_location_priority
        it_request_location_priorities = lt_int_loc_prios
        it_allowed_storage_locations   = it_allowed_storage_locations
        it_request_locations           = lt_int_request_locations
        iv_require_full_quantity       = iv_require_full_quantity
        iv_reservation_through_date    = iv_reservation_through_date ).
    LOOP AT ls_rechecked_preview-allocations
        INTO DATA(ls_rechecked_allocation).
      APPEND ls_rechecked_allocation-allocation TO
        lt_rechecked_allocations.
    ENDLOOP.

    LOOP AT ls_rechecked_preview-storage_allocations
        INTO DATA(ls_rechecked_split).
      APPEND VALUE #(
        request_id       =
          ls_rechecked_split-split-storage_allocation-request_id
        material         =
          ls_rechecked_split-split-storage_allocation-material
        plant            =
          ls_rechecked_split-split-storage_allocation-plant
        storage_location =
          ls_rechecked_split-split-storage_allocation-storage_location
        quantity         =
          ls_rechecked_split-split-storage_allocation-allocated_quantity
        base_unit        = ls_rechecked_split-split-base_unit )
        TO lt_rechecked_splits.
    ENDLOOP.

    IF same_allocation_splits(
        it_expected = lt_splits
        it_actual   = lt_rechecked_splits ) <> abap_true
        OR same_unit_allocation_summaries(
          it_expected = lt_allocations
          it_actual   = lt_rechecked_allocations ) <> abap_true.
      rs_result-reservation-is_successful = abap_false.
      rs_result-reservation-is_test_run = iv_test_run.
      rs_result-reservation-failed_count = 1.
      APPEND VALUE #(
        type    = 'E'
        message = 'Priority location allocation changed after preview; no reservation was created' )
        TO rs_result-reservation-messages.
      RETURN.
    ENDIF.

    rs_result-reservation = reserve_allocation(
      it_allocations             = lt_allocations
      it_wbs_assignments         = lt_assignments
      it_splits                  = lt_splits
      iv_required_date           = iv_required_date
      it_wbs_required_dates      = it_wbs_required_dates
      iv_test_run                = iv_test_run
      iv_require_full_allocation = iv_require_full_quantity
      iv_require_batch           = abap_false
      iv_atomic                  = iv_atomic
      iv_stop_on_failure         = iv_stop_on_failure ).
  ENDMETHOD.

  METHOD same_unit_allocation_summaries.
    DATA lt_expected TYPE zcl_stock_service=>ty_unit_allocation_summaries.
    DATA lt_actual TYPE zcl_stock_service=>ty_unit_allocation_summaries.

    rv_same = abap_false.
    IF lines( it_expected ) <> lines( it_actual ).
      RETURN.
    ENDIF.
    lt_expected = it_expected.
    lt_actual = it_actual.
    SORT lt_expected BY allocation-request_id.
    SORT lt_actual BY allocation-request_id.

    LOOP AT lt_expected INTO DATA(ls_expected).
      READ TABLE lt_actual INDEX sy-tabix INTO DATA(ls_actual).
      IF sy-subrc <> 0
          OR ls_expected-allocation-request_id
            <> ls_actual-allocation-request_id
          OR ls_expected-allocation-material
            <> ls_actual-allocation-material
          OR ls_expected-allocation-plant
            <> ls_actual-allocation-plant
          OR ls_expected-allocation-priority
            <> ls_actual-allocation-priority
          OR ls_expected-allocation-requested_quantity
            <> ls_actual-allocation-requested_quantity
          OR ls_expected-allocation-available_quantity
            <> ls_actual-allocation-available_quantity
          OR ls_expected-allocation-allocated_quantity
            <> ls_actual-allocation-allocated_quantity
          OR ls_expected-allocation-shortfall_quantity
            <> ls_actual-allocation-shortfall_quantity
          OR ls_expected-allocation-require_full_quantity
            <> ls_actual-allocation-require_full_quantity
          OR ls_expected-source_quantity <> ls_actual-source_quantity
          OR ls_expected-source_unit <> ls_actual-source_unit
          OR ls_expected-base_quantity <> ls_actual-base_quantity
          OR ls_expected-base_unit <> ls_actual-base_unit
          OR ls_expected-allocated_source_quantity
            <> ls_actual-allocated_source_quantity
          OR ls_expected-shortfall_source_quantity
            <> ls_actual-shortfall_source_quantity.
        RETURN.
      ENDIF.
    ENDLOOP.

    rv_same = abap_true.
  ENDMETHOD.

  METHOD same_allocation_splits.
    DATA lt_expected TYPE ty_allocation_splits.
    DATA lt_actual TYPE ty_allocation_splits.

    rv_same = abap_false.
    IF lines( it_expected ) <> lines( it_actual ).
      RETURN.
    ENDIF.

    lt_expected = it_expected.
    lt_actual = it_actual.
    SORT lt_expected BY request_id material plant storage_location
      batch expiration_date minimum_shelf_life_days require_known_expiry
      allow_undated_batches quantity base_unit.
    SORT lt_actual BY request_id material plant storage_location
      batch expiration_date minimum_shelf_life_days require_known_expiry
      allow_undated_batches quantity base_unit.

    LOOP AT lt_expected INTO DATA(ls_expected).
      READ TABLE lt_actual INDEX sy-tabix INTO DATA(ls_actual).
      IF sy-subrc <> 0
          OR ls_expected-request_id <> ls_actual-request_id
          OR ls_expected-material <> ls_actual-material
          OR ls_expected-plant <> ls_actual-plant
          OR ls_expected-storage_location <> ls_actual-storage_location
          OR ls_expected-batch <> ls_actual-batch
          OR ls_expected-expiration_date <> ls_actual-expiration_date
          OR ls_expected-minimum_shelf_life_days
            <> ls_actual-minimum_shelf_life_days
          OR ls_expected-require_known_expiry
            <> ls_actual-require_known_expiry
          OR ls_expected-allow_undated_batches
            <> ls_actual-allow_undated_batches
          OR ls_expected-quantity <> ls_actual-quantity
          OR ls_expected-base_unit <> ls_actual-base_unit.
        RETURN.
      ENDIF.
    ENDLOOP.

    rv_same = abap_true.
  ENDMETHOD.

  METHOD reserve_allocation.
    TYPES ty_seen_reservation TYPE
      zif_project_reservation_api=>ty_reservation_number.
    TYPES:
      BEGIN OF ty_wbs_key,
        wbs_element TYPE zif_project_stock_repository=>ty_wbs_element,
      END OF ty_wbs_key.
    DATA lt_assignments TYPE ty_assignments.
    DATA lt_summaries TYPE ty_allocation_summaries.
    DATA lt_allocated_totals TYPE ty_allocated_totals.
    DATA lt_allocated_items TYPE ty_allocated_items.
    DATA lt_ordered_items TYPE ty_ordered_allocated_items.
    DATA lt_groups TYPE ty_reservation_groups.
    DATA lt_assigned_wbs TYPE HASHED TABLE OF ty_wbs_key
      WITH UNIQUE KEY wbs_element.
    DATA lt_wbs_dates TYPE HASHED TABLE OF ty_wbs_required_date
      WITH UNIQUE KEY wbs_element.
    DATA lt_request_dates TYPE ty_request_required_dates.
    DATA lt_seen_reservation_numbers TYPE HASHED TABLE OF
      ty_seen_reservation WITH UNIQUE KEY table_line.
    DATA lv_has_failure TYPE abap_bool.
    DATA lv_has_error_message TYPE abap_bool.
    DATA lv_stop_processing TYPE abap_bool.
    DATA lv_effective_shelf_life TYPE i.
    DATA lv_effective_include_undated TYPE abap_bool.
    DATA lv_item_required_date TYPE d.
    FIELD-SYMBOLS <ls_reservation> TYPE ty_wbs_reservation.

    IF ( iv_test_run <> abap_true AND iv_test_run <> abap_false )
        OR ( iv_require_full_allocation <> abap_true
          AND iv_require_full_allocation <> abap_false )
        OR ( iv_require_batch <> abap_true
          AND iv_require_batch <> abap_false )
        OR ( iv_atomic <> abap_true AND iv_atomic <> abap_false )
        OR ( iv_stop_on_failure <> abap_true
          AND iv_stop_on_failure <> abap_false )
        OR iv_minimum_shelf_life_days < 0
        OR ( iv_include_undated_batches <> abap_true
          AND iv_include_undated_batches <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_reservation.
    ENDIF.

    rs_result-is_test_run = iv_test_run.
    rs_result-is_successful = abap_true.
    IF it_allocations IS INITIAL
        AND it_wbs_assignments IS INITIAL
        AND it_splits IS INITIAL
        AND it_wbs_required_dates IS INITIAL
        AND it_request_required_dates IS INITIAL.
      RETURN.
    ENDIF.
    IF lines( it_allocations ) <> lines( it_wbs_assignments ).
      RAISE EXCEPTION TYPE zcx_invalid_reservation.
    ENDIF.
    IF it_request_required_dates IS INITIAL.
      IF it_wbs_required_dates IS INITIAL.
        validate_required_date( iv_required_date = iv_required_date ).
      ELSEIF iv_required_date IS NOT INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
    ENDIF.

    LOOP AT it_wbs_assignments INTO DATA(ls_assignment).
      IF ls_assignment-request_id IS INITIAL
          OR ls_assignment-wbs_element IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
      INSERT VALUE #(
        request_id  = ls_assignment-request_id
        wbs_element = ls_assignment-wbs_element ) INTO TABLE lt_assignments.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
      INSERT VALUE #( wbs_element = ls_assignment-wbs_element )
        INTO TABLE lt_assigned_wbs.
    ENDLOOP.

    LOOP AT it_wbs_required_dates INTO DATA(ls_wbs_date).
      IF ls_wbs_date-wbs_element IS INITIAL
          OR NOT line_exists( lt_assigned_wbs[
            wbs_element = ls_wbs_date-wbs_element ] ).
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
      validate_required_date( iv_required_date = ls_wbs_date-required_date ).
      INSERT ls_wbs_date INTO TABLE lt_wbs_dates.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
    ENDLOOP.
    IF it_wbs_required_dates IS NOT INITIAL
        AND lines( lt_wbs_dates ) <> lines( lt_assigned_wbs ).
      RAISE EXCEPTION TYPE zcx_invalid_reservation.
    ENDIF.

    IF it_request_required_dates IS NOT INITIAL.
      IF iv_required_date IS NOT INITIAL
          OR it_wbs_required_dates IS NOT INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
      LOOP AT it_request_required_dates INTO DATA(ls_request_date).
        IF ls_request_date-request_id IS INITIAL
            OR NOT line_exists( lt_assignments[
              request_id = ls_request_date-request_id ] ).
          RAISE EXCEPTION TYPE zcx_invalid_reservation.
        ENDIF.
        validate_required_date(
          iv_required_date = ls_request_date-required_date ).
        INSERT ls_request_date INTO TABLE lt_request_dates.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_reservation.
        ENDIF.
      ENDLOOP.
      IF lines( lt_request_dates ) <> lines( lt_assignments ).
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
    ENDIF.

    LOOP AT it_allocations INTO DATA(ls_allocation).
      DATA(ls_summary) = ls_allocation-allocation.
      IF ls_summary-request_id IS INITIAL
          OR ls_summary-material IS INITIAL
          OR ls_summary-plant IS INITIAL
          OR ls_allocation-source_quantity <= 0
          OR ls_allocation-source_unit IS INITIAL
          OR ls_allocation-base_unit IS INITIAL
          OR ls_allocation-base_quantity <= 0
          OR ls_allocation-base_quantity <> ls_summary-requested_quantity
          OR ls_summary-allocated_quantity < 0
          OR ls_summary-shortfall_quantity < 0
          OR ls_summary-available_quantity < 0
          OR ls_summary-allocated_quantity > ls_allocation-base_quantity
          OR CONV decfloat34( ls_summary-allocated_quantity )
            + CONV decfloat34( ls_summary-shortfall_quantity )
            <> CONV decfloat34( ls_summary-requested_quantity )
          OR ls_summary-shortfall_quantity
            <> ls_allocation-base_quantity
              - ls_summary-allocated_quantity
          OR ls_summary-allocated_quantity > ls_summary-available_quantity
          OR ( ls_summary-require_full_quantity <> abap_true
            AND ls_summary-require_full_quantity <> abap_false )
          OR ( ls_summary-require_full_quantity = abap_true
            AND ls_summary-allocated_quantity > 0
            AND ls_summary-shortfall_quantity > 0 )
          OR ( ls_summary-require_known_expiry <> abap_true
            AND ls_summary-require_known_expiry <> abap_false )
          OR ( ls_summary-allow_undated_batches <> abap_true
            AND ls_summary-allow_undated_batches <> abap_false )
          OR ( ls_summary-require_known_expiry = abap_true
            AND ls_summary-allow_undated_batches = abap_true ).
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
      IF iv_require_full_allocation = abap_true
          AND ls_summary-allocated_quantity <> ls_allocation-base_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
      IF NOT line_exists( lt_assignments[
        request_id = ls_summary-request_id ] ).
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
      INSERT VALUE #(
        request_id = ls_summary-request_id
        allocation = ls_allocation ) INTO TABLE lt_summaries.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
    ENDLOOP.

    LOOP AT it_splits INTO DATA(ls_split).
      IF ls_split-request_id IS INITIAL
          OR ls_split-material IS INITIAL
          OR ls_split-plant IS INITIAL
          OR ls_split-storage_location IS INITIAL
          OR ls_split-quantity <= 0
          OR ls_split-base_unit IS INITIAL
          OR ls_split-minimum_shelf_life_days < 0
          OR ( iv_require_batch = abap_true
            AND ls_split-batch IS INITIAL )
          OR ( iv_require_batch = abap_false
            AND ls_split-batch IS NOT INITIAL ).
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.

      READ TABLE lt_summaries
        WITH TABLE KEY request_id = ls_split-request_id
        INTO DATA(ls_split_summary).
      IF sy-subrc <> 0
          OR NOT line_exists( lt_assignments[
            request_id = ls_split-request_id ] )
          OR ls_split_summary-allocation-allocation-material
            <> ls_split-material
          OR ls_split_summary-allocation-allocation-plant <> ls_split-plant
          OR ls_split_summary-allocation-base_unit <> ls_split-base_unit
          OR ls_split-require_known_expiry
            <> ls_split_summary-allocation-allocation-require_known_expiry
          OR ls_split-allow_undated_batches
            <> ls_split_summary-allocation-allocation-allow_undated_batches.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.

      DATA(ls_item_assignment) = lt_assignments[
        request_id = ls_split-request_id ].
      lv_item_required_date = iv_required_date.
      IF it_request_required_dates IS NOT INITIAL.
        READ TABLE lt_request_dates INTO DATA(ls_split_request_date)
          WITH TABLE KEY request_id = ls_split-request_id.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_reservation.
        ENDIF.
        lv_item_required_date = ls_split_request_date-required_date.
      ELSEIF it_wbs_required_dates IS NOT INITIAL.
        READ TABLE lt_wbs_dates INTO DATA(ls_split_wbs_date)
          WITH TABLE KEY wbs_element = ls_item_assignment-wbs_element.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_reservation.
        ENDIF.
        lv_item_required_date = ls_split_wbs_date-required_date.
      ENDIF.
      IF iv_require_batch = abap_true.
        lv_effective_shelf_life = iv_minimum_shelf_life_days.
        IF ls_split-minimum_shelf_life_days > lv_effective_shelf_life.
          lv_effective_shelf_life = ls_split-minimum_shelf_life_days.
        ENDIF.
        lv_effective_include_undated = iv_include_undated_batches.
        IF ls_split-allow_undated_batches = abap_true.
          lv_effective_include_undated = abap_true.
        ENDIF.
        IF ls_split-require_known_expiry = abap_true.
          lv_effective_include_undated = abap_false.
        ENDIF.
        IF ls_split-expiration_date IS INITIAL.
          IF lv_effective_shelf_life > 0
              OR lv_effective_include_undated <> abap_true.
            RAISE EXCEPTION TYPE zcx_invalid_reservation.
          ENDIF.
        ELSE.
          validate_required_date(
            iv_required_date = ls_split-expiration_date ).
          IF ls_split-expiration_date < lv_item_required_date
              OR ls_split-expiration_date - lv_item_required_date
                < lv_effective_shelf_life.
            RAISE EXCEPTION TYPE zcx_invalid_reservation.
          ENDIF.
        ENDIF.
      ENDIF.

      READ TABLE lt_allocated_totals ASSIGNING
        FIELD-SYMBOL(<ls_allocated_total>)
        WITH TABLE KEY request_id = ls_split-request_id.
      IF sy-subrc = 0.
        <ls_allocated_total>-quantity =
          <ls_allocated_total>-quantity + CONV decfloat34(
            ls_split-quantity ).
      ELSE.
        INSERT VALUE #(
          request_id = ls_split-request_id
          quantity   = CONV decfloat34( ls_split-quantity ) )
          INTO TABLE lt_allocated_totals.
      ENDIF.

      READ TABLE lt_allocated_items ASSIGNING
        FIELD-SYMBOL(<ls_allocated_item>)
        WITH TABLE KEY wbs_element = ls_item_assignment-wbs_element
                       required_date = lv_item_required_date
                       material = ls_split-material
                       plant = ls_split-plant
                       storage_location = ls_split-storage_location
                       batch = ls_split-batch.
      IF sy-subrc = 0.
        IF <ls_allocated_item>-unit <> ls_split-base_unit.
          RAISE EXCEPTION TYPE zcx_invalid_reservation.
        ENDIF.
        <ls_allocated_item>-quantity =
          <ls_allocated_item>-quantity + CONV decfloat34(
            ls_split-quantity ).
      ELSE.
        INSERT VALUE #(
          wbs_element      = ls_item_assignment-wbs_element
          required_date    = lv_item_required_date
          material         = ls_split-material
          plant            = ls_split-plant
          storage_location = ls_split-storage_location
          batch            = ls_split-batch
          quantity         = CONV decfloat34( ls_split-quantity )
          unit             = ls_split-base_unit ) INTO TABLE lt_allocated_items.
      ENDIF.
    ENDLOOP.

    LOOP AT it_allocations INTO ls_allocation.
      DATA(lv_split_quantity) = CONV decfloat34( 0 ).
      READ TABLE lt_allocated_totals
        WITH TABLE KEY request_id = ls_allocation-allocation-request_id
        INTO DATA(ls_allocated_total).
      IF sy-subrc = 0.
        lv_split_quantity = ls_allocated_total-quantity.
      ENDIF.
      IF lv_split_quantity <> CONV decfloat34(
          ls_allocation-allocation-allocated_quantity ).
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
    ENDLOOP.

    DATA(lv_max_reservation_quantity) = CONV decfloat34(
      CONV mard-labst( '9999999999.999' ) ).
    LOOP AT lt_allocated_items INTO DATA(ls_allocated_item).
      IF ls_allocated_item-quantity <= 0
          OR ls_allocated_item-quantity > lv_max_reservation_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
      DATA(lv_reservation_quantity) = CONV mard-labst(
        ls_allocated_item-quantity ).
      DATA(ls_conversion) = mo_uom_converter->convert_material_unit(
        iv_material    = ls_allocated_item-material
        iv_quantity    = lv_reservation_quantity
        iv_source_unit = ls_allocated_item-unit ).
      IF ls_conversion-is_successful <> abap_true
          OR ls_conversion-base_unit <> ls_allocated_item-unit
          OR ls_conversion-base_quantity <> lv_reservation_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
      APPEND VALUE #( BASE ls_allocated_item
        quantity = lv_reservation_quantity ) TO lt_ordered_items.
    ENDLOOP.
    SORT lt_ordered_items BY wbs_element required_date material plant
                             storage_location batch.

    LOOP AT lt_ordered_items INTO ls_allocated_item.
      READ TABLE lt_groups ASSIGNING FIELD-SYMBOL(<ls_group>)
        WITH KEY wbs_element = ls_allocated_item-wbs_element
                 required_date = ls_allocated_item-required_date.
      IF sy-subrc <> 0.
        APPEND VALUE #(
          wbs_element   = ls_allocated_item-wbs_element
          required_date = ls_allocated_item-required_date )
          TO lt_groups.
        READ TABLE lt_groups ASSIGNING <ls_group>
          WITH KEY wbs_element = ls_allocated_item-wbs_element
                   required_date = ls_allocated_item-required_date.
      ENDIF.
      APPEND VALUE #(
        material         = ls_allocated_item-material
        plant            = ls_allocated_item-plant
        storage_location = ls_allocated_item-storage_location
        batch            = ls_allocated_item-batch
        quantity         = CONV mard-labst( ls_allocated_item-quantity )
        unit             = ls_allocated_item-unit ) TO <ls_group>-items.
    ENDLOOP.

    IF it_wbs_required_dates IS NOT INITIAL.
      LOOP AT lt_groups INTO DATA(ls_date_group).
        IF NOT line_exists( lt_wbs_dates[
          wbs_element = ls_date_group-wbs_element ] ).
          RAISE EXCEPTION TYPE zcx_invalid_reservation.
        ENDIF.
      ENDLOOP.
    ENDIF.

    LOOP AT lt_groups INTO DATA(ls_group).
      DATA(lv_group_required_date) = ls_group-required_date.
      IF lv_stop_processing = abap_true.
        APPEND VALUE #(
          wbs_element   = ls_group-wbs_element
          required_date = lv_group_required_date
          is_test_run   = iv_test_run
          is_skipped    = abap_true ) TO rs_result-reservations.
        rs_result-skipped_count = rs_result-skipped_count + 1.
        CONTINUE.
      ENDIF.
      IF iv_atomic = abap_true AND iv_test_run = abap_false.
        APPEND INITIAL LINE TO rs_result-reservations
          ASSIGNING <ls_reservation>.
        <ls_reservation>-wbs_element = ls_group-wbs_element.
        <ls_reservation>-required_date = lv_group_required_date.
        <ls_reservation>-is_test_run = abap_false.
        DATA(ls_create_result) = mo_api->create_reservation(
          is_request  = VALUE #(
            wbs_element   = ls_group-wbs_element
            required_date = lv_group_required_date
            items         = ls_group-items )
          iv_test_run = abap_false ).
        <ls_reservation>-reservation_number =
          ls_create_result-reservation_number.
        <ls_reservation>-messages = ls_create_result-messages.
        <ls_reservation>-is_successful = ls_create_result-is_successful.
        CLEAR lv_has_error_message.
        LOOP AT <ls_reservation>-messages INTO DATA(ls_create_message).
          IF ls_create_message-type = 'A'
              OR ls_create_message-type = 'E'
              OR ls_create_message-type = 'X'.
            <ls_reservation>-is_successful = abap_false.
            lv_has_error_message = abap_true.
          ENDIF.
        ENDLOOP.

        IF <ls_reservation>-is_successful = abap_true.
          INSERT <ls_reservation>-reservation_number
            INTO TABLE lt_seen_reservation_numbers.
          IF <ls_reservation>-reservation_number IS INITIAL.
            <ls_reservation>-is_successful = abap_false.
            APPEND VALUE #(
              type    = 'E'
              message = 'Reservation API returned no reservation number' )
              TO <ls_reservation>-messages.
            lv_has_error_message = abap_true.
          ELSEIF sy-subrc <> 0.
            <ls_reservation>-is_successful = abap_false.
            APPEND VALUE #(
              type    = 'E'
              message = 'Reservation API returned a duplicate reservation number' )
              TO <ls_reservation>-messages.
            lv_has_error_message = abap_true.
          ENDIF.
        ENDIF.

        IF <ls_reservation>-is_successful <> abap_true.
          IF lv_has_error_message = abap_false.
            APPEND VALUE #(
              type    = 'E'
              message = 'Atomic project reservation creation failed' )
              TO <ls_reservation>-messages.
          ENDIF.
          lv_has_failure = abap_true.
          IF iv_stop_on_failure = abap_true.
            lv_stop_processing = abap_true.
            rs_result-stopped_on_failure = abap_true.
          ENDIF.
        ENDIF.
        CONTINUE.
      ENDIF.

      TRY.
          DATA(ls_reservation_result) = reserve_for_wbs(
            is_request  = VALUE #(
              wbs_element   = ls_group-wbs_element
              required_date = lv_group_required_date
              items         = ls_group-items )
            iv_test_run = iv_test_run ).
          APPEND VALUE #(
            wbs_element        = ls_group-wbs_element
            reservation_number = ls_reservation_result-reservation_number
            required_date      = lv_group_required_date
            messages           = ls_reservation_result-messages
            is_successful      = ls_reservation_result-is_successful
            is_committed       = ls_reservation_result-is_committed
            is_test_run        = iv_test_run )
            TO rs_result-reservations.
          IF ls_reservation_result-is_successful = abap_true.
            rs_result-successful_count = rs_result-successful_count + 1.
          ELSE.
            rs_result-failed_count = rs_result-failed_count + 1.
            IF iv_stop_on_failure = abap_true.
              lv_stop_processing = abap_true.
              rs_result-stopped_on_failure = abap_true.
            ENDIF.
          ENDIF.
        CATCH zcx_invalid_reservation.
          APPEND VALUE #(
            wbs_element   = ls_group-wbs_element
            required_date = lv_group_required_date
            messages      = VALUE #(
              ( type    = 'E'
                message = 'Project reservation request failed validation' ) )
            is_test_run   = iv_test_run ) TO rs_result-reservations.
          rs_result-failed_count = rs_result-failed_count + 1.
          IF iv_stop_on_failure = abap_true.
            lv_stop_processing = abap_true.
            rs_result-stopped_on_failure = abap_true.
          ENDIF.
      ENDTRY.
    ENDLOOP.

    LOOP AT rs_result-reservations INTO DATA(ls_allocation_reservation).
      APPEND LINES OF ls_allocation_reservation-messages
        TO rs_result-messages.
    ENDLOOP.

    IF iv_atomic = abap_true AND iv_test_run = abap_false.
      IF lv_has_failure = abap_true.
        mo_api->rollback( ).
        rs_result-is_successful = abap_false.
        rs_result-failed_count = lines( rs_result-reservations )
          - rs_result-skipped_count.
        rs_result-was_rolled_back = abap_true.
        LOOP AT rs_result-reservations ASSIGNING <ls_reservation>.
          CLEAR <ls_reservation>-reservation_number.
          <ls_reservation>-is_successful = abap_false.
          <ls_reservation>-is_committed = abap_false.
          IF <ls_reservation>-is_skipped = abap_true.
            CLEAR <ls_reservation>-was_rolled_back.
          ELSE.
            <ls_reservation>-was_rolled_back = abap_true.
          ENDIF.
        ENDLOOP.
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
        rs_result-is_successful = abap_false.
        rs_result-failed_count = lines( rs_result-reservations ).
        rs_result-was_rolled_back = abap_true.
        IF ls_commit_result-message-message IS NOT INITIAL.
          APPEND ls_commit_result-message TO rs_result-messages.
        ELSE.
          APPEND VALUE #(
            type    = 'E'
            message = 'Atomic project reservation commit failed' )
            TO rs_result-messages.
        ENDIF.
        LOOP AT rs_result-reservations ASSIGNING <ls_reservation>.
          CLEAR <ls_reservation>-reservation_number.
          <ls_reservation>-is_successful = abap_false.
          <ls_reservation>-is_committed = abap_false.
          <ls_reservation>-was_rolled_back = abap_true.
        ENDLOOP.
        RETURN.
      ENDIF.

      rs_result-is_successful = abap_true.
      rs_result-is_committed = abap_true.
      rs_result-successful_count = lines( rs_result-reservations ).
      LOOP AT rs_result-reservations ASSIGNING <ls_reservation>.
        <ls_reservation>-is_successful = abap_true.
        <ls_reservation>-is_committed = abap_true.
      ENDLOOP.
      RETURN.
    ENDIF.

    rs_result-is_successful = xsdbool( rs_result-failed_count = 0 ).
    LOOP AT rs_result-reservations ASSIGNING <ls_reservation>.
      IF <ls_reservation>-is_committed = abap_true.
        rs_result-is_committed = abap_true.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validate_required_date.
    IF zcl_date_validation=>is_valid_gregorian_date(
      iv_date = iv_required_date ) <> abap_true.
      RAISE EXCEPTION TYPE zcx_invalid_reservation.
    ENDIF.
  ENDMETHOD.

  METHOD validate_wbs_date_inputs.
    DATA lt_seen_wbs_dates TYPE HASHED TABLE OF
      zif_project_stock_repository=>ty_wbs_element
      WITH UNIQUE KEY table_line.
    DATA lt_demand_wbs TYPE HASHED TABLE OF
      zif_project_stock_repository=>ty_wbs_element
      WITH UNIQUE KEY table_line.

    IF it_wbs_required_dates IS INITIAL.
      IF it_demands IS NOT INITIAL OR iv_required_date IS NOT INITIAL.
        validate_required_date( iv_required_date = iv_required_date ).
      ENDIF.
    ELSEIF iv_required_date IS NOT INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_reservation.
    ENDIF.

    LOOP AT it_wbs_required_dates INTO DATA(ls_wbs_required_date).
      IF ls_wbs_required_date-wbs_element IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
      validate_required_date(
        iv_required_date = ls_wbs_required_date-required_date ).
      INSERT ls_wbs_required_date-wbs_element INTO TABLE lt_seen_wbs_dates.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_reservation.
      ENDIF.
    ENDLOOP.

    LOOP AT it_demands INTO DATA(ls_demand).
      INSERT ls_demand-wbs_element INTO TABLE lt_demand_wbs.
    ENDLOOP.
    IF it_wbs_required_dates IS NOT INITIAL.
      LOOP AT lt_demand_wbs INTO DATA(lv_demand_wbs).
        IF NOT line_exists( lt_seen_wbs_dates[
          table_line = lv_demand_wbs ] ).
          RAISE EXCEPTION TYPE zcx_invalid_reservation.
        ENDIF.
      ENDLOOP.
      LOOP AT it_wbs_required_dates INTO ls_wbs_required_date.
        IF NOT line_exists( lt_demand_wbs[
          table_line = ls_wbs_required_date-wbs_element ] ).
          RAISE EXCEPTION TYPE zcx_invalid_reservation.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
