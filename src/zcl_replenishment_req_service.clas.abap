CLASS zcl_replenishment_req_service DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_requisition_type TYPE
      zif_purchase_requisition_api=>ty_requisition_type.
    TYPES ty_purchasing_group TYPE
      zif_purchase_requisition_api=>ty_purchasing_group.
    TYPES ty_purchasing_org TYPE
      zif_purchase_requisition_api=>ty_purchasing_org.
    TYPES:
      BEGIN OF ty_suggestion_purchasing_control,
        source_suggestion_index TYPE i,
        purchasing_group        TYPE ty_purchasing_group,
        purchasing_org          TYPE ty_purchasing_org,
      END OF ty_suggestion_purchasing_control.
    TYPES ty_suggestion_purchasing_controls TYPE STANDARD TABLE OF
      ty_suggestion_purchasing_control WITH EMPTY KEY.

    METHODS constructor
      IMPORTING
        io_api TYPE REF TO zif_purchase_requisition_api.

    METHODS create_from_suggestions
      IMPORTING
        it_suggestions         TYPE zcl_prod_comp_service=>ty_comp_replenishments
        iv_requisition_type    TYPE ty_requisition_type DEFAULT 'NB'
        iv_purchasing_group    TYPE ty_purchasing_group OPTIONAL
        iv_purchasing_org      TYPE ty_purchasing_org OPTIONAL
        it_purchasing_controls TYPE ty_suggestion_purchasing_controls
          OPTIONAL
        iv_test_run            TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)       TYPE zif_purchase_requisition_api=>ty_result
      RAISING
        zcx_invalid_stock_request.

    METHODS create_from_selected_sources
      IMPORTING
        it_suggestions             TYPE zcl_prod_comp_service=>ty_comp_replenishments
        it_selected_source_options TYPE zcl_repl_source_service=>ty_suggestion_source_options
        iv_requisition_type        TYPE ty_requisition_type DEFAULT 'NB'
        iv_purchasing_group        TYPE ty_purchasing_group OPTIONAL
        iv_purchasing_org          TYPE ty_purchasing_org OPTIONAL
        it_purchasing_controls     TYPE ty_suggestion_purchasing_controls
          OPTIONAL
        iv_test_run                TYPE abap_bool DEFAULT abap_false
      RETURNING
        VALUE(rs_result)           TYPE zif_purchase_requisition_api=>ty_result
      RAISING
        zcx_invalid_stock_request.

  PRIVATE SECTION.
    METHODS complete_write
      IMPORTING
        is_request       TYPE zif_purchase_requisition_api=>ty_request
        is_result        TYPE zif_purchase_requisition_api=>ty_result
      RETURNING
        VALUE(rs_result) TYPE zif_purchase_requisition_api=>ty_result.

    DATA mo_api TYPE REF TO zif_purchase_requisition_api.
ENDCLASS.

CLASS zcl_replenishment_req_service IMPLEMENTATION.

  METHOD constructor.
    mo_api = io_api.
  ENDMETHOD.

  METHOD create_from_suggestions.
    IF iv_requisition_type IS INITIAL
        OR ( iv_test_run <> abap_true AND iv_test_run <> abap_false ).
      RAISE EXCEPTION TYPE zcx_invalid_stock_request.
    ENDIF.

    DATA ls_request TYPE zif_purchase_requisition_api=>ty_request.
    DATA lv_item_number TYPE n LENGTH 5.
    DATA lv_receipt_count TYPE i.
    DATA lv_receipt_item_quantity TYPE mard-labst.
    DATA lv_suggestion_index TYPE i.
    DATA lv_item_purchasing_group TYPE ty_purchasing_group.
    DATA lv_item_purchasing_org TYPE ty_purchasing_org.
    DATA lt_purchasing_controls TYPE HASHED TABLE OF
      ty_suggestion_purchasing_control
      WITH UNIQUE KEY source_suggestion_index.
    ls_request-requisition_type = iv_requisition_type.
    ls_request-is_test_run = iv_test_run.

    LOOP AT it_purchasing_controls INTO DATA(ls_purchasing_control).
      IF ls_purchasing_control-source_suggestion_index <= 0
          OR ls_purchasing_control-source_suggestion_index
            > lines( it_suggestions )
          OR ( ls_purchasing_control-purchasing_group IS INITIAL
            AND ls_purchasing_control-purchasing_org IS INITIAL ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      READ TABLE it_suggestions
        INDEX ls_purchasing_control-source_suggestion_index
        INTO DATA(ls_control_suggestion).
      IF sy-subrc <> 0
          OR ls_control_suggestion-suggested_base_quantity <= 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      INSERT ls_purchasing_control INTO TABLE lt_purchasing_controls.
      IF sy-subrc <> 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
    ENDLOOP.

    LOOP AT it_suggestions INTO DATA(ls_suggestion).
      lv_suggestion_index = sy-tabix.
      IF ls_suggestion-material IS INITIAL
          OR ls_suggestion-plant IS INITIAL
          OR ls_suggestion-base_unit IS INITIAL
          OR ls_suggestion-required_date IS INITIAL
          OR ls_suggestion-suggested_base_quantity < 0
          OR ls_suggestion-suggested_receipt_count < 0
          OR ls_suggestion-final_receipt_base_quantity < 0
          OR ls_suggestion-maximum_base_quantity < 0
          OR ls_suggestion-fixed_base_quantity < 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      IF ls_suggestion-source_vendor IS NOT INITIAL
          OR ls_suggestion-source_purchasing_org IS NOT INITIAL
          OR ls_suggestion-source_info_record IS NOT INITIAL
          OR ls_suggestion-source_category IS NOT INITIAL
          OR ls_suggestion-source_agreement IS NOT INITIAL
          OR ls_suggestion-source_agreement_item IS NOT INITIAL.
        IF ls_suggestion-source_agreement IS NOT INITIAL
            OR ls_suggestion-source_agreement_item IS NOT INITIAL.
          IF ls_suggestion-source_agreement IS INITIAL
              OR ls_suggestion-source_agreement_item IS INITIAL
              OR ls_suggestion-source_vendor IS INITIAL
              OR ls_suggestion-source_purchasing_org IS INITIAL
              OR ls_suggestion-source_info_record IS NOT INITIAL
              OR ls_suggestion-source_category IS NOT INITIAL.
            RAISE EXCEPTION TYPE zcx_invalid_stock_request.
          ENDIF.
        ELSEIF ls_suggestion-source_vendor IS INITIAL
            OR ls_suggestion-source_purchasing_org IS INITIAL
            OR ls_suggestion-source_info_record IS INITIAL
            OR ls_suggestion-source_category IS INITIAL.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
      ENDIF.
      IF ls_suggestion-suggested_base_quantity = 0.
        IF ls_suggestion-suggested_receipt_count <> 0
            OR ls_suggestion-final_receipt_base_quantity <> 0.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        CONTINUE.
      ENDIF.
      lv_item_purchasing_group = iv_purchasing_group.
      lv_item_purchasing_org = iv_purchasing_org.
      IF ls_suggestion-source_purchasing_org IS NOT INITIAL.
        lv_item_purchasing_org =
          ls_suggestion-source_purchasing_org.
      ENDIF.
      READ TABLE lt_purchasing_controls
        INTO ls_purchasing_control
        WITH TABLE KEY source_suggestion_index = lv_suggestion_index.
      IF sy-subrc = 0.
        IF ls_purchasing_control-purchasing_group IS NOT INITIAL.
          lv_item_purchasing_group =
            ls_purchasing_control-purchasing_group.
        ENDIF.
        IF ls_purchasing_control-purchasing_org IS NOT INITIAL.
          lv_item_purchasing_org = ls_purchasing_control-purchasing_org.
        ENDIF.
      ENDIF.
      IF ls_suggestion-procurement_type <> 'F'
          OR ls_suggestion-special_procurement_key IS NOT INITIAL.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      IF ls_suggestion-suggested_receipt_count <= 0
          OR ls_suggestion-suggested_receipt_count > 9999
          OR ls_suggestion-final_receipt_base_quantity <= 0.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      lv_receipt_count = CONV i(
        ls_suggestion-suggested_receipt_count ).
      IF lv_receipt_count > 9999 - lines( ls_request-items ).
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.
      IF lv_receipt_count = 1.
        IF ls_suggestion-final_receipt_base_quantity
            <> ls_suggestion-suggested_base_quantity.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        lv_receipt_item_quantity =
          ls_suggestion-final_receipt_base_quantity.
      ELSEIF ls_suggestion-fixed_base_quantity > 0.
        IF ls_suggestion-rounding_profile IS INITIAL.
          IF ls_suggestion-final_receipt_base_quantity
                <> ls_suggestion-fixed_base_quantity
              OR ls_suggestion-suggested_base_quantity
                <> ls_suggestion-fixed_base_quantity * lv_receipt_count.
            RAISE EXCEPTION TYPE zcx_invalid_stock_request.
          ENDIF.
        ELSEIF ls_suggestion-suggested_base_quantity
              <> ls_suggestion-final_receipt_base_quantity
                * lv_receipt_count.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        lv_receipt_item_quantity =
          ls_suggestion-final_receipt_base_quantity.
      ELSEIF ls_suggestion-maximum_base_quantity > 0.
        IF ls_suggestion-final_receipt_base_quantity
              > ls_suggestion-maximum_base_quantity
            OR ls_suggestion-suggested_base_quantity
              <> ls_suggestion-maximum_base_quantity
                * ( lv_receipt_count - 1 )
                + ls_suggestion-final_receipt_base_quantity.
          RAISE EXCEPTION TYPE zcx_invalid_stock_request.
        ENDIF.
        lv_receipt_item_quantity = ls_suggestion-maximum_base_quantity.
      ELSE.
        RAISE EXCEPTION TYPE zcx_invalid_stock_request.
      ENDIF.

      DO lv_receipt_count TIMES.
        ADD 10 TO lv_item_number.
        IF sy-index = lv_receipt_count.
          lv_receipt_item_quantity =
            ls_suggestion-final_receipt_base_quantity.
        ENDIF.
        APPEND VALUE #(
          item_number             = lv_item_number
          source_suggestion_index = lv_suggestion_index
          material                = ls_suggestion-material
          plant                   = ls_suggestion-plant
          quantity                = lv_receipt_item_quantity
          unit                    = ls_suggestion-base_unit
          delivery_date           = ls_suggestion-required_date
          purchasing_group        = lv_item_purchasing_group
          purchasing_org          = lv_item_purchasing_org
          source_vendor           = ls_suggestion-source_vendor
          source_info_record      = ls_suggestion-source_info_record
          source_agreement        = ls_suggestion-source_agreement
          source_agreement_item   = ls_suggestion-source_agreement_item )
          TO ls_request-items.
      ENDDO.
    ENDLOOP.

    IF ls_request-items IS INITIAL.
      rs_result-is_successful = abap_true.
      rs_result-is_test_run = iv_test_run.
      APPEND VALUE #(
        type    = 'S'
        message = 'No positive replenishment suggestions to requisition' )
        TO rs_result-messages.
      RETURN.
    ENDIF.

    rs_result = complete_write(
      is_request = ls_request
      is_result  = mo_api->create_requisition( ls_request ) ).
    rs_result-submitted_items = ls_request-items.
  ENDMETHOD.

  METHOD create_from_selected_sources.
    DATA(lt_selected_suggestions) =
      zcl_repl_source_service=>apply_selected_source_options(
        it_suggestions = it_suggestions
        it_options     = it_selected_source_options ).

    rs_result = create_from_suggestions(
      it_suggestions         = lt_selected_suggestions
      iv_requisition_type    = iv_requisition_type
      iv_purchasing_group    = iv_purchasing_group
      iv_purchasing_org      = iv_purchasing_org
      it_purchasing_controls = it_purchasing_controls
      iv_test_run            = iv_test_run ).
  ENDMETHOD.

  METHOD complete_write.
    rs_result = is_result.
    rs_result-is_test_run = is_request-is_test_run.
    rs_result-bapi_was_called = abap_true.
    rs_result-is_committed = abap_false.
    LOOP AT rs_result-messages ASSIGNING FIELD-SYMBOL(<ls_message>).
      IF ( <ls_message>-parameter = 'PRITEM'
          OR <ls_message>-parameter = 'PRITEMX' )
          AND <ls_message>-row > 0.
        READ TABLE is_request-items
          INDEX CONV i( <ls_message>-row )
          INTO DATA(ls_item_message).
        IF sy-subrc = 0.
          <ls_message>-item_number = ls_item_message-item_number.
          <ls_message>-source_suggestion_index =
            ls_item_message-source_suggestion_index.
        ENDIF.
      ENDIF.
      IF <ls_message>-type = 'A'
          OR <ls_message>-type = 'E'
          OR <ls_message>-type = 'X'.
        mo_api->rollback( ).
        rs_result-is_successful = abap_false.
        RETURN.
      ENDIF.
    ENDLOOP.

    IF rs_result-is_successful = abap_false.
      mo_api->rollback( ).
      RETURN.
    ENDIF.

    IF is_request-is_test_run = abap_true.
      rs_result-is_successful = abap_true.
      RETURN.
    ENDIF.

    IF rs_result-requisition_number IS INITIAL.
      mo_api->rollback( ).
      APPEND VALUE #(
        type    = 'E'
        message = 'Purchase requisition write returned no document number' )
        TO rs_result-messages.
      rs_result-is_successful = abap_false.
      RETURN.
    ENDIF.

    DATA(ls_commit_result) = mo_api->commit( ).
    IF ls_commit_result-is_successful = abap_false.
      mo_api->rollback( ).
      IF ls_commit_result-message IS NOT INITIAL.
        APPEND ls_commit_result-message TO rs_result-messages.
      ENDIF.
      rs_result-is_successful = abap_false.
      RETURN.
    ENDIF.

    rs_result-is_successful = abap_true.
    rs_result-is_committed = abap_true.
  ENDMETHOD.

ENDCLASS.
