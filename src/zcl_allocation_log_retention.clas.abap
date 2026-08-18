CLASS zcl_allocation_log_retention DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS gc_default_retention_days TYPE i VALUE 365.

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
    IF iv_retention_days <= 0.
      rs_result-is_success = abap_false.
      rs_result-message = 'Retention days must be greater than zero'.
      RETURN.
    ENDIF.

    DATA(lv_today) = COND d(
      WHEN iv_today IS INITIAL
      THEN sy-datum
      ELSE iv_today ).
    DATA lv_cutoff_date TYPE d.
    lv_cutoff_date = lv_today - iv_retention_days.

    rs_result = mo_store->remove_before(
      iv_cutoff_date = lv_cutoff_date
      iv_simulation  = iv_simulation ).
  ENDMETHOD.
ENDCLASS.
