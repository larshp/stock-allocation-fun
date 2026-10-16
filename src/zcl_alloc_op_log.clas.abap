CLASS zcl_alloc_op_log DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_name   TYPE c LENGTH 20.
    TYPES ty_status TYPE c LENGTH 1.

    TYPES: BEGIN OF ty_entry,
             seq         TYPE i,
             name        TYPE ty_name,
             status      TYPE ty_status,
             duration_ms TYPE i,
           END OF ty_entry.
    TYPES ty_entry_tt TYPE STANDARD TABLE OF ty_entry WITH DEFAULT KEY.

    METHODS add
      IMPORTING
        iv_name         TYPE ty_name
        iv_duration_ms  TYPE i
        iv_ok           TYPE abap_bool
      RETURNING
        VALUE(rs_entry) TYPE ty_entry.

    METHODS count
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS errors
      RETURNING
        VALUE(rt_entries) TYPE ty_entry_tt.

    METHODS total_ms
      RETURNING
        VALUE(rv_ms) TYPE i.

    METHODS slowest
      RETURNING
        VALUE(rv_name) TYPE ty_name.

  PRIVATE SECTION.
    DATA mt_entries TYPE ty_entry_tt.
    DATA mv_seq     TYPE i.

ENDCLASS.


CLASS zcl_alloc_op_log IMPLEMENTATION.

  METHOD add.
    DATA ls_entry TYPE ty_entry.

    mv_seq = mv_seq + 1.

    ls_entry-seq = mv_seq.
    ls_entry-name = iv_name.
    ls_entry-duration_ms = iv_duration_ms.

    IF iv_ok = abap_true.
      ls_entry-status = 'S'.
    ELSE.
      ls_entry-status = 'E'.
    ENDIF.

    APPEND ls_entry TO mt_entries.

    rs_entry = ls_entry.
  ENDMETHOD.

  METHOD count.
    rv_count = lines( mt_entries ).
  ENDMETHOD.

  METHOD errors.
    DATA ls_entry TYPE ty_entry.

    LOOP AT mt_entries INTO ls_entry.
      IF ls_entry-status = 'E'.
        APPEND ls_entry TO rt_entries.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD total_ms.
    DATA ls_entry TYPE ty_entry.

    rv_ms = 0.

    LOOP AT mt_entries INTO ls_entry.
      rv_ms = rv_ms + ls_entry-duration_ms.
    ENDLOOP.
  ENDMETHOD.

  METHOD slowest.
    DATA ls_entry TYPE ty_entry.
    DATA lv_max    TYPE i.

    LOOP AT mt_entries INTO ls_entry.
      IF ls_entry-duration_ms > lv_max.
        lv_max = ls_entry-duration_ms.
        rv_name = ls_entry-name.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
