CLASS ltc_bapi_gm_api DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS allows_simulation_without_key FOR TESTING.
    METHODS rejects_post_without_key FOR TESTING.
    METHODS rejects_cancel_without_key FOR TESTING.
    METHODS rejects_partial_key FOR TESTING.
    METHODS accepts_complete_key FOR TESTING.
ENDCLASS.

CLASS ltc_bapi_gm_api IMPLEMENTATION.
  METHOD allows_simulation_without_key.
    DATA(ls_result) = VALUE zif_goods_movement_api=>ty_result(
      is_successful = abap_true ).

    zcl_bapi_goods_movement_api=>ensure_document_key(
      EXPORTING
        iv_test_run  = abap_true
        iv_is_cancel = abap_false
      CHANGING
        cs_result    = ls_result ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_initial(
      act = ls_result-material_document ).
    cl_abap_unit_assert=>assert_initial(
      act = ls_result-fiscal_year ).
    cl_abap_unit_assert=>assert_initial(
      act = ls_result-messages ).
  ENDMETHOD.

  METHOD rejects_post_without_key.
    DATA(ls_result) = VALUE zif_goods_movement_api=>ty_result(
      is_successful = abap_true ).

    zcl_bapi_goods_movement_api=>ensure_document_key(
      EXPORTING
        iv_test_run  = abap_false
        iv_is_cancel = abap_false
      CHANGING
        cs_result    = ls_result ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'E'
      act = ls_result-messages[ 1 ]-type ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BAPI_GOODSMVT_CREATE returned no material document key'
      act = ls_result-messages[ 1 ]-message ).
  ENDMETHOD.

  METHOD rejects_cancel_without_key.
    DATA(ls_result) = VALUE zif_goods_movement_api=>ty_result(
      is_successful = abap_true ).

    zcl_bapi_goods_movement_api=>ensure_document_key(
      EXPORTING
        iv_test_run  = abap_false
        iv_is_cancel = abap_true
      CHANGING
        cs_result    = ls_result ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BAPI_GOODSMVT_CANCEL returned no reversal document key'
      act = ls_result-messages[ 1 ]-message ).
  ENDMETHOD.

  METHOD rejects_partial_key.
    DATA(ls_result) = VALUE zif_goods_movement_api=>ty_result(
      material_document = '4900001234'
      is_successful     = abap_true ).

    zcl_bapi_goods_movement_api=>ensure_document_key(
      EXPORTING
        iv_test_run  = abap_false
        iv_is_cancel = abap_false
      CHANGING
        cs_result    = ls_result ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'E'
      act = ls_result-messages[ 1 ]-type ).
  ENDMETHOD.

  METHOD accepts_complete_key.
    DATA(ls_result) = VALUE zif_goods_movement_api=>ty_result(
      material_document = '4900001234'
      fiscal_year       = '2026'
      is_successful     = abap_true ).

    zcl_bapi_goods_movement_api=>ensure_document_key(
      EXPORTING
        iv_test_run  = abap_false
        iv_is_cancel = abap_false
      CHANGING
        cs_result    = ls_result ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_initial(
      act = ls_result-messages ).
  ENDMETHOD.
ENDCLASS.
