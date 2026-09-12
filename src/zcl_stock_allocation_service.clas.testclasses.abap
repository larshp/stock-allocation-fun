CLASS lcl_poster_stub DEFINITION
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES zif_allocation_poster.

    DATA mv_move_type  TYPE bapi2017_gm_item_create-move_type.
    DATA mv_call_count TYPE i.
    DATA mv_item_count TYPE i.

ENDCLASS.


CLASS lcl_poster_stub IMPLEMENTATION.

  METHOD zif_allocation_poster~post.
    mv_move_type  = iv_move_type.
    mv_call_count = mv_call_count + 1.
    mv_item_count = lines( it_result ).

    rs_result-success         = abap_true.
    rs_result-document_number = '4711'.
  ENDMETHOD.

ENDCLASS.


CLASS ltcl_stock_allocation_service DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    TYPES ty_mard_tt TYPE STANDARD TABLE OF mard WITH DEFAULT KEY.
    TYPES ty_resb_tt TYPE STANDARD TABLE OF resb WITH DEFAULT KEY.
    TYPES ty_vbap_tt TYPE STANDARD TABLE OF vbap WITH DEFAULT KEY.
    TYPES ty_mchb_tt TYPE STANDARD TABLE OF mchb WITH DEFAULT KEY.
    TYPES ty_mcha_tt TYPE STANDARD TABLE OF mcha WITH DEFAULT KEY.
    TYPES ty_marm_tt TYPE STANDARD TABLE OF marm WITH DEFAULT KEY.

    DATA mo_environment TYPE REF TO if_osql_test_environment.
    DATA mo_cut         TYPE REF TO zcl_stock_allocation_service.

    METHODS setup.
    METHODS teardown.

    METHODS given_stock
      IMPORTING
        iv_lgort TYPE lgort_d
        iv_labst TYPE menge_d DEFAULT 0.

    METHODS given_requirement
      IMPORTING
        iv_rsnum TYPE resb-rsnum
        iv_rspos TYPE resb-rspos DEFAULT '0001'
        iv_bdmng TYPE menge_d DEFAULT 0
        iv_bdter TYPE d DEFAULT '20260101'.

    METHODS given_sales_order
      IMPORTING
        iv_vbeln  TYPE vbap-vbeln
        iv_kwmeng TYPE menge_d DEFAULT 0
        iv_edatu  TYPE d DEFAULT '20260101'
        iv_meins  TYPE vbap-meins DEFAULT 'ST'.

    METHODS given_uom
      IMPORTING
        iv_meinh TYPE marm-meinh
        iv_umrez TYPE marm-umrez
        iv_umren TYPE marm-umren.

    METHODS given_batch
      IMPORTING
        iv_lgort TYPE lgort_d
        iv_charg TYPE mchb-charg
        iv_clabs TYPE menge_d DEFAULT 0
        iv_vfdat TYPE d OPTIONAL.

    METHODS stock_of
      IMPORTING
        iv_lgort        TYPE lgort_d
      RETURNING
        VALUE(rv_labst) TYPE menge_d.

    METHODS allocates_stock_to_open_resb   FOR TESTING.
    METHODS reports_shortage_end_to_end    FOR TESTING.
    METHODS spills_over_two_bins           FOR TESTING.
    METHODS available_quantity_sums_bins   FOR TESTING.
    METHODS total_shortage_sums_results    FOR TESTING.
    METHODS no_requirements_no_result      FOR TESTING.
    METHODS records_allocation_run         FOR TESTING.
    METHODS runs_posts_and_records         FOR TESTING.
    METHODS no_allocation_skips_posting    FOR TESTING.
    METHODS uses_injected_poster           FOR TESTING.
    METHODS allocates_from_sales_order     FOR TESTING.
    METHODS fefo_allocates_earliest_batch  FOR TESTING.
    METHODS converts_sales_unit_to_base    FOR TESTING.
ENDCLASS.


CLASS ltcl_stock_allocation_service IMPLEMENTATION.

  METHOD setup.
    mo_environment = cl_osql_test_environment=>create(
      i_dependency_list = VALUE #( ( 'MARD' ) ( 'RESB' ) ( 'VBAP' ) ( 'MCHB' )
                                   ( 'MCHA' ) ( 'MARM' )
                                   ( 'ZSTOCKALLOC' ) ) ).
    mo_cut = NEW #( ).
  ENDMETHOD.

  METHOD teardown.
    mo_environment->destroy( ).
  ENDMETHOD.

  METHOD given_stock.
    DATA ls_mard TYPE mard.

    ls_mard-mandt = sy-mandt.
    ls_mard-matnr = 'MAT-1'.
    ls_mard-werks = '1000'.
    ls_mard-lgort = iv_lgort.
    ls_mard-labst = iv_labst.

    mo_environment->insert_test_data( VALUE ty_mard_tt( ( ls_mard ) ) ).
  ENDMETHOD.

  METHOD given_requirement.
    DATA ls_resb TYPE resb.

    ls_resb-mandt = sy-mandt.
    ls_resb-rsnum = iv_rsnum.
    ls_resb-rspos = iv_rspos.
    ls_resb-rsart = '1'.
    ls_resb-matnr = 'MAT-1'.
    ls_resb-werks = '1000'.
    ls_resb-lgort = '0001'.
    ls_resb-bdmng = iv_bdmng.
    ls_resb-bdter = iv_bdter.

    mo_environment->insert_test_data( VALUE ty_resb_tt( ( ls_resb ) ) ).
  ENDMETHOD.

  METHOD given_sales_order.
    DATA ls_vbap TYPE vbap.

    ls_vbap-mandt  = sy-mandt.
    ls_vbap-vbeln  = iv_vbeln.
    ls_vbap-posnr  = '000010'.
    ls_vbap-matnr  = 'MAT-1'.
    ls_vbap-werks  = '1000'.
    ls_vbap-kwmeng = iv_kwmeng.
    ls_vbap-meins  = iv_meins.
    ls_vbap-edatu  = iv_edatu.

    mo_environment->insert_test_data( VALUE ty_vbap_tt( ( ls_vbap ) ) ).
  ENDMETHOD.

  METHOD given_uom.
    DATA ls_marm TYPE marm.

    ls_marm-mandt = sy-mandt.
    ls_marm-matnr = 'MAT-1'.
    ls_marm-meinh = iv_meinh.
    ls_marm-umrez = iv_umrez.
    ls_marm-umren = iv_umren.

    mo_environment->insert_test_data( VALUE ty_marm_tt( ( ls_marm ) ) ).
  ENDMETHOD.

  METHOD given_batch.
    DATA ls_mchb TYPE mchb.
    DATA ls_mcha TYPE mcha.

    ls_mchb-mandt = sy-mandt.
    ls_mchb-matnr = 'MAT-1'.
    ls_mchb-werks = '1000'.
    ls_mchb-lgort = iv_lgort.
    ls_mchb-charg = iv_charg.
    ls_mchb-clabs = iv_clabs.

    mo_environment->insert_test_data( VALUE ty_mchb_tt( ( ls_mchb ) ) ).

    IF iv_vfdat IS NOT INITIAL.
      ls_mcha-mandt = sy-mandt.
      ls_mcha-matnr = 'MAT-1'.
      ls_mcha-charg = iv_charg.
      ls_mcha-vfdat = iv_vfdat.

      mo_environment->insert_test_data( VALUE ty_mcha_tt( ( ls_mcha ) ) ).
    ENDIF.
  ENDMETHOD.

  METHOD stock_of.
    SELECT SINGLE labst FROM mard INTO @rv_labst
      WHERE matnr = 'MAT-1'
        AND werks = '1000'
        AND lgort = @iv_lgort.
  ENDMETHOD.

  METHOD allocates_stock_to_open_resb.
    given_stock( iv_lgort = '0001' iv_labst = '10' ).
    given_requirement( iv_rsnum = '0000000001' iv_bdmng = '6' ).

    DATA(lt_result) = mo_cut->allocate( iv_matnr = 'MAT-1'
                                        iv_werks = '1000' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_result )
                                        exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-allocated_qty
                                        exp = '6' ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-shortage_qty
                                        exp = '0' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_result[ 1 ]-allocations[ 1 ]-lgort exp = '0001' ).
  ENDMETHOD.

  METHOD reports_shortage_end_to_end.
    given_stock( iv_lgort = '0001' iv_labst = '2' ).
    given_requirement( iv_rsnum = '0000000001' iv_bdmng = '10' ).

    DATA(lt_result) = mo_cut->allocate( iv_matnr = 'MAT-1'
                                        iv_werks = '1000' ).

    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-allocated_qty
                                        exp = '2' ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-shortage_qty
                                        exp = '8' ).
  ENDMETHOD.

  METHOD spills_over_two_bins.
    given_stock( iv_lgort = '0001' iv_labst = '4' ).
    given_stock( iv_lgort = '0002' iv_labst = '4' ).
    given_requirement( iv_rsnum = '0000000001' iv_bdmng = '6' ).

    DATA(lt_result) = mo_cut->allocate( iv_matnr = 'MAT-1'
                                        iv_werks = '1000' ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_result[ 1 ]-allocations ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-allocated_qty
                                        exp = '6' ).
  ENDMETHOD.

  METHOD available_quantity_sums_bins.
    given_stock( iv_lgort = '0001' iv_labst = '3' ).
    given_stock( iv_lgort = '0002' iv_labst = '5' ).
    given_stock( iv_lgort = '0003' iv_labst = '7' ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->available_quantity( iv_matnr = 'MAT-1'
                                        iv_werks = '1000' )
      exp = '15' ).
  ENDMETHOD.

  METHOD total_shortage_sums_results.
    given_stock( iv_lgort = '0001' iv_labst = '1' ).
    given_requirement( iv_rsnum = '0000000001' iv_bdmng = '4' ).
    given_requirement( iv_rsnum = '0000000002' iv_bdmng = '5' ).

    DATA(lt_result) = mo_cut->allocate( iv_matnr = 'MAT-1'
                                        iv_werks = '1000' ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total_shortage( lt_result ) exp = '8' ).
  ENDMETHOD.

  METHOD no_requirements_no_result.
    given_stock( iv_lgort = '0001' iv_labst = '10' ).

    DATA(lt_result) = mo_cut->allocate( iv_matnr = 'MAT-1'
                                        iv_werks = '1000' ).

    cl_abap_unit_assert=>assert_initial( act = lt_result ).
  ENDMETHOD.

  METHOD records_allocation_run.
    given_stock( iv_lgort = '0001' iv_labst = '4' ).
    given_stock( iv_lgort = '0002' iv_labst = '4' ).
    given_requirement( iv_rsnum = '0000000001' iv_bdmng = '6' ).

    DATA(lt_result) = mo_cut->allocate_and_record( iv_run_id = 'RUN-1'
                                                   iv_matnr  = 'MAT-1'
                                                   iv_werks  = '1000' ).

    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-allocated_qty
                                        exp = '6' ).

    SELECT * FROM zstockalloc INTO TABLE @DATA(lt_log).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_log )
                                        exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_log[ 1 ]-run_id
                                        exp = 'RUN-1' ).
    cl_abap_unit_assert=>assert_equals( act = lt_log[ 1 ]-lgort
                                        exp = '0001' ).
    cl_abap_unit_assert=>assert_equals( act = lt_log[ 1 ]-alloc_qty
                                        exp = '4' ).
    cl_abap_unit_assert=>assert_equals( act = lt_log[ 2 ]-lgort
                                        exp = '0002' ).
  ENDMETHOD.

  METHOD runs_posts_and_records.
    given_stock( iv_lgort = '0001' iv_labst = '10' ).
    given_requirement( iv_rsnum = '0000000001' iv_bdmng = '6' ).

    DATA(ls_run) = mo_cut->run_with_posting( iv_run_id = 'RUN-2'
                                             iv_matnr  = 'MAT-1'
                                             iv_werks  = '1000' ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_run-allocations[ 1 ]-allocated_qty exp = '6' ).
    cl_abap_unit_assert=>assert_equals( act = ls_run-posting-success
                                        exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = ls_run-posting-document_number
                                        exp = '4900000001' ).

    " the goods issue posted through the BAPI stub reduces MARD
    cl_abap_unit_assert=>assert_equals( act = stock_of( '0001' )
                                        exp = '4' ).

    SELECT * FROM zstockalloc INTO TABLE @DATA(lt_log).
    cl_abap_unit_assert=>assert_equals( act = lines( lt_log )
                                        exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_log[ 1 ]-run_id
                                        exp = 'RUN-2' ).
  ENDMETHOD.

  METHOD no_allocation_skips_posting.
    given_stock( iv_lgort = '0001' iv_labst = '10' ).

    DATA(ls_run) = mo_cut->run_with_posting( iv_run_id = 'RUN-3'
                                             iv_matnr  = 'MAT-1'
                                             iv_werks  = '1000' ).

    cl_abap_unit_assert=>assert_initial( act = ls_run-allocations ).
    cl_abap_unit_assert=>assert_equals( act = ls_run-posting-success
                                        exp = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = stock_of( '0001' )
                                        exp = '10' ).

    SELECT * FROM zstockalloc INTO TABLE @DATA(lt_log).
    cl_abap_unit_assert=>assert_initial( act = lt_log ).
  ENDMETHOD.

  METHOD uses_injected_poster.
    given_stock( iv_lgort = '0001' iv_labst = '10' ).
    given_requirement( iv_rsnum = '0000000001' iv_bdmng = '6' ).

    DATA(lo_poster) = NEW lcl_poster_stub( ).
    DATA(lo_cut) = NEW zcl_stock_allocation_service(
      io_poster = lo_poster ).

    DATA(ls_run) = lo_cut->run_with_posting( iv_run_id    = 'RUN-4'
                                             iv_matnr     = 'MAT-1'
                                             iv_werks     = '1000'
                                             iv_move_type = '601' ).

    cl_abap_unit_assert=>assert_equals( act = lo_poster->mv_call_count
                                        exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lo_poster->mv_move_type
                                        exp = '601' ).
    cl_abap_unit_assert=>assert_equals( act = lo_poster->mv_item_count
                                        exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = ls_run-posting-document_number
                                        exp = '4711' ).
  ENDMETHOD.

  METHOD allocates_from_sales_order.
    given_stock( iv_lgort = '0001' iv_labst = '10' ).
    given_sales_order( iv_vbeln  = '0000001234'
                       iv_kwmeng = '4' ).

    DATA(lo_cut) = NEW zcl_stock_allocation_service(
      io_requirement_reader = NEW zcl_requirement_reader_vbap( ) ).

    DATA(lt_result) = lo_cut->allocate( iv_matnr = 'MAT-1'
                                        iv_werks = '1000' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_result )
                                        exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-requirement_id
                                        exp = '0000001234000010' ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-allocated_qty
                                        exp = '4' ).
  ENDMETHOD.

  METHOD fefo_allocates_earliest_batch.
    given_batch( iv_lgort = '0001'
                 iv_charg = 'OLD'
                 iv_clabs = '3'
                 iv_vfdat = '20260101' ).
    given_batch( iv_lgort = '0001'
                 iv_charg = 'NEW'
                 iv_clabs = '3'
                 iv_vfdat = '20261231' ).
    given_requirement( iv_rsnum = '0000000001'
                       iv_bdmng = '4' ).

    DATA(ls_policy) = VALUE zcl_stock_allocator=>ty_policy(
      use_fefo = abap_true ).
    DATA(lo_cut) = NEW zcl_stock_allocation_service(
      io_stock_reader = NEW zcl_stock_reader_mchb( )
      is_policy       = ls_policy ).

    DATA(lt_result) = lo_cut->allocate( iv_matnr = 'MAT-1'
                                        iv_werks = '1000' ).
    DATA(lt_alloc) = lt_result[ 1 ]-allocations.

    cl_abap_unit_assert=>assert_equals( act = lt_alloc[ 1 ]-charg
                                        exp = 'OLD' ).
    cl_abap_unit_assert=>assert_equals( act = lt_alloc[ 1 ]-quantity
                                        exp = '3' ).
    cl_abap_unit_assert=>assert_equals( act = lt_alloc[ 2 ]-charg
                                        exp = 'NEW' ).
    cl_abap_unit_assert=>assert_equals( act = lt_alloc[ 2 ]-quantity
                                        exp = '1' ).
  ENDMETHOD.

  METHOD converts_sales_unit_to_base.
    given_stock( iv_lgort = '0001'
                 iv_labst = '100' ).
    given_sales_order( iv_vbeln  = '0000001234'
                       iv_kwmeng = '4'
                       iv_meins  = 'CS' ).
    given_uom( iv_meinh = 'CS'
               iv_umrez = 12
               iv_umren = 1 ).

    DATA(lo_cut) = NEW zcl_stock_allocation_service(
      io_requirement_reader = NEW zcl_requirement_reader_vbap( ) ).

    DATA(lt_result) = lo_cut->allocate( iv_matnr = 'MAT-1'
                                        iv_werks = '1000' ).

    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-requested_qty
                                        exp = '48' ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-allocated_qty
                                        exp = '48' ).
    cl_abap_unit_assert=>assert_equals( act = lt_result[ 1 ]-shortage_qty
                                        exp = '0' ).
  ENDMETHOD.

ENDCLASS.
