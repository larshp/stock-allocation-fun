CLASS zcl_repl_source_service DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS c_standard_source_category TYPE eina-esokz VALUE '0'.

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
      BEGIN OF ty_candidate,
        request_index               TYPE i,
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
        quota_value                 TYPE equp-quote,
        quota_base_quantity         TYPE equp-qubmg,
        quota_allocated_quantity    TYPE equp-qumng,
        quota_rating                TYPE decfloat34,
        source_list_record          TYPE eord-zeord,
        source_list_valid_from      TYPE eord-vdatu,
        source_list_valid_to        TYPE eord-bdatu,
        is_preferred_vendor         TYPE abap_bool,
        is_plant_specific           TYPE abap_bool,
      END OF ty_candidate.
    TYPES ty_candidates TYPE STANDARD TABLE OF ty_candidate
      WITH EMPTY KEY.

    METHODS constructor
      IMPORTING
        io_repository TYPE REF TO zif_repl_source_repo.

    METHODS get_valid_pir_candidates
      IMPORTING
        it_requests          TYPE ty_requests
      RETURNING
        VALUE(rt_candidates) TYPE ty_candidates
      RAISING
        zcx_invalid_stock_request.

  PRIVATE SECTION.
    TYPES ty_quota_arrangements TYPE
      zif_repl_source_repo=>ty_quota_arrangements.
    TYPES ty_quota_usage_rules TYPE
      zif_repl_source_repo=>ty_quota_usage_rules.
    TYPES:
      BEGIN OF ty_quota_match,
        has_active_arrangement   TYPE abap_bool,
        is_assigned              TYPE abap_bool,
        quota_number             TYPE equk-qunum,
        quota_item               TYPE equp-qupos,
        quota_value              TYPE equp-quote,
        quota_base_quantity      TYPE equp-qubmg,
        quota_allocated_quantity TYPE equp-qumng,
        rating                   TYPE decfloat34,
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
        iv_material      TYPE mara-matnr
        iv_plant         TYPE t001w-werks
        iv_vendor        TYPE eina-lifnr
        iv_delivery_date TYPE d
        it_arrangements  TYPE ty_quota_arrangements
      RETURNING
        VALUE(rs_match)  TYPE ty_quota_match.

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

    LOOP AT it_requests INTO ls_request.
      DATA(lv_request_index) = sy-tabix.
      LOOP AT lt_records INTO DATA(ls_record).
        IF ls_record-material <> ls_request-material
            OR ls_record-purchasing_org <> ls_request-purchasing_org
            OR ( ls_record-record_plant IS NOT INITIAL
              AND ls_record-record_plant <> ls_request-plant )
            OR ls_record-vendor IS INITIAL
            OR ls_record-info_record IS INITIAL
            OR ls_record-source_category <> c_standard_source_category
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
              AND lv_source_listed = abap_false ).
          CONTINUE.
        ENDIF.

        READ TABLE lt_quota_usage_rules INTO ls_quota_usage_rule
          WITH KEY quota_usage = lv_quota_arrangement_usage.

        DATA(ls_quota_match) = get_quota_match(
          iv_material      = ls_request-material
          iv_plant         = ls_request-plant
          iv_vendor        = ls_record-vendor
          iv_delivery_date = ls_request-delivery_date
          it_arrangements  = lt_quota_arrangements ).

        DATA(ls_quantity_evaluation) = evaluate_quantity_limits(
          iv_requested_quantity = ls_request-requested_quantity
          iv_requested_unit     = ls_request-requested_quantity_unit
          iv_minimum_quantity   = ls_record-minimum_order_quantity
          iv_maximum_quantity   = ls_record-maximum_order_quantity
          iv_purchase_unit      = ls_record-purchase_order_unit
          iv_base_unit          = ls_record-base_unit
          iv_conversion_num     = ls_record-order_unit_to_base_numerator
          iv_conversion_den     = ls_record-order_unit_to_base_denominator ).

        DATA(ls_candidate) = VALUE ty_candidate(
          request_index               = lv_request_index
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
          quota_value                 = ls_quota_match-quota_value
          quota_base_quantity         = ls_quota_match-quota_base_quantity
          quota_allocated_quantity    =
            ls_quota_match-quota_allocated_quantity
          quota_rating                = ls_quota_match-rating
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
          has_quota_assignment = ls_quota_match-is_assigned
          quota_rating         = ls_quota_match-rating
          quota_item           = ls_quota_match-quota_item
          is_fixed_source      = lv_fixed_source
          is_preferred_vendor  = ls_candidate-is_preferred_vendor
          is_plant_specific    = ls_candidate-is_plant_specific
          vendor               = ls_record-vendor
          info_record          = ls_record-info_record
          candidate            = ls_candidate ) TO lt_ranked_candidates.
      ENDLOOP.
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

      DATA(lv_rating) = CONV decfloat34(
        CONV decfloat34( ls_arrangement-quota_allocated_quantity )
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
      rs_match-quota_value = ls_arrangement-quota.
      rs_match-quota_base_quantity =
        ls_arrangement-quota_base_quantity.
      rs_match-quota_allocated_quantity =
        ls_arrangement-quota_allocated_quantity.
      rs_match-rating = lv_rating.
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
