CLASS zcl_stock_reserved_checked DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_stock_reserved_issue.
    METHODS constructor
      IMPORTING source TYPE REF TO zif_stock_reservation_source
                writer TYPE REF TO zif_stock_reserved_issue
      RAISING zcx_stock_alloc.
  PRIVATE SECTION.
    DATA source TYPE REF TO zif_stock_reservation_source.
    DATA writer TYPE REF TO zif_stock_reserved_issue.
ENDCLASS.

CLASS zcl_stock_reserved_checked IMPLEMENTATION.
  METHOD constructor.
    IF source IS NOT BOUND OR writer IS NOT BOUND.
      RAISE EXCEPTION TYPE zcx_stock_alloc
        EXPORTING reason = 'A reservation source and writer are required'.
    ENDIF.
    me->source = source.
    me->writer = writer.
  ENDMETHOD.

  METHOD zif_stock_reserved_issue~create.
    IF test_run <> abap_true AND test_run <> abap_false.
      RAISE EXCEPTION TYPE zcx_stock_alloc
        EXPORTING reason = 'A valid test mode is required for reserved goods issue'.
    ENDIF.
    zcl_stock_alloc_date=>validate( posting_date ).
    zcl_stock_alloc_date=>validate( document_date ).
    zcl_stock_alloc_result=>validate( allocations ).
    zcl_stock_alloc_origin=>require_reserved( allocations ).
    DATA references TYPE zif_stock_reservation_source=>ty_references.
    LOOP AT allocations INTO DATA(allocation) WHERE allocated > 0.
      APPEND allocation-origin TO references.
    ENDLOOP.
    IF references IS INITIAL.
      RAISE EXCEPTION TYPE zcx_stock_alloc
        EXPORTING reason = 'No allocated quantity to issue'.
    ENDIF.
    DATA(current) = source->read( references ).
    NEW zcl_stock_allocator( )->validate( stocks   = VALUE #( )
                                          requests = current ).
    " Flat hash keys also work in the transpiled runtime.
    TYPES: BEGIN OF ty_snapshot,
             reservation      TYPE n LENGTH 10,
             reservation_item TYPE n LENGTH 4,
             reservation_type TYPE c LENGTH 1,
             request          TYPE zif_stock_alloc_types=>ty_request,
           END OF ty_snapshot.
    DATA indexed TYPE HASHED TABLE OF ty_snapshot
      WITH UNIQUE KEY reservation reservation_item reservation_type.
    LOOP AT current INTO DATA(request).
      INSERT VALUE #( reservation      = request-origin-reservation
                      reservation_item = request-origin-reservation_item
                      reservation_type = request-origin-reservation_type
                      request          = request ) INTO TABLE indexed.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_stock_alloc
          EXPORTING reason = 'Reservation source returned duplicate references'.
      ENDIF.
    ENDLOOP.
    IF lines( indexed ) <> lines( references ).
      RAISE EXCEPTION TYPE zcx_stock_alloc
        EXPORTING reason = 'Reservation source returned a different set of open items'.
    ENDIF.
    LOOP AT allocations INTO allocation WHERE allocated > 0.
      READ TABLE indexed INTO DATA(snapshot)
        WITH TABLE KEY reservation = allocation-origin-reservation
                       reservation_item = allocation-origin-reservation_item
                       reservation_type = allocation-origin-reservation_type.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_stock_alloc
          EXPORTING reason = |Reservation is no longer open for { allocation-request_id }|.
      ENDIF.
      request = snapshot-request.
      IF request-origin-order_id <> allocation-origin-order_id
          OR request-material <> allocation-material OR request-plant <> allocation-plant
          OR request-storage <> allocation-storage OR request-unit <> allocation-unit
          OR request-required_date <> allocation-required_date.
        RAISE EXCEPTION TYPE zcx_stock_alloc
          EXPORTING reason = |Reservation identity changed for { allocation-request_id }|.
      ENDIF.
      IF request-quantity < allocation-allocated.
        RAISE EXCEPTION TYPE zcx_stock_alloc
          EXPORTING reason = |Reservation demand is below the proposed issue for { allocation-request_id }|.
      ENDIF.
    ENDLOOP.
    result = writer->create( allocations   = allocations
                             posting_date  = posting_date
                             document_date = document_date
                             test_run      = test_run ).
  ENDMETHOD.
ENDCLASS.
