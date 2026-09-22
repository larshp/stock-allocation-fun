CLASS lcl_raw_source DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_stock_source.
    DATA stocks TYPE zif_stock_alloc_types=>ty_stocks.
ENDCLASS.

CLASS lcl_raw_source IMPLEMENTATION.
  METHOD zif_stock_source~read.
    stocks = me->stocks.
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_adjusted DEFINITION FINAL FOR TESTING DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA source TYPE REF TO lcl_raw_source.
    DATA adjustments TYPE zif_stock_alloc_types=>ty_stocks.
    METHODS setup.
    METHODS applies_to_matching_location FOR TESTING RAISING zcx_stock_alloc.
    METHODS rejects_unit_mismatch FOR TESTING.
    METHODS rejects_stacked_adjustments FOR TESTING.
    METHODS rejects_quantity_override FOR TESTING.
ENDCLASS.

CLASS ltcl_adjusted IMPLEMENTATION.
  METHOD setup.
    source = NEW #( ).
    source->stocks = VALUE #( ( material = 'MAT1' plant = '1000' storage = '0001'
                                unit = 'EA' quantity = 10 )
                              ( material = 'MAT1' plant = '1000' storage = '0002'
                                unit = 'EA' quantity = 20 ) ).
    adjustments = VALUE #( ( material = 'MAT1' plant = '1000' storage = '0001'
                              unit = 'EA' safety_stock = 2 committed = 3 ) ).
  ENDMETHOD.

  METHOD applies_to_matching_location.
    DATA adjusted TYPE REF TO zif_stock_source.
    adjusted = NEW zcl_stock_source_adjusted( source     = source
                                             adjustments = adjustments ).
    DATA(stocks) = adjusted->read( VALUE #( ) ).
    cl_abap_unit_assert=>assert_equals( act = stocks[ 1 ]-quantity
                                        exp = 10 ).
    cl_abap_unit_assert=>assert_equals( act = stocks[ 1 ]-committed
                                        exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = stocks[ 1 ]-safety_stock
                                        exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = stocks[ 2 ]-committed
                                        exp = 0 ).
    cl_abap_unit_assert=>assert_equals( act = source->stocks[ 1 ]-committed
                                        exp = 0 ).
  ENDMETHOD.

  METHOD rejects_unit_mismatch.
    adjustments[ 1 ]-unit = 'KG'.
    TRY.
        DATA adjusted TYPE REF TO zif_stock_source.
        adjusted = NEW zcl_stock_source_adjusted( source     = source
                                                 adjustments = adjustments ).
        adjusted->read( VALUE #( ) ).
        cl_abap_unit_assert=>fail( 'Mixed adjustment units accepted' ).
      CATCH zcx_stock_alloc.
    ENDTRY.
  ENDMETHOD.

  METHOD rejects_stacked_adjustments.
    source->stocks[ 1 ]-committed = 1.
    TRY.
        DATA adjusted TYPE REF TO zif_stock_source.
        adjusted = NEW zcl_stock_source_adjusted( source     = source
                                                 adjustments = adjustments ).
        adjusted->read( VALUE #( ) ).
        cl_abap_unit_assert=>fail( 'Existing commitments silently overwritten' ).
      CATCH zcx_stock_alloc.
    ENDTRY.
  ENDMETHOD.

  METHOD rejects_quantity_override.
    adjustments[ 1 ]-quantity = 100.
    TRY.
        DATA(adjusted) = NEW zcl_stock_source_adjusted( source     = source
                                                       adjustments = adjustments ).
        cl_abap_unit_assert=>fail( 'Adjustment tried to override physical stock' ).
      CATCH zcx_stock_alloc.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
