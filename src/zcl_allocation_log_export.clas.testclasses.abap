CLASS lcl_allocation_history_reader DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_allocation_history_reader.
    DATA ms_result TYPE zif_allocation_history_reader=>ty_result.
    DATA mv_from_date TYPE d.
    DATA mv_to_date TYPE d.
    DATA mv_request_id TYPE zstock_algh-request_id.
    DATA mv_run_mode TYPE zstock_algh-run_mode.
    DATA mv_run_id TYPE zstock_algh-run_id.
    DATA mv_max_rows TYPE i.
    DATA mv_calls TYPE i.
ENDCLASS.

CLASS lcl_allocation_history_reader IMPLEMENTATION.
  METHOD zif_allocation_history_reader~read.
    mv_calls = mv_calls + 1.
    mv_from_date = iv_from_date.
    mv_to_date = iv_to_date.
    mv_request_id = iv_request_id.
    mv_run_mode = iv_run_mode.
    mv_run_id = iv_run_id.
    mv_max_rows = iv_max_rows.
    rs_result = ms_result.
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_allocation_log_export DEFINITION FINAL
  FOR TESTING
  RISK LEVEL HARMLESS
  DURATION SHORT.

  PRIVATE SECTION.
    DATA mo_reader TYPE REF TO lcl_allocation_history_reader.
    DATA mo_cut TYPE REF TO zcl_allocation_log_export.

    METHODS setup.
    METHODS exports_filtered_csv FOR TESTING.
    METHODS supplies_default_dates FOR TESTING.
    METHODS rejects_invalid_range FOR TESTING.
    METHODS rejects_invalid_limit FOR TESTING.
    METHODS rejects_truncated_result FOR TESTING.
    METHODS rejects_invalid_mode FOR TESTING.
    METHODS propagates_read_failure FOR TESTING.
    METHODS creates_sap_composition FOR TESTING.
ENDCLASS.

CLASS ltcl_allocation_log_export IMPLEMENTATION.
  METHOD setup.
    mo_reader = NEW #( ).
    mo_reader->ms_result-is_success = abap_true.
    mo_cut = NEW #( mo_reader ).
  ENDMETHOD.

  METHOD exports_filtered_csv.
    mo_reader->ms_result-entries = VALUE #(
      ( logged_on            = '20260801'
        logged_at            = '123456'
        run_id               = '00112233445566778899AABBCCDDEEFF'
        request_id           = 'REQ;1'
        run_mode             = 'P'
        material             = 'MAT-1'
        plant                = '1000'
        storage_location     = '0001'
        movement_type        = '201'
        requirement_date     = '20260815'
        minimum_fill_pct     = 75
        priority             = 10
        allow_partial        = abap_true
        allocation_strategy  = 'DUE_PRIORITY'
        horizon_date         = '20260831'
        require_full_batch   = abap_true
        cost_center          = 'CC1000'
        order_id             = 'ORDER-1'
        wbs_element          = 'PROJECT-1'
        sales_order          = '0000123456'
        sales_order_item     = '000010'
        asset_number         = '000000123456'
        asset_subnumber      = '0000'
        network_id           = '000001234567'
        network_activity     = '0010'
        allocation_status    = 'ALLOCATED'
        decision_code        = 'FULLY_ALLOCATED'
        posting_status       = 'POSTED'
        source_requested_qty = 1
        source_unit          = 'BOX'
        requested_qty        = 5
        allocated_qty        = 5
        unit_of_measure      = 'EA'
        reservation_id       = '0000000001'
        prior_reservation_id = '0000000041'
        log_message          = 'Text "quoted"'
        logged_by            = 'TESTER' ) ).

    DATA(ls_result) = mo_cut->run(
      iv_from_date  = '20260801'
      iv_to_date    = '20260818'
      iv_request_id = 'REQ;1'
      iv_run_mode   = 'P'
      iv_run_id     = '00112233445566778899AABBCCDDEEFF'
      iv_max_rows   = 50 ).

    cl_abap_unit_assert=>assert_true( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-exported_rows
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lines( ls_result-lines )
      exp = 2 ).
    FIND FIRST OCCURRENCE OF 'SALES_ORDER_ITEM' IN ls_result-lines[ 1 ].
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0 ).
    FIND FIRST OCCURRENCE OF 'ALLOCATION_STRATEGY' IN ls_result-lines[ 1 ].
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0 ).
    FIND FIRST OCCURRENCE OF 'DECISION_CODE' IN ls_result-lines[ 1 ].
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0 ).
    FIND FIRST OCCURRENCE OF 'RUN_ID' IN ls_result-lines[ 1 ].
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0 ).
    FIND FIRST OCCURRENCE OF '"00112233445566778899AABBCCDDEEFF"'
      IN ls_result-lines[ 2 ].
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0 ).
    FIND FIRST OCCURRENCE OF '"REQ;1"' IN ls_result-lines[ 2 ].
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0 ).
    FIND FIRST OCCURRENCE OF '"Text ""quoted"""' IN ls_result-lines[ 2 ].
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0 ).
    FIND FIRST OCCURRENCE OF ';"EA";' IN ls_result-lines[ 2 ].
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0 ).
    FIND FIRST OCCURRENCE OF ';"BOX";' IN ls_result-lines[ 2 ].
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0 ).
    FIND FIRST OCCURRENCE OF ';"CC1000";' IN ls_result-lines[ 2 ].
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0 ).
    FIND FIRST OCCURRENCE OF ';"000010";' IN ls_result-lines[ 2 ].
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0 ).
    FIND FIRST OCCURRENCE OF ';"000001234567";"0010";' IN ls_result-lines[ 2 ].
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0 ).
    FIND FIRST OCCURRENCE OF ';"MAT-1";"1000";"0001";"201";'
      IN ls_result-lines[ 2 ].
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0 ).
    FIND FIRST OCCURRENCE OF ';"0000000001";"0000000041";'
      IN ls_result-lines[ 2 ].
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0 ).
    FIND FIRST OCCURRENCE OF ';"ALLOCATED";"FULLY_ALLOCATED";"POSTED";'
      IN ls_result-lines[ 2 ].
    cl_abap_unit_assert=>assert_equals(
      act = sy-subrc
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_max_rows
      exp = 51 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_run_id
      exp = '00112233445566778899AABBCCDDEEFF' ).
  ENDMETHOD.

  METHOD supplies_default_dates.
    DATA(ls_result) = mo_cut->run( iv_today = '20260818' ).

    cl_abap_unit_assert=>assert_true( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_from_date
      exp = '20260719' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_to_date
      exp = '20260818' ).
  ENDMETHOD.

  METHOD rejects_invalid_range.
    DATA(ls_result) = mo_cut->run(
      iv_from_date = '20260818'
      iv_to_date   = '20260801' ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_invalid_limit.
    DATA(ls_result) = mo_cut->run(
      iv_max_rows = zcl_allocation_log_export=>gc_max_rows + 1
      iv_today    = '20260818' ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_truncated_result.
    mo_reader->ms_result-entries = VALUE #(
      ( request_id = 'REQUEST-1' )
      ( request_id = 'REQUEST-2' ) ).

    DATA(ls_result) = mo_cut->run(
      iv_max_rows = 1
      iv_today    = '20260818' ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Export row limit exceeded; narrow the filters' ).
    cl_abap_unit_assert=>assert_initial( ls_result-lines ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_max_rows
      exp = 2 ).
  ENDMETHOD.

  METHOD rejects_invalid_mode.
    DATA(ls_result) = mo_cut->run(
      iv_run_mode = 'X'
      iv_today    = '20260818' ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_reader->mv_calls
      exp = 0 ).
  ENDMETHOD.

  METHOD propagates_read_failure.
    mo_reader->ms_result-is_success = abap_false.
    mo_reader->ms_result-message = 'Read failed'.

    DATA(ls_result) = mo_cut->run( iv_today = '20260818' ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Read failed' ).
  ENDMETHOD.

  METHOD creates_sap_composition.
    DATA(lo_export) = zcl_allocation_log_export=>create_sap( ).

    cl_abap_unit_assert=>assert_bound( lo_export ).
  ENDMETHOD.
ENDCLASS.
