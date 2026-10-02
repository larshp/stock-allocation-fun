CLASS lcl_repl_source_repo_double DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_repl_source_repo.
    METHODS set_records
      IMPORTING
        it_records TYPE zif_repl_source_repo=>ty_info_records.
    METHODS set_source_contexts
      IMPORTING
        it_contexts TYPE zif_repl_source_repo=>ty_source_contexts.
    METHODS set_quota_arrangements
      IMPORTING
        it_arrangements TYPE zif_repl_source_repo=>ty_quota_arrangements.
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
    DATA mt_source_contexts TYPE zif_repl_source_repo=>ty_source_contexts.
    DATA mt_quota_arrangements TYPE
      zif_repl_source_repo=>ty_quota_arrangements.
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

  METHOD set_source_contexts.
    mt_source_contexts = it_contexts.
    mv_contexts_configured = abap_true.
  ENDMETHOD.

  METHOD set_quota_arrangements.
    mt_quota_arrangements = it_arrangements.
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
    METHODS exposes_auto_source_flag FOR TESTING.
    METHODS evaluates_quantity_limits FOR TESTING.
    METHODS reports_missing_uom_factor FOR TESTING.
    METHODS flags_invalid_qty_range FOR TESTING.
    METHODS rejects_missing_quantity_unit FOR TESTING.
    METHODS ranks_preferred_vendor_first FOR TESTING.
    METHODS ranks_by_quota_rating FOR TESTING.
    METHODS orders_zero_tie_by_item FOR TESTING.
    METHODS filters_quota_items FOR TESTING.
    METHODS skips_quota_read_without_usage FOR TESTING.
    METHODS requires_quota_usage_rule FOR TESTING.
    METHODS applies_source_list_rules FOR TESTING.
    METHODS filters_source_list_by_date FOR TESTING.
    METHODS excludes_global_source_block FOR TESTING.
    METHODS excludes_missing_mat_plant FOR TESTING.
    METHODS filters_each_delivery_date FOR TESTING.
    METHODS rejects_incomplete_pir_request FOR TESTING.
ENDCLASS.

CLASS ltcl_repl_source_service IMPLEMENTATION.
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
      exp = 5
      act = lt_candidates[ 1 ]-planned_delivery_days ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = lt_candidates[ 2 ]-is_plant_specific ).
    cl_abap_unit_assert=>assert_equals(
      exp = '0000100001'
      act = lt_candidates[ 2 ]-vendor ).
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
          procurement_type = 'F' vendor = '0000100001'
          quota = 3 quota_allocated_quantity = 780 )
        ( material = 'MAT-1' plant = '1000'
          quota_valid_from = '20260101' quota_valid_to = '20261231'
          quota_number = '0000000001' quota_item = '002'
          procurement_type = 'F' vendor = '0000100002'
          quota = 2 quota_allocated_quantity = 380 )
        ( material = 'MAT-1' plant = '1000'
          quota_valid_from = '20260101' quota_valid_to = '20261231'
          quota_number = '0000000001' quota_item = '003'
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
          procurement_type = 'F' vendor = '0000100004' quota = 1 ) ) ).
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
      exp = abap_true
      act = lt_candidates[ 2 ]-has_active_vendor_quota ).
    cl_abap_unit_assert=>assert_equals(
      exp = abap_false
      act = lt_candidates[ 2 ]-is_quota_assigned ).
  ENDMETHOD.
ENDCLASS.
