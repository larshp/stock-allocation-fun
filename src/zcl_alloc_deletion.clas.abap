CLASS zcl_alloc_deletion DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_run_id TYPE c LENGTH 20.

    TYPES: BEGIN OF ty_candidate,
             run_id      TYPE ty_run_id,
             archived_on TYPE d,
           END OF ty_candidate.
    TYPES ty_candidate_tt TYPE STANDARD TABLE OF ty_candidate WITH DEFAULT KEY.
    TYPES ty_run_id_tt    TYPE STANDARD TABLE OF ty_run_id WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_request,
             retention TYPE i,
             reference TYPE d,
             protected TYPE ty_run_id,
           END OF ty_request.

    METHODS propose
      IMPORTING
        it_candidates    TYPE ty_candidate_tt
        is_request       TYPE ty_request
      RETURNING
        VALUE(rt_delete) TYPE ty_run_id_tt.

ENDCLASS.


CLASS zcl_alloc_deletion IMPLEMENTATION.

  METHOD propose.
    DATA lo_retention TYPE REF TO zcl_alloc_retention.
    DATA ls_candidate TYPE ty_candidate.
    DATA lv_expired   TYPE abap_bool.

    lo_retention = NEW zcl_alloc_retention( iv_retention_days = is_request-retention ).

    LOOP AT it_candidates INTO ls_candidate.
      IF ls_candidate-run_id IS NOT INITIAL AND ls_candidate-run_id <> is_request-protected.
        lv_expired = lo_retention->is_expired( iv_archived_on = ls_candidate-archived_on
                                               iv_reference   = is_request-reference ).

        IF lv_expired = abap_true.
          APPEND ls_candidate-run_id TO rt_delete.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
