CLASS lcl_sales_order_uom_repo DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_material_uom_repository.
    DATA mv_base_unit TYPE mara-meins.
    DATA mv_alternative_unit TYPE marm-meinh.
    DATA mv_numerator TYPE marm-umrez.
    DATA mv_denominator TYPE marm-umren.
ENDCLASS.

CLASS lcl_sales_order_uom_repo IMPLEMENTATION.
  METHOD zif_material_uom_repository~get_base_unit.
    rv_base_unit = mv_base_unit.
  ENDMETHOD.

  METHOD zif_material_uom_repository~get_alt_unit_ratio.
    IF iv_alternative_unit = mv_alternative_unit.
      rs_ratio-numerator = mv_numerator.
      rs_ratio-denominator = mv_denominator.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_bapi_sales_order_api DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    DATA mo_repository TYPE REF TO lcl_sales_order_uom_repo.
    DATA mo_converter TYPE REF TO zif_material_uom_converter.
    METHODS setup.
    METHODS maps_rejected_alt_unit FOR TESTING.
    METHODS rejects_missing_ratio FOR TESTING.
    METHODS rejects_item_uom_round_zero FOR TESTING.
    METHODS maps_sales_order_header FOR TESTING.
ENDCLASS.

CLASS ltcl_bapi_sales_order_api IMPLEMENTATION.
  METHOD setup.
    mo_repository = NEW lcl_sales_order_uom_repo( ).
    mo_converter = NEW zcl_material_uom_converter(
      io_repository = mo_repository ).
  ENDMETHOD.

  METHOD maps_rejected_alt_unit.
    mo_repository->mv_base_unit = 'EA'.
    mo_repository->mv_alternative_unit = 'BOX'.
    mo_repository->mv_numerator = 12.
    mo_repository->mv_denominator = 1.

    DATA(ls_mapping) = zcl_bapi_sales_order_api=>map_rejected_item(
      is_bapi_item      = VALUE #(
        itm_number = '000020'
        material   = 'MAT-1'
        plant      = '1000'
        req_qty    = '3.000'
        sales_unit = 'BOX'
        sales_qty1 = 12
        sales_qty2 = 1
        reason_rej = '01' )
      io_unit_converter = mo_converter ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_mapping-is_conversion_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = '000020'
      act = ls_mapping-item-item_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = '01'
      act = ls_mapping-item-rejection_reason ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = ls_mapping-item-sales_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '36.000' )
      act = ls_mapping-item-base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = ls_mapping-item-base_unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = 12
      act = ls_mapping-item-sales_unit_numerator ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_mapping-item-sales_unit_denominator ).
  ENDMETHOD.

  METHOD rejects_missing_ratio.
    mo_repository->mv_base_unit = 'EA'.

    DATA(ls_mapping) = zcl_bapi_sales_order_api=>map_rejected_item(
      is_bapi_item      = VALUE #(
        itm_number = '000020'
        material   = 'MAT-1'
        req_qty    = '3.000'
        sales_unit = 'BOX'
        reason_rej = '01' )
      io_unit_converter = mo_converter ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_mapping-is_conversion_successful ).
    cl_abap_unit_assert=>assert_initial(
      act = ls_mapping-item-base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = ls_mapping-item-base_unit ).
  ENDMETHOD.

  METHOD rejects_item_uom_round_zero.
    mo_repository->mv_base_unit = 'EA'.
    mo_repository->mv_alternative_unit = 'BOX'.
    mo_repository->mv_numerator = 1.
    mo_repository->mv_denominator = 1000.

    DATA(ls_mapping) = zcl_bapi_sales_order_api=>map_rejected_item(
      is_bapi_item      = VALUE #(
        itm_number = '000020'
        material   = 'MAT-1'
        req_qty    = '0.001'
        sales_unit = 'BOX'
        sales_qty1 = 1
        sales_qty2 = 1000
        reason_rej = '01' )
      io_unit_converter = mo_converter ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_mapping-is_conversion_successful ).
    cl_abap_unit_assert=>assert_initial(
      act = ls_mapping-item-base_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'EA'
      act = ls_mapping-item-base_unit ).
  ENDMETHOD.

  METHOD maps_sales_order_header.
    DATA(ls_order) = zcl_bapi_sales_order_api=>map_order_header(
      VALUE bapisdhd(
        doc_number = '0000004711'
        doc_type   = 'OR'
        sales_org  = '1000'
        distr_chan = '10'
        division   = '00'
        sold_to    = '0000123456'
        purch_no   = 'CUST-PO-1'
        doc_date   = '20261014' ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = '0000004711'
      act = ls_order-sales_document ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'OR'
      act = ls_order-order_type ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1000'
      act = ls_order-sales_organization ).
    cl_abap_unit_assert=>assert_equals(
      exp = '10'
      act = ls_order-distribution_channel ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00'
      act = ls_order-division ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000123456'
      act = ls_order-sold_to_party ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'CUST-PO-1'
      act = ls_order-customer_purchase_order ).
    cl_abap_unit_assert=>assert_equals(
      exp = '20261014'
      act = ls_order-document_date ).
  ENDMETHOD.
ENDCLASS.
