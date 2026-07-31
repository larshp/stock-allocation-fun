CLASS ltcl_stock_allocator DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS allocates_priority_first FOR TESTING.
    METHODS keeps_deterministic_order FOR TESTING.
    METHODS rejects_negative_stock FOR TESTING.
ENDCLASS.

CLASS ltcl_stock_allocator IMPLEMENTATION.
  METHOD allocates_priority_first.
    DATA lo_cut TYPE REF TO zif_stock_allocation.
    DATA lt_demands TYPE zif_stock_allocation=>tt_demands.
    DATA lv_remaining TYPE zif_stock_allocation=>ty_quantity.

    CREATE OBJECT lo_cut TYPE zcl_stock_allocator.
    APPEND VALUE #( order_id     = 'LOW'
                    priority     = 1
                    requested_on = '20260101'
                    requested    = '8' ) TO lt_demands.
    APPEND VALUE #( order_id     = 'HIGH'
                    priority     = 10
                    requested_on = '20260102'
                    requested    = '5' ) TO lt_demands.

    lv_remaining = lo_cut->allocate(
      EXPORTING
        iv_available = '7'
      CHANGING
        ct_demands   = lt_demands ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ order_id = 'HIGH' ]-allocated
      exp = '5' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ order_id = 'LOW' ]-allocated
      exp = '2' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_remaining
      exp = '0' ).
  ENDMETHOD.

  METHOD keeps_deterministic_order.
    DATA lo_cut TYPE REF TO zif_stock_allocation.
    DATA lt_demands TYPE zif_stock_allocation=>tt_demands.

    CREATE OBJECT lo_cut TYPE zcl_stock_allocator.
    APPEND VALUE #( order_id     = 'B'
                    priority     = 5
                    requested_on = '20260101'
                    requested    = '1' ) TO lt_demands.
    APPEND VALUE #( order_id     = 'A'
                    priority     = 5
                    requested_on = '20260101'
                    requested    = '1' ) TO lt_demands.
    lo_cut->allocate(
      EXPORTING
        iv_available = '1'
      CHANGING
        ct_demands   = lt_demands ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ 1 ]-order_id
      exp = 'A' ).
  ENDMETHOD.

  METHOD rejects_negative_stock.
    DATA lo_cut TYPE REF TO zif_stock_allocation.
    DATA lt_demands TYPE zif_stock_allocation=>tt_demands.
    DATA lv_raised TYPE abap_bool.

    CREATE OBJECT lo_cut TYPE zcl_stock_allocator.
    TRY.
        lo_cut->allocate(
          EXPORTING
            iv_available = '-1'
          CHANGING
            ct_demands   = lt_demands ).
      CATCH zcx_stock_allocation.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
  ENDMETHOD.
ENDCLASS.

CLASS lcl_stock_source_stub DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_stock_source.
ENDCLASS.

CLASS lcl_stock_source_stub IMPLEMENTATION.
  METHOD zif_stock_source~get_available.
    rv_available = '10'.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_order_source_stub DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_order_source.
ENDCLASS.

CLASS lcl_order_source_stub IMPLEMENTATION.
  METHOD zif_order_source~get_open_demands.
    APPEND VALUE #( order_id     = 'ORDER-1'
                    requested_on = '20260101'
                    requested    = '6' ) TO rt_demands.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_allocation_sink_stub DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_allocation_sink.
    METHODS was_saved RETURNING VALUE(rv_saved) TYPE abap_bool.
    METHODS reservation_id RETURNING VALUE(rv_id) TYPE zif_stock_allocation=>ty_order_id.
  PRIVATE SECTION.
    DATA mv_saved TYPE abap_bool.
    DATA mv_reservation_id TYPE zif_stock_allocation=>ty_order_id.
ENDCLASS.

CLASS lcl_allocation_sink_stub IMPLEMENTATION.
  METHOD zif_allocation_sink~save_allocations.
    mv_saved = abap_true.
    mv_reservation_id = it_demands[ 1 ]-reservation_id.
  ENDMETHOD.

  METHOD was_saved.
    rv_saved = mv_saved.
  ENDMETHOD.

  METHOD reservation_id.
    rv_id = mv_reservation_id.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_stock_reservation_stub DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_stock_reservation.
    METHODS was_called RETURNING VALUE(rv_called) TYPE abap_bool.
    METHODS quantity RETURNING VALUE(rv_quantity) TYPE zif_stock_allocation=>ty_quantity.
  PRIVATE SECTION.
    DATA mv_called TYPE abap_bool.
    DATA mv_quantity TYPE zif_stock_allocation=>ty_quantity.
ENDCLASS.

CLASS lcl_stock_reservation_stub IMPLEMENTATION.
  METHOD zif_stock_reservation~reserve.
    mv_called = abap_true.
    mv_quantity = iv_quantity.
    rv_document = 'RES-1'.
  ENDMETHOD.

  METHOD was_called.
    rv_called = mv_called.
  ENDMETHOD.

  METHOD quantity.
    rv_quantity = mv_quantity.
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_stock_allocation_service DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS allocates_and_persists FOR TESTING.
ENDCLASS.

CLASS ltcl_stock_allocation_service IMPLEMENTATION.
  METHOD allocates_and_persists.
    DATA lo_stock_source TYPE REF TO lcl_stock_source_stub.
    DATA lo_order_source TYPE REF TO lcl_order_source_stub.
    DATA lo_sink TYPE REF TO lcl_allocation_sink_stub.
    DATA lo_reservation TYPE REF TO lcl_stock_reservation_stub.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_remaining TYPE zif_stock_allocation=>ty_quantity.

    CREATE OBJECT lo_stock_source.
    CREATE OBJECT lo_order_source.
    CREATE OBJECT lo_sink.
    CREATE OBJECT lo_reservation.
    CREATE OBJECT lo_allocator TYPE zcl_stock_allocator.
    CREATE OBJECT lo_cut
      EXPORTING
        io_stock_source = lo_stock_source
        io_order_source = lo_order_source
        io_sink         = lo_sink
        io_allocator    = lo_allocator
        io_reservation  = lo_reservation.

    lv_remaining = lo_cut->allocate(
      iv_material         = 'MATERIAL-1'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_movement_type    = '201'
      iv_unit             = 'EA' ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_remaining
      exp = '4' ).
    cl_abap_unit_assert=>assert_true( lo_sink->was_saved( ) ).
    cl_abap_unit_assert=>assert_true( lo_reservation->was_called( ) ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_reservation->quantity( )
      exp = '6' ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_sink->reservation_id( )
      exp = 'RES-1' ).
  ENDMETHOD.
ENDCLASS.
