CLASS zcl_reservation_issue_service DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_issue_request,
        reservation_number TYPE bapi2093_res_key-reserv_no,
        reservation_item   TYPE bapi2093_res_item_detail-res_item,
        base_quantity      TYPE mard-labst,
        storage_location   TYPE mard-lgort,
        batch              TYPE bapi2093_res_item_detail-batch,
      END OF ty_issue_request.
    TYPES ty_issue_requests TYPE STANDARD TABLE OF
      ty_issue_request WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_reservation_item_key,
        reservation_number TYPE bapi2093_res_key-reserv_no,
        reservation_item   TYPE bapi2093_res_item_detail-res_item,
      END OF ty_reservation_item_key.
    TYPES ty_reservation_item_keys TYPE STANDARD TABLE OF
      ty_reservation_item_key WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_remaining_issue_request,
        reservation_number TYPE bapi2093_res_key-reserv_no,
        reservation_item   TYPE bapi2093_res_item_detail-res_item,
        base_quantity      TYPE mard-labst,
        base_unit          TYPE mara-meins,
        base_unit_iso      TYPE bapi2093_res_item_detail-base_uom_iso,
        storage_location   TYPE mard-lgort,
        batch              TYPE bapi2093_res_item_detail-batch,
      END OF ty_remaining_issue_request.
    TYPES ty_remaining_issue_requests TYPE STANDARD TABLE OF
      ty_remaining_issue_request WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_issue_request_in_unit,
        reservation_number TYPE bapi2093_res_key-reserv_no,
        reservation_item   TYPE bapi2093_res_item_detail-res_item,
        quantity           TYPE mard-labst,
        unit               TYPE mara-meins,
        storage_location   TYPE mard-lgort,
        batch              TYPE bapi2093_res_item_detail-batch,
      END OF ty_issue_request_in_unit.
    TYPES ty_issue_requests_in_unit TYPE STANDARD TABLE OF
      ty_issue_request_in_unit WITH EMPTY KEY.
    TYPES ty_cc_reservation_numbers TYPE STANDARD TABLE OF resb-rsnum
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_bulk_issue_item,
        reservation_number TYPE bapi2093_res_key-reserv_no,
        movement_result    TYPE zif_goods_movement_api=>ty_result,
        is_attempted       TYPE abap_bool,
        is_successful      TYPE abap_bool,
        is_committed       TYPE abap_bool,
        is_skipped         TYPE abap_bool,
      END OF ty_bulk_issue_item.
    TYPES ty_bulk_issue_items TYPE STANDARD TABLE OF ty_bulk_issue_item
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_bulk_issue_result,
        items              TYPE ty_bulk_issue_items,
        successful_count   TYPE i,
        failed_count       TYPE i,
        skipped_count      TYPE i,
        stopped_on_failure TYPE abap_bool,
        is_successful      TYPE abap_bool,
        is_test_run        TYPE abap_bool,
        is_committed       TYPE abap_bool,
      END OF ty_bulk_issue_result.
    TYPES:
      BEGIN OF ty_atomic_issue_result,
        items            TYPE ty_bulk_issue_items,
        commit_result    TYPE zif_goods_movement_api=>ty_commit_result,
        successful_count TYPE i,
        failed_count     TYPE i,
        is_successful    TYPE abap_bool,
        is_committed     TYPE abap_bool,
        is_test_run      TYPE abap_bool,
        was_rolled_back  TYPE abap_bool,
      END OF ty_atomic_issue_result.

    METHODS constructor
      IMPORTING
        io_reservation_reader    TYPE REF TO zif_so_reservation_reader OPTIONAL
        io_goods_movement_api    TYPE REF TO zif_goods_movement_api OPTIONAL
        io_uom_repository        TYPE REF TO zif_material_uom_repository
          OPTIONAL
        io_cc_reservation_reader TYPE REF TO zif_cc_reservation_read_repo
          OPTIONAL.

    METHODS post_goods_issue
      IMPORTING
        is_header        TYPE zif_goods_movement_api=>ty_header
        it_requests      TYPE ty_issue_requests
        iv_test_run      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS post_sales_order_issue
      IMPORTING
        iv_sales_document TYPE vbap-vbeln
        iv_item_number    TYPE vbap-posnr
        is_header         TYPE zif_goods_movement_api=>ty_header
        it_requests       TYPE ty_issue_requests
        iv_test_run       TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)  TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS post_sales_order_issue_uom
      IMPORTING
        iv_sales_document TYPE vbap-vbeln
        iv_item_number    TYPE vbap-posnr
        is_header         TYPE zif_goods_movement_api=>ty_header
        it_requests       TYPE ty_issue_requests_in_unit
        iv_test_run       TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)  TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS post_so_issue_bulk
      IMPORTING
        iv_sales_document  TYPE vbap-vbeln
        iv_item_number     TYPE vbap-posnr
        is_header          TYPE zif_goods_movement_api=>ty_header
        it_requests        TYPE ty_issue_requests
        iv_test_run        TYPE abap_bool DEFAULT abap_false
        iv_stop_on_failure TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)   TYPE ty_bulk_issue_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS post_so_issue_remaining
      IMPORTING
        iv_sales_document      TYPE vbap-vbeln
        iv_item_number         TYPE vbap-posnr
        is_header              TYPE zif_goods_movement_api=>ty_header
        it_reservation_numbers TYPE zcl_so_res_read_service=>ty_reservation_numbers
        iv_test_run            TYPE abap_bool DEFAULT abap_false
        iv_stop_on_failure     TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)       TYPE ty_bulk_issue_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS preview_so_issue_remaining
      IMPORTING
        iv_sales_document      TYPE vbap-vbeln
        iv_item_number         TYPE vbap-posnr
        it_reservation_numbers TYPE zcl_so_res_read_service=>ty_reservation_numbers
      RETURNING
        VALUE(rt_requests)     TYPE ty_remaining_issue_requests
      RAISING
        zcx_invalid_goods_movement.

    METHODS post_so_issue_remaining_atomic
      IMPORTING
        iv_sales_document      TYPE vbap-vbeln
        iv_item_number         TYPE vbap-posnr
        is_header              TYPE zif_goods_movement_api=>ty_header
        it_reservation_numbers TYPE zcl_so_res_read_service=>ty_reservation_numbers
        iv_test_run            TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)       TYPE ty_atomic_issue_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS preview_so_issue_rem_items
      IMPORTING
        iv_sales_document  TYPE vbap-vbeln
        iv_item_number     TYPE vbap-posnr
        it_item_keys       TYPE ty_reservation_item_keys
      RETURNING
        VALUE(rt_requests) TYPE ty_remaining_issue_requests
      RAISING
        zcx_invalid_goods_movement.

    METHODS post_so_issue_rem_items_bulk
      IMPORTING
        iv_sales_document  TYPE vbap-vbeln
        iv_item_number     TYPE vbap-posnr
        is_header          TYPE zif_goods_movement_api=>ty_header
        it_item_keys       TYPE ty_reservation_item_keys
        iv_test_run        TYPE abap_bool DEFAULT abap_false
        iv_stop_on_failure TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)   TYPE ty_bulk_issue_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS post_so_issue_rem_items_atomic
      IMPORTING
        iv_sales_document TYPE vbap-vbeln
        iv_item_number    TYPE vbap-posnr
        is_header         TYPE zif_goods_movement_api=>ty_header
        it_item_keys      TYPE ty_reservation_item_keys
        iv_test_run       TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)  TYPE ty_atomic_issue_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS preview_so_rev_remaining
      IMPORTING
        iv_sales_document      TYPE vbap-vbeln
        iv_item_number         TYPE vbap-posnr
        it_reservation_numbers TYPE zcl_so_res_read_service=>ty_reservation_numbers
      RETURNING
        VALUE(rt_requests)     TYPE ty_remaining_issue_requests
      RAISING
        zcx_invalid_goods_movement.

    METHODS post_so_rev_remaining_bulk
      IMPORTING
        iv_sales_document      TYPE vbap-vbeln
        iv_item_number         TYPE vbap-posnr
        is_header              TYPE zif_goods_movement_api=>ty_header
        it_reservation_numbers TYPE zcl_so_res_read_service=>ty_reservation_numbers
        iv_test_run            TYPE abap_bool DEFAULT abap_false
        iv_stop_on_failure     TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)       TYPE ty_bulk_issue_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS post_so_rev_remaining_atomic
      IMPORTING
        iv_sales_document      TYPE vbap-vbeln
        iv_item_number         TYPE vbap-posnr
        is_header              TYPE zif_goods_movement_api=>ty_header
        it_reservation_numbers TYPE zcl_so_res_read_service=>ty_reservation_numbers
        iv_test_run            TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)       TYPE ty_atomic_issue_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS preview_so_rev_remaining_items
      IMPORTING
        iv_sales_document  TYPE vbap-vbeln
        iv_item_number     TYPE vbap-posnr
        it_item_keys       TYPE ty_reservation_item_keys
      RETURNING
        VALUE(rt_requests) TYPE ty_remaining_issue_requests
      RAISING
        zcx_invalid_goods_movement.

    METHODS post_so_rev_rem_items_bulk
      IMPORTING
        iv_sales_document  TYPE vbap-vbeln
        iv_item_number     TYPE vbap-posnr
        is_header          TYPE zif_goods_movement_api=>ty_header
        it_item_keys       TYPE ty_reservation_item_keys
        iv_test_run        TYPE abap_bool DEFAULT abap_false
        iv_stop_on_failure TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)   TYPE ty_bulk_issue_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS post_so_rev_rem_items_atomic
      IMPORTING
        iv_sales_document TYPE vbap-vbeln
        iv_item_number    TYPE vbap-posnr
        is_header         TYPE zif_goods_movement_api=>ty_header
        it_item_keys      TYPE ty_reservation_item_keys
        iv_test_run       TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)  TYPE ty_atomic_issue_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS post_so_issue_bulk_uom
      IMPORTING
        iv_sales_document  TYPE vbap-vbeln
        iv_item_number     TYPE vbap-posnr
        is_header          TYPE zif_goods_movement_api=>ty_header
        it_requests        TYPE ty_issue_requests_in_unit
        iv_test_run        TYPE abap_bool DEFAULT abap_false
        iv_stop_on_failure TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)   TYPE ty_bulk_issue_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS post_so_reversal_bulk
      IMPORTING
        iv_sales_document  TYPE vbap-vbeln
        iv_item_number     TYPE vbap-posnr
        is_header          TYPE zif_goods_movement_api=>ty_header
        it_requests        TYPE ty_issue_requests
        iv_test_run        TYPE abap_bool DEFAULT abap_false
        iv_stop_on_failure TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)   TYPE ty_bulk_issue_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS post_so_reversal_bulk_uom
      IMPORTING
        iv_sales_document  TYPE vbap-vbeln
        iv_item_number     TYPE vbap-posnr
        is_header          TYPE zif_goods_movement_api=>ty_header
        it_requests        TYPE ty_issue_requests_in_unit
        iv_test_run        TYPE abap_bool DEFAULT abap_false
        iv_stop_on_failure TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)   TYPE ty_bulk_issue_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS post_sales_order_reversal
      IMPORTING
        iv_sales_document TYPE vbap-vbeln
        iv_item_number    TYPE vbap-posnr
        is_header         TYPE zif_goods_movement_api=>ty_header
        it_requests       TYPE ty_issue_requests
        iv_test_run       TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)  TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS post_sales_order_reversal_uom
      IMPORTING
        iv_sales_document TYPE vbap-vbeln
        iv_item_number    TYPE vbap-posnr
        is_header         TYPE zif_goods_movement_api=>ty_header
        it_requests       TYPE ty_issue_requests_in_unit
        iv_test_run       TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)  TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS post_goods_issue_reversal
      IMPORTING
        is_header        TYPE zif_goods_movement_api=>ty_header
        it_requests      TYPE ty_issue_requests
        iv_test_run      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS post_goods_issue_bulk
      IMPORTING
        is_header          TYPE zif_goods_movement_api=>ty_header
        it_requests        TYPE ty_issue_requests
        iv_test_run        TYPE abap_bool DEFAULT abap_false
        iv_stop_on_failure TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)   TYPE ty_bulk_issue_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS post_goods_issue_reversal_bulk
      IMPORTING
        is_header          TYPE zif_goods_movement_api=>ty_header
        it_requests        TYPE ty_issue_requests
        iv_test_run        TYPE abap_bool DEFAULT abap_false
        iv_stop_on_failure TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)   TYPE ty_bulk_issue_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS post_goods_issue_in_unit
      IMPORTING
        is_header        TYPE zif_goods_movement_api=>ty_header
        it_requests      TYPE ty_issue_requests_in_unit
        iv_test_run      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS post_goods_issue_rev_in_unit
      IMPORTING
        is_header        TYPE zif_goods_movement_api=>ty_header
        it_requests      TYPE ty_issue_requests_in_unit
        iv_test_run      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS post_goods_issue_bulk_unit
      IMPORTING
        is_header          TYPE zif_goods_movement_api=>ty_header
        it_requests        TYPE ty_issue_requests_in_unit
        iv_test_run        TYPE abap_bool DEFAULT abap_false
        iv_stop_on_failure TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)   TYPE ty_bulk_issue_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS post_goods_issue_rev_bulk_unit
      IMPORTING
        is_header          TYPE zif_goods_movement_api=>ty_header
        it_requests        TYPE ty_issue_requests_in_unit
        iv_test_run        TYPE abap_bool DEFAULT abap_false
        iv_stop_on_failure TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)   TYPE ty_bulk_issue_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS post_goods_issue_atomic_unit
      IMPORTING
        is_header        TYPE zif_goods_movement_api=>ty_header
        it_requests      TYPE ty_issue_requests_in_unit
        iv_test_run      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE ty_atomic_issue_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS post_goods_issue_rev_atomic
      IMPORTING
        is_header        TYPE zif_goods_movement_api=>ty_header
        it_requests      TYPE ty_issue_requests_in_unit
        iv_test_run      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE ty_atomic_issue_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS post_cc_goods_issue
      IMPORTING
        iv_cost_center   TYPE rkpf-kostl
        is_header        TYPE zif_goods_movement_api=>ty_header
        it_requests      TYPE ty_issue_requests
        iv_test_run      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS post_cc_goods_issue_bulk
      IMPORTING
        iv_cost_center     TYPE rkpf-kostl
        is_header          TYPE zif_goods_movement_api=>ty_header
        it_requests        TYPE ty_issue_requests
        iv_test_run        TYPE abap_bool DEFAULT abap_false
        iv_stop_on_failure TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)   TYPE ty_bulk_issue_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS preview_cc_issue_remaining
      IMPORTING
        iv_cost_center         TYPE rkpf-kostl
        it_reservation_numbers TYPE ty_cc_reservation_numbers OPTIONAL
      RETURNING
        VALUE(rt_reservations) TYPE zif_cc_reservation_read_repo=>ty_reservations
      RAISING
        zcx_invalid_goods_movement.

    METHODS preview_cc_remaining_items
      IMPORTING
        iv_cost_center         TYPE rkpf-kostl
        it_item_keys           TYPE zif_cc_reservation_read_repo=>ty_item_keys
      RETURNING
        VALUE(rt_reservations) TYPE zif_cc_reservation_read_repo=>ty_reservations
      RAISING
        zcx_invalid_goods_movement.

    METHODS post_cc_issue_remaining
      IMPORTING
        iv_cost_center         TYPE rkpf-kostl
        is_header              TYPE zif_goods_movement_api=>ty_header
        it_reservation_numbers TYPE ty_cc_reservation_numbers
        iv_test_run            TYPE abap_bool DEFAULT abap_false
        iv_stop_on_failure     TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)       TYPE ty_bulk_issue_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS post_cc_issue_remaining_atomic
      IMPORTING
        iv_cost_center         TYPE rkpf-kostl
        is_header              TYPE zif_goods_movement_api=>ty_header
        it_reservation_numbers TYPE ty_cc_reservation_numbers
        iv_test_run            TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)       TYPE ty_atomic_issue_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS post_cc_remaining_items_atomic
      IMPORTING
        iv_cost_center   TYPE rkpf-kostl
        is_header        TYPE zif_goods_movement_api=>ty_header
        it_item_keys     TYPE zif_cc_reservation_read_repo=>ty_item_keys
        iv_test_run      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE ty_atomic_issue_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS post_cc_remaining_items
      IMPORTING
        iv_cost_center     TYPE rkpf-kostl
        is_header          TYPE zif_goods_movement_api=>ty_header
        it_item_keys       TYPE zif_cc_reservation_read_repo=>ty_item_keys
        iv_test_run        TYPE abap_bool DEFAULT abap_false
        iv_stop_on_failure TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)   TYPE ty_bulk_issue_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS post_cc_goods_issue_in_unit
      IMPORTING
        iv_cost_center   TYPE rkpf-kostl
        is_header        TYPE zif_goods_movement_api=>ty_header
        it_requests      TYPE ty_issue_requests_in_unit
        iv_test_run      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS post_cc_goods_issue_bulk_unit
      IMPORTING
        iv_cost_center     TYPE rkpf-kostl
        is_header          TYPE zif_goods_movement_api=>ty_header
        it_requests        TYPE ty_issue_requests_in_unit
        iv_test_run        TYPE abap_bool DEFAULT abap_false
        iv_stop_on_failure TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)   TYPE ty_bulk_issue_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS post_cc_issue_rev
      IMPORTING
        iv_cost_center   TYPE rkpf-kostl
        is_header        TYPE zif_goods_movement_api=>ty_header
        it_requests      TYPE ty_issue_requests
        iv_test_run      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS post_cc_issue_rev_bulk
      IMPORTING
        iv_cost_center     TYPE rkpf-kostl
        is_header          TYPE zif_goods_movement_api=>ty_header
        it_requests        TYPE ty_issue_requests
        iv_test_run        TYPE abap_bool DEFAULT abap_false
        iv_stop_on_failure TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)   TYPE ty_bulk_issue_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS post_cc_issue_rev_unit
      IMPORTING
        iv_cost_center   TYPE rkpf-kostl
        is_header        TYPE zif_goods_movement_api=>ty_header
        it_requests      TYPE ty_issue_requests_in_unit
        iv_test_run      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS post_cc_issue_rev_bulk_unit
      IMPORTING
        iv_cost_center     TYPE rkpf-kostl
        is_header          TYPE zif_goods_movement_api=>ty_header
        it_requests        TYPE ty_issue_requests_in_unit
        iv_test_run        TYPE abap_bool DEFAULT abap_false
        iv_stop_on_failure TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)   TYPE ty_bulk_issue_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS post_cc_issue_rev_atomic
      IMPORTING
        iv_cost_center   TYPE rkpf-kostl
        is_header        TYPE zif_goods_movement_api=>ty_header
        it_requests      TYPE ty_issue_requests_in_unit
        iv_test_run      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE ty_atomic_issue_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS preview_cc_rev_remaining
      IMPORTING
        iv_cost_center     TYPE rkpf-kostl
        it_item_keys       TYPE zif_cc_reservation_read_repo=>ty_item_keys
      RETURNING
        VALUE(rt_requests) TYPE ty_remaining_issue_requests
      RAISING
        zcx_invalid_goods_movement.

    METHODS post_cc_rev_remaining_atomic
      IMPORTING
        iv_cost_center   TYPE rkpf-kostl
        is_header        TYPE zif_goods_movement_api=>ty_header
        it_item_keys     TYPE zif_cc_reservation_read_repo=>ty_item_keys
        iv_test_run      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE ty_atomic_issue_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS post_cc_rev_remaining_bulk
      IMPORTING
        iv_cost_center     TYPE rkpf-kostl
        is_header          TYPE zif_goods_movement_api=>ty_header
        it_item_keys       TYPE zif_cc_reservation_read_repo=>ty_item_keys
        iv_test_run        TYPE abap_bool DEFAULT abap_false
        iv_stop_on_failure TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)   TYPE ty_bulk_issue_result
      RAISING
        zcx_invalid_goods_movement.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_movement_request,
        reservation_number TYPE bapi2093_res_key-reserv_no,
        reservation_item   TYPE bapi2093_res_item_detail-res_item,
        quantity           TYPE mard-labst,
        unit               TYPE mara-meins,
        is_unit_quantity   TYPE abap_bool,
        storage_location   TYPE mard-lgort,
        batch              TYPE bapi2093_res_item_detail-batch,
      END OF ty_movement_request.
    TYPES ty_movement_requests TYPE STANDARD TABLE OF
      ty_movement_request WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_item_key,
        reservation_number TYPE bapi2093_res_key-reserv_no,
        reservation_item   TYPE bapi2093_res_item_detail-res_item,
      END OF ty_item_key.
    METHODS post_reservation_movement
      IMPORTING
        is_header         TYPE zif_goods_movement_api=>ty_header
        it_requests       TYPE ty_movement_requests
        iv_test_run       TYPE abap_bool
        iv_is_reversal    TYPE abap_bool
        iv_defer_commit   TYPE abap_bool DEFAULT abap_false
        iv_sales_document TYPE vbap-vbeln OPTIONAL
        iv_sales_item     TYPE vbap-posnr OPTIONAL
      RETURNING
        VALUE(rs_result)  TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS post_reservation_movement_bulk
      IMPORTING
        is_header          TYPE zif_goods_movement_api=>ty_header
        it_requests        TYPE ty_movement_requests
        iv_test_run        TYPE abap_bool
        iv_is_reversal     TYPE abap_bool
        iv_stop_on_failure TYPE abap_bool DEFAULT abap_false
        iv_sales_document  TYPE vbap-vbeln OPTIONAL
        iv_sales_item      TYPE vbap-posnr OPTIONAL
      RETURNING
        VALUE(rs_result)   TYPE ty_bulk_issue_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS post_reservation_atomic
      IMPORTING
        is_header         TYPE zif_goods_movement_api=>ty_header
        it_requests       TYPE ty_movement_requests
        iv_test_run       TYPE abap_bool
        iv_is_reversal    TYPE abap_bool
        iv_sales_document TYPE vbap-vbeln OPTIONAL
        iv_sales_item     TYPE vbap-posnr OPTIONAL
        iv_cost_center    TYPE rkpf-kostl OPTIONAL
      RETURNING
        VALUE(rs_result)  TYPE ty_atomic_issue_result
      RAISING
        zcx_invalid_goods_movement.

    METHODS normalize_base_requests
      IMPORTING
        it_requests        TYPE ty_issue_requests
      RETURNING
        VALUE(rt_requests) TYPE ty_movement_requests.

    METHODS normalize_unit_requests
      IMPORTING
        it_requests        TYPE ty_issue_requests_in_unit
      RETURNING
        VALUE(rt_requests) TYPE ty_movement_requests.

    METHODS validate_cc_item_scope
      IMPORTING
        iv_cost_center TYPE rkpf-kostl
        it_requests    TYPE ty_movement_requests
      RAISING
        zcx_invalid_goods_movement.

    METHODS validate_cc_reversal_scope
      IMPORTING
        iv_cost_center TYPE rkpf-kostl
        it_requests    TYPE ty_movement_requests
      RAISING
        zcx_invalid_goods_movement.

    DATA mo_reservation_read_service TYPE REF TO zcl_so_res_read_service.
    DATA mo_cost_center_service TYPE REF TO zcl_cc_reservation_service.
    DATA mo_cc_reservation_reader TYPE REF TO zif_cc_reservation_read_repo.
    DATA mo_goods_movement_api TYPE REF TO zif_goods_movement_api.
    DATA mo_goods_movement_service TYPE REF TO zcl_goods_movement_service.
    DATA mo_uom_converter TYPE REF TO zif_material_uom_converter.
ENDCLASS.

CLASS zcl_reservation_issue_service IMPLEMENTATION.

  METHOD constructor.
    DATA lo_uom_repository TYPE REF TO zif_material_uom_repository.
    DATA lo_cc_reservation_reader TYPE REF TO zif_cc_reservation_read_repo.

    mo_reservation_read_service = NEW zcl_so_res_read_service(
      io_reader = io_reservation_reader ).
    IF io_cc_reservation_reader IS BOUND.
      lo_cc_reservation_reader = io_cc_reservation_reader.
    ELSE.
      lo_cc_reservation_reader = NEW zcl_cc_reservation_read_repo( ).
    ENDIF.
    mo_cc_reservation_reader = lo_cc_reservation_reader.
    mo_cost_center_service = NEW zcl_cc_reservation_service(
      io_stock_repository   = NEW zcl_mard_stock_repository( )
      io_reservation_reader = lo_cc_reservation_reader ).

    IF io_uom_repository IS BOUND.
      lo_uom_repository = io_uom_repository.
    ELSE.
      lo_uom_repository = NEW zcl_material_uom_repository( ).
    ENDIF.
    mo_uom_converter = NEW zcl_material_uom_converter(
      io_repository = lo_uom_repository ).

    mo_goods_movement_api = io_goods_movement_api.
    IF mo_goods_movement_api IS NOT BOUND.
      mo_goods_movement_api = NEW zcl_bapi_goods_movement_api( ).
    ENDIF.
    mo_goods_movement_service = NEW zcl_goods_movement_service(
      io_api = mo_goods_movement_api ).
  ENDMETHOD.

  METHOD post_goods_issue.
    DATA(lt_requests) = normalize_base_requests( it_requests ).
    rs_result = post_reservation_movement(
      is_header      = is_header
      it_requests    = lt_requests
      iv_test_run    = iv_test_run
      iv_is_reversal = abap_false ).
  ENDMETHOD.

  METHOD post_sales_order_issue.
    IF iv_sales_document IS INITIAL OR iv_item_number IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    DATA(lt_requests) = normalize_base_requests( it_requests ).
    rs_result = post_reservation_movement(
      is_header         = is_header
      it_requests       = lt_requests
      iv_test_run       = iv_test_run
      iv_is_reversal    = abap_false
      iv_sales_document = iv_sales_document
      iv_sales_item     = iv_item_number ).
  ENDMETHOD.

  METHOD post_sales_order_issue_uom.
    IF iv_sales_document IS INITIAL OR iv_item_number IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    DATA(lt_requests) = normalize_unit_requests( it_requests ).
    rs_result = post_reservation_movement(
      is_header         = is_header
      it_requests       = lt_requests
      iv_test_run       = iv_test_run
      iv_is_reversal    = abap_false
      iv_sales_document = iv_sales_document
      iv_sales_item     = iv_item_number ).
  ENDMETHOD.

  METHOD post_so_issue_bulk.
    IF iv_sales_document IS INITIAL OR iv_item_number IS INITIAL
        OR ( iv_stop_on_failure <> abap_true
          AND iv_stop_on_failure <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    DATA(lt_requests) = normalize_base_requests( it_requests ).
    rs_result = post_reservation_movement_bulk(
      is_header          = is_header
      it_requests        = lt_requests
      iv_test_run        = iv_test_run
      iv_stop_on_failure = iv_stop_on_failure
      iv_is_reversal     = abap_false
      iv_sales_document  = iv_sales_document
      iv_sales_item      = iv_item_number ).
  ENDMETHOD.

  METHOD post_so_issue_remaining.
    DATA lt_requests TYPE ty_issue_requests.
    IF ( iv_test_run <> abap_true AND iv_test_run <> abap_false )
        OR ( iv_stop_on_failure <> abap_true
          AND iv_stop_on_failure <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    DATA(lt_remaining_requests) = preview_so_issue_remaining(
      iv_sales_document      = iv_sales_document
      iv_item_number         = iv_item_number
      it_reservation_numbers = it_reservation_numbers ).

    LOOP AT lt_remaining_requests INTO DATA(ls_remaining_request).
      APPEND VALUE #(
        reservation_number = ls_remaining_request-reservation_number
        reservation_item   = ls_remaining_request-reservation_item
        base_quantity      = ls_remaining_request-base_quantity
        storage_location   = ls_remaining_request-storage_location
        batch              = ls_remaining_request-batch ) TO lt_requests.
    ENDLOOP.

    IF lt_requests IS INITIAL.
      rs_result-is_successful = abap_true.
      rs_result-is_test_run = iv_test_run.
      RETURN.
    ENDIF.

    rs_result = post_so_issue_bulk(
      iv_sales_document  = iv_sales_document
      iv_item_number     = iv_item_number
      is_header          = is_header
      it_requests        = lt_requests
      iv_test_run        = iv_test_run
      iv_stop_on_failure = iv_stop_on_failure ).
  ENDMETHOD.

  METHOD post_so_issue_remaining_atomic.
    DATA lt_requests TYPE ty_issue_requests_in_unit.

    IF iv_test_run <> abap_true AND iv_test_run <> abap_false.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    DATA(lt_remaining_requests) = preview_so_issue_remaining(
      iv_sales_document      = iv_sales_document
      iv_item_number         = iv_item_number
      it_reservation_numbers = it_reservation_numbers ).
    LOOP AT lt_remaining_requests INTO DATA(ls_remaining_request).
      APPEND VALUE #(
        reservation_number = ls_remaining_request-reservation_number
        reservation_item   = ls_remaining_request-reservation_item
        quantity           = ls_remaining_request-base_quantity
        unit               = ls_remaining_request-base_unit
        storage_location   = ls_remaining_request-storage_location
        batch              = ls_remaining_request-batch ) TO lt_requests.
    ENDLOOP.

    DATA(lt_movement_requests) = normalize_unit_requests( lt_requests ).
    rs_result = post_reservation_atomic(
      is_header         = is_header
      it_requests       = lt_movement_requests
      iv_test_run       = iv_test_run
      iv_is_reversal    = abap_false
      iv_sales_document = iv_sales_document
      iv_sales_item     = iv_item_number ).
  ENDMETHOD.

  METHOD preview_so_issue_remaining.
    DATA lt_seen_reservations TYPE HASHED TABLE OF
      bapi2093_res_key-reserv_no WITH UNIQUE KEY table_line.
    DATA lt_reservation_reads TYPE zcl_so_res_read_service=>ty_reservation_reads.

    IF iv_sales_document IS INITIAL OR iv_item_number IS INITIAL
        OR it_reservation_numbers IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    LOOP AT it_reservation_numbers INTO DATA(lv_reservation_number).
      IF lv_reservation_number IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT lv_reservation_number INTO TABLE lt_seen_reservations.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ENDLOOP.

    TRY.
        lt_reservation_reads = mo_reservation_read_service->read_reservations(
          it_reservation_numbers = it_reservation_numbers ).
      CATCH zcx_invalid_reservation.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDTRY.

    LOOP AT lt_reservation_reads INTO DATA(ls_reservation_read).
      IF ls_reservation_read-read_result-is_successful <> abap_true
          OR ls_reservation_read-read_result-movement_type <> '231'
          OR ls_reservation_read-read_result-sales_document
            <> iv_sales_document
          OR ls_reservation_read-read_result-sales_document_item
            <> iv_item_number.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      LOOP AT ls_reservation_read-read_result-items
          INTO DATA(ls_reservation_item).
        IF ls_reservation_item-is_deleted = abap_true.
          CONTINUE.
        ENDIF.
        IF ls_reservation_item-required_quantity
            < ls_reservation_item-withdrawn_quantity.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.

        DATA(lv_open_quantity) =
          zcl_stock_avail_qty_calc=>calculate_open_res_qty(
            iv_required_quantity  = ls_reservation_item-required_quantity
            iv_withdrawn_quantity = ls_reservation_item-withdrawn_quantity ).
        IF lv_open_quantity = 0.
          CONTINUE.
        ENDIF.
        IF ls_reservation_item-movement_allowed <> abap_true
            OR ls_reservation_item-is_final_issue = abap_true
            OR ls_reservation_item-item_number IS INITIAL
            OR ls_reservation_item-base_unit IS INITIAL
            OR ls_reservation_item-base_unit_iso IS INITIAL.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.

        APPEND VALUE #(
          reservation_number = ls_reservation_read-reservation_number
          reservation_item   = ls_reservation_item-item_number
          base_quantity      = lv_open_quantity
          base_unit          = ls_reservation_item-base_unit
          base_unit_iso      = ls_reservation_item-base_unit_iso
          storage_location   = ls_reservation_item-storage_location
          batch              = ls_reservation_item-batch )
          TO rt_requests.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD preview_so_issue_rem_items.
    DATA lt_selected_keys TYPE HASHED TABLE OF ty_item_key
      WITH UNIQUE KEY reservation_number reservation_item.
    DATA lt_found_keys TYPE HASHED TABLE OF ty_item_key
      WITH UNIQUE KEY reservation_number reservation_item.
    DATA lt_seen_reservations TYPE HASHED TABLE OF
      bapi2093_res_key-reserv_no WITH UNIQUE KEY table_line.
    DATA lt_seen_reads TYPE HASHED TABLE OF
      bapi2093_res_key-reserv_no WITH UNIQUE KEY table_line.
    DATA lt_reservation_numbers TYPE zcl_so_res_read_service=>ty_reservation_numbers.
    DATA lt_reservation_reads TYPE zcl_so_res_read_service=>ty_reservation_reads.

    IF iv_sales_document IS INITIAL OR iv_item_number IS INITIAL
        OR it_item_keys IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    LOOP AT it_item_keys INTO DATA(ls_item_key).
      IF ls_item_key-reservation_number IS INITIAL
          OR ls_item_key-reservation_item IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT VALUE #(
        reservation_number = ls_item_key-reservation_number
        reservation_item   = ls_item_key-reservation_item )
        INTO TABLE lt_selected_keys.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT ls_item_key-reservation_number INTO TABLE lt_seen_reservations.
      IF sy-subrc = 0.
        APPEND ls_item_key-reservation_number TO lt_reservation_numbers.
      ENDIF.
    ENDLOOP.

    TRY.
        lt_reservation_reads = mo_reservation_read_service->read_reservations(
          it_reservation_numbers = lt_reservation_numbers ).
      CATCH zcx_invalid_reservation.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDTRY.

    LOOP AT lt_reservation_reads INTO DATA(ls_reservation_read).
      IF NOT line_exists( lt_seen_reservations[
            table_line = ls_reservation_read-reservation_number ] )
          OR ls_reservation_read-read_result-is_successful <> abap_true
          OR ls_reservation_read-read_result-movement_type <> '231'
          OR ls_reservation_read-read_result-sales_document
            <> iv_sales_document
          OR ls_reservation_read-read_result-sales_document_item
            <> iv_item_number.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT ls_reservation_read-reservation_number INTO TABLE lt_seen_reads.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      LOOP AT ls_reservation_read-read_result-items
          INTO DATA(ls_reservation_item).
        IF ls_reservation_item-is_deleted = abap_true.
          CONTINUE.
        ENDIF.
        READ TABLE lt_selected_keys TRANSPORTING NO FIELDS
          WITH TABLE KEY reservation_number =
                           ls_reservation_read-reservation_number
                         reservation_item =
                           ls_reservation_item-item_number.
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.
        IF ls_reservation_item-required_quantity < 0
            OR ls_reservation_item-withdrawn_quantity < 0
            OR ls_reservation_item-required_quantity
              < ls_reservation_item-withdrawn_quantity.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.
        IF ls_reservation_item-required_quantity
            = ls_reservation_item-withdrawn_quantity
            OR ls_reservation_item-movement_allowed <> abap_true
            OR ls_reservation_item-is_final_issue = abap_true
            OR ls_reservation_item-item_number IS INITIAL
            OR ls_reservation_item-base_unit IS INITIAL
            OR ls_reservation_item-base_unit_iso IS INITIAL.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.

        INSERT VALUE #(
          reservation_number = ls_reservation_read-reservation_number
          reservation_item   = ls_reservation_item-item_number )
          INTO TABLE lt_found_keys.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.
        APPEND VALUE #(
          reservation_number = ls_reservation_read-reservation_number
          reservation_item   = ls_reservation_item-item_number
          base_quantity      = zcl_stock_avail_qty_calc=>calculate_open_res_qty(
            iv_required_quantity  = ls_reservation_item-required_quantity
            iv_withdrawn_quantity = ls_reservation_item-withdrawn_quantity )
          base_unit          = ls_reservation_item-base_unit
          base_unit_iso      = ls_reservation_item-base_unit_iso
          storage_location   = ls_reservation_item-storage_location
          batch              = ls_reservation_item-batch ) TO rt_requests.
      ENDLOOP.
    ENDLOOP.

    IF lines( lt_seen_reads ) <> lines( lt_seen_reservations )
        OR lines( lt_found_keys ) <> lines( lt_selected_keys ).
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.
  ENDMETHOD.

  METHOD post_so_issue_rem_items_bulk.
    DATA lt_requests TYPE ty_issue_requests_in_unit.

    IF ( iv_test_run <> abap_true AND iv_test_run <> abap_false )
        OR ( iv_stop_on_failure <> abap_true
          AND iv_stop_on_failure <> abap_false )
        OR is_header-posting_date IS INITIAL
        OR is_header-document_date IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    DATA(lt_remaining_requests) = preview_so_issue_rem_items(
      iv_sales_document = iv_sales_document
      iv_item_number    = iv_item_number
      it_item_keys      = it_item_keys ).
    LOOP AT lt_remaining_requests INTO DATA(ls_remaining_request).
      APPEND VALUE #(
        reservation_number = ls_remaining_request-reservation_number
        reservation_item   = ls_remaining_request-reservation_item
        quantity           = ls_remaining_request-base_quantity
        unit               = ls_remaining_request-base_unit
        storage_location   = ls_remaining_request-storage_location
        batch              = ls_remaining_request-batch ) TO lt_requests.
    ENDLOOP.

    rs_result = post_so_issue_bulk_uom(
      iv_sales_document  = iv_sales_document
      iv_item_number     = iv_item_number
      is_header          = is_header
      it_requests        = lt_requests
      iv_test_run        = iv_test_run
      iv_stop_on_failure = iv_stop_on_failure ).
  ENDMETHOD.

  METHOD post_so_issue_rem_items_atomic.
    DATA lt_requests TYPE ty_issue_requests_in_unit.

    IF ( iv_test_run <> abap_true AND iv_test_run <> abap_false )
        OR is_header-posting_date IS INITIAL
        OR is_header-document_date IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    DATA(lt_remaining_requests) = preview_so_issue_rem_items(
      iv_sales_document = iv_sales_document
      iv_item_number    = iv_item_number
      it_item_keys      = it_item_keys ).
    LOOP AT lt_remaining_requests INTO DATA(ls_remaining_request).
      APPEND VALUE #(
        reservation_number = ls_remaining_request-reservation_number
        reservation_item   = ls_remaining_request-reservation_item
        quantity           = ls_remaining_request-base_quantity
        unit               = ls_remaining_request-base_unit
        storage_location   = ls_remaining_request-storage_location
        batch              = ls_remaining_request-batch ) TO lt_requests.
    ENDLOOP.

    DATA(lt_movement_requests) = normalize_unit_requests( lt_requests ).
    rs_result = post_reservation_atomic(
      is_header         = is_header
      it_requests       = lt_movement_requests
      iv_test_run       = iv_test_run
      iv_is_reversal    = abap_false
      iv_sales_document = iv_sales_document
      iv_sales_item     = iv_item_number ).
  ENDMETHOD.

  METHOD preview_so_rev_remaining.
    DATA lt_seen_reservations TYPE HASHED TABLE OF
      bapi2093_res_key-reserv_no WITH UNIQUE KEY table_line.
    DATA lt_seen_reads TYPE HASHED TABLE OF
      bapi2093_res_key-reserv_no WITH UNIQUE KEY table_line.
    DATA lt_seen_items TYPE HASHED TABLE OF ty_item_key
      WITH UNIQUE KEY reservation_number reservation_item.
    DATA lt_reservation_reads TYPE zcl_so_res_read_service=>ty_reservation_reads.

    IF iv_sales_document IS INITIAL OR iv_item_number IS INITIAL
        OR it_reservation_numbers IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    LOOP AT it_reservation_numbers INTO DATA(lv_reservation_number).
      IF lv_reservation_number IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT lv_reservation_number INTO TABLE lt_seen_reservations.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ENDLOOP.

    TRY.
        lt_reservation_reads = mo_reservation_read_service->read_reservations(
          it_reservation_numbers = it_reservation_numbers ).
      CATCH zcx_invalid_reservation.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDTRY.

    LOOP AT lt_reservation_reads INTO DATA(ls_reservation_read).
      IF NOT line_exists( lt_seen_reservations[
            table_line = ls_reservation_read-reservation_number ] )
          OR ls_reservation_read-read_result-is_successful <> abap_true
          OR ls_reservation_read-read_result-movement_type <> '231'
          OR ls_reservation_read-read_result-sales_document
            <> iv_sales_document
          OR ls_reservation_read-read_result-sales_document_item
            <> iv_item_number.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT ls_reservation_read-reservation_number INTO TABLE lt_seen_reads.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      LOOP AT ls_reservation_read-read_result-items
          INTO DATA(ls_reservation_item).
        IF ls_reservation_item-is_deleted = abap_true.
          CONTINUE.
        ENDIF.
        IF ls_reservation_item-required_quantity < 0
            OR ls_reservation_item-withdrawn_quantity < 0
            OR ls_reservation_item-required_quantity
              < ls_reservation_item-withdrawn_quantity.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.
        IF ls_reservation_item-withdrawn_quantity <= 0.
          CONTINUE.
        ENDIF.
        IF ls_reservation_item-item_number IS INITIAL
            OR ls_reservation_item-base_unit IS INITIAL
            OR ls_reservation_item-base_unit_iso IS INITIAL.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.

        INSERT VALUE #(
          reservation_number = ls_reservation_read-reservation_number
          reservation_item   = ls_reservation_item-item_number )
          INTO TABLE lt_seen_items.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.
        APPEND VALUE #(
          reservation_number = ls_reservation_read-reservation_number
          reservation_item   = ls_reservation_item-item_number
          base_quantity      = ls_reservation_item-withdrawn_quantity
          base_unit          = ls_reservation_item-base_unit
          base_unit_iso      = ls_reservation_item-base_unit_iso
          storage_location   = ls_reservation_item-storage_location
          batch              = ls_reservation_item-batch ) TO rt_requests.
      ENDLOOP.
    ENDLOOP.

    IF lines( lt_seen_reads ) <> lines( lt_seen_reservations ).
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.
  ENDMETHOD.

  METHOD post_so_rev_remaining_bulk.
    DATA lt_requests TYPE ty_issue_requests_in_unit.

    IF ( iv_test_run <> abap_true AND iv_test_run <> abap_false )
        OR ( iv_stop_on_failure <> abap_true
          AND iv_stop_on_failure <> abap_false )
        OR is_header-posting_date IS INITIAL
        OR is_header-document_date IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    DATA(lt_return_requests) = preview_so_rev_remaining(
      iv_sales_document      = iv_sales_document
      iv_item_number         = iv_item_number
      it_reservation_numbers = it_reservation_numbers ).
    LOOP AT lt_return_requests INTO DATA(ls_return_request).
      APPEND VALUE #(
        reservation_number = ls_return_request-reservation_number
        reservation_item   = ls_return_request-reservation_item
        quantity           = ls_return_request-base_quantity
        unit               = ls_return_request-base_unit
        storage_location   = ls_return_request-storage_location
        batch              = ls_return_request-batch ) TO lt_requests.
    ENDLOOP.

    rs_result = post_so_reversal_bulk_uom(
      iv_sales_document  = iv_sales_document
      iv_item_number     = iv_item_number
      is_header          = is_header
      it_requests        = lt_requests
      iv_test_run        = iv_test_run
      iv_stop_on_failure = iv_stop_on_failure ).
  ENDMETHOD.

  METHOD post_so_rev_remaining_atomic.
    DATA lt_requests TYPE ty_issue_requests_in_unit.

    IF ( iv_test_run <> abap_true AND iv_test_run <> abap_false )
        OR is_header-posting_date IS INITIAL
        OR is_header-document_date IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    DATA(lt_return_requests) = preview_so_rev_remaining(
      iv_sales_document      = iv_sales_document
      iv_item_number         = iv_item_number
      it_reservation_numbers = it_reservation_numbers ).
    LOOP AT lt_return_requests INTO DATA(ls_return_request).
      APPEND VALUE #(
        reservation_number = ls_return_request-reservation_number
        reservation_item   = ls_return_request-reservation_item
        quantity           = ls_return_request-base_quantity
        unit               = ls_return_request-base_unit
        storage_location   = ls_return_request-storage_location
        batch              = ls_return_request-batch ) TO lt_requests.
    ENDLOOP.

    DATA(lt_movement_requests) = normalize_unit_requests( lt_requests ).
    rs_result = post_reservation_atomic(
      is_header         = is_header
      it_requests       = lt_movement_requests
      iv_test_run       = iv_test_run
      iv_is_reversal    = abap_true
      iv_sales_document = iv_sales_document
      iv_sales_item     = iv_item_number ).
  ENDMETHOD.

  METHOD preview_so_rev_remaining_items.
    DATA lt_selected_keys TYPE HASHED TABLE OF ty_item_key
      WITH UNIQUE KEY reservation_number reservation_item.
    DATA lt_found_keys TYPE HASHED TABLE OF ty_item_key
      WITH UNIQUE KEY reservation_number reservation_item.
    DATA lt_seen_reservations TYPE HASHED TABLE OF
      bapi2093_res_key-reserv_no WITH UNIQUE KEY table_line.
    DATA lt_reservation_numbers TYPE zcl_so_res_read_service=>ty_reservation_numbers.
    DATA lt_all_requests TYPE ty_remaining_issue_requests.

    IF iv_sales_document IS INITIAL OR iv_item_number IS INITIAL
        OR it_item_keys IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    LOOP AT it_item_keys INTO DATA(ls_item_key).
      IF ls_item_key-reservation_number IS INITIAL
          OR ls_item_key-reservation_item IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT VALUE #(
        reservation_number = ls_item_key-reservation_number
        reservation_item   = ls_item_key-reservation_item )
        INTO TABLE lt_selected_keys.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT ls_item_key-reservation_number INTO TABLE lt_seen_reservations.
      IF sy-subrc = 0.
        APPEND ls_item_key-reservation_number TO lt_reservation_numbers.
      ENDIF.
    ENDLOOP.

    lt_all_requests = preview_so_rev_remaining(
      iv_sales_document      = iv_sales_document
      iv_item_number         = iv_item_number
      it_reservation_numbers = lt_reservation_numbers ).
    LOOP AT lt_all_requests INTO DATA(ls_request).
      READ TABLE lt_selected_keys TRANSPORTING NO FIELDS
        WITH TABLE KEY reservation_number = ls_request-reservation_number
                       reservation_item   = ls_request-reservation_item.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      INSERT VALUE #(
        reservation_number = ls_request-reservation_number
        reservation_item   = ls_request-reservation_item )
        INTO TABLE lt_found_keys.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      APPEND ls_request TO rt_requests.
    ENDLOOP.

    IF lines( lt_found_keys ) <> lines( lt_selected_keys ).
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.
  ENDMETHOD.

  METHOD post_so_rev_rem_items_bulk.
    DATA lt_requests TYPE ty_issue_requests_in_unit.

    IF ( iv_test_run <> abap_true AND iv_test_run <> abap_false )
        OR ( iv_stop_on_failure <> abap_true
          AND iv_stop_on_failure <> abap_false )
        OR is_header-posting_date IS INITIAL
        OR is_header-document_date IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    DATA(lt_return_requests) = preview_so_rev_remaining_items(
      iv_sales_document = iv_sales_document
      iv_item_number    = iv_item_number
      it_item_keys      = it_item_keys ).
    LOOP AT lt_return_requests INTO DATA(ls_return_request).
      APPEND VALUE #(
        reservation_number = ls_return_request-reservation_number
        reservation_item   = ls_return_request-reservation_item
        quantity           = ls_return_request-base_quantity
        unit               = ls_return_request-base_unit
        storage_location   = ls_return_request-storage_location
        batch              = ls_return_request-batch ) TO lt_requests.
    ENDLOOP.

    rs_result = post_so_reversal_bulk_uom(
      iv_sales_document  = iv_sales_document
      iv_item_number     = iv_item_number
      is_header          = is_header
      it_requests        = lt_requests
      iv_test_run        = iv_test_run
      iv_stop_on_failure = iv_stop_on_failure ).
  ENDMETHOD.

  METHOD post_so_rev_rem_items_atomic.
    DATA lt_requests TYPE ty_issue_requests_in_unit.

    IF ( iv_test_run <> abap_true AND iv_test_run <> abap_false )
        OR is_header-posting_date IS INITIAL
        OR is_header-document_date IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    DATA(lt_return_requests) = preview_so_rev_remaining_items(
      iv_sales_document = iv_sales_document
      iv_item_number    = iv_item_number
      it_item_keys      = it_item_keys ).
    LOOP AT lt_return_requests INTO DATA(ls_return_request).
      APPEND VALUE #(
        reservation_number = ls_return_request-reservation_number
        reservation_item   = ls_return_request-reservation_item
        quantity           = ls_return_request-base_quantity
        unit               = ls_return_request-base_unit
        storage_location   = ls_return_request-storage_location
        batch              = ls_return_request-batch ) TO lt_requests.
    ENDLOOP.

    DATA(lt_movement_requests) = normalize_unit_requests( lt_requests ).
    rs_result = post_reservation_atomic(
      is_header         = is_header
      it_requests       = lt_movement_requests
      iv_test_run       = iv_test_run
      iv_is_reversal    = abap_true
      iv_sales_document = iv_sales_document
      iv_sales_item     = iv_item_number ).
  ENDMETHOD.

  METHOD post_so_issue_bulk_uom.
    IF iv_sales_document IS INITIAL OR iv_item_number IS INITIAL
        OR ( iv_stop_on_failure <> abap_true
          AND iv_stop_on_failure <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    DATA(lt_requests) = normalize_unit_requests( it_requests ).
    rs_result = post_reservation_movement_bulk(
      is_header          = is_header
      it_requests        = lt_requests
      iv_stop_on_failure = iv_stop_on_failure
      iv_test_run        = iv_test_run
      iv_is_reversal     = abap_false
      iv_sales_document  = iv_sales_document
      iv_sales_item      = iv_item_number ).
  ENDMETHOD.

  METHOD post_so_reversal_bulk.
    IF iv_sales_document IS INITIAL OR iv_item_number IS INITIAL
        OR ( iv_stop_on_failure <> abap_true
          AND iv_stop_on_failure <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    DATA(lt_requests) = normalize_base_requests( it_requests ).
    rs_result = post_reservation_movement_bulk(
      is_header          = is_header
      it_requests        = lt_requests
      iv_stop_on_failure = iv_stop_on_failure
      iv_test_run        = iv_test_run
      iv_is_reversal     = abap_true
      iv_sales_document  = iv_sales_document
      iv_sales_item      = iv_item_number ).
  ENDMETHOD.

  METHOD post_so_reversal_bulk_uom.
    IF iv_sales_document IS INITIAL OR iv_item_number IS INITIAL
        OR ( iv_stop_on_failure <> abap_true
          AND iv_stop_on_failure <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    DATA(lt_requests) = normalize_unit_requests( it_requests ).
    rs_result = post_reservation_movement_bulk(
      is_header          = is_header
      it_requests        = lt_requests
      iv_stop_on_failure = iv_stop_on_failure
      iv_test_run        = iv_test_run
      iv_is_reversal     = abap_true
      iv_sales_document  = iv_sales_document
      iv_sales_item      = iv_item_number ).
  ENDMETHOD.

  METHOD post_sales_order_reversal.
    IF iv_sales_document IS INITIAL OR iv_item_number IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    DATA(lt_requests) = normalize_base_requests( it_requests ).
    rs_result = post_reservation_movement(
      is_header         = is_header
      it_requests       = lt_requests
      iv_test_run       = iv_test_run
      iv_is_reversal    = abap_true
      iv_sales_document = iv_sales_document
      iv_sales_item     = iv_item_number ).
  ENDMETHOD.

  METHOD post_sales_order_reversal_uom.
    IF iv_sales_document IS INITIAL OR iv_item_number IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    DATA(lt_requests) = normalize_unit_requests( it_requests ).
    rs_result = post_reservation_movement(
      is_header         = is_header
      it_requests       = lt_requests
      iv_test_run       = iv_test_run
      iv_is_reversal    = abap_true
      iv_sales_document = iv_sales_document
      iv_sales_item     = iv_item_number ).
  ENDMETHOD.

  METHOD post_goods_issue_reversal.
    DATA(lt_requests) = normalize_base_requests( it_requests ).
    rs_result = post_reservation_movement(
      is_header      = is_header
      it_requests    = lt_requests
      iv_test_run    = iv_test_run
      iv_is_reversal = abap_true ).
  ENDMETHOD.

  METHOD post_goods_issue_bulk.
    IF iv_stop_on_failure <> abap_true
        AND iv_stop_on_failure <> abap_false.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    DATA(lt_requests) = normalize_base_requests( it_requests ).
    rs_result = post_reservation_movement_bulk(
      is_header          = is_header
      it_requests        = lt_requests
      iv_test_run        = iv_test_run
      iv_is_reversal     = abap_false
      iv_stop_on_failure = iv_stop_on_failure ).
  ENDMETHOD.

  METHOD post_goods_issue_reversal_bulk.
    IF iv_stop_on_failure <> abap_true
        AND iv_stop_on_failure <> abap_false.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    DATA(lt_requests) = normalize_base_requests( it_requests ).
    rs_result = post_reservation_movement_bulk(
      is_header          = is_header
      it_requests        = lt_requests
      iv_test_run        = iv_test_run
      iv_is_reversal     = abap_true
      iv_stop_on_failure = iv_stop_on_failure ).
  ENDMETHOD.

  METHOD post_goods_issue_in_unit.
    DATA(lt_requests) = normalize_unit_requests( it_requests ).
    rs_result = post_reservation_movement(
      is_header      = is_header
      it_requests    = lt_requests
      iv_test_run    = iv_test_run
      iv_is_reversal = abap_false ).
  ENDMETHOD.

  METHOD post_goods_issue_rev_in_unit.
    DATA(lt_requests) = normalize_unit_requests( it_requests ).
    rs_result = post_reservation_movement(
      is_header      = is_header
      it_requests    = lt_requests
      iv_test_run    = iv_test_run
      iv_is_reversal = abap_true ).
  ENDMETHOD.

  METHOD post_goods_issue_bulk_unit.
    IF iv_stop_on_failure <> abap_true
        AND iv_stop_on_failure <> abap_false.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    DATA(lt_requests) = normalize_unit_requests( it_requests ).
    rs_result = post_reservation_movement_bulk(
      is_header          = is_header
      it_requests        = lt_requests
      iv_test_run        = iv_test_run
      iv_is_reversal     = abap_false
      iv_stop_on_failure = iv_stop_on_failure ).
  ENDMETHOD.

  METHOD post_goods_issue_rev_bulk_unit.
    IF iv_stop_on_failure <> abap_true
        AND iv_stop_on_failure <> abap_false.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    DATA(lt_requests) = normalize_unit_requests( it_requests ).
    rs_result = post_reservation_movement_bulk(
      is_header          = is_header
      it_requests        = lt_requests
      iv_test_run        = iv_test_run
      iv_is_reversal     = abap_true
      iv_stop_on_failure = iv_stop_on_failure ).
  ENDMETHOD.

  METHOD post_goods_issue_atomic_unit.
    DATA(lt_requests) = normalize_unit_requests( it_requests ).
    rs_result = post_reservation_atomic(
      is_header      = is_header
      it_requests    = lt_requests
      iv_test_run    = iv_test_run
      iv_is_reversal = abap_false ).
  ENDMETHOD.

  METHOD post_goods_issue_rev_atomic.
    DATA(lt_requests) = normalize_unit_requests( it_requests ).
    rs_result = post_reservation_atomic(
      is_header      = is_header
      it_requests    = lt_requests
      iv_test_run    = iv_test_run
      iv_is_reversal = abap_true ).
  ENDMETHOD.

  METHOD post_cc_goods_issue.
    IF iv_test_run <> abap_true AND iv_test_run <> abap_false.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    DATA(lt_requests) = normalize_base_requests( it_requests ).
    validate_cc_item_scope(
      iv_cost_center = iv_cost_center
      it_requests    = lt_requests ).
    rs_result = post_reservation_movement(
      is_header      = is_header
      it_requests    = lt_requests
      iv_test_run    = iv_test_run
      iv_is_reversal = abap_false ).
  ENDMETHOD.

  METHOD post_cc_goods_issue_bulk.
    IF ( iv_test_run <> abap_true AND iv_test_run <> abap_false )
        OR ( iv_stop_on_failure <> abap_true
          AND iv_stop_on_failure <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    DATA(lt_requests) = normalize_base_requests( it_requests ).
    validate_cc_item_scope(
      iv_cost_center = iv_cost_center
      it_requests    = lt_requests ).
    rs_result = post_reservation_movement_bulk(
      is_header          = is_header
      it_requests        = lt_requests
      iv_test_run        = iv_test_run
      iv_is_reversal     = abap_false
      iv_stop_on_failure = iv_stop_on_failure ).
  ENDMETHOD.

  METHOD preview_cc_issue_remaining.
    DATA lt_selected_numbers TYPE HASHED TABLE OF resb-rsnum
      WITH UNIQUE KEY table_line.
    DATA ls_read_result TYPE zcl_cc_reservation_service=>ty_reservation_read_result.

    IF iv_cost_center IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    LOOP AT it_reservation_numbers INTO DATA(lv_reservation_number).
      IF lv_reservation_number IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT lv_reservation_number INTO TABLE lt_selected_numbers.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ENDLOOP.

    TRY.
        ls_read_result = mo_cost_center_service->read_cost_center_reservations(
          iv_cost_center = iv_cost_center ).
      CATCH zcx_invalid_reservation.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDTRY.
    IF ls_read_result-is_successful <> abap_true.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    LOOP AT ls_read_result-reservations INTO DATA(ls_reservation).
      IF it_reservation_numbers IS INITIAL
          OR line_exists( lt_selected_numbers[
            table_line = ls_reservation-reservation_number ] ).
        APPEND ls_reservation TO rt_reservations.
      ENDIF.
    ENDLOOP.

    LOOP AT it_reservation_numbers INTO lv_reservation_number.
      READ TABLE rt_reservations TRANSPORTING NO FIELDS
        WITH KEY reservation_number = lv_reservation_number.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD preview_cc_remaining_items.
    DATA lt_seen_keys TYPE HASHED TABLE OF ty_item_key
      WITH UNIQUE KEY reservation_number reservation_item.
    DATA lt_seen_numbers TYPE HASHED TABLE OF resb-rsnum
      WITH UNIQUE KEY table_line.
    DATA lt_reservation_numbers TYPE ty_cc_reservation_numbers.
    DATA lt_open_reservations TYPE zif_cc_reservation_read_repo=>ty_reservations.
    DATA lt_seen_open_keys TYPE HASHED TABLE OF ty_item_key
      WITH UNIQUE KEY reservation_number reservation_item.

    IF iv_cost_center IS INITIAL OR it_item_keys IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    LOOP AT it_item_keys INTO DATA(ls_item_key).
      IF ls_item_key-reservation_number IS INITIAL
          OR ls_item_key-reservation_item IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT VALUE #(
        reservation_number = ls_item_key-reservation_number
        reservation_item   = ls_item_key-reservation_item )
        INTO TABLE lt_seen_keys.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT ls_item_key-reservation_number INTO TABLE lt_seen_numbers.
      IF sy-subrc = 0.
        APPEND ls_item_key-reservation_number TO lt_reservation_numbers.
      ENDIF.
    ENDLOOP.

    lt_open_reservations = preview_cc_issue_remaining(
      iv_cost_center         = iv_cost_center
      it_reservation_numbers = lt_reservation_numbers ).
    LOOP AT lt_open_reservations INTO DATA(ls_open_reservation).
      READ TABLE lt_seen_keys TRANSPORTING NO FIELDS
        WITH TABLE KEY reservation_number =
                         ls_open_reservation-reservation_number
                       reservation_item =
                         ls_open_reservation-reservation_item.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      INSERT VALUE #(
        reservation_number = ls_open_reservation-reservation_number
        reservation_item   = ls_open_reservation-reservation_item )
        INTO TABLE lt_seen_open_keys.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ENDLOOP.

    LOOP AT it_item_keys INTO ls_item_key.
      READ TABLE lt_open_reservations INTO ls_open_reservation
        WITH KEY reservation_number = ls_item_key-reservation_number
                 reservation_item   = ls_item_key-reservation_item.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      APPEND ls_open_reservation TO rt_reservations.
    ENDLOOP.
  ENDMETHOD.

  METHOD post_cc_issue_remaining.
    DATA lt_requests TYPE ty_issue_requests.

    IF it_reservation_numbers IS INITIAL
        OR ( iv_test_run <> abap_true AND iv_test_run <> abap_false )
        OR ( iv_stop_on_failure <> abap_true
          AND iv_stop_on_failure <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    DATA(lt_reservations) = preview_cc_issue_remaining(
      iv_cost_center         = iv_cost_center
      it_reservation_numbers = it_reservation_numbers ).
    LOOP AT lt_reservations INTO DATA(ls_reservation).
      APPEND VALUE #(
        reservation_number = ls_reservation-reservation_number
        reservation_item   = ls_reservation-reservation_item
        base_quantity      = ls_reservation-open_quantity
        storage_location   = ls_reservation-storage_location
        batch              = ls_reservation-batch ) TO lt_requests.
    ENDLOOP.

    rs_result = post_cc_goods_issue_bulk(
      iv_cost_center     = iv_cost_center
      is_header          = is_header
      it_requests        = lt_requests
      iv_test_run        = iv_test_run
      iv_stop_on_failure = iv_stop_on_failure ).
  ENDMETHOD.

  METHOD post_cc_issue_remaining_atomic.
    DATA lt_requests TYPE ty_issue_requests_in_unit.

    IF it_reservation_numbers IS INITIAL
        OR ( iv_test_run <> abap_true AND iv_test_run <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    DATA(lt_reservations) = preview_cc_issue_remaining(
      iv_cost_center         = iv_cost_center
      it_reservation_numbers = it_reservation_numbers ).
    LOOP AT lt_reservations INTO DATA(ls_reservation).
      APPEND VALUE #(
        reservation_number = ls_reservation-reservation_number
        reservation_item   = ls_reservation-reservation_item
        quantity           = ls_reservation-open_quantity
        unit               = ls_reservation-unit
        storage_location   = ls_reservation-storage_location
        batch              = ls_reservation-batch ) TO lt_requests.
    ENDLOOP.

    DATA(lt_movement_requests) = normalize_unit_requests( lt_requests ).
    rs_result = post_reservation_atomic(
      is_header      = is_header
      it_requests    = lt_movement_requests
      iv_test_run    = iv_test_run
      iv_is_reversal = abap_false
      iv_cost_center = iv_cost_center ).
  ENDMETHOD.

  METHOD post_cc_remaining_items_atomic.
    DATA lt_requests TYPE ty_issue_requests_in_unit.

    IF ( iv_test_run <> abap_true AND iv_test_run <> abap_false )
        OR is_header-posting_date IS INITIAL
        OR is_header-document_date IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    DATA(lt_reservations) = preview_cc_remaining_items(
      iv_cost_center = iv_cost_center
      it_item_keys   = it_item_keys ).
    LOOP AT lt_reservations INTO DATA(ls_reservation).
      APPEND VALUE #(
        reservation_number = ls_reservation-reservation_number
        reservation_item   = ls_reservation-reservation_item
        quantity           = ls_reservation-open_quantity
        unit               = ls_reservation-unit
        storage_location   = ls_reservation-storage_location
        batch              = ls_reservation-batch ) TO lt_requests.
    ENDLOOP.

    DATA(lt_movement_requests) = normalize_unit_requests( lt_requests ).
    rs_result = post_reservation_atomic(
      is_header      = is_header
      it_requests    = lt_movement_requests
      iv_test_run    = iv_test_run
      iv_is_reversal = abap_false
      iv_cost_center = iv_cost_center ).
  ENDMETHOD.

  METHOD post_cc_remaining_items.
    DATA lt_requests TYPE ty_issue_requests_in_unit.

    IF ( iv_test_run <> abap_true AND iv_test_run <> abap_false )
        OR ( iv_stop_on_failure <> abap_true
          AND iv_stop_on_failure <> abap_false )
        OR is_header-posting_date IS INITIAL
        OR is_header-document_date IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    DATA(lt_reservations) = preview_cc_remaining_items(
      iv_cost_center = iv_cost_center
      it_item_keys   = it_item_keys ).
    LOOP AT lt_reservations INTO DATA(ls_reservation).
      APPEND VALUE #(
        reservation_number = ls_reservation-reservation_number
        reservation_item   = ls_reservation-reservation_item
        quantity           = ls_reservation-open_quantity
        unit               = ls_reservation-unit
        storage_location   = ls_reservation-storage_location
        batch              = ls_reservation-batch ) TO lt_requests.
    ENDLOOP.

    rs_result = post_cc_goods_issue_bulk_unit(
      iv_cost_center     = iv_cost_center
      is_header          = is_header
      it_requests        = lt_requests
      iv_test_run        = iv_test_run
      iv_stop_on_failure = iv_stop_on_failure ).
  ENDMETHOD.

  METHOD post_cc_goods_issue_in_unit.
    IF iv_test_run <> abap_true AND iv_test_run <> abap_false.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    DATA(lt_requests) = normalize_unit_requests( it_requests ).
    validate_cc_item_scope(
      iv_cost_center = iv_cost_center
      it_requests    = lt_requests ).
    rs_result = post_reservation_movement(
      is_header      = is_header
      it_requests    = lt_requests
      iv_test_run    = iv_test_run
      iv_is_reversal = abap_false ).
  ENDMETHOD.

  METHOD post_cc_goods_issue_bulk_unit.
    IF ( iv_test_run <> abap_true AND iv_test_run <> abap_false )
        OR ( iv_stop_on_failure <> abap_true
          AND iv_stop_on_failure <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    DATA(lt_requests) = normalize_unit_requests( it_requests ).
    validate_cc_item_scope(
      iv_cost_center = iv_cost_center
      it_requests    = lt_requests ).
    rs_result = post_reservation_movement_bulk(
      is_header          = is_header
      it_requests        = lt_requests
      iv_test_run        = iv_test_run
      iv_is_reversal     = abap_false
      iv_stop_on_failure = iv_stop_on_failure ).
  ENDMETHOD.

  METHOD post_cc_issue_rev.
    IF iv_test_run <> abap_true AND iv_test_run <> abap_false.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    DATA(lt_requests) = normalize_base_requests( it_requests ).
    validate_cc_reversal_scope(
      iv_cost_center = iv_cost_center
      it_requests    = lt_requests ).
    rs_result = post_reservation_movement(
      is_header      = is_header
      it_requests    = lt_requests
      iv_test_run    = iv_test_run
      iv_is_reversal = abap_true ).
  ENDMETHOD.

  METHOD post_cc_issue_rev_bulk.
    IF ( iv_test_run <> abap_true AND iv_test_run <> abap_false )
        OR ( iv_stop_on_failure <> abap_true
          AND iv_stop_on_failure <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    DATA(lt_requests) = normalize_base_requests( it_requests ).
    validate_cc_reversal_scope(
      iv_cost_center = iv_cost_center
      it_requests    = lt_requests ).
    rs_result = post_reservation_movement_bulk(
      is_header          = is_header
      it_requests        = lt_requests
      iv_test_run        = iv_test_run
      iv_is_reversal     = abap_true
      iv_stop_on_failure = iv_stop_on_failure ).
  ENDMETHOD.

  METHOD post_cc_issue_rev_unit.
    IF iv_test_run <> abap_true AND iv_test_run <> abap_false.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    DATA(lt_requests) = normalize_unit_requests( it_requests ).
    validate_cc_reversal_scope(
      iv_cost_center = iv_cost_center
      it_requests    = lt_requests ).
    rs_result = post_reservation_movement(
      is_header      = is_header
      it_requests    = lt_requests
      iv_test_run    = iv_test_run
      iv_is_reversal = abap_true ).
  ENDMETHOD.

  METHOD post_cc_issue_rev_bulk_unit.
    IF ( iv_test_run <> abap_true AND iv_test_run <> abap_false )
        OR ( iv_stop_on_failure <> abap_true
          AND iv_stop_on_failure <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    DATA(lt_requests) = normalize_unit_requests( it_requests ).
    validate_cc_reversal_scope(
      iv_cost_center = iv_cost_center
      it_requests    = lt_requests ).
    rs_result = post_reservation_movement_bulk(
      is_header          = is_header
      it_requests        = lt_requests
      iv_test_run        = iv_test_run
      iv_is_reversal     = abap_true
      iv_stop_on_failure = iv_stop_on_failure ).
  ENDMETHOD.

  METHOD post_cc_issue_rev_atomic.
    IF ( iv_test_run <> abap_true AND iv_test_run <> abap_false )
        OR is_header-posting_date IS INITIAL
        OR is_header-document_date IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    DATA(lt_requests) = normalize_unit_requests( it_requests ).
    validate_cc_reversal_scope(
      iv_cost_center = iv_cost_center
      it_requests    = lt_requests ).
    rs_result = post_reservation_atomic(
      is_header      = is_header
      it_requests    = lt_requests
      iv_test_run    = iv_test_run
      iv_is_reversal = abap_true
      iv_cost_center = iv_cost_center ).
  ENDMETHOD.

  METHOD preview_cc_rev_remaining.
    DATA lt_seen_keys TYPE HASHED TABLE OF ty_item_key
      WITH UNIQUE KEY reservation_number reservation_item.
    DATA lt_seen_reservations TYPE HASHED TABLE OF resb-rsnum
      WITH UNIQUE KEY table_line.
    DATA lt_reservation_numbers TYPE zcl_so_res_read_service=>ty_reservation_numbers.
    DATA lt_reads TYPE zcl_so_res_read_service=>ty_reservation_reads.
    DATA lt_scope_requests TYPE ty_movement_requests.
    DATA lt_seen_items TYPE HASHED TABLE OF ty_item_key
      WITH UNIQUE KEY reservation_number reservation_item.

    IF iv_cost_center IS INITIAL OR it_item_keys IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    LOOP AT it_item_keys INTO DATA(ls_item_key).
      IF ls_item_key-reservation_number IS INITIAL
          OR ls_item_key-reservation_item IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT VALUE #(
        reservation_number = ls_item_key-reservation_number
        reservation_item   = ls_item_key-reservation_item )
        INTO TABLE lt_seen_keys.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      APPEND VALUE #(
        reservation_number = ls_item_key-reservation_number
        reservation_item   = ls_item_key-reservation_item
        quantity           = 1
        is_unit_quantity   = abap_false ) TO lt_scope_requests.
      INSERT ls_item_key-reservation_number INTO TABLE lt_seen_reservations.
      IF sy-subrc = 0.
        APPEND ls_item_key-reservation_number TO lt_reservation_numbers.
      ENDIF.
    ENDLOOP.

    validate_cc_reversal_scope(
      iv_cost_center = iv_cost_center
      it_requests    = lt_scope_requests ).
    TRY.
        lt_reads = mo_reservation_read_service->read_reservations(
          it_reservation_numbers = lt_reservation_numbers ).
      CATCH zcx_invalid_reservation.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDTRY.

    LOOP AT lt_reads INTO DATA(ls_read).
      IF ls_read-read_result-is_successful <> abap_true
          OR ls_read-read_result-movement_type <> '201'.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      LOOP AT ls_read-read_result-items INTO DATA(ls_item).
        READ TABLE lt_seen_keys TRANSPORTING NO FIELDS
          WITH TABLE KEY reservation_number = ls_item-reservation_number
                         reservation_item = ls_item-item_number.
        IF sy-subrc <> 0.
          CONTINUE.
        ENDIF.
        IF ls_item-is_deleted = abap_true
            OR ls_item-required_quantity < ls_item-withdrawn_quantity
            OR ls_item-withdrawn_quantity <= 0
            OR ls_item-base_unit IS INITIAL
            OR ls_item-base_unit_iso IS INITIAL.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.
        INSERT VALUE #(
          reservation_number = ls_item-reservation_number
          reservation_item   = ls_item-item_number ) INTO TABLE lt_seen_items.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.
        APPEND VALUE #(
          reservation_number = ls_item-reservation_number
          reservation_item   = ls_item-item_number
          base_quantity      = ls_item-withdrawn_quantity
          base_unit          = ls_item-base_unit
          base_unit_iso      = ls_item-base_unit_iso
          storage_location   = ls_item-storage_location
          batch              = ls_item-batch ) TO rt_requests.
      ENDLOOP.
    ENDLOOP.

    IF lines( lt_seen_items ) <> lines( lt_seen_keys ).
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.
  ENDMETHOD.

  METHOD post_cc_rev_remaining_atomic.
    DATA lt_requests TYPE ty_issue_requests_in_unit.

    IF ( iv_test_run <> abap_true AND iv_test_run <> abap_false )
        OR is_header-posting_date IS INITIAL
        OR is_header-document_date IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    DATA(lt_return_requests) = preview_cc_rev_remaining(
      iv_cost_center = iv_cost_center
      it_item_keys   = it_item_keys ).
    LOOP AT lt_return_requests INTO DATA(ls_return_request).
      APPEND VALUE #(
        reservation_number = ls_return_request-reservation_number
        reservation_item   = ls_return_request-reservation_item
        quantity           = ls_return_request-base_quantity
        unit               = ls_return_request-base_unit
        storage_location   = ls_return_request-storage_location
        batch              = ls_return_request-batch ) TO lt_requests.
    ENDLOOP.

    DATA(lt_movement_requests) = normalize_unit_requests( lt_requests ).
    rs_result = post_reservation_atomic(
      is_header      = is_header
      it_requests    = lt_movement_requests
      iv_test_run    = iv_test_run
      iv_is_reversal = abap_true
      iv_cost_center = iv_cost_center ).
  ENDMETHOD.

  METHOD post_cc_rev_remaining_bulk.
    DATA lt_requests TYPE ty_issue_requests_in_unit.

    IF ( iv_test_run <> abap_true AND iv_test_run <> abap_false )
        OR ( iv_stop_on_failure <> abap_true
          AND iv_stop_on_failure <> abap_false )
        OR is_header-posting_date IS INITIAL
        OR is_header-document_date IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    DATA(lt_return_requests) = preview_cc_rev_remaining(
      iv_cost_center = iv_cost_center
      it_item_keys   = it_item_keys ).
    LOOP AT lt_return_requests INTO DATA(ls_return_request).
      APPEND VALUE #(
        reservation_number = ls_return_request-reservation_number
        reservation_item   = ls_return_request-reservation_item
        quantity           = ls_return_request-base_quantity
        unit               = ls_return_request-base_unit
        storage_location   = ls_return_request-storage_location
        batch              = ls_return_request-batch ) TO lt_requests.
    ENDLOOP.

    rs_result = post_cc_issue_rev_bulk_unit(
      iv_cost_center     = iv_cost_center
      is_header          = is_header
      it_requests        = lt_requests
      iv_test_run        = iv_test_run
      iv_stop_on_failure = iv_stop_on_failure ).
  ENDMETHOD.

  METHOD post_reservation_movement_bulk.
    DATA lt_seen_requests TYPE HASHED TABLE OF ty_item_key
      WITH UNIQUE KEY reservation_number reservation_item.
    DATA lt_seen_reservations TYPE HASHED TABLE OF
      bapi2093_res_key-reserv_no WITH UNIQUE KEY table_line.
    DATA lt_reservation_numbers TYPE STANDARD TABLE OF
      bapi2093_res_key-reserv_no WITH EMPTY KEY.
    DATA lt_group_requests TYPE ty_movement_requests.
    DATA lv_stop_processing TYPE abap_bool.
    FIELD-SYMBOLS <ls_item> TYPE ty_bulk_issue_item.

    IF is_header-posting_date IS INITIAL
        OR is_header-document_date IS INITIAL
        OR ( ( iv_sales_document IS INITIAL
            AND iv_sales_item IS NOT INITIAL )
          OR ( iv_sales_document IS NOT INITIAL
            AND iv_sales_item IS INITIAL ) )
        OR ( iv_test_run <> abap_true
          AND iv_test_run <> abap_false )
        OR ( iv_is_reversal <> abap_true
          AND iv_is_reversal <> abap_false )
        OR ( iv_stop_on_failure <> abap_true
          AND iv_stop_on_failure <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-reservation_number IS INITIAL
          OR ls_request-reservation_item IS INITIAL
          OR ls_request-quantity <= 0
          OR ( ls_request-is_unit_quantity <> abap_true
            AND ls_request-is_unit_quantity <> abap_false )
          OR ( ls_request-is_unit_quantity = abap_true
            AND ls_request-unit IS INITIAL ).
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT VALUE #(
        reservation_number = ls_request-reservation_number
        reservation_item   = ls_request-reservation_item )
        INTO TABLE lt_seen_requests.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT ls_request-reservation_number INTO TABLE lt_seen_reservations.
      IF sy-subrc = 0.
        APPEND ls_request-reservation_number TO lt_reservation_numbers.
      ENDIF.
    ENDLOOP.

    rs_result-is_successful = abap_true.
    rs_result-is_test_run = iv_test_run.
    LOOP AT lt_reservation_numbers INTO DATA(lv_reservation_number).
      APPEND INITIAL LINE TO rs_result-items ASSIGNING <ls_item>.
      <ls_item>-reservation_number = lv_reservation_number.

      IF lv_stop_processing = abap_true.
        <ls_item>-is_skipped = abap_true.
        ADD 1 TO rs_result-skipped_count.
        CONTINUE.
      ENDIF.

      <ls_item>-is_attempted = abap_true.

      CLEAR lt_group_requests.
      LOOP AT it_requests INTO ls_request
          WHERE reservation_number = lv_reservation_number.
        APPEND ls_request TO lt_group_requests.
      ENDLOOP.

      TRY.
          <ls_item>-movement_result = post_reservation_movement(
            is_header         = is_header
            it_requests       = lt_group_requests
            iv_test_run       = iv_test_run
            iv_is_reversal    = iv_is_reversal
            iv_sales_document = iv_sales_document
            iv_sales_item     = iv_sales_item ).
        CATCH zcx_invalid_goods_movement.
          APPEND VALUE #(
            type    = 'E'
            message = 'Reservation goods movement failed validation' )
            TO <ls_item>-movement_result-messages.
      ENDTRY.

      <ls_item>-is_successful =
        <ls_item>-movement_result-is_successful.
      IF <ls_item>-is_successful = abap_true.
        ADD 1 TO rs_result-successful_count.
        IF iv_test_run = abap_false.
          <ls_item>-is_committed = abap_true.
        ENDIF.
        IF <ls_item>-is_committed = abap_true.
          rs_result-is_committed = abap_true.
        ENDIF.
      ELSE.
        ADD 1 TO rs_result-failed_count.
        rs_result-is_successful = abap_false.
        IF iv_stop_on_failure = abap_true.
          lv_stop_processing = abap_true.
          rs_result-stopped_on_failure = abap_true.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD post_reservation_atomic.
    FIELD-SYMBOLS <ls_item> TYPE ty_bulk_issue_item.
    DATA lt_seen_items TYPE HASHED TABLE OF ty_item_key
      WITH UNIQUE KEY reservation_number reservation_item.
    DATA lt_seen_reservations TYPE HASHED TABLE OF
      bapi2093_res_key-reserv_no WITH UNIQUE KEY table_line.
    DATA lt_reservation_numbers TYPE STANDARD TABLE OF
      bapi2093_res_key-reserv_no WITH EMPTY KEY.
    DATA lt_group_requests TYPE ty_movement_requests.

    IF ( iv_test_run <> abap_true AND iv_test_run <> abap_false )
        OR ( iv_is_reversal <> abap_true
          AND iv_is_reversal <> abap_false )
        OR ( iv_cost_center IS NOT INITIAL
          AND ( iv_sales_document IS NOT INITIAL
            OR iv_sales_item IS NOT INITIAL ) ).
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    rs_result-is_successful = abap_true.
    rs_result-is_test_run = iv_test_run.
    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.
    IF is_header-posting_date IS INITIAL
        OR is_header-document_date IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-reservation_number IS INITIAL
          OR ls_request-reservation_item IS INITIAL
          OR ls_request-quantity <= 0
          OR ls_request-is_unit_quantity <> abap_true
          OR ls_request-unit IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT VALUE #(
        reservation_number = ls_request-reservation_number
        reservation_item   = ls_request-reservation_item )
        INTO TABLE lt_seen_items.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT ls_request-reservation_number INTO TABLE lt_seen_reservations.
      IF sy-subrc = 0.
        APPEND ls_request-reservation_number TO lt_reservation_numbers.
        APPEND VALUE #(
          reservation_number = ls_request-reservation_number )
          TO rs_result-items.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_reservation_numbers INTO DATA(lv_reservation_number).
      READ TABLE rs_result-items ASSIGNING <ls_item> INDEX sy-tabix.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      <ls_item>-is_attempted = abap_true.
      CLEAR lt_group_requests.
      LOOP AT it_requests INTO ls_request
          WHERE reservation_number = lv_reservation_number.
        APPEND ls_request TO lt_group_requests.
      ENDLOOP.

      DATA lv_call_raised TYPE abap_bool.
      TRY.
          IF iv_cost_center IS NOT INITIAL.
            IF iv_is_reversal = abap_true.
              validate_cc_reversal_scope(
                iv_cost_center = iv_cost_center
                it_requests    = lt_group_requests ).
            ELSE.
              validate_cc_item_scope(
                iv_cost_center = iv_cost_center
                it_requests    = lt_group_requests ).
            ENDIF.
          ENDIF.
          <ls_item>-movement_result = post_reservation_movement(
            is_header         = is_header
            it_requests       = lt_group_requests
            iv_test_run       = iv_test_run
            iv_is_reversal    = iv_is_reversal
            iv_defer_commit   = xsdbool( iv_test_run = abap_false )
            iv_sales_document = iv_sales_document
            iv_sales_item     = iv_sales_item ).
        CATCH zcx_invalid_goods_movement.
          lv_call_raised = abap_true.
          APPEND VALUE #(
            type    = 'E'
            message = 'Atomic reservation issue failed validation' )
            TO <ls_item>-movement_result-messages.
      ENDTRY.

      <ls_item>-is_successful =
        <ls_item>-movement_result-is_successful.
      IF <ls_item>-is_successful = abap_true.
        ADD 1 TO rs_result-successful_count.
        CONTINUE.
      ENDIF.

      rs_result-is_successful = abap_false.
      IF iv_test_run = abap_false.
        IF lv_call_raised = abap_true.
          mo_goods_movement_api->rollback( ).
        ENDIF.
        rs_result-was_rolled_back = abap_true.
      ENDIF.
      rs_result-failed_count = lines( rs_result-items ).
      rs_result-successful_count = 0.
      LOOP AT rs_result-items ASSIGNING <ls_item>.
        <ls_item>-is_successful = abap_false.
        CLEAR: <ls_item>-is_committed,
          <ls_item>-movement_result-material_document,
          <ls_item>-movement_result-fiscal_year.
        <ls_item>-movement_result-is_successful = abap_false.
      ENDLOOP.
      RETURN.
    ENDLOOP.

    IF iv_test_run = abap_true.
      RETURN.
    ENDIF.

    rs_result-commit_result = mo_goods_movement_api->commit( ).
    IF rs_result-commit_result-is_successful = abap_true
        AND rs_result-commit_result-message-type <> 'A'
        AND rs_result-commit_result-message-type <> 'E'
        AND rs_result-commit_result-message-type <> 'X'.
      rs_result-is_committed = abap_true.
      LOOP AT rs_result-items ASSIGNING <ls_item>.
        <ls_item>-is_committed = abap_true.
      ENDLOOP.
      RETURN.
    ENDIF.

    mo_goods_movement_api->rollback( ).
    rs_result-is_successful = abap_false.
    rs_result-is_committed = abap_false.
    rs_result-was_rolled_back = abap_true.
    rs_result-failed_count = lines( rs_result-items ).
    rs_result-successful_count = 0.
    LOOP AT rs_result-items ASSIGNING <ls_item>.
      <ls_item>-is_successful = abap_false.
      <ls_item>-movement_result-is_successful = abap_false.
      CLEAR: <ls_item>-is_committed,
        <ls_item>-movement_result-material_document,
        <ls_item>-movement_result-fiscal_year.
    ENDLOOP.
    READ TABLE rs_result-items ASSIGNING <ls_item>
      INDEX lines( rs_result-items ).
    IF sy-subrc = 0.
      IF rs_result-commit_result-message IS NOT INITIAL.
        APPEND rs_result-commit_result-message
          TO <ls_item>-movement_result-messages.
      ELSE.
        APPEND VALUE #(
          type    = 'E'
          message = 'Atomic reservation issue commit failed' )
          TO <ls_item>-movement_result-messages.
      ENDIF.
    ENDIF.
  ENDMETHOD.

  METHOD post_reservation_movement.
    IF is_header-posting_date IS INITIAL
        OR is_header-document_date IS INITIAL
        OR it_requests IS INITIAL
        OR ( ( iv_sales_document IS INITIAL
            AND iv_sales_item IS NOT INITIAL )
          OR ( iv_sales_document IS NOT INITIAL
            AND iv_sales_item IS INITIAL ) )
        OR ( iv_test_run <> abap_true
          AND iv_test_run <> abap_false )
        OR ( iv_defer_commit <> abap_true
          AND iv_defer_commit <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    DATA lt_seen TYPE HASHED TABLE OF ty_item_key
      WITH UNIQUE KEY reservation_number reservation_item.
    DATA lt_seen_reservation_numbers TYPE HASHED TABLE OF
      bapi2093_res_key-reserv_no WITH UNIQUE KEY table_line.
    DATA lt_read_numbers TYPE zcl_so_res_read_service=>ty_reservation_numbers.
    DATA lt_reservation_reads TYPE zcl_so_res_read_service=>ty_reservation_reads.
    DATA lt_reservation_items TYPE zif_so_reservation_reader=>ty_items.
    DATA lt_read_messages TYPE zif_so_reservation_reader=>ty_result-messages.
    DATA lv_read_failed TYPE abap_bool.

    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-reservation_number IS INITIAL
          OR ls_request-reservation_item IS INITIAL
          OR ls_request-quantity <= 0
          OR ( ls_request-is_unit_quantity <> abap_true
            AND ls_request-is_unit_quantity <> abap_false )
          OR ( ls_request-is_unit_quantity = abap_true
            AND ls_request-unit IS INITIAL ).
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      INSERT VALUE #(
        reservation_number = ls_request-reservation_number
        reservation_item   = ls_request-reservation_item )
        INTO TABLE lt_seen.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      INSERT ls_request-reservation_number
        INTO TABLE lt_seen_reservation_numbers.
      IF sy-subrc = 0.
        APPEND ls_request-reservation_number TO lt_read_numbers.
      ENDIF.
    ENDLOOP.

    lt_reservation_reads = mo_reservation_read_service->read_reservations(
      it_reservation_numbers = lt_read_numbers ).
    LOOP AT lt_reservation_reads INTO DATA(ls_reservation_read).
      APPEND LINES OF ls_reservation_read-read_result-messages
        TO lt_read_messages.
      IF ls_reservation_read-read_result-is_successful = abap_false.
        lv_read_failed = abap_true.
      ELSEIF iv_sales_document IS NOT INITIAL
          AND ( ls_reservation_read-read_result-movement_type <> '231'
            OR ls_reservation_read-read_result-sales_document
              <> iv_sales_document
            OR ls_reservation_read-read_result-sales_document_item
              <> iv_sales_item ).
        APPEND VALUE #(
          type    = 'E'
          message = 'Reservation is not assigned to the requested sales order item' )
          TO lt_read_messages.
        lv_read_failed = abap_true.
      ELSE.
        APPEND LINES OF ls_reservation_read-read_result-items
          TO lt_reservation_items.
      ENDIF.
    ENDLOOP.

    IF lv_read_failed = abap_true.
      rs_result-messages = lt_read_messages.
      IF rs_result-messages IS INITIAL.
        APPEND VALUE #(
          type    = 'E'
          message = 'Reservation details could not be read' )
          TO rs_result-messages.
      ENDIF.
      IF iv_defer_commit = abap_true.
        mo_goods_movement_api->rollback( ).
      ENDIF.
      RETURN.
    ENDIF.

    DATA lt_movement_items TYPE zif_goods_movement_api=>ty_items.
    LOOP AT it_requests INTO ls_request.
      READ TABLE lt_reservation_items INTO DATA(ls_reservation_item)
        WITH KEY reservation_number = ls_request-reservation_number
                 item_number        = ls_request-reservation_item.
      IF sy-subrc <> 0
          OR ls_reservation_item-is_deleted = abap_true
          OR ls_reservation_item-base_unit IS INITIAL
          OR ls_reservation_item-base_unit_iso IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      IF iv_is_reversal = abap_true.
        IF ls_reservation_item-withdrawn_quantity <= 0.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.
      ELSEIF ls_reservation_item-movement_allowed <> abap_true
          OR ls_reservation_item-is_final_issue = abap_true.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      IF ls_request-storage_location IS NOT INITIAL
          AND ls_reservation_item-storage_location IS NOT INITIAL
          AND ls_request-storage_location
            <> ls_reservation_item-storage_location.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      IF ls_request-batch IS NOT INITIAL
          AND ls_reservation_item-batch IS NOT INITIAL
          AND ls_request-batch <> ls_reservation_item-batch.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      DATA(lv_requested_base_quantity) = ls_request-quantity.
      IF ls_request-is_unit_quantity = abap_true.
        DATA(ls_conversion) = mo_uom_converter->convert_material_unit(
          iv_material    = ls_reservation_item-material
          iv_quantity    = ls_request-quantity
          iv_source_unit = ls_request-unit ).
        IF ls_conversion-is_successful <> abap_true
            OR ls_conversion-base_unit <> ls_reservation_item-base_unit.
          RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
        ENDIF.
        lv_requested_base_quantity = ls_conversion-base_quantity.
      ENDIF.

      DATA(lv_available_quantity) = COND mard-labst(
        WHEN iv_is_reversal = abap_true
          THEN ls_reservation_item-withdrawn_quantity
        ELSE zcl_stock_avail_qty_calc=>calculate_open_res_qty(
          iv_required_quantity  = ls_reservation_item-required_quantity
          iv_withdrawn_quantity = ls_reservation_item-withdrawn_quantity ) ).
      IF lv_requested_base_quantity <= 0
          OR lv_requested_base_quantity > lv_available_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      DATA lv_storage_location TYPE mard-lgort.
      IF ls_reservation_item-storage_location IS INITIAL.
        lv_storage_location = ls_request-storage_location.
      ELSE.
        lv_storage_location = ls_reservation_item-storage_location.
      ENDIF.

      DATA lv_batch TYPE bapi2093_res_item_detail-batch.
      IF ls_reservation_item-batch IS INITIAL.
        lv_batch = ls_request-batch.
      ELSE.
        lv_batch = ls_reservation_item-batch.
      ENDIF.

      APPEND VALUE #(
        reservation_number      = ls_request-reservation_number
        reservation_item        = ls_request-reservation_item
        reservation_record_type = ls_reservation_item-record_type
        movement_indicator      = space
        is_reversal             = iv_is_reversal
        quantity                = lv_requested_base_quantity
        entry_unit              = ls_reservation_item-base_unit
        entry_unit_iso          = ls_reservation_item-base_unit_iso
        storage_location        = lv_storage_location
        batch                   = lv_batch )
        TO lt_movement_items.
    ENDLOOP.

    rs_result = mo_goods_movement_service->execute(
      is_header       = is_header
      iv_gm_code      = COND #(
        WHEN iv_is_reversal = abap_true THEN '06'
        ELSE '03' )
      it_items        = lt_movement_items
      iv_test_run     = iv_test_run
      iv_defer_commit = iv_defer_commit ).
    APPEND LINES OF lt_read_messages TO rs_result-messages.
  ENDMETHOD.

  METHOD normalize_base_requests.
    LOOP AT it_requests INTO DATA(ls_request).
      APPEND VALUE #(
        reservation_number = ls_request-reservation_number
        reservation_item   = ls_request-reservation_item
        quantity           = ls_request-base_quantity
        is_unit_quantity   = abap_false
        storage_location   = ls_request-storage_location
        batch              = ls_request-batch )
        TO rt_requests.
    ENDLOOP.
  ENDMETHOD.

  METHOD normalize_unit_requests.
    LOOP AT it_requests INTO DATA(ls_request).
      APPEND VALUE #(
        reservation_number = ls_request-reservation_number
        reservation_item   = ls_request-reservation_item
        quantity           = ls_request-quantity
        unit               = ls_request-unit
        is_unit_quantity   = abap_true
        storage_location   = ls_request-storage_location
        batch              = ls_request-batch )
        TO rt_requests.
    ENDLOOP.
  ENDMETHOD.

  METHOD validate_cc_item_scope.
    DATA lt_seen_requests TYPE HASHED TABLE OF ty_item_key
      WITH UNIQUE KEY reservation_number reservation_item.

    IF iv_cost_center IS INITIAL OR it_requests IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-reservation_number IS INITIAL
          OR ls_request-reservation_item IS INITIAL
          OR ls_request-quantity <= 0
          OR ( ls_request-is_unit_quantity <> abap_true
            AND ls_request-is_unit_quantity <> abap_false )
          OR ( ls_request-is_unit_quantity = abap_true
            AND ls_request-unit IS INITIAL ).
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT VALUE #(
        reservation_number = ls_request-reservation_number
        reservation_item   = ls_request-reservation_item )
        INTO TABLE lt_seen_requests.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ENDLOOP.

    DATA(ls_cc_read) = mo_cost_center_service->read_cost_center_reservations(
      iv_cost_center = iv_cost_center ).
    IF ls_cc_read-is_successful <> abap_true.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    LOOP AT it_requests INTO ls_request.
      READ TABLE ls_cc_read-reservations INTO DATA(ls_cc_item)
        WITH KEY reservation_number = ls_request-reservation_number
                 reservation_item   = ls_request-reservation_item.
      IF sy-subrc <> 0
          OR ls_cc_item-cost_center <> iv_cost_center
          OR ls_cc_item-open_quantity <= 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD validate_cc_reversal_scope.
    DATA lt_seen_requests TYPE HASHED TABLE OF ty_item_key
      WITH UNIQUE KEY reservation_number reservation_item.
    DATA lt_item_keys TYPE zif_cc_reservation_read_repo=>ty_item_keys.
    DATA lt_seen_scopes TYPE HASHED TABLE OF ty_item_key
      WITH UNIQUE KEY reservation_number reservation_item.

    IF iv_cost_center IS INITIAL OR it_requests IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-reservation_number IS INITIAL
          OR ls_request-reservation_item IS INITIAL
          OR ls_request-quantity <= 0
          OR ( ls_request-is_unit_quantity <> abap_true
            AND ls_request-is_unit_quantity <> abap_false )
          OR ( ls_request-is_unit_quantity = abap_true
            AND ls_request-unit IS INITIAL ).
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      INSERT VALUE #(
        reservation_number = ls_request-reservation_number
        reservation_item   = ls_request-reservation_item )
        INTO TABLE lt_seen_requests.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      APPEND VALUE #(
        reservation_number = ls_request-reservation_number
        reservation_item   = ls_request-reservation_item )
        TO lt_item_keys.
    ENDLOOP.

    DATA(lt_scopes) = mo_cc_reservation_reader->get_reservation_item_scopes(
      iv_cost_center = iv_cost_center
      it_item_keys   = lt_item_keys ).
    LOOP AT lt_scopes INTO DATA(ls_scope).
      IF ls_scope-cost_center <> iv_cost_center.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      READ TABLE lt_seen_requests TRANSPORTING NO FIELDS
        WITH TABLE KEY reservation_number = ls_scope-reservation_number
                       reservation_item   = ls_scope-reservation_item.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
      INSERT VALUE #(
        reservation_number = ls_scope-reservation_number
        reservation_item   = ls_scope-reservation_item )
        INTO TABLE lt_seen_scopes.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.
    ENDLOOP.

    IF lines( lt_seen_scopes ) <> lines( lt_seen_requests ).
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
