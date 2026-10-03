CLASS lcl_replenishment_req_api DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_purchase_requisition_api.
    METHODS set_write_result
      IMPORTING
        is_result TYPE zif_purchase_requisition_api=>ty_result.
    METHODS set_commit_result
      IMPORTING
        is_result TYPE zif_purchase_requisition_api=>ty_commit_result.
    METHODS get_create_count
      RETURNING
        VALUE(rv_count) TYPE i.
    METHODS get_commit_count
      RETURNING
        VALUE(rv_count) TYPE i.
    METHODS get_rollback_count
      RETURNING
        VALUE(rv_count) TYPE i.
    DATA ms_request TYPE zif_purchase_requisition_api=>ty_request.
  PRIVATE SECTION.
    DATA ms_write_result TYPE zif_purchase_requisition_api=>ty_result.
    DATA ms_commit_result TYPE zif_purchase_requisition_api=>ty_commit_result.
    DATA mv_create_count TYPE i.
    DATA mv_commit_count TYPE i.
    DATA mv_rollback_count TYPE i.
ENDCLASS.

CLASS lcl_replenishment_req_api IMPLEMENTATION.
  METHOD set_write_result.
    ms_write_result = is_result.
  ENDMETHOD.

  METHOD set_commit_result.
    ms_commit_result = is_result.
  ENDMETHOD.

  METHOD get_create_count.
    rv_count = mv_create_count.
  ENDMETHOD.

  METHOD get_commit_count.
    rv_count = mv_commit_count.
  ENDMETHOD.

  METHOD get_rollback_count.
    rv_count = mv_rollback_count.
  ENDMETHOD.

  METHOD zif_purchase_requisition_api~create_requisition.
    ADD 1 TO mv_create_count.
    ms_request = is_request.
    rs_result = ms_write_result.
  ENDMETHOD.

  METHOD zif_purchase_requisition_api~commit.
    ADD 1 TO mv_commit_count.
    rs_result = ms_commit_result.
  ENDMETHOD.

  METHOD zif_purchase_requisition_api~rollback.
    ADD 1 TO mv_rollback_count.
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_replenishment_req_service DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS creates_from_suggestions FOR TESTING.
    METHODS creates_from_selected_sources FOR TESTING.
    METHODS creates_from_agreement_source FOR TESTING.
    METHODS simulates_replenishment_req FOR TESTING.
    METHODS rolls_back_replenishment_req FOR TESTING.
    METHODS handles_covered_suggestions FOR TESTING.
    METHODS rejects_bad_repl_req FOR TESTING.
ENDCLASS.

CLASS ltcl_replenishment_req_service IMPLEMENTATION.
  METHOD creates_from_suggestions.
    DATA(lo_api) = NEW lcl_replenishment_req_api( ).
    lo_api->set_write_result( is_result = VALUE #(
      requisition_number = '0010001234'
      is_successful      = abap_true ) ).
    lo_api->set_commit_result( is_result = VALUE #(
      is_successful = abap_true ) ).
    DATA(lo_cut) = NEW zcl_replenishment_req_service( io_api = lo_api ).

    DATA(ls_result) = lo_cut->create_from_suggestions(
      it_suggestions         = VALUE #(
        ( material                    = 'MAT-REQ-1'
          plant                       = '1000'
          base_unit                   = 'EA'
          required_date               = '20261115'
          procurement_type            = 'F'
          source_vendor               = '0000100001'
          source_purchasing_org       = '2000'
          source_info_record          = '0000001234'
          source_category             = '0'
          suggested_base_quantity     = '2.500'
          suggested_receipt_count     = 1
          final_receipt_base_quantity = '2.500' )
        ( material                    = 'MAT-REQ-2'
          plant                       = '1000'
          base_unit                   = 'EA'
          required_date               = '20261116'
          suggested_base_quantity     = '0.000'
          suggested_receipt_count     = 0
          final_receipt_base_quantity = '0.000' )
        ( material                    = 'MAT-REQ-3'
          plant                       = '2000'
          base_unit                   = 'KG'
          required_date               = '20261117'
          procurement_type            = 'F'
          suggested_base_quantity     = '4.000'
          suggested_receipt_count     = 1
          final_receipt_base_quantity = '4.000' )
        ( material                    = 'MAT-REQ-4'
          plant                       = '2000'
          base_unit                   = 'EA'
          required_date               = '20261118'
          procurement_type            = 'F'
          maximum_base_quantity       = '3.000'
          suggested_base_quantity     = '5.000'
          suggested_receipt_count     = 2
          final_receipt_base_quantity = '2.000' )
        ( material                    = 'MAT-REQ-5'
          plant                       = '2000'
          base_unit                   = 'EA'
          required_date               = '20261119'
          procurement_type            = 'F'
          fixed_base_quantity         = '3.000'
          rounding_profile            = 'R001'
          suggested_base_quantity     = '15.000'
          suggested_receipt_count     = 3
          final_receipt_base_quantity = '5.000' ) )
      iv_requisition_type    = 'ZNB'
      iv_purchasing_group    = '001'
      iv_purchasing_org      = '1000'
      it_purchasing_controls = VALUE #(
        ( source_suggestion_index = 1
          purchasing_group        = '005' )
        ( source_suggestion_index = 4
          purchasing_group        = '002'
          purchasing_org          = '2000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_test_run ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-bapi_was_called ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0010001234'
      act = ls_result-requisition_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_rollback_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'ZNB'
      act = lo_api->ms_request-requisition_type ).
    cl_abap_unit_assert=>assert_equals(
      exp = 7
      act = lines( lo_api->ms_request-items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 7
      act = lines( ls_result-submitted_items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00010'
      act = lo_api->ms_request-items[ 1 ]-item_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'MAT-REQ-1'
      act = lo_api->ms_request-items[ 1 ]-material ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.500' )
      act = lo_api->ms_request-items[ 1 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '005'
      act = lo_api->ms_request-items[ 1 ]-purchasing_group ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1000'
      act = lo_api->ms_request-items[ 2 ]-purchasing_org ).
    cl_abap_unit_assert=>assert_equals(
      exp = '2000'
      act = lo_api->ms_request-items[ 1 ]-purchasing_org ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100001'
      act = lo_api->ms_request-items[ 1 ]-source_vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000001234'
      act = lo_api->ms_request-items[ 1 ]-source_info_record ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV d( '20261115' )
      act = lo_api->ms_request-items[ 1 ]-delivery_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-submitted_items[ 1 ]-source_suggestion_index ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00020'
      act = lo_api->ms_request-items[ 2 ]-item_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'KG'
      act = lo_api->ms_request-items[ 2 ]-unit ).
    cl_abap_unit_assert=>assert_equals(
      exp = '001'
      act = lo_api->ms_request-items[ 2 ]-purchasing_group ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1000'
      act = lo_api->ms_request-items[ 2 ]-purchasing_org ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'MAT-REQ-4'
      act = lo_api->ms_request-items[ 3 ]-material ).
    cl_abap_unit_assert=>assert_equals(
      exp = '002'
      act = lo_api->ms_request-items[ 3 ]-purchasing_group ).
    cl_abap_unit_assert=>assert_equals(
      exp = '2000'
      act = lo_api->ms_request-items[ 3 ]-purchasing_org ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '3.000' )
      act = lo_api->ms_request-items[ 3 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00040'
      act = lo_api->ms_request-items[ 4 ]-item_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '2.000' )
      act = lo_api->ms_request-items[ 4 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = ls_result-submitted_items[ 4 ]-source_suggestion_index ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00050'
      act = lo_api->ms_request-items[ 5 ]-item_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = lo_api->ms_request-items[ 5 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = lo_api->ms_request-items[ 6 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV mard-labst( '5.000' )
      act = lo_api->ms_request-items[ 7 ]-quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = 5
      act = lo_api->ms_request-items[ 7 ]-source_suggestion_index ).
  ENDMETHOD.

  METHOD creates_from_selected_sources.
    DATA(lo_api) = NEW lcl_replenishment_req_api( ).
    lo_api->set_write_result( is_result = VALUE #(
      requisition_number = '0010004321'
      is_successful      = abap_true ) ).
    lo_api->set_commit_result( is_result = VALUE #(
      is_successful = abap_true ) ).
    DATA(lo_cut) = NEW zcl_replenishment_req_service( io_api = lo_api ).

    DATA(ls_result) = lo_cut->create_from_selected_sources(
      it_suggestions             = VALUE #(
        ( material = 'MAT-SELECT-1' plant = '1000' base_unit = 'EA'
          required_date = '20261115' procurement_type = 'F'
          suggested_base_quantity = '2.000'
          suggested_receipt_count = 1
          final_receipt_base_quantity = '2.000' )
        ( material = 'MAT-SELECT-2' plant = '1000' base_unit = 'EA'
          required_date = '20261116' procurement_type = 'F'
          suggested_base_quantity = '3.000'
          suggested_receipt_count = 1
          final_receipt_base_quantity = '3.000' ) )
      it_selected_source_options = VALUE #(
        ( suggestion_index = 1 source_kind =
            zcl_repl_source_service=>c_suggestion_source_pir
          candidate_rank = 1
          pir_candidate = VALUE #(
            request_index = 1 candidate_rank = 1
            material = 'MAT-SELECT-1' plant = '1000'
            purchasing_org = '1000' delivery_date = '20261115'
            vendor = '0000100001' info_record = '0000001001'
            source_category = '0' ) )
        ( suggestion_index = 2 source_kind =
            zcl_repl_source_service=>c_suggestion_source_outline
          candidate_rank = 1
          outline_candidate = VALUE #(
            request_index = 2 candidate_rank = 1
            material = 'MAT-SELECT-2' plant = '1000'
            purchasing_org = '2000' delivery_date = '20261116'
            vendor = '0000100002' purchasing_document = '4500000099'
            purchasing_item = '00020' document_category = 'L' ) ) )
      iv_purchasing_org          = '1000' ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0010004321'
      act = ls_result-requisition_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_api->get_create_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lo_api->ms_request-items ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100001'
      act = lo_api->ms_request-items[ 1 ]-source_vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000001001'
      act = lo_api->ms_request-items[ 1 ]-source_info_record ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100002'
      act = lo_api->ms_request-items[ 2 ]-source_vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = '4500000099'
      act = lo_api->ms_request-items[ 2 ]-source_agreement ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00020'
      act = lo_api->ms_request-items[ 2 ]-source_agreement_item ).
    cl_abap_unit_assert=>assert_initial(
      act = lo_api->ms_request-items[ 2 ]-source_info_record ).
  ENDMETHOD.

  METHOD creates_from_agreement_source.
    DATA(lo_api) = NEW lcl_replenishment_req_api( ).
    lo_api->set_write_result( is_result = VALUE #(
      requisition_number = '0010001234'
      is_successful      = abap_true ) ).
    lo_api->set_commit_result( is_result = VALUE #(
      is_successful = abap_true ) ).
    DATA(lo_cut) = NEW zcl_replenishment_req_service( io_api = lo_api ).

    lo_cut->create_from_suggestions(
      it_suggestions = VALUE #(
        ( material                    = 'MAT-CONTRACT'
          plant                       = '1000'
          base_unit                   = 'EA'
          required_date               = '20261115'
          procurement_type            = 'F'
          source_vendor               = '0000100001'
          source_purchasing_org       = '2000'
          source_agreement            = '4500000001'
          source_agreement_item       = '00010'
          suggested_base_quantity     = '2.000'
          suggested_receipt_count     = 1
          final_receipt_base_quantity = '2.000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = '4500000001'
      act = lo_api->ms_request-items[ 1 ]-source_agreement ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00010'
      act = lo_api->ms_request-items[ 1 ]-source_agreement_item ).
    cl_abap_unit_assert=>assert_equals(
      exp = '2000'
      act = lo_api->ms_request-items[ 1 ]-purchasing_org ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100001'
      act = lo_api->ms_request-items[ 1 ]-source_vendor ).
    cl_abap_unit_assert=>assert_initial(
      act = lo_api->ms_request-items[ 1 ]-source_info_record ).
  ENDMETHOD.

  METHOD simulates_replenishment_req.
    DATA(lo_api) = NEW lcl_replenishment_req_api( ).
    lo_api->set_write_result( is_result = VALUE #(
      is_successful = abap_true ) ).
    DATA(lo_cut) = NEW zcl_replenishment_req_service( io_api = lo_api ).

    DATA(ls_result) = lo_cut->create_from_suggestions(
      it_suggestions = VALUE #(
        ( material                    = 'MAT-REQ'
          plant                       = '1000'
          base_unit                   = 'EA'
          required_date               = '20261115'
          procurement_type            = 'F'
          suggested_base_quantity     = '1.000'
          suggested_receipt_count     = 1
          final_receipt_base_quantity = '1.000' ) )
      iv_test_run    = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_test_run ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-bapi_was_called ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lo_api->ms_request-is_test_run ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00010'
      act = ls_result-submitted_items[ 1 ]-item_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_result-submitted_items[ 1 ]-source_suggestion_index ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_rollback_count( ) ).
  ENDMETHOD.

  METHOD rolls_back_replenishment_req.
    DATA(lo_error_api) = NEW lcl_replenishment_req_api( ).
    lo_error_api->set_write_result( is_result = VALUE #(
      messages      = VALUE #( ( type      = 'E'
                                 id        = '06'
                                 number    = '123'
                                 message   = 'Invalid plant'
                                 parameter = 'PRITEM'
                                 row       = 1
                                 field     = 'PLANT' ) )
      is_successful = abap_false ) ).
    DATA(lo_error_cut) = NEW zcl_replenishment_req_service(
      io_api = lo_error_api ).
    DATA(ls_error_result) = lo_error_cut->create_from_suggestions(
      it_suggestions = VALUE #(
        ( material                    = 'MAT-REQ'
          plant                       = '1000'
          base_unit                   = 'EA'
          required_date               = '20261115'
          procurement_type            = 'F'
          suggested_base_quantity     = '1.000'
          suggested_receipt_count     = 1
          final_receipt_base_quantity = '1.000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_error_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = '06'
      act = ls_error_result-messages[ 1 ]-id ).
    cl_abap_unit_assert=>assert_equals(
      exp = '123'
      act = ls_error_result-messages[ 1 ]-number ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PRITEM'
      act = ls_error_result-messages[ 1 ]-parameter ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_error_result-messages[ 1 ]-row ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'PLANT'
      act = ls_error_result-messages[ 1 ]-field ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00010'
      act = ls_error_result-messages[ 1 ]-item_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = ls_error_result-messages[ 1 ]-source_suggestion_index ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_error_api->get_rollback_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_error_api->get_commit_count( ) ).

    DATA(lo_missing_number_api) = NEW lcl_replenishment_req_api( ).
    lo_missing_number_api->set_write_result( is_result = VALUE #(
      is_successful = abap_true ) ).
    DATA(lo_missing_number_cut) = NEW zcl_replenishment_req_service(
      io_api = lo_missing_number_api ).
    DATA(ls_missing_number_result) =
      lo_missing_number_cut->create_from_suggestions(
        it_suggestions = VALUE #(
          ( material                    = 'MAT-REQ'
            plant                       = '1000'
            base_unit                   = 'EA'
            required_date               = '20261115'
            procurement_type            = 'F'
            suggested_base_quantity     = '1.000'
            suggested_receipt_count     = 1
            final_receipt_base_quantity = '1.000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_missing_number_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_missing_number_api->get_rollback_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_missing_number_api->get_commit_count( ) ).

    DATA(lo_commit_api) = NEW lcl_replenishment_req_api( ).
    lo_commit_api->set_write_result( is_result = VALUE #(
      requisition_number = '0010001235'
      is_successful      = abap_true ) ).
    lo_commit_api->set_commit_result( is_result = VALUE #(
      is_successful = abap_false
      message       = VALUE #( type       = 'E'
                               id         = '00'
                               number     = '001'
                               message    = 'Commit failed'
                               message_v1 = 'COMMIT' ) ) ).
    DATA(lo_commit_cut) = NEW zcl_replenishment_req_service(
      io_api = lo_commit_api ).
    DATA(ls_commit_result) = lo_commit_cut->create_from_suggestions(
      it_suggestions = VALUE #(
        ( material                    = 'MAT-REQ'
          plant                       = '1000'
          base_unit                   = 'EA'
          required_date               = '20261115'
          procurement_type            = 'F'
          suggested_base_quantity     = '1.000'
          suggested_receipt_count     = 1
          final_receipt_base_quantity = '1.000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_commit_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_commit_api->get_commit_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_commit_api->get_rollback_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00'
      act = ls_commit_result-messages[ 1 ]-id ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'COMMIT'
      act = ls_commit_result-messages[ 1 ]-message_v1 ).
  ENDMETHOD.

  METHOD handles_covered_suggestions.
    DATA(lo_api) = NEW lcl_replenishment_req_api( ).
    DATA(lo_cut) = NEW zcl_replenishment_req_service( io_api = lo_api ).

    DATA(ls_result) = lo_cut->create_from_suggestions(
      it_suggestions = VALUE #(
        ( material                = 'MAT-COVERED'
          plant                   = '1000'
          base_unit               = 'EA'
          required_date           = '20261115'
          suggested_base_quantity = '0.000' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_result-is_successful ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-bapi_was_called ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_result-is_committed ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( ls_result-messages ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_create_count( ) ).
  ENDMETHOD.

  METHOD rejects_bad_repl_req.
    DATA(lo_api) = NEW lcl_replenishment_req_api( ).
    DATA(lo_cut) = NEW zcl_replenishment_req_service( io_api = lo_api ).
    DATA lv_rejected TYPE abap_bool.
    DATA lv_bad_lot_split_rejected TYPE abap_bool.
    DATA lv_inhouse_route_rejected TYPE abap_bool.
    DATA lv_ambiguous_route_rejected TYPE abap_bool.
    DATA lv_special_route_rejected TYPE abap_bool.
    DATA lv_missing_route_rejected TYPE abap_bool.
    DATA lv_duplicate_control_rejected TYPE abap_bool.
    DATA lv_bad_range_control TYPE abap_bool.
    DATA lv_covered_control_rejected TYPE abap_bool.
    DATA lv_empty_control_rejected TYPE abap_bool.
    DATA lv_partial_source_rejected TYPE abap_bool.
    DATA lv_partial_agreement_rejected TYPE abap_bool.
    DATA lv_mixed_source_rejected TYPE abap_bool.
    DATA(lt_control_test_suggestions) =
      VALUE zcl_prod_comp_service=>ty_comp_replenishments(
        ( material                    = 'MAT-REQ'
          plant                       = '1000'
          base_unit                   = 'EA'
          required_date               = '20261115'
          procurement_type            = 'F'
          suggested_base_quantity     = '1.000'
          suggested_receipt_count     = 1
          final_receipt_base_quantity = '1.000' )
        ( material                = 'MAT-COVERED'
          plant                   = '1000'
          base_unit               = 'EA'
          required_date           = '20261116'
          suggested_base_quantity = '0.000' ) ).

    TRY.
        lo_cut->create_from_suggestions(
          it_suggestions = VALUE #(
            ( material                = 'MAT-REQ'
          plant                       = '1000'
          base_unit                   = 'EA'
          required_date               = '20261115'
          suggested_base_quantity     = '-1.000'
          suggested_receipt_count     = 1
          final_receipt_base_quantity = '-1.000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_rejected = abap_true.
    ENDTRY.

    TRY.
        lo_cut->create_from_suggestions(
          it_suggestions = VALUE #(
            ( material                    = 'MAT-REQ'
              plant                       = '1000'
              base_unit                   = 'EA'
              required_date               = '20261115'
              procurement_type            = 'F'
              maximum_base_quantity       = '2.000'
              suggested_base_quantity     = '4.000'
              suggested_receipt_count     = 2
              final_receipt_base_quantity = '1.000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_bad_lot_split_rejected = abap_true.
    ENDTRY.

    TRY.
        lo_cut->create_from_suggestions(
          it_suggestions = VALUE #(
            ( material                    = 'MAT-INHOUSE'
              plant                       = '1000'
              base_unit                   = 'EA'
              required_date               = '20261115'
              procurement_type            = 'E'
              suggested_base_quantity     = '1.000'
              suggested_receipt_count     = 1
              final_receipt_base_quantity = '1.000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_inhouse_route_rejected = abap_true.
    ENDTRY.

    TRY.
        lo_cut->create_from_suggestions(
          it_suggestions = VALUE #(
            ( material                    = 'MAT-AMBIGUOUS'
              plant                       = '1000'
              base_unit                   = 'EA'
              required_date               = '20261115'
              procurement_type            = 'X'
              suggested_base_quantity     = '1.000'
              suggested_receipt_count     = 1
              final_receipt_base_quantity = '1.000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_ambiguous_route_rejected = abap_true.
    ENDTRY.

    TRY.
        lo_cut->create_from_suggestions(
          it_suggestions = VALUE #(
            ( material                    = 'MAT-SPECIAL'
              plant                       = '1000'
              base_unit                   = 'EA'
              required_date               = '20261115'
              procurement_type            = 'F'
              special_procurement_key     = '30'
              suggested_base_quantity     = '1.000'
              suggested_receipt_count     = 1
              final_receipt_base_quantity = '1.000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_special_route_rejected = abap_true.
    ENDTRY.

    TRY.
        lo_cut->create_from_suggestions(
          it_suggestions = VALUE #(
            ( material                    = 'MAT-NO-POLICY'
              plant                       = '1000'
              base_unit                   = 'EA'
              required_date               = '20261115'
              suggested_base_quantity     = '1.000'
              suggested_receipt_count     = 1
              final_receipt_base_quantity = '1.000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_missing_route_rejected = abap_true.
    ENDTRY.

    TRY.
        lo_cut->create_from_suggestions(
          it_suggestions         = lt_control_test_suggestions
          it_purchasing_controls = VALUE #(
            ( source_suggestion_index = 1 purchasing_group = '001' )
            ( source_suggestion_index = 1 purchasing_group = '002' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_duplicate_control_rejected = abap_true.
    ENDTRY.

    TRY.
        lo_cut->create_from_suggestions(
          it_suggestions         = lt_control_test_suggestions
          it_purchasing_controls = VALUE #(
            ( source_suggestion_index = 3 purchasing_org = '1000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_bad_range_control = abap_true.
    ENDTRY.

    TRY.
        lo_cut->create_from_suggestions(
          it_suggestions         = lt_control_test_suggestions
          it_purchasing_controls = VALUE #(
            ( source_suggestion_index = 2 purchasing_org = '1000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_covered_control_rejected = abap_true.
    ENDTRY.

    TRY.
        lo_cut->create_from_suggestions(
          it_suggestions         = lt_control_test_suggestions
          it_purchasing_controls = VALUE #(
            ( source_suggestion_index = 1 ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_empty_control_rejected = abap_true.
    ENDTRY.

    TRY.
        lo_cut->create_from_suggestions(
          it_suggestions = VALUE #(
            ( material                    = 'MAT-PARTIAL-SOURCE'
              plant                       = '1000'
              base_unit                   = 'EA'
              required_date               = '20261115'
              procurement_type            = 'F'
              source_vendor               = '0000100001'
              suggested_base_quantity     = '1.000'
              suggested_receipt_count     = 1
              final_receipt_base_quantity = '1.000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_partial_source_rejected = abap_true.
    ENDTRY.

    TRY.
        lo_cut->create_from_suggestions(
          it_suggestions = VALUE #(
            ( material                    = 'MAT-PARTIAL-AGREEMENT'
              plant                       = '1000'
              base_unit                   = 'EA'
              required_date               = '20261115'
              procurement_type            = 'F'
              source_vendor               = '0000100001'
              source_purchasing_org       = '1000'
              source_agreement            = '4500000001'
              suggested_base_quantity     = '1.000'
              suggested_receipt_count     = 1
              final_receipt_base_quantity = '1.000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_partial_agreement_rejected = abap_true.
    ENDTRY.

    TRY.
        lo_cut->create_from_suggestions(
          it_suggestions = VALUE #(
            ( material                    = 'MAT-MIXED-SOURCES'
              plant                       = '1000'
              base_unit                   = 'EA'
              required_date               = '20261115'
              procurement_type            = 'F'
              source_vendor               = '0000100001'
              source_purchasing_org       = '1000'
              source_info_record          = '0000001234'
              source_category             = '0'
              source_agreement            = '4500000001'
              source_agreement_item       = '00010'
              suggested_base_quantity     = '1.000'
              suggested_receipt_count     = 1
              final_receipt_base_quantity = '1.000' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_mixed_source_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_bad_lot_split_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_inhouse_route_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_ambiguous_route_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_special_route_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_missing_route_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_duplicate_control_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_bad_range_control ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_covered_control_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_empty_control_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_partial_source_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_partial_agreement_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_mixed_source_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_api->get_create_count( ) ).
  ENDMETHOD.
ENDCLASS.
