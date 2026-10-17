INTERFACE zif_planned_order_api PUBLIC.

  TYPES:
    BEGIN OF ty_request,
      material         TYPE plaf-matnr,
      plant            TYPE t001w-werks,
      quantity         TYPE plaf-gsmng,
      planned_end_date TYPE plaf-pedtr,
    END OF ty_request.
  TYPES ty_requests TYPE STANDARD TABLE OF ty_request WITH EMPTY KEY.
  TYPES ty_order_number TYPE plaf-plnum.
  TYPES ty_order_numbers TYPE STANDARD TABLE OF ty_order_number
    WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_change_request,
      planned_order          TYPE ty_order_number,
      quantity               TYPE plaf-gsmng,
      planned_start_date     TYPE plaf-psttr,
      planned_end_date       TYPE plaf-pedtr,
      fixed_indicator        TYPE plaf-auffx,
      change_quantity        TYPE abap_bool,
      change_start_date      TYPE abap_bool,
      change_end_date        TYPE abap_bool,
      change_fixed_indicator TYPE abap_bool,
    END OF ty_change_request.
  TYPES ty_change_requests TYPE STANDARD TABLE OF ty_change_request
    WITH EMPTY KEY.
  TYPES:
    BEGIN OF ty_message,
      type    TYPE c LENGTH 1,
      message TYPE c LENGTH 220,
    END OF ty_message.
  TYPES:
    BEGIN OF ty_result,
      planned_order TYPE plaf-plnum,
      message       TYPE ty_message,
      is_successful TYPE abap_bool,
    END OF ty_result.
  TYPES:
    BEGIN OF ty_conversion_result,
      planned_order    TYPE plaf-plnum,
      production_order TYPE aufk-aufnr,
      message          TYPE ty_message,
      is_successful    TYPE abap_bool,
    END OF ty_conversion_result.
  TYPES:
    BEGIN OF ty_commit_result,
      is_successful TYPE abap_bool,
      message       TYPE ty_message,
    END OF ty_commit_result.

  METHODS create_order
    IMPORTING
      is_request       TYPE ty_request
    RETURNING
      VALUE(rs_result) TYPE ty_result.

  METHODS delete_order
    IMPORTING
      iv_planned_order TYPE ty_order_number
    RETURNING
      VALUE(rs_result) TYPE ty_result.

  METHODS change_order
    IMPORTING
      is_request       TYPE ty_change_request
    RETURNING
      VALUE(rs_result) TYPE ty_result.

  METHODS convert_order
    IMPORTING
      iv_planned_order TYPE ty_order_number
    RETURNING
      VALUE(rs_result) TYPE ty_conversion_result.

  METHODS commit
    RETURNING
      VALUE(rs_result) TYPE ty_commit_result.

  METHODS rollback.

ENDINTERFACE.
