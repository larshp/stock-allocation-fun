CLASS ltcl_reserv_source DEFINITION FINAL FOR TESTING DURATION SHORT RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA source TYPE REF TO zif_stock_reservation_source.
    DATA references TYPE zif_stock_reservation_source=>ty_references.
    METHODS setup.
    METHODS reads_current_demand FOR TESTING RAISING zcx_stock_alloc.
    METHODS filters_closed_items FOR TESTING RAISING zcx_stock_alloc.
    METHODS keys_and_missing_items FOR TESTING RAISING zcx_stock_alloc.
    METHODS empty_and_duplicate_keys FOR TESTING RAISING zcx_stock_alloc.
    METHODS rejects_incomplete_keys FOR TESTING.
    METHODS manual_and_negative_demand FOR TESTING RAISING zcx_stock_alloc.
ENDCLASS.

CLASS ltcl_reserv_source IMPLEMENTATION.
  METHOD setup.
    source = NEW zcl_stock_reserv_source_sap( ).
    references = VALUE #( ( reservation = '0000000100' reservation_item = '0001' ) ).
  ENDMETHOD.

  METHOD reads_current_demand.
    DATA(requests) = source->read( references ).
    cl_abap_unit_assert=>assert_equals( act = lines( requests ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = requests[ 1 ]-quantity exp = 8 ).
    cl_abap_unit_assert=>assert_equals( act = requests[ 1 ]-material exp = 'MAT1' ).
    cl_abap_unit_assert=>assert_equals( act = requests[ 1 ]-required_date exp = '20260906' ).
    cl_abap_unit_assert=>assert_equals( act = requests[ 1 ]-origin-order_id exp = '000000001000' ).
    cl_abap_unit_assert=>assert_equals( act = requests[ 1 ]-origin-reservation_item exp = '0001' ).
  ENDMETHOD.

  METHOD filters_closed_items.
    CLEAR references.
    DO 9 TIMES.
      APPEND VALUE #( reservation = '0000000100' reservation_item = sy-index ) TO references.
    ENDDO.
    DATA(requests) = source->read( references ).
    cl_abap_unit_assert=>assert_equals( act = lines( requests ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = requests[ 1 ]-quantity exp = 8 ).
    cl_abap_unit_assert=>assert_equals( act = requests[ 2 ]-quantity exp = 6 ).
    cl_abap_unit_assert=>assert_equals( act = requests[ 3 ]-origin-order_id exp = '000000002000' ).
  ENDMETHOD.

  METHOD keys_and_missing_items.
    references[ 1 ]-reservation_type = '1'.
    cl_abap_unit_assert=>assert_initial( source->read( references ) ).
    CLEAR references[ 1 ]-reservation_type.
    references[ 1 ]-reservation_item = '0099'.
    cl_abap_unit_assert=>assert_initial( source->read( references ) ).
    references[ 1 ]-reservation_item = '0001'.
    references[ 1 ]-reservation = '9999999999'.
    cl_abap_unit_assert=>assert_initial( source->read( references ) ).
  ENDMETHOD.

  METHOD empty_and_duplicate_keys.
    cl_abap_unit_assert=>assert_initial( source->read( VALUE #( ) ) ).
    APPEND references[ 1 ] TO references.
    references[ 2 ]-order_id = 'UNTRUSTED'.
    DATA(requests) = source->read( references ).
    cl_abap_unit_assert=>assert_equals( act = lines( requests ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = requests[ 1 ]-origin-order_id exp = '000000001000' ).
  ENDMETHOD.

  METHOD rejects_incomplete_keys.
    APPEND VALUE #( reservation = '0000000100' ) TO references.
    TRY.
        source->read( references ).
        cl_abap_unit_assert=>fail( 'Incomplete reservation key accepted' ).
      CATCH zcx_stock_alloc.
    ENDTRY.
    references = VALUE #( ( ) ).
    TRY.
        source->read( references ).
        cl_abap_unit_assert=>fail( 'Empty reservation key accepted' ).
      CATCH zcx_stock_alloc.
    ENDTRY.
  ENDMETHOD.

  METHOD manual_and_negative_demand.
    references[ 1 ]-reservation = '0000000200'.
    DATA(requests) = source->read( references ).
    cl_abap_unit_assert=>assert_equals( act = requests[ 1 ]-quantity exp = '0.200' ).
    cl_abap_unit_assert=>assert_initial( requests[ 1 ]-origin-order_id ).
    references[ 1 ]-reservation_item = '0002'.
    TRY.
        source->read( references ).
        cl_abap_unit_assert=>fail( 'Negative reservation demand accepted' ).
      CATCH zcx_stock_alloc.
    ENDTRY.
  ENDMETHOD.
ENDCLASS.
