CLASS lcl_stock_repository_double DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_stock_repository.
    METHODS set_stock
      IMPORTING
        iv_quantity TYPE mard-labst.
  PRIVATE SECTION.
    DATA mv_quantity TYPE mard-labst.
ENDCLASS.

CLASS lcl_stock_repository_double IMPLEMENTATION.
  METHOD set_stock.
    mv_quantity = iv_quantity.
  ENDMETHOD.

  METHOD zif_stock_repository~get_unrestricted_stock.
    rv_quantity = mv_quantity.
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_stock_service DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS returns_available_quantity FOR TESTING.
    METHODS returns_zero_when_no_stock FOR TESTING.
    METHODS allocates_requested_quantity FOR TESTING.
    METHODS reports_partial_shortfall FOR TESTING.
    METHODS negative_stock_is_unavailable FOR TESTING.
    METHODS rejects_negative_request FOR TESTING.
ENDCLASS.

CLASS ltcl_stock_service IMPLEMENTATION.
  METHOD returns_available_quantity.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).

    lo_repository->set_stock( iv_quantity = '17.250' ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '17.250' )
      act = lo_cut->get_unrestricted_stock(
        iv_material = 'MAT-1'
        iv_plant    = '1000' ) ).
  ENDMETHOD.

  METHOD returns_zero_when_no_stock.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( 0 )
      act = lo_cut->get_unrestricted_stock(
        iv_material = 'MAT-1'
        iv_plant    = '1000' ) ).
  ENDMETHOD.

  METHOD allocates_requested_quantity.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).

    lo_repository->set_stock( iv_quantity = '17.250' ).

    DATA(ls_allocation) = lo_cut->allocate_request(
      iv_material           = 'MAT-1'
      iv_plant              = '1000'
      iv_requested_quantity = '10.000' ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '17.250' )
      act = ls_allocation-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '10.000' )
      act = ls_allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( 0 )
      act = ls_allocation-shortfall_quantity ).
  ENDMETHOD.

  METHOD reports_partial_shortfall.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).

    lo_repository->set_stock( iv_quantity = '17.250' ).

    DATA(ls_allocation) = lo_cut->allocate_request(
      iv_material           = 'MAT-1'
      iv_plant              = '1000'
      iv_requested_quantity = '20.000' ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '17.250' )
      act = ls_allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.750' )
      act = ls_allocation-shortfall_quantity ).
  ENDMETHOD.

  METHOD negative_stock_is_unavailable.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).

    lo_repository->set_stock( iv_quantity = '-4.000' ).

    DATA(ls_allocation) = lo_cut->allocate_request(
      iv_material           = 'MAT-1'
      iv_plant              = '1000'
      iv_requested_quantity = '5.000' ).

    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( 0 )
      act = ls_allocation-available_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( 0 )
      act = ls_allocation-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = ls_allocation-shortfall_quantity ).
  ENDMETHOD.

  METHOD rejects_negative_request.
    DATA(lo_repository) = NEW lcl_stock_repository_double( ).
    DATA(lo_cut) = NEW zcl_stock_service(
      io_stock_repository = lo_repository ).
    DATA lv_exception_raised TYPE abap_bool.

    TRY.
        lo_cut->allocate_request(
          iv_material           = 'MAT-1'
          iv_plant              = '1000'
          iv_requested_quantity = '-1.000' ).
      CATCH zcx_invalid_stock_request.
        lv_exception_raised = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_exception_raised ).
  ENDMETHOD.
ENDCLASS.
