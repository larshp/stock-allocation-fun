CLASS lcl_repl_source_repo_double DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_repl_source_repo.
    METHODS set_records
      IMPORTING
        it_records TYPE zif_repl_source_repo=>ty_info_records.
    METHODS set_outline_agreements
      IMPORTING
        it_agreements TYPE zif_repl_source_repo=>ty_outline_agreements.
    METHODS set_source_contexts
      IMPORTING
        it_contexts TYPE zif_repl_source_repo=>ty_source_contexts.
    METHODS set_quota_arrangements
      IMPORTING
        it_arrangements TYPE zif_repl_source_repo=>ty_quota_arrangements.
    METHODS set_quota_rounding_profiles
      IMPORTING
        it_profiles TYPE zif_repl_source_repo=>ty_quota_rounding_profiles.
    METHODS set_quota_usage_rules
      IMPORTING
        it_rules TYPE zif_repl_source_repo=>ty_quota_usage_rules.
    METHODS get_read_count
      RETURNING
        VALUE(rv_count) TYPE i.
    METHODS get_quota_read_count
      RETURNING
        VALUE(rv_count) TYPE i.
    METHODS get_quota_usage_read_count
      RETURNING
        VALUE(rv_count) TYPE i.
  PRIVATE SECTION.
    DATA mt_records TYPE zif_repl_source_repo=>ty_info_records.
    DATA mt_outline_agreements TYPE
      zif_repl_source_repo=>ty_outline_agreements.
    DATA mt_source_contexts TYPE zif_repl_source_repo=>ty_source_contexts.
    DATA mt_quota_arrangements TYPE
      zif_repl_source_repo=>ty_quota_arrangements.
    DATA mt_quota_rounding_profiles TYPE
      zif_repl_source_repo=>ty_quota_rounding_profiles.
    DATA mt_quota_usage_rules TYPE
      zif_repl_source_repo=>ty_quota_usage_rules.
    DATA mv_read_count TYPE i.
    DATA mv_quota_read_count TYPE i.
    DATA mv_quota_usage_read_count TYPE i.
    DATA mv_contexts_configured TYPE abap_bool.
ENDCLASS.

CLASS lcl_repl_source_repo_double IMPLEMENTATION.
  METHOD set_records.
    mt_records = it_records.
  ENDMETHOD.

  METHOD set_outline_agreements.
    mt_outline_agreements = it_agreements.
  ENDMETHOD.

  METHOD set_source_contexts.
    mt_source_contexts = it_contexts.
    mv_contexts_configured = abap_true.
  ENDMETHOD.

  METHOD set_quota_arrangements.
    mt_quota_arrangements = it_arrangements.
  ENDMETHOD.

  METHOD set_quota_rounding_profiles.
    mt_quota_rounding_profiles = it_profiles.
  ENDMETHOD.

  METHOD set_quota_usage_rules.
    mt_quota_usage_rules = it_rules.
  ENDMETHOD.

  METHOD get_read_count.
    rv_count = mv_read_count.
  ENDMETHOD.

  METHOD get_quota_read_count.
    rv_count = mv_quota_read_count.
  ENDMETHOD.

  METHOD get_quota_usage_read_count.
    rv_count = mv_quota_usage_read_count.
  ENDMETHOD.

  METHOD zif_repl_source_repo~get_candidates_bulk.
    ADD 1 TO mv_read_count.
    rt_records = mt_records.
  ENDMETHOD.

  METHOD zif_repl_source_repo~get_outline_agreements_bulk.
    rt_agreements = mt_outline_agreements.
  ENDMETHOD.

  METHOD zif_repl_source_repo~get_source_contexts_bulk.
    IF mv_contexts_configured = abap_true.
      rt_contexts = mt_source_contexts.
      RETURN.
    ENDIF.
    LOOP AT it_requests INTO DATA(ls_request).
      READ TABLE rt_contexts TRANSPORTING NO FIELDS
        WITH KEY material = ls_request-material
                 plant = ls_request-plant.
      IF sy-subrc = 0.
        CONTINUE.
      ENDIF.
      APPEND VALUE #(
        material = ls_request-material
        plant    = ls_request-plant ) TO rt_contexts.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_repl_source_repo~get_quota_arrangements_bulk.
    ADD 1 TO mv_quota_read_count.
    rt_arrangements = mt_quota_arrangements.
  ENDMETHOD.

  METHOD zif_repl_source_repo~get_quota_roundings_bulk.
    LOOP AT mt_quota_rounding_profiles INTO DATA(ls_profile).
      READ TABLE it_profile_keys TRANSPORTING NO FIELDS
        WITH KEY plant = ls_profile-plant
                 rounding_profile = ls_profile-rounding_profile.
      IF sy-subrc = 0.
        APPEND ls_profile TO rt_profiles.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_repl_source_repo~get_quota_usage_rules_bulk.
    ADD 1 TO mv_quota_usage_read_count.
    rt_rules = mt_quota_usage_rules.
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_repl_source_service DEFINITION FINAL
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS lists_valid_pir_sources FOR TESTING.
    METHODS maps_candidates_to_suggestions FOR TESTING.
    METHODS requires_pir_source_org FOR TESTING.
    METHODS maps_outline_to_suggestions FOR TESTING.
    METHODS requires_outline_source_org FOR TESTING.
    METHODS combines_suggestion_options FOR TESTING.
    METHODS applies_selected_source_option FOR TESTING.
    METHODS rejects_mismatched_option FOR TESTING.
    METHODS applies_source_options_in_bulk FOR TESTING.
    METHODS rejects_duplicate_choice FOR TESTING.
    METHODS exposes_auto_source_flag FOR TESTING.
    METHODS filters_pir_source_list_use FOR TESTING.
    METHODS rejects_invalid_source_filters FOR TESTING.
    METHODS evaluates_quantity_limits FOR TESTING.
    METHODS reports_missing_uom_factor FOR TESTING.
    METHODS flags_invalid_qty_range FOR TESTING.
    METHODS rejects_missing_quantity_unit FOR TESTING.
    METHODS ranks_preferred_vendor_first FOR TESTING.
    METHODS ranks_by_quota_rating FOR TESTING.
    METHODS orders_zero_tie_by_item FOR TESTING.
    METHODS simulates_quota_by_due_date FOR TESTING.
    METHODS simulates_split_quota FOR TESTING.
    METHODS respects_quota_pr_usage FOR TESTING.
    METHODS filters_quota_items FOR TESTING.
    METHODS skips_quota_read_without_usage FOR TESTING.
    METHODS requires_quota_usage_rule FOR TESTING.
    METHODS applies_source_list_rules FOR TESTING.
    METHODS filters_source_list_by_date FOR TESTING.
    METHODS excludes_global_source_block FOR TESTING.
    METHODS excludes_missing_mat_plant FOR TESTING.
    METHODS filters_each_delivery_date FOR TESTING.
    METHODS rejects_incomplete_pir_request FOR TESTING.
    METHODS lists_valid_outline_sources FOR TESTING.
    METHODS filters_bad_outline_sources FOR TESTING.
    METHODS rejects_bad_agreement_request FOR TESTING.
    METHODS respects_general_vendor_block FOR TESTING.
ENDCLASS.

CLASS ltcl_repl_source_service IMPLEMENTATION.
  METHOD maps_candidates_to_suggestions.
    DATA(lo_repository) = NEW lcl_repl_source_repo_double( ).
    lo_repository->set_records( it_records = VALUE #(
      ( material = 'MAT-1' purchasing_org = '1000'
        vendor = '0000100001' info_record = '0000000001'
        source_category = '0' purchase_order_unit = 'EA'
        base_unit = 'EA' minimum_order_quantity = '1.000'
        maximum_order_quantity = '5.000' )
      ( material = 'MAT-2' purchasing_org = '1000'
        vendor = '0000100002' info_record = '0000000002'
        source_category = '0' purchase_order_unit = 'EA'
        base_unit = 'EA' minimum_order_quantity = '1.000'
        maximum_order_quantity = '3.000' ) ) ).
    DATA(lo_cut) = NEW zcl_repl_source_service(
      io_repository = lo_repository ).

    DATA(lt_options) = lo_cut->get_suggestion_pir_candidates(
      it_suggestions    = VALUE #(
        ( material = 'MAT-INT' plant = '1000' base_unit = 'EA'
          required_date = '20261015' procurement_type = 'E'
          suggested_base_quantity = '2.000' )
        ( material = 'MAT-1' plant = '1000' base_unit = 'EA'
          required_date = '20261015' procurement_type = 'F'
          suggested_base_quantity = '3.000' )
        ( material = 'MAT-SPEC' plant = '1000' base_unit = 'EA'
          required_date = '20261015' procurement_type = 'F'
          special_procurement_key = '30'
          suggested_base_quantity = '2.000' )
        ( material = 'MAT-2' plant = '1000' base_unit = 'EA'
          required_date = '20261016' procurement_type = 'F'
          suggested_base_quantity = '4.000' )
        ( material = 'MAT-ZERO' plant = '1000' base_unit = 'EA'
          procurement_type = 'F'
          suggested_base_quantity = '0.000' ) )
      iv_purchasing_org = '1000' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_options ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lt_options[ 1 ]-suggestion_index ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lt_options[ 1 ]-candidate-request_index ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100001'
      act = lt_options[ 1 ]-candidate-vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV d( '20261015' )
      act = lt_options[ 1 ]-candidate-delivery_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = zcl_repl_source_service=>c_quantity_limit_within_range
      act = lt_options[ 1 ]-candidate-quantity_limit_status ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = lt_options[ 2 ]-suggestion_index ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lt_options[ 2 ]-candidate-request_index ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100002'
      act = lt_options[ 2 ]-candidate-vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV d( '20261016' )
      act = lt_options[ 2 ]-candidate-delivery_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = zcl_repl_source_service=>c_quantity_limit_above_maximum
      act = lt_options[ 2 ]-candidate-quantity_limit_status ).
  ENDMETHOD.

  METHOD requires_pir_source_org.
    DATA lv_org_rejected TYPE abap_bool.
    DATA(lo_repository) = NEW lcl_repl_source_repo_double( ).
    DATA(lo_cut) = NEW zcl_repl_source_service(
      io_repository = lo_repository ).

    TRY.
        DATA(lt_options) = lo_cut->get_suggestion_pir_candidates(
          it_suggestions    = VALUE #(
            ( material = 'MAT-1' plant = '1000' base_unit = 'EA'
              required_date = '20261015' procurement_type = 'F'
              suggested_base_quantity = '1.000' ) )
          iv_purchasing_org = '' ).
      CATCH zcx_invalid_stock_request.
        lv_org_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_org_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD maps_outline_to_suggestions.
    DATA(lo_repository) = NEW lcl_repl_source_repo_double( ).
    lo_repository->set_source_contexts(
      it_contexts = VALUE #(
        ( material = 'MAT-1' plant = '1000'
          source_list_required = 'X' ) ) ).
    lo_repository->set_outline_agreements(
      it_agreements = VALUE #(
        ( material = 'MAT-1' plant = '1000'
          purchasing_document = '4500000001' purchasing_item = '00010'
          purchasing_org = '1000' vendor = '0000100001'
          document_category = 'K' )
        ( material = 'MAT-1' plant = '1000'
          purchasing_document = '4500000002' purchasing_item = '00020'
          purchasing_org = '1000' vendor = '0000100002'
          document_category = 'L' ) ) ).
    DATA(lo_cut) = NEW zcl_repl_source_service(
      io_repository = lo_repository ).

    DATA(lt_options) = lo_cut->get_suggestion_outline_sources(
      it_suggestions      = VALUE #(
        ( material = 'MAT-INT' plant = '1000' base_unit = 'EA'
          required_date = '20261015' procurement_type = 'E'
          suggested_base_quantity = '2.000' )
        ( material = 'MAT-1' plant = '1000' base_unit = 'EA'
          required_date = '20261015' procurement_type = 'F'
          suggested_base_quantity = '3.000' )
        ( material = 'MAT-SPEC' plant = '1000' base_unit = 'EA'
          required_date = '20261015' procurement_type = 'F'
          special_procurement_key = '30'
          suggested_base_quantity = '2.000' )
        ( material = 'MAT-ZERO' plant = '1000' procurement_type = 'F'
          suggested_base_quantity = '0.000' ) )
      iv_purchasing_org   = '1000'
      iv_preferred_vendor = '0000100002' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_options ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lt_options[ 1 ]-suggestion_index ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lt_options[ 1 ]-candidate-request_index ).
    cl_abap_unit_assert=>assert_equals(
      exp = '4500000002'
      act = lt_options[ 1 ]-candidate-purchasing_document ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100002'
      act = lt_options[ 1 ]-candidate-vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV d( '20261015' )
      act = lt_options[ 1 ]-candidate-delivery_date ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_options[ 1 ]-candidate-is_preferred_vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lt_options[ 1 ]-candidate-candidate_rank ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lt_options[ 2 ]-suggestion_index ).
    cl_abap_unit_assert=>assert_equals(
      exp = '4500000001'
      act = lt_options[ 2 ]-candidate-purchasing_document ).
  ENDMETHOD.

  METHOD requires_outline_source_org.
    DATA lv_org_rejected TYPE abap_bool.
    DATA(lo_repository) = NEW lcl_repl_source_repo_double( ).
    DATA(lo_cut) = NEW zcl_repl_source_service(
      io_repository = lo_repository ).

    TRY.
        DATA(lt_options) = lo_cut->get_suggestion_outline_sources(
          it_suggestions    = VALUE #(
            ( material = 'MAT-1' plant = '1000' base_unit = 'EA'
              required_date = '20261015' procurement_type = 'F'
              suggested_base_quantity = '1.000' ) )
          iv_purchasing_org = '' ).
      CATCH zcx_invalid_stock_request.
        lv_org_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_org_rejected ).
  ENDMETHOD.

  METHOD combines_suggestion_options.
    DATA(lo_repository) = NEW lcl_repl_source_repo_double( ).
    lo_repository->set_records(
      it_records = VALUE #(
        ( material = 'MAT-1' purchasing_org = '1000'
          vendor = '0000100001' info_record = '0000000001'
          source_category = '0' purchase_order_unit = 'EA'
          base_unit = 'EA' ) ) ).
    lo_repository->set_outline_agreements(
      it_agreements = VALUE #(
        ( material = 'MAT-1' plant = '1000'
          purchasing_document = '4500000001' purchasing_item = '00010'
          purchasing_org = '1000' vendor = '0000100002'
          document_category = 'K' ) ) ).
    DATA(lo_cut) = NEW zcl_repl_source_service(
      io_repository = lo_repository ).

    DATA(lt_options) = lo_cut->get_suggestion_source_options(
      it_suggestions    = VALUE #(
        ( material = 'MAT-1' plant = '1000' base_unit = 'EA'
          required_date = '20261015' procurement_type = 'F'
          suggested_base_quantity = '3.000' ) )
      iv_purchasing_org = '1000' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_options ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lt_options[ 1 ]-suggestion_index ).
    cl_abap_unit_assert=>assert_equals(
      exp = zcl_repl_source_service=>c_suggestion_source_pir
      act = lt_options[ 1 ]-source_kind ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lt_options[ 1 ]-candidate_rank ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000001'
      act = lt_options[ 1 ]-pir_candidate-info_record ).
    cl_abap_unit_assert=>assert_equals(
      exp = zcl_repl_source_service=>c_suggestion_source_outline
      act = lt_options[ 2 ]-source_kind ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lt_options[ 2 ]-candidate_rank ).
    cl_abap_unit_assert=>assert_equals(
      exp = '4500000001'
      act = lt_options[ 2 ]-outline_candidate-purchasing_document ).
  ENDMETHOD.

  METHOD applies_selected_source_option.
    DATA(lt_suggestions) = VALUE zcl_prod_comp_service=>ty_comp_replenishments(
      ( material = 'MAT-1' plant = '1000' base_unit = 'EA'
        required_date = '20261015' procurement_type = 'F'
        suggested_base_quantity = '3.000' ) ).

    DATA(lt_pir_selected) = zcl_repl_source_service=>apply_suggestion_source_option(
      it_suggestions = lt_suggestions
      is_option      = VALUE #(
        suggestion_index = 1 source_kind =
          zcl_repl_source_service=>c_suggestion_source_pir
        candidate_rank = 1
        pir_candidate = VALUE #(
          request_index = 1 candidate_rank = 1
          material = 'MAT-1' plant = '1000'
          purchasing_org = '1000' delivery_date = '20261015'
          vendor = '0000100001' info_record = '0000000001'
          source_category = '0' planned_delivery_days = 4 ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = '0000100001'
      act = lt_pir_selected[ 1 ]-source_vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000001'
      act = lt_pir_selected[ 1 ]-source_info_record ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = lt_pir_selected[ 1 ]-source_planned_delivery_days ).
    cl_abap_unit_assert=>assert_initial(
      act = lt_pir_selected[ 1 ]-source_agreement ).
    cl_abap_unit_assert=>assert_initial(
      act = lt_suggestions[ 1 ]-source_vendor ).

    DATA(lt_outline_selected) = zcl_repl_source_service=>apply_suggestion_source_option(
      it_suggestions = lt_pir_selected
      is_option      = VALUE #(
        suggestion_index = 1 source_kind =
          zcl_repl_source_service=>c_suggestion_source_outline
        candidate_rank = 1
        outline_candidate = VALUE #(
          request_index = 1 candidate_rank = 1
          material = 'MAT-1' plant = '1000'
          purchasing_org = '1000' delivery_date = '20261015'
          vendor = '0000100002' purchasing_document = '4500000001'
          purchasing_item = '00010' document_category = 'K' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = '0000100002'
      act = lt_outline_selected[ 1 ]-source_vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = '4500000001'
      act = lt_outline_selected[ 1 ]-source_agreement ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00010'
      act = lt_outline_selected[ 1 ]-source_agreement_item ).
    cl_abap_unit_assert=>assert_initial(
      act = lt_outline_selected[ 1 ]-source_info_record ).
    cl_abap_unit_assert=>assert_initial(
      act = lt_outline_selected[ 1 ]-source_planned_delivery_days ).
  ENDMETHOD.

  METHOD rejects_mismatched_option.
    DATA lv_option_rejected TYPE abap_bool.
    DATA(lt_suggestions) = VALUE zcl_prod_comp_service=>ty_comp_replenishments(
      ( material = 'MAT-1' plant = '1000' base_unit = 'EA'
        required_date = '20261015' procurement_type = 'F'
        suggested_base_quantity = '3.000' ) ).

    TRY.
        zcl_repl_source_service=>apply_suggestion_source_option(
          it_suggestions = lt_suggestions
          is_option      = VALUE #(
            suggestion_index = 1 source_kind =
              zcl_repl_source_service=>c_suggestion_source_pir
            candidate_rank = 1
            pir_candidate = VALUE #(
              request_index = 1 candidate_rank = 1
              material = 'MAT-OTHER' plant = '1000'
              purchasing_org = '1000' delivery_date = '20261015'
              vendor = '0000100001' info_record = '0000000001'
              source_category = '0' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_option_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_option_rejected ).
  ENDMETHOD.

  METHOD applies_source_options_in_bulk.
    DATA(lt_suggestions) = VALUE zcl_prod_comp_service=>ty_comp_replenishments(
      ( material = 'MAT-INT' plant = '1000' base_unit = 'EA'
        required_date = '20261015' procurement_type = 'E'
        suggested_base_quantity = '2.000' )
      ( material = 'MAT-1' plant = '1000' base_unit = 'EA'
        required_date = '20261015' procurement_type = 'F'
        suggested_base_quantity = '3.000' )
      ( material = 'MAT-2' plant = '1000' base_unit = 'EA'
        required_date = '20261016' procurement_type = 'F'
        suggested_base_quantity = '4.000' ) ).

    DATA(lt_selected) = zcl_repl_source_service=>apply_selected_source_options(
      it_suggestions = lt_suggestions
      it_options     = VALUE #(
        ( suggestion_index = 2 source_kind =
            zcl_repl_source_service=>c_suggestion_source_pir
          candidate_rank = 1
          pir_candidate = VALUE #(
            request_index = 1 candidate_rank = 1
            material = 'MAT-1' plant = '1000'
            purchasing_org = '1000' delivery_date = '20261015'
            vendor = '0000100001' info_record = '0000000001'
            source_category = '0' ) )
        ( suggestion_index = 3 source_kind =
            zcl_repl_source_service=>c_suggestion_source_outline
          candidate_rank = 1
          outline_candidate = VALUE #(
            request_index = 2 candidate_rank = 1
            material = 'MAT-2' plant = '1000'
            purchasing_org = '1000' delivery_date = '20261016'
            vendor = '0000100002' purchasing_document = '4500000001'
            purchasing_item = '00010' document_category = 'K' ) ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_selected ) ).
    cl_abap_unit_assert=>assert_initial(
      act = lt_selected[ 1 ]-source_vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100001'
      act = lt_selected[ 2 ]-source_vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000001'
      act = lt_selected[ 2 ]-source_info_record ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100002'
      act = lt_selected[ 3 ]-source_vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = '4500000001'
      act = lt_selected[ 3 ]-source_agreement ).
    cl_abap_unit_assert=>assert_initial(
      act = lt_suggestions[ 2 ]-source_vendor ).
  ENDMETHOD.

  METHOD rejects_duplicate_choice.
    DATA lv_duplicate_rejected TYPE abap_bool.
    DATA(lt_suggestions) = VALUE zcl_prod_comp_service=>ty_comp_replenishments(
      ( material = 'MAT-1' plant = '1000' base_unit = 'EA'
        required_date = '20261015' procurement_type = 'F'
        suggested_base_quantity = '3.000' ) ).

    TRY.
        zcl_repl_source_service=>apply_selected_source_options(
          it_suggestions = lt_suggestions
          it_options     = VALUE #(
            ( suggestion_index = 1 source_kind =
                zcl_repl_source_service=>c_suggestion_source_pir
              candidate_rank = 1
              pir_candidate = VALUE #(
                request_index = 1 candidate_rank = 1
                material = 'MAT-1' plant = '1000'
                purchasing_org = '1000' delivery_date = '20261015'
                vendor = '0000100001' info_record = '0000000001'
                source_category = '0' ) )
            ( suggestion_index = 1 source_kind =
                zcl_repl_source_service=>c_suggestion_source_outline
              candidate_rank = 1
              outline_candidate = VALUE #(
                request_index = 1 candidate_rank = 1
                material = 'MAT-1' plant = '1000'
                purchasing_org = '1000' delivery_date = '20261015'
                vendor = '0000100002' purchasing_document = '4500000001'
                purchasing_item = '00010' document_category = 'K' ) ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_duplicate_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_duplicate_rejected ).
  ENDMETHOD.

  METHOD exposes_auto_source_flag.
    DATA(lo_repository) = NEW lcl_repl_source_repo_double( ).
    lo_repository->set_records(
      it_records = VALUE #(
        ( material              = 'MAT-1'
          purchasing_org        = '1000'
          vendor                = '0000100001'
          info_record           = '0000000001'
          source_category       = '0'
          auto_source_indicator = 'X' )
        ( material        = 'MAT-1'
          purchasing_org  = '1000'
          vendor          = '0000100002'
          info_record     = '0000000002'
          source_category = '0' ) ) ).
    DATA(lo_cut) = NEW zcl_repl_source_service(
      io_repository = lo_repository ).

    DATA(lt_candidates) = lo_cut->get_valid_pir_candidates(
      it_requests = VALUE #(
        ( material       = 'MAT-1'
          plant          = '1000'
          purchasing_org = '1000'
          delivery_date  = '20261005' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_candidates ) ).
    READ TABLE lt_candidates INTO DATA(ls_relevant)
      WITH KEY vendor = '0000100001'.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = ls_relevant-is_auto_source_relevant ).
    READ TABLE lt_candidates INTO DATA(ls_not_relevant)
      WITH KEY vendor = '0000100002'.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = ls_not_relevant-is_auto_source_relevant ).
    cl_abap_unit_assert=>assert_equals(
      exp = zcl_repl_source_service=>c_quantity_limit_not_requested
      act = lt_candidates[ 1 ]-quantity_limit_status ).

    lt_candidates = lo_cut->get_valid_pir_candidates(
      it_requests            = VALUE #(
        ( material       = 'MAT-1'
          plant          = '1000'
          purchasing_org = '1000'
          delivery_date  = '20261005' ) )
      iv_require_auto_source = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_candidates ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100001'
      act = lt_candidates[ 1 ]-vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_candidates[ 1 ]-is_auto_source_relevant ).
  ENDMETHOD.

  METHOD filters_pir_source_list_use.
    DATA(lo_repository) = NEW lcl_repl_source_repo_double( ).
    lo_repository->set_records(
      it_records = VALUE #(
        ( material        = 'MAT-1'
          purchasing_org  = '1000'
          vendor          = '0000100001'
          info_record     = '0000000001'
          source_category = '0' )
        ( material        = 'MAT-1'
          purchasing_org  = '1000'
          vendor          = '0000100002'
          info_record     = '0000000002'
          source_category = '0' )
        ( material        = 'MAT-1'
          purchasing_org  = '1000'
          vendor          = '0000100003'
          info_record     = '0000000003'
          source_category = '0' ) ) ).
    lo_repository->set_source_contexts(
      it_contexts = VALUE #(
        ( material               = 'MAT-1'
          plant                  = '1000'
          source_list_vendor     = '0000100001'
          source_list_fixed      = 'X'
          source_list_mrp_usage  = '1'
          source_list_valid_from = '20261001'
          source_list_valid_to   = '20261231' )
        ( material               = 'MAT-1'
          plant                  = '1000'
          source_list_vendor     = '0000100002'
          source_list_valid_from = '20261001'
          source_list_valid_to   = '20261231' ) ) ).
    DATA(lo_cut) = NEW zcl_repl_source_service(
      io_repository = lo_repository ).

    DATA(lt_candidates) = lo_cut->get_valid_pir_candidates(
      it_requests = VALUE #(
        ( material       = 'MAT-1'
          plant          = '1000'
          purchasing_org = '1000'
          delivery_date  = '20261005' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_candidates ) ).

    lt_candidates = lo_cut->get_valid_pir_candidates(
      it_requests              = VALUE #(
        ( material       = 'MAT-1'
          plant          = '1000'
          purchasing_org = '1000'
          delivery_date  = '20261005' ) )
      iv_require_source_listed = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_candidates ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100001'
      act = lt_candidates[ 1 ]-vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_candidates[ 1 ]-is_source_listed ).

    lt_candidates = lo_cut->get_valid_pir_candidates(
      it_requests             = VALUE #(
        ( material       = 'MAT-1'
          plant          = '1000'
          purchasing_org = '1000'
          delivery_date  = '20261005' ) )
      iv_require_mrp_relevant = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_candidates ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100001'
      act = lt_candidates[ 1 ]-vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_candidates[ 1 ]-is_mrp_relevant ).

    lt_candidates = lo_cut->get_valid_pir_candidates(
      it_requests             = VALUE #(
        ( material       = 'MAT-1'
          plant          = '1000'
          purchasing_org = '1000'
          delivery_date  = '20261005' ) )
      iv_require_fixed_source = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_candidates ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100001'
      act = lt_candidates[ 1 ]-vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_candidates[ 1 ]-is_fixed_source ).
  ENDMETHOD.

  METHOD rejects_invalid_source_filters.
    DATA lv_auto_filter_rejected TYPE abap_bool.
    DATA lv_list_filter_rejected TYPE abap_bool.
    DATA lv_fixed_filter_rejected TYPE abap_bool.
    DATA lv_mrp_filter_rejected TYPE abap_bool.
    DATA lv_qty_filter_rejected TYPE abap_bool.
    DATA lv_quota_simulation_rejected TYPE abap_bool.
    DATA(lo_cut) = NEW zcl_repl_source_service(
      io_repository = NEW lcl_repl_source_repo_double( ) ).

    TRY.
        lo_cut->get_valid_pir_candidates(
          it_requests            = VALUE #( )
          iv_require_auto_source = CONV abap_bool( 'Y' ) ).
      CATCH zcx_invalid_stock_request.
        lv_auto_filter_rejected = abap_true.
    ENDTRY.
    TRY.
        lo_cut->get_valid_pir_candidates(
          it_requests              = VALUE #( )
          iv_require_source_listed = CONV abap_bool( 'Y' ) ).
      CATCH zcx_invalid_stock_request.
        lv_list_filter_rejected = abap_true.
    ENDTRY.
    TRY.
        lo_cut->get_valid_pir_candidates(
          it_requests             = VALUE #( )
          iv_require_fixed_source = CONV abap_bool( 'Y' ) ).
      CATCH zcx_invalid_stock_request.
        lv_fixed_filter_rejected = abap_true.
    ENDTRY.
    TRY.
        lo_cut->get_valid_pir_candidates(
          it_requests             = VALUE #( )
          iv_require_mrp_relevant = CONV abap_bool( 'Y' ) ).
      CATCH zcx_invalid_stock_request.
        lv_mrp_filter_rejected = abap_true.
    ENDTRY.
    TRY.
        lo_cut->get_valid_pir_candidates(
          it_requests             = VALUE #( )
          iv_require_qty_in_range = CONV abap_bool( 'Y' ) ).
      CATCH zcx_invalid_stock_request.
        lv_qty_filter_rejected = abap_true.
    ENDTRY.
    TRY.
        lo_cut->get_valid_pir_candidates(
          it_requests                  = VALUE #( )
          iv_simulate_quota_assignment = CONV abap_bool( 'Y' ) ).
      CATCH zcx_invalid_stock_request.
        lv_quota_simulation_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_auto_filter_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_list_filter_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_fixed_filter_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_mrp_filter_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_qty_filter_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_quota_simulation_rejected ).
  ENDMETHOD.

  METHOD evaluates_quantity_limits.
    DATA(lo_repository) = NEW lcl_repl_source_repo_double( ).
    lo_repository->set_records(
      it_records = VALUE #(
        ( material                       = 'MAT-1'
          purchasing_org                 = '1000'
          vendor                         = '0000100001'
          info_record                    = '0000000001'
          source_category                = '0'
          purchase_order_unit            = 'BOX'
          base_unit                      = 'EA'
          order_unit_to_base_numerator   = 12
          order_unit_to_base_denominator = 1
          minimum_order_quantity         = 2
          maximum_order_quantity         = 5 ) ) ).
    DATA(lo_cut) = NEW zcl_repl_source_service(
      io_repository = lo_repository ).

    DATA(lt_candidates) = lo_cut->get_valid_pir_candidates(
      it_requests = VALUE #(
        ( material                = 'MAT-1'
          plant                   = '1000'
          purchasing_org          = '1000'
          delivery_date           = '20261005'
          requested_quantity      = '23.999'
          requested_quantity_unit = 'EA' )
        ( material                = 'MAT-1'
          plant                   = '1000'
          purchasing_org          = '1000'
          delivery_date           = '20261005'
          requested_quantity      = '24'
          requested_quantity_unit = 'EA' )
        ( material                = 'MAT-1'
          plant                   = '1000'
          purchasing_org          = '1000'
          delivery_date           = '20261005'
          requested_quantity      = '60'
          requested_quantity_unit = 'EA' )
        ( material                = 'MAT-1'
          plant                   = '1000'
          purchasing_org          = '1000'
          delivery_date           = '20261005'
          requested_quantity      = '60.001'
          requested_quantity_unit = 'EA' )
        ( material                = 'MAT-1'
          plant                   = '1000'
          purchasing_org          = '1000'
          delivery_date           = '20261005'
          requested_quantity      = '30'
          requested_quantity_unit = 'KG' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 5
      act = lines( lt_candidates ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = zcl_repl_source_service=>c_quantity_limit_below_minimum
      act = lt_candidates[ 1 ]-quantity_limit_status ).
    cl_abap_unit_assert=>assert_equals(
      exp = zcl_repl_source_service=>c_quantity_limit_within_range
      act = lt_candidates[ 2 ]-quantity_limit_status ).
    cl_abap_unit_assert=>assert_equals(
      exp = zcl_repl_source_service=>c_quantity_limit_within_range
      act = lt_candidates[ 3 ]-quantity_limit_status ).
    cl_abap_unit_assert=>assert_equals(
      exp = zcl_repl_source_service=>c_quantity_limit_above_maximum
      act = lt_candidates[ 4 ]-quantity_limit_status ).
    cl_abap_unit_assert=>assert_equals(
      exp = zcl_repl_source_service=>c_quantity_limit_unit_mismatch
      act = lt_candidates[ 5 ]-quantity_limit_status ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( 24 )
      act = lt_candidates[ 2 ]-minimum_order_quantity_base ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( 60 )
      act = lt_candidates[ 2 ]-maximum_order_quantity_base ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BOX'
      act = lt_candidates[ 2 ]-purchase_order_unit ).

    lt_candidates = lo_cut->get_valid_pir_candidates(
      it_requests             = VALUE #(
        ( material                = 'MAT-1'
          plant                   = '1000'
          purchasing_org          = '1000'
          delivery_date           = '20261005'
          requested_quantity      = '23.999'
          requested_quantity_unit = 'EA' )
        ( material                = 'MAT-1'
          plant                   = '1000'
          purchasing_org          = '1000'
          delivery_date           = '20261005'
          requested_quantity      = '24'
          requested_quantity_unit = 'EA' )
        ( material                = 'MAT-1'
          plant                   = '1000'
          purchasing_org          = '1000'
          delivery_date           = '20261005'
          requested_quantity      = '60'
          requested_quantity_unit = 'EA' )
        ( material                = 'MAT-1'
          plant                   = '1000'
          purchasing_org          = '1000'
          delivery_date           = '20261005'
          requested_quantity      = '60.001'
          requested_quantity_unit = 'EA' )
        ( material                = 'MAT-1'
          plant                   = '1000'
          purchasing_org          = '1000'
          delivery_date           = '20261005'
          requested_quantity      = '30'
          requested_quantity_unit = 'KG' ) )
      iv_require_qty_in_range = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_candidates ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lt_candidates[ 1 ]-request_index ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lt_candidates[ 2 ]-request_index ).
    cl_abap_unit_assert=>assert_equals(
      exp = zcl_repl_source_service=>c_quantity_limit_within_range
      act = lt_candidates[ 1 ]-quantity_limit_status ).

    lt_candidates = lo_cut->get_valid_pir_candidates(
      it_requests             = VALUE #(
        ( material       = 'MAT-1'
          plant          = '1000'
          purchasing_org = '1000'
          delivery_date  = '20261005' ) )
      iv_require_qty_in_range = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_candidates ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = zcl_repl_source_service=>c_quantity_limit_not_requested
      act = lt_candidates[ 1 ]-quantity_limit_status ).
  ENDMETHOD.

  METHOD reports_missing_uom_factor.
    DATA(lo_repository) = NEW lcl_repl_source_repo_double( ).
    lo_repository->set_records(
      it_records = VALUE #(
        ( material               = 'MAT-1'
          purchasing_org         = '1000'
          vendor                 = '0000100001'
          info_record            = '0000000001'
          source_category        = '0'
          purchase_order_unit    = 'BOX'
          base_unit              = 'EA'
          minimum_order_quantity = 2
          maximum_order_quantity = 5 ) ) ).
    DATA(lo_cut) = NEW zcl_repl_source_service(
      io_repository = lo_repository ).

    DATA(lt_candidates) = lo_cut->get_valid_pir_candidates(
      it_requests = VALUE #(
        ( material                = 'MAT-1'
          plant                   = '1000'
          purchasing_org          = '1000'
          delivery_date           = '20261005'
          requested_quantity      = '24'
          requested_quantity_unit = 'EA' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = zcl_repl_source_service=>c_quantity_limit_no_conversion
      act = lt_candidates[ 1 ]-quantity_limit_status ).
  ENDMETHOD.

  METHOD flags_invalid_qty_range.
    DATA(lo_repository) = NEW lcl_repl_source_repo_double( ).
    lo_repository->set_records(
      it_records = VALUE #(
        ( material               = 'MAT-1'
          purchasing_org         = '1000'
          vendor                 = '0000100001'
          info_record            = '0000000001'
          source_category        = '0'
          purchase_order_unit    = 'EA'
          base_unit              = 'EA'
          minimum_order_quantity = 10
          maximum_order_quantity = 5 ) ) ).
    DATA(lo_cut) = NEW zcl_repl_source_service(
      io_repository = lo_repository ).

    DATA(lt_candidates) = lo_cut->get_valid_pir_candidates(
      it_requests = VALUE #(
        ( material                = 'MAT-1'
          plant                   = '1000'
          purchasing_org          = '1000'
          delivery_date           = '20261005'
          requested_quantity      = '7'
          requested_quantity_unit = 'EA' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = zcl_repl_source_service=>c_quantity_limit_invalid_range
      act = lt_candidates[ 1 ]-quantity_limit_status ).
  ENDMETHOD.

  METHOD rejects_missing_quantity_unit.
    DATA(lo_repository) = NEW lcl_repl_source_repo_double( ).
    DATA(lo_cut) = NEW zcl_repl_source_service(
      io_repository = lo_repository ).

    TRY.
        lo_cut->get_valid_pir_candidates(
          it_requests = VALUE #(
            ( material           = 'MAT-1'
              plant              = '1000'
              purchasing_org     = '1000'
              delivery_date      = '20261005'
              requested_quantity = '10' ) ) ).
        cl_abap_unit_assert=>fail( ).
      CATCH zcx_invalid_stock_request.
        cl_abap_unit_assert=>assert_true( act = abap_true ).
    ENDTRY.
  ENDMETHOD.

  METHOD lists_valid_pir_sources.
    DATA(lo_repository) = NEW lcl_repl_source_repo_double( ).
    lo_repository->set_records(
      it_records = VALUE #(
        ( material              = 'MAT-1'
          purchasing_org        = '1000'
          vendor                = '0000100001'
          info_record           = '0000000001'
          source_category       = '0'
          planned_delivery_days = 7
          valid_from            = '20260101'
          valid_to              = '20261231' )
        ( material              = 'MAT-1'
          purchasing_org        = '1000'
          record_plant          = '1000'
          vendor                = '0000100002'
          info_record           = '0000000002'
          source_category       = '0'
          planned_delivery_days = 5 )
        ( material        = 'MAT-1'
          purchasing_org  = '1000'
          record_plant    = '2000'
          vendor          = '0000100003'
          info_record     = '0000000003'
          source_category = '0' )
        ( material        = 'MAT-1'
          purchasing_org  = '1000'
          vendor          = '0000100004'
          info_record     = '0000000004'
          source_category = '2' )
        ( material                   = 'MAT-1'
          purchasing_org             = '1000'
          vendor                     = '0000100005'
          info_record                = '0000000005'
          source_category            = '0'
          general_deletion_indicator = 'X' )
        ( material                      = 'MAT-1'
          purchasing_org                = '1000'
          vendor                        = '0000100006'
          info_record                   = '0000000006'
          source_category               = '0'
          purchasing_deletion_indicator = 'X' )
        ( material        = 'MAT-1'
          purchasing_org  = '2000'
          vendor          = '0000100007'
          info_record     = '0000000007'
          source_category = '0' )
        ( material        = 'MAT-2'
          purchasing_org  = '1000'
          vendor          = '0000100008'
          info_record     = '0000000008'
          source_category = '0' )
        ( material        = 'MAT-1'
          purchasing_org  = '1000'
          vendor          = '0000100009'
          info_record     = '0000000009'
          source_category = '0'
          valid_from      = '20261006' )
        ( material        = 'MAT-1'
          purchasing_org  = '1000'
          vendor          = '0000100010'
          info_record     = '0000000010'
          source_category = '0'
          valid_to        = '20261004' ) ) ).
    DATA(lo_cut) = NEW zcl_repl_source_service(
      io_repository = lo_repository ).

    DATA(lt_candidates) = lo_cut->get_valid_pir_candidates(
      it_requests = VALUE #(
        ( material       = 'MAT-1'
          plant          = '1000'
          purchasing_org = '1000'
          delivery_date  = '20261005' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_candidates ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_candidates[ 1 ]-is_plant_specific ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100002'
      act = lt_candidates[ 1 ]-vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lt_candidates[ 1 ]-candidate_rank ).
    cl_abap_unit_assert=>assert_equals(
      exp = 5
      act = lt_candidates[ 1 ]-planned_delivery_days ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = lt_candidates[ 2 ]-is_plant_specific ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100001'
      act = lt_candidates[ 2 ]-vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lt_candidates[ 2 ]-candidate_rank ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV d( '20260101' )
      act = lt_candidates[ 2 ]-valid_from ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV d( '20261231' )
      act = lt_candidates[ 2 ]-valid_to ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lt_candidates[ 2 ]-request_index ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD ranks_preferred_vendor_first.
    DATA(lo_repository) = NEW lcl_repl_source_repo_double( ).
    lo_repository->set_records(
      it_records = VALUE #(
        ( material        = 'MAT-1'
          purchasing_org  = '1000'
          record_plant    = '1000'
          vendor          = '0000100001'
          info_record     = '0000000001'
          source_category = '0' )
        ( material        = 'MAT-1'
          purchasing_org  = '1000'
          vendor          = '0000100002'
          info_record     = '0000000002'
          source_category = '0' ) ) ).
    DATA(lo_cut) = NEW zcl_repl_source_service(
      io_repository = lo_repository ).

    DATA(lt_candidates) = lo_cut->get_valid_pir_candidates(
      it_requests = VALUE #(
        ( material         = 'MAT-1'
          plant            = '1000'
          purchasing_org   = '1000'
          delivery_date    = '20261005'
          preferred_vendor = '0000100002' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_candidates ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lt_candidates[ 1 ]-candidate_rank ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lt_candidates[ 2 ]-candidate_rank ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100002'
      act = lt_candidates[ 1 ]-vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_candidates[ 1 ]-is_preferred_vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = lt_candidates[ 1 ]-is_plant_specific ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_candidates[ 2 ]-is_plant_specific ).
  ENDMETHOD.

  METHOD applies_source_list_rules.
    DATA(lo_repository) = NEW lcl_repl_source_repo_double( ).
    lo_repository->set_records(
      it_records = VALUE #(
        ( material        = 'MAT-1'
          purchasing_org  = '1000'
          vendor          = '0000100001'
          info_record     = '0000000001'
          source_category = '0' )
        ( material        = 'MAT-1'
          purchasing_org  = '1000'
          vendor          = '0000100002'
          info_record     = '0000000002'
          source_category = '0' )
        ( material        = 'MAT-1'
          purchasing_org  = '1000'
          vendor          = '0000100003'
          info_record     = '0000000003'
          source_category = '0' )
        ( material        = 'MAT-1'
          purchasing_org  = '1000'
          vendor          = '0000100004'
          info_record     = '0000000004'
          source_category = '0' ) ) ).
    lo_repository->set_source_contexts(
      it_contexts = VALUE #(
        ( material                = 'MAT-1'
          plant                   = '1000'
          source_list_required    = 'X'
          quota_arrangement_usage = '1' )
        ( material                   = 'MAT-1'
          plant                      = '1000'
          source_list_vendor         = '0000100001'
          source_list_purchasing_org = '1000'
          source_list_record         = '00001'
          source_list_valid_from     = '20260101'
          source_list_valid_to       = '20261231'
          source_list_fixed          = 'X'
          source_list_mrp_usage      = '1' )
        ( material                   = 'MAT-1'
          plant                      = '1000'
          source_list_vendor         = '0000100002'
          source_list_purchasing_org = '1000'
          source_list_record         = '00002'
          source_list_valid_from     = '20260101'
          source_list_valid_to       = '20261231'
          source_list_mrp_usage      = '1' )
        ( material                   = 'MAT-1'
          plant                      = '1000'
          source_list_vendor         = '0000100003'
          source_list_purchasing_org = '1000'
          source_list_valid_from     = '20260101'
          source_list_valid_to       = '20261231'
          source_list_blocked        = 'X' )
        ( material                   = 'MAT-1'
          plant                      = '1000'
          source_list_vendor         = '0000100004'
          source_list_purchasing_org = '1000'
          source_list_agreement      = '4500000001'
          source_list_agreement_item = '00010'
          source_list_valid_from     = '20260101'
          source_list_valid_to       = '20261231' ) ) ).
    DATA(lo_cut) = NEW zcl_repl_source_service(
      io_repository = lo_repository ).

    DATA(lt_candidates) = lo_cut->get_valid_pir_candidates(
      it_requests = VALUE #(
        ( material         = 'MAT-1'
          plant            = '1000'
          purchasing_org   = '1000'
          delivery_date    = '20261005'
          preferred_vendor = '0000100002' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_candidates ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100001'
      act = lt_candidates[ 1 ]-vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_candidates[ 1 ]-source_list_required ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1'
      act = lt_candidates[ 1 ]-quota_arrangement_usage ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_candidates[ 1 ]-is_source_listed ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_candidates[ 1 ]-is_fixed_source ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_candidates[ 1 ]-is_mrp_relevant ).
    cl_abap_unit_assert=>assert_equals(
      exp = '00001'
      act = lt_candidates[ 1 ]-source_list_record ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100002'
      act = lt_candidates[ 2 ]-vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_candidates[ 2 ]-is_preferred_vendor ).

  ENDMETHOD.

  METHOD filters_source_list_by_date.
    DATA(lo_repository) = NEW lcl_repl_source_repo_double( ).
    lo_repository->set_records(
      it_records = VALUE #(
        ( material        = 'MAT-1'
          purchasing_org  = '1000'
          vendor          = '0000100001'
          info_record     = '0000000001'
          source_category = '0' ) ) ).
    lo_repository->set_source_contexts(
      it_contexts = VALUE #(
        ( material             = 'MAT-1'
          plant                = '1000'
          source_list_required = 'X' )
        ( material                   = 'MAT-1'
          plant                      = '1000'
          source_list_vendor         = '0000100001'
          source_list_purchasing_org = '1000'
          source_list_valid_from     = '20261006'
          source_list_valid_to       = '20261231' ) ) ).
    DATA(lo_cut) = NEW zcl_repl_source_service(
      io_repository = lo_repository ).

    DATA(lt_candidates) = lo_cut->get_valid_pir_candidates(
      it_requests = VALUE #(
        ( material       = 'MAT-1'
          plant          = '1000'
          purchasing_org = '1000'
          delivery_date  = '20261005' )
        ( material       = 'MAT-1'
          plant          = '1000'
          purchasing_org = '1000'
          delivery_date  = '20261006' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_candidates ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lt_candidates[ 1 ]-request_index ).
  ENDMETHOD.

  METHOD excludes_missing_mat_plant.
    DATA(lo_repository) = NEW lcl_repl_source_repo_double( ).
    lo_repository->set_records(
      it_records = VALUE #(
        ( material        = 'MAT-1'
          purchasing_org  = '1000'
          vendor          = '0000100001'
          info_record     = '0000000001'
          source_category = '0' ) ) ).
    lo_repository->set_source_contexts( it_contexts = VALUE #( ) ).
    DATA(lo_cut) = NEW zcl_repl_source_service(
      io_repository = lo_repository ).

    DATA(lt_candidates) = lo_cut->get_valid_pir_candidates(
      it_requests = VALUE #(
        ( material       = 'MAT-1'
          plant          = '1000'
          purchasing_org = '1000'
          delivery_date  = '20261005' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( lt_candidates ) ).
  ENDMETHOD.

  METHOD excludes_global_source_block.
    DATA(lo_repository) = NEW lcl_repl_source_repo_double( ).
    lo_repository->set_records(
      it_records = VALUE #(
        ( material        = 'MAT-1'
          purchasing_org  = '1000'
          vendor          = '0000100001'
          info_record     = '0000000001'
          source_category = '0' ) ) ).
    lo_repository->set_source_contexts(
      it_contexts = VALUE #(
        ( material                   = 'MAT-1'
          plant                      = '1000'
          source_list_vendor         = space
          source_list_purchasing_org = '1000'
          source_list_valid_from     = '20261001'
          source_list_valid_to       = '20261031'
          source_list_blocked        = 'X' ) ) ).
    DATA(lo_cut) = NEW zcl_repl_source_service(
      io_repository = lo_repository ).

    DATA(lt_candidates) = lo_cut->get_valid_pir_candidates(
      it_requests = VALUE #(
        ( material       = 'MAT-1'
          plant          = '1000'
          purchasing_org = '1000'
          delivery_date  = '20261015' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( lt_candidates ) ).
  ENDMETHOD.

  METHOD filters_each_delivery_date.
    DATA(lo_repository) = NEW lcl_repl_source_repo_double( ).
    lo_repository->set_records(
      it_records = VALUE #(
        ( material        = 'MAT-1'
          purchasing_org  = '1000'
          vendor          = '0000100001'
          info_record     = '0000000001'
          source_category = '0'
          valid_from      = '20261001'
          valid_to        = '20261031' ) ) ).
    DATA(lo_cut) = NEW zcl_repl_source_service(
      io_repository = lo_repository ).

    DATA(lt_candidates) = lo_cut->get_valid_pir_candidates(
      it_requests = VALUE #(
        ( material       = 'MAT-1'
          plant          = '1000'
          purchasing_org = '1000'
          delivery_date  = '20261015' )
        ( material       = 'MAT-1'
          plant          = '1000'
          purchasing_org = '1000'
          delivery_date  = '20261101' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_candidates ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lt_candidates[ 1 ]-request_index ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV d( '20261015' )
      act = lt_candidates[ 1 ]-delivery_date ).
  ENDMETHOD.

  METHOD rejects_incomplete_pir_request.
    DATA lv_invalid_request_rejected TYPE abap_bool.
    DATA(lo_repository) = NEW lcl_repl_source_repo_double( ).
    DATA(lo_cut) = NEW zcl_repl_source_service(
      io_repository = lo_repository ).

    TRY.
        DATA(lt_candidates) = lo_cut->get_valid_pir_candidates(
          it_requests = VALUE #(
            ( material      = 'MAT-1'
              plant         = '1000'
              delivery_date = '20261005' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_invalid_request_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_invalid_request_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_read_count( ) ).
  ENDMETHOD.

  METHOD ranks_by_quota_rating.
    DATA(lo_repository) = NEW lcl_repl_source_repo_double( ).
    lo_repository->set_records(
      it_records = VALUE #(
        ( material = 'MAT-1' purchasing_org = '1000'
          vendor = '0000100001' info_record = '0000000001'
          source_category = '0' )
        ( material = 'MAT-1' purchasing_org = '1000'
          vendor = '0000100002' info_record = '0000000002'
          source_category = '0' )
        ( material = 'MAT-1' purchasing_org = '1000'
          vendor = '0000100003' info_record = '0000000003'
          source_category = '0' ) ) ).
    lo_repository->set_source_contexts(
      it_contexts = VALUE #(
        ( material = 'MAT-1' plant = '1000'
          quota_arrangement_usage = '1' ) ) ).
    lo_repository->set_quota_usage_rules(
      it_rules = VALUE #(
        ( quota_usage                    = '1'
          includes_purchase_orders       = 'X'
          includes_purchase_requisitions = 'X' ) ) ).
    lo_repository->set_quota_arrangements(
      it_arrangements = VALUE #(
        ( material = 'MAT-1' plant = '1000'
          quota_valid_from = '20260101' quota_valid_to = '20261231'
          quota_number = '0000000001' quota_item = '001'
          minimum_split_quantity = 125
          procurement_type = 'F' vendor = '0000100001'
          quota = 3 quota_allocated_quantity = 780 )
        ( material = 'MAT-1' plant = '1000'
          quota_valid_from = '20260101' quota_valid_to = '20261231'
          quota_number = '0000000001' quota_item = '002'
          minimum_split_quantity = 125
          quota_priority = '01'
          quota_minimum_lot_size = 75
          quota_maximum_lot_size = 500
          quota_maximum_quantity = 2000
          source_assigned_once = 'X'
          procurement_type = 'F' vendor = '0000100002'
          quota = 2 quota_allocated_quantity = 380 )
        ( material = 'MAT-1' plant = '1000'
          quota_valid_from = '20260101' quota_valid_to = '20261231'
          quota_number = '0000000001' quota_item = '003'
          minimum_split_quantity = 125
          procurement_type = 'F' vendor = '0000100003'
          quota = 1 quota_base_quantity = 260 ) ) ).
    DATA(lo_cut) = NEW zcl_repl_source_service(
      io_repository = lo_repository ).

    DATA(lt_candidates) = lo_cut->get_valid_pir_candidates(
      it_requests = VALUE #(
        ( material = 'MAT-1' plant = '1000'
          purchasing_org = '1000' delivery_date = '20261005'
          preferred_vendor = '0000100001' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_candidates ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100002'
      act = lt_candidates[ 1 ]-vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( 190 )
      act = lt_candidates[ 1 ]-quota_rating ).
    cl_abap_unit_assert=>assert_equals(
      exp = 125
      act = lt_candidates[ 1 ]-quota_min_split_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '01'
      act = lt_candidates[ 1 ]-quota_priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = 75
      act = lt_candidates[ 1 ]-quota_min_lot_size ).
    cl_abap_unit_assert=>assert_equals(
      exp = 500
      act = lt_candidates[ 1 ]-quota_max_lot_size ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2000
      act = lt_candidates[ 1 ]-quota_maximum_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_candidates[ 1 ]-quota_once_only ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100001'
      act = lt_candidates[ 2 ]-vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( 260 )
      act = lt_candidates[ 2 ]-quota_rating ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000000001'
      act = lt_candidates[ 1 ]-quota_number ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'X'
      act = lt_candidates[ 1 ]-quota_usage_rule-includes_purchase_requisitions ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_candidates[ 3 ]-has_active_vendor_quota ).
  ENDMETHOD.

  METHOD orders_zero_tie_by_item.
    DATA(lo_repository) = NEW lcl_repl_source_repo_double( ).
    lo_repository->set_records(
      it_records = VALUE #(
        ( material = 'MAT-1' purchasing_org = '1000'
          vendor = '0000100001' info_record = '0000000001'
          source_category = '0' )
        ( material = 'MAT-1' purchasing_org = '1000'
          vendor = '0000100002' info_record = '0000000002'
          source_category = '0' ) ) ).
    lo_repository->set_source_contexts(
      it_contexts = VALUE #(
        ( material = 'MAT-1' plant = '1000'
          quota_arrangement_usage = '1' ) ) ).
    lo_repository->set_quota_usage_rules(
      it_rules = VALUE #(
        ( quota_usage                    = '1'
          includes_purchase_requisitions = 'X' ) ) ).
    lo_repository->set_quota_arrangements(
      it_arrangements = VALUE #(
        ( material = 'MAT-1' plant = '1000'
          quota_valid_from = '20260101' quota_valid_to = '20261231'
          quota_number = '0000000001' quota_item = '001'
          procurement_type = 'F' vendor = '0000100001' quota = 1 )
        ( material = 'MAT-1' plant = '1000'
          quota_valid_from = '20260101' quota_valid_to = '20261231'
          quota_number = '0000000001' quota_item = '002'
          procurement_type = 'F' vendor = '0000100002' quota = 2 ) ) ).
    DATA(lo_cut) = NEW zcl_repl_source_service(
      io_repository = lo_repository ).

    DATA(lt_candidates) = lo_cut->get_valid_pir_candidates(
      it_requests = VALUE #(
        ( material = 'MAT-1' plant = '1000'
          purchasing_org = '1000' delivery_date = '20261005' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = '0000100001'
      act = lt_candidates[ 1 ]-vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( 0 )
      act = lt_candidates[ 1 ]-quota_rating ).
    cl_abap_unit_assert=>assert_equals(
      exp = '001'
      act = lt_candidates[ 1 ]-quota_item ).
  ENDMETHOD.

  METHOD simulates_quota_by_due_date.
    DATA(lo_repository) = NEW lcl_repl_source_repo_double( ).
    lo_repository->set_records(
      it_records = VALUE #(
        ( material        = 'MAT-1'
          purchasing_org  = '1000'
          vendor          = '0000100001'
          info_record     = '0000000001'
          source_category = '0'
          base_unit       = 'EA' )
        ( material        = 'MAT-1'
          purchasing_org  = '1000'
          vendor          = '0000100002'
          info_record     = '0000000002'
          source_category = '0'
          base_unit       = 'EA' ) ) ).
    lo_repository->set_source_contexts(
      it_contexts = VALUE #(
        ( material                = 'MAT-1'
          plant                   = '1000'
          quota_arrangement_usage = '1' ) ) ).
    lo_repository->set_quota_usage_rules(
      it_rules = VALUE #(
        ( quota_usage                    = '1'
          includes_purchase_requisitions = 'X' ) ) ).
    lo_repository->set_quota_arrangements(
      it_arrangements = VALUE #(
        ( material         = 'MAT-1'
          plant            = '1000'
          quota_valid_from = '20260101'
          quota_valid_to   = '20261231'
          quota_number     = '0000000001'
          quota_item       = '001'
          procurement_type = 'F'
          vendor           = '0000100001'
          quota            = 1 )
        ( material         = 'MAT-1'
          plant            = '1000'
          quota_valid_from = '20260101'
          quota_valid_to   = '20261231'
          quota_number     = '0000000001'
          quota_item       = '002'
          procurement_type = 'F'
          vendor           = '0000100002'
          quota            = 1 ) ) ).
    DATA(lo_cut) = NEW zcl_repl_source_service(
      io_repository = lo_repository ).

    DATA(lt_candidates) = lo_cut->get_valid_pir_candidates(
      it_requests                  = VALUE #(
        ( material                = 'MAT-1'
          plant                   = '1000'
          purchasing_org          = '1000'
          delivery_date           = '20261015'
          requested_quantity      = 5
          requested_quantity_unit = 'EA' )
        ( material                = 'MAT-1'
          plant                   = '1000'
          purchasing_org          = '1000'
          delivery_date           = '20261005'
          requested_quantity      = 5
          requested_quantity_unit = 'EA' ) )
      iv_simulate_quota_assignment = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = lines( lt_candidates ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lt_candidates[ 1 ]-request_index ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100002'
      act = lt_candidates[ 1 ]-vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_candidates[ 1 ]-quota_simulation-is_selected_source ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( 0 )
      act = lt_candidates[ 1 ]-quota_simulation-rating_before ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100001'
      act = lt_candidates[ 2 ]-vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( 5 )
      act = lt_candidates[ 2 ]-quota_simulation-rating_before ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = lt_candidates[ 2 ]-quota_simulation-is_selected_source ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lt_candidates[ 3 ]-request_index ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100001'
      act = lt_candidates[ 3 ]-vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_candidates[ 3 ]-quota_simulation-is_selected_source ).

    DATA(lt_priority_candidates) = lo_cut->get_valid_pir_candidates(
      it_requests                  = VALUE #(
        ( material                = 'MAT-1'
          plant                   = '1000'
          purchasing_org          = '1000'
          delivery_date           = '20261005'
          requested_quantity      = 5
          requested_quantity_unit = 'EA'
          priority                = 0 )
        ( material                = 'MAT-1'
          plant                   = '1000'
          purchasing_org          = '1000'
          delivery_date           = '20261005'
          requested_quantity      = 5
          requested_quantity_unit = 'EA'
          priority                = 10 ) )
      iv_simulate_quota_assignment = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lt_priority_candidates[ 1 ]-request_index ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lt_priority_candidates[ 1 ]-candidate_rank ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lt_priority_candidates[ 1 ]-request_priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100002'
      act = lt_priority_candidates[ 1 ]-vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_priority_candidates[ 1 ]-quota_simulation-is_selected_source ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lt_priority_candidates[ 3 ]-request_index ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lt_priority_candidates[ 3 ]-candidate_rank ).
    cl_abap_unit_assert=>assert_equals(
      exp = 10
      act = lt_priority_candidates[ 3 ]-request_priority ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100001'
      act = lt_priority_candidates[ 3 ]-vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_priority_candidates[ 3 ]-quota_simulation-is_selected_source ).

    DATA lv_bad_sim_unit_rejected TYPE abap_bool.
    TRY.
        lo_cut->get_valid_pir_candidates(
          it_requests                  = VALUE #(
            ( material                = 'MAT-1'
              plant                   = '1000'
              purchasing_org          = '1000'
              delivery_date           = '20261005'
              requested_quantity      = 5
              requested_quantity_unit = 'KG' ) )
          iv_simulate_quota_assignment = abap_true ).
      CATCH zcx_invalid_stock_request.
        lv_bad_sim_unit_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_bad_sim_unit_rejected ).

    DATA(lt_default_candidates) = lo_cut->get_valid_pir_candidates(
      it_requests = VALUE #(
        ( material                = 'MAT-1'
          plant                   = '1000'
          purchasing_org          = '1000'
          delivery_date           = '20261015'
          requested_quantity      = 5
          requested_quantity_unit = 'EA' )
        ( material                = 'MAT-1'
          plant                   = '1000'
          purchasing_org          = '1000'
          delivery_date           = '20261005'
          requested_quantity      = 5
          requested_quantity_unit = 'EA' ) ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100001'
      act = lt_default_candidates[ 1 ]-vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100001'
      act = lt_default_candidates[ 3 ]-vendor ).
    cl_abap_unit_assert=>assert_initial(
      act = lt_default_candidates[ 1 ]-quota_simulation ).

    lo_repository->set_quota_arrangements(
      it_arrangements = VALUE #(
        ( material               = 'MAT-1'
          plant                  = '1000'
          quota_valid_from       = '20260101'
          quota_valid_to         = '20261231'
          quota_number           = '0000000001'
          quota_item             = '001'
          procurement_type       = 'F'
          vendor                 = '0000100001'
          quota                  = 1
          quota_maximum_quantity = 5 )
        ( material         = 'MAT-1'
          plant            = '1000'
          quota_valid_from = '20260101'
          quota_valid_to   = '20261231'
          quota_number     = '0000000001'
          quota_item       = '002'
          procurement_type = 'F'
          vendor           = '0000100002'
          quota            = 1 ) ) ).
    DATA(lt_max_candidates) = lo_cut->get_valid_pir_candidates(
      it_requests                  = VALUE #(
        ( material                = 'MAT-1'
          plant                   = '1000'
          purchasing_org          = '1000'
          delivery_date           = '20261005'
          requested_quantity      = 5
          requested_quantity_unit = 'EA' ) )
      iv_simulate_quota_assignment = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_max_candidates ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100002'
      act = lt_max_candidates[ 1 ]-vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_max_candidates[ 1 ]-quota_simulation-is_selected_source ).

    lo_repository->set_quota_arrangements(
      it_arrangements = VALUE #(
        ( material                 = 'MAT-1'
          plant                    = '1000'
          quota_valid_from         = '20260101'
          quota_valid_to           = '20261231'
          quota_number             = '0000000001'
          quota_item               = '001'
          procurement_type         = 'F'
          vendor                   = '0000100001'
          quota                    = 1
          quota_allocated_quantity = 5
          quota_maximum_quantity   = 5 )
        ( material         = 'MAT-1'
          plant            = '1000'
          quota_valid_from = '20260101'
          quota_valid_to   = '20261231'
          quota_number     = '0000000001'
          quota_item       = '002'
          procurement_type = 'F'
          vendor           = '0000100002'
          quota            = 1 ) ) ).
    DATA(lt_exhausted_candidates) = lo_cut->get_valid_pir_candidates(
      it_requests                  = VALUE #(
        ( material       = 'MAT-1'
          plant          = '1000'
          purchasing_org = '1000'
          delivery_date  = '20261005' ) )
      iv_simulate_quota_assignment = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_exhausted_candidates ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100002'
      act = lt_exhausted_candidates[ 1 ]-vendor ).

    lo_repository->set_quota_arrangements(
      it_arrangements = VALUE #(
        ( material               = 'MAT-1'
          plant                  = '1000'
          quota_valid_from       = '20260101'
          quota_valid_to         = '20261231'
          quota_number           = '0000000001'
          quota_item             = '001'
          procurement_type       = 'F'
          vendor                 = '0000100001'
          quota                  = 1
          quota_maximum_quantity = 10 )
        ( material         = 'MAT-1'
          plant            = '1000'
          quota_valid_from = '20260101'
          quota_valid_to   = '20261231'
          quota_number     = '0000000001'
          quota_item       = '002'
          procurement_type = 'F'
          vendor           = '0000100002'
          quota            = 1 ) ) ).
    DATA(lt_sequential_max_candidates) = lo_cut->get_valid_pir_candidates(
      it_requests                  = VALUE #(
        ( material                = 'MAT-1'
          plant                   = '1000'
          purchasing_org          = '1000'
          delivery_date           = '20261005'
          requested_quantity      = 5
          requested_quantity_unit = 'EA' )
        ( material                = 'MAT-1'
          plant                   = '1000'
          purchasing_org          = '1000'
          delivery_date           = '20261005'
          requested_quantity      = 5
          requested_quantity_unit = 'EA' ) )
      iv_simulate_quota_assignment = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_sequential_max_candidates ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100001'
      act = lt_sequential_max_candidates[ 1 ]-vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_sequential_max_candidates[
        request_index = 1 ]-quota_simulation-is_selected_source ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100002'
      act = lt_sequential_max_candidates[ 3 ]-vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_sequential_max_candidates[
        request_index = 2 ]-quota_simulation-is_selected_source ).
  ENDMETHOD.

  METHOD simulates_split_quota.
    DATA(lo_cut) = NEW zcl_repl_source_service(
      io_repository = NEW lcl_repl_source_repo_double( ) ).
    DATA(lt_candidates) = VALUE zcl_repl_source_service=>ty_candidates(
      ( request_index     = 1
        candidate_rank    = 3
        material          = 'MAT-SPLIT'
        plant             = '1000'
        purchasing_org    = '1000'
        delivery_date     = '20261020'
        vendor            = '0000100001'
        info_record       = '0000000001'
        source_category   = '0'
        base_unit         = 'EA'
        is_quota_assigned = abap_true
        quota_number      = '0000000001'
        quota_item        = '001'
        quota_value       = 40
        quota_rating      = '10' )
      ( request_index     = 1
        candidate_rank    = 1
        material          = 'MAT-SPLIT'
        plant             = '1000'
        purchasing_org    = '1000'
        delivery_date     = '20261020'
        vendor            = '0000100002'
        info_record       = '0000000002'
        source_category   = '0'
        base_unit         = 'EA'
        is_quota_assigned = abap_true
        quota_number      = '0000000001'
        quota_item        = '002'
        quota_value       = 30
        quota_rating      = '1' )
      ( request_index     = 1
        candidate_rank    = 2
        material          = 'MAT-SPLIT'
        plant             = '1000'
        purchasing_org    = '1000'
        delivery_date     = '20261020'
        vendor            = '0000100003'
        info_record       = '0000000003'
        source_category   = '0'
        base_unit         = 'EA'
        is_quota_assigned = abap_true
        quota_number      = '0000000001'
        quota_item        = '003'
        quota_value       = 20
        quota_rating      = '2' )
      ( request_index     = 1
        candidate_rank    = 4
        material          = 'MAT-SPLIT'
        plant             = '1000'
        purchasing_org    = '1000'
        delivery_date     = '20261020'
        vendor            = '0000100004'
        info_record       = '0000000004'
        source_category   = '0'
        base_unit         = 'EA'
        is_quota_assigned = abap_true
        quota_number      = '0000000001'
        quota_item        = '004'
        quota_value       = 10
        quota_rating      = '20' ) ).

    LOOP AT lt_candidates ASSIGNING FIELD-SYMBOL(<ls_split_candidate>).
      <ls_split_candidate>-quota_min_split_quantity = 400.
    ENDLOOP.

    DATA(lt_splits) = lo_cut->simulate_split_quota(
      it_candidates         = lt_candidates
      iv_request_index      = 1
      iv_requested_quantity = '1000'
      iv_requested_unit     = 'EA' ).

    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_splits ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100001'
      act = lt_splits[ 1 ]-candidate-vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '400' )
      act = lt_splits[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '400' )
      act = lt_splits[ 1 ]-proposal_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100002'
      act = lt_splits[ 2 ]-candidate-vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '300' )
      act = lt_splits[ 2 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100003'
      act = lt_splits[ 3 ]-candidate-vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '300' )
      act = lt_splits[ 3 ]-allocated_quantity ).

    DATA(lt_maximum_candidates) = lt_candidates.
    lt_maximum_candidates[ 1 ]-quota_maximum_quantity = 400.
    DATA(lt_maximum_splits) = lo_cut->simulate_split_quota(
      it_candidates         = lt_maximum_candidates
      iv_request_index      = 1
      iv_requested_quantity = '1000'
      iv_requested_unit     = 'EA' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_maximum_splits ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100002'
      act = lt_maximum_splits[ 1 ]-candidate-vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '500' )
      act = lt_maximum_splits[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100003'
      act = lt_maximum_splits[ 2 ]-candidate-vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100004'
      act = lt_maximum_splits[ 3 ]-candidate-vendor ).
    DATA lv_maximum_required_sum TYPE decfloat34.
    LOOP AT lt_maximum_splits INTO DATA(ls_maximum_split).
      lv_maximum_required_sum = lv_maximum_required_sum
        + ls_maximum_split-allocated_quantity.
    ENDLOOP.
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1000' )
      act = lv_maximum_required_sum ).

    DATA(lt_max_threshold_candidates) = lt_candidates.
    lt_max_threshold_candidates[ 2 ]-quota_maximum_quantity = 300.
    DATA(lt_max_threshold_splits) = lo_cut->simulate_split_quota(
      it_candidates         = lt_max_threshold_candidates
      iv_request_index      = 1
      iv_requested_quantity = '300'
      iv_requested_unit     = 'EA' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_max_threshold_splits ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100003'
      act = lt_max_threshold_splits[ 1 ]-candidate-vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '300' )
      act = lt_max_threshold_splits[ 1 ]-allocated_quantity ).

    DATA(lt_lot_candidates) = lt_candidates.
    lt_lot_candidates[ 1 ]-quota_max_lot_size = 250.
    lt_lot_candidates[ 2 ]-quota_min_lot_size = 350.
    DATA(lt_lot_splits) = lo_cut->simulate_split_quota(
      it_candidates         = lt_lot_candidates
      iv_request_index      = 1
      iv_requested_quantity = '1000'
      iv_requested_unit     = 'EA' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = lines( lt_lot_splits ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '250' )
      act = lt_lot_splits[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '250' )
      act = lt_lot_splits[ 2 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '200' )
      act = lt_lot_splits[ 3 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '350' )
      act = lt_lot_splits[ 4 ]-proposal_quantity ).
    DATA lv_required_lot_sum TYPE decfloat34.
    DATA lv_order_lot_sum TYPE decfloat34.
    LOOP AT lt_lot_splits INTO DATA(ls_lot_split).
      lv_required_lot_sum = lv_required_lot_sum
        + ls_lot_split-allocated_quantity.
      lv_order_lot_sum = lv_order_lot_sum
        + ls_lot_split-proposal_quantity.
    ENDLOOP.
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1000' )
      act = lv_required_lot_sum ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1050' )
      act = lv_order_lot_sum ).

    DATA(lt_recalculated_lot_candidates) = lt_candidates.
    lt_recalculated_lot_candidates[ 1 ]-quota_max_lot_size = 250.
    DATA(lt_recalculated_lot_splits) = lo_cut->simulate_split_quota(
      it_candidates             = lt_recalculated_lot_candidates
      iv_request_index          = 1
      iv_requested_quantity     = '1000'
      iv_requested_unit         = 'EA'
      iv_minimum_split_quantity = '0' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 6
      act = lines( lt_recalculated_lot_splits ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100001'
      act = lt_recalculated_lot_splits[ 1 ]-candidate-vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '250' )
      act = lt_recalculated_lot_splits[ 1 ]-proposal_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100001'
      act = lt_recalculated_lot_splits[ 2 ]-candidate-vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '250' )
      act = lt_recalculated_lot_splits[ 2 ]-proposal_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '200' )
      act = lt_recalculated_lot_splits[ 3 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100002'
      act = lt_recalculated_lot_splits[ 4 ]-candidate-vendor ).
    DATA lv_recalculated_lot_sum TYPE decfloat34.
    LOOP AT lt_recalculated_lot_splits INTO DATA(ls_recalculated_lot_split).
      lv_recalculated_lot_sum = lv_recalculated_lot_sum
        + ls_recalculated_lot_split-allocated_quantity.
      cl_abap_unit_assert=>assert_true(
        act = xsdbool(
          ls_recalculated_lot_split-proposal_quantity <= 250 ) ).
    ENDLOOP.
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1000' )
      act = lv_recalculated_lot_sum ).

    DATA(lt_recalc_max_candidates) =
      lt_recalculated_lot_candidates.
    lt_recalc_max_candidates[ 1 ]-quota_maximum_quantity = 500.
    DATA(lt_recalculated_maximum_splits) = lo_cut->simulate_split_quota(
      it_candidates             = lt_recalc_max_candidates
      iv_request_index          = 1
      iv_requested_quantity     = '1000'
      iv_requested_unit         = 'EA'
      iv_minimum_split_quantity = '0' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = lines( lt_recalculated_maximum_splits ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100001'
      act = lt_recalculated_maximum_splits[ 1 ]-candidate-vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '250' )
      act = lt_recalculated_maximum_splits[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100002'
      act = lt_recalculated_maximum_splits[ 2 ]-candidate-vendor ).
    DATA lv_recalculated_maximum_sum TYPE decfloat34.
    LOOP AT lt_recalculated_maximum_splits
        INTO DATA(ls_recalculated_maximum_split).
      lv_recalculated_maximum_sum = lv_recalculated_maximum_sum
        + ls_recalculated_maximum_split-allocated_quantity.
    ENDLOOP.
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1000' )
      act = lv_recalculated_maximum_sum ).

    DATA(lo_round_repo) = NEW lcl_repl_source_repo_double( ).
    lo_round_repo->set_quota_rounding_profiles(
      it_profiles = VALUE #(
        ( plant = '1000' rounding_profile = 'R001'
          level_number = '000001' threshold_quantity = 2
          rounding_quantity = 5 )
        ( plant = '1000' rounding_profile = 'R001'
          level_number = '000002' threshold_quantity = 32
          rounding_quantity = 40 )
        ( plant = '1000' rounding_profile = 'R002'
          level_number = '000001' threshold_quantity = 2
          rounding_quantity = 100 )
        ( plant = '1000' rounding_profile = 'R002'
          level_number = '000002' threshold_quantity = 301
          rounding_quantity = 500 ) ) ).
    DATA(lo_round_cut) = NEW zcl_repl_source_service(
      io_repository = lo_round_repo ).
    DATA lt_round_candidates TYPE zcl_repl_source_service=>ty_candidates.
    APPEND lt_candidates[ 1 ] TO lt_round_candidates.
    lt_round_candidates[ 1 ]-quota_rounding_profile = 'R001'.
    DATA(lt_rounded_74) = lo_round_cut->simulate_split_quota(
      it_candidates             = lt_round_candidates
      iv_request_index          = 1
      iv_requested_quantity     = '74'
      iv_requested_unit         = 'EA'
      iv_minimum_split_quantity = '0' ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '74' )
      act = lt_rounded_74[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '80' )
      act = lt_rounded_74[ 1 ]-proposal_quantity ).
    DATA(lt_rounded_31) = lo_round_cut->simulate_split_quota(
      it_candidates             = lt_round_candidates
      iv_request_index          = 1
      iv_requested_quantity     = '31'
      iv_requested_unit         = 'EA'
      iv_minimum_split_quantity = '0' ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '35' )
      act = lt_rounded_31[ 1 ]-proposal_quantity ).
    DATA(lt_unrounded_1) = lo_round_cut->simulate_split_quota(
      it_candidates             = lt_round_candidates
      iv_request_index          = 1
      iv_requested_quantity     = '1'
      iv_requested_unit         = 'EA'
      iv_minimum_split_quantity = '0' ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1' )
      act = lt_unrounded_1[ 1 ]-proposal_quantity ).
    DATA(lt_cascaded_round_candidates) = lt_round_candidates.
    lt_cascaded_round_candidates[ 1 ]-quota_rounding_profile = 'R002'.
    DATA(lt_cascaded_round) = lo_round_cut->simulate_split_quota(
      it_candidates             = lt_cascaded_round_candidates
      iv_request_index          = 1
      iv_requested_quantity     = '2215'
      iv_requested_unit         = 'EA'
      iv_minimum_split_quantity = '0' ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '2300' )
      act = lt_cascaded_round[ 1 ]-proposal_quantity ).

    DATA(lt_round_lot_candidates) = lt_round_candidates.
    lt_round_lot_candidates[ 1 ]-quota_max_lot_size = 40.
    DATA(lt_round_lot_splits) = lo_round_cut->simulate_split_quota(
      it_candidates             = lt_round_lot_candidates
      iv_request_index          = 1
      iv_requested_quantity     = '74'
      iv_requested_unit         = 'EA'
      iv_minimum_split_quantity = '0' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_round_lot_splits ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '40' )
      act = lt_round_lot_splits[ 1 ]-proposal_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '40' )
      act = lt_round_lot_splits[ 2 ]-proposal_quantity ).
    DATA lv_rounded_lot_demand TYPE decfloat34.
    LOOP AT lt_round_lot_splits INTO DATA(ls_round_lot_split).
      lv_rounded_lot_demand = lv_rounded_lot_demand
        + ls_round_lot_split-allocated_quantity.
    ENDLOOP.
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '74' )
      act = lv_rounded_lot_demand ).

    DATA(lt_round_maxmg_candidates) = lt_candidates.
    lt_round_maxmg_candidates[ 1 ]-quota_rounding_profile = 'R001'.
    lt_round_maxmg_candidates[ 1 ]-quota_maximum_quantity = 30.
    DATA(lt_round_maxmg_splits) = lo_round_cut->simulate_split_quota(
      it_candidates             = lt_round_maxmg_candidates
      iv_request_index          = 1
      iv_requested_quantity     = '74'
      iv_requested_unit         = 'EA'
      iv_minimum_split_quantity = '0' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 3
      act = lines( lt_round_maxmg_splits ) ).
    DATA lv_round_maxmg_demand TYPE decfloat34.
    LOOP AT lt_round_maxmg_splits INTO DATA(ls_round_maxmg_split).
      cl_abap_unit_assert=>assert_true(
        act = xsdbool(
          ls_round_maxmg_split-candidate-vendor <> '0000100001' ) ).
      lv_round_maxmg_demand = lv_round_maxmg_demand
        + ls_round_maxmg_split-allocated_quantity.
    ENDLOOP.
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '74' )
      act = lv_round_maxmg_demand ).

    DATA(lt_bad_round_lot_candidates) = lt_round_candidates.
    lt_bad_round_lot_candidates[ 1 ]-quota_max_lot_size = 39.
    DATA lv_bad_round_lot_rejected TYPE abap_bool.
    TRY.
        lo_round_cut->simulate_split_quota(
          it_candidates             = lt_bad_round_lot_candidates
          iv_request_index          = 1
          iv_requested_quantity     = '39'
          iv_requested_unit         = 'EA'
          iv_minimum_split_quantity = '0' ).
      CATCH zcx_invalid_stock_request.
        lv_bad_round_lot_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_bad_round_lot_rejected ).

    DATA(lt_once_candidates) = lt_candidates.
    lt_once_candidates[ 1 ]-quota_max_lot_size = 250.
    lt_once_candidates[ 1 ]-quota_once_only = abap_true.
    DATA(lt_once_splits) = lo_cut->simulate_split_quota(
      it_candidates             = lt_once_candidates
      iv_request_index          = 1
      iv_requested_quantity     = '1000'
      iv_requested_unit         = 'EA'
      iv_minimum_split_quantity = '0' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = lines( lt_once_splits ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100001'
      act = lt_once_splits[ 1 ]-candidate-vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '250' )
      act = lt_once_splits[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '250' )
      act = lt_once_splits[ 1 ]-proposal_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100002'
      act = lt_once_splits[ 2 ]-candidate-vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '375' )
      act = lt_once_splits[ 2 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100003'
      act = lt_once_splits[ 3 ]-candidate-vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '250' )
      act = lt_once_splits[ 3 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100004'
      act = lt_once_splits[ 4 ]-candidate-vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '125' )
      act = lt_once_splits[ 4 ]-allocated_quantity ).
    DATA lv_once_required_sum TYPE decfloat34.
    LOOP AT lt_once_splits INTO DATA(ls_once_split).
      lv_once_required_sum = lv_once_required_sum
        + ls_once_split-allocated_quantity.
    ENDLOOP.
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '1000' )
      act = lv_once_required_sum ).

    DATA(lt_once_short_candidates) = lt_once_candidates.
    lt_once_short_candidates[ 1 ]-candidate_rank = 1.
    lt_once_short_candidates[ 2 ]-candidate_rank = 2.
    lt_once_short_candidates[ 3 ]-candidate_rank = 3.
    lt_once_short_candidates[ 4 ]-candidate_rank = 4.
    DATA(lt_once_short_splits) = lo_cut->simulate_split_quota(
      it_candidates             = lt_once_short_candidates
      iv_request_index          = 1
      iv_requested_quantity     = '300'
      iv_requested_unit         = 'EA'
      iv_minimum_split_quantity = '400' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_once_short_splits ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100001'
      act = lt_once_short_splits[ 1 ]-candidate-vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '250' )
      act = lt_once_short_splits[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100002'
      act = lt_once_short_splits[ 2 ]-candidate-vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '50' )
      act = lt_once_short_splits[ 2 ]-allocated_quantity ).

    DATA lt_only_once_candidate TYPE
      zcl_repl_source_service=>ty_candidates.
    APPEND lt_once_candidates[ 1 ] TO lt_only_once_candidate.
    DATA lv_uncovered_once_rejected TYPE abap_bool.
    TRY.
        lo_cut->simulate_split_quota(
          it_candidates         = lt_only_once_candidate
          iv_request_index      = 1
          iv_requested_quantity = '300'
          iv_requested_unit     = 'EA' ).
      CATCH zcx_invalid_stock_request.
        lv_uncovered_once_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_uncovered_once_rejected ).

    DATA(lt_priority_candidates) = lt_candidates.
    lt_priority_candidates[ 4 ]-quota_priority = '01'.
    lt_priority_candidates[ 3 ]-quota_priority = '02'.

    DATA(lt_priority_splits) = lo_cut->simulate_split_quota(
      it_candidates         = lt_priority_candidates
      iv_request_index      = 1
      iv_requested_quantity = '1000'
      iv_requested_unit     = 'EA' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 4
      act = lines( lt_priority_splits ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100004'
      act = lt_priority_splits[ 1 ]-candidate-vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '100' )
      act = lt_priority_splits[ 1 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100003'
      act = lt_priority_splits[ 2 ]-candidate-vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '200' )
      act = lt_priority_splits[ 2 ]-allocated_quantity ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100001'
      act = lt_priority_splits[ 3 ]-candidate-vendor ).

    DATA(lt_unsplit) = lo_cut->simulate_split_quota(
      it_candidates             = lt_priority_candidates
      iv_request_index          = 1
      iv_requested_quantity     = '300'
      iv_requested_unit         = 'EA'
      iv_minimum_split_quantity = '400' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_unsplit ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100002'
      act = lt_unsplit[ 1 ]-candidate-vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( '300' )
      act = lt_unsplit[ 1 ]-allocated_quantity ).

    DATA lv_bad_unit_rejected TYPE abap_bool.
    TRY.
        lo_cut->simulate_split_quota(
          it_candidates             = lt_candidates
          iv_request_index          = 1
          iv_requested_quantity     = '300'
          iv_requested_unit         = 'KG'
          iv_minimum_split_quantity = '400' ).
      CATCH zcx_invalid_stock_request.
        lv_bad_unit_rejected = abap_true.
    ENDTRY.
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_bad_unit_rejected ).
  ENDMETHOD.

  METHOD respects_quota_pr_usage.
    DATA(lo_repository) = NEW lcl_repl_source_repo_double( ).
    lo_repository->set_records(
      it_records = VALUE #(
        ( material        = 'MAT-1'
          purchasing_org  = '1000'
          vendor          = '0000100001'
          info_record     = '0000000001'
          source_category = '0'
          base_unit       = 'EA' )
        ( material        = 'MAT-1'
          purchasing_org  = '1000'
          vendor          = '0000100002'
          info_record     = '0000000002'
          source_category = '0'
          base_unit       = 'EA' ) ) ).
    lo_repository->set_source_contexts(
      it_contexts = VALUE #(
        ( material                = 'MAT-1'
          plant                   = '1000'
          quota_arrangement_usage = '1' ) ) ).
    lo_repository->set_quota_usage_rules(
      it_rules = VALUE #(
        ( quota_usage = '1' ) ) ).
    lo_repository->set_quota_arrangements(
      it_arrangements = VALUE #(
        ( material         = 'MAT-1'
          plant            = '1000'
          quota_valid_from = '20260101'
          quota_valid_to   = '20261231'
          quota_number     = '0000000001'
          quota_item       = '001'
          procurement_type = 'F'
          vendor           = '0000100001'
          quota            = 1 )
        ( material         = 'MAT-1'
          plant            = '1000'
          quota_valid_from = '20260101'
          quota_valid_to   = '20261231'
          quota_number     = '0000000001'
          quota_item       = '002'
          procurement_type = 'F'
          vendor           = '0000100002'
          quota            = 1 ) ) ).
    DATA(lo_cut) = NEW zcl_repl_source_service(
      io_repository = lo_repository ).

    DATA(lt_candidates) = lo_cut->get_valid_pir_candidates(
      it_requests                  = VALUE #(
        ( material                = 'MAT-1'
          plant                   = '1000'
          purchasing_org          = '1000'
          delivery_date           = '20261005'
          requested_quantity      = 5
          requested_quantity_unit = 'EA' )
        ( material                = 'MAT-1'
          plant                   = '1000'
          purchasing_org          = '1000'
          delivery_date           = '20261015'
          requested_quantity      = 5
          requested_quantity_unit = 'EA' ) )
      iv_simulate_quota_assignment = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      exp = '0000100001'
      act = lt_candidates[ 1 ]-vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100001'
      act = lt_candidates[ 3 ]-vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = CONV decfloat34( 0 )
      act = lt_candidates[ 3 ]-quota_simulation-rating_before ).
  ENDMETHOD.

  METHOD skips_quota_read_without_usage.
    DATA(lo_repository) = NEW lcl_repl_source_repo_double( ).
    lo_repository->set_records(
      it_records = VALUE #(
        ( material = 'MAT-1' purchasing_org = '1000'
          vendor = '0000100001' info_record = '0000000001'
          source_category = '0' ) ) ).
    lo_repository->set_quota_arrangements(
      it_arrangements = VALUE #(
        ( material = 'MAT-1' plant = '1000'
          quota_valid_from = '20260101' quota_valid_to = '20261231'
          quota_number = '0000000001' quota_item = '001'
          procurement_type = 'F' vendor = '0000100001' quota = 1 ) ) ).
    DATA(lo_cut) = NEW zcl_repl_source_service(
      io_repository = lo_repository ).

    DATA(lt_candidates) = lo_cut->get_valid_pir_candidates(
      it_requests = VALUE #(
        ( material = 'MAT-1' plant = '1000'
          purchasing_org = '1000' delivery_date = '20261005' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_quota_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_quota_usage_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = lt_candidates[ 1 ]-is_quota_assigned ).
  ENDMETHOD.

  METHOD requires_quota_usage_rule.
    DATA(lo_repository) = NEW lcl_repl_source_repo_double( ).
    lo_repository->set_records(
      it_records = VALUE #(
        ( material = 'MAT-1' purchasing_org = '1000'
          vendor = '0000100001' info_record = '0000000001'
          source_category = '0' ) ) ).
    lo_repository->set_source_contexts(
      it_contexts = VALUE #(
        ( material = 'MAT-1' plant = '1000'
          quota_arrangement_usage = '1' ) ) ).
    lo_repository->set_quota_arrangements(
      it_arrangements = VALUE #(
        ( material = 'MAT-1' plant = '1000'
          quota_valid_from = '20260101' quota_valid_to = '20261231'
          quota_number = '0000000001' quota_item = '001'
          procurement_type = 'F' vendor = '0000100001' quota = 1 ) ) ).
    DATA(lo_cut) = NEW zcl_repl_source_service(
      io_repository = lo_repository ).

    DATA(lt_candidates) = lo_cut->get_valid_pir_candidates(
      it_requests = VALUE #(
        ( material = 'MAT-1' plant = '1000'
          purchasing_org = '1000' delivery_date = '20261005' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lo_repository->get_quota_usage_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lo_repository->get_quota_read_count( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = lt_candidates[ 1 ]-is_quota_assigned ).
  ENDMETHOD.

  METHOD filters_quota_items.
    DATA(lo_repository) = NEW lcl_repl_source_repo_double( ).
    lo_repository->set_records(
      it_records = VALUE #(
        ( material = 'MAT-1' purchasing_org = '1000'
          vendor = '0000100001' info_record = '0000000001'
          source_category = '0' )
        ( material = 'MAT-1' purchasing_org = '1000'
          vendor = '0000100002' info_record = '0000000002'
          source_category = '0' )
        ( material = 'MAT-1' purchasing_org = '1000'
          vendor = '0000100003' info_record = '0000000003'
          source_category = '0' )
        ( material = 'MAT-1' purchasing_org = '1000'
          vendor = '0000100004' info_record = '0000000004'
          source_category = '0' ) ) ).
    lo_repository->set_source_contexts(
      it_contexts = VALUE #(
        ( material = 'MAT-1' plant = '1000'
          quota_arrangement_usage = '1' ) ) ).
    lo_repository->set_quota_usage_rules(
      it_rules = VALUE #(
        ( quota_usage                    = '1'
          includes_purchase_requisitions = 'X' ) ) ).
    lo_repository->set_quota_arrangements(
      it_arrangements = VALUE #(
        ( material = 'MAT-1' plant = '1000'
          quota_valid_from = '20261006' quota_valid_to = '20261231'
          quota_number = '0000000001' quota_item = '001'
          procurement_type = 'F' vendor = '0000100001' quota = 1 )
        ( material = 'MAT-1' plant = '1000'
          quota_valid_from = '20260101' quota_valid_to = '20261231'
          quota_number = '0000000001' quota_item = '002'
          procurement_type = 'F' special_procurement_type = 'K'
          vendor = '0000100002' quota = 1 )
        ( material = 'MAT-1' plant = '1000'
          quota_valid_from = '20260101' quota_valid_to = '20261231'
          quota_number = '0000000001' quota_item = '003'
          procurement_type = 'E' vendor = '0000100003' quota = 1 )
        ( material = 'MAT-1' plant = '1000'
          quota_valid_from = '20260101' quota_valid_to = '20261231'
          quota_number = '0000000001' quota_item = '004'
          procurement_type = 'F' vendor = '0000100004' quota = 1
          quota_rounding_profile = 'R001' ) ) ).
    DATA(lo_cut) = NEW zcl_repl_source_service(
      io_repository = lo_repository ).

    DATA(lt_candidates) = lo_cut->get_valid_pir_candidates(
      it_requests = VALUE #(
        ( material = 'MAT-1' plant = '1000'
          purchasing_org = '1000' delivery_date = '20261005' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = '0000100004'
      act = lt_candidates[ 1 ]-vendor ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_candidates[ 1 ]-is_quota_assigned ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'R001'
      act = lt_candidates[ 1 ]-quota_rounding_profile ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_candidates[ 2 ]-has_active_vendor_quota ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = lt_candidates[ 2 ]-is_quota_assigned ).
  ENDMETHOD.

  METHOD lists_valid_outline_sources.
    DATA(lo_repository) = NEW lcl_repl_source_repo_double( ).
    lo_repository->set_source_contexts(
      it_contexts = VALUE #(
        ( material = 'MAT-1' plant = '1000'
          source_list_required = 'X' ) ) ).
    lo_repository->set_outline_agreements(
      it_agreements = VALUE #(
        ( material = 'MAT-1' plant = '1000'
          purchasing_document = '4500000001' purchasing_item = '00010'
          source_list_record = '00001'
          source_list_valid_from = '20261001'
          source_list_valid_to = '20261231'
          source_list_fixed = 'X' source_list_mrp_usage = '1'
          purchasing_org = '1000' vendor = '0000100001'
          document_category = 'K'
          agreement_valid_from = '20261001'
          agreement_valid_to = '20261231' )
        ( material = 'MAT-1' plant = '1000'
          purchasing_document = '4500000002' purchasing_item = '00020'
          source_list_record = '00002'
          source_list_valid_from = '20260101'
          source_list_valid_to = '20261231'
          purchasing_org = '1000' vendor = '0000100002'
          document_category = 'L' ) ) ).
    DATA(lo_cut) = NEW zcl_repl_source_service(
      io_repository = lo_repository ).

    DATA(lt_candidates) = lo_cut->get_valid_outline_sources(
      it_requests = VALUE #(
        ( material = 'MAT-1' plant = '1000'
          purchasing_org = '1000' delivery_date = '20261005'
          preferred_vendor = '0000100002' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lines( lt_candidates ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '4500000001'
      act = lt_candidates[ 1 ]-purchasing_document ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lt_candidates[ 1 ]-candidate_rank ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'K'
      act = lt_candidates[ 1 ]-document_category ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_candidates[ 1 ]-source_list_required ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_candidates[ 1 ]-is_fixed_source ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_candidates[ 1 ]-is_mrp_relevant ).
    cl_abap_unit_assert=>assert_equals(
      exp = '4500000002'
      act = lt_candidates[ 2 ]-purchasing_document ).
    cl_abap_unit_assert=>assert_equals(
      exp = 2
      act = lt_candidates[ 2 ]-candidate_rank ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lt_candidates[ 2 ]-is_preferred_vendor ).

    lt_candidates = lo_cut->get_valid_outline_sources(
      it_requests             = VALUE #(
        ( material = 'MAT-1' plant = '1000'
          purchasing_org = '1000' delivery_date = '20261005'
          preferred_vendor = '0000100002' ) )
      iv_require_mrp_relevant = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_candidates ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '4500000001'
      act = lt_candidates[ 1 ]-purchasing_document ).

    lt_candidates = lo_cut->get_valid_outline_sources(
      it_requests             = VALUE #(
        ( material = 'MAT-1' plant = '1000'
          purchasing_org = '1000' delivery_date = '20261005'
          preferred_vendor = '0000100002' ) )
      iv_require_fixed_source = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      exp = 1
      act = lines( lt_candidates ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '4500000001'
      act = lt_candidates[ 1 ]-purchasing_document ).
  ENDMETHOD.

  METHOD filters_bad_outline_sources.
    DATA(lo_repository) = NEW lcl_repl_source_repo_double( ).
    lo_repository->set_outline_agreements(
      it_agreements = VALUE #(
        ( material = 'MAT-1' plant = '1000'
          purchasing_document = '4500000001' purchasing_item = '00010'
          purchasing_org = '1000' vendor = '0000100001'
          document_category = 'K'
          source_list_valid_from = '20261006'
          source_list_valid_to = '20261231' )
        ( material = 'MAT-1' plant = '1000'
          purchasing_document = '4500000002' purchasing_item = '00020'
          purchasing_org = '1000' vendor = '0000100002'
          document_category = 'L'
          agreement_valid_from = '20261006'
          agreement_valid_to = '20261231' )
        ( material = 'MAT-1' plant = '1000'
          purchasing_document = '4500000003' purchasing_item = '00030'
          purchasing_org = '1000' vendor = '0000100003'
          document_category = 'K' source_list_blocked = 'X' )
        ( material = 'MAT-1' plant = '1000'
          purchasing_document = '4500000004' purchasing_item = '00040'
          purchasing_org = '1000' vendor = '0000100004'
          document_category = 'K' item_deletion_indicator = 'L' )
        ( material = 'MAT-1' plant = '1000'
          purchasing_document = '4500000005' purchasing_item = '00050'
          purchasing_org = '1000' vendor = '0000100005'
          document_category = 'L' item_delivery_complete = 'X' )
        ( material = 'MAT-1' plant = '1000'
          purchasing_document = '4500000006' purchasing_item = '00060'
          purchasing_org = '1000' vendor = '0000100006'
          document_category = 'F' )
        ( material = 'MAT-1' plant = '1000'
          purchasing_document = '4500000007' purchasing_item = '00070'
          purchasing_org = '1000' vendor = '0000100007'
          source_list_vendor = '0000100008'
          document_category = 'K' ) ) ).
    DATA(lo_cut) = NEW zcl_repl_source_service(
      io_repository = lo_repository ).

    DATA(lt_candidates) = lo_cut->get_valid_outline_sources(
      it_requests = VALUE #(
        ( material = 'MAT-1' plant = '1000'
          purchasing_org = '1000' delivery_date = '20261005' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( lt_candidates ) ).
  ENDMETHOD.

  METHOD rejects_bad_agreement_request.
    DATA lv_invalid_request_rejected TYPE abap_bool.
    DATA lv_bad_fixed_rejected TYPE abap_bool.
    DATA lv_invalid_mrp_filter_rejected TYPE abap_bool.
    DATA(lo_repository) = NEW lcl_repl_source_repo_double( ).
    DATA(lo_cut) = NEW zcl_repl_source_service(
      io_repository = lo_repository ).

    TRY.
        lo_cut->get_valid_outline_sources(
          it_requests = VALUE #(
            ( material = 'MAT-1' purchasing_org = '1000'
              delivery_date = '20261005' ) ) ).
      CATCH zcx_invalid_stock_request.
        lv_invalid_request_rejected = abap_true.
    ENDTRY.
    TRY.
        lo_cut->get_valid_outline_sources(
          it_requests             = VALUE #( )
          iv_require_fixed_source = CONV abap_bool( 'Y' ) ).
      CATCH zcx_invalid_stock_request.
        lv_bad_fixed_rejected = abap_true.
    ENDTRY.
    TRY.
        lo_cut->get_valid_outline_sources(
          it_requests             = VALUE #( )
          iv_require_mrp_relevant = CONV abap_bool( 'Y' ) ).
      CATCH zcx_invalid_stock_request.
        lv_invalid_mrp_filter_rejected = abap_true.
    ENDTRY.

    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_invalid_request_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_bad_fixed_rejected ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_true
      act = lv_invalid_mrp_filter_rejected ).
  ENDMETHOD.

  METHOD respects_general_vendor_block.
    DATA(lo_repository) = NEW lcl_repl_source_repo_double( ).
    lo_repository->set_source_contexts(
      it_contexts = VALUE #(
        ( material = 'MAT-1' plant = '1000' )
        ( material = 'MAT-1' plant = '1000'
          source_list_vendor = '0000100001'
          source_list_blocked = 'X' ) ) ).
    lo_repository->set_outline_agreements(
      it_agreements = VALUE #(
        ( material = 'MAT-1' plant = '1000'
          purchasing_document = '4500000001' purchasing_item = '00010'
          purchasing_org = '1000' vendor = '0000100001'
          document_category = 'K' ) ) ).
    DATA(lo_cut) = NEW zcl_repl_source_service(
      io_repository = lo_repository ).

    DATA(lt_candidates) = lo_cut->get_valid_outline_sources(
      it_requests = VALUE #(
        ( material = 'MAT-1' plant = '1000'
          purchasing_org = '1000' delivery_date = '20261005' ) ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = 0
      act = lines( lt_candidates ) ).
  ENDMETHOD.
ENDCLASS.
