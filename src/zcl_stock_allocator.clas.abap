CLASS zcl_stock_allocator DEFINITION PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    METHODS allocate
      IMPORTING stocks             TYPE zif_stock_alloc_types=>ty_stocks
                requests           TYPE zif_stock_alloc_types=>ty_requests
      RETURNING VALUE(allocations) TYPE zif_stock_alloc_types=>ty_allocations
      RAISING   zcx_stock_alloc.
    METHODS validate
      IMPORTING stocks   TYPE zif_stock_alloc_types=>ty_stocks
                requests TYPE zif_stock_alloc_types=>ty_requests
      RAISING   zcx_stock_alloc.
ENDCLASS.

CLASS zcl_stock_allocator IMPLEMENTATION.
  METHOD allocate.
    validate( stocks   = stocks
              requests = requests ).
    DATA remaining TYPE HASHED TABLE OF zif_stock_alloc_types=>ty_stock
      WITH UNIQUE KEY material plant storage.
    remaining = stocks.
    DATA(ordered) = requests.
    SORT ordered BY priority required_date request_id.
    LOOP AT remaining ASSIGNING FIELD-SYMBOL(<stock>).
      <stock>-quantity = <stock>-quantity - <stock>-committed.
      IF <stock>-quantity < 0.
        <stock>-quantity = 0.
      ENDIF.
      <stock>-quantity = <stock>-quantity - <stock>-safety_stock.
      IF <stock>-quantity < 0.
        <stock>-quantity = 0.
      ENDIF.
    ENDLOOP.

    LOOP AT ordered INTO DATA(request).
      DATA(result) = VALUE zif_stock_alloc_types=>ty_allocation(
        request_id    = request-request_id
        material      = request-material
        plant         = request-plant
        storage       = request-storage
        unit          = request-unit
        required_date = request-required_date
        origin        = request-origin
        requested     = request-quantity
        shortage      = request-quantity
        status        = zif_stock_alloc_types=>status_short
        reason        = zif_stock_alloc_types=>reason_missing ).
      READ TABLE remaining ASSIGNING <stock>
        WITH TABLE KEY material = request-material
                       plant    = request-plant
                       storage  = request-storage.
      IF sy-subrc = 0.
        IF <stock>-unit <> request-unit.
          RAISE EXCEPTION TYPE zcx_stock_alloc
            EXPORTING reason = |Unit mismatch for request { request-request_id }|.
        ENDIF.
        result-available_before = <stock>-quantity.
        result-reason = zif_stock_alloc_types=>reason_empty.
        IF <stock>-quantity > 0.
          result-reason = zif_stock_alloc_types=>reason_insufficient.
        ENDIF.
        IF <stock>-quantity >= request-quantity.
          result-allocated = request-quantity.
          result-reason = zif_stock_alloc_types=>reason_full.
        ELSEIF request-allow_partial = abap_true.
          result-allocated = <stock>-quantity.
        ELSEIF <stock>-quantity > 0.
          result-reason = zif_stock_alloc_types=>reason_complete.
        ENDIF.
        IF request-lot_size > 0.
          " Integer thousandths avoid fractional MOD rounding in both runtimes.
          DATA available_ticks TYPE p LENGTH 9 DECIMALS 0.
          DATA lot_ticks TYPE p LENGTH 9 DECIMALS 0.
          available_ticks = result-allocated * 1000.
          lot_ticks = request-lot_size * 1000.
          IF available_ticks MOD lot_ticks <> 0.
            result-reason = zif_stock_alloc_types=>reason_lot.
          ENDIF.
          result-allocated = ( available_ticks DIV lot_ticks ) * lot_ticks / 1000.
        ENDIF.
        IF result-allocated > 0 AND result-allocated < request-min_allocation.
          CLEAR result-allocated.
          result-reason = zif_stock_alloc_types=>reason_minimum.
        ENDIF.
        <stock>-quantity = <stock>-quantity - result-allocated.
        result-available_after = <stock>-quantity.
      ENDIF.
      result-shortage = result-requested - result-allocated.
      IF result-shortage = 0.
        result-status = zif_stock_alloc_types=>status_full.
      ELSEIF result-allocated > 0.
        result-status = zif_stock_alloc_types=>status_partial.
      ENDIF.
      APPEND result TO allocations.
    ENDLOOP.
  ENDMETHOD.

  METHOD validate.
    DATA seen_stocks TYPE HASHED TABLE OF zif_stock_alloc_types=>ty_stock
      WITH UNIQUE KEY material plant storage.
    LOOP AT stocks INTO DATA(stock).
      IF stock-material IS INITIAL OR stock-plant IS INITIAL
          OR stock-storage IS INITIAL OR stock-unit IS INITIAL
          OR stock-quantity < 0 OR stock-safety_stock < 0 OR stock-committed < 0.
        RAISE EXCEPTION TYPE zcx_stock_alloc
          EXPORTING reason = 'Invalid stock key, unit or negative quantity'.
      ENDIF.
      INSERT stock INTO TABLE seen_stocks.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_stock_alloc
          EXPORTING reason = 'Duplicate stock location'.
      ENDIF.
    ENDLOOP.

    DATA seen_requests TYPE HASHED TABLE OF zif_stock_alloc_types=>ty_request
      WITH UNIQUE KEY request_id.
    LOOP AT requests INTO DATA(request).
      IF request-request_id IS INITIAL OR request-material IS INITIAL
          OR request-plant IS INITIAL OR request-storage IS INITIAL
          OR request-unit IS INITIAL OR request-quantity <= 0
          OR request-priority < 0 OR request-required_date IS INITIAL
          OR request-lot_size < 0
          OR request-min_allocation < 0 OR request-min_allocation > request-quantity
          OR ( request-allow_partial <> abap_true AND request-allow_partial <> abap_false ).
        RAISE EXCEPTION TYPE zcx_stock_alloc
          EXPORTING reason = 'Invalid request key, date, policy or quantity'.
      ENDIF.
      zcl_stock_alloc_date=>validate( request-required_date ).
      zcl_stock_alloc_origin=>validate( request-origin ).
      IF request-lot_size > 0.
        DATA requested_ticks TYPE p LENGTH 9 DECIMALS 0.
        DATA lot_ticks TYPE p LENGTH 9 DECIMALS 0.
        requested_ticks = request-quantity * 1000.
        lot_ticks = request-lot_size * 1000.
        IF requested_ticks MOD lot_ticks <> 0.
          RAISE EXCEPTION TYPE zcx_stock_alloc
            EXPORTING reason = |Request { request-request_id } is not a whole number of lots|.
        ENDIF.
      ENDIF.
      INSERT request INTO TABLE seen_requests.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_stock_alloc
          EXPORTING reason = |Duplicate request { request-request_id }|.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.
