CLASS zcl_repl_source_service DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS c_standard_source_category TYPE eina-esokz VALUE '0'.
    CONSTANTS:
      c_suggestion_source_pir     TYPE c LENGTH 1 VALUE 'P',
      c_suggestion_source_outline TYPE c LENGTH 1 VALUE 'O'.

    TYPES ty_quantity_limit_status TYPE c LENGTH 1.
    CONSTANTS:
      c_quantity_limit_not_requested TYPE ty_quantity_limit_status VALUE 'N',
      c_quantity_limit_within_range  TYPE ty_quantity_limit_status VALUE 'I',
      c_quantity_limit_below_minimum TYPE ty_quantity_limit_status VALUE 'L',
      c_quantity_limit_above_maximum TYPE ty_quantity_limit_status VALUE 'H',
      c_quantity_limit_unit_mismatch TYPE ty_quantity_limit_status VALUE 'U',
      c_quantity_limit_no_conversion TYPE ty_quantity_limit_status VALUE 'C',
      c_quantity_limit_invalid_range TYPE ty_quantity_limit_status VALUE 'R'.

    TYPES ty_requests TYPE zif_repl_source_repo=>ty_requests.
    TYPES:
      BEGIN OF ty_candidate_quota_simulation,
        is_selected_source        TYPE abap_bool,
        is_quota_assigned         TYPE abap_bool,
        quota_number              TYPE equk-qunum,
        quota_item                TYPE equp-qupos,
        allocated_quantity_before TYPE decfloat34,
        rating_before             TYPE decfloat34,
      END OF ty_candidate_quota_simulation.
    TYPES:
      BEGIN OF ty_candidate,
        request_index               TYPE i,
        candidate_rank              TYPE i,
        request_priority            TYPE i,
        material                    TYPE mara-matnr,
        plant                       TYPE t001w-werks,
        purchasing_org              TYPE eine-ekorg,
        delivery_date               TYPE d,
        vendor                      TYPE eina-lifnr,
        info_record                 TYPE eina-infnr,
        source_category             TYPE eina-esokz,
        planned_delivery_days       TYPE eine-aplfz,
        is_auto_source_relevant     TYPE abap_bool,
        purchase_order_unit         TYPE eina-meins,
        base_unit                   TYPE eina-lmein,
        minimum_order_quantity      TYPE eine-minbm,
        maximum_order_quantity      TYPE eine-bstma,
        minimum_order_quantity_base TYPE decfloat34,
        maximum_order_quantity_base TYPE decfloat34,
        quantity_limit_status       TYPE ty_quantity_limit_status,
        record_plant                TYPE eine-werks,
        valid_from                  TYPE eina-lifab,
        valid_to                    TYPE eina-lifbi,
        source_list_required        TYPE abap_bool,
        quota_arrangement_usage     TYPE marc-usequ,
        quota_usage_rule            TYPE zif_repl_source_repo=>ty_quota_usage_rule,
        is_source_listed            TYPE abap_bool,
        is_fixed_source             TYPE abap_bool,
        is_mrp_relevant             TYPE abap_bool,
        has_active_vendor_quota     TYPE abap_bool,
        is_quota_assigned           TYPE abap_bool,
        quota_number                TYPE equk-qunum,
        quota_item                  TYPE equp-qupos,
        quota_priority              TYPE equp-preih,
        quota_min_lot_size          TYPE equp-minls,
        quota_max_lot_size          TYPE equp-maxls,
        quota_rounding_profile      TYPE equp-rdprf,
        quota_once_only             TYPE abap_bool,
        quota_value                 TYPE equp-quote,
        quota_min_split_quantity    TYPE equk-scmng,
        quota_base_quantity         TYPE equp-qubmg,
        quota_allocated_quantity    TYPE equp-qumng,
        quota_maximum_quantity      TYPE equp-maxmg,
        quota_rating                TYPE decfloat34,
        quota_simulation            TYPE ty_candidate_quota_simulation,
        source_list_record          TYPE eord-zeord,
        source_list_valid_from      TYPE eord-vdatu,
        source_list_valid_to        TYPE eord-bdatu,
        is_preferred_vendor         TYPE abap_bool,
        is_plant_specific           TYPE abap_bool,
      END OF ty_candidate.
    TYPES ty_candidates TYPE STANDARD TABLE OF ty_candidate
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_suggestion_candidate,
        suggestion_index TYPE i,
        candidate        TYPE ty_candidate,
      END OF ty_suggestion_candidate.
    TYPES ty_suggestion_candidates TYPE STANDARD TABLE OF
      ty_suggestion_candidate WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_quota_split,
        split_sequence     TYPE i,
        allocated_quantity TYPE decfloat34,
        proposal_quantity  TYPE decfloat34,
        candidate          TYPE ty_candidate,
      END OF ty_quota_split.
    TYPES ty_quota_splits TYPE STANDARD TABLE OF ty_quota_split
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_outline_source_candidate,
        request_index          TYPE i,
        candidate_rank         TYPE i,
        material               TYPE mara-matnr,
        plant                  TYPE t001w-werks,
        purchasing_org         TYPE eine-ekorg,
        delivery_date          TYPE d,
        vendor                 TYPE eina-lifnr,
        purchasing_document    TYPE eord-ebeln,
        purchasing_item        TYPE eord-ebelp,
        document_category      TYPE ekko-bstyp,
        agreement_valid_from   TYPE ekko-kdatb,
        agreement_valid_to     TYPE ekko-kdate,
        source_list_record     TYPE eord-zeord,
        source_list_valid_from TYPE eord-vdatu,
        source_list_valid_to   TYPE eord-bdatu,
        source_list_required   TYPE abap_bool,
        is_fixed_source        TYPE abap_bool,
        is_mrp_relevant        TYPE abap_bool,
        is_preferred_vendor    TYPE abap_bool,
      END OF ty_outline_source_candidate.
    TYPES ty_outline_source_candidates TYPE STANDARD TABLE OF
      ty_outline_source_candidate WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_suggestion_outline_source,
        suggestion_index TYPE i,
        candidate        TYPE ty_outline_source_candidate,
      END OF ty_suggestion_outline_source.
    TYPES ty_suggestion_outline_sources TYPE STANDARD TABLE OF
      ty_suggestion_outline_source WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_suggestion_source_option,
        suggestion_index  TYPE i,
        source_kind       TYPE c LENGTH 1,
        candidate_rank    TYPE i,
        pir_candidate     TYPE ty_candidate,
        outline_candidate TYPE ty_outline_source_candidate,
      END OF ty_suggestion_source_option.
    TYPES ty_suggestion_source_options TYPE STANDARD TABLE OF
      ty_suggestion_source_option WITH EMPTY KEY.

    METHODS constructor
      IMPORTING
        io_repository TYPE REF TO zif_repl_source_repo.

    METHODS get_valid_pir_candidates
      IMPORTING
        it_requests                  TYPE ty_requests
        iv_require_auto_source       TYPE abap_bool DEFAULT abap_false
        iv_require_source_listed     TYPE abap_bool DEFAULT abap_false
        iv_require_fixed_source      TYPE abap_bool DEFAULT abap_false
        iv_require_mrp_relevant      TYPE abap_bool DEFAULT abap_false
        iv_require_qty_in_range      TYPE abap_bool DEFAULT abap_false
        iv_simulate_quota_assignment TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rt_candidates)         TYPE ty_candidates
      RAISING
        zcx_invalid_stock_request.

    METHODS get_valid_outline_sources
      IMPORTING
        it_requests             TYPE ty_requests
        iv_require_fixed_source TYPE abap_bool DEFAULT abap_false
        iv_require_mrp_relevant TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rt_candidates)    TYPE ty_outline_source_candidates
      RAISING
        zcx_invalid_stock_request.

    METHODS get_suggestion_pir_candidates
      IMPORTING
        it_suggestions               TYPE zcl_prod_comp_service=>ty_comp_replenishments
        iv_purchasing_org            TYPE eine-ekorg
        iv_preferred_vendor          TYPE eina-lifnr OPTIONAL
        iv_require_auto_source       TYPE abap_bool DEFAULT abap_false
        iv_require_source_listed     TYPE abap_bool DEFAULT abap_false
        iv_require_fixed_source      TYPE abap_bool DEFAULT abap_false
        iv_require_mrp_relevant      TYPE abap_bool DEFAULT abap_false
        iv_require_qty_in_range      TYPE abap_bool DEFAULT abap_false
        iv_simulate_quota_assignment TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rt_options)            TYPE ty_suggestion_candidates
      RAISING
        zcx_invalid_stock_request.

    METHODS get_suggestion_outline_sources
      IMPORTING
        it_suggestions          TYPE zcl_prod_comp_service=>ty_comp_replenishments
        iv_purchasing_org       TYPE eine-ekorg
        iv_preferred_vendor     TYPE eina-lifnr OPTIONAL
        iv_require_fixed_source TYPE abap_bool DEFAULT abap_false
        iv_require_mrp_relevant TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rt_options)       TYPE ty_suggestion_outline_sources
      RAISING
        zcx_invalid_stock_request.

    METHODS get_suggestion_source_options
      IMPORTING
        it_suggestions               TYPE zcl_prod_comp_service=>ty_comp_replenishments
        iv_purchasing_org            TYPE eine-ekorg
        iv_preferred_vendor          TYPE eina-lifnr OPTIONAL
        iv_require_auto_source       TYPE abap_bool DEFAULT abap_false
        iv_require_source_listed     TYPE abap_bool DEFAULT abap_false
        iv_require_fixed_source      TYPE abap_bool DEFAULT abap_false
        iv_require_mrp_relevant      TYPE abap_bool DEFAULT abap_false
        iv_require_qty_in_range      TYPE abap_bool DEFAULT abap_false
        iv_simulate_quota_assignment TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rt_options)            TYPE ty_suggestion_source_options
      RAISING
        zcx_invalid_stock_request.

    CLASS-METHODS apply_suggestion_source_option
      IMPORTING
        it_suggestions        TYPE zcl_prod_comp_service=>ty_comp_replenishments
        is_option             TYPE ty_suggestion_source_option
      RETURNING
        VALUE(rt_suggestions) TYPE zcl_prod_comp_service=>ty_comp_replenishments
      RAISING
        zcx_invalid_stock_request.

    CLASS-METHODS apply_selected_source_options
      IMPORTING
        it_suggestions        TYPE zcl_prod_comp_service=>ty_comp_replenishments
        it_options            TYPE ty_suggestion_source_options
      RETURNING
        VALUE(rt_suggestions) TYPE zcl_prod_comp_service=>ty_comp_replenishments
      RAISING
        zcx_invalid_stock_request.

    METHODS simulate_split_quota
      IMPORTING
        it_candidates             TYPE ty_candidates
        iv_request_index          TYPE i
        iv_requested_quantity     TYPE decfloat34
        iv_requested_unit         TYPE eina-lmein
        iv_minimum_split_quantity TYPE decfloat34 OPTIONAL
      RETURNING
        VALUE(rt_splits)          TYPE ty_quota_splits
      RAISING
        zcx_invalid_stock_request.

  PRIVATE SECTION.
    TYPES ty_quota_arrangements TYPE
      zif_repl_source_repo=>ty_quota_arrangements.
    TYPES ty_quota_usage_rules TYPE
      zif_repl_source_repo=>ty_quota_usage_rules.
    TYPES ty_quota_rounding_profiles TYPE
      zif_repl_source_repo=>ty_quota_rounding_profiles.
    TYPES ty_quota_rounding_profile_keys TYPE
      zif_repl_source_repo=>ty_quota_rounding_profile_keys.
    TYPES:
      BEGIN OF ty_prior_quota_allocation,
        material     TYPE equk-matnr,
        plant        TYPE equk-werks,
        quota_number TYPE equk-qunum,
        quota_item   TYPE equp-qupos,
        quantity     TYPE decfloat34,
      END OF ty_prior_quota_allocation.
    TYPES ty_prior_quota_allocations TYPE HASHED TABLE OF
      ty_prior_quota_allocation WITH UNIQUE KEY material plant
        quota_number quota_item.
    TYPES:
      BEGIN OF ty_request_index,
        request_index TYPE i,
        material      TYPE mara-matnr,
        plant         TYPE t001w-werks,
        delivery_date TYPE d,
        priority      TYPE i,
      END OF ty_request_index.
    TYPES ty_request_indexes TYPE STANDARD TABLE OF ty_request_index
      WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_quota_match,
        has_active_arrangement    TYPE abap_bool,
        is_assigned               TYPE abap_bool,
        quota_number              TYPE equk-qunum,
        quota_item                TYPE equp-qupos,
        quota_priority            TYPE equp-preih,
        quota_min_lot_size        TYPE equp-minls,
        quota_max_lot_size        TYPE equp-maxls,
        quota_rounding_profile    TYPE equp-rdprf,
        source_assigned_once      TYPE equp-kzein,
        quota_value               TYPE equp-quote,
        minimum_split_quantity    TYPE equk-scmng,
        quota_base_quantity       TYPE equp-qubmg,
        quota_allocated_quantity  TYPE equp-qumng,
        quota_maximum_quantity    TYPE equp-maxmg,
        rating                    TYPE decfloat34,
        allocated_quantity_before TYPE decfloat34,
      END OF ty_quota_match.
    TYPES:
      BEGIN OF ty_quantity_evaluation,
        status                      TYPE ty_quantity_limit_status,
        purchase_order_unit         TYPE eina-meins,
        base_unit                   TYPE eina-lmein,
        minimum_order_quantity_base TYPE decfloat34,
        maximum_order_quantity_base TYPE decfloat34,
      END OF ty_quantity_evaluation.
    TYPES:
      BEGIN OF ty_ranked_candidate,
        request_index        TYPE i,
        has_quota_assignment TYPE abap_bool,
        quota_rating         TYPE decfloat34,
        quota_item           TYPE equp-qupos,
        is_fixed_source      TYPE abap_bool,
        is_preferred_vendor  TYPE abap_bool,
        is_plant_specific    TYPE abap_bool,
        vendor               TYPE eina-lifnr,
        info_record          TYPE eina-infnr,
        candidate            TYPE ty_candidate,
      END OF ty_ranked_candidate.
    TYPES ty_ranked_candidates TYPE STANDARD TABLE OF ty_ranked_candidate
      WITH EMPTY KEY.

    DATA mo_repository TYPE REF TO zif_repl_source_repo.

    METHODS get_quota_match
      IMPORTING
        iv_material          TYPE mara-matnr
        iv_plant             TYPE t001w-werks
        iv_vendor            TYPE eina-lifnr
        iv_delivery_date     TYPE d
        it_arrangements      TYPE ty_quota_arrangements
        it_prior_allocations TYPE ty_prior_quota_allocations
      RETURNING
        VALUE(rs_match)      TYPE ty_quota_match.

    METHODS apply_quota_item_lot_sizes
      IMPORTING
        it_splits            TYPE ty_quota_splits
        it_rounding_profiles TYPE ty_quota_rounding_profiles
      RETURNING
        VALUE(rt_splits)     TYPE ty_quota_splits
      RAISING
        zcx_invalid_stock_request.

    METHODS round_quota_proposal
      IMPORTING
        iv_plant           TYPE t001w-werks
        iv_profile         TYPE equp-rdprf
        iv_quantity        TYPE decfloat34
        it_profile_values  TYPE ty_quota_rounding_profiles
      RETURNING
        VALUE(rv_quantity) TYPE decfloat34
      RAISING
        zcx_invalid_stock_request.

    METHODS evaluate_quantity_limits
      IMPORTING
        iv_requested_quantity TYPE decfloat34
        iv_requested_unit     TYPE eina-lmein
        iv_minimum_quantity   TYPE eine-minbm
        iv_maximum_quantity   TYPE eine-bstma
        iv_purchase_unit      TYPE eina-meins
        iv_base_unit          TYPE eina-lmein
        iv_conversion_num     TYPE eina-umrez
        iv_conversion_den     TYPE eina-umren
      RETURNING
        VALUE(rs_evaluation)  TYPE ty_quantity_evaluation.
ENDCLASS.

CLASS zcl_repl_source_service IMPLEMENTATION.

  METHOD constructor.
    mo_repository = io_repository.
  ENDMETHOD.

  METHOD get_valid_pir_candidates.
    DATA lt_records TYPE zif_repl_source_repo=>ty_info_records.
    DATA lt_source_contexts TYPE zif_repl_source_repo=>ty_source_contexts.
    DATA lt_quota_requests TYPE zif_repl_source_repo=>ty_requests.
    DATA lt_quota_arrangements TYPE zif_repl_source_repo=>ty_quota_arrangements.
    DATA lt_quota_usage_keys TYPE zif_repl_source_repo=>ty_quota_usage_rules.
    DATA lt_quota_usage_rules TYPE ty_quota_usage_rules.
    DATA lt_ranked_candidates TYPE ty_ranked_candidates.
    DATA lt_request_candidates TYPE ty_ranked_candidates.
    DATA lt_request_indexes TYPE ty_request_indexes.
    DATA lt_prior_allocations TYPE ty_prior_quota_allocations.
    DATA lv_candidate_rank TYPE i.
    DATA lv_source_list_required TYPE abap_bool.
    DATA lv_source_listed TYPE abap_bool.
    DATA lv_source_blocked TYPE abap_bool.
    DATA lv_fixed_source TYPE abap_bool.
    DATA lv_mrp_relevant TYPE abap_bool.
    DATA lv_material_plant_found TYPE abap_bool.
    DATA lv_source_list_record TYPE eord-zeord.
    DATA lv_source_list_valid_from TYPE eord-vdatu.
    DATA lv_source_list_valid_to TYPE eord-bdatu.
    DATA lv_quota_arrangement_usage TYPE marc-usequ.
    DATA lv_quota_usage_found TYPE abap_bool.
    FIELD-SYMBOLS:
      <ls_prior_allocation> TYPE ty_prior_quota_allocation,
      <ls_request_candidate> TYPE ty_ranked_candidate.

    IF ( iv_require_auto_source <> abap_true
        AND iv_require_auto_source <> abap_false )
        OR ( iv_require_source_listed <> abap_true
          AND iv_require_source_listed <> abap_false )
        OR ( iv_require_fixed_source <> abap_true
          AND iv_require_fixed_source <> abap_false )
        OR ( iv_require_mrp_relevant <> abap_true
          AND iv_require_mrp_relevant <> abap_false )
        OR ( iv_require_qty_in_range <> abap_true
          AND iv_require_qty_in_range <> abap_false )
        OR ( iv_simulate_quota_assignment <> abap_true
          AND iv_simulate_quota_assignment <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-material IS INITIAL
          OR ls_request-plant IS INITIAL
          OR ls_request-purchasing_org IS INITIAL
          OR ls_request-delivery_date IS INITIAL
          OR ls_request-requested_quantity < 0
          OR ( ls_request-requested_quantity IS INITIAL
            AND ls_request-requested_quantity_unit IS NOT INITIAL )
          OR ( ls_request-requested_quantity > 0
            AND ls_request-requested_quantity_unit IS INITIAL ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      APPEND VALUE #(
        request_index = sy-tabix
        material      = ls_request-material
        plant         = ls_request-plant
        delivery_date = ls_request-delivery_date
        priority      = ls_request-priority )
        TO lt_request_indexes.
    ENDLOOP.
    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.
    IF iv_simulate_quota_assignment = abap_true.
      SORT lt_request_indexes BY material plant delivery_date
        priority DESCENDING request_index.
    ENDIF.

    lt_records = mo_repository->get_candidates_bulk(
      it_requests = it_requests ).
    lt_source_contexts = mo_repository->get_source_contexts_bulk(
      it_requests = it_requests ).

    LOOP AT lt_source_contexts INTO DATA(ls_usage_context)
      WHERE quota_arrangement_usage IS NOT INITIAL.
      APPEND VALUE #(
        quota_usage = ls_usage_context-quota_arrangement_usage )
        TO lt_quota_usage_keys.
    ENDLOOP.
    SORT lt_quota_usage_keys BY quota_usage.
    DELETE ADJACENT DUPLICATES FROM lt_quota_usage_keys
      COMPARING quota_usage.
    IF lt_quota_usage_keys IS NOT INITIAL.
      lt_quota_usage_rules = mo_repository->get_quota_usage_rules_bulk(
        it_usages = lt_quota_usage_keys ).
    ENDIF.

    LOOP AT it_requests INTO ls_request.
      CLEAR lv_quota_usage_found.
      LOOP AT lt_source_contexts INTO DATA(ls_quota_context)
        WHERE material = ls_request-material
          AND plant = ls_request-plant.
        IF ls_quota_context-quota_arrangement_usage IS NOT INITIAL.
          READ TABLE lt_quota_usage_rules TRANSPORTING NO FIELDS
            WITH KEY quota_usage =
              ls_quota_context-quota_arrangement_usage.
          IF sy-subrc <> 0.
            CONTINUE.
          ENDIF.
          lv_quota_usage_found = abap_true.
          EXIT.
        ENDIF.
      ENDLOOP.
      IF lv_quota_usage_found = abap_true.
        APPEND ls_request TO lt_quota_requests.
      ENDIF.
    ENDLOOP.
    SORT lt_quota_requests BY material plant.
    DELETE ADJACENT DUPLICATES FROM lt_quota_requests
      COMPARING material plant.
    IF lt_quota_requests IS NOT INITIAL.
      lt_quota_arrangements = mo_repository->get_quota_arrangements_bulk(
        it_requests = lt_quota_requests ).
    ENDIF.

    LOOP AT lt_request_indexes INTO DATA(ls_request_index).
      DATA(lv_request_index) = ls_request_index-request_index.
      READ TABLE it_requests INDEX lv_request_index INTO ls_request.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      CLEAR lt_request_candidates.
      LOOP AT lt_records INTO DATA(ls_record).
        IF ls_record-material <> ls_request-material
            OR ls_record-purchasing_org <> ls_request-purchasing_org
            OR ( ls_record-record_plant IS NOT INITIAL
              AND ls_record-record_plant <> ls_request-plant )
            OR ls_record-vendor IS INITIAL
            OR ls_record-info_record IS INITIAL
            OR ls_record-source_category <> c_standard_source_category
            OR ( iv_require_auto_source = abap_true
              AND ls_record-auto_source_indicator <> 'X' )
            OR ls_record-general_deletion_indicator IS NOT INITIAL
            OR ls_record-purchasing_deletion_indicator IS NOT INITIAL
            OR ( ls_record-valid_from IS NOT INITIAL
              AND ls_record-valid_from > ls_request-delivery_date )
            OR ( ls_record-valid_to IS NOT INITIAL
              AND ls_record-valid_to < ls_request-delivery_date ).
          CONTINUE.
        ENDIF.

        CLEAR: lv_source_list_required, lv_source_listed,
          lv_source_blocked, lv_fixed_source, lv_mrp_relevant,
          lv_material_plant_found,
          lv_source_list_record, lv_source_list_valid_from,
          lv_source_list_valid_to, lv_quota_arrangement_usage.
        DATA(ls_quota_usage_rule) = VALUE
          zif_repl_source_repo=>ty_quota_usage_rule( ).
        LOOP AT lt_source_contexts INTO DATA(ls_source_context)
          WHERE material = ls_request-material
            AND plant = ls_request-plant.
          lv_material_plant_found = abap_true.
          IF ls_source_context-source_list_required IS NOT INITIAL.
            lv_source_list_required = abap_true.
          ENDIF.
          IF ls_source_context-quota_arrangement_usage IS NOT INITIAL.
            lv_quota_arrangement_usage =
              ls_source_context-quota_arrangement_usage.
          ENDIF.
          IF ( ls_source_context-source_list_purchasing_org IS NOT INITIAL
                AND ls_source_context-source_list_purchasing_org
                  <> ls_request-purchasing_org )
              OR ( ls_source_context-source_list_valid_from IS NOT INITIAL
                AND ls_source_context-source_list_valid_from
                  > ls_request-delivery_date )
              OR ( ls_source_context-source_list_valid_to IS NOT INITIAL
                AND ls_source_context-source_list_valid_to
                  < ls_request-delivery_date ).
            CONTINUE.
          ENDIF.
          IF ls_source_context-source_list_blocked IS NOT INITIAL
              AND ls_source_context-source_list_agreement IS INITIAL
              AND ls_source_context-source_list_agreement_item IS INITIAL
              AND ( ls_source_context-source_list_vendor IS INITIAL
                OR ls_source_context-source_list_vendor = ls_record-vendor ).
            lv_source_blocked = abap_true.
            CONTINUE.
          ENDIF.
          IF ls_source_context-source_list_agreement IS NOT INITIAL
              OR ls_source_context-source_list_agreement_item IS NOT INITIAL
              OR ls_source_context-source_list_vendor IS INITIAL
              OR ls_source_context-source_list_vendor <> ls_record-vendor.
            CONTINUE.
          ENDIF.
          lv_source_listed = abap_true.
          IF ls_source_context-source_list_fixed IS NOT INITIAL.
            lv_fixed_source = abap_true.
            lv_source_list_record = ls_source_context-source_list_record.
            lv_source_list_valid_from =
              ls_source_context-source_list_valid_from.
            lv_source_list_valid_to = ls_source_context-source_list_valid_to.
          ELSEIF lv_fixed_source = abap_false.
            lv_source_list_record = ls_source_context-source_list_record.
            lv_source_list_valid_from =
              ls_source_context-source_list_valid_from.
            lv_source_list_valid_to = ls_source_context-source_list_valid_to.
          ENDIF.
          IF ls_source_context-source_list_mrp_usage IS NOT INITIAL.
            lv_mrp_relevant = abap_true.
          ENDIF.
        ENDLOOP.
        IF lv_material_plant_found = abap_false
            OR lv_source_blocked = abap_true
            OR ( lv_source_list_required = abap_true
              AND lv_source_listed = abap_false )
            OR ( iv_require_source_listed = abap_true
              AND lv_source_listed = abap_false )
            OR ( iv_require_fixed_source = abap_true
              AND lv_fixed_source = abap_false )
            OR ( iv_require_mrp_relevant = abap_true
              AND lv_mrp_relevant = abap_false ).
          CONTINUE.
        ENDIF.

        READ TABLE lt_quota_usage_rules INTO ls_quota_usage_rule
          WITH KEY quota_usage = lv_quota_arrangement_usage.

        DATA(ls_quota_match) = get_quota_match(
          iv_material          = ls_request-material
          iv_plant             = ls_request-plant
          iv_vendor            = ls_record-vendor
          iv_delivery_date     = ls_request-delivery_date
          it_arrangements      = lt_quota_arrangements
          it_prior_allocations = VALUE #( ) ).
        DATA(ls_ranking_match) = ls_quota_match.
        DATA(ls_quota_simulation) =
          VALUE ty_candidate_quota_simulation( ).
        IF iv_simulate_quota_assignment = abap_true.
          ls_ranking_match = get_quota_match(
            iv_material          = ls_request-material
            iv_plant             = ls_request-plant
            iv_vendor            = ls_record-vendor
            iv_delivery_date     = ls_request-delivery_date
            it_arrangements      = lt_quota_arrangements
            it_prior_allocations = lt_prior_allocations ).
          ls_quota_simulation = VALUE #(
            is_quota_assigned         = ls_ranking_match-is_assigned
            quota_number              = ls_ranking_match-quota_number
            quota_item                = ls_ranking_match-quota_item
            allocated_quantity_before =
              ls_ranking_match-allocated_quantity_before
            rating_before             = ls_ranking_match-rating ).
        ENDIF.
        IF iv_simulate_quota_assignment = abap_true
            AND ls_ranking_match-is_assigned = abap_true
            AND ls_ranking_match-quota_maximum_quantity > 0
            AND ( ls_ranking_match-allocated_quantity_before >=
                  CONV decfloat34(
                    ls_ranking_match-quota_maximum_quantity )
              OR ( ls_request-requested_quantity > 0
                AND ls_request-requested_quantity_unit = ls_record-base_unit
                AND ls_quota_usage_rule-includes_purchase_requisitions = 'X'
                AND ls_ranking_match-allocated_quantity_before
                  + CONV decfloat34( ls_request-requested_quantity )
                  >= CONV decfloat34(
                    ls_ranking_match-quota_maximum_quantity ) ) ).
          CONTINUE.
        ENDIF.

        DATA(ls_quantity_evaluation) = evaluate_quantity_limits(
          iv_requested_quantity = ls_request-requested_quantity
          iv_requested_unit     = ls_request-requested_quantity_unit
          iv_minimum_quantity   = ls_record-minimum_order_quantity
          iv_maximum_quantity   = ls_record-maximum_order_quantity
          iv_purchase_unit      = ls_record-purchase_order_unit
          iv_base_unit          = ls_record-base_unit
          iv_conversion_num     = ls_record-order_unit_to_base_numerator
          iv_conversion_den     = ls_record-order_unit_to_base_denominator ).
        IF iv_require_qty_in_range = abap_true
            AND ls_request-requested_quantity > 0
            AND ls_quantity_evaluation-status
              <> c_quantity_limit_within_range.
          CONTINUE.
        ENDIF.

        DATA(ls_candidate) = VALUE ty_candidate(
          request_index               = lv_request_index
          request_priority            = ls_request-priority
          material                    = ls_request-material
          plant                       = ls_request-plant
          purchasing_org              = ls_request-purchasing_org
          delivery_date               = ls_request-delivery_date
          vendor                      = ls_record-vendor
          info_record                 = ls_record-info_record
          source_category             = ls_record-source_category
          planned_delivery_days       = ls_record-planned_delivery_days
          is_auto_source_relevant     = COND #(
            WHEN ls_record-auto_source_indicator = 'X'
            THEN abap_true
            ELSE abap_false )
          purchase_order_unit         = ls_record-purchase_order_unit
          base_unit                   = ls_record-base_unit
          minimum_order_quantity      = ls_record-minimum_order_quantity
          maximum_order_quantity      = ls_record-maximum_order_quantity
          minimum_order_quantity_base =
            ls_quantity_evaluation-minimum_order_quantity_base
          maximum_order_quantity_base =
            ls_quantity_evaluation-maximum_order_quantity_base
          quantity_limit_status       = ls_quantity_evaluation-status
          record_plant                = ls_record-record_plant
          valid_from                  = ls_record-valid_from
          valid_to                    = ls_record-valid_to
          source_list_required        = lv_source_list_required
          quota_usage_rule            = ls_quota_usage_rule
          is_source_listed            = lv_source_listed
          is_fixed_source             = lv_fixed_source
          is_mrp_relevant             = lv_mrp_relevant
          has_active_vendor_quota     =
            ls_quota_match-has_active_arrangement
          is_quota_assigned           = ls_quota_match-is_assigned
          quota_number                = ls_quota_match-quota_number
          quota_item                  = ls_quota_match-quota_item
          quota_priority              = ls_quota_match-quota_priority
          quota_min_lot_size          = ls_quota_match-quota_min_lot_size
          quota_max_lot_size          = ls_quota_match-quota_max_lot_size
          quota_rounding_profile      =
            ls_quota_match-quota_rounding_profile
          quota_once_only             = COND abap_bool(
            WHEN ls_quota_match-source_assigned_once = 'X'
            THEN abap_true
            ELSE abap_false )
          quota_value                 = ls_quota_match-quota_value
          quota_min_split_quantity    =
            ls_quota_match-minimum_split_quantity
          quota_base_quantity         = ls_quota_match-quota_base_quantity
          quota_allocated_quantity    =
            ls_quota_match-quota_allocated_quantity
          quota_maximum_quantity      =
            ls_quota_match-quota_maximum_quantity
          quota_rating                = ls_quota_match-rating
          quota_simulation            = ls_quota_simulation
          source_list_record          = lv_source_list_record
          source_list_valid_from      = lv_source_list_valid_from
          source_list_valid_to        = lv_source_list_valid_to
          quota_arrangement_usage     = lv_quota_arrangement_usage
          is_preferred_vendor         = COND #(
            WHEN ls_record-vendor = ls_request-preferred_vendor
              AND ls_request-preferred_vendor IS NOT INITIAL
            THEN abap_true
            ELSE abap_false )
          is_plant_specific           = COND #(
            WHEN ls_record-record_plant = ls_request-plant
            THEN abap_true
            ELSE abap_false ) ).
        APPEND VALUE #(
          request_index        = lv_request_index
          has_quota_assignment = ls_ranking_match-is_assigned
          quota_rating         = ls_ranking_match-rating
          quota_item           = ls_ranking_match-quota_item
          is_fixed_source      = lv_fixed_source
          is_preferred_vendor  = ls_candidate-is_preferred_vendor
          is_plant_specific    = ls_candidate-is_plant_specific
          vendor               = ls_record-vendor
          info_record          = ls_record-info_record
          candidate            = ls_candidate )
          TO lt_request_candidates.
      ENDLOOP.
      SORT lt_request_candidates BY has_quota_assignment DESCENDING
        quota_rating ASCENDING quota_item ASCENDING
        is_fixed_source DESCENDING is_preferred_vendor DESCENDING
        is_plant_specific DESCENDING vendor info_record.
      CLEAR lv_candidate_rank.
      LOOP AT lt_request_candidates ASSIGNING <ls_request_candidate>.
        ADD 1 TO lv_candidate_rank.
        <ls_request_candidate>-candidate-candidate_rank =
          lv_candidate_rank.
      ENDLOOP.
      IF iv_simulate_quota_assignment = abap_true
          AND lt_request_candidates IS NOT INITIAL.
        READ TABLE lt_request_candidates INTO DATA(ls_selected_ranked)
          INDEX 1.
        ls_selected_ranked-candidate-quota_simulation-is_selected_source =
          abap_true.
        MODIFY lt_request_candidates FROM ls_selected_ranked INDEX 1.
        DATA(ls_selected_simulation) =
          ls_selected_ranked-candidate-quota_simulation.
        IF ls_selected_ranked-candidate-quota_simulation-is_quota_assigned
              = abap_true
            AND ls_request-requested_quantity > 0
            AND ls_selected_ranked-candidate-quota_usage_rule-includes_purchase_requisitions
              = 'X'.
          IF ls_request-requested_quantity_unit
              <> ls_selected_ranked-candidate-base_unit.
            RAISE EXCEPTION TYPE zcx_invalid_stock_request.
          ENDIF.
          READ TABLE lt_prior_allocations ASSIGNING <ls_prior_allocation>
            WITH TABLE KEY material = ls_request-material
                           plant = ls_request-plant
                           quota_number =
                             ls_selected_simulation-quota_number
                           quota_item =
                             ls_selected_simulation-quota_item.
          IF sy-subrc = 0.
            <ls_prior_allocation>-quantity =
              <ls_prior_allocation>-quantity
                + ls_request-requested_quantity.
          ELSE.
            INSERT VALUE #(
              material     = ls_request-material
              plant        = ls_request-plant
              quota_number = ls_selected_simulation-quota_number
              quota_item   = ls_selected_simulation-quota_item
              quantity     = ls_request-requested_quantity )
              INTO TABLE lt_prior_allocations.
          ENDIF.
        ENDIF.
      ENDIF.
      APPEND LINES OF lt_request_candidates TO lt_ranked_candidates.
    ENDLOOP.

    SORT lt_ranked_candidates BY request_index ASCENDING
      has_quota_assignment DESCENDING quota_rating ASCENDING
      quota_item ASCENDING is_fixed_source DESCENDING
      is_preferred_vendor DESCENDING is_plant_specific DESCENDING
      vendor info_record.
    LOOP AT lt_ranked_candidates INTO DATA(ls_ranked_candidate).
      APPEND ls_ranked_candidate-candidate TO rt_candidates.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_suggestion_pir_candidates.
    TYPES:
      BEGIN OF ty_suggestion_request_map,
        request_index    TYPE i,
        suggestion_index TYPE i,
      END OF ty_suggestion_request_map.
    DATA lt_requests TYPE ty_requests.
    DATA lt_suggestion_request_map TYPE HASHED TABLE OF
      ty_suggestion_request_map WITH UNIQUE KEY request_index.
    DATA lt_candidates TYPE ty_candidates.

    LOOP AT it_suggestions INTO DATA(ls_suggestion).
      IF ls_suggestion-suggested_base_quantity < 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      IF ls_suggestion-suggested_base_quantity = 0
          OR ls_suggestion-procurement_type <> 'F'
          OR ls_suggestion-special_procurement_key IS NOT INITIAL.
        CONTINUE.
      ENDIF.
      IF ls_suggestion-material IS INITIAL
          OR ls_suggestion-plant IS INITIAL
          OR ls_suggestion-base_unit IS INITIAL
          OR ls_suggestion-required_date IS INITIAL
          OR iv_purchasing_org IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      DATA(lv_suggestion_index) = sy-tabix.
      DATA(lv_request_index) = lines( lt_requests ) + 1.
      APPEND VALUE #(
        material                = ls_suggestion-material
        plant                   = ls_suggestion-plant
        purchasing_org          = iv_purchasing_org
        delivery_date           = ls_suggestion-required_date
        requested_quantity      = ls_suggestion-suggested_base_quantity
        requested_quantity_unit = ls_suggestion-base_unit
        preferred_vendor        = iv_preferred_vendor )
        TO lt_requests.
      INSERT VALUE #(
        request_index    = lv_request_index
        suggestion_index = lv_suggestion_index )
        INTO TABLE lt_suggestion_request_map.
    ENDLOOP.

    lt_candidates = get_valid_pir_candidates(
      it_requests                  = lt_requests
      iv_require_auto_source       = iv_require_auto_source
      iv_require_source_listed     = iv_require_source_listed
      iv_require_fixed_source      = iv_require_fixed_source
      iv_require_mrp_relevant      = iv_require_mrp_relevant
      iv_require_qty_in_range      = iv_require_qty_in_range
      iv_simulate_quota_assignment = iv_simulate_quota_assignment ).

    LOOP AT lt_candidates INTO DATA(ls_candidate).
      READ TABLE lt_suggestion_request_map
        WITH TABLE KEY request_index = ls_candidate-request_index
        INTO DATA(ls_suggestion_request_map).
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      APPEND VALUE #(
        suggestion_index = ls_suggestion_request_map-suggestion_index
        candidate        = ls_candidate ) TO rt_options.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_suggestion_outline_sources.
    TYPES:
      BEGIN OF ty_suggestion_request_map,
        request_index    TYPE i,
        suggestion_index TYPE i,
      END OF ty_suggestion_request_map.
    DATA lt_requests TYPE ty_requests.
    DATA lt_suggestion_request_map TYPE HASHED TABLE OF
      ty_suggestion_request_map WITH UNIQUE KEY request_index.
    DATA lt_candidates TYPE ty_outline_source_candidates.

    LOOP AT it_suggestions INTO DATA(ls_suggestion).
      IF ls_suggestion-suggested_base_quantity < 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      IF ls_suggestion-suggested_base_quantity = 0
          OR ls_suggestion-procurement_type <> 'F'
          OR ls_suggestion-special_procurement_key IS NOT INITIAL.
        CONTINUE.
      ENDIF.
      IF ls_suggestion-material IS INITIAL
          OR ls_suggestion-plant IS INITIAL
          OR ls_suggestion-base_unit IS INITIAL
          OR ls_suggestion-required_date IS INITIAL
          OR iv_purchasing_org IS INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      DATA(lv_suggestion_index) = sy-tabix.
      DATA(lv_request_index) = lines( lt_requests ) + 1.
      APPEND VALUE #(
        material                = ls_suggestion-material
        plant                   = ls_suggestion-plant
        purchasing_org          = iv_purchasing_org
        delivery_date           = ls_suggestion-required_date
        requested_quantity      = ls_suggestion-suggested_base_quantity
        requested_quantity_unit = ls_suggestion-base_unit
        preferred_vendor        = iv_preferred_vendor )
        TO lt_requests.
      INSERT VALUE #(
        request_index    = lv_request_index
        suggestion_index = lv_suggestion_index )
        INTO TABLE lt_suggestion_request_map.
    ENDLOOP.

    lt_candidates = get_valid_outline_sources(
      it_requests             = lt_requests
      iv_require_fixed_source = iv_require_fixed_source
      iv_require_mrp_relevant = iv_require_mrp_relevant ).

    LOOP AT lt_candidates INTO DATA(ls_candidate).
      READ TABLE lt_suggestion_request_map
        WITH TABLE KEY request_index = ls_candidate-request_index
        INTO DATA(ls_suggestion_request_map).
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      APPEND VALUE #(
        suggestion_index = ls_suggestion_request_map-suggestion_index
        candidate        = ls_candidate ) TO rt_options.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_suggestion_source_options.
    DATA lt_pir_options TYPE ty_suggestion_candidates.
    DATA lt_outline_options TYPE ty_suggestion_outline_sources.

    lt_pir_options = get_suggestion_pir_candidates(
      it_suggestions               = it_suggestions
      iv_purchasing_org            = iv_purchasing_org
      iv_preferred_vendor          = iv_preferred_vendor
      iv_require_auto_source       = iv_require_auto_source
      iv_require_source_listed     = iv_require_source_listed
      iv_require_fixed_source      = iv_require_fixed_source
      iv_require_mrp_relevant      = iv_require_mrp_relevant
      iv_require_qty_in_range      = iv_require_qty_in_range
      iv_simulate_quota_assignment = iv_simulate_quota_assignment ).
    lt_outline_options = get_suggestion_outline_sources(
      it_suggestions          = it_suggestions
      iv_purchasing_org       = iv_purchasing_org
      iv_preferred_vendor     = iv_preferred_vendor
      iv_require_fixed_source = iv_require_fixed_source
      iv_require_mrp_relevant = iv_require_mrp_relevant ).

    LOOP AT lt_pir_options INTO DATA(ls_pir_option).
      APPEND VALUE #(
        suggestion_index = ls_pir_option-suggestion_index
        source_kind      = c_suggestion_source_pir
        candidate_rank   = ls_pir_option-candidate-candidate_rank
        pir_candidate    = ls_pir_option-candidate ) TO rt_options.
    ENDLOOP.
    LOOP AT lt_outline_options INTO DATA(ls_outline_option).
      APPEND VALUE #(
        suggestion_index  = ls_outline_option-suggestion_index
        source_kind       = c_suggestion_source_outline
        candidate_rank    = ls_outline_option-candidate-candidate_rank
        outline_candidate = ls_outline_option-candidate ) TO rt_options.
    ENDLOOP.
    SORT rt_options BY suggestion_index ASCENDING source_kind DESCENDING
      candidate_rank ASCENDING.
  ENDMETHOD.

  METHOD apply_suggestion_source_option.
    DATA ls_suggestion TYPE zcl_prod_comp_service=>ty_comp_replenishment.

    IF is_option-suggestion_index <= 0
        OR is_option-candidate_rank <= 0
        OR is_option-suggestion_index > lines( it_suggestions )
        OR ( is_option-source_kind <> c_suggestion_source_pir
          AND is_option-source_kind <> c_suggestion_source_outline ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    READ TABLE it_suggestions INDEX is_option-suggestion_index
      INTO ls_suggestion.
    IF sy-subrc <> 0
        OR ls_suggestion-material IS INITIAL
        OR ls_suggestion-plant IS INITIAL
        OR ls_suggestion-base_unit IS INITIAL
        OR ls_suggestion-required_date IS INITIAL
        OR ls_suggestion-suggested_base_quantity <= 0
        OR ls_suggestion-procurement_type <> 'F'
        OR ls_suggestion-special_procurement_key IS NOT INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    CLEAR: ls_suggestion-source_vendor,
      ls_suggestion-source_purchasing_org,
      ls_suggestion-source_info_record,
      ls_suggestion-source_agreement,
      ls_suggestion-source_agreement_item,
      ls_suggestion-source_category,
      ls_suggestion-source_planned_delivery_days.

    CASE is_option-source_kind.
      WHEN c_suggestion_source_pir.
        IF is_option-outline_candidate IS NOT INITIAL
            OR is_option-pir_candidate-request_index <= 0
            OR is_option-candidate_rank
              <> is_option-pir_candidate-candidate_rank
            OR is_option-pir_candidate-material <> ls_suggestion-material
            OR is_option-pir_candidate-plant <> ls_suggestion-plant
            OR is_option-pir_candidate-delivery_date
              <> ls_suggestion-required_date
            OR is_option-pir_candidate-purchasing_org IS INITIAL
            OR is_option-pir_candidate-vendor IS INITIAL
            OR is_option-pir_candidate-info_record IS INITIAL
            OR is_option-pir_candidate-source_category
              <> c_standard_source_category.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        ls_suggestion-source_vendor = is_option-pir_candidate-vendor.
        ls_suggestion-source_purchasing_org =
          is_option-pir_candidate-purchasing_org.
        ls_suggestion-source_info_record =
          is_option-pir_candidate-info_record.
        ls_suggestion-source_category =
          is_option-pir_candidate-source_category.
        ls_suggestion-source_planned_delivery_days =
          is_option-pir_candidate-planned_delivery_days.
      WHEN c_suggestion_source_outline.
        IF is_option-pir_candidate IS NOT INITIAL
            OR is_option-outline_candidate-request_index <= 0
            OR is_option-candidate_rank
              <> is_option-outline_candidate-candidate_rank
            OR is_option-outline_candidate-material <> ls_suggestion-material
            OR is_option-outline_candidate-plant <> ls_suggestion-plant
            OR is_option-outline_candidate-delivery_date
              <> ls_suggestion-required_date
            OR is_option-outline_candidate-purchasing_org IS INITIAL
            OR is_option-outline_candidate-vendor IS INITIAL
            OR is_option-outline_candidate-purchasing_document IS INITIAL
            OR is_option-outline_candidate-purchasing_item IS INITIAL
            OR ( is_option-outline_candidate-document_category <> 'K'
              AND is_option-outline_candidate-document_category <> 'L' ).
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        ls_suggestion-source_vendor =
          is_option-outline_candidate-vendor.
        ls_suggestion-source_purchasing_org =
          is_option-outline_candidate-purchasing_org.
        ls_suggestion-source_agreement =
          is_option-outline_candidate-purchasing_document.
        ls_suggestion-source_agreement_item =
          is_option-outline_candidate-purchasing_item.
    ENDCASE.

    rt_suggestions = it_suggestions.
    MODIFY rt_suggestions FROM ls_suggestion
      INDEX is_option-suggestion_index.
  ENDMETHOD.

  METHOD apply_selected_source_options.
    TYPES:
      BEGIN OF ty_selected_suggestion_index,
        suggestion_index TYPE i,
      END OF ty_selected_suggestion_index.
    DATA lt_selected_suggestion_indexes TYPE HASHED TABLE OF
      ty_selected_suggestion_index WITH UNIQUE KEY suggestion_index.
    DATA ls_suggestion TYPE zcl_prod_comp_service=>ty_comp_replenishment.
    DATA ls_option TYPE ty_suggestion_source_option.
    DATA ls_single_option TYPE ty_suggestion_source_option.
    DATA lt_single_suggestion TYPE
      zcl_prod_comp_service=>ty_comp_replenishments.
    DATA lt_applied_suggestion TYPE
      zcl_prod_comp_service=>ty_comp_replenishments.

    rt_suggestions = it_suggestions.
    LOOP AT it_options INTO ls_option.
      IF ls_option-suggestion_index <= 0
          OR ls_option-suggestion_index > lines( it_suggestions ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      READ TABLE lt_selected_suggestion_indexes TRANSPORTING NO FIELDS
        WITH TABLE KEY suggestion_index = ls_option-suggestion_index.
      IF sy-subrc = 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT VALUE #(
        suggestion_index = ls_option-suggestion_index )
        INTO TABLE lt_selected_suggestion_indexes.

      READ TABLE rt_suggestions INDEX ls_option-suggestion_index
        INTO ls_suggestion.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      lt_single_suggestion = VALUE #( ( ls_suggestion ) ).
      ls_single_option = ls_option.
      ls_single_option-suggestion_index = 1.
      lt_applied_suggestion = zcl_repl_source_service=>apply_suggestion_source_option(
        it_suggestions = lt_single_suggestion
        is_option      = ls_single_option ).
      READ TABLE lt_applied_suggestion INDEX 1 INTO ls_suggestion.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      MODIFY rt_suggestions FROM ls_suggestion
        INDEX ls_option-suggestion_index.
    ENDLOOP.
  ENDMETHOD.

  METHOD simulate_split_quota.
    TYPES:
      BEGIN OF ty_split_candidate,
        quota_number   TYPE equk-qunum,
        quota_item     TYPE equp-qupos,
        quota_value    TYPE equp-quote,
        priority_group TYPE i,
        quota_priority TYPE equp-preih,
        candidate_rank TYPE i,
        is_capped      TYPE abap_bool,
        candidate      TYPE ty_candidate,
      END OF ty_split_candidate.
    DATA lt_unique_candidates TYPE HASHED TABLE OF ty_split_candidate
      WITH UNIQUE KEY quota_number quota_item.
    DATA lt_split_candidates TYPE STANDARD TABLE OF ty_split_candidate
      WITH EMPTY KEY.
    DATA lv_material TYPE mara-matnr.
    DATA lv_plant TYPE t001w-werks.
    DATA lv_purchasing_org TYPE eine-ekorg.
    DATA lv_delivery_date TYPE d.
    DATA lv_quota_number TYPE equk-qunum.
    DATA lv_base_unit TYPE eina-lmein.
    DATA lv_total_quota TYPE decfloat34.
    DATA lv_remaining_quota TYPE decfloat34.
    DATA lv_remaining_quantity TYPE decfloat34.
    DATA lv_split_quantity TYPE decfloat34.
    DATA lv_minimum_split_quantity TYPE decfloat34.
    DATA lv_header_min_split_qty TYPE equk-scmng.
    DATA lv_has_context TYPE abap_bool.
    DATA lv_has_capped_source TYPE abap_bool.
    DATA lv_has_once_capped TYPE abap_bool.
    DATA lv_has_max_lot_capped TYPE abap_bool.
    DATA lv_remaining_request TYPE decfloat34.
    DATA lv_minimum_lot_size TYPE decfloat34.
    DATA lv_maximum_lot_size TYPE decfloat34.
    DATA lv_proposal_quantity TYPE decfloat34.
    DATA lt_fixed_splits TYPE ty_quota_splits.
    DATA lt_final_splits TYPE ty_quota_splits.
    DATA lt_rounding_profile_keys TYPE ty_quota_rounding_profile_keys.
    DATA lt_rounding_profiles TYPE ty_quota_rounding_profiles.

    IF iv_request_index <= 0
        OR iv_requested_quantity <= 0
        OR iv_requested_unit IS INITIAL
        OR ( iv_minimum_split_quantity IS SUPPLIED
          AND iv_minimum_split_quantity < 0 ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT it_candidates INTO DATA(ls_candidate)
        WHERE request_index = iv_request_index.
      IF ls_candidate-is_quota_assigned <> abap_true
          AND ls_candidate-is_quota_assigned <> abap_false.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      IF ls_candidate-is_quota_assigned = abap_false.
        CONTINUE.
      ENDIF.
      IF ls_candidate-material IS INITIAL
          OR ls_candidate-plant IS INITIAL
          OR ls_candidate-purchasing_org IS INITIAL
          OR ls_candidate-delivery_date IS INITIAL
          OR ls_candidate-source_category <> c_standard_source_category
          OR ls_candidate-vendor IS INITIAL
          OR ls_candidate-quota_number IS INITIAL
          OR ls_candidate-quota_item IS INITIAL
          OR ls_candidate-quota_value <= 0
          OR ls_candidate-quota_allocated_quantity < 0
          OR ls_candidate-quota_maximum_quantity < 0
          OR ls_candidate-quota_min_split_quantity < 0
          OR ls_candidate-candidate_rank <= 0
          OR ls_candidate-base_unit IS INITIAL
          OR ls_candidate-base_unit <> iv_requested_unit.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      IF lv_has_context = abap_false.
        lv_material = ls_candidate-material.
        lv_plant = ls_candidate-plant.
        lv_purchasing_org = ls_candidate-purchasing_org.
        lv_delivery_date = ls_candidate-delivery_date.
        lv_quota_number = ls_candidate-quota_number.
        lv_base_unit = ls_candidate-base_unit.
        lv_header_min_split_qty = ls_candidate-quota_min_split_quantity.
        IF iv_minimum_split_quantity IS SUPPLIED.
          lv_minimum_split_quantity = iv_minimum_split_quantity.
        ELSE.
          lv_minimum_split_quantity = CONV decfloat34(
            ls_candidate-quota_min_split_quantity ).
        ENDIF.
        lv_has_context = abap_true.
      ELSEIF lv_material <> ls_candidate-material
          OR lv_plant <> ls_candidate-plant
          OR lv_purchasing_org <> ls_candidate-purchasing_org
          OR lv_delivery_date <> ls_candidate-delivery_date
          OR lv_quota_number <> ls_candidate-quota_number
          OR lv_base_unit <> ls_candidate-base_unit
          OR lv_header_min_split_qty <>
            ls_candidate-quota_min_split_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      READ TABLE lt_unique_candidates ASSIGNING
        FIELD-SYMBOL(<ls_split_candidate>)
        WITH TABLE KEY quota_number = ls_candidate-quota_number
                       quota_item = ls_candidate-quota_item.
      IF sy-subrc = 0.
        IF <ls_split_candidate>-candidate-vendor <> ls_candidate-vendor
            OR <ls_split_candidate>-quota_value <> ls_candidate-quota_value
            OR <ls_split_candidate>-quota_priority <>
              ls_candidate-quota_priority
            OR <ls_split_candidate>-candidate-quota_rounding_profile <>
              ls_candidate-quota_rounding_profile
            OR <ls_split_candidate>-candidate-quota_allocated_quantity <>
              ls_candidate-quota_allocated_quantity
            OR <ls_split_candidate>-candidate-quota_maximum_quantity <>
              ls_candidate-quota_maximum_quantity.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        IF ls_candidate-candidate_rank <
            <ls_split_candidate>-candidate_rank.
          <ls_split_candidate>-candidate_rank =
            ls_candidate-candidate_rank.
          <ls_split_candidate>-candidate = ls_candidate.
        ENDIF.
      ELSE.
        INSERT VALUE #(
          quota_number   = ls_candidate-quota_number
          quota_item     = ls_candidate-quota_item
          quota_value    = ls_candidate-quota_value
          priority_group = COND i(
            WHEN ls_candidate-quota_priority IS INITIAL THEN 1
            ELSE 0 )
          quota_priority = ls_candidate-quota_priority
          candidate_rank = ls_candidate-candidate_rank
          candidate      = ls_candidate )
          INTO TABLE lt_unique_candidates.
      ENDIF.
    ENDLOOP.

    IF lt_unique_candidates IS INITIAL.
      RETURN.
    ENDIF.

    LOOP AT lt_unique_candidates INTO DATA(ls_unique_candidate).
      IF ls_unique_candidate-candidate-quota_maximum_quantity > 0
          AND ls_unique_candidate-candidate-quota_allocated_quantity >=
            ls_unique_candidate-candidate-quota_maximum_quantity.
        CONTINUE.
      ENDIF.
      APPEND ls_unique_candidate TO lt_split_candidates.
      lv_total_quota = lv_total_quota
        + CONV decfloat34( ls_unique_candidate-quota_value ).
    ENDLOOP.
    IF lt_split_candidates IS INITIAL.
      RETURN.
    ENDIF.
    IF lv_total_quota <= 0.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT lt_split_candidates INTO DATA(ls_profile_candidate).
      IF ls_profile_candidate-candidate-quota_rounding_profile IS INITIAL.
        CONTINUE.
      ENDIF.
      APPEND VALUE #(
        plant            = ls_profile_candidate-candidate-plant
        rounding_profile =
          ls_profile_candidate-candidate-quota_rounding_profile )
        TO lt_rounding_profile_keys.
    ENDLOOP.
    SORT lt_rounding_profile_keys BY plant rounding_profile.
    DELETE ADJACENT DUPLICATES FROM lt_rounding_profile_keys
      COMPARING plant rounding_profile.
    IF lt_rounding_profile_keys IS NOT INITIAL.
      lt_rounding_profiles =
        mo_repository->get_quota_roundings_bulk(
          it_profile_keys = lt_rounding_profile_keys ).
    ENDIF.

    lv_remaining_request = iv_requested_quantity.
    SORT lt_split_candidates BY priority_group ASCENDING
      quota_priority ASCENDING
      quota_value DESCENDING
      quota_item ASCENDING.
    DO.
      CLEAR rt_splits.
      lv_remaining_quantity = lv_remaining_request.

      IF lv_remaining_quantity < lv_minimum_split_quantity
          OR lines( lt_split_candidates ) = 1.
        SORT lt_split_candidates BY candidate_rank ASCENDING
          quota_item ASCENDING.
        LOOP AT lt_split_candidates INTO DATA(ls_ranked_split_candidate).
          lv_minimum_lot_size = CONV decfloat34(
            ls_ranked_split_candidate-candidate-quota_min_lot_size ).
          lv_maximum_lot_size = CONV decfloat34(
            ls_ranked_split_candidate-candidate-quota_max_lot_size ).
          lv_proposal_quantity = lv_minimum_lot_size.
          IF lv_proposal_quantity < lv_remaining_quantity.
            lv_proposal_quantity = lv_remaining_quantity.
          ENDIF.
          IF lv_maximum_lot_size > 0
              AND lv_proposal_quantity > lv_maximum_lot_size.
            IF lv_minimum_lot_size > lv_maximum_lot_size.
              RAISE EXCEPTION TYPE zcx_invalid_stock_request.
            ENDIF.
            lv_proposal_quantity = lv_maximum_lot_size.
          ENDIF.
          lv_proposal_quantity = round_quota_proposal(
            iv_plant          =
              ls_ranked_split_candidate-candidate-plant
            iv_profile        =
              ls_ranked_split_candidate-candidate-quota_rounding_profile
            iv_quantity       = lv_proposal_quantity
            it_profile_values = lt_rounding_profiles ).
          IF ls_ranked_split_candidate-candidate-quota_maximum_quantity > 0
              AND CONV decfloat34(
                ls_ranked_split_candidate-candidate-quota_allocated_quantity )
                + lv_proposal_quantity >= CONV decfloat34(
                  ls_ranked_split_candidate-candidate-quota_maximum_quantity ).
            CONTINUE.
          ENDIF.
          APPEND VALUE #(
            split_sequence     = 1
            allocated_quantity = lv_remaining_quantity
            candidate          = ls_ranked_split_candidate-candidate )
            TO rt_splits.
          EXIT.
        ENDLOOP.
      ELSE.
        CLEAR lv_remaining_quota.
        LOOP AT lt_split_candidates INTO DATA(ls_quota_sum_candidate).
          lv_remaining_quota = lv_remaining_quota
            + CONV decfloat34( ls_quota_sum_candidate-quota_value ).
        ENDLOOP.
        IF lv_remaining_quota <= 0.
          IF lt_fixed_splits IS NOT INITIAL.
            RAISE EXCEPTION TYPE zcx_invalid_stock_request.
          ENDIF.
          RETURN.
        ENDIF.

        LOOP AT lt_split_candidates INTO DATA(ls_split_candidate).
          IF lv_remaining_quantity <= 0.
            EXIT.
          ENDIF.
          IF sy-tabix = lines( lt_split_candidates ).
            APPEND VALUE #(
              split_sequence     = sy-tabix
              allocated_quantity = lv_remaining_quantity
              candidate          = ls_split_candidate-candidate )
              TO rt_splits.
            EXIT.
          ENDIF.

          lv_split_quantity = lv_remaining_quantity
            * CONV decfloat34( ls_split_candidate-quota_value )
            / lv_remaining_quota.
          lv_remaining_quantity = lv_remaining_quantity
            - lv_split_quantity.
          lv_remaining_quota = lv_remaining_quota
            - CONV decfloat34( ls_split_candidate-quota_value ).
          APPEND VALUE #(
            split_sequence     = sy-tabix
            allocated_quantity = lv_split_quantity
            candidate          = ls_split_candidate-candidate )
            TO rt_splits.

          IF lv_remaining_quantity > 0
              AND lv_remaining_quantity < lv_minimum_split_quantity.
            READ TABLE lt_split_candidates INTO DATA(ls_remainder_candidate)
              INDEX sy-tabix + 1.
            IF sy-subrc <> 0.
              RAISE EXCEPTION TYPE zcx_invalid_stock_request.
            ENDIF.
            APPEND VALUE #(
              split_sequence     = sy-tabix + 1
              allocated_quantity = lv_remaining_quantity
              candidate          = ls_remainder_candidate-candidate )
              TO rt_splits.
            EXIT.
          ENDIF.
        ENDLOOP.
      ENDIF.

      CLEAR lv_has_capped_source.
      LOOP AT rt_splits INTO DATA(ls_proposed_split).
        READ TABLE lt_split_candidates ASSIGNING
          FIELD-SYMBOL(<ls_proposed_source>)
          WITH KEY quota_number = ls_proposed_split-candidate-quota_number
                   quota_item = ls_proposed_split-candidate-quota_item.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        lv_minimum_lot_size = CONV decfloat34(
          <ls_proposed_source>-candidate-quota_min_lot_size ).
        lv_maximum_lot_size = CONV decfloat34(
          <ls_proposed_source>-candidate-quota_max_lot_size ).
        lv_proposal_quantity = lv_minimum_lot_size.
        IF lv_proposal_quantity < ls_proposed_split-allocated_quantity.
          lv_proposal_quantity = ls_proposed_split-allocated_quantity.
        ENDIF.
        IF lv_maximum_lot_size > 0
            AND lv_proposal_quantity > lv_maximum_lot_size.
          IF lv_minimum_lot_size > lv_maximum_lot_size.
            RAISE EXCEPTION TYPE zcx_invalid_stock_request.
          ENDIF.
          lv_proposal_quantity = lv_maximum_lot_size.
        ENDIF.
        lv_proposal_quantity = round_quota_proposal(
          iv_plant          = <ls_proposed_source>-candidate-plant
          iv_profile        =
            <ls_proposed_source>-candidate-quota_rounding_profile
          iv_quantity       = lv_proposal_quantity
          it_profile_values = lt_rounding_profiles ).
        IF <ls_proposed_source>-candidate-quota_maximum_quantity > 0
            AND CONV decfloat34(
              <ls_proposed_source>-candidate-quota_allocated_quantity )
              + lv_proposal_quantity >= CONV decfloat34(
                <ls_proposed_source>-candidate-quota_maximum_quantity ).
          <ls_proposed_source>-is_capped = abap_true.
          lv_has_capped_source = abap_true.
        ENDIF.
      ENDLOOP.
      IF lv_has_capped_source = abap_true.
        DELETE lt_split_candidates WHERE is_capped = abap_true.
        IF lt_split_candidates IS INITIAL.
          IF lt_fixed_splits IS NOT INITIAL.
            RAISE EXCEPTION TYPE zcx_invalid_stock_request.
          ENDIF.
          RETURN.
        ENDIF.
        CONTINUE.
      ENDIF.

      CLEAR lv_has_once_capped.
      LOOP AT rt_splits INTO ls_proposed_split.
        READ TABLE lt_split_candidates ASSIGNING <ls_proposed_source>
          WITH KEY quota_number = ls_proposed_split-candidate-quota_number
                   quota_item = ls_proposed_split-candidate-quota_item.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        lv_minimum_lot_size = CONV decfloat34(
          <ls_proposed_source>-candidate-quota_min_lot_size ).
        lv_maximum_lot_size = CONV decfloat34(
          <ls_proposed_source>-candidate-quota_max_lot_size ).
        lv_proposal_quantity = lv_minimum_lot_size.
        IF lv_proposal_quantity < ls_proposed_split-allocated_quantity.
          lv_proposal_quantity = ls_proposed_split-allocated_quantity.
        ENDIF.
        IF <ls_proposed_source>-candidate-quota_once_only = abap_true
            AND lv_maximum_lot_size > 0
            AND lv_proposal_quantity > lv_maximum_lot_size.
          IF lv_minimum_lot_size > lv_maximum_lot_size.
            RAISE EXCEPTION TYPE zcx_invalid_stock_request.
          ENDIF.
          APPEND VALUE #(
            split_sequence     = lines( lt_fixed_splits ) + 1
            allocated_quantity = lv_maximum_lot_size
            proposal_quantity  = lv_maximum_lot_size
            candidate          = <ls_proposed_source>-candidate )
            TO lt_fixed_splits.
          lv_remaining_request = lv_remaining_request
            - lv_maximum_lot_size.
          DELETE lt_split_candidates
            WHERE quota_number = ls_proposed_split-candidate-quota_number
              AND quota_item = ls_proposed_split-candidate-quota_item.
          lv_has_once_capped = abap_true.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF lv_has_once_capped = abap_true.
        IF lv_remaining_request <= 0.
          rt_splits = apply_quota_item_lot_sizes(
            it_splits            = lt_fixed_splits
            it_rounding_profiles = lt_rounding_profiles ).
          RETURN.
        ENDIF.
        IF lt_split_candidates IS INITIAL.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        CONTINUE.
      ENDIF.

      CLEAR lv_has_max_lot_capped.
      LOOP AT rt_splits INTO ls_proposed_split.
        READ TABLE lt_split_candidates ASSIGNING <ls_proposed_source>
          WITH KEY quota_number = ls_proposed_split-candidate-quota_number
                   quota_item = ls_proposed_split-candidate-quota_item.
        IF sy-subrc <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        IF <ls_proposed_source>-candidate-quota_once_only = abap_true.
          CONTINUE.
        ENDIF.
        lv_minimum_lot_size = CONV decfloat34(
          <ls_proposed_source>-candidate-quota_min_lot_size ).
        lv_maximum_lot_size = CONV decfloat34(
          <ls_proposed_source>-candidate-quota_max_lot_size ).
        lv_proposal_quantity = lv_minimum_lot_size.
        IF lv_proposal_quantity < ls_proposed_split-allocated_quantity.
          lv_proposal_quantity = ls_proposed_split-allocated_quantity.
        ENDIF.
        IF lv_maximum_lot_size > 0
            AND lv_proposal_quantity > lv_maximum_lot_size.
          IF lv_minimum_lot_size > lv_maximum_lot_size.
            RAISE EXCEPTION TYPE zcx_invalid_stock_request.
          ENDIF.
          APPEND VALUE #(
            split_sequence     = lines( lt_fixed_splits ) + 1
            allocated_quantity = lv_maximum_lot_size
            proposal_quantity  = lv_maximum_lot_size
            candidate          = <ls_proposed_source>-candidate )
            TO lt_fixed_splits.
          lv_remaining_request = lv_remaining_request
            - lv_maximum_lot_size.
          <ls_proposed_source>-candidate-quota_allocated_quantity =
            <ls_proposed_source>-candidate-quota_allocated_quantity
              + lv_maximum_lot_size.
          lv_has_max_lot_capped = abap_true.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF lv_has_max_lot_capped = abap_true.
        IF lv_remaining_request <= 0.
          rt_splits = apply_quota_item_lot_sizes(
            it_splits            = lt_fixed_splits
            it_rounding_profiles = lt_rounding_profiles ).
          RETURN.
        ENDIF.
        CONTINUE.
      ENDIF.
      EXIT.
    ENDDO.

    IF lt_fixed_splits IS NOT INITIAL.
      APPEND LINES OF lt_fixed_splits TO lt_final_splits.
      APPEND LINES OF rt_splits TO lt_final_splits.
      rt_splits = lt_final_splits.
      DATA lv_total_allocated TYPE decfloat34.
      LOOP AT rt_splits INTO DATA(ls_final_split).
        lv_total_allocated = lv_total_allocated
          + ls_final_split-allocated_quantity.
      ENDLOOP.
      IF lv_total_allocated <> iv_requested_quantity.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDIF.

    rt_splits = apply_quota_item_lot_sizes(
      it_splits            = rt_splits
      it_rounding_profiles = lt_rounding_profiles ).
  ENDMETHOD.

  METHOD apply_quota_item_lot_sizes.
    DATA lv_minimum_lot_size TYPE decfloat34.
    DATA lv_maximum_lot_size TYPE decfloat34.
    DATA lv_remaining_quantity TYPE decfloat34.
    DATA lv_allocated_quantity TYPE decfloat34.
    DATA lv_proposal_quantity TYPE decfloat34.
    DATA lv_lot_quantity TYPE decfloat34.

    LOOP AT it_splits INTO DATA(ls_split).
      IF ls_split-candidate-quota_once_only <> abap_true
          AND ls_split-candidate-quota_once_only <> abap_false.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      lv_minimum_lot_size = CONV decfloat34(
        ls_split-candidate-quota_min_lot_size ).
      lv_maximum_lot_size = CONV decfloat34(
        ls_split-candidate-quota_max_lot_size ).
      lv_remaining_quantity = ls_split-allocated_quantity.
      IF lv_minimum_lot_size < 0 OR lv_maximum_lot_size < 0
          OR ( lv_minimum_lot_size > 0
            AND lv_maximum_lot_size > 0
            AND lv_minimum_lot_size > lv_maximum_lot_size ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      IF ls_split-candidate-quota_once_only = abap_true
          AND lv_maximum_lot_size > 0
          AND lv_remaining_quantity > lv_maximum_lot_size.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      WHILE lv_remaining_quantity > 0.
        lv_lot_quantity = lv_remaining_quantity.
        IF lv_maximum_lot_size > 0
            AND lv_lot_quantity > lv_maximum_lot_size.
          lv_lot_quantity = lv_maximum_lot_size.
        ENDIF.
        lv_allocated_quantity = lv_lot_quantity.
        lv_proposal_quantity = lv_lot_quantity.
        IF lv_minimum_lot_size > lv_proposal_quantity.
          lv_proposal_quantity = lv_minimum_lot_size.
        ENDIF.
        lv_proposal_quantity = round_quota_proposal(
          iv_plant          = ls_split-candidate-plant
          iv_profile        =
            ls_split-candidate-quota_rounding_profile
          iv_quantity       = lv_proposal_quantity
          it_profile_values = it_rounding_profiles ).
        IF lv_maximum_lot_size > 0
            AND lv_proposal_quantity > lv_maximum_lot_size.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.

        APPEND VALUE #(
          split_sequence     = lines( rt_splits ) + 1
          allocated_quantity = lv_allocated_quantity
          proposal_quantity  = lv_proposal_quantity
          candidate          = ls_split-candidate )
          TO rt_splits.
        lv_remaining_quantity = lv_remaining_quantity
          - lv_lot_quantity.
      ENDWHILE.
    ENDLOOP.
  ENDMETHOD.

  METHOD round_quota_proposal.
    DATA lt_profile_levels TYPE ty_quota_rounding_profiles.
    DATA lv_remaining_quantity TYPE decfloat34.
    DATA lv_rounded_quantity TYPE decfloat34.
    DATA lv_threshold_quantity TYPE decfloat34.
    DATA lv_rounding_quantity TYPE decfloat34.
    DATA lv_whole_quantity TYPE decfloat34.
    DATA lv_remainder_quantity TYPE decfloat34.
    DATA lv_level_quantity TYPE decfloat34.
    DATA lv_previous_threshold TYPE decfloat34.
    DATA lv_previous_level TYPE rdpr-rdzae.

    rv_quantity = iv_quantity.
    IF iv_profile IS INITIAL OR iv_quantity <= 0.
      RETURN.
    ENDIF.

    LOOP AT it_profile_values INTO DATA(ls_profile_line)
        WHERE plant = iv_plant
          AND rounding_profile = iv_profile.
      APPEND ls_profile_line TO lt_profile_levels.
    ENDLOOP.
    IF lt_profile_levels IS INITIAL.
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    SORT lt_profile_levels BY level_number DESCENDING.
    LOOP AT lt_profile_levels INTO ls_profile_line.
      lv_threshold_quantity = CONV decfloat34(
        ls_profile_line-threshold_quantity ).
      lv_rounding_quantity = CONV decfloat34(
        ls_profile_line-rounding_quantity ).
      IF ls_profile_line-level_number IS INITIAL
          OR lv_threshold_quantity < 0
          OR lv_rounding_quantity <= 0
          OR ( lv_previous_level IS NOT INITIAL
            AND ls_profile_line-level_number >= lv_previous_level )
          OR ( lv_previous_level IS NOT INITIAL
            AND lv_threshold_quantity > lv_previous_threshold ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      lv_previous_level = ls_profile_line-level_number.
      lv_previous_threshold = lv_threshold_quantity.
    ENDLOOP.

    lv_remaining_quantity = iv_quantity.
    LOOP AT lt_profile_levels INTO ls_profile_line.
      lv_threshold_quantity = CONV decfloat34(
        ls_profile_line-threshold_quantity ).
      lv_rounding_quantity = CONV decfloat34(
        ls_profile_line-rounding_quantity ).
      IF sy-tabix = lines( lt_profile_levels ).
        IF lv_remaining_quantity >= lv_threshold_quantity.
          lv_level_quantity = CONV decfloat34(
            floor( lv_remaining_quantity / lv_rounding_quantity ) )
              * lv_rounding_quantity.
          IF lv_level_quantity < lv_remaining_quantity.
            lv_level_quantity = lv_level_quantity + lv_rounding_quantity.
          ENDIF.
          lv_rounded_quantity = lv_rounded_quantity + lv_level_quantity.
        ELSE.
          lv_rounded_quantity = lv_rounded_quantity
            + lv_remaining_quantity.
        ENDIF.
        EXIT.
      ENDIF.

      lv_whole_quantity = CONV decfloat34(
        floor( lv_remaining_quantity / lv_rounding_quantity ) )
          * lv_rounding_quantity.
      lv_remainder_quantity = lv_remaining_quantity - lv_whole_quantity.
      lv_rounded_quantity = lv_rounded_quantity + lv_whole_quantity.
      IF lv_remainder_quantity > 0
          AND lv_remainder_quantity >= lv_threshold_quantity.
        lv_rounded_quantity = lv_rounded_quantity
          + lv_rounding_quantity.
        EXIT.
      ENDIF.
      lv_remaining_quantity = lv_remainder_quantity.
    ENDLOOP.

    rv_quantity = lv_rounded_quantity.
  ENDMETHOD.

  METHOD get_valid_outline_sources.
    DATA lt_agreements TYPE zif_repl_source_repo=>ty_outline_agreements.
    DATA lt_source_contexts TYPE zif_repl_source_repo=>ty_source_contexts.
    DATA lv_vendor_blocked TYPE abap_bool.
    DATA lv_candidate_rank TYPE i.
    DATA lv_ranked_request_index TYPE i.
    FIELD-SYMBOLS <ls_outline_candidate> TYPE ty_outline_source_candidate.

    IF ( iv_require_fixed_source <> abap_true
        AND iv_require_fixed_source <> abap_false )
        OR ( iv_require_mrp_relevant <> abap_true
          AND iv_require_mrp_relevant <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    LOOP AT it_requests INTO DATA(ls_request).
      IF ls_request-material IS INITIAL
          OR ls_request-plant IS INITIAL
          OR ls_request-purchasing_org IS INITIAL
          OR ls_request-delivery_date IS INITIAL
          OR ls_request-requested_quantity < 0
          OR ( ls_request-requested_quantity IS INITIAL
            AND ls_request-requested_quantity_unit IS NOT INITIAL )
          OR ( ls_request-requested_quantity > 0
            AND ls_request-requested_quantity_unit IS INITIAL ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.
    IF it_requests IS INITIAL.
      RETURN.
    ENDIF.

    lt_source_contexts = mo_repository->get_source_contexts_bulk(
      it_requests = it_requests ).
    lt_agreements = mo_repository->get_outline_agreements_bulk(
      it_requests = it_requests ).

    LOOP AT it_requests INTO ls_request.
      DATA(lv_request_index) = sy-tabix.
      DATA(lv_material_plant_found) = abap_false.
      DATA(lv_source_list_required) = abap_false.
      LOOP AT lt_source_contexts INTO DATA(ls_context)
        WHERE material = ls_request-material
          AND plant = ls_request-plant.
        lv_material_plant_found = abap_true.
        IF ls_context-source_list_required IS NOT INITIAL.
          lv_source_list_required = abap_true.
        ENDIF.
      ENDLOOP.
      IF lv_material_plant_found = abap_false.
        CONTINUE.
      ENDIF.

      LOOP AT lt_agreements INTO DATA(ls_agreement)
        WHERE material = ls_request-material
          AND plant = ls_request-plant
          AND purchasing_org = ls_request-purchasing_org.
        IF ls_agreement-vendor IS INITIAL
            OR ( ls_agreement-document_category <> 'K'
              AND ls_agreement-document_category <> 'L' )
            OR ls_agreement-source_list_blocked IS NOT INITIAL
            OR ls_agreement-header_deletion_indicator IS NOT INITIAL
            OR ls_agreement-item_deletion_indicator IS NOT INITIAL
            OR ls_agreement-item_delivery_complete IS NOT INITIAL
            OR ( iv_require_fixed_source = abap_true
              AND ls_agreement-source_list_fixed IS INITIAL )
            OR ( iv_require_mrp_relevant = abap_true
              AND ls_agreement-source_list_mrp_usage IS INITIAL )
            OR ( ls_agreement-source_list_vendor IS NOT INITIAL
              AND ls_agreement-source_list_vendor
                <> ls_agreement-vendor )
            OR ( ls_agreement-source_list_purchasing_org IS NOT INITIAL
              AND ls_agreement-source_list_purchasing_org
                <> ls_request-purchasing_org )
            OR ( ls_agreement-source_list_valid_from IS NOT INITIAL
              AND ls_agreement-source_list_valid_from
                > ls_request-delivery_date )
            OR ( ls_agreement-source_list_valid_to IS NOT INITIAL
              AND ls_agreement-source_list_valid_to
                < ls_request-delivery_date )
            OR ( ls_agreement-agreement_valid_from IS NOT INITIAL
              AND ls_agreement-agreement_valid_from
                > ls_request-delivery_date )
            OR ( ls_agreement-agreement_valid_to IS NOT INITIAL
              AND ls_agreement-agreement_valid_to
                < ls_request-delivery_date ).
          CONTINUE.
        ENDIF.

        CLEAR lv_vendor_blocked.
        LOOP AT lt_source_contexts INTO DATA(ls_block_context)
          WHERE material = ls_request-material
            AND plant = ls_request-plant.
          IF ls_block_context-source_list_blocked IS INITIAL
              OR ls_block_context-source_list_agreement IS NOT INITIAL
              OR ls_block_context-source_list_agreement_item IS NOT INITIAL
              OR ( ls_block_context-source_list_vendor IS NOT INITIAL
                AND ls_block_context-source_list_vendor
                  <> ls_agreement-vendor )
              OR ( ls_block_context-source_list_purchasing_org IS NOT INITIAL
                AND ls_block_context-source_list_purchasing_org
                  <> ls_request-purchasing_org )
              OR ( ls_block_context-source_list_valid_from IS NOT INITIAL
                AND ls_block_context-source_list_valid_from
                  > ls_request-delivery_date )
              OR ( ls_block_context-source_list_valid_to IS NOT INITIAL
                AND ls_block_context-source_list_valid_to
                  < ls_request-delivery_date ).
            CONTINUE.
          ENDIF.
          lv_vendor_blocked = abap_true.
          EXIT.
        ENDLOOP.
        IF lv_vendor_blocked = abap_true.
          CONTINUE.
        ENDIF.

        APPEND VALUE #(
          request_index          = lv_request_index
          material               = ls_request-material
          plant                  = ls_request-plant
          purchasing_org         = ls_request-purchasing_org
          delivery_date          = ls_request-delivery_date
          vendor                 = ls_agreement-vendor
          purchasing_document    = ls_agreement-purchasing_document
          purchasing_item        = ls_agreement-purchasing_item
          document_category      = ls_agreement-document_category
          agreement_valid_from   = ls_agreement-agreement_valid_from
          agreement_valid_to     = ls_agreement-agreement_valid_to
          source_list_record     = ls_agreement-source_list_record
          source_list_valid_from = ls_agreement-source_list_valid_from
          source_list_valid_to   = ls_agreement-source_list_valid_to
          source_list_required   = lv_source_list_required
          is_fixed_source        = COND #(
            WHEN ls_agreement-source_list_fixed IS NOT INITIAL
            THEN abap_true
            ELSE abap_false )
          is_mrp_relevant        = COND #(
            WHEN ls_agreement-source_list_mrp_usage IS NOT INITIAL
            THEN abap_true
            ELSE abap_false )
          is_preferred_vendor    = COND #(
            WHEN ls_agreement-vendor = ls_request-preferred_vendor
              AND ls_request-preferred_vendor IS NOT INITIAL
            THEN abap_true
            ELSE abap_false ) ) TO rt_candidates.
      ENDLOOP.
    ENDLOOP.

    SORT rt_candidates BY request_index ASCENDING
      is_fixed_source DESCENDING is_preferred_vendor DESCENDING
      document_category vendor purchasing_document purchasing_item
      source_list_record.
    CLEAR: lv_candidate_rank, lv_ranked_request_index.
    LOOP AT rt_candidates ASSIGNING <ls_outline_candidate>.
      IF <ls_outline_candidate>-request_index <> lv_ranked_request_index.
        lv_ranked_request_index = <ls_outline_candidate>-request_index.
        CLEAR lv_candidate_rank.
      ENDIF.
      ADD 1 TO lv_candidate_rank.
      <ls_outline_candidate>-candidate_rank = lv_candidate_rank.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_quota_match.
    LOOP AT it_arrangements INTO DATA(ls_arrangement)
      WHERE material = iv_material
        AND plant = iv_plant
        AND procurement_type = 'F'
        AND special_procurement_type = space.
      IF ( ls_arrangement-quota_valid_from IS NOT INITIAL
            AND ls_arrangement-quota_valid_from > iv_delivery_date )
          OR ( ls_arrangement-quota_valid_to IS NOT INITIAL
            AND ls_arrangement-quota_valid_to < iv_delivery_date ).
        CONTINUE.
      ENDIF.

      rs_match-has_active_arrangement = abap_true.
      IF ls_arrangement-vendor <> iv_vendor
          OR ls_arrangement-quota <= 0.
        CONTINUE.
      ENDIF.

      DATA(lv_allocated_quantity) = CONV decfloat34(
        ls_arrangement-quota_allocated_quantity ).
      READ TABLE it_prior_allocations INTO DATA(ls_prior_allocation)
        WITH TABLE KEY material = ls_arrangement-material
                       plant = ls_arrangement-plant
                       quota_number = ls_arrangement-quota_number
                       quota_item = ls_arrangement-quota_item.
      IF sy-subrc = 0.
        lv_allocated_quantity = lv_allocated_quantity
          + ls_prior_allocation-quantity.
      ENDIF.
      DATA(lv_rating) = CONV decfloat34(
        lv_allocated_quantity
          + CONV decfloat34( ls_arrangement-quota_base_quantity ) )
        / CONV decfloat34( ls_arrangement-quota ).
      DATA(lv_better_match) = abap_false.
      IF rs_match-is_assigned = abap_false
          OR lv_rating < rs_match-rating.
        lv_better_match = abap_true.
      ELSEIF lv_rating = rs_match-rating.
        IF ls_arrangement-quota_item < rs_match-quota_item.
          lv_better_match = abap_true.
        ENDIF.
      ENDIF.
      IF lv_better_match = abap_false.
        CONTINUE.
      ENDIF.

      rs_match-is_assigned = abap_true.
      rs_match-quota_number = ls_arrangement-quota_number.
      rs_match-quota_item = ls_arrangement-quota_item.
      rs_match-quota_priority = ls_arrangement-quota_priority.
      rs_match-quota_min_lot_size =
        ls_arrangement-quota_minimum_lot_size.
      rs_match-quota_max_lot_size =
        ls_arrangement-quota_maximum_lot_size.
      rs_match-quota_rounding_profile =
        ls_arrangement-quota_rounding_profile.
      rs_match-source_assigned_once =
        ls_arrangement-source_assigned_once.
      rs_match-quota_value = ls_arrangement-quota.
      rs_match-minimum_split_quantity =
        ls_arrangement-minimum_split_quantity.
      rs_match-quota_base_quantity =
        ls_arrangement-quota_base_quantity.
      rs_match-quota_allocated_quantity =
        ls_arrangement-quota_allocated_quantity.
      rs_match-quota_maximum_quantity =
        ls_arrangement-quota_maximum_quantity.
      rs_match-rating = lv_rating.
      rs_match-allocated_quantity_before = lv_allocated_quantity.
    ENDLOOP.
  ENDMETHOD.

  METHOD evaluate_quantity_limits.
    rs_evaluation-status = c_quantity_limit_not_requested.
    rs_evaluation-purchase_order_unit = iv_purchase_unit.
    rs_evaluation-base_unit = iv_base_unit.

    IF iv_minimum_quantity < 0 OR iv_maximum_quantity < 0
        OR ( iv_minimum_quantity > 0
          AND iv_maximum_quantity > 0
          AND iv_minimum_quantity > iv_maximum_quantity ).
      rs_evaluation-status = c_quantity_limit_invalid_range.
      RETURN.
    ENDIF.

    IF iv_requested_quantity > 0
        AND ( iv_base_unit IS INITIAL
          OR iv_requested_unit <> iv_base_unit ).
      rs_evaluation-status = c_quantity_limit_unit_mismatch.
      RETURN.
    ENDIF.

    DATA(lv_conversion_factor) = CONV decfloat34( 1 ).
    IF iv_minimum_quantity > 0 OR iv_maximum_quantity > 0.
      IF iv_purchase_unit IS INITIAL OR iv_base_unit IS INITIAL.
        IF iv_requested_quantity > 0.
          rs_evaluation-status = c_quantity_limit_no_conversion.
        ENDIF.
        RETURN.
      ENDIF.
      IF iv_purchase_unit <> iv_base_unit.
        IF iv_conversion_num <= 0 OR iv_conversion_den <= 0.
          IF iv_requested_quantity > 0.
            rs_evaluation-status = c_quantity_limit_no_conversion.
          ENDIF.
          RETURN.
        ENDIF.
        lv_conversion_factor = CONV decfloat34( iv_conversion_num )
          / CONV decfloat34( iv_conversion_den ).
      ENDIF.
    ENDIF.

    IF iv_minimum_quantity > 0.
      rs_evaluation-minimum_order_quantity_base =
        CONV decfloat34( iv_minimum_quantity ) * lv_conversion_factor.
    ENDIF.
    IF iv_maximum_quantity > 0.
      rs_evaluation-maximum_order_quantity_base =
        CONV decfloat34( iv_maximum_quantity ) * lv_conversion_factor.
    ENDIF.

    IF iv_requested_quantity IS INITIAL.
      RETURN.
    ENDIF.

    IF iv_minimum_quantity > 0
        AND iv_requested_quantity <
          rs_evaluation-minimum_order_quantity_base.
      rs_evaluation-status = c_quantity_limit_below_minimum.
      RETURN.
    ENDIF.

    IF iv_maximum_quantity > 0
        AND iv_requested_quantity >
          rs_evaluation-maximum_order_quantity_base.
      rs_evaluation-status = c_quantity_limit_above_maximum.
      RETURN.
    ENDIF.

    rs_evaluation-status = c_quantity_limit_within_range.
  ENDMETHOD.

ENDCLASS.
