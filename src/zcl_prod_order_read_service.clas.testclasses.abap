CLASS lcl_prod_order_read_repo DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_prod_order_read_repo.
    DATA order_items TYPE zif_prod_order_read_repo=>ty_order_items.
    DATA order_statuses TYPE zif_prod_order_read_repo=>ty_order_statuses.
    DATA order_confirmations TYPE
      zif_prod_order_read_repo=>ty_order_confirmations.
    DATA order_operations TYPE zif_prod_order_read_repo=>ty_order_operations.
    DATA requested_orders TYPE zif_prod_order_read_repo=>ty_order_numbers.
    DATA requested_status_orders TYPE
      zif_prod_order_read_repo=>ty_order_numbers.
    DATA read_calls TYPE i.
    DATA status_read_calls TYPE i.
    DATA confirmation_read_calls TYPE i.
    DATA operation_read_calls TYPE i.
    DATA requested_confirmation_orders TYPE
      zif_prod_order_read_repo=>ty_order_numbers.
    DATA requested_operation_orders TYPE
      zif_prod_order_read_repo=>ty_order_numbers.
ENDCLASS.

CLASS lcl_prod_order_read_repo IMPLEMENTATION.
  METHOD zif_prod_order_read_repo~read_orders.
    ADD 1 TO read_calls.
    requested_orders = it_production_orders.
    rt_order_items = order_items.
  ENDMETHOD.

  METHOD zif_prod_order_read_repo~read_order_statuses.
    ADD 1 TO status_read_calls.
    requested_status_orders = it_production_orders.
    rt_statuses = order_statuses.
  ENDMETHOD.

  METHOD zif_prod_order_read_repo~read_confirmations.
    ADD 1 TO confirmation_read_calls.
    requested_confirmation_orders = it_production_orders.
    rt_confirmations = order_confirmations.
  ENDMETHOD.

  METHOD zif_prod_order_read_repo~read_operations.
    ADD 1 TO operation_read_calls.
    requested_operation_orders = it_production_orders.
    rt_operations = order_operations.
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_prod_order_read DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS reads_multiple_items_and_units FOR TESTING
      RAISING cx_static_check.
    METHODS reports_missing_or_bad_units FOR TESTING
      RAISING cx_static_check.
    METHODS validates_numbers_before_read FOR TESTING
      RAISING cx_static_check.
    METHODS empty_read_skips_repository FOR TESTING
      RAISING cx_static_check.
    METHODS reads_order_statuses FOR TESTING
      RAISING cx_static_check.
    METHODS reads_order_confirmations FOR TESTING
      RAISING cx_static_check.
    METHODS validates_confirmation_reads FOR TESTING
      RAISING cx_static_check.
    METHODS empty_confirmation_read FOR TESTING
      RAISING cx_static_check.
    METHODS reads_order_operations FOR TESTING
      RAISING cx_static_check.
    METHODS validates_operation_reads FOR TESTING
      RAISING cx_static_check.
    METHODS empty_operation_read FOR TESTING
      RAISING cx_static_check.
ENDCLASS.

CLASS ltcl_prod_order_read IMPLEMENTATION.
  METHOD reads_multiple_items_and_units.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    lo_repository->order_items = VALUE #(
      ( production_order          = '0000000002'
        production_item           = '0002'
        material                  = 'MAT-BY'
        plant                     = '1000'
        order_unit                = 'CS'
        base_unit                 = 'EA'
        order_quantity            = '5.000'
        received_quantity         = '1.000'
        order_to_base_numerator   = 12
        order_to_base_denominator = 1
        receipt_expected          = abap_true )
      ( production_order          = '0000000001'
        production_item           = '0001'
        material                  = 'MAT-A'
        plant                     = '2000'
        order_unit                = 'KG'
        base_unit                 = 'KG'
        order_quantity            = '2.000'
        received_quantity         = '0.500'
        order_to_base_numerator   = 1
        order_to_base_denominator = 1
        phase_1_indicator         = abap_true )
      ( production_order          = '0000000002'
        production_item           = '0003'
        material                  = 'MAT-C'
        plant                     = '1000'
        order_unit                = 'EA'
        base_unit                 = 'EA'
        order_quantity            = '3.000'
        received_quantity         = '3.000'
        order_to_base_numerator   = 12
        order_to_base_denominator = 1 ) ).
    DATA(lo_cut) = NEW zcl_prod_order_read_service( lo_repository ).

    DATA(ls_result) = lo_cut->read_orders_bulk(
      it_production_orders = VALUE #(
        ( '0000000001' )
        ( '0000000002' ) ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->read_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-found_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-production_order
      exp = '0000000001' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( ls_result-orders[ 2 ]-items )
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-items[ 1 ]-order_quantity_base
      exp = CONV decfloat34( '60.000' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-items[ 1 ]-received_quantity_base
      exp = CONV decfloat34( '12.000' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-items[ 1 ]-open_quantity_base
      exp = CONV decfloat34( '48.000' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-items[ 2 ]-open_quantity_base
      exp = CONV decfloat34( 0 ) ).
    cl_abap_unit_assert=>assert_true(
      ls_result-orders[ 2 ]-items[ 1 ]-is_quantity_converted ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->status_read_calls
      exp = 1 ).
  ENDMETHOD.

  METHOD reads_order_statuses.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    lo_repository->order_items = VALUE #(
      ( production_order          = '0000000001'
        production_item           = '0001'
        order_unit                = 'EA'
        base_unit                 = 'EA'
        order_quantity            = 1
        received_quantity         = 0
        order_to_base_numerator   = 1
        order_to_base_denominator = 1 )
      ( production_order          = '0000000002'
        production_item           = '0001'
        order_unit                = 'EA'
        base_unit                 = 'EA'
        order_quantity            = 1
        received_quantity         = 0
        order_to_base_numerator   = 1
        order_to_base_denominator = 1 ) ).
    lo_repository->order_statuses = VALUE #(
      ( production_order  = '0000000002'
        status_code       = 'E0001'
        status_profile    = 'ZPROD'
        is_user_status    = abap_true
        status_short_name = 'HOLD'
        status_name       = 'Material hold' )
      ( production_order  = '0000000001'
        status_code       = 'I0002'
        is_user_status    = abap_false
        status_short_name = 'REL'
        status_name       = 'Released' )
      ( production_order  = '0000000002'
        status_code       = 'I0001'
        is_user_status    = abap_false
        status_short_name = 'CRTD'
        status_name       = 'Created' ) ).
    DATA(lo_cut) = NEW zcl_prod_order_read_service( lo_repository ).

    DATA(ls_result) = lo_cut->read_orders_bulk(
      it_production_orders = VALUE #(
        ( '0000000001' )
        ( '0000000002' ) ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->status_read_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->requested_status_orders[ 2 ]
      exp = '0000000002' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( ls_result-orders[ 1 ]-statuses )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-statuses[ 1 ]-status_code
      exp = 'I0002' ).
    cl_abap_unit_assert=>assert_false(
      ls_result-orders[ 1 ]-statuses[ 1 ]-is_user_status ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-statuses[ 1 ]-status_name
      exp = 'Released' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( ls_result-orders[ 2 ]-statuses )
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-statuses[ 1 ]-status_code
      exp = 'E0001' ).
    cl_abap_unit_assert=>assert_true(
      ls_result-orders[ 2 ]-statuses[ 1 ]-is_user_status ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-statuses[ 1 ]-status_short_name
      exp = 'HOLD' ).
  ENDMETHOD.

  METHOD reports_missing_or_bad_units.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    lo_repository->order_items = VALUE #(
      ( production_order          = '0000000001'
        production_item           = '0001'
        material                  = 'MAT-A'
        plant                     = '1000'
        order_quantity            = '2.000'
        received_quantity         = '0.000'
        order_to_base_numerator   = 1
        order_to_base_denominator = 1 )
      ( production_order          = '0000000001'
        production_item           = '0002'
        material                  = 'MAT-B'
        plant                     = '1000'
        order_unit                = 'CS'
        base_unit                 = 'EA'
        order_quantity            = '2.000'
        received_quantity         = '0.000'
        order_to_base_numerator   = 0
        order_to_base_denominator = 1 ) ).
    DATA(lo_cut) = NEW zcl_prod_order_read_service( lo_repository ).

    DATA(ls_result) = lo_cut->read_orders_bulk(
      it_production_orders = VALUE #(
        ( '0000000001' )
        ( '0000000002' ) ) ).

    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-not_found_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-conversion_failed_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_true( ls_result-orders[ 1 ]-is_found ).
    cl_abap_unit_assert=>assert_false( ls_result-orders[ 2 ]-is_found ).
    cl_abap_unit_assert=>assert_false(
      ls_result-orders[ 1 ]-items[ 1 ]-is_quantity_converted ).
  ENDMETHOD.

  METHOD validates_numbers_before_read.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    DATA(lo_cut) = NEW zcl_prod_order_read_service( lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->read_orders_bulk(
          it_production_orders = VALUE #(
            ( '0000000001' )
            ( '0000000001' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->read_calls
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->status_read_calls
      exp = 0 ).

    CLEAR lv_raised.
    TRY.
        lo_cut->read_orders_bulk(
          it_production_orders = VALUE #(
            ( '0000000001' )
            ( ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->read_calls
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->status_read_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD empty_read_skips_repository.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    DATA(lo_cut) = NEW zcl_prod_order_read_service( lo_repository ).

    DATA(ls_result) = lo_cut->read_orders_bulk(
      it_production_orders = VALUE #( ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_initial( ls_result-orders ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->read_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD reads_order_confirmations.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    lo_repository->order_confirmations = VALUE #(
      ( production_order     = '0000000002'
        operation_number     = '0020'
        operation_sequence   = '000000'
        confirmation         = '0000000003'
        confirmation_counter = '00000001'
        posting_date         = '20261011'
        is_reversed          = 'X' )
      ( production_order     = '0000000001'
        operation_number     = '0010'
        operation_sequence   = '000000'
        confirmation         = '0000000001'
        confirmation_counter = '00000001'
        posting_date         = '20261009' )
      ( production_order     = '0000000002'
        operation_number     = '0020'
        operation_sequence   = '000000'
        confirmation         = '0000000002'
        confirmation_counter = '00000002'
        posting_date         = '20261010'
        is_final             = 'X' ) ).
    DATA(lo_cut) = NEW zcl_prod_order_read_service( lo_repository ).

    DATA(ls_result) = lo_cut->read_confirmations_bulk(
      it_production_orders = VALUE #(
        ( '0000000001' )
        ( '0000000002' ) ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->confirmation_read_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->requested_confirmation_orders[ 2 ]
      exp = '0000000002' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-found_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-empty_count
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-production_order
      exp = '0000000001' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-confirmations[ 1 ]-confirmation
      exp = '0000000001' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( ls_result-orders[ 2 ]-confirmations )
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-confirmations[ 1 ]-confirmation
      exp = '0000000003' ).
    cl_abap_unit_assert=>assert_true(
      ls_result-orders[ 2 ]-confirmations[ 1 ]-is_reversed ).
    cl_abap_unit_assert=>assert_true(
      ls_result-orders[ 2 ]-confirmations[ 2 ]-is_final ).
  ENDMETHOD.

  METHOD validates_confirmation_reads.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    DATA(lo_cut) = NEW zcl_prod_order_read_service( lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->read_confirmations_bulk(
          it_production_orders = VALUE #(
            ( '0000000001' )
            ( '0000000001' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->confirmation_read_calls
      exp = 0 ).

    lo_repository->order_confirmations = VALUE #(
      ( production_order     = '0000000002'
        confirmation         = '0000000001'
        confirmation_counter = '00000001' ) ).
    CLEAR lv_raised.
    TRY.
        lo_cut->read_confirmations_bulk(
          it_production_orders = VALUE #( ( '0000000001' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->confirmation_read_calls
      exp = 1 ).

    lo_repository->order_confirmations = VALUE #(
      ( production_order     = '0000000001'
        confirmation         = '0000000001'
        confirmation_counter = '00000001' )
      ( production_order     = '0000000001'
        confirmation         = '0000000001'
        confirmation_counter = '00000001' ) ).
    CLEAR lv_raised.
    TRY.
        lo_cut->read_confirmations_bulk(
          it_production_orders = VALUE #( ( '0000000001' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
  ENDMETHOD.

  METHOD empty_confirmation_read.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    DATA(lo_cut) = NEW zcl_prod_order_read_service( lo_repository ).

    DATA(ls_result) = lo_cut->read_confirmations_bulk(
      it_production_orders = VALUE #( ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_initial( ls_result-orders ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->confirmation_read_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD reads_order_operations.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    lo_repository->order_operations = VALUE #(
      ( production_order      = '0000000001'
        operation_counter     = '00000001'
        operation_sequence    = '000000'
        operation_number      = '0010'
        suboperation_number   = '0010'
        operation_description = 'Prepare'
        control_key           = 'PP02' )
      ( production_order      = '0000000002'
        operation_counter     = '00000001'
        operation_sequence    = '000000'
        operation_number      = '0010'
        operation_description = 'Cut'
        control_key           = 'PP01' )
      ( production_order      = '0000000002'
        operation_counter     = '00000002'
        operation_sequence    = '000001'
        operation_number      = '0020'
        operation_description = 'Assembly'
        control_key           = 'PP01' ) ).
    DATA(lo_cut) = NEW zcl_prod_order_read_service( lo_repository ).

    DATA(ls_result) = lo_cut->read_operations_bulk(
      it_production_orders = VALUE #(
        ( '0000000001' )
        ( '0000000002' )
        ( '0000000003' ) ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->operation_read_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->requested_operation_orders[ 2 ]
      exp = '0000000002' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-found_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-empty_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-production_order
      exp = '0000000001' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-operations[ 1 ]-operation_number
      exp = '0010' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-operations[ 1 ]-suboperation_number
      exp = '0010' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-operations[ 1 ]-operation_description
      exp = 'Prepare' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-operations[ 1 ]-control_key
      exp = 'PP02' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( ls_result-orders[ 2 ]-operations )
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-operations[ 1 ]-operation_number
      exp = '0010' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-operations[ 2 ]-operation_number
      exp = '0020' ).
    cl_abap_unit_assert=>assert_false(
      ls_result-orders[ 3 ]-is_found ).
  ENDMETHOD.

  METHOD validates_operation_reads.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    DATA(lo_cut) = NEW zcl_prod_order_read_service( lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->read_operations_bulk(
          it_production_orders = VALUE #(
            ( '0000000001' )
            ( '0000000001' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->operation_read_calls
      exp = 0 ).

    lo_repository->order_operations = VALUE #(
      ( production_order  = '0000000002'
        operation_counter = '00000001'
        operation_number  = '0010' ) ).
    CLEAR lv_raised.
    TRY.
        lo_cut->read_operations_bulk(
          it_production_orders = VALUE #( ( '0000000001' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).

    lo_repository->order_operations = VALUE #(
      ( production_order  = '0000000001'
        operation_counter = '00000001'
        operation_number  = '0010' )
      ( production_order  = '0000000001'
        operation_counter = '00000001'
        operation_number  = '0020' ) ).
    CLEAR lv_raised.
    TRY.
        lo_cut->read_operations_bulk(
          it_production_orders = VALUE #( ( '0000000001' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_true( lv_raised ).
  ENDMETHOD.

  METHOD empty_operation_read.
    DATA(lo_repository) = NEW lcl_prod_order_read_repo( ).
    DATA(lo_cut) = NEW zcl_prod_order_read_service( lo_repository ).

    DATA(ls_result) = lo_cut->read_operations_bulk(
      it_production_orders = VALUE #( ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_initial( ls_result-orders ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->operation_read_calls
      exp = 0 ).
  ENDMETHOD.
ENDCLASS.
