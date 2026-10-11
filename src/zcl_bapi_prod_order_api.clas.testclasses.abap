CLASS ltcl_bapi_prod_order_api DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS maps_create_order_request FOR TESTING
      RAISING cx_static_check.
    METHODS maps_create_order_result FOR TESTING
      RAISING cx_static_check.
    METHODS maps_release_detail_errors FOR TESTING
      RAISING cx_static_check.
    METHODS maps_release_global_error FOR TESTING
      RAISING cx_static_check.
    METHODS maps_operation_release_errors FOR TESTING
      RAISING cx_static_check.
    METHODS maps_confirmation_cancel FOR TESTING
      RAISING cx_static_check.
    METHODS maps_confirmation_create FOR TESTING
      RAISING cx_static_check.
    METHODS maps_confirmation_create_error FOR TESTING
      RAISING cx_static_check.
    METHODS maps_technical_completion FOR TESTING
      RAISING cx_static_check.
    METHODS maps_deletion_flag FOR TESTING
      RAISING cx_static_check.
    METHODS maps_close_order FOR TESTING
      RAISING cx_static_check.
    METHODS maps_deletion_indicator FOR TESTING
      RAISING cx_static_check.
    METHODS maps_change_request FOR TESTING
      RAISING cx_static_check.
    METHODS maps_change_error FOR TESTING
      RAISING cx_static_check.
ENDCLASS.

CLASS ltcl_bapi_prod_order_api IMPLEMENTATION.
  METHOD maps_create_order_request.
    DATA(ls_orderdata) = zcl_bapi_prod_order_api=>map_create_order_request(
      is_request = VALUE #(
        order_number      = '0000000101'
        material          = 'MAT-1'
        plant             = '1000'
        planning_plant    = '2000'
        order_type        = 'PP01'
        basic_start_date  = '20261011'
        basic_finish_date = '20261012'
        quantity          = '12.500'
        quantity_uom      = 'EA' ) ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_orderdata-order_number
      exp = '0000000101' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_orderdata-material
      exp = 'MAT-1' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_orderdata-plant
      exp = '1000' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_orderdata-planning_plant
      exp = '2000' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_orderdata-order_type
      exp = 'PP01' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_orderdata-basic_end_date
      exp = '20261012' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_orderdata-quantity
      exp = '12.500' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_orderdata-quantity_uom
      exp = 'EA' ).
  ENDMETHOD.

  METHOD maps_create_order_result.
    DATA(ls_result) = zcl_bapi_prod_order_api=>map_create_order_result(
      is_request      = VALUE #( material = 'MAT-1' )
      iv_order_number = '0000000101'
      is_return       = VALUE #(
        type    = 'S'
        message = 'Production order created' ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-production_order
      exp = '0000000101' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message-message
      exp = 'Production order created' ).

    ls_result = zcl_bapi_prod_order_api=>map_create_order_result(
      is_request      = VALUE #( material = 'MAT-1' )
      iv_order_number = space
      is_return       = VALUE #( type = 'S' ) ).
    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
  ENDMETHOD.

  METHOD maps_release_detail_errors.
    DATA(ls_result) = zcl_bapi_prod_order_api=>map_release_result(
      it_production_orders = VALUE #(
        ( '0000000101' )
        ( '0000000102' ) )
      it_detail_returns    = VALUE #(
        ( order_number = '0000000101'
          type         = 'S'
          message      = 'Order released' )
        ( order_number = '0000000102'
          type         = 'E'
          message      = 'Order cannot be released' ) )
      is_return            = VALUE #( type = 'S' message = 'Release completed' ) ).

    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_true(
      ls_result-orders[ 1 ]-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-message-type
      exp = 'S' ).
    cl_abap_unit_assert=>assert_false(
      ls_result-orders[ 2 ]-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-message-message
      exp = 'Order cannot be released' ).
  ENDMETHOD.

  METHOD maps_release_global_error.
    DATA(ls_result) = zcl_bapi_prod_order_api=>map_release_result(
      it_production_orders = VALUE #(
        ( '0000000101' )
        ( '0000000102' ) )
      it_detail_returns    = VALUE #(
        ( order_number = '0000000101' type = 'S' ) )
      is_return            = VALUE #(
        type    = 'E'
        message = 'Release request failed' ) ).

    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_false(
      ls_result-orders[ 1 ]-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 1 ]-message-type
      exp = 'E' ).
    cl_abap_unit_assert=>assert_false(
      ls_result-orders[ 2 ]-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-orders[ 2 ]-message-message
      exp = 'Release request failed' ).
  ENDMETHOD.

  METHOD maps_operation_release_errors.
    DATA(ls_result) =
      zcl_bapi_prod_order_api=>map_operation_release_result(
        it_operations     = VALUE #(
          ( production_order = '0000000101' operation_number = '0010' )
          ( production_order = '0000000101' operation_number = '0020' ) )
        it_detail_returns = VALUE #(
          ( order_number     = '0000000101'
            operation_number = '0010'
            type             = 'S'
            message          = 'Operation released' )
          ( order_number     = '0000000101'
            operation_number = '0020'
            type             = 'E'
            message          = 'Preceding operation is not released' ) )
        is_return         = VALUE #( type = 'S' message = 'Request processed' ) ).

    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_true(
      ls_result-operations[ 1 ]-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-operations[ 1 ]-operation_number
      exp = '0010' ).
    cl_abap_unit_assert=>assert_false(
      ls_result-operations[ 2 ]-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-operations[ 2 ]-message-message
      exp = 'Preceding operation is not released' ).
  ENDMETHOD.

  METHOD maps_confirmation_cancel.
    DATA(ls_result) = zcl_bapi_prod_order_api=>map_confirmation_cancel_result(
        is_request = VALUE #(
          confirmation         = '0000000123'
          confirmation_counter = '00000007'
          posting_date         = '20261011' )
        is_return  = VALUE #(
          type    = 'E'
          message = 'Confirmation has already been cancelled' ) ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_result-confirmation
      exp = '0000000123' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-confirmation_counter
      exp = '00000007' ).
    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message-message
      exp = 'Confirmation has already been cancelled' ).
  ENDMETHOD.

  METHOD maps_confirmation_create.
    DATA(ls_result) =
      zcl_bapi_prod_order_api=>map_confirmation_create_result(
        is_request        = VALUE #(
          production_order   = '0000000101'
          operation_number   = '0010'
          operation_sequence = '000000' )
        it_detail_returns = VALUE #(
          ( row      = 1
            type     = 'S'
            message  = 'Confirmation saved'
            conf_no  = '0000000123'
            conf_cnt = '00000004' ) )
        is_return         = VALUE #( type = 'S' ) ).

    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-production_order
      exp = '0000000101' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-confirmation
      exp = '0000000123' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-confirmation_counter
      exp = '00000004' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message-message
      exp = 'Confirmation saved' ).
  ENDMETHOD.

  METHOD maps_confirmation_create_error.
    DATA(ls_result) =
      zcl_bapi_prod_order_api=>map_confirmation_create_result(
        is_request        = VALUE #(
          production_order   = '0000000101'
          operation_number   = '0010'
          operation_sequence = '000000' )
        it_detail_returns = VALUE #(
          ( row     = 1
            type    = 'E'
            message = 'Operation is not released' ) )
        is_return         = VALUE #( type = 'S' ) ).

    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message-type
      exp = 'E' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message-message
      exp = 'Operation is not released' ).
  ENDMETHOD.

  METHOD maps_technical_completion.
    DATA(ls_result) = zcl_bapi_prod_order_api=>map_completion_result(
      iv_production_order = '0000000101'
      is_return           = VALUE #(
        type    = 'E'
        message = 'Order cannot be completed' ) ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_result-production_order
      exp = '0000000101' ).
    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message-type
      exp = 'E' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message-message
      exp = 'Order cannot be completed' ).
  ENDMETHOD.

  METHOD maps_deletion_flag.
    DATA(ls_result) = zcl_bapi_prod_order_api=>map_deletion_flag_result(
      iv_production_order = '0000000101'
      is_return           = VALUE #(
        type    = 'W'
        message = 'Deletion flag set with a warning' ) ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_result-production_order
      exp = '0000000101' ).
    cl_abap_unit_assert=>assert_true( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message-type
      exp = 'W' ).
  ENDMETHOD.

  METHOD maps_close_order.
    DATA(ls_result) = zcl_bapi_prod_order_api=>map_close_result(
      iv_production_order = '0000000101'
      is_return           = VALUE #(
        type    = 'E'
        message = 'Order is not ready to close' ) ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_result-production_order
      exp = '0000000101' ).
    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message-message
      exp = 'Order is not ready to close' ).
  ENDMETHOD.

  METHOD maps_deletion_indicator.
    DATA(ls_result) =
      zcl_bapi_prod_order_api=>map_deletion_indicator_result(
        iv_production_order = '0000000101'
        is_return           = VALUE #(
          type    = 'E'
          message = 'Deletion flag must be set first' ) ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_result-production_order
      exp = '0000000101' ).
    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message-message
      exp = 'Deletion flag must be set first' ).
  ENDMETHOD.

  METHOD maps_change_request.
    DATA(ls_parameters) = zcl_bapi_prod_order_api=>map_change_request(
      is_request = VALUE #(
        production_order   = '0000000101'
        quantity           = '12.500'
        quantity_uom       = 'EA'
        basic_start_date   = '20261012'
        basic_finish_date  = '20261015'
        change_quantity    = abap_true
        change_start_date  = abap_true
        change_finish_date = abap_true ) ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_parameters-orderdata-quantity
      exp = CONV bapi_pp_order_change-quantity( '12.500' ) ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_parameters-orderdata-quantity_uom
      exp = 'EA' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_parameters-orderdata-basic_start_date
      exp = '20261012' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_parameters-orderdata-basic_end_date
      exp = '20261015' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_parameters-orderdatax-quantity
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_parameters-orderdatax-quantity_uom
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_parameters-orderdatax-basic_start_date
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_parameters-orderdatax-basic_end_date
      exp = abap_true ).
  ENDMETHOD.

  METHOD maps_change_error.
    DATA(ls_result) = zcl_bapi_prod_order_api=>map_change_result(
      iv_production_order = '0000000101'
      is_return           = VALUE #(
        type    = 'E'
        message = 'Order quantity is not changeable' ) ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_result-production_order
      exp = '0000000101' ).
    cl_abap_unit_assert=>assert_false( ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message-message
      exp = 'Order quantity is not changeable' ).
  ENDMETHOD.
ENDCLASS.
