CLASS zcl_alloc_upsert DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_key   TYPE c LENGTH 20.
    TYPES ty_value TYPE c LENGTH 40.

    TYPES: BEGIN OF ty_entry,
             key   TYPE ty_key,
             value TYPE ty_value,
           END OF ty_entry.
    TYPES ty_entry_tt TYPE STANDARD TABLE OF ty_entry WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_result,
             inserted TYPE i,
             updated  TYPE i,
           END OF ty_result.

    METHODS upsert
      IMPORTING
        it_entries       TYPE ty_entry_tt
      RETURNING
        VALUE(rs_result) TYPE ty_result.

    METHODS entries
      RETURNING
        VALUE(rt_entries) TYPE ty_entry_tt.

    METHODS count
      RETURNING
        VALUE(rv_count) TYPE i.

  PRIVATE SECTION.
    DATA mt_entries TYPE ty_entry_tt.

ENDCLASS.


CLASS zcl_alloc_upsert IMPLEMENTATION.

  METHOD upsert.
    DATA ls_entry TYPE ty_entry.

    LOOP AT it_entries INTO ls_entry.
      READ TABLE mt_entries ASSIGNING FIELD-SYMBOL(<ls_target>)
        WITH KEY key = ls_entry-key.

      IF sy-subrc = 0.
        <ls_target>-value = ls_entry-value.
        rs_result-updated = rs_result-updated + 1.
      ELSE.
        APPEND ls_entry TO mt_entries.
        rs_result-inserted = rs_result-inserted + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD entries.
    rt_entries = mt_entries.
  ENDMETHOD.

  METHOD count.
    rv_count = lines( mt_entries ).
  ENDMETHOD.

ENDCLASS.
