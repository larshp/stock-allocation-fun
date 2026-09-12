CLASS ltcl_requirement_reader_vbap DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    TYPES ty_vbap_tt TYPE STANDARD TABLE OF vbap WITH DEFAULT KEY.

    DATA mo_environment TYPE REF TO if_osql_test_environment.
    DATA mo_cut         TYPE REF TO zif_requirement_reader.

    METHODS setup.
    METHODS teardown.

    METHODS given_sales_order
      IMPORTING
        iv_vbeln  TYPE vbap-vbeln
        iv_posnr  TYPE vbap-posnr DEFAULT '000010'
        iv_kwmeng TYPE menge_d DEFAULT 0
        iv_edatu  TYPE d DEFAULT '20260101'
        iv_abgru  TYPE vbap-abgru OPTIONAL
        iv_lprio  TYPE vbap-lprio DEFAULT '01'
        iv_meins  TYPE vbap-meins DEFAULT 'ST'
        iv_matnr  TYPE matnr DEFAULT 'MAT-1'
        iv_werks  TYPE werks_d DEFAULT '1000'.

    METHODS read
      RETURNING
        VALUE(rt_requirements) TYPE zif_requirement_reader=>ty_requirement_tt.

    METHODS reads_open_item           FOR TESTING.
    METHODS skips_rejected_item       FOR TESTING.
    METHODS skips_zero_quantity       FOR TESTING.
    METHODS ignores_other_material    FOR TESTING.
    METHODS sorts_by_requirement_date FOR TESTING.
    METHODS maps_delivery_priority    FOR TESTING.
    METHODS maps_sales_unit           FOR TESTING.
    METHODS builds_id_from_key        FOR TESTING.
ENDCLASS.


CLASS ltcl_requirement_reader_vbap IMPLEMENTATION.

  METHOD setup.
    mo_environment = cl_osql_test_environment=>create(
      i_dependency_list = VALUE #( ( 'VBAP' ) ) ).
    mo_cut = NEW zcl_requirement_reader_vbap( ).
  ENDMETHOD.

  METHOD teardown.
    mo_environment->destroy( ).
  ENDMETHOD.

  METHOD given_sales_order.
    DATA ls_vbap TYPE vbap.

    ls_vbap-mandt  = sy-mandt.
    ls_vbap-vbeln  = iv_vbeln.
    ls_vbap-posnr  = iv_posnr.
    ls_vbap-matnr  = iv_matnr.
    ls_vbap-werks  = iv_werks.
    ls_vbap-kwmeng = iv_kwmeng.
    ls_vbap-meins  = iv_meins.
    ls_vbap-edatu  = iv_edatu.
    ls_vbap-abgru  = iv_abgru.
    ls_vbap-lprio  = iv_lprio.

    mo_environment->insert_test_data( VALUE ty_vbap_tt( ( ls_vbap ) ) ).
  ENDMETHOD.

  METHOD read.
    rt_requirements = mo_cut->read_requirements( iv_matnr = 'MAT-1'
                                                 iv_werks = '1000' ).
  ENDMETHOD.

  METHOD reads_open_item.
    given_sales_order( iv_vbeln  = '0000001234'
                       iv_kwmeng = '5' ).

    DATA(lt_req) = read( ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_req )
                                        exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_req[ 1 ]-requested_qty
                                        exp = '5' ).
    cl_abap_unit_assert=>assert_equals( act = lt_req[ 1 ]-requested_date
                                        exp = '20260101' ).
  ENDMETHOD.

  METHOD skips_rejected_item.
    given_sales_order( iv_vbeln  = '0000001234'
                       iv_kwmeng = '5'
                       iv_abgru  = '01' ).

    cl_abap_unit_assert=>assert_initial( act = read( ) ).
  ENDMETHOD.

  METHOD skips_zero_quantity.
    given_sales_order( iv_vbeln  = '0000001234'
                       iv_kwmeng = '0' ).

    cl_abap_unit_assert=>assert_initial( act = read( ) ).
  ENDMETHOD.

  METHOD ignores_other_material.
    given_sales_order( iv_vbeln  = '0000001234'
                       iv_kwmeng = '5'
                       iv_matnr  = 'MAT-2' ).

    cl_abap_unit_assert=>assert_initial( act = read( ) ).
  ENDMETHOD.

  METHOD sorts_by_requirement_date.
    given_sales_order( iv_vbeln  = '0000001235'
                       iv_kwmeng = '2'
                       iv_edatu  = '20260201' ).
    given_sales_order( iv_vbeln  = '0000001234'
                       iv_kwmeng = '3'
                       iv_edatu  = '20260115' ).

    DATA(lt_req) = read( ).

    cl_abap_unit_assert=>assert_equals( act = lt_req[ 1 ]-requested_date
                                        exp = '20260115' ).
    cl_abap_unit_assert=>assert_equals( act = lt_req[ 2 ]-requested_date
                                        exp = '20260201' ).
  ENDMETHOD.

  METHOD maps_delivery_priority.
    given_sales_order( iv_vbeln  = '0000001234'
                       iv_kwmeng = '5'
                       iv_lprio  = '03' ).

    DATA(lt_req) = read( ).

    cl_abap_unit_assert=>assert_equals( act = lt_req[ 1 ]-priority
                                        exp = 3 ).
  ENDMETHOD.

  METHOD maps_sales_unit.
    given_sales_order( iv_vbeln  = '0000001234'
                       iv_kwmeng = '5'
                       iv_meins  = 'CS' ).

    DATA(lt_req) = read( ).

    cl_abap_unit_assert=>assert_equals( act = lt_req[ 1 ]-unit
                                        exp = 'CS' ).
  ENDMETHOD.

  METHOD builds_id_from_key.
    given_sales_order( iv_vbeln  = '0000001234'
                       iv_posnr  = '000020'
                       iv_kwmeng = '5' ).

    DATA(lt_req) = read( ).

    cl_abap_unit_assert=>assert_equals( act = lt_req[ 1 ]-id
                                        exp = '0000001234000020' ).
  ENDMETHOD.

ENDCLASS.
