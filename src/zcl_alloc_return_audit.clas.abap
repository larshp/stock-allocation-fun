CLASS zcl_alloc_return_audit DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_entry,
             action    TYPE string,
             user_name TYPE string,
           END OF ty_entry.
    TYPES ty_entry_tt TYPE STANDARD TABLE OF ty_entry WITH DEFAULT KEY.

    METHODS record
      IMPORTING
        it_entries        TYPE ty_entry_tt
        iv_action         TYPE string
        iv_user           TYPE string
      RETURNING
        VALUE(rt_entries) TYPE ty_entry_tt.

    METHODS entries
      IMPORTING
        it_entries      TYPE ty_entry_tt
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS last_action
      IMPORTING
        it_entries       TYPE ty_entry_tt
      RETURNING
        VALUE(rv_action) TYPE string.

ENDCLASS.


CLASS zcl_alloc_return_audit IMPLEMENTATION.

  METHOD record.
    DATA ls_entry TYPE ty_entry.

    " A named action joins the trail; anything else leaves it as it was.
    rt_entries = it_entries.

    IF iv_action IS INITIAL.
      RETURN.
    ENDIF.

    ls_entry-action = iv_action.
    ls_entry-user_name = iv_user.
    APPEND ls_entry TO rt_entries.
  ENDMETHOD.

  METHOD entries.
    rv_count = lines( it_entries ).
  ENDMETHOD.

  METHOD last_action.
    LOOP AT it_entries INTO DATA(ls_entry).
      rv_action = ls_entry-action.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
