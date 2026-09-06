CLASS ltcl_order_source DEFINITION FINAL FOR TESTING DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA source TYPE REF TO zif_stock_order_source.
    DATA orders TYPE zif_stock_order_source=>ty_orders.
    METHODS setup.
    METHODS reads_open_components FOR TESTING RAISING zcx_stock_alloc.
    METHODS filters_date_horizon FOR TESTING RAISING zcx_stock_alloc.
    METHODS excludes_other_orders FOR TESTING RAISING zcx_stock_alloc.
    METHODS rejects_duplicate_orders FOR TESTING.
    METHODS empty_orders FOR TESTING RAISING zcx_stock_alloc.
    METHODS allocates_order_demand FOR TESTING RAISING zcx_stock_alloc.
ENDCLASS.

CLASS ltcl_order_source IMPLEMENTATION.
  METHOD setup.
    source = NEW zcl_stock_order_source_sap( ).
    orders = VALUE #( ( order_id = '000000001000' priority = 5 allow_partial = abap_true ) ).
  ENDMETHOD.

  METHOD reads_open_components.
    DATA(requests) = source->read( orders ).
    cl_abap_unit_assert=>assert_equals( act = lines( requests )
                                        exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = requests[ 1 ]-quantity
                                        exp = 8 ).
    cl_abap_unit_assert=>assert_equals( act = requests[ 1 ]-request_id
                                        exp = '0000000100/0001/' ).
    cl_abap_unit_assert=>assert_equals( act = requests[ 1 ]-priority
                                        exp = 5 ).
    cl_abap_unit_assert=>assert_true( requests[ 1 ]-allow_partial ).
    cl_abap_unit_assert=>assert_equals( act = requests[ 1 ]-origin-order_id
                                      exp   = '000000001000' ).
    cl_abap_unit_assert=>assert_equals( act = requests[ 1 ]-origin-reservation
                                      exp   = '0000000100' ).
    cl_abap_unit_assert=>assert_equals( act = requests[ 1 ]-origin-reservation_item
                                      exp   = '0001' ).
  ENDMETHOD.

  METHOD filters_date_horizon.
    DATA(requests) = source->read( orders      = orders
                                  through_date = '20260906' ).
    cl_abap_unit_assert=>assert_equals( act = lines( requests )
                                        exp = 1 ).
  ENDMETHOD.

  METHOD excludes_other_orders.
    orders[ 1 ]-order_id = '000000002000'.
    DATA(requests) = source->read( orders ).
    cl_abap_unit_assert=>assert_equals( act = lines( requests )
                                        exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = requests[ 1 ]-quantity
                                        exp = 99 ).
  ENDMETHOD.

  METHOD rejects_duplicate_orders.
    APPEND orders[ 1 ] TO orders.
    TRY.
        source->read( orders ).
        cl_abap_unit_assert=>fail( 'Duplicate order accepted' ).
      CATCH zcx_stock_alloc.
    ENDTRY.
  ENDMETHOD.

  METHOD empty_orders.
    DATA(requests) = source->read( VALUE #( ) ).
    cl_abap_unit_assert=>assert_initial( requests ).
  ENDMETHOD.

  METHOD allocates_order_demand.
    DATA(service) = NEW zcl_stock_order_service( order_source = source
                                                stock_source  = NEW zcl_stock_source_sap( ) ).
    DATA(result) = service->simulate( orders ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-allocated
                                        exp = 8 ).
    cl_abap_unit_assert=>assert_equals( act = result[ 2 ]-allocated
                                        exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = result[ 2 ]-shortage
                                        exp = 4 ).
    cl_abap_unit_assert=>assert_equals( act = result[ 2 ]-origin-reservation_item
                                      exp   = '0002' ).
  ENDMETHOD.
ENDCLASS.
