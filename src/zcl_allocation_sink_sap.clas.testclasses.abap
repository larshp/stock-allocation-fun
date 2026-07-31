CLASS ltcl_allocation_sink_sap DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS persists_allocation FOR TESTING.
ENDCLASS.

CLASS ltcl_allocation_sink_sap IMPLEMENTATION.
  METHOD persists_allocation.
    DATA lo_cut TYPE REF TO zif_allocation_sink.
    DATA lt_demands TYPE zif_stock_allocation=>tt_demands.
    DATA lv_order_id TYPE c LENGTH 20.
    DATA lv_reservation_id TYPE c LENGTH 20.
    DATA lv_allocation_status TYPE c LENGTH 1.
    DATA lv_sales_document TYPE c LENGTH 10.
    DATA lv_sales_document_type TYPE c LENGTH 4.
    DATA lv_sales_item TYPE n LENGTH 6.
    DATA lv_schedule_line TYPE n LENGTH 4.
    DATA lv_order_unit TYPE c LENGTH 3.
    DATA lv_allocation_unit TYPE c LENGTH 3.
    DATA lv_batch TYPE c LENGTH 10.
    DATA lv_run_id TYPE c LENGTH 32.

    CREATE OBJECT lo_cut TYPE zcl_allocation_sink_sap.
    APPEND VALUE #( order_id  = 'STALE'
                    requested = '1' ) TO lt_demands.
    lo_cut->save_allocations(
      iv_material         = 'MATERIAL-DB'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_batch            = 'BATCH-001'
      iv_run_id           = 'RUN-STALE'
      iv_unit             = 'EA'
      it_demands          = lt_demands ).

    CLEAR lt_demands.
    APPEND VALUE #( order_id  = 'OTHER-LOC'
                    requested = '2' ) TO lt_demands.
    lo_cut->save_allocations(
      iv_material         = 'MATERIAL-DB'
      iv_plant            = '1000'
      iv_storage_location = '0002'
      iv_run_id           = 'RUN-OTHER'
      iv_unit             = 'EA'
      it_demands          = lt_demands ).

    CLEAR lt_demands.
    APPEND VALUE #( sales_document      = 'ORDER-DB01'
                    sales_document_type = 'OR'
                    sales_item          = '000010'
                    schedule_line       = '0001'
                    order_unit          = 'EA'
                    order_id            = 'ORDER-DB'
                    requested           = '5'
                    allocated           = '4'
                    shortage            = '1'
                    allocation_status   = 'P'
                    reservation_id      = 'RES-DB' ) TO lt_demands.

    lo_cut->save_allocations(
      iv_material         = 'MATERIAL-DB'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_batch            = 'BATCH-001'
      iv_run_id           = 'RUN-DB'
      iv_unit             = 'EA'
      it_demands          = lt_demands ).

    SELECT SINGLE run_id, batch, allocation_unit, sales_document, sales_document_type,
                  sales_item, schedule_line, order_unit,
                  order_id, reservation_id, allocation_status
      FROM zstockalloc
      INTO (@lv_run_id, @lv_batch, @lv_allocation_unit, @lv_sales_document, @lv_sales_document_type,
            @lv_sales_item, @lv_schedule_line, @lv_order_unit,
            @lv_order_id, @lv_reservation_id, @lv_allocation_status)
      WHERE matnr = 'MATERIAL-DB'
        AND werks = '1000'
        AND lgort = '0001'
        AND batch = 'BATCH-001'.

    cl_abap_unit_assert=>assert_equals(
      act = lv_run_id
      exp = 'RUN-DB' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_batch
      exp = 'BATCH-001' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_allocation_unit
      exp = 'EA' ).

    cl_abap_unit_assert=>assert_equals(
      act = lv_order_id
      exp = 'ORDER-DB' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_sales_document
      exp = 'ORDER-DB01' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_sales_document_type
      exp = 'OR' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_sales_item
      exp = '000010' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_schedule_line
      exp = '0001' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_order_unit
      exp = 'EA' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_reservation_id
      exp = 'RES-DB' ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_allocation_status
      exp = 'P' ).

    CLEAR lt_demands.
    APPEND VALUE #( order_id          = 'ORDER-DB'
                    requested         = '3'
                    allocated         = '3'
                    allocation_status = 'F' ) TO lt_demands.
    lo_cut->save_allocations(
      iv_material         = 'MATERIAL-DB'
      iv_plant            = '1000'
      iv_storage_location = '0001'
      iv_batch            = 'BATCH-001'
      iv_run_id           = 'RUN-BOX'
      iv_unit             = 'BOX'
      it_demands          = lt_demands ).

    SELECT COUNT( * )
      FROM zstockalloc
      INTO @DATA(lv_unit_count)
      WHERE mandt = @sy-mandt
        AND matnr = 'MATERIAL-DB'
        AND werks = '1000'
        AND lgort = '0001'
        AND batch = 'BATCH-001'
        AND order_id = 'ORDER-DB'.
    cl_abap_unit_assert=>assert_equals(
      act = lv_unit_count
      exp = 2 ).

    SELECT COUNT( * )
      FROM zstockalloc
      INTO @DATA(lv_stale_count)
      WHERE mandt = @sy-mandt
        AND matnr = 'MATERIAL-DB'
        AND werks = '1000'
        AND lgort = '0001'
        AND batch = 'BATCH-001'
        AND order_id = 'STALE'.
    cl_abap_unit_assert=>assert_equals(
      act = lv_stale_count
      exp = 0 ).

    SELECT COUNT( * )
      FROM zstockalloc
      INTO @DATA(lv_other_location_count)
      WHERE mandt = @sy-mandt
        AND matnr = 'MATERIAL-DB'
        AND werks = '1000'
        AND lgort = '0002'.
    cl_abap_unit_assert=>assert_equals(
      act = lv_other_location_count
      exp = 1 ).
  ENDMETHOD.
ENDCLASS.
