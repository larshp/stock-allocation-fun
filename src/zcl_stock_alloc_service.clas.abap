CLASS zcl_stock_alloc_service DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS constructor
      IMPORTING source TYPE REF TO zif_stock_source
      RAISING   zcx_stock_alloc.
    METHODS simulate
      IMPORTING requests           TYPE zif_stock_alloc_types=>ty_requests
                from_date          TYPE d DEFAULT '00010101'
                through_date       TYPE d DEFAULT '99991231'
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
    zcl_stock_alloc_date=>validate( from_date ).
    zcl_stock_alloc_date=>validate( through_date ).
    IF from_date > through_date.
      RAISE EXCEPTION TYPE zcx_stock_alloc
        EXPORTING reason = 'Simulation start date is after its end date'.
    ENDIF.
    DATA(allocator) = NEW zcl_stock_allocator( ).
    " Validate requests before any database access.
    allocator->validate( stocks   = VALUE #( )
                         requests = requests ).
    DATA(selected) = requests.
    DELETE selected WHERE required_date < from_date OR required_date > through_date.
    IF selected IS INITIAL.
      RETURN.
    ENDIF.
    allocations = allocator->allocate( stocks   = source->read( selected )
                                       requests = selected ).
  ENDMETHOD.
ENDCLASS.
