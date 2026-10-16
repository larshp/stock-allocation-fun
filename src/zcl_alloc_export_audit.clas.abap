CLASS zcl_alloc_export_audit DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_format TYPE c LENGTH 10.
    TYPES ty_user   TYPE c LENGTH 12.
    TYPES ty_object TYPE c LENGTH 30.

    TYPES: BEGIN OF ty_entry,
             seq       TYPE i,
             format    TYPE ty_format,
             user      TYPE ty_user,
             object    TYPE ty_object,
             row_count TYPE i,
           END OF ty_entry.
    TYPES ty_entry_tt TYPE STANDARD TABLE OF ty_entry WITH DEFAULT KEY.

    METHODS log
      IMPORTING
        iv_format       TYPE ty_format
        iv_user         TYPE ty_user
        iv_object       TYPE ty_object
        iv_row_count    TYPE i
      RETURNING
        VALUE(rs_entry) TYPE ty_entry.

    METHODS count
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS format_count
      IMPORTING
        iv_format       TYPE ty_format
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS total_rows
      RETURNING
        VALUE(rv_rows) TYPE i.

  PRIVATE SECTION.
    DATA mt_entries TYPE ty_entry_tt.
    DATA mv_seq     TYPE i.

ENDCLASS.


CLASS zcl_alloc_export_audit IMPLEMENTATION.

  METHOD log.
    DATA ls_entry TYPE ty_entry.

    mv_seq = mv_seq + 1.

    ls_entry-seq = mv_seq.
    ls_entry-format = iv_format.
    ls_entry-user = iv_user.
    ls_entry-object = iv_object.
    ls_entry-row_count = iv_row_count.

    APPEND ls_entry TO mt_entries.

    rs_entry = ls_entry.
  ENDMETHOD.

  METHOD count.
    rv_count = lines( mt_entries ).
  ENDMETHOD.

  METHOD format_count.
    DATA ls_entry TYPE ty_entry.

    LOOP AT mt_entries INTO ls_entry.
      IF ls_entry-format = iv_format.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD total_rows.
    DATA ls_entry TYPE ty_entry.

    LOOP AT mt_entries INTO ls_entry.
      rv_rows = rv_rows + ls_entry-row_count.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
