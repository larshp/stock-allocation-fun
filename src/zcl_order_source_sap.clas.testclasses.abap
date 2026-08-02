CLASS ltcl_order_source_sap DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.
  PRIVATE SECTION.
    METHODS maps_delivery_priority FOR TESTING.
    METHODS filters_requested_horizon FOR TESTING.
    METHODS rejects_reversed_horizon FOR TESTING.
    METHODS rejects_missing_order_unit FOR TESTING.
    METHODS rejects_missing_requested_date FOR TESTING.
    METHODS rejects_missing_doc_type FOR TESTING.
    METHODS rejects_invalid_identity FOR TESTING.
    METHODS filters_delivery_blocks FOR TESTING.
ENDCLASS.

CLASS ltcl_order_source_sap IMPLEMENTATION.
  METHOD maps_delivery_priority.
    DATA lo_cut TYPE REF TO zif_order_source.
    DATA lt_demands TYPE zif_stock_allocation=>tt_demands.

    CREATE OBJECT lo_cut TYPE zcl_order_source_sap.
    lt_demands = lo_cut->get_open_demands(
      iv_material = 'MATERIAL-PRIO'
      iv_plant    = '1000' ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_demands )
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ order_id = 'PRIO0000010000100001' ]-priority
      exp = 99 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ order_id = 'PRIO0000010000100001' ]-sales_document
      exp = 'PRIO000001' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ order_id = 'PRIO0000010000100001' ]-sales_document_type
      exp = 'OR' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ order_id = 'PRIO0000010000100001' ]-sales_item
      exp = '000010' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ order_id = 'PRIO0000010000100001' ]-schedule_line
      exp = '0001' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ order_id = 'PRIO0000010000100001' ]-order_unit
      exp = 'EA' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ order_id = 'PRIO0000010000100001' ]-requested
      exp = '5' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ order_id = 'PRIO0000010000100002' ]-requested
      exp = '2' ).
  ENDMETHOD.

  METHOD filters_requested_horizon.
    DATA lo_cut TYPE REF TO zif_order_source.
    DATA lt_demands TYPE zif_stock_allocation=>tt_demands.

    CREATE OBJECT lo_cut TYPE zcl_order_source_sap.
    lt_demands = lo_cut->get_open_demands(
      iv_material        = 'MATERIAL-PRIO'
      iv_plant           = '1000'
      iv_requested_on_to = '20260816' ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_demands )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ 1 ]-order_id
      exp = 'PRIO0000010000100001' ).
    lt_demands = lo_cut->get_open_demands(
      iv_material          = 'MATERIAL-PRIO'
      iv_plant             = '1000'
      iv_requested_on_from = '20260820'
      iv_requested_on_to   = '20260820' ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( lt_demands )
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_demands[ 1 ]-order_id
      exp = 'PRIO0000010000100002' ).
  ENDMETHOD.

  METHOD rejects_reversed_horizon.
    DATA lo_cut TYPE REF TO zif_order_source.
    DATA lv_raised TYPE abap_bool.
    DATA lv_message TYPE c LENGTH 220.

    CREATE OBJECT lo_cut TYPE zcl_order_source_sap.
    TRY.
        lo_cut->get_open_demands(
          iv_material          = 'MATERIAL-PRIO'
          iv_plant             = '1000'
          iv_requested_on_from = '20260820'
          iv_requested_on_to   = '20260816' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        lv_message = lo_error->message.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Requested delivery date range is invalid' ).
  ENDMETHOD.

  METHOD rejects_missing_order_unit.
    DATA lo_cut TYPE REF TO zif_order_source.
    DATA lv_raised TYPE abap_bool.
    DATA lv_message TYPE c LENGTH 220.

    CREATE OBJECT lo_cut TYPE zcl_order_source_sap.
    TRY.
        lo_cut->get_open_demands(
          iv_material = 'MATERIAL-NO-UNIT'
          iv_plant    = '1000' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        lv_message = lo_error->message.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Open demand unit is missing' ).
  ENDMETHOD.

  METHOD rejects_missing_requested_date.
    DATA lo_cut TYPE REF TO zif_order_source.
    DATA lv_raised TYPE abap_bool.
    DATA lv_message TYPE c LENGTH 220.

    CREATE OBJECT lo_cut TYPE zcl_order_source_sap.
    TRY.
        lo_cut->get_open_demands(
          iv_material = 'MATERIAL-NO-DATE'
          iv_plant    = '1000' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        lv_message = lo_error->message.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Open demand requested date is missing' ).
  ENDMETHOD.

  METHOD filters_delivery_blocks.
    DATA lo_cut TYPE REF TO zif_order_source.
    DATA lt_demands TYPE zif_stock_allocation=>tt_demands.

    CREATE OBJECT lo_cut TYPE zcl_order_source_sap.
    lt_demands = lo_cut->get_open_demands(
      iv_material = 'MATERIAL-PRIO'
      iv_plant    = '1000' ).

    READ TABLE lt_demands
      WITH KEY sales_document = 'BLKHEAD001'
      TRANSPORTING NO FIELDS.
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 4 ).
    READ TABLE lt_demands
      WITH KEY sales_document = 'BLKITEM001'
      TRANSPORTING NO FIELDS.
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 4 ).
  ENDMETHOD.

  METHOD rejects_invalid_identity.
    DATA lo_cut TYPE REF TO zif_order_source.
    DATA lv_raised TYPE abap_bool.
    DATA lv_message TYPE c LENGTH 220.

    CREATE OBJECT lo_cut TYPE zcl_order_source_sap.
    TRY.
        lo_cut->get_open_demands(
          iv_material = 'MATERIAL-MALFORMED'
          iv_plant    = '1000' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        lv_message = lo_error->message.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Open demand record is invalid' ).
  ENDMETHOD.

  METHOD rejects_missing_doc_type.
    DATA lo_cut TYPE REF TO zif_order_source.
    DATA lv_raised TYPE abap_bool.
    DATA lv_message TYPE c LENGTH 220.

    CREATE OBJECT lo_cut TYPE zcl_order_source_sap.
    TRY.
        lo_cut->get_open_demands(
          iv_material = 'MATERIAL-NO-TYPE'
          iv_plant    = '1000' ).
      CATCH zcx_stock_allocation INTO DATA(lo_error).
        lv_raised = abap_true.
        lv_message = lo_error->message.
    ENDTRY.

    cl_abap_unit_assert=>assert_true( lv_raised ).
    cl_abap_unit_assert=>assert_equals(
      act = lv_message
      exp = 'Sales document type is missing' ).
  ENDMETHOD.
ENDCLASS.
