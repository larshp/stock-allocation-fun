CLASS zcl_stock_order_service DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS constructor
      IMPORTING order_source TYPE REF TO zif_stock_order_source
                stock_source TYPE REF TO zif_stock_source
      RAISING zcx_stock_alloc.
    METHODS simulate
      IMPORTING orders             TYPE zif_stock_order_source=>ty_orders
                through_date       TYPE d DEFAULT '99991231'
                from_date          TYPE d DEFAULT '00010101'
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
                                      through_date = through_date
                                      from_date    = from_date ).
    IF orders IS INITIAL.
      RETURN.
    ENDIF.
    DATA(requests) = order_source->read( orders       = orders
                                         through_date = through_date
                                         from_date    = from_date ).
    DATA selected TYPE HASHED TABLE OF zif_stock_order_source=>ty_order WITH UNIQUE KEY order_id.
    selected = orders.
    LOOP AT requests INTO DATA(request).
      IF request-required_date > through_date OR request-required_date < from_date.
        RAISE EXCEPTION TYPE zcx_stock_alloc
          EXPORTING reason = 'Order source returned demand beyond the requested horizon'.
      ENDIF.
      READ TABLE selected INTO DATA(order) WITH TABLE KEY order_id = request-origin-order_id.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_stock_alloc
          EXPORTING reason = |Order source returned unselected or missing origin for { request-request_id }|.
      ENDIF.
      IF request-priority <> order-priority OR request-allow_partial <> order-allow_partial.
        RAISE EXCEPTION TYPE zcx_stock_alloc
          EXPORTING reason = |Order source changed the selected policy for { request-request_id }|.
      ENDIF.
    ENDLOOP.
    allocations = service->simulate( requests ).
  ENDMETHOD.
ENDCLASS.
