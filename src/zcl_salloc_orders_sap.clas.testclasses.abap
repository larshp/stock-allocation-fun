CLASS ltcl_orders_sap DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS setup.
    METHODS reads_base_unit_open_demand FOR TESTING
      RAISING zcx_salloc_integration.
    METHODS save_accumulates_allocation FOR TESTING
      RAISING zcx_salloc_integration.
    METHODS reads_multiple_schedule_lines FOR TESTING
      RAISING zcx_salloc_integration.
    METHODS ignores_rejected_item FOR TESTING
      RAISING zcx_salloc_integration.
    METHODS ignores_non_order_document FOR TESTING
      RAISING zcx_salloc_integration.
ENDCLASS.

CLASS ltcl_orders_sap IMPLEMENTATION.
  METHOD setup.
    DELETE FROM vbak.
    DELETE FROM vbap.
    DELETE FROM vbep.
    DELETE FROM zsalloc_order.
  ENDMETHOD.

  METHOD reads_base_unit_open_demand.
    INSERT vbak FROM @( VALUE #(
      mandt = sy-mandt vbeln = '5000000001' vbtyp = 'C' audat = '20260701' ) ).
    INSERT vbap FROM @( VALUE #(
      mandt = sy-mandt vbeln = '5000000001' posnr = '000010'
      matnr = 'MAT-1' werks = '1000' ) ).
    INSERT vbep FROM @( VALUE #(
      mandt = sy-mandt vbeln = '5000000001' posnr = '000010'
      etenr = '0001' edatu = '20260715'
      wmeng = 1 lmeng = 10 bmeng = 2 ) ).
    INSERT zsalloc_order FROM @( VALUE #(
      mandt = sy-mandt order_id = '50000000010000100001'
      matnr = 'MAT-1' werks = '1000' requested = 8 allocated = 3
      shortage = 5 requested_on = '20260715' ) ).
    DATA(orders) = NEW zcl_salloc_orders_sap( ).

    DATA(demands) = orders->zif_salloc_orders~get_open_demands(
      iv_material = 'MAT-1'
      iv_plant = '1000' ).

    cl_abap_unit_assert=>assert_equals( act = lines( demands ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = demands[ 1 ]-order_id
      exp = '50000000010000100001' ).
    cl_abap_unit_assert=>assert_equals( act = demands[ 1 ]-requested exp = 5 ).
    cl_abap_unit_assert=>assert_equals(
      act = demands[ 1 ]-requested_on
      exp = '20260715' ).
  ENDMETHOD.

  METHOD save_accumulates_allocation.
    INSERT zsalloc_order FROM @( VALUE #(
      mandt = sy-mandt order_id = '50000000010000100001'
      matnr = 'MAT-1' werks = '1000' requested = 8 allocated = 3
      shortage = 5 requested_on = '20260701' ) ).
    DATA(demands) = VALUE zif_salloc_types=>tt_demands(
      ( order_id = '50000000010000100001' requested_on = '20260701'
        requested = 5 allocated = 2 shortage = 3 ) ).
    DATA(orders) = NEW zcl_salloc_orders_sap( ).

    orders->zif_salloc_orders~save_allocations(
      iv_material = 'MAT-1'
      iv_plant = '1000'
      it_demands = demands ).

    SELECT SINGLE requested, allocated, shortage
      FROM zsalloc_order
      WHERE order_id = '50000000010000100001'
      INTO @DATA(saved).
    cl_abap_unit_assert=>assert_equals( act = saved-requested exp = 8 ).
    cl_abap_unit_assert=>assert_equals( act = saved-allocated exp = 5 ).
    cl_abap_unit_assert=>assert_equals( act = saved-shortage exp = 3 ).
  ENDMETHOD.

  METHOD reads_multiple_schedule_lines.
    INSERT vbak FROM @( VALUE #(
      mandt = sy-mandt vbeln = '5000000001' vbtyp = 'C' ) ).
    INSERT vbap FROM @( VALUE #(
      mandt = sy-mandt vbeln = '5000000001' posnr = '000010'
      matnr = 'MAT-1' werks = '1000' ) ).
    DATA schedule_lines TYPE STANDARD TABLE OF vbep WITH EMPTY KEY.
    schedule_lines = VALUE #(
      ( mandt = sy-mandt vbeln = '5000000001' posnr = '000010'
        etenr = '0001' edatu = '20260715' wmeng = 2 lmeng = 4 )
      ( mandt = sy-mandt vbeln = '5000000001' posnr = '000010'
        etenr = '0002' edatu = '20260710' wmeng = 1 lmeng = 3 ) ).
    INSERT vbep FROM TABLE @schedule_lines.
    DATA(orders) = NEW zcl_salloc_orders_sap( ).

    DATA(demands) = orders->zif_salloc_orders~get_open_demands(
      iv_material = 'MAT-1'
      iv_plant = '1000' ).

    cl_abap_unit_assert=>assert_equals( act = lines( demands ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = demands[ order_id = '50000000010000100002' ]-requested_on
      exp = '20260710' ).
    cl_abap_unit_assert=>assert_equals(
      act = demands[ order_id = '50000000010000100001' ]-requested
      exp = 4 ).
  ENDMETHOD.

  METHOD ignores_rejected_item.
    INSERT vbak FROM @( VALUE #(
      mandt = sy-mandt vbeln = '5000000001' vbtyp = 'C' ) ).
    INSERT vbap FROM @( VALUE #(
      mandt = sy-mandt vbeln = '5000000001' posnr = '000010'
      matnr = 'MAT-1' werks = '1000' abgru = '01' ) ).
    INSERT vbep FROM @( VALUE #(
      mandt = sy-mandt vbeln = '5000000001' posnr = '000010'
      etenr = '0001' edatu = '20260715' lmeng = 10 ) ).
    DATA(orders) = NEW zcl_salloc_orders_sap( ).

    DATA(demands) = orders->zif_salloc_orders~get_open_demands(
      iv_material = 'MAT-1'
      iv_plant = '1000' ).

    cl_abap_unit_assert=>assert_initial( demands ).
  ENDMETHOD.

  METHOD ignores_non_order_document.
    INSERT vbak FROM @( VALUE #(
      mandt = sy-mandt vbeln = '5000000001' vbtyp = 'B' ) ).
    INSERT vbap FROM @( VALUE #(
      mandt = sy-mandt vbeln = '5000000001' posnr = '000010'
      matnr = 'MAT-1' werks = '1000' ) ).
    INSERT vbep FROM @( VALUE #(
      mandt = sy-mandt vbeln = '5000000001' posnr = '000010'
      etenr = '0001' edatu = '20260715' lmeng = 10 ) ).
    DATA(orders) = NEW zcl_salloc_orders_sap( ).

    DATA(demands) = orders->zif_salloc_orders~get_open_demands(
      iv_material = 'MAT-1'
      iv_plant = '1000' ).

    cl_abap_unit_assert=>assert_initial( demands ).
  ENDMETHOD.
ENDCLASS.
