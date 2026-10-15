CLASS zcl_alloc_dedupe_win DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_entry,
             entry_key TYPE string,
             stamp     TYPE i,
           END OF ty_entry.
    TYPES ty_entry_tt TYPE STANDARD TABLE OF ty_entry WITH DEFAULT KEY.

    METHODS is_duplicate
      IMPORTING
        iv_key              TYPE string
        iv_stamp            TYPE i
        iv_window           TYPE i
      RETURNING
        VALUE(rv_duplicate) TYPE abap_bool.

    METHODS purge_before
      IMPORTING
        iv_cutoff TYPE i.

    METHODS count
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS reset.

  PRIVATE SECTION.
    " The window is checked once per key, so a hashed store keeps that check
    " constant time instead of scanning every seen key.
    TYPES ty_store_tt TYPE HASHED TABLE OF ty_entry WITH UNIQUE KEY entry_key.

    DATA mt_entries TYPE ty_store_tt.

ENDCLASS.


CLASS zcl_alloc_dedupe_win IMPLEMENTATION.

  METHOD is_duplicate.
    DATA ls_entry TYPE ty_entry.

    rv_duplicate = abap_false.

    READ TABLE mt_entries ASSIGNING FIELD-SYMBOL(<ls_entry>)
      WITH KEY entry_key = iv_key.
    IF sy-subrc = 0.
      IF iv_stamp - <ls_entry>-stamp <= iv_window.
        rv_duplicate = abap_true.
        RETURN.
      ENDIF.

      " Refresh the stamp of the key that is no longer inside the window.
      <ls_entry>-stamp = iv_stamp.
      RETURN.
    ENDIF.

    ls_entry-entry_key = iv_key.
    ls_entry-stamp = iv_stamp.
    INSERT ls_entry INTO TABLE mt_entries.
  ENDMETHOD.

  METHOD purge_before.
    DELETE mt_entries WHERE stamp < iv_cutoff.
  ENDMETHOD.

  METHOD count.
    rv_count = lines( mt_entries ).
  ENDMETHOD.

  METHOD reset.
    CLEAR mt_entries.
  ENDMETHOD.

ENDCLASS.
