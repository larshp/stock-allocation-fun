CLASS zcl_alloc_access_log DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_user   TYPE c LENGTH 12.
    TYPES ty_object TYPE c LENGTH 30.
    TYPES ty_action TYPE c LENGTH 10.

    TYPES: BEGIN OF ty_entry,
             seq    TYPE i,
             user   TYPE ty_user,
             object TYPE ty_object,
             action TYPE ty_action,
           END OF ty_entry.
    TYPES ty_entry_tt TYPE STANDARD TABLE OF ty_entry WITH DEFAULT KEY.

    METHODS log
      IMPORTING
        iv_user         TYPE ty_user
        iv_object       TYPE ty_object
        iv_action       TYPE ty_action
      RETURNING
        VALUE(rs_entry) TYPE ty_entry.

    METHODS count
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS count_of_user
      IMPORTING
        iv_user         TYPE ty_user
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS entries
      RETURNING
        VALUE(rt_entries) TYPE ty_entry_tt.

  PRIVATE SECTION.
    DATA mt_entries TYPE ty_entry_tt.
    DATA mv_seq     TYPE i.

ENDCLASS.


CLASS zcl_alloc_access_log IMPLEMENTATION.

  METHOD log.
    DATA ls_entry TYPE ty_entry.

    mv_seq = mv_seq + 1.

    ls_entry-seq = mv_seq.
    ls_entry-user = iv_user.
    ls_entry-object = iv_object.
    ls_entry-action = iv_action.

    APPEND ls_entry TO mt_entries.

    rs_entry = ls_entry.
  ENDMETHOD.

  METHOD count.
    rv_count = lines( mt_entries ).
  ENDMETHOD.

  METHOD count_of_user.
    DATA ls_entry TYPE ty_entry.

    LOOP AT mt_entries INTO ls_entry.
      IF ls_entry-user = iv_user.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD entries.
    rt_entries = mt_entries.
  ENDMETHOD.

ENDCLASS.
