CLASS zcl_stock_alloc_service DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS constructor
      IMPORTING source TYPE REF TO zif_stock_source
      RAISING   zcx_stock_alloc.
    METHODS simulate
      IMPORTING requests           TYPE zif_stock_alloc_types=>ty_requests
      RETURNING VALUE(allocations) TYPE zif_stock_alloc_types=>ty_allocations
      RAISING   zcx_stock_alloc.
  PRIVATE SECTION.
    DATA source TYPE REF TO zif_stock_source.
ENDCLASS.

CLASS zcl_stock_alloc_service IMPLEMENTATION.
  METHOD constructor.
    IF source IS NOT BOUND.
      RAISE EXCEPTION TYPE zcx_stock_alloc
        EXPORTING reason = 'A stock source is required'.
    ENDIF.
    me->source = source.
  ENDMETHOD.

  METHOD simulate.
    DATA(allocator) = NEW zcl_stock_allocator( ).
    " Validate requests before any database access.
    allocator->validate( stocks   = VALUE #( )
                         requests = requests ).
    IF requests IS INITIAL.
      RETURN.
    ENDIF.
    allocations = allocator->allocate( stocks   = source->read( requests )
                                       requests = requests ).
  ENDMETHOD.
ENDCLASS.
