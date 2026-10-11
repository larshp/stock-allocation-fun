INTERFACE zif_prod_order_api PUBLIC.

  TYPES ty_order_number TYPE aufk-aufnr.
  TYPES ty_order_numbers TYPE STANDARD TABLE OF ty_order_number
    WITH EMPTY KEY.
  TYPES ty_operation_number TYPE c LENGTH 4.
  TYPES ty_release_control TYPE c LENGTH 1.
  TYPES:
    BEGIN OF ty_create_order_request,
      order_number      TYPE ty_order_number,
      material          TYPE mard-matnr,
      plant             TYPE mard-werks,
      planning_plant    TYPE mard-werks,
      order_type        TYPE c LENGTH 4,
      basic_start_date  TYPE d,
      basic_finish_date TYPE d,
      quantity          TYPE bapi_pp_order_create-quantity,
      quantity_uom      TYPE bapi_pp_order_create-quantity_uom,
    END OF ty_create_order_request.
  TYPES ty_create_order_requests TYPE STANDARD TABLE OF
    ty_create_order_request WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_operation_key,
      production_order TYPE ty_order_number,
      operation_number TYPE ty_operation_number,
    END OF ty_operation_key.
  TYPES ty_operation_keys TYPE STANDARD TABLE OF ty_operation_key
    WITH EMPTY KEY.
  TYPES ty_confirmation_number TYPE n LENGTH 10.
  TYPES ty_confirmation_counter TYPE n LENGTH 8.
  TYPES ty_operation_sequence TYPE c LENGTH 6.
  TYPES ty_confirmation_unit_iso TYPE c LENGTH 3.
  TYPES ty_final_confirmation TYPE c LENGTH 1.
  TYPES:
    BEGIN OF ty_confirmation_create_request,
      production_order   TYPE ty_order_number,
      operation_number   TYPE ty_operation_number,
      operation_sequence TYPE ty_operation_sequence,
      posting_date       TYPE d,
      yield_quantity     TYPE bapi_pp_timeticket-yield,
      scrap_quantity     TYPE bapi_pp_timeticket-scrap,
      rework_quantity    TYPE bapi_pp_timeticket-rework,
      quantity_unit_iso  TYPE ty_confirmation_unit_iso,
      final_confirmation TYPE ty_final_confirmation,
      clear_reservations TYPE abap_bool,
    END OF ty_confirmation_create_request.
  TYPES ty_confirmation_create_requests TYPE STANDARD TABLE OF
    ty_confirmation_create_request WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_confirmation_cancel_request,
      confirmation         TYPE ty_confirmation_number,
      confirmation_counter TYPE ty_confirmation_counter,
      posting_date         TYPE d,
    END OF ty_confirmation_cancel_request.
  TYPES ty_confirmation_cancel_requests TYPE STANDARD TABLE OF
    ty_confirmation_cancel_request WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_change_request,
      production_order   TYPE ty_order_number,
      quantity           TYPE bapi_pp_order_change-quantity,
      quantity_uom       TYPE bapi_pp_order_change-quantity_uom,
      basic_start_date   TYPE bapi_pp_order_change-basic_start_date,
      basic_finish_date  TYPE bapi_pp_order_change-basic_end_date,
      change_quantity    TYPE abap_bool,
      change_start_date  TYPE abap_bool,
      change_finish_date TYPE abap_bool,
    END OF ty_change_request.
  TYPES ty_change_requests TYPE STANDARD TABLE OF ty_change_request
    WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_message,
      type    TYPE c LENGTH 1,
      message TYPE c LENGTH 220,
    END OF ty_message.
  TYPES:
    BEGIN OF ty_commit_result,
      is_successful TYPE abap_bool,
      message       TYPE ty_message,
    END OF ty_commit_result.
  TYPES:
    BEGIN OF ty_confirmation_create_result,
      production_order     TYPE ty_order_number,
      operation_number     TYPE ty_operation_number,
      operation_sequence   TYPE ty_operation_sequence,
      confirmation         TYPE ty_confirmation_number,
      confirmation_counter TYPE ty_confirmation_counter,
      message              TYPE ty_message,
      commit_result        TYPE ty_commit_result,
      is_successful        TYPE abap_bool,
    END OF ty_confirmation_create_result.
  TYPES:
    BEGIN OF ty_confirmation_cancel_result,
      confirmation         TYPE ty_confirmation_number,
      confirmation_counter TYPE ty_confirmation_counter,
      message              TYPE ty_message,
      is_successful        TYPE abap_bool,
    END OF ty_confirmation_cancel_result.
  TYPES:
    BEGIN OF ty_order_result,
      production_order TYPE ty_order_number,
      message          TYPE ty_message,
      is_successful    TYPE abap_bool,
    END OF ty_order_result.
  TYPES ty_order_results TYPE STANDARD TABLE OF ty_order_result
    WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_operation_result,
      production_order TYPE ty_order_number,
      operation_number TYPE ty_operation_number,
      message          TYPE ty_message,
      is_successful    TYPE abap_bool,
    END OF ty_operation_result.
  TYPES ty_operation_results TYPE STANDARD TABLE OF ty_operation_result
    WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_operation_release_result,
      operations    TYPE ty_operation_results,
      is_successful TYPE abap_bool,
    END OF ty_operation_release_result.
  TYPES:
    BEGIN OF ty_release_result,
      orders        TYPE ty_order_results,
      is_successful TYPE abap_bool,
    END OF ty_release_result.
  METHODS release_orders
    IMPORTING
      it_production_orders TYPE ty_order_numbers
      iv_release_control   TYPE ty_release_control
    RETURNING
      VALUE(rs_result)     TYPE ty_release_result.

  METHODS create_order
    IMPORTING
      is_request       TYPE ty_create_order_request
    RETURNING
      VALUE(rs_result) TYPE ty_order_result.

  METHODS release_operations
    IMPORTING
      it_operations      TYPE ty_operation_keys
      iv_release_control TYPE ty_release_control
    RETURNING
      VALUE(rs_result)   TYPE ty_operation_release_result.

  METHODS cancel_confirmation
    IMPORTING
      is_request       TYPE ty_confirmation_cancel_request
    RETURNING
      VALUE(rs_result) TYPE ty_confirmation_cancel_result.

  METHODS create_confirmation
    IMPORTING
      is_request       TYPE ty_confirmation_create_request
    RETURNING
      VALUE(rs_result) TYPE ty_confirmation_create_result.

  METHODS change_order
    IMPORTING
      is_request       TYPE ty_change_request
    RETURNING
      VALUE(rs_result) TYPE ty_order_result.

  METHODS complete_technically
    IMPORTING
      iv_production_order TYPE ty_order_number
    RETURNING
      VALUE(rs_result)    TYPE ty_order_result.

  METHODS set_deletion_flag
    IMPORTING
      iv_production_order TYPE ty_order_number
    RETURNING
      VALUE(rs_result)    TYPE ty_order_result.

  METHODS close_order
    IMPORTING
      iv_production_order TYPE ty_order_number
    RETURNING
      VALUE(rs_result)    TYPE ty_order_result.

  METHODS set_deletion_indicator
    IMPORTING
      iv_production_order TYPE ty_order_number
    RETURNING
      VALUE(rs_result)    TYPE ty_order_result.

  METHODS commit
    RETURNING
      VALUE(rs_result) TYPE ty_commit_result.

  METHODS rollback.

ENDINTERFACE.
