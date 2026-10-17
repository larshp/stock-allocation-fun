CLASS ltcl_bapi_planned_order_api DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS maps_request_fields FOR TESTING.
    METHODS maps_change_fields FOR TESTING.
ENDCLASS.

CLASS ltcl_bapi_planned_order_api IMPLEMENTATION.
  METHOD maps_request_fields.
    DATA(ls_header) = zcl_bapi_planned_order_api=>map_request(
      VALUE zif_planned_order_api=>ty_request(
        material         = 'MAT-1'
        plant            = '1000'
        quantity         = '12.500'
        planned_end_date = '20261115' ) ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_header-material
      exp = 'MAT-1' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_header-plan_plant
      exp = '1000' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_header-total_plord_qty
      exp = '12.500' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_header-order_finish_date
      exp = '20261115' ).
  ENDMETHOD.

  METHOD maps_change_fields.
    DATA(ls_change_data) = zcl_bapi_planned_order_api=>map_change_request(
      VALUE zif_planned_order_api=>ty_change_request(
        quantity               = '12.500'
        planned_start_date     = '20261101'
        planned_end_date       = '20261115'
        fixed_indicator        = abap_true
        change_quantity        = abap_true
        change_start_date      = abap_true
        change_end_date        = abap_true
        change_fixed_indicator = abap_true ) ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_change_data-headerdata-total_plord_qty
      exp = '12.500' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_change_data-headerdatax-total_plord_qty
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_change_data-headerdata-order_finish_date
      exp = '20261115' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_change_data-headerdatax-order_finish_date
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_change_data-headerdata-order_start_date
      exp = '20261101' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_change_data-headerdatax-order_start_date
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_change_data-headerdata-firming_ind
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_change_data-headerdatax-firming_ind
      exp = abap_true ).

    ls_change_data = zcl_bapi_planned_order_api=>map_change_request(
      VALUE zif_planned_order_api=>ty_change_request(
        quantity               = '12.500'
        change_quantity        = abap_true
        change_fixed_indicator = abap_true ) ).
    cl_abap_unit_assert=>assert_initial(
      ls_change_data-headerdata-order_finish_date ).
    cl_abap_unit_assert=>assert_initial(
      ls_change_data-headerdatax-order_finish_date ).
    cl_abap_unit_assert=>assert_initial(
      ls_change_data-headerdata-order_start_date ).
    cl_abap_unit_assert=>assert_initial(
      ls_change_data-headerdatax-order_start_date ).
    cl_abap_unit_assert=>assert_initial(
      ls_change_data-headerdata-firming_ind ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_change_data-headerdatax-firming_ind
      exp = abap_true ).
  ENDMETHOD.
ENDCLASS.
