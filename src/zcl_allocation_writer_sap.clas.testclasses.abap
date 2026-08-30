CLASS lcl_reservation_gateway DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_reservation_gateway.

    TYPES:
      BEGIN OF ty_response,
        document_id TYPE zcl_stock_allocator=>ty_document_id,
        messages    TYPE zif_reservation_gateway=>ty_messages,
      END OF ty_response.
    TYPES ty_responses TYPE STANDARD TABLE OF ty_response WITH EMPTY KEY.

    DATA mt_responses TYPE ty_responses.
    DATA mt_requests TYPE STANDARD TABLE OF zif_reservation_gateway=>ty_request
      WITH EMPTY KEY.
    DATA mt_commit_messages TYPE zif_reservation_gateway=>ty_messages.
    DATA mv_commit_count TYPE i.
    DATA mv_rollback_count TYPE i.
ENDCLASS.

CLASS lcl_reservation_gateway IMPLEMENTATION.
  METHOD zif_reservation_gateway~create_reservation.
    APPEND is_request TO mt_requests.
    DATA(lv_index) = lines( mt_requests ).
    IF line_exists( mt_responses[ lv_index ] ).
      ev_document_id = mt_responses[ lv_index ]-document_id.
      et_messages = mt_responses[ lv_index ]-messages.
    ENDIF.
  ENDMETHOD.

  METHOD zif_reservation_gateway~commit.
    mv_commit_count = mv_commit_count + 1.
    rt_messages = mt_commit_messages.
  ENDMETHOD.

  METHOD zif_reservation_gateway~rollback.
    mv_rollback_count = mv_rollback_count + 1.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_idempotency_store DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_idempotency_store.

    TYPES ty_request_ids TYPE HASHED TABLE OF
      zcl_stock_allocator=>ty_request_id
      WITH UNIQUE KEY table_line.
    TYPES:
      BEGIN OF ty_document,
        request_id  TYPE zcl_stock_allocator=>ty_request_id,
        document_id TYPE zcl_stock_allocator=>ty_document_id,
      END OF ty_document.
    TYPES ty_documents TYPE STANDARD TABLE OF ty_document WITH EMPTY KEY.

    DATA mt_claimed TYPE ty_request_ids.
    DATA mt_claim_order TYPE STANDARD TABLE OF
      zcl_stock_allocator=>ty_request_id WITH EMPTY KEY.
    DATA mt_documents TYPE ty_documents.
    DATA mt_replaced_documents TYPE ty_documents.
    DATA mv_update_fails TYPE abap_bool.
    DATA mv_replacement_fails TYPE abap_bool.
    DATA mv_claim_invalid TYPE abap_bool.
    DATA mv_update_invalid TYPE abap_bool.
ENDCLASS.

CLASS lcl_idempotency_store IMPLEMENTATION.
  METHOD zif_idempotency_store~find.
    IF line_exists( mt_documents[ request_id = iv_request_id ] ).
      rs_record-is_found = abap_true.
      rs_record-request_id = iv_request_id.
      rs_record-document_id =
        mt_documents[ request_id = iv_request_id ]-document_id.
    ENDIF.
  ENDMETHOD.

  METHOD zif_idempotency_store~find_many.
    rs_result-is_success = abap_true.
    LOOP AT it_request_ids INTO DATA(lv_request_id).
      READ TABLE mt_documents INTO DATA(ls_document)
        WITH KEY request_id = lv_request_id.
      IF sy-subrc = 0.
        INSERT VALUE #(
          is_found    = abap_true
          request_id  = lv_request_id
          document_id = ls_document-document_id )
          INTO TABLE rs_result-records.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD zif_idempotency_store~claim.
    APPEND is_allocation-request_id TO mt_claim_order.
    IF mv_claim_invalid = abap_true.
      rv_acquired = 'Y'.
      RETURN.
    ENDIF.
    IF iv_replaced_document_id IS NOT INITIAL.
      APPEND VALUE #(
        request_id  = is_allocation-request_id
        document_id = iv_replaced_document_id )
        TO mt_replaced_documents.
      IF mv_replacement_fails = abap_true.
        rv_acquired = abap_false.
        RETURN.
      ENDIF.
    ENDIF.

    IF line_exists( mt_claimed[ table_line = is_allocation-request_id ] ).
      rv_acquired = abap_false.
      RETURN.
    ENDIF.

    INSERT is_allocation-request_id INTO TABLE mt_claimed.
    rv_acquired = abap_true.
  ENDMETHOD.

  METHOD zif_idempotency_store~set_document.
    IF mv_update_invalid = abap_true.
      rv_updated = 'Y'.
      RETURN.
    ENDIF.
    IF mv_update_fails = abap_true.
      rv_updated = abap_false.
      RETURN.
    ENDIF.

    APPEND VALUE #(
      request_id  = iv_request_id
      document_id = iv_document_id ) TO mt_documents.
    rv_updated = abap_true.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_stock_rechecker DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_stock_rechecker.
    DATA ms_result TYPE zif_stock_rechecker=>ty_result.
    DATA mt_checked TYPE zcl_stock_allocator=>ty_allocations.
ENDCLASS.

CLASS lcl_stock_rechecker IMPLEMENTATION.
  METHOD zif_stock_rechecker~recheck.
    mt_checked = it_allocations.
    rs_result = ms_result.
  ENDMETHOD.
ENDCLASS.

CLASS lcl_stock_lock DEFINITION FINAL.
  PUBLIC SECTION.
    INTERFACES zif_stock_lock.
    DATA ms_result TYPE zif_stock_lock=>ty_result.
    DATA mt_allocations TYPE zcl_stock_allocator=>ty_allocations.
    DATA mv_acquire_count TYPE i.
    DATA mv_release_count TYPE i.
ENDCLASS.

CLASS lcl_stock_lock IMPLEMENTATION.
  METHOD zif_stock_lock~acquire.
    mt_allocations = it_allocations.
    mv_acquire_count = mv_acquire_count + 1.
    rs_result = ms_result.
  ENDMETHOD.

  METHOD zif_stock_lock~release.
    mv_release_count = mv_release_count + 1.
  ENDMETHOD.
ENDCLASS.

CLASS ltcl_allocation_writer_sap DEFINITION FINAL
  FOR TESTING
  RISK LEVEL HARMLESS
  DURATION SHORT.

  PRIVATE SECTION.
    DATA mo_gateway TYPE REF TO lcl_reservation_gateway.
    DATA mo_store TYPE REF TO lcl_idempotency_store.
    DATA mo_rechecker TYPE REF TO lcl_stock_rechecker.
    DATA mo_lock TYPE REF TO lcl_stock_lock.
    DATA mo_cut TYPE REF TO zcl_allocation_writer_sap.

    METHODS setup.
    METHODS commits_successful_batch FOR TESTING.
    METHODS orders_claims_before_posting FOR TESTING.
    METHODS preserves_success_warnings FOR TESTING.
    METHODS rolls_back_create_error FOR TESTING.
    METHODS rejects_bad_create_message FOR TESTING.
    METHODS rolls_back_missing_document FOR TESTING.
    METHODS rejects_invalid_document FOR TESTING.
    METHODS rejects_duplicate_document FOR TESTING.
    METHODS rolls_back_commit_error FOR TESTING.
    METHODS rejects_bad_commit_message FOR TESTING.
    METHODS rejects_duplicate_claim FOR TESTING.
    METHODS rolls_back_store_failure FOR TESTING.
    METHODS rejects_stale_stock FOR TESTING.
    METHODS rejects_lock_failure FOR TESTING.
    METHODS rejects_invalid_claim_state FOR TESTING.
    METHODS rejects_invalid_lock_state FOR TESTING.
    METHODS rejects_invalid_recheck_state FOR TESTING.
    METHODS rejects_invalid_update_state FOR TESTING.
    METHODS rejects_invalid_pending_input FOR TESTING.
    METHODS rejects_imprecise_allocation FOR TESTING.
    METHODS rejects_missing_assignment FOR TESTING.
    METHODS rejects_conflicting_assignment FOR TESTING.
    METHODS rejects_missing_gateway FOR TESTING.
    METHODS rejects_missing_store FOR TESTING.
    METHODS rejects_missing_rechecker FOR TESTING.
    METHODS rejects_missing_lock FOR TESTING.
    METHODS normalizes_empty_lock_failure FOR TESTING.
    METHODS normalizes_empty_recheck FOR TESTING.
    METHODS forwards_sales_assignment FOR TESTING.
    METHODS ignores_empty_batch FOR TESTING.
    METHODS ignores_already_posted FOR TESTING.
    METHODS replaces_cancelled_claim FOR TESTING.
    METHODS rolls_back_replacement_race FOR TESTING.

    METHODS allocations
      IMPORTING
        iv_count              TYPE i DEFAULT 1
      RETURNING
        VALUE(rt_allocations) TYPE zcl_stock_allocator=>ty_allocations.
ENDCLASS.

CLASS ltcl_allocation_writer_sap IMPLEMENTATION.
  METHOD setup.
    mo_gateway = NEW #( ).
    mo_store = NEW #( ).
    mo_rechecker = NEW #( ).
    mo_rechecker->ms_result-is_valid = abap_true.
    mo_lock = NEW #( ).
    mo_lock->ms_result-acquired = abap_true.
    mo_cut = NEW #(
      io_gateway           = mo_gateway
      io_idempotency_store = mo_store
      io_stock_rechecker   = mo_rechecker
      io_stock_lock        = mo_lock ).
  ENDMETHOD.

  METHOD commits_successful_batch.
    mo_gateway->mt_responses = VALUE #(
      ( document_id = '0000000001' )
      ( document_id = '0000000002' ) ).
    DATA(lt_allocations) = allocations( 2 ).

    mo_cut->zif_allocation_writer~save_allocations(
      CHANGING
        ct_allocations = lt_allocations ).

    cl_abap_unit_assert=>assert_equals(
      act = lines( mo_gateway->mt_requests )
      exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_gateway->mv_commit_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_gateway->mv_rollback_count
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_lock->mv_acquire_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_lock->mv_release_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_allocations[ 1 ]-posting_status
      exp = zcl_stock_allocator=>gc_posting_posted ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_allocations[ 2 ]-document_id
      exp = '0000000002' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mt_documents[ request_id = 'REQUEST-2' ]-document_id
      exp = '0000000002' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_gateway->mt_requests[ 1 ]-unit_of_measure
      exp = 'EA' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_gateway->mt_requests[ 1 ]-cost_center
      exp = 'CC1000' ).
  ENDMETHOD.

  METHOD rolls_back_create_error.
    mo_gateway->mt_responses = VALUE #(
      ( document_id = '0000000001' )
      ( messages = VALUE #(
          ( type = 'E' message = 'Insufficient stock during posting' ) ) ) ).
    DATA(lt_allocations) = allocations( 2 ).

    mo_cut->zif_allocation_writer~save_allocations(
      CHANGING
        ct_allocations = lt_allocations ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_gateway->mv_commit_count
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_gateway->mv_rollback_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_allocations[ 1 ]-posting_status
      exp = zcl_stock_allocator=>gc_posting_failed ).
    cl_abap_unit_assert=>assert_initial(
      act = lt_allocations[ 1 ]-document_id ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_allocations[ 2 ]-posting_message
      exp = 'Insufficient stock during posting' ).
  ENDMETHOD.

  METHOD rejects_bad_create_message.
    mo_gateway->mt_responses = VALUE #(
      ( document_id = '0000000001'
        messages    = VALUE #(
          ( type = 'Y' message = 'Unknown create state' ) ) ) ).
    DATA(lt_allocations) = allocations( ).

    mo_cut->zif_allocation_writer~save_allocations(
      CHANGING
        ct_allocations = lt_allocations ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_gateway->mv_commit_count
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_gateway->mv_rollback_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_allocations[ 1 ]-posting_status
      exp = zcl_stock_allocator=>gc_posting_failed ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_allocations[ 1 ]-posting_message
      exp = 'Reservation API returned invalid message type' ).
    cl_abap_unit_assert=>assert_initial( lt_allocations[ 1 ]-document_id ).
  ENDMETHOD.

  METHOD rolls_back_commit_error.
    mo_gateway->mt_responses = VALUE #(
      ( document_id = '0000000001' ) ).
    mo_gateway->mt_commit_messages = VALUE #(
      ( type = 'E' message = 'Commit failed' ) ).
    DATA(lt_allocations) = allocations( ).

    mo_cut->zif_allocation_writer~save_allocations(
      CHANGING
        ct_allocations = lt_allocations ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_gateway->mv_commit_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_gateway->mv_rollback_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_allocations[ 1 ]-posting_status
      exp = zcl_stock_allocator=>gc_posting_failed ).
  ENDMETHOD.

  METHOD rejects_bad_commit_message.
    mo_gateway->mt_responses = VALUE #(
      ( document_id = '0000000001' ) ).
    mo_gateway->mt_commit_messages = VALUE #(
      ( message = 'Missing commit message type' ) ).
    DATA(lt_allocations) = allocations( ).

    mo_cut->zif_allocation_writer~save_allocations(
      CHANGING
        ct_allocations = lt_allocations ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_gateway->mv_commit_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_gateway->mv_rollback_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_allocations[ 1 ]-posting_status
      exp = zcl_stock_allocator=>gc_posting_failed ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_allocations[ 1 ]-posting_message
      exp = 'Reservation commit returned invalid message type' ).
    cl_abap_unit_assert=>assert_initial( lt_allocations[ 1 ]-document_id ).
  ENDMETHOD.

  METHOD rolls_back_missing_document.
    mo_gateway->mt_responses = VALUE #( ( ) ).
    DATA(lt_allocations) = allocations( ).

    mo_cut->zif_allocation_writer~save_allocations(
      CHANGING
        ct_allocations = lt_allocations ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_gateway->mv_rollback_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_allocations[ 1 ]-posting_status
      exp = zcl_stock_allocator=>gc_posting_failed ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_allocations[ 1 ]-posting_message
      exp = 'Reservation API returned no document ID' ).
  ENDMETHOD.

  METHOD rejects_invalid_document.
    mo_gateway->mt_responses = VALUE #(
      ( document_id = 'BAD-DOC-ID' ) ).
    DATA(lt_allocations) = allocations( ).

    mo_cut->zif_allocation_writer~save_allocations(
      CHANGING
        ct_allocations = lt_allocations ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_gateway->mv_commit_count
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_gateway->mv_rollback_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_allocations[ 1 ]-posting_message
      exp = 'Reservation API returned invalid document ID' ).
    cl_abap_unit_assert=>assert_initial( lt_allocations[ 1 ]-document_id ).
  ENDMETHOD.

  METHOD rejects_duplicate_document.
    mo_gateway->mt_responses = VALUE #(
      ( document_id = '0000000001' )
      ( document_id = '0000000001' ) ).
    DATA(lt_allocations) = allocations( 2 ).

    mo_cut->zif_allocation_writer~save_allocations(
      CHANGING
        ct_allocations = lt_allocations ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_gateway->mv_commit_count
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_gateway->mv_rollback_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_allocations[ 1 ]-posting_status
      exp = zcl_stock_allocator=>gc_posting_failed ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_allocations[ 2 ]-posting_message
      exp = 'Reservation API returned duplicate document ID' ).
    cl_abap_unit_assert=>assert_initial( lt_allocations[ 1 ]-document_id ).
    cl_abap_unit_assert=>assert_initial( lt_allocations[ 2 ]-document_id ).
  ENDMETHOD.

  METHOD ignores_empty_batch.
    DATA lt_allocations TYPE zcl_stock_allocator=>ty_allocations.

    mo_cut->zif_allocation_writer~save_allocations(
      CHANGING
        ct_allocations = lt_allocations ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_gateway->mv_commit_count
      exp = 0 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_gateway->mv_rollback_count
      exp = 0 ).
  ENDMETHOD.

  METHOD ignores_already_posted.
    DATA(lt_allocations) = allocations( ).
    lt_allocations[ 1 ]-posting_status =
      zcl_stock_allocator=>gc_posting_posted.
    lt_allocations[ 1 ]-document_id = '0000000001'.

    mo_cut->zif_allocation_writer~save_allocations(
      CHANGING
        ct_allocations = lt_allocations ).

    cl_abap_unit_assert=>assert_initial( mo_store->mt_claimed ).
    cl_abap_unit_assert=>assert_initial( mo_gateway->mt_requests ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_lock->mv_acquire_count
      exp = 0 ).
  ENDMETHOD.

  METHOD orders_claims_before_posting.
    mo_gateway->mt_responses = VALUE #(
      ( document_id = '0000000001' )
      ( document_id = '0000000002' ) ).
    DATA(lt_allocations) = allocations( 2 ).
    lt_allocations[ 1 ]-request_id = 'Z-REQUEST'.
    lt_allocations[ 2 ]-request_id = 'A-REQUEST'.

    mo_cut->zif_allocation_writer~save_allocations(
      CHANGING
        ct_allocations = lt_allocations ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mt_claim_order[ 1 ]
      exp = 'A-REQUEST' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mt_claim_order[ 2 ]
      exp = 'Z-REQUEST' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_gateway->mt_requests[ 1 ]-request_id
      exp = 'Z-REQUEST' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_gateway->mt_requests[ 2 ]-request_id
      exp = 'A-REQUEST' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_allocations[ 1 ]-document_id
      exp = '0000000001' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_allocations[ 2 ]-document_id
      exp = '0000000002' ).
  ENDMETHOD.

  METHOD preserves_success_warnings.
    mo_gateway->mt_responses = VALUE #(
      ( document_id = '0000000001'
        messages    = VALUE #(
          ( type = 'W' message = 'Requirement date was adjusted' ) ) )
      ( document_id = '0000000002' ) ).
    mo_gateway->mt_commit_messages = VALUE #(
      ( type = 'W' message = 'Commit completed with a warning' ) ).
    DATA(lt_allocations) = allocations( 2 ).
    lt_allocations[ 1 ]-replaced_document_id = '0000000041'.

    mo_cut->zif_allocation_writer~save_allocations(
      CHANGING
        ct_allocations = lt_allocations ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_allocations[ 1 ]-posting_status
      exp = zcl_stock_allocator=>gc_posting_posted ).
    DATA(lv_expected_message) =
      |Cancelled reservation 0000000041 replaced; | &&
      |Requirement date was adjusted; | &&
      |Commit completed with a warning|.
    cl_abap_unit_assert=>assert_equals(
      act = lt_allocations[ 1 ]-posting_message
      exp = lv_expected_message ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_allocations[ 2 ]-posting_message
      exp = 'Commit completed with a warning' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_gateway->mv_rollback_count
      exp = 0 ).
  ENDMETHOD.

  METHOD replaces_cancelled_claim.
    mo_gateway->mt_responses = VALUE #(
      ( document_id = '0000000099' ) ).
    DATA(lt_allocations) = allocations( ).
    lt_allocations[ 1 ]-replaced_document_id = '0000000041'.

    mo_cut->zif_allocation_writer~save_allocations(
      CHANGING
        ct_allocations = lt_allocations ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_store->mt_replaced_documents[ 1 ]-document_id
      exp = '0000000041' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_allocations[ 1 ]-document_id
      exp = '0000000099' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_allocations[ 1 ]-posting_message
      exp = 'Cancelled reservation 0000000041 replaced' ).
  ENDMETHOD.

  METHOD rolls_back_replacement_race.
    mo_store->mv_replacement_fails = abap_true.
    DATA(lt_allocations) = allocations( ).
    lt_allocations[ 1 ]-replaced_document_id = '0000000041'.

    mo_cut->zif_allocation_writer~save_allocations(
      CHANGING
        ct_allocations = lt_allocations ).

    cl_abap_unit_assert=>assert_initial( mo_gateway->mt_requests ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_gateway->mv_rollback_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_allocations[ 1 ]-posting_status
      exp = zcl_stock_allocator=>gc_posting_failed ).
  ENDMETHOD.

  METHOD rejects_duplicate_claim.
    INSERT 'REQUEST-1' INTO TABLE mo_store->mt_claimed.
    DATA(lt_allocations) = allocations( ).

    mo_cut->zif_allocation_writer~save_allocations(
      CHANGING
        ct_allocations = lt_allocations ).

    cl_abap_unit_assert=>assert_initial(
      act = mo_gateway->mt_requests ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_gateway->mv_rollback_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_allocations[ 1 ]-posting_status
      exp = zcl_stock_allocator=>gc_posting_failed ).
  ENDMETHOD.

  METHOD rolls_back_store_failure.
    mo_gateway->mt_responses = VALUE #(
      ( document_id = '0000000001' ) ).
    mo_store->mv_update_fails = abap_true.
    DATA(lt_allocations) = allocations( ).

    mo_cut->zif_allocation_writer~save_allocations(
      CHANGING
        ct_allocations = lt_allocations ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_gateway->mv_rollback_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_allocations[ 1 ]-posting_message
      exp = 'Reservation document could not be persisted' ).
  ENDMETHOD.

  METHOD rejects_stale_stock.
    mo_rechecker->ms_result = VALUE #(
      is_valid = abap_false
      message  = 'Available stock changed during allocation posting' ).
    DATA(lt_allocations) = allocations( ).

    mo_cut->zif_allocation_writer~save_allocations(
      CHANGING
        ct_allocations = lt_allocations ).

    cl_abap_unit_assert=>assert_initial(
      act = mo_gateway->mt_requests ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_gateway->mv_rollback_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_allocations[ 1 ]-posting_status
      exp = zcl_stock_allocator=>gc_posting_failed ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_allocations[ 1 ]-posting_message
      exp = 'Available stock changed during allocation posting' ).
  ENDMETHOD.

  METHOD rejects_lock_failure.
    mo_lock->ms_result = VALUE #(
      acquired = abap_false
      message  = 'Stock pool is locked by another process' ).
    DATA(lt_allocations) = allocations( ).

    mo_cut->zif_allocation_writer~save_allocations(
      CHANGING
        ct_allocations = lt_allocations ).

    cl_abap_unit_assert=>assert_initial(
      act = mo_rechecker->mt_checked ).
    cl_abap_unit_assert=>assert_initial(
      act = mo_gateway->mt_requests ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_gateway->mv_rollback_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_lock->mv_release_count
      exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_allocations[ 1 ]-posting_message
      exp = 'Stock pool is locked by another process' ).
  ENDMETHOD.

  METHOD rejects_invalid_claim_state.
    mo_store->mv_claim_invalid = abap_true.
    DATA(lt_allocations) = allocations( ).

    mo_cut->zif_allocation_writer~save_allocations(
      CHANGING
        ct_allocations = lt_allocations ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_allocations[ 1 ]-posting_message
      exp = 'Idempotency claim returned invalid state' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_lock->mv_acquire_count
      exp = 0 ).
    cl_abap_unit_assert=>assert_initial( mo_gateway->mt_requests ).
  ENDMETHOD.

  METHOD rejects_invalid_lock_state.
    mo_lock->ms_result = VALUE #(
      acquired = 'Y'
      message  = 'Malformed lock state' ).
    DATA(lt_allocations) = allocations( ).

    mo_cut->zif_allocation_writer~save_allocations(
      CHANGING
        ct_allocations = lt_allocations ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_allocations[ 1 ]-posting_message
      exp = 'Stock lock returned invalid state' ).
    cl_abap_unit_assert=>assert_initial( mo_rechecker->mt_checked ).
    cl_abap_unit_assert=>assert_initial( mo_gateway->mt_requests ).
  ENDMETHOD.

  METHOD rejects_invalid_recheck_state.
    mo_rechecker->ms_result = VALUE #(
      is_valid = 'Y'
      message  = 'Malformed recheck state' ).
    DATA(lt_allocations) = allocations( ).

    mo_cut->zif_allocation_writer~save_allocations(
      CHANGING
        ct_allocations = lt_allocations ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_allocations[ 1 ]-posting_message
      exp = 'Stock recheck returned invalid state' ).
    cl_abap_unit_assert=>assert_initial( mo_gateway->mt_requests ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_lock->mv_release_count
      exp = 1 ).
  ENDMETHOD.

  METHOD rejects_invalid_update_state.
    mo_gateway->mt_responses = VALUE #(
      ( document_id = '0000000001' ) ).
    mo_store->mv_update_invalid = abap_true.
    DATA(lt_allocations) = allocations( ).

    mo_cut->zif_allocation_writer~save_allocations(
      CHANGING
        ct_allocations = lt_allocations ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_allocations[ 1 ]-posting_message
      exp = 'Idempotency document update returned invalid state' ).
    cl_abap_unit_assert=>assert_initial(
      lt_allocations[ 1 ]-document_id ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_gateway->mv_rollback_count
      exp = 1 ).
  ENDMETHOD.

  METHOD rejects_invalid_pending_input.
    DATA(lt_allocations) = allocations( ).
    CLEAR lt_allocations[ 1 ]-material.

    mo_cut->zif_allocation_writer~save_allocations(
      CHANGING
        ct_allocations = lt_allocations ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_allocations[ 1 ]-posting_status
      exp = zcl_stock_allocator=>gc_posting_failed ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_allocations[ 1 ]-posting_message
      exp = 'Allocation writer input is invalid' ).
    cl_abap_unit_assert=>assert_initial( mo_store->mt_claim_order ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_lock->mv_acquire_count
      exp = 0 ).
    cl_abap_unit_assert=>assert_initial( mo_gateway->mt_requests ).
  ENDMETHOD.

  METHOD rejects_imprecise_allocation.
    DATA(lt_allocations) = allocations( ).
    lt_allocations[ 1 ]-allocated_qty = '1.0001'.
    lt_allocations[ 1 ]-status = zcl_stock_allocator=>gc_status_partial.

    mo_cut->zif_allocation_writer~save_allocations(
      CHANGING
        ct_allocations = lt_allocations ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_allocations[ 1 ]-posting_status
      exp = zcl_stock_allocator=>gc_posting_failed ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_allocations[ 1 ]-posting_message
      exp = 'Allocation writer input is invalid' ).
    cl_abap_unit_assert=>assert_initial( mo_store->mt_claim_order ).
    cl_abap_unit_assert=>assert_initial( mo_gateway->mt_requests ).
  ENDMETHOD.

  METHOD rejects_missing_assignment.
    DATA(lt_allocations) = allocations( ).
    CLEAR lt_allocations[ 1 ]-cost_center.

    mo_cut->zif_allocation_writer~save_allocations(
      CHANGING
        ct_allocations = lt_allocations ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_allocations[ 1 ]-posting_status
      exp = zcl_stock_allocator=>gc_posting_failed ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_allocations[ 1 ]-posting_message
      exp = 'Allocation writer input is invalid' ).
    cl_abap_unit_assert=>assert_initial( mo_store->mt_claim_order ).
    cl_abap_unit_assert=>assert_initial( mo_gateway->mt_requests ).
  ENDMETHOD.

  METHOD rejects_conflicting_assignment.
    DATA(lt_allocations) = allocations( ).
    lt_allocations[ 1 ]-order_id = 'ORDER-1'.

    mo_cut->zif_allocation_writer~save_allocations(
      CHANGING
        ct_allocations = lt_allocations ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_allocations[ 1 ]-posting_status
      exp = zcl_stock_allocator=>gc_posting_failed ).
    cl_abap_unit_assert=>assert_initial( mo_store->mt_claim_order ).
    cl_abap_unit_assert=>assert_initial( mo_gateway->mt_requests ).
  ENDMETHOD.

  METHOD rejects_missing_gateway.
    DATA lo_gateway TYPE REF TO zif_reservation_gateway.
    mo_cut = NEW #(
      io_gateway           = lo_gateway
      io_idempotency_store = mo_store
      io_stock_rechecker   = mo_rechecker
      io_stock_lock        = mo_lock ).
    DATA(lt_allocations) = allocations( ).

    mo_cut->zif_allocation_writer~save_allocations(
      CHANGING
        ct_allocations = lt_allocations ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_allocations[ 1 ]-posting_message
      exp = 'Allocation writer dependencies are required' ).
    cl_abap_unit_assert=>assert_initial( mo_store->mt_claim_order ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_lock->mv_acquire_count
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_missing_store.
    DATA lo_store TYPE REF TO zif_idempotency_store.
    mo_cut = NEW #(
      io_gateway           = mo_gateway
      io_idempotency_store = lo_store
      io_stock_rechecker   = mo_rechecker
      io_stock_lock        = mo_lock ).
    DATA(lt_allocations) = allocations( ).

    mo_cut->zif_allocation_writer~save_allocations(
      CHANGING
        ct_allocations = lt_allocations ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_allocations[ 1 ]-posting_message
      exp = 'Allocation writer dependencies are required' ).
    cl_abap_unit_assert=>assert_initial( mo_gateway->mt_requests ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_lock->mv_acquire_count
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_missing_rechecker.
    DATA lo_rechecker TYPE REF TO zif_stock_rechecker.
    mo_cut = NEW #(
      io_gateway           = mo_gateway
      io_idempotency_store = mo_store
      io_stock_rechecker   = lo_rechecker
      io_stock_lock        = mo_lock ).
    DATA(lt_allocations) = allocations( ).

    mo_cut->zif_allocation_writer~save_allocations(
      CHANGING
        ct_allocations = lt_allocations ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_allocations[ 1 ]-posting_message
      exp = 'Allocation writer dependencies are required' ).
    cl_abap_unit_assert=>assert_initial( mo_store->mt_claim_order ).
    cl_abap_unit_assert=>assert_initial( mo_gateway->mt_requests ).
  ENDMETHOD.

  METHOD rejects_missing_lock.
    DATA lo_lock TYPE REF TO zif_stock_lock.
    mo_cut = NEW #(
      io_gateway           = mo_gateway
      io_idempotency_store = mo_store
      io_stock_rechecker   = mo_rechecker
      io_stock_lock        = lo_lock ).
    DATA(lt_allocations) = allocations( ).

    mo_cut->zif_allocation_writer~save_allocations(
      CHANGING
        ct_allocations = lt_allocations ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_allocations[ 1 ]-posting_message
      exp = 'Allocation writer dependencies are required' ).
    cl_abap_unit_assert=>assert_initial( mo_store->mt_claim_order ).
    cl_abap_unit_assert=>assert_initial( mo_gateway->mt_requests ).
  ENDMETHOD.

  METHOD normalizes_empty_lock_failure.
    mo_lock->ms_result-acquired = abap_false.
    DATA(lt_allocations) = allocations( ).

    mo_cut->zif_allocation_writer~save_allocations(
      CHANGING
        ct_allocations = lt_allocations ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_allocations[ 1 ]-posting_message
      exp = 'Stock lock acquisition failed' ).
    cl_abap_unit_assert=>assert_initial( mo_rechecker->mt_checked ).
    cl_abap_unit_assert=>assert_initial( mo_gateway->mt_requests ).
  ENDMETHOD.

  METHOD normalizes_empty_recheck.
    mo_rechecker->ms_result-is_valid = abap_false.
    DATA(lt_allocations) = allocations( ).

    mo_cut->zif_allocation_writer~save_allocations(
      CHANGING
        ct_allocations = lt_allocations ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_allocations[ 1 ]-posting_message
      exp = 'Stock recheck failed' ).
    cl_abap_unit_assert=>assert_initial( mo_gateway->mt_requests ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_lock->mv_release_count
      exp = 1 ).
  ENDMETHOD.

  METHOD forwards_sales_assignment.
    mo_gateway->mt_responses = VALUE #(
      ( document_id = '0000000001' ) ).
    DATA(lt_allocations) = allocations( ).
    CLEAR lt_allocations[ 1 ]-cost_center.
    lt_allocations[ 1 ]-movement_type = '231'.
    lt_allocations[ 1 ]-sales_order = '0000123456'.
    lt_allocations[ 1 ]-sales_order_item = '000010'.

    mo_cut->zif_allocation_writer~save_allocations(
      CHANGING
        ct_allocations = lt_allocations ).

    cl_abap_unit_assert=>assert_equals(
      act = lt_allocations[ 1 ]-posting_status
      exp = zcl_stock_allocator=>gc_posting_posted ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_gateway->mt_requests[ 1 ]-sales_order
      exp = '0000123456' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_gateway->mt_requests[ 1 ]-sales_order_item
      exp = '000010' ).
  ENDMETHOD.

  METHOD allocations.
    DO iv_count TIMES.
      APPEND VALUE #(
        request_id             = |REQUEST-{ sy-index }|
        material               = 'MAT-1'
        plant                  = '1000'
        storage_location       = '0001'
        movement_type          = '201'
        cost_center            = 'CC1000'
        source_requested_qty   = 5
        source_unit_of_measure = 'EA'
        minimum_fill_pct       = 80
        priority               = 1
        allow_partial          = abap_true
        unit_of_measure        = 'EA'
        requirement_date       = '20260818'
        requested_qty          = 5
        allocated_qty          = 5
        status                 = zcl_stock_allocator=>gc_status_allocated
        posting_status         = zcl_stock_allocator=>gc_posting_pending )
        TO rt_allocations.
    ENDDO.
  ENDMETHOD.
ENDCLASS.
