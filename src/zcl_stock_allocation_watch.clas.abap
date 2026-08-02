CLASS zcl_stock_allocation_watch DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_alert,
        run_id             TYPE zif_allocation_audit=>ty_run_id,
        strategy           TYPE zif_allocation_audit=>ty_strategy,
        unit               TYPE zif_stock_allocation=>ty_unit,
        start_date         TYPE d,
        start_time         TYPE t,
        age_seconds        TYPE i,
        available          TYPE zif_stock_allocation=>ty_quantity,
        requested          TYPE zif_stock_allocation=>ty_quantity,
        allocated          TYPE zif_stock_allocation=>ty_quantity,
        shortage           TYPE zif_stock_allocation=>ty_quantity,
        coverage           TYPE zif_allocation_audit=>ty_coverage,
        coverage_available TYPE abap_bool,
        demand_count       TYPE i,
        message            TYPE zif_allocation_audit=>ty_message,
      END OF ty_alert.
    TYPES tt_alerts TYPE STANDARD TABLE OF ty_alert WITH EMPTY KEY.

    CLASS-METHODS sort_and_limit
      IMPORTING
        iv_sort_by_shortage TYPE abap_bool
        iv_sort_by_coverage TYPE abap_bool OPTIONAL
        iv_sort_by_newest   TYPE abap_bool OPTIONAL
        iv_max              TYPE i
        iv_offset           TYPE i OPTIONAL
      CHANGING
        ct_alerts           TYPE tt_alerts.
ENDCLASS.

CLASS zcl_stock_allocation_watch IMPLEMENTATION.
  METHOD sort_and_limit.
    FIELD-SYMBOLS <ls_alert> TYPE ty_alert.

    IF iv_sort_by_coverage = abap_true.
      SORT ct_alerts BY coverage_available DESCENDING coverage ASCENDING
                        age_seconds DESCENDING start_date ASCENDING
                        start_time ASCENDING run_id ASCENDING.
    ELSEIF iv_sort_by_shortage = abap_true.
      SORT ct_alerts BY shortage DESCENDING age_seconds DESCENDING
                        start_date ASCENDING start_time ASCENDING
                        run_id ASCENDING.
    ELSEIF iv_sort_by_newest = abap_true.
      SORT ct_alerts BY age_seconds ASCENDING start_date DESCENDING
                        start_time DESCENDING run_id ASCENDING.
    ELSE.
      SORT ct_alerts BY age_seconds DESCENDING start_date ASCENDING
                        start_time ASCENDING run_id ASCENDING.
    ENDIF.

    IF iv_offset > 0.
      IF iv_offset >= lines( ct_alerts ).
        CLEAR ct_alerts.
      ELSE.
        DELETE ct_alerts FROM 1 TO iv_offset.
      ENDIF.
    ENDIF.

    IF iv_max > 0.
      LOOP AT ct_alerts ASSIGNING <ls_alert>.
        IF sy-tabix > iv_max.
          DELETE ct_alerts.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.
ENDCLASS.
