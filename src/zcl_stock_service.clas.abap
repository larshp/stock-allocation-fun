CLASS zcl_stock_service DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_allocation,
        requested_quantity TYPE mard-labst,
        available_quantity TYPE mard-labst,
        allocated_quantity TYPE mard-labst,
        shortfall_quantity TYPE mard-labst,
      END OF ty_allocation.

    METHODS constructor
      IMPORTING
        io_stock_repository TYPE REF TO zif_stock_repository.

    METHODS get_unrestricted_stock
      IMPORTING
        iv_material        TYPE mard-matnr
        iv_plant           TYPE mard-werks
      RETURNING
        VALUE(rv_quantity) TYPE mard-labst.

    METHODS allocate_request
      IMPORTING
        iv_material           TYPE mard-matnr
        iv_plant              TYPE mard-werks
        iv_requested_quantity TYPE mard-labst
      RETURNING
        VALUE(rs_allocation)  TYPE ty_allocation
      RAISING
        zcx_invalid_stock_request.

  PRIVATE SECTION.
    DATA mo_stock_repository TYPE REF TO zif_stock_repository.
ENDCLASS.

CLASS zcl_stock_service IMPLEMENTATION.

  METHOD constructor.
    mo_stock_repository = io_stock_repository.
  ENDMETHOD.

  METHOD get_unrestricted_stock.
    rv_quantity = mo_stock_repository->get_unrestricted_stock(
      iv_material = iv_material
      iv_plant    = iv_plant ).
  ENDMETHOD.

  METHOD allocate_request.
    IF iv_requested_quantity < 0.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    rs_allocation-requested_quantity = iv_requested_quantity.
    rs_allocation-available_quantity = get_unrestricted_stock(
      iv_material = iv_material
      iv_plant    = iv_plant ).

    IF rs_allocation-available_quantity < 0.
      CLEAR rs_allocation-available_quantity.
    ENDIF.

    IF iv_requested_quantity < rs_allocation-available_quantity.
      rs_allocation-allocated_quantity = iv_requested_quantity.
    ELSE.
      rs_allocation-allocated_quantity = rs_allocation-available_quantity.
    ENDIF.

    rs_allocation-shortfall_quantity = iv_requested_quantity
      - rs_allocation-allocated_quantity.
  ENDMETHOD.

ENDCLASS.
