INTERFACE zif_cc_reservation_api PUBLIC.

  TYPES:
    BEGIN OF ty_item,
      storage_location TYPE mard-lgort,
      batch            TYPE mchb-charg,
      quantity         TYPE mard-labst,
      unit             TYPE mara-meins,
    END OF ty_item.
  TYPES ty_items TYPE STANDARD TABLE OF ty_item WITH EMPTY KEY.
  TYPES ty_reservation_number TYPE bapi2093_res_key-reserv_no.
  TYPES ty_reservation_numbers TYPE STANDARD TABLE OF
    ty_reservation_number WITH EMPTY KEY.
  TYPES ty_reservation_item_number TYPE resb-rspos.
  TYPES ty_reservation_item_numbers TYPE STANDARD TABLE OF
    ty_reservation_item_number WITH EMPTY KEY.

  TYPES:
    BEGIN OF ty_request,
      material      TYPE mard-matnr,
      plant         TYPE mard-werks,
      cost_center   TYPE bapi2093_res_head-costcenter,
      required_date TYPE d,
      items         TYPE ty_items,
    END OF ty_request.

  TYPES:
    BEGIN OF ty_message,
      type    TYPE c LENGTH 1,
      message TYPE c LENGTH 220,
    END OF ty_message.
  TYPES ty_messages TYPE STANDARD TABLE OF ty_message WITH EMPTY KEY.

  TYPES:
    BEGIN OF ty_result,
      reservation_number TYPE bapi2093_res_key-reserv_no,
      messages           TYPE ty_messages,
      is_successful      TYPE abap_bool,
    END OF ty_result.

  TYPES:
    BEGIN OF ty_commit_result,
      is_successful TYPE abap_bool,
      message       TYPE ty_message,
    END OF ty_commit_result.
  TYPES:
    BEGIN OF ty_delete_result,
      messages      TYPE ty_messages,
      is_successful TYPE abap_bool,
    END OF ty_delete_result.

  METHODS create_reservation
    IMPORTING
      is_request       TYPE ty_request
      iv_test_run      TYPE abap_bool
    RETURNING
      VALUE(rs_result) TYPE ty_result.

  METHODS delete_reservations
    IMPORTING
      it_reservation_numbers TYPE ty_reservation_numbers
      iv_test_run            TYPE abap_bool
    RETURNING
      VALUE(rs_result)       TYPE ty_delete_result.

  METHODS delete_reservation_items
    IMPORTING
      iv_reservation_number TYPE ty_reservation_number
      it_item_numbers       TYPE ty_reservation_item_numbers
    RETURNING
      VALUE(rs_result)      TYPE ty_delete_result.

  METHODS commit
    RETURNING
      VALUE(rs_result) TYPE ty_commit_result.

  METHODS rollback.

ENDINTERFACE.
