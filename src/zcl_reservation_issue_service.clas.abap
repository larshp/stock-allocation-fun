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

    METHODS constructor
      IMPORTING
        io_reservation_reader TYPE REF TO zif_so_reservation_reader OPTIONAL
        io_goods_movement_api TYPE REF TO zif_goods_movement_api OPTIONAL.

    METHODS post_goods_issue
      IMPORTING
        is_header        TYPE zif_goods_movement_api=>ty_header
        it_requests      TYPE ty_issue_requests
        iv_test_run      TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result) TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_goods_movement.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_item_key,
        reservation_number TYPE bapi2093_res_key-reserv_no,
        reservation_item   TYPE bapi2093_res_item_detail-res_item,
      END OF ty_item_key.

    DATA mo_reservation_read_service TYPE REF TO zcl_so_res_read_service.
    DATA mo_goods_movement_service TYPE REF TO zcl_goods_movement_service.
ENDCLASS.

CLASS zcl_reservation_issue_service IMPLEMENTATION.

  METHOD constructor.
    mo_reservation_read_service = NEW zcl_so_res_read_service(
      io_reader = io_reservation_reader ).

    IF io_goods_movement_api IS BOUND.
      mo_goods_movement_service = NEW zcl_goods_movement_service(
        io_api = io_goods_movement_api ).
    ELSE.
      DATA(lo_goods_movement_api) = NEW zcl_bapi_goods_movement_api( ).
      mo_goods_movement_service = NEW zcl_goods_movement_service(
        io_api = lo_goods_movement_api ).
    ENDIF.
  ENDMETHOD.

  METHOD post_goods_issue.
    IF is_header-posting_date IS INITIAL
        OR is_header-document_date IS INITIAL
        OR it_requests IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    DATA lt_seen TYPE HASHED TABLE OF ty_item_key
      WITH UNIQUE KEY reservation_number reservation_item.
    DATA lt_read_numbers TYPE HASHED TABLE OF
      bapi2093_res_key-reserv_no WITH UNIQUE KEY table_line.
    DATA lt_reservation_items TYPE zif_so_reservation_reader=>ty_items.
    DATA lt_read_messages TYPE zif_so_reservation_reader=>ty_result-messages.

    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-reservation_number IS INITIAL
          OR ls_request-reservation_item IS INITIAL
          OR ls_request-base_quantity <= 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      INSERT VALUE #(
        reservation_number = ls_request-reservation_number
        reservation_item   = ls_request-reservation_item )
        INTO TABLE lt_seen.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      INSERT ls_request-reservation_number INTO TABLE lt_read_numbers.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.

      DATA(ls_read_result) = mo_reservation_read_service->read_reservation(
        ls_request-reservation_number ).
      APPEND LINES OF ls_read_result-messages TO lt_read_messages.
      IF ls_read_result-is_successful = abap_false.
        rs_result-messages = lt_read_messages.
        IF rs_result-messages IS INITIAL.
          APPEND VALUE #(
            type    = 'E'
            message = 'Reservation details could not be read' )
            TO rs_result-messages.
        ENDIF.
        RETURN.
      ENDIF.

      APPEND LINES OF ls_read_result-items TO lt_reservation_items.
    ENDLOOP.

    DATA lt_movement_items TYPE zif_goods_movement_api=>ty_items.
    LOOP AT it_requests INTO ls_request.
      READ TABLE lt_reservation_items INTO DATA(ls_reservation_item)
        WITH KEY reservation_number = ls_request-reservation_number
                 item_number        = ls_request-reservation_item.
      IF sy-subrc <> 0
          OR ls_reservation_item-movement_allowed <> abap_true
          OR ls_reservation_item-is_deleted = abap_true
          OR ls_reservation_item-is_final_issue = abap_true
          OR ls_reservation_item-base_unit IS INITIAL
          OR ls_reservation_item-base_unit_iso IS INITIAL.
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

      DATA(lv_remaining_quantity) = ls_reservation_item-required_quantity
        - ls_reservation_item-withdrawn_quantity.
      IF ls_request-base_quantity > lv_remaining_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      DATA lv_storage_location TYPE mard-lgort.
      IF ls_reservation_item-storage_location IS INITIAL.
        lv_storage_location = ls_request-storage_location.
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
        quantity                = ls_request-base_quantity
        entry_unit              = ls_reservation_item-base_unit
        entry_unit_iso          = ls_reservation_item-base_unit_iso
        storage_location        = lv_storage_location
        batch                   = lv_batch )
        TO lt_movement_items.
    ENDLOOP.

    rs_result = mo_goods_movement_service->execute(
      is_header   = is_header
      iv_gm_code  = '03'
      it_items    = lt_movement_items
      iv_test_run = iv_test_run ).
    APPEND LINES OF lt_read_messages TO rs_result-messages.
  ENDMETHOD.

ENDCLASS.
