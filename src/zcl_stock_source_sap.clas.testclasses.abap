CLASS ltcl_source DEFINITION FINAL FOR TESTING DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA source TYPE REF TO zif_stock_source.
    DATA requests TYPE zif_stock_alloc_types=>ty_requests.
    METHODS setup.
    METHODS reads_selected_location FOR TESTING RAISING zcx_stock_alloc.
    METHODS empty_selection FOR TESTING RAISING zcx_stock_alloc.
    METHODS repeated_key FOR TESTING RAISING zcx_stock_alloc.
    METHODS negative_stock FOR TESTING RAISING zcx_stock_alloc.
    METHODS deleted_location FOR TESTING RAISING zcx_stock_alloc.
    METHODS missing_master FOR TESTING.
    METHODS service_simulation FOR TESTING RAISING zcx_stock_alloc.
    METHODS multiple_material_locations FOR TESTING RAISING zcx_stock_alloc.
ENDCLASS.

CLASS ltcl_source IMPLEMENTATION.
  METHOD setup.
    source = NEW zcl_stock_source_sap( ).
    requests = VALUE #( ( request_id = 'READ1' material = 'MAT1' plant = '1000'
                          storage = '0001' unit = 'EA' quantity = 12
                          required_date = '20260905' allow_partial = abap_true ) ).
  ENDMETHOD.

  METHOD reads_selected_location.
    DATA(stocks) = source->read( requests ).
    cl_abap_unit_assert=>assert_equals( act = lines( stocks )
                                       exp  = 1 ).
    cl_abap_unit_assert=>assert_equals( act = stocks[ 1 ]-quantity
                                       exp  = 10 ).
    cl_abap_unit_assert=>assert_equals( act = stocks[ 1 ]-unit
                                       exp  = 'EA' ).
  ENDMETHOD.

  METHOD empty_selection.
    DATA(stocks) = source->read( VALUE #( ) ).
    cl_abap_unit_assert=>assert_initial( stocks ).
  ENDMETHOD.

  METHOD repeated_key.
    APPEND requests[ 1 ] TO requests.
    DATA(stocks) = source->read( requests ).
    cl_abap_unit_assert=>assert_equals( act = lines( stocks )
                                       exp  = 1 ).
  ENDMETHOD.

  METHOD negative_stock.
    requests[ 1 ]-material = 'NEGATIVE'.
    DATA(stocks) = source->read( requests ).
    cl_abap_unit_assert=>assert_equals( act = stocks[ 1 ]-quantity
                                       exp  = 0 ).
  ENDMETHOD.

  METHOD deleted_location.
    requests[ 1 ]-material = 'DELETED'.
    DATA(stocks) = source->read( requests ).
    cl_abap_unit_assert=>assert_initial( stocks ).
  ENDMETHOD.

  METHOD missing_master.
    requests[ 1 ]-material = 'NO_MASTER'.
    TRY.
        source->read( requests ).
        cl_abap_unit_assert=>fail( 'Missing master data accepted' ).
      CATCH zcx_stock_alloc.
    ENDTRY.
  ENDMETHOD.

  METHOD service_simulation.
    DATA(service) = NEW zcl_stock_alloc_service( source ).
    DATA(result) = service->simulate( requests ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-allocated
                                       exp  = 10 ).
    cl_abap_unit_assert=>assert_equals( act = result[ 1 ]-shortage
                                       exp  = 2 ).
  ENDMETHOD.

  METHOD multiple_material_locations.
    DATA(extra) = requests[ 1 ].
    extra-storage = '0002'.
    APPEND extra TO requests.
    extra-storage = '0001'.
    extra-material = 'NEGATIVE'.
    APPEND extra TO requests.
    DATA(stocks) = source->read( requests ).
    cl_abap_unit_assert=>assert_equals( act = lines( stocks )
                                      exp   = 3 ).
    cl_abap_unit_assert=>assert_equals( act = stocks[ 1 ]-quantity
                                      exp   = 10 ).
    cl_abap_unit_assert=>assert_equals( act = stocks[ 2 ]-quantity
                                      exp   = 25 ).
    cl_abap_unit_assert=>assert_equals( act = stocks[ 2 ]-unit
                                      exp   = 'EA' ).
    cl_abap_unit_assert=>assert_equals( act = stocks[ 3 ]-unit
                                      exp   = 'KG' ).
  ENDMETHOD.
ENDCLASS.
