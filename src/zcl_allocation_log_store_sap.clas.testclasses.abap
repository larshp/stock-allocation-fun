CLASS ltcl_allocation_log_store_sap DEFINITION FINAL
  FOR TESTING
  RISK LEVEL HARMLESS
  DURATION SHORT.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_allocation_log_store_sap.

    METHODS setup.
    METHODS accepts_empty_log_batch FOR TESTING.
    METHODS rejects_orphan_current FOR TESTING.
    METHODS rejects_orphan_history FOR TESTING.
    METHODS rejects_misaligned_log_rows FOR TESTING.
    METHODS rejects_initial_history_uuid FOR TESTING.
    METHODS rejects_duplicate_history_uuid FOR TESTING.
    METHODS rejects_invalid_simulation FOR TESTING.
    METHODS rejects_initial_cutoff FOR TESTING.
    METHODS rejects_current_cutoff FOR TESTING.
ENDCLASS.

CLASS ltcl_allocation_log_store_sap IMPLEMENTATION.
  METHOD setup.
    mo_cut = NEW #( ).
  ENDMETHOD.

  METHOD accepts_empty_log_batch.
    DATA(lv_saved) = mo_cut->zif_allocation_log_store~save(
      it_current = VALUE #( )
      it_history = VALUE #( ) ).

    cl_abap_unit_assert=>assert_true( lv_saved ).
  ENDMETHOD.

  METHOD rejects_orphan_current.
    DATA(lv_saved) = mo_cut->zif_allocation_log_store~save(
      it_current = VALUE #( ( request_id = 'ORPHAN-CURRENT' ) )
      it_history = VALUE #( ) ).

    cl_abap_unit_assert=>assert_false( lv_saved ).
  ENDMETHOD.

  METHOD rejects_orphan_history.
    DATA(lv_saved) = mo_cut->zif_allocation_log_store~save(
      it_current = VALUE #( )
      it_history = VALUE #( ( request_id = 'ORPHAN-HISTORY' ) ) ).

    cl_abap_unit_assert=>assert_false( lv_saved ).
  ENDMETHOD.

  METHOD rejects_misaligned_log_rows.
    DATA(lv_uuid) = cl_system_uuid=>create_uuid_x16_static( ).
    DATA(lv_saved) = mo_cut->zif_allocation_log_store~save(
      it_current = VALUE #( ( request_id = 'CURRENT-REQUEST' ) )
      it_history = VALUE #(
        ( log_uuid   = lv_uuid
          request_id = 'HISTORY-REQUEST' ) ) ).

    cl_abap_unit_assert=>assert_false( lv_saved ).
  ENDMETHOD.

  METHOD rejects_initial_history_uuid.
    DATA(lv_saved) = mo_cut->zif_allocation_log_store~save(
      it_current = VALUE #( ( request_id = 'REQUEST-1' ) )
      it_history = VALUE #( ( request_id = 'REQUEST-1' ) ) ).

    cl_abap_unit_assert=>assert_false( lv_saved ).
  ENDMETHOD.

  METHOD rejects_duplicate_history_uuid.
    DATA(lv_uuid) = cl_system_uuid=>create_uuid_x16_static( ).
    DATA(lv_saved) = mo_cut->zif_allocation_log_store~save(
      it_current = VALUE #(
        ( request_id = 'REQUEST-1' )
        ( request_id = 'REQUEST-2' ) )
      it_history = VALUE #(
        ( log_uuid   = lv_uuid
          request_id = 'REQUEST-1' )
        ( log_uuid   = lv_uuid
          request_id = 'REQUEST-2' ) ) ).

    cl_abap_unit_assert=>assert_false( lv_saved ).
  ENDMETHOD.

  METHOD rejects_invalid_simulation.
    DATA(ls_result) = mo_cut->zif_allocation_history_store~remove_before(
      iv_cutoff_date = '20260801'
      iv_simulation  = 'Y' ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Retention simulation flag must be X or blank' ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-affected_rows
      exp = 0 ).
  ENDMETHOD.

  METHOD rejects_initial_cutoff.
    DATA(ls_result) = mo_cut->zif_allocation_history_store~remove_before(
      iv_cutoff_date = '00000000'
      iv_simulation  = abap_true ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Retention cutoff date must not be initial' ).
  ENDMETHOD.

  METHOD rejects_current_cutoff.
    DATA(ls_result) = mo_cut->zif_allocation_history_store~remove_before(
      iv_cutoff_date = sy-datum
      iv_simulation  = abap_true ).

    cl_abap_unit_assert=>assert_false( ls_result-is_success ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_result-message
      exp = 'Retention cutoff date must be before today' ).
  ENDMETHOD.
ENDCLASS.
