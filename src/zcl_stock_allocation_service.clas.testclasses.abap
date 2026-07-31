CLASS ltcl_stock_allocation_service_sap DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS allocates_sap_vertical_slice FOR TESTING.
ENDCLASS.

CLASS ltcl_stock_allocation_service_sap IMPLEMENTATION.
  METHOD allocates_sap_vertical_slice.
    DATA lo_stock_source TYPE REF TO zif_stock_source.
    DATA lo_order_source TYPE REF TO zif_order_source.
    DATA lo_sink TYPE REF TO zif_allocation_sink.
    DATA lo_allocator TYPE REF TO zif_stock_allocation.
    DATA lo_reservation TYPE REF TO zif_stock_reservation.
    DATA lo_audit TYPE REF TO zif_allocation_audit.
    DATA lo_cut TYPE REF TO zcl_stock_allocation_service.
    DATA lv_remaining TYPE zif_stock_allocation=>ty_quantity.
    DATA lv_allocation_count TYPE i.
    DATA lv_reservation_id TYPE zif_stock_allocation=>ty_order_id.
    DATA lv_second_reservation_id TYPE zif_stock_allocation=>ty_order_id.
    DATA lv_rerun_reservation_id TYPE zif_stock_allocation=>ty_order_id.
    DATA lv_rerun_second_reservation_id TYPE zif_stock_allocation=>ty_order_id.
    DATA lv_changed_reservation_id TYPE zif_stock_allocation=>ty_order_id.
    DATA lv_changed_second_id TYPE zif_stock_allocation=>ty_order_id.
    DATA lv_reservations_differ TYPE abap_bool.
    DATA lv_run_count TYPE i.

    CREATE OBJECT lo_stock_source TYPE zcl_stock_source_sap.
    CREATE OBJECT lo_order_source TYPE zcl_order_source_sap.
    CREATE OBJECT lo_sink TYPE zcl_allocation_sink_sap.
    CREATE OBJECT lo_allocator TYPE zcl_stock_allocator.
    CREATE OBJECT lo_reservation TYPE zcl_stock_reservation_sap.
    CREATE OBJECT lo_audit TYPE zcl_allocation_audit_sap.
    CREATE OBJECT lo_cut
      EXPORTING
        io_stock_source = lo_stock_source
        io_order_source = lo_order_source
        io_sink         = lo_sink
        io_allocator    = lo_allocator
        io_reservation  = lo_reservation
        io_audit        = lo_audit.

    lv_remaining = lo_cut->allocate(
      iv_material         = 'MATERIAL-PRIO'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_movement_type    = '201'
      iv_unit             = 'EA' ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_remaining
      exp = '0' ).

    SELECT COUNT( * )
      FROM zstockalloc
      INTO @lv_allocation_count
      WHERE mandt = @sy-mandt
        AND matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'.
    cl_abap_unit_assert=>assert_equals(
      act = lv_allocation_count
      exp = 2 ).

    SELECT SINGLE reservation_id
      FROM zstockalloc
      INTO @lv_reservation_id
      WHERE mandt = @sy-mandt
        AND matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'
        AND order_id = 'PRIO0000010000100001'.
    cl_abap_unit_assert=>assert_not_initial( lv_reservation_id ).
    SELECT SINGLE reservation_id
      FROM zstockalloc
      INTO @lv_second_reservation_id
      WHERE mandt = @sy-mandt
        AND matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'
        AND order_id = 'PRIO0000010000100002'.
    cl_abap_unit_assert=>assert_not_initial( lv_second_reservation_id ).
    IF lv_reservation_id <> lv_second_reservation_id.
      lv_reservations_differ = abap_true.
    ENDIF.
    cl_abap_unit_assert=>assert_true( lv_reservations_differ ).

    lv_remaining = lo_cut->allocate(
      iv_material         = 'MATERIAL-PRIO'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_movement_type    = '201'
      iv_unit             = 'EA' ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_remaining
      exp = '0' ).
    SELECT SINGLE reservation_id
      FROM zstockalloc
      INTO @lv_rerun_reservation_id
      WHERE mandt = @sy-mandt
        AND matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'
        AND order_id = 'PRIO0000010000100001'.
    SELECT SINGLE reservation_id
      FROM zstockalloc
      INTO @lv_rerun_second_reservation_id
      WHERE mandt = @sy-mandt
        AND matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'
        AND order_id = 'PRIO0000010000100002'.
    cl_abap_unit_assert=>assert_equals(
      act = lv_rerun_reservation_id
      exp = lv_reservation_id ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_rerun_second_reservation_id
      exp = lv_second_reservation_id ).

    lv_remaining = lo_cut->allocate(
      iv_material         = 'MATERIAL-PRIO'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_movement_type    = '202'
      iv_unit             = 'EA' ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_remaining
      exp = '0' ).
    SELECT SINGLE reservation_id
      FROM zstockalloc
      INTO @lv_changed_reservation_id
      WHERE mandt = @sy-mandt
        AND matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'
        AND order_id = 'PRIO0000010000100001'.
    SELECT SINGLE reservation_id
      FROM zstockalloc
      INTO @lv_changed_second_id
      WHERE mandt = @sy-mandt
        AND matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'
        AND order_id = 'PRIO0000010000100002'.
    IF lv_changed_reservation_id = lv_reservation_id
        OR lv_changed_second_id = lv_second_reservation_id.
      lv_reservations_differ = abap_false.
    ELSE.
      lv_reservations_differ = abap_true.
    ENDIF.
    cl_abap_unit_assert=>assert_true( lv_reservations_differ ).

    SELECT COUNT( * )
      FROM zstockalloc_run
      INTO @lv_run_count
      WHERE mandt = @sy-mandt
        AND matnr = 'MATERIAL-PRIO'
        AND werks = '1000'
        AND lgort = '0001'
        AND status = 'S'.
    cl_abap_unit_assert=>assert_equals(
      act = lv_run_count
      exp = 3 ).
  ENDMETHOD.
ENDCLASS.
