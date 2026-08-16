CLASS zcl_stock_allocation_watch DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_alert,
        run_id                 TYPE zif_allocation_audit=>ty_run_id,
        strategy               TYPE zif_allocation_audit=>ty_strategy,
        preview                TYPE abap_bool,
        adaptive_branch        TYPE c LENGTH 10,
        movement_type          TYPE zif_stock_allocation=>ty_movement_type,
        min_shelf_life         TYPE i,
        safety_stock           TYPE zif_stock_allocation=>ty_quantity,
        requested_on_from      TYPE d,
        requested_on_to        TYPE d,
        requested_deadline     TYPE d,
        deadline_age_days      TYPE i,
        deadline_age_available TYPE abap_bool,
        deadline_age_ref       TYPE d,
        requested_sort_date    TYPE d,
        horizon_available      TYPE abap_bool,
        unit                   TYPE zif_stock_allocation=>ty_unit,
        start_date             TYPE d,
        start_time             TYPE t,
        age_seconds            TYPE i,
        available              TYPE zif_stock_allocation=>ty_quantity,
        requested              TYPE zif_stock_allocation=>ty_quantity,
        allocated              TYPE zif_stock_allocation=>ty_quantity,
        shortage               TYPE zif_stock_allocation=>ty_quantity,
        coverage               TYPE zif_allocation_audit=>ty_coverage,
        coverage_available     TYPE abap_bool,
        shortage_pct           TYPE zif_allocation_audit=>ty_coverage,
        shortage_pct_available TYPE abap_bool,
        demand_count           TYPE i,
        full_count             TYPE i,
        partial_count          TYPE i,
        unallocated_count      TYPE i,
        full_mix_pct           TYPE zif_allocation_audit=>ty_coverage,
        partial_mix_pct        TYPE zif_allocation_audit=>ty_coverage,
        unallocated_mix_pct    TYPE zif_allocation_audit=>ty_coverage,
        message                TYPE zif_allocation_audit=>ty_message,
      END OF ty_alert.
    TYPES tt_alerts TYPE STANDARD TABLE OF ty_alert WITH EMPTY KEY.
    TYPES:
      BEGIN OF ty_unit_summary,
        unit                        TYPE string,
        mixed_units                 TYPE abap_bool,
        demand_count                TYPE i,
        preview_runs                TYPE i,
        operational_runs            TYPE i,
        preview_mix_pct             TYPE zif_allocation_audit=>ty_coverage,
        operational_mix_pct         TYPE zif_allocation_audit=>ty_coverage,
        full_count                  TYPE i,
        partial_count               TYPE i,
        unallocated_count           TYPE i,
        full_mix_pct                TYPE zif_allocation_audit=>ty_coverage,
        partial_mix_pct             TYPE zif_allocation_audit=>ty_coverage,
        unallocated_mix_pct         TYPE zif_allocation_audit=>ty_coverage,
        deadline_count              TYPE i,
        deadline_mix_pct            TYPE zif_allocation_audit=>ty_coverage,
        overdue_count               TYPE i,
        current_deadline_count      TYPE i,
        future_deadline_count       TYPE i,
        overdue_mix_pct             TYPE zif_allocation_audit=>ty_coverage,
        current_deadline_mix_pct    TYPE zif_allocation_audit=>ty_coverage,
        future_deadline_mix_pct     TYPE zif_allocation_audit=>ty_coverage,
        weighted_strategy_runs      TYPE i,
        weighted_requested          TYPE zif_stock_allocation=>ty_quantity,
        weighted_allocated          TYPE zif_stock_allocation=>ty_quantity,
        weighted_shortage           TYPE zif_stock_allocation=>ty_quantity,
        total_available             TYPE zif_stock_allocation=>ty_quantity,
        total_requested             TYPE zif_stock_allocation=>ty_quantity,
        total_allocated             TYPE zif_stock_allocation=>ty_quantity,
        total_shortage              TYPE zif_stock_allocation=>ty_quantity,
        oldest_age_seconds          TYPE i,
        newest_age_seconds          TYPE i,
        earliest_requested_deadline TYPE d,
        latest_requested_deadline   TYPE d,
        oldest_deadline_age_days    TYPE i,
        newest_deadline_age_days    TYPE i,
        oldest_deadline_urgency     TYPE string,
        newest_deadline_urgency     TYPE string,
        deadline_age_reference_date TYPE d,
        deadline_age_mixed          TYPE abap_bool,
      END OF ty_unit_summary.

    CLASS-METHODS summarize_units
      IMPORTING
        it_alerts         TYPE tt_alerts
      RETURNING
        VALUE(rs_summary) TYPE ty_unit_summary.

    CLASS-METHODS sort_and_limit
      IMPORTING
        iv_sort_by_shortage     TYPE abap_bool
        iv_sort_by_coverage     TYPE abap_bool OPTIONAL
        iv_sort_by_shrt_pct     TYPE abap_bool OPTIONAL
        iv_sort_by_demand_count TYPE abap_bool OPTIONAL
        iv_sort_by_deadline_age TYPE abap_bool OPTIONAL
        iv_sort_by_due          TYPE abap_bool OPTIONAL
        iv_sort_by_newest       TYPE abap_bool OPTIONAL
        iv_max                  TYPE i
        iv_offset               TYPE i OPTIONAL
      CHANGING
        ct_alerts               TYPE tt_alerts.
ENDCLASS.

CLASS zcl_stock_allocation_watch IMPLEMENTATION.
  METHOD summarize_units.
    DATA lv_unit TYPE zif_stock_allocation=>ty_unit.
    DATA lv_deadline_age_initialized TYPE abap_bool.
    DATA lv_reference_initialized TYPE abap_bool.
    LOOP AT it_alerts ASSIGNING FIELD-SYMBOL(<ls_alert>).
      IF lv_reference_initialized = abap_false.
        rs_summary-deadline_age_reference_date =
          <ls_alert>-deadline_age_ref.
        lv_reference_initialized = abap_true.
      ELSEIF rs_summary-deadline_age_mixed = abap_false
          AND rs_summary-deadline_age_reference_date
             <> <ls_alert>-deadline_age_ref.
        rs_summary-deadline_age_mixed = abap_true.
        CLEAR rs_summary-deadline_age_reference_date.
      ENDIF.
      lv_unit = to_upper( <ls_alert>-unit ).
      rs_summary-demand_count = rs_summary-demand_count
        + <ls_alert>-demand_count.
      rs_summary-full_count = rs_summary-full_count
        + <ls_alert>-full_count.
      rs_summary-partial_count = rs_summary-partial_count
        + <ls_alert>-partial_count.
      rs_summary-unallocated_count = rs_summary-unallocated_count
        + <ls_alert>-unallocated_count.
      IF <ls_alert>-preview = abap_true.
        rs_summary-preview_runs = rs_summary-preview_runs + 1.
      ELSE.
        rs_summary-operational_runs =
          rs_summary-operational_runs + 1.
      ENDIF.
      IF <ls_alert>-strategy = 'W'.
        rs_summary-weighted_strategy_runs =
          rs_summary-weighted_strategy_runs + 1.
        rs_summary-weighted_requested = rs_summary-weighted_requested
          + <ls_alert>-requested.
        rs_summary-weighted_allocated = rs_summary-weighted_allocated
          + <ls_alert>-allocated.
        rs_summary-weighted_shortage = rs_summary-weighted_shortage
          + <ls_alert>-shortage.
      ENDIF.
      rs_summary-total_available = rs_summary-total_available
        + <ls_alert>-available.
      rs_summary-total_requested = rs_summary-total_requested
        + <ls_alert>-requested.
      rs_summary-total_allocated = rs_summary-total_allocated
        + <ls_alert>-allocated.
      rs_summary-total_shortage = rs_summary-total_shortage
        + <ls_alert>-shortage.
      IF sy-tabix = 1 OR <ls_alert>-age_seconds > rs_summary-oldest_age_seconds.
        rs_summary-oldest_age_seconds = <ls_alert>-age_seconds.
      ENDIF.
      IF sy-tabix = 1 OR <ls_alert>-age_seconds < rs_summary-newest_age_seconds.
        rs_summary-newest_age_seconds = <ls_alert>-age_seconds.
      ENDIF.
      IF <ls_alert>-requested_deadline IS NOT INITIAL.
        rs_summary-deadline_count = rs_summary-deadline_count + 1.
        IF <ls_alert>-deadline_age_days > 0.
          rs_summary-overdue_count = rs_summary-overdue_count + 1.
        ELSEIF <ls_alert>-deadline_age_days = 0.
          rs_summary-current_deadline_count =
            rs_summary-current_deadline_count + 1.
        ELSE.
          rs_summary-future_deadline_count =
            rs_summary-future_deadline_count + 1.
        ENDIF.
        IF lv_deadline_age_initialized = abap_false.
          rs_summary-oldest_deadline_age_days =
            <ls_alert>-deadline_age_days.
          rs_summary-newest_deadline_age_days =
            <ls_alert>-deadline_age_days.
          lv_deadline_age_initialized = abap_true.
        ELSEIF <ls_alert>-deadline_age_days
            > rs_summary-oldest_deadline_age_days.
          rs_summary-oldest_deadline_age_days =
            <ls_alert>-deadline_age_days.
        ELSEIF <ls_alert>-deadline_age_days
            < rs_summary-newest_deadline_age_days.
          rs_summary-newest_deadline_age_days =
            <ls_alert>-deadline_age_days.
        ENDIF.
        IF rs_summary-earliest_requested_deadline IS INITIAL
            OR <ls_alert>-requested_deadline
               < rs_summary-earliest_requested_deadline.
          rs_summary-earliest_requested_deadline =
            <ls_alert>-requested_deadline.
        ENDIF.
        IF rs_summary-latest_requested_deadline IS INITIAL
            OR <ls_alert>-requested_deadline
               > rs_summary-latest_requested_deadline.
          rs_summary-latest_requested_deadline =
            <ls_alert>-requested_deadline.
        ENDIF.
      ENDIF.
      IF sy-tabix = 1.
        rs_summary-unit = lv_unit.
      ELSEIF lv_unit <> rs_summary-unit.
        rs_summary-mixed_units = abap_true.
      ENDIF.
    ENDLOOP.

    IF rs_summary-demand_count > 0.
      rs_summary-full_mix_pct = rs_summary-full_count * 100
        / rs_summary-demand_count.
      rs_summary-partial_mix_pct = rs_summary-partial_count * 100
        / rs_summary-demand_count.
      rs_summary-unallocated_mix_pct = rs_summary-unallocated_count * 100
        / rs_summary-demand_count.
    ENDIF.

    IF lines( it_alerts ) > 0.
      rs_summary-preview_mix_pct = rs_summary-preview_runs * 100
        / lines( it_alerts ).
      rs_summary-operational_mix_pct = rs_summary-operational_runs * 100
        / lines( it_alerts ).
      rs_summary-deadline_mix_pct = rs_summary-deadline_count * 100
        / lines( it_alerts ).
      rs_summary-overdue_mix_pct = rs_summary-overdue_count * 100
        / lines( it_alerts ).
      rs_summary-current_deadline_mix_pct =
        rs_summary-current_deadline_count * 100 / lines( it_alerts ).
      rs_summary-future_deadline_mix_pct = rs_summary-future_deadline_count * 100
        / lines( it_alerts ).
    ENDIF.

    IF lv_deadline_age_initialized = abap_false.
      rs_summary-oldest_deadline_urgency = 'n/a'.
      rs_summary-newest_deadline_urgency = 'n/a'.
    ELSEIF rs_summary-oldest_deadline_age_days > 0.
      rs_summary-oldest_deadline_urgency = 'overdue'.
      IF rs_summary-newest_deadline_age_days > 0.
        rs_summary-newest_deadline_urgency = 'overdue'.
      ELSEIF rs_summary-newest_deadline_age_days = 0.
        rs_summary-newest_deadline_urgency = 'current_day'.
      ELSE.
        rs_summary-newest_deadline_urgency = 'future'.
      ENDIF.
    ELSEIF rs_summary-oldest_deadline_age_days = 0.
      rs_summary-oldest_deadline_urgency = 'current_day'.
      IF rs_summary-newest_deadline_age_days = 0.
        rs_summary-newest_deadline_urgency = 'current_day'.
      ELSE.
        rs_summary-newest_deadline_urgency = 'future'.
      ENDIF.
    ELSE.
      rs_summary-oldest_deadline_urgency = 'future'.
      rs_summary-newest_deadline_urgency = 'future'.
    ENDIF.

    IF lines( it_alerts ) = 0.
      rs_summary-unit = 'n/a'.
    ELSEIF rs_summary-mixed_units = abap_true.
      rs_summary-unit = 'mixed'.
      CLEAR: rs_summary-total_available,
             rs_summary-total_requested,
             rs_summary-total_allocated,
             rs_summary-total_shortage,
             rs_summary-weighted_requested,
             rs_summary-weighted_allocated,
             rs_summary-weighted_shortage.
    ENDIF.
  ENDMETHOD.

  METHOD sort_and_limit.
    FIELD-SYMBOLS <ls_alert> TYPE ty_alert.

    IF iv_sort_by_due = abap_true.
      LOOP AT ct_alerts ASSIGNING <ls_alert>.
        IF <ls_alert>-requested_on_from IS INITIAL.
          <ls_alert>-requested_sort_date = <ls_alert>-requested_on_to.
        ELSE.
          <ls_alert>-requested_sort_date = <ls_alert>-requested_on_from.
        ENDIF.
        <ls_alert>-horizon_available = xsdbool(
          <ls_alert>-requested_sort_date IS NOT INITIAL ).
      ENDLOOP.
    ENDIF.

    IF iv_sort_by_coverage = abap_true.
      SORT ct_alerts BY coverage_available DESCENDING coverage ASCENDING
                        age_seconds DESCENDING start_date ASCENDING
                        start_time ASCENDING run_id ASCENDING.
    ELSEIF iv_sort_by_shrt_pct = abap_true.
      SORT ct_alerts BY shortage_pct_available DESCENDING shortage_pct DESCENDING
                        shortage DESCENDING age_seconds DESCENDING
                        start_date ASCENDING start_time ASCENDING
                        run_id ASCENDING.
    ELSEIF iv_sort_by_demand_count = abap_true.
      SORT ct_alerts BY demand_count DESCENDING shortage DESCENDING
                        age_seconds DESCENDING start_date ASCENDING
                        start_time ASCENDING run_id ASCENDING.
    ELSEIF iv_sort_by_deadline_age = abap_true.
      SORT ct_alerts BY deadline_age_available DESCENDING
                        deadline_age_days DESCENDING requested_deadline ASCENDING
                        shortage DESCENDING age_seconds DESCENDING
                        start_date ASCENDING start_time ASCENDING
                        run_id ASCENDING.
    ELSEIF iv_sort_by_due = abap_true.
      SORT ct_alerts BY horizon_available DESCENDING
                        requested_sort_date ASCENDING requested_on_to ASCENDING
                        shortage DESCENDING age_seconds DESCENDING
                        start_date ASCENDING start_time ASCENDING
                        run_id ASCENDING.
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
