CLASS zcl_stock_allocator_auto DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_stock_allocation.
  PRIVATE SECTION.
    METHODS raise_error
      IMPORTING
        iv_message TYPE zif_allocation_audit=>ty_message
      RAISING
        zcx_stock_allocation.
ENDCLASS.

CLASS zcl_stock_allocator_auto IMPLEMENTATION.
  METHOD zif_stock_allocation~allocate.
    DATA lv_requested_total TYPE zif_stock_allocation=>ty_quantity.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    FIELD-SYMBOLS <ls_demand> TYPE zif_stock_allocation=>ty_demand.

    IF iv_available < 0.
      raise_error( iv_message = 'Available stock is invalid' ).
    ENDIF.

    LOOP AT ct_demands ASSIGNING <ls_demand>.
      IF <ls_demand>-order_id IS INITIAL
          OR <ls_demand>-requested <= 0
          OR <ls_demand>-priority < 0
          OR <ls_demand>-priority > zif_stock_allocation=>c_max_priority.
        raise_error( iv_message = 'Allocation demand is invalid' ).
      ENDIF.
      lv_requested_total = lv_requested_total + <ls_demand>-requested.
    ENDLOOP.

    IF iv_available >= lv_requested_total.
      CREATE OBJECT lo_allocator TYPE zcl_stock_allocator.
    ELSE.
      CREATE OBJECT lo_allocator TYPE zcl_stock_allocator_fair.
    ENDIF.
    rv_remaining = lo_allocator->allocate(
      EXPORTING
        iv_available = iv_available
      CHANGING
        ct_demands   = ct_demands ).
  ENDMETHOD.

  METHOD raise_error.
    DATA lo_error TYPE REF TO zcx_stock_allocation.
    CREATE OBJECT lo_error.
    lo_error->message = iv_message.
    RAISE EXCEPTION lo_error.
  ENDMETHOD.
ENDCLASS.
