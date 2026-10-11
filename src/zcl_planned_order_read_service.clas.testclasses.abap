CLASS lcl_planned_order_read_repo DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_planned_order_read_repo.
    DATA orders TYPE zif_planned_order_read_repo=>ty_order_headers.
    DATA requested_orders TYPE zif_planned_order_read_repo=>ty_order_numbers.
    DATA read_calls TYPE i.
ENDCLASS.

CLASS lcl_planned_order_read_repo IMPLEMENTATION.
  METHOD zif_planned_order_read_repo~read_orders.
    ADD 1 TO read_calls.
    requested_orders = it_planned_orders.
    rt_orders = orders.
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_planned_order_read DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS reads_in_request_order FOR TESTING
      RAISING cx_static_check.
    METHODS reports_missing_order FOR TESTING
      RAISING cx_static_check.
    METHODS reports_missing_unit_ratio FOR TESTING
      RAISING cx_static_check.
    METHODS validates_numbers_before_read FOR TESTING
      RAISING cx_static_check.
    METHODS empty_read_skips_repository FOR TESTING
      RAISING cx_static_check.
ENDCLASS.

CLASS ltcl_planned_order_read IMPLEMENTATION.
  METHOD reads_in_request_order.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    lo_repository->orders = VALUE #(
      ( planned_order            = '0000000002'
        material                 = 'MAT-2'
        plant                    = '1000'
        quantity                 = '3.000'
        order_unit               = 'CS'
        base_unit                = 'EA'
        unit_to_base_numerator   = 12
        unit_to_base_denominator = 1 )
      ( planned_order   = '0000000001'
        material        = 'MAT-1'
        plant           = '2000'
        quantity        = '2.000'
        order_unit      = 'EA'
        base_unit       = 'EA'
        fixed_indicator = abap_true ) ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).

    DATA(ls_result) = lo_cut->read_orders_bulk(
      it_planned_orders = VALUE #(
        ( '0000000001' )
        ( '0000000002' ) ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-found_count
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->read_calls
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->requested_orders[ 2 ]
      exp = '0000000002' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-planned_order
      exp = '0000000001' ).
    cl_abap_unit_assert=>assert_true(
      ls_result-orders[ 1 ]-order_header-fixed_indicator ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-quantity_in_base_unit
      exp = CONV decfloat34( '2.000' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-quantity_in_base_unit
      exp = CONV decfloat34( '36.000' ) ).
    cl_abap_unit_assert=>assert_true(
      ls_result-orders[ 2 ]-is_quantity_converted ).
  ENDMETHOD.

  METHOD reports_missing_order.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    lo_repository->orders = VALUE #(
      ( planned_order = '0000000001'
        material      = 'MAT-1'
        plant         = '1000'
        quantity      = '2.000'
        order_unit    = 'EA'
        base_unit     = 'EA' ) ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).

    DATA(ls_result) = lo_cut->read_orders_bulk(
      it_planned_orders = VALUE #(
        ( '0000000001' )
        ( '0000000002' ) ) ).

    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-not_found_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_true( ls_result-orders[ 1 ]-is_found ).
    cl_abap_unit_assert=>assert_false( ls_result-orders[ 2 ]-is_found ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-request_index
      exp = 2 ).
  ENDMETHOD.

  METHOD reports_missing_unit_ratio.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    lo_repository->orders = VALUE #(
      ( planned_order = '0000000001'
        material      = 'MAT-1'
        plant         = '1000'
        quantity      = '5.000'
        order_unit    = 'BOX'
        base_unit     = 'EA' ) ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).

    DATA(ls_result) = lo_cut->read_orders_bulk(
      it_planned_orders = VALUE #( ( '0000000001' ) ) ).

    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-conversion_failed_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_true( ls_result-orders[ 1 ]-is_found ).
    cl_abap_unit_assert=>assert_false(
      ls_result-orders[ 1 ]-is_quantity_converted ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-order_header-quantity
      exp = '5.000' ).
  ENDMETHOD.

  METHOD validates_numbers_before_read.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).
    DATA lv_raised TYPE abap_bool.

    TRY.
        lo_cut->read_orders_bulk(
          it_planned_orders = VALUE #(
            ( '0000000001' )
            ( '0000000001' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->read_calls
      exp = 0 ).

    CLEAR lv_raised.
    TRY.
        lo_cut->read_orders_bulk(
          it_planned_orders = VALUE #(
            ( '0000000001' )
            ( ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->read_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD empty_read_skips_repository.
    DATA(lo_repository) = NEW lcl_planned_order_read_repo( ).
    DATA(lo_cut) = NEW zcl_planned_order_read_service( lo_repository ).

    DATA(ls_result) = lo_cut->read_orders_bulk(
      it_planned_orders = VALUE #( ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_initial( ls_result-orders ).
    cl_abap_unit_assert=>assert_equals(
      act = lo_repository->read_calls
      exp = 0 ).
  ENDMETHOD.
ENDCLASS.
