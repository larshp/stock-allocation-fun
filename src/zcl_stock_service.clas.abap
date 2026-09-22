CLASS zcl_stock_service DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_demand,
        request_id         TYPE c LENGTH 30,
        material           TYPE mard-matnr,
        plant              TYPE mard-werks,
        requested_quantity TYPE mard-labst,
      END OF ty_demand,
      ty_demands TYPE STANDARD TABLE OF ty_demand WITH EMPTY KEY,
      BEGIN OF ty_allocation,
        request_id         TYPE c LENGTH 30,
        material           TYPE mard-matnr,
        plant              TYPE mard-werks,
        requested_quantity TYPE mard-labst,
        available_quantity TYPE mard-labst,
        allocated_quantity TYPE mard-labst,
        shortfall_quantity TYPE mard-labst,
      END OF ty_allocation.
    TYPES ty_allocations TYPE STANDARD TABLE OF ty_allocation WITH EMPTY KEY.

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

    METHODS allocate_demands
      IMPORTING
        it_demands            TYPE ty_demands
      RETURNING
        VALUE(rt_allocations) TYPE ty_allocations
      RAISING
        zcx_invalid_stock_request.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_stock_balance,
        material           TYPE mard-matnr,
        plant              TYPE mard-werks,
        remaining_quantity TYPE mard-labst,
      END OF ty_stock_balance.
    TYPES ty_stock_balances TYPE HASHED TABLE OF ty_stock_balance
      WITH UNIQUE KEY material plant.

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
    DATA(lt_demands) = VALUE ty_demands(
      ( material           = iv_material
        plant              = iv_plant
        requested_quantity = iv_requested_quantity ) ).
    DATA(lt_allocations) = allocate_demands( it_demands = lt_demands ).

    READ TABLE lt_allocations INDEX 1 INTO rs_allocation.
  ENDMETHOD.

  METHOD allocate_demands.
    DATA lt_stock_balances TYPE ty_stock_balances.
    DATA ls_stock_balance TYPE ty_stock_balance.
    DATA ls_allocation TYPE ty_allocation.
    FIELD-SYMBOLS <ls_stock_balance> TYPE ty_stock_balance.

    LOOP AT it_demands INTO DATA(ls_demand).
      IF ls_demand-requested_quantity < 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      READ TABLE lt_stock_balances ASSIGNING <ls_stock_balance>
        WITH TABLE KEY material = ls_demand-material
                       plant = ls_demand-plant.
      IF sy-subrc <> 0.
        CLEAR ls_stock_balance.
        ls_stock_balance-material = ls_demand-material.
        ls_stock_balance-plant = ls_demand-plant.
        ls_stock_balance-remaining_quantity = get_unrestricted_stock(
          iv_material = ls_demand-material
          iv_plant    = ls_demand-plant ).
        IF ls_stock_balance-remaining_quantity < 0.
          CLEAR ls_stock_balance-remaining_quantity.
        ENDIF.
        INSERT ls_stock_balance INTO TABLE lt_stock_balances.

        READ TABLE lt_stock_balances ASSIGNING <ls_stock_balance>
          WITH TABLE KEY material = ls_demand-material
                         plant = ls_demand-plant.
      ENDIF.

      CLEAR ls_allocation.
      ls_allocation-request_id = ls_demand-request_id.
      ls_allocation-material = ls_demand-material.
      ls_allocation-plant = ls_demand-plant.
      ls_allocation-requested_quantity = ls_demand-requested_quantity.
      ls_allocation-available_quantity = <ls_stock_balance>-remaining_quantity.

      IF ls_demand-requested_quantity < <ls_stock_balance>-remaining_quantity.
        ls_allocation-allocated_quantity = ls_demand-requested_quantity.
      ELSE.
        ls_allocation-allocated_quantity = <ls_stock_balance>-remaining_quantity.
      ENDIF.

      ls_allocation-shortfall_quantity = ls_demand-requested_quantity
        - ls_allocation-allocated_quantity.
      <ls_stock_balance>-remaining_quantity = <ls_stock_balance>-remaining_quantity
        - ls_allocation-allocated_quantity.
      APPEND ls_allocation TO rt_allocations.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
