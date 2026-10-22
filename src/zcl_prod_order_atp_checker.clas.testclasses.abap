CLASS ltcl_prod_order_atp_checker DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS maps_order_summaries FOR TESTING
      RAISING cx_static_check.
    METHODS allows_order_without_comps FOR TESTING
      RAISING cx_static_check.
    METHODS rejects_readiness_overflow FOR TESTING.
ENDCLASS.

CLASS ltcl_prod_order_atp_checker IMPLEMENTATION.
  METHOD maps_order_summaries.
    DATA(lt_readiness) = zcl_prod_order_atp_checker=>map_summaries(
      it_production_orders = VALUE #(
        ( '0000000101' )
        ( '0000000102' ) )
      it_summaries         = VALUE #(
        ( production_order          = '0000000101'
          component_count           = 2
          fully_confirmed_count     = 1
          partially_confirmed_count = 1
          requested_base_quantity   = '10.000'
          confirmed_base_quantity   = '7.000'
          unconfirmed_base_quantity = '3.000'
          is_split_fully_confirmed  = abap_false ) ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_readiness )
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_readiness[ 1 ]-not_fully_confirmed_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_readiness[ 1 ]-unconfirmed_base_quantity
      exp = '3.000' ).
    cl_abap_unit_assert=>assert_false(
      lt_readiness[ 1 ]-is_fully_confirmed ).
    cl_abap_unit_assert=>assert_true(
      lt_readiness[ 2 ]-is_fully_confirmed ).
  ENDMETHOD.

  METHOD rejects_readiness_overflow.
    DATA(lv_max_quantity) = CONV mard-labst( '9999999999.999' ).
    DATA lv_requested_rejected TYPE abap_bool.
    DATA lv_confirmed_rejected TYPE abap_bool.
    DATA lv_unconfirmed_rejected TYPE abap_bool.

    TRY.
        zcl_prod_order_atp_checker=>map_summaries(
          it_production_orders = VALUE #( ( '0000000101' ) )
          it_summaries         = VALUE #(
            ( production_order        = '0000000101'
              requested_base_quantity = lv_max_quantity )
            ( production_order        = '0000000101'
              requested_base_quantity = lv_max_quantity ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_requested_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_requested_rejected ).

    TRY.
        zcl_prod_order_atp_checker=>map_summaries(
          it_production_orders = VALUE #( ( '0000000101' ) )
          it_summaries         = VALUE #(
            ( production_order        = '0000000101'
              confirmed_base_quantity = lv_max_quantity )
            ( production_order        = '0000000101'
              confirmed_base_quantity = lv_max_quantity ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_confirmed_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_confirmed_rejected ).

    TRY.
        zcl_prod_order_atp_checker=>map_summaries(
          it_production_orders = VALUE #( ( '0000000101' ) )
          it_summaries         = VALUE #(
            ( production_order          = '0000000101'
              unconfirmed_base_quantity = lv_max_quantity )
            ( production_order          = '0000000101'
              unconfirmed_base_quantity = lv_max_quantity ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_unconfirmed_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_unconfirmed_rejected ).
  ENDMETHOD.

  METHOD allows_order_without_comps.
    DATA(lt_readiness) = zcl_prod_order_atp_checker=>map_summaries(
      it_production_orders = VALUE #( ( '0000000101' ) )
      it_summaries         = VALUE #( ) ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_readiness[ 1 ]-component_count
      exp = 0 ).
    cl_abap_unit_assert=>assert_true(
      lt_readiness[ 1 ]-is_fully_confirmed ).
  ENDMETHOD.
ENDCLASS.
