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
    METHODS selects_exact_locations FOR TESTING RAISING zcx_stock_alloc.
    METHODS retains_equal_quantities FOR TESTING RAISING zcx_stock_alloc.
    METHODS missing_locations FOR TESTING RAISING zcx_stock_alloc.
    METHODS rejects_blank_unit FOR TESTING.
    METHODS rejects_missing_bulk_master FOR TESTING.
ENDCLASS.

CLASS ltcl_source IMPLEMENTATION.
  METHOD selects_exact_locations.
    requests[ 1 ]-storage = '0002'.
    DATA(extra) = requests[ 1 ].
    extra-plant = '2000'.
    extra-storage = '0001'.
    APPEND extra TO requests.
    DATA(stocks) = source->read( requests ).
    cl_abap_unit_assert=>assert_equals( act = lines( stocks ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = stocks[ 1 ]-plant exp = '1000' ).
    cl_abap_unit_assert=>assert_equals( act = stocks[ 1 ]-storage exp = '0002' ).
    cl_abap_unit_assert=>assert_equals( act = stocks[ 1 ]-quantity exp = 25 ).
    cl_abap_unit_assert=>assert_equals( act = stocks[ 2 ]-plant exp = '2000' ).
    cl_abap_unit_assert=>assert_equals( act = stocks[ 2 ]-storage exp = '0001' ).
    cl_abap_unit_assert=>assert_equals( act = stocks[ 2 ]-quantity exp = 50 ).
  ENDMETHOD.

  METHOD retains_equal_quantities.
    DATA(extra) = requests[ 1 ].
    extra-storage = '0003'.
    APPEND extra TO requests.
    DATA(stocks) = source->read( requests ).
    cl_abap_unit_assert=>assert_equals( act = lines( stocks ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = stocks[ 1 ]-storage exp = '0001' ).
    cl_abap_unit_assert=>assert_equals( act = stocks[ 2 ]-storage exp = '0003' ).
    cl_abap_unit_assert=>assert_equals( act = stocks[ 1 ]-quantity exp = 10 ).
    cl_abap_unit_assert=>assert_equals( act = stocks[ 2 ]-quantity exp = 10 ).
  ENDMETHOD.

  METHOD missing_locations.
    requests[ 1 ]-storage = '9999'.
    cl_abap_unit_assert=>assert_initial( source->read( requests ) ).
    requests[ 1 ]-storage = '0001'.
    requests[ 1 ]-material = 'MISSING'.
    cl_abap_unit_assert=>assert_initial( source->read( requests ) ).
  ENDMETHOD.

  METHOD rejects_blank_unit.
    requests[ 1 ]-material = 'BLANK_UNIT'.
    TRY.
        source->read( requests ).
        cl_abap_unit_assert=>fail( 'Blank material unit accepted' ).
      CATCH zcx_stock_alloc.
    ENDTRY.
  ENDMETHOD.

  METHOD rejects_missing_bulk_master.
    DATA(extra) = requests[ 1 ].
    extra-material = 'NO_MASTER'.
    APPEND extra TO requests.
    TRY.
        source->read( requests ).
        cl_abap_unit_assert=>fail( 'Missing material among valid locations accepted' ).
      CATCH zcx_stock_alloc.
    ENDTRY.
  ENDMETHOD.

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
