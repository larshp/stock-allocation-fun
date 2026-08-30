CLASS zcl_allocation_log_retention DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS gc_default_retention_days TYPE i VALUE 365.
    CONSTANTS gc_max_retention_days TYPE i VALUE 36500.

    METHODS constructor
      IMPORTING
        io_store TYPE REF TO zif_allocation_history_store.

    CLASS-METHODS create_sap
      RETURNING
        VALUE(ro_retention) TYPE REF TO zcl_allocation_log_retention.

    METHODS run
      IMPORTING
        iv_retention_days TYPE i DEFAULT gc_default_retention_days
        iv_simulation     TYPE abap_bool DEFAULT abap_true
        iv_today          TYPE d OPTIONAL
      RETURNING
        VALUE(rs_result)  TYPE zif_allocation_history_store=>ty_result.

  PRIVATE SECTION.
    DATA mo_store TYPE REF TO zif_allocation_history_store.
ENDCLASS.

CLASS zcl_allocation_log_retention IMPLEMENTATION.
  METHOD constructor.
    mo_store = io_store.
  ENDMETHOD.

  METHOD create_sap.
    DATA(lo_store) = NEW zcl_allocation_log_store_sap( ).
    ro_retention = NEW #( lo_store ).
  ENDMETHOD.

  METHOD run.
    IF iv_simulation <> abap_false AND iv_simulation <> abap_true.
      rs_result-is_success = abap_false.
      rs_result-message = 'Retention simulation flag must be X or blank'.
      RETURN.
    ENDIF.
    IF iv_retention_days <= 0
        OR iv_retention_days > gc_max_retention_days.
      rs_result-is_success = abap_false.
      rs_result-message = 'Retention days must be between 1 and 36500'.
      RETURN.
    ENDIF.

    DATA(lv_today) = COND d(
      WHEN iv_today IS INITIAL
      THEN sy-datum
      ELSE iv_today ).
    IF lv_today > sy-datum.
      rs_result-is_success = abap_false.
      rs_result-message = 'Retention effective date must not be in the future'.
      RETURN.
    ENDIF.
    DATA lv_cutoff_date TYPE d.
    lv_cutoff_date = lv_today - iv_retention_days.

    IF mo_store IS NOT BOUND.
      rs_result-is_success = abap_false.
      rs_result-message = 'Retention store is required'.
      RETURN.
    ENDIF.

    DATA(ls_store_result) = mo_store->remove_before(
      iv_cutoff_date = lv_cutoff_date
      iv_simulation  = iv_simulation ).
    IF ( ls_store_result-is_success <> abap_false
          AND ls_store_result-is_success <> abap_true )
        OR ls_store_result-affected_rows < 0
        OR ( ls_store_result-is_success = abap_false
          AND ls_store_result-affected_rows <> 0 ).
      rs_result-is_success = abap_false.
      rs_result-message = 'Retention store returned invalid state'.
      RETURN.
    ENDIF.
    IF ls_store_result-is_success = abap_false
        AND ls_store_result-message IS INITIAL.
      rs_result = ls_store_result.
      rs_result-message = 'Retention cleanup failed'.
      RETURN.
    ENDIF.
    rs_result = ls_store_result.
  ENDMETHOD.
ENDCLASS.
