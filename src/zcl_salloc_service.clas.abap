CLASS zcl_salloc_service DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        io_stock TYPE REF TO zif_salloc_stock
        io_orders TYPE REF TO zif_salloc_orders
        io_transaction TYPE REF TO zif_salloc_transaction
        io_authorization TYPE REF TO zif_salloc_authorization
        io_logger TYPE REF TO zif_salloc_logger.
    METHODS run
      IMPORTING
        iv_material TYPE zif_salloc_types=>ty_material
        iv_plant TYPE zif_salloc_types=>ty_plant
        iv_simulate TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rt_allocations) TYPE zif_salloc_types=>tt_demands
      RAISING
        zcx_salloc_invalid
        zcx_salloc_integration.
    METHODS release
      IMPORTING
        iv_material TYPE zif_salloc_types=>ty_material
        iv_plant TYPE zif_salloc_types=>ty_plant
        iv_order_id TYPE zif_salloc_types=>ty_order_id
        iv_quantity TYPE zif_salloc_types=>ty_quantity
      RAISING
        zcx_salloc_invalid
        zcx_salloc_integration.
  PRIVATE SECTION.
    DATA mo_stock TYPE REF TO zif_salloc_stock.
    DATA mo_orders TYPE REF TO zif_salloc_orders.
    DATA mo_transaction TYPE REF TO zif_salloc_transaction.
    DATA mo_authorization TYPE REF TO zif_salloc_authorization.
    DATA mo_logger TYPE REF TO zif_salloc_logger.
ENDCLASS.

CLASS zcl_salloc_service IMPLEMENTATION.
  METHOD constructor.
    mo_stock = io_stock.
    mo_orders = io_orders.
    mo_transaction = io_transaction.
    mo_authorization = io_authorization.
    mo_logger = io_logger.
  ENDMETHOD.

  METHOD run.
    IF iv_material IS INITIAL OR iv_plant IS INITIAL.
      RAISE EXCEPTION TYPE zcx_salloc_invalid
        EXPORTING iv_reason = `Material and plant are required`.
    ENDIF.

    DATA activity TYPE zif_salloc_types=>ty_activity.
    IF iv_simulate = abap_true.
      activity = '03'.
    ELSE.
      activity = '02'.
    ENDIF.
    mo_authorization->check_authorization(
      iv_plant = iv_plant
      iv_activity = activity ).

    IF iv_simulate <> abap_true.
      mo_transaction->begin( ).
    ENDIF.
    TRY.
        DATA(available) = mo_stock->get_available(
          iv_material = iv_material
          iv_plant = iv_plant ).
        rt_allocations = mo_orders->get_open_demands(
          iv_material = iv_material
          iv_plant = iv_plant ).
        DATA(remaining) = zcl_salloc_allocator=>allocate(
          EXPORTING iv_available = available
          CHANGING ct_demands = rt_allocations ).
        DATA(reserved) = available - remaining.

        IF iv_simulate <> abap_true.
          IF reserved > 0.
            mo_stock->reserve(
              iv_material = iv_material
              iv_plant = iv_plant
              iv_quantity = reserved ).
            mo_orders->save_allocations(
              iv_material = iv_material
              iv_plant = iv_plant
              it_demands = rt_allocations ).
            LOOP AT rt_allocations ASSIGNING FIELD-SYMBOL(<allocation>)
              WHERE allocated > 0.
              mo_logger->log(
                iv_event = 'ALLOCATE'
                iv_material = iv_material
                iv_plant = iv_plant
                iv_order_id = <allocation>-order_id
                iv_quantity = <allocation>-allocated ).
            ENDLOOP.
          ENDIF.
          mo_transaction->commit( ).
        ENDIF.
      CATCH zcx_salloc_invalid zcx_salloc_integration INTO DATA(error).
        IF iv_simulate <> abap_true.
          mo_transaction->rollback( ).
        ENDIF.
        RAISE EXCEPTION error.
    ENDTRY.
  ENDMETHOD.

  METHOD release.
    IF iv_material IS INITIAL OR iv_plant IS INITIAL OR iv_order_id IS INITIAL.
      RAISE EXCEPTION TYPE zcx_salloc_invalid
        EXPORTING iv_reason = `Material, plant, and order ID are required`.
    ELSEIF iv_quantity <= 0.
      RAISE EXCEPTION TYPE zcx_salloc_invalid
        EXPORTING iv_reason = `Release quantity must be positive`.
    ENDIF.

    mo_authorization->check_authorization(
      iv_plant = iv_plant
      iv_activity = '02' ).

    mo_transaction->begin( ).
    TRY.
        mo_orders->release_allocation(
          iv_material = iv_material
          iv_plant = iv_plant
          iv_order_id = iv_order_id
          iv_quantity = iv_quantity ).
        mo_stock->release(
          iv_material = iv_material
          iv_plant = iv_plant
          iv_quantity = iv_quantity ).
        mo_logger->log(
          iv_event = 'RELEASE'
          iv_material = iv_material
          iv_plant = iv_plant
          iv_order_id = iv_order_id
          iv_quantity = iv_quantity ).
        mo_transaction->commit( ).
      CATCH zcx_salloc_integration INTO DATA(error).
        mo_transaction->rollback( ).
        RAISE EXCEPTION error.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
