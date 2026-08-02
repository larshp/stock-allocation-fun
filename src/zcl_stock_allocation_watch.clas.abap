CLASS zcl_stock_allocation_watch DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    TYPES:
      BEGIN OF ty_alert,
        run_id       TYPE zif_allocation_audit=>ty_run_id,
        strategy     TYPE zif_allocation_audit=>ty_strategy,
        unit         TYPE zif_stock_allocation=>ty_unit,
        start_date   TYPE d,
        start_time   TYPE t,
        age_seconds  TYPE i,
        available    TYPE zif_stock_allocation=>ty_quantity,
        requested    TYPE zif_stock_allocation=>ty_quantity,
        allocated    TYPE zif_stock_allocation=>ty_quantity,
        shortage     TYPE zif_stock_allocation=>ty_quantity,
        demand_count TYPE i,
        message      TYPE zif_allocation_audit=>ty_message,
      END OF ty_alert.
    TYPES tt_alerts TYPE STANDARD TABLE OF ty_alert WITH EMPTY KEY.

    CLASS-METHODS sort_and_limit
      IMPORTING
        iv_sort_by_shortage TYPE abap_bool
        iv_max              TYPE i
      CHANGING
        ct_alerts           TYPE tt_alerts.
ENDCLASS.

CLASS zcl_stock_allocation_watch IMPLEMENTATION.
  METHOD sort_and_limit.
    FIELD-SYMBOLS <ls_alert> TYPE ty_alert.

    IF iv_sort_by_shortage = abap_true.
      SORT ct_alerts BY shortage DESCENDING age_seconds DESCENDING
                        start_date ASCENDING start_time ASCENDING
                        run_id ASCENDING.
    ELSE.
      SORT ct_alerts BY age_seconds DESCENDING start_date ASCENDING
                        start_time ASCENDING run_id ASCENDING.
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
