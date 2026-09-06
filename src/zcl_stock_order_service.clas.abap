CLASS zcl_stock_order_service DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS constructor
      IMPORTING order_source TYPE REF TO zif_stock_order_source
                stock_source TYPE REF TO zif_stock_source
      RAISING zcx_stock_alloc.
    METHODS simulate
      IMPORTING orders             TYPE zif_stock_order_source=>ty_orders
                through_date       TYPE d DEFAULT '99991231'
      RETURNING VALUE(allocations) TYPE zif_stock_alloc_types=>ty_allocations
      RAISING zcx_stock_alloc.
  PRIVATE SECTION.
    DATA order_source TYPE REF TO zif_stock_order_source.
    DATA service TYPE REF TO zcl_stock_alloc_service.
ENDCLASS.

CLASS zcl_stock_order_service IMPLEMENTATION.
  METHOD constructor.
    IF order_source IS NOT BOUND.
      RAISE EXCEPTION TYPE zcx_stock_alloc
        EXPORTING reason = 'An order source is required'.
    ENDIF.
    me->order_source = order_source.
    service = NEW #( stock_source ).
  ENDMETHOD.

  METHOD simulate.
    zcl_stock_order_policy=>validate( orders       = orders
                                      through_date = through_date ).
    IF orders IS INITIAL.
      RETURN.
    ENDIF.
    DATA(requests) = order_source->read( orders       = orders
                                         through_date = through_date ).
    LOOP AT requests INTO DATA(request).
      IF request-required_date > through_date.
        RAISE EXCEPTION TYPE zcx_stock_alloc
          EXPORTING reason = 'Order source returned demand beyond the requested horizon'.
      ENDIF.
    ENDLOOP.
    allocations = service->simulate( requests ).
  ENDMETHOD.
ENDCLASS.
