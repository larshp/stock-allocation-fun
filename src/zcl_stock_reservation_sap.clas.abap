CLASS zcl_stock_reservation_sap DEFINITION PUBLIC CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_stock_reservation.
  PROTECTED SECTION.
    TYPES ty_items TYPE STANDARD TABLE OF bapi2093_res_item WITH DEFAULT KEY.
    METHODS invoke
      IMPORTING header        TYPE bapi2093_res_head
                items         TYPE ty_items
                test_run      TYPE abap_bool
      RETURNING VALUE(result) TYPE zif_stock_reservation=>ty_result.
ENDCLASS.

CLASS zcl_stock_reservation_sap IMPLEMENTATION.
  METHOD zif_stock_reservation~create.
    IF cost_center IS INITIAL OR base_date IS INITIAL
        OR ( test_run <> abap_true AND test_run <> abap_false ).
      RAISE EXCEPTION TYPE zcx_stock_alloc
        EXPORTING reason = 'Cost center, base date and valid test mode are required'.
    ENDIF.
    zcl_stock_alloc_date=>validate( base_date ).
    DATA header TYPE bapi2093_res_head.
    header-res_date = base_date.
    header-move_type = '201'.
    header-cost_ctr = cost_center.
    DATA items TYPE ty_items.
    DATA seen TYPE HASHED TABLE OF zif_stock_alloc_types=>ty_allocation WITH UNIQUE KEY request_id.
    LOOP AT allocations INTO DATA(allocation).
      IF allocation-request_id IS INITIAL OR allocation-material IS INITIAL
          OR allocation-plant IS INITIAL OR allocation-storage IS INITIAL
          OR allocation-unit IS INITIAL OR allocation-required_date IS INITIAL
          OR allocation-requested <= 0 OR allocation-allocated < 0
          OR allocation-allocated > allocation-requested
          OR allocation-shortage <> allocation-requested - allocation-allocated.
        RAISE EXCEPTION TYPE zcx_stock_alloc
          EXPORTING reason = 'Invalid allocation cannot be reserved'.
      ENDIF.
      zcl_stock_alloc_date=>validate( allocation-required_date ).
      INSERT allocation INTO TABLE seen.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_stock_alloc
          EXPORTING reason = 'Duplicate allocation cannot be reserved'.
      ENDIF.
      IF allocation-allocated = 0.
        CONTINUE.
      ENDIF.
      APPEND VALUE #( material  = allocation-material
                      plant     = allocation-plant
                      stge_loc  = allocation-storage
                      entry_qnt = allocation-allocated
                      entry_uom = allocation-unit
                      req_date  = allocation-required_date
                      movement  = abap_true ) TO items.
    ENDLOOP.
    IF items IS INITIAL.
      RAISE EXCEPTION TYPE zcx_stock_alloc
        EXPORTING reason = 'No allocated quantity to reserve'.
    ENDIF.
    result = invoke( header   = header
                     items    = items
                     test_run = test_run ).
    result-simulated = test_run.
    LOOP AT result-messages INTO DATA(message).
      IF message-type = 'E' OR message-type = 'A' OR message-type = 'X'.
        RAISE EXCEPTION TYPE zcx_stock_alloc
          EXPORTING reason   = |SAP reservation failed: { message-id } { message-number } { message-message }|
                    messages = result-messages.
      ENDIF.
    ENDLOOP.
    IF test_run = abap_false AND result-reservation IS INITIAL.
      RAISE EXCEPTION TYPE zcx_stock_alloc
        EXPORTING reason   = 'SAP returned no reservation number'
                  messages = result-messages.
    ENDIF.
    IF test_run = abap_true.
      CLEAR result-reservation.
    ENDIF.
  ENDMETHOD.

  METHOD invoke.
    DATA bapi_test TYPE bapi2093_test.
    DATA bapi_atp TYPE bapi2093_atpcheck.
    DATA segments TYPE STANDARD TABLE OF bapi_profitability_segment WITH DEFAULT KEY.
    DATA(bapi_items) = items.
    bapi_test-testrun = test_run.
    bapi_atp-atpcheck = abap_true.
    CALL FUNCTION 'BAPI_RESERVATION_CREATE1'
      EXPORTING
        reservationheader    = header
        testrun              = bapi_test
        atpcheck             = bapi_atp
      IMPORTING
        reservation          = result-reservation
      TABLES
        reservationitems     = bapi_items
        profitabilitysegment = segments
        return               = result-messages.
  ENDMETHOD.
ENDCLASS.
