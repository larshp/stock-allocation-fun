REPORT zstock_order_demo.

" This report uses only in-memory sources and a preview writer. No SAP calls.
CLASS lcl_samples DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_stock_order_source.
    INTERFACES zif_stock_reservation_source.
    INTERFACES zif_stock_source.
    DATA main_stock TYPE zif_stock_alloc_types=>ty_quantity VALUE 10.
    METHODS constructor.
  PRIVATE SECTION.
    DATA components TYPE zif_stock_alloc_types=>ty_requests.
ENDCLASS.

CLASS lcl_samples IMPLEMENTATION.
  METHOD constructor.
    components = VALUE #(
      ( request_id = 'ORDER1-PART' material = 'PART' plant = '1000' storage = '0001'
        unit = 'ST' quantity = 8 required_date = '20260930'
        origin = VALUE #( order_id = '000000001000' reservation = '0000000100' reservation_item = '0001' ) )
      ( request_id = 'ORDER1-FLUID' material = 'FLUID' plant = '1000' storage = '0001'
        unit = 'KG' quantity = 2 required_date = '20260930'
        origin = VALUE #( order_id = '000000001000' reservation = '0000000100' reservation_item = '0002' ) )
      ( request_id = 'ORDER2-PART' material = 'PART' plant = '1000' storage = '0001'
        unit = 'ST' quantity = 8 required_date = '20261001'
        origin = VALUE #( order_id = '000000002000' reservation = '0000000200' reservation_item = '0001' ) ) ).
  ENDMETHOD.

  METHOD zif_stock_order_source~read.
    LOOP AT components INTO DATA(component).
      READ TABLE orders INTO DATA(order) WITH KEY order_id = component-origin-order_id.
      IF sy-subrc <> 0 OR component-required_date < from_date OR component-required_date > through_date.
        CONTINUE.
      ENDIF.
      component-priority = order-priority.
      component-allow_partial = order-allow_partial.
      APPEND component TO requests.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_stock_reservation_source~read.
    LOOP AT references INTO DATA(reference).
      LOOP AT components INTO DATA(component).
        IF component-origin-reservation = reference-reservation
            AND component-origin-reservation_item = reference-reservation_item
            AND component-origin-reservation_type = reference-reservation_type.
          APPEND component TO requests.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_stock_source~read.
    DATA(available) = VALUE zif_stock_alloc_types=>ty_stocks(
      ( material = 'PART' plant = '1000' storage = '0001' unit = 'ST' quantity = main_stock )
      ( material = 'FLUID' plant = '1000' storage = '0001' unit = 'KG' quantity = 2 ) ).
    LOOP AT available INTO DATA(stock).
      READ TABLE requests TRANSPORTING NO FIELDS
        WITH KEY material = stock-material plant = stock-plant storage = stock-storage.
      IF sy-subrc = 0.
        APPEND stock TO stocks.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_preview DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_stock_reserved_issue.
    DATA calls TYPE i READ-ONLY.
    DATA item_count TYPE i READ-ONLY.
ENDCLASS.

CLASS lcl_preview IMPLEMENTATION.
  METHOD zif_stock_reserved_issue~create.
    IF test_run <> abap_true.
      RAISE EXCEPTION TYPE zcx_stock_alloc
        EXPORTING reason = 'The demo writer only supports local previews'.
    ENDIF.
    calls = calls + 1.
    CLEAR item_count.
    LOOP AT allocations TRANSPORTING NO FIELDS WHERE allocated > 0.
      item_count = item_count + 1.
    ENDLOOP.
    result-simulated = abap_true.
    result-messages = VALUE #( ( type = 'S' message = 'Local preview only; no SAP call' ) ).
  ENDMETHOD.
ENDCLASS.

DATA samples TYPE REF TO lcl_samples.
DATA preview TYPE REF TO lcl_preview.
DATA service TYPE REF TO zcl_stock_order_service.
DATA issuer TYPE REF TO zif_stock_reserved_issue.
DATA orders TYPE zif_stock_order_source=>ty_orders.
DATA baseline TYPE zif_stock_alloc_types=>ty_allocations.
DATA scenario TYPE zif_stock_alloc_types=>ty_allocations.
DATA summaries TYPE zcl_stock_order_summary=>ty_summaries.
DATA comparisons TYPE zcl_stock_alloc_comparison=>ty_comparisons.
DATA result TYPE zif_stock_reserved_issue=>ty_result.
DATA error TYPE REF TO zcx_stock_alloc.

START-OF-SELECTION.
  TRY.
      samples = NEW #( ).
      preview = NEW #( ).
      service = NEW #( order_source = samples
                       stock_source = samples ).
      orders = VALUE #( ( order_id = '000000001000' priority = 1 allow_partial = abap_true )
                        ( order_id = '000000002000' priority = 2 allow_partial = abap_true ) ).
      baseline = service->simulate( orders ).
      summaries = NEW zcl_stock_order_summary( )->summarize( baseline ).
      WRITE / 'Order workflow demo: local samples only; no database or BAPI calls'.
      WRITE / 'Baseline: 10 ST of PART and 2 KG of FLUID'.
      LOOP AT summaries INTO DATA(summary).
        WRITE / |Order { summary-order_id }: { summary-status }, full { summary-full_count }, | &&
                |partial { summary-partial_count }, unfilled { summary-unfilled_count }|.
        LOOP AT summary-shortages INTO DATA(shortage).
          WRITE / |Shortage { shortage-request_id }: { shortage-shortage } { shortage-unit }|.
        ENDLOOP.
      ENDLOOP.
      samples->main_stock = 16.
      scenario = service->simulate( orders ).
      comparisons = NEW zcl_stock_alloc_comparison( )->compare( baseline = baseline
                                                               scenario  = scenario ).
      WRITE / 'Scenario: replenish PART to 16 ST'.
      LOOP AT comparisons INTO DATA(comparison).
        WRITE / |{ comparison-request_id }: { comparison-change }, | &&
                |delta { comparison-allocation_delta } { comparison-unit }|.
      ENDLOOP.
      issuer = NEW zcl_stock_reserved_checked( source       = samples
                                               writer       = preview
                                               stock_source = samples ).
      result = issuer->create( allocations   = scenario
                               posting_date  = '20260922'
                               document_date = '20260922' ).
      WRITE / |Checked preview: { preview->item_count } items, simulated { result-simulated }|.
      WRITE / result-messages[ 1 ]-message.
      samples->main_stock = 15.
      TRY.
          result = issuer->create( allocations   = scenario
                                   posting_date  = '20260922'
                                   document_date = '20260922' ).
          WRITE / 'Unexpected: reduced stock was accepted'.
        CATCH zcx_stock_alloc INTO error.
          WRITE / |Reduced stock: blocked; preview calls { preview->calls }|.
          WRITE / error->reason.
      ENDTRY.
    CATCH zcx_stock_alloc INTO error.
      WRITE / |Demo failed: { error->reason }|.
  ENDTRY.
