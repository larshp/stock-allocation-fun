CLASS zcl_alloc_audit DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_kind   TYPE c LENGTH 12.
    TYPES ty_run_id TYPE c LENGTH 20.
    TYPES ty_detail TYPE c LENGTH 60.

    TYPES: BEGIN OF ty_entry,
             seq    TYPE i,
             kind   TYPE ty_kind,
             run_id TYPE ty_run_id,
             detail TYPE ty_detail,
           END OF ty_entry.
    TYPES ty_entry_tt TYPE STANDARD TABLE OF ty_entry WITH DEFAULT KEY.

    METHODS add
      IMPORTING
        iv_kind         TYPE ty_kind
        iv_run_id       TYPE ty_run_id
        iv_detail       TYPE ty_detail
      RETURNING
        VALUE(rs_entry) TYPE ty_entry.

    METHODS count
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS of_run
      IMPORTING
        iv_run_id         TYPE ty_run_id
      RETURNING
        VALUE(rt_entries) TYPE ty_entry_tt.

    METHODS entries
      RETURNING
        VALUE(rt_entries) TYPE ty_entry_tt.

  PRIVATE SECTION.
    DATA mt_entries TYPE ty_entry_tt.
    DATA mv_seq     TYPE i.

ENDCLASS.


CLASS zcl_alloc_audit IMPLEMENTATION.

  METHOD add.
    DATA ls_entry TYPE ty_entry.

    mv_seq = mv_seq + 1.

    ls_entry-seq = mv_seq.
    ls_entry-kind = iv_kind.
    ls_entry-run_id = iv_run_id.
    ls_entry-detail = iv_detail.

    APPEND ls_entry TO mt_entries.

    rs_entry = ls_entry.
  ENDMETHOD.

  METHOD count.
    rv_count = lines( mt_entries ).
  ENDMETHOD.

  METHOD entries.
    rt_entries = mt_entries.
  ENDMETHOD.

  METHOD of_run.
    DATA ls_entry TYPE ty_entry.

    LOOP AT mt_entries INTO ls_entry.
      IF ls_entry-run_id = iv_run_id.
        APPEND ls_entry TO rt_entries.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
