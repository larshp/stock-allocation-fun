CLASS zcl_alloc_sort DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_mode TYPE c LENGTH 1.

    METHODS sort
      IMPORTING
        it_overview      TYPE zcl_alloc_run_report=>ty_overview_tt
        iv_mode          TYPE ty_mode DEFAULT 'R'
      RETURNING
        VALUE(rt_sorted) TYPE zcl_alloc_run_report=>ty_overview_tt.

ENDCLASS.


CLASS zcl_alloc_sort IMPLEMENTATION.

  METHOD sort.
    rt_sorted = it_overview.

    IF iv_mode = 'M'.
      SORT rt_sorted BY matnr ASCENDING
                       werks ASCENDING.
    ELSEIF iv_mode = 'C'.
      SORT rt_sorted BY coverage_pct DESCENDING
                       run_id ASCENDING.
    ELSEIF iv_mode = 'S'.
      SORT rt_sorted BY shortage_qty DESCENDING
                       run_id ASCENDING.
    ELSE.
      SORT rt_sorted BY run_id ASCENDING
                       matnr ASCENDING.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
