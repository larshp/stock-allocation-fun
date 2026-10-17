INTERFACE zif_so_reservation_api PUBLIC.

  TYPES:
    BEGIN OF ty_request,
      request_id       TYPE c LENGTH 30,
      sales_document   TYPE c LENGTH 10,
      item_number      TYPE c LENGTH 6,
      material         TYPE mard-matnr,
      plant            TYPE mard-werks,
      storage_location TYPE mard-lgort,
      batch            TYPE mchb-charg,
      required_date    TYPE d,
      quantity         TYPE mard-labst,
      unit             TYPE mara-meins,
    END OF ty_request.
  TYPES ty_requests TYPE STANDARD TABLE OF ty_request WITH EMPTY KEY.

  TYPES ty_reservation_numbers TYPE STANDARD TABLE OF
    bapi2093_res_key-reserv_no WITH EMPTY KEY.

  TYPES:
    BEGIN OF ty_reservation,
      request_id         TYPE c LENGTH 30,
      reservation_number TYPE bapi2093_res_key-reserv_no,
      storage_location   TYPE mard-lgort,
      batch              TYPE mchb-charg,
      required_date      TYPE d,
      quantity           TYPE mard-labst,
    END OF ty_reservation.
  TYPES ty_reservations TYPE STANDARD TABLE OF ty_reservation WITH EMPTY KEY.

  TYPES:
    BEGIN OF ty_message,
      type    TYPE c LENGTH 1,
      message TYPE c LENGTH 220,
    END OF ty_message.
  TYPES ty_messages TYPE STANDARD TABLE OF ty_message WITH EMPTY KEY.

  TYPES:
    BEGIN OF ty_result,
      reservations  TYPE ty_reservations,
      messages      TYPE ty_messages,
      is_successful TYPE abap_bool,
    END OF ty_result.
  TYPES:
    BEGIN OF ty_delete_result,
      messages      TYPE ty_messages,
      is_successful TYPE abap_bool,
    END OF ty_delete_result.
  TYPES:
    BEGIN OF ty_commit_result,
      is_successful TYPE abap_bool,
      message       TYPE ty_message,
    END OF ty_commit_result.

  METHODS create_reservations
    IMPORTING
      it_requests      TYPE ty_requests
      iv_test_run      TYPE abap_bool
    RETURNING
      VALUE(rs_result) TYPE ty_result.

  METHODS delete_reservations
    IMPORTING
      it_reservation_numbers TYPE ty_reservation_numbers
      iv_test_run            TYPE abap_bool
    RETURNING
      VALUE(rs_result)       TYPE ty_delete_result.

  METHODS commit
    RETURNING
      VALUE(rs_result) TYPE ty_commit_result.

  METHODS rollback.

ENDINTERFACE.
