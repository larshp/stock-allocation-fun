REPORT zstock_alloc_demo.

DATA stocks TYPE zif_stock_alloc_types=>ty_stocks.
DATA requests TYPE zif_stock_alloc_types=>ty_requests.
DATA allocations TYPE zif_stock_alloc_types=>ty_allocations.
DATA error TYPE REF TO zcx_stock_alloc.

START-OF-SELECTION.
  stocks = VALUE #(
    ( material = 'DEMO-MATERIAL' plant = '1000' storage = '0001'
      unit = 'ST' quantity = 20 safety_stock = 2 committed = 3 ) ).
  requests = VALUE #(
    ( request_id = 'URGENT' material = 'DEMO-MATERIAL' plant = '1000' storage = '0001'
      unit = 'ST' quantity = 8 priority = 1 required_date = '20260930' )
    ( request_id = 'WHOLE-LOTS' material = 'DEMO-MATERIAL' plant = '1000' storage = '0001'
      unit = 'ST' quantity = 8 priority = 2 required_date = '20260930'
      allow_partial = abap_true lot_size = 4 )
    ( request_id = 'REMAINDER' material = 'DEMO-MATERIAL' plant = '1000' storage = '0001'
      unit = 'ST' quantity = 5 priority = 3 required_date = '20261001' allow_partial = abap_true ) ).
  TRY.
      allocations = NEW zcl_stock_allocator( )->allocate( stocks = stocks
                                                        requests = requests ).
      WRITE / 'Stock allocation demo: physical 20, committed 3, safety 2, available 15 ST'.
      LOOP AT allocations INTO DATA(allocation).
        WRITE / |{ allocation-request_id }: allocated { allocation-allocated } | &&
                |{ allocation-unit }, shortage { allocation-shortage }, { allocation-status }|.
      ENDLOOP.
    CATCH zcx_stock_alloc INTO error.
      WRITE / error->reason.
  ENDTRY.
