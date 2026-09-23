CLASS zcl_prod_comp_service DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_component,
        production_order   TYPE resb-aufnr,
        reservation_number TYPE resb-rsnum,
        reservation_item   TYPE resb-rspos,
        material           TYPE resb-matnr,
        plant              TYPE resb-werks,
        storage_location   TYPE resb-lgort,
        batch              TYPE resb-charg,
        movement_type      TYPE resb-bwart,
        required_date      TYPE resb-bdter,
        required_quantity  TYPE resb-bdmng,
        withdrawn_quantity TYPE resb-enmng,
        open_quantity      TYPE resb-bdmng,
        unit               TYPE resb-meins,
      END OF ty_component.
    TYPES ty_components TYPE STANDARD TABLE OF ty_component WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_issue_request,
        reservation_number TYPE resb-rsnum,
        reservation_item   TYPE resb-rspos,
        quantity           TYPE resb-bdmng,
        storage_location   TYPE resb-lgort,
        batch              TYPE resb-charg,
      END OF ty_issue_request.
    TYPES ty_issue_requests TYPE STANDARD TABLE OF ty_issue_request
      WITH EMPTY KEY.

    METHODS constructor
      IMPORTING
        io_repository         TYPE REF TO zif_prod_comp_repo OPTIONAL
        io_reservation_reader TYPE REF TO zif_so_reservation_reader OPTIONAL
        io_goods_movement_api TYPE REF TO zif_goods_movement_api OPTIONAL.

    METHODS get_open_components
      IMPORTING
        iv_production_order  TYPE resb-aufnr
      RETURNING
        VALUE(rt_components) TYPE ty_components
      RAISING
        zcx_invalid_production_order.

    METHODS issue_components
      IMPORTING
        iv_production_order TYPE resb-aufnr
        is_header           TYPE zif_goods_movement_api=>ty_header
        it_requests         TYPE ty_issue_requests
        iv_test_run         TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)    TYPE zif_goods_movement_api=>ty_result
      RAISING
        zcx_invalid_production_order
        zcx_invalid_goods_movement.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_component_key,
        reservation_number TYPE resb-rsnum,
        reservation_item   TYPE resb-rspos,
      END OF ty_component_key.

    DATA mo_repository TYPE REF TO zif_prod_comp_repo.
    DATA mo_issue_service TYPE REF TO zcl_reservation_issue_service.
ENDCLASS.

CLASS zcl_prod_comp_service IMPLEMENTATION.

  METHOD constructor.
    IF io_repository IS BOUND.
      mo_repository = io_repository.
    ELSE.
      mo_repository = NEW zcl_prod_comp_repo( ).
    ENDIF.
    mo_issue_service = NEW zcl_reservation_issue_service(
      io_reservation_reader = io_reservation_reader
      io_goods_movement_api = io_goods_movement_api ).
  ENDMETHOD.

  METHOD get_open_components.
    IF iv_production_order IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_production_order.
    ENDIF.

    DATA(lt_items) = mo_repository->get_components(
      iv_production_order = iv_production_order ).

    LOOP AT lt_items INTO DATA(ls_item).
      IF ls_item-production_order <> iv_production_order
          OR ls_item-is_deleted <> space
          OR ls_item-is_final_issue = abap_true
          OR ls_item-reservation_number IS INITIAL
          OR ls_item-reservation_item IS INITIAL.
        CONTINUE.
      ENDIF.

      DATA(lv_open_quantity) = ls_item-required_quantity
        - ls_item-withdrawn_quantity.
      IF lv_open_quantity <= 0.
        CONTINUE.
      ENDIF.

      APPEND VALUE #(
        production_order   = ls_item-production_order
        reservation_number = ls_item-reservation_number
        reservation_item   = ls_item-reservation_item
        material           = ls_item-material
        plant              = ls_item-plant
        storage_location   = ls_item-storage_location
        batch              = ls_item-batch
        movement_type      = ls_item-movement_type
        required_date      = ls_item-required_date
        required_quantity  = ls_item-required_quantity
        withdrawn_quantity = ls_item-withdrawn_quantity
        open_quantity      = lv_open_quantity
        unit               = ls_item-unit ) TO rt_components.
    ENDLOOP.

    SORT rt_components BY reservation_number reservation_item.
  ENDMETHOD.

  METHOD issue_components.
    IF is_header-posting_date IS INITIAL
        OR is_header-document_date IS INITIAL
        OR it_requests IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
    ENDIF.

    DATA(lt_components) = get_open_components(
      iv_production_order = iv_production_order ).
    DATA lt_seen TYPE HASHED TABLE OF ty_component_key
      WITH UNIQUE KEY reservation_number reservation_item.
    DATA lt_issue_requests TYPE zcl_reservation_issue_service=>ty_issue_requests.

    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-reservation_number IS INITIAL
          OR ls_request-reservation_item IS INITIAL
          OR ls_request-quantity <= 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      INSERT VALUE #(
        reservation_number = ls_request-reservation_number
        reservation_item   = ls_request-reservation_item )
        INTO TABLE lt_seen.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      READ TABLE lt_components INTO DATA(ls_component)
        WITH KEY reservation_number = ls_request-reservation_number
                 reservation_item   = ls_request-reservation_item.
      IF sy-subrc <> 0
          OR ls_request-quantity > ls_component-open_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_goods_movement.
      ENDIF.

      APPEND VALUE #(
        reservation_number = ls_request-reservation_number
        reservation_item   = ls_request-reservation_item
        base_quantity      = ls_request-quantity
        storage_location   = ls_request-storage_location
        batch              = ls_request-batch ) TO lt_issue_requests.
    ENDLOOP.

    rs_result = mo_issue_service->post_goods_issue(
      is_header   = is_header
      it_requests = lt_issue_requests
      iv_test_run = iv_test_run ).
  ENDMETHOD.

ENDCLASS.
