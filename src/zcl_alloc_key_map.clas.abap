CLASS zcl_alloc_key_map DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_entry,
             entry_key TYPE string,
             value     TYPE menge_d,
           END OF ty_entry.
    TYPES ty_entry_tt TYPE HASHED TABLE OF ty_entry WITH UNIQUE KEY entry_key.

    METHODS put
      IMPORTING
        iv_key   TYPE string
        iv_value TYPE menge_d.

    METHODS add
      IMPORTING
        iv_key   TYPE string
        iv_delta TYPE menge_d.

    METHODS get
      IMPORTING
        iv_key          TYPE string
      RETURNING
        VALUE(rv_value) TYPE menge_d.

    METHODS has
      IMPORTING
        iv_key            TYPE string
      RETURNING
        VALUE(rv_present) TYPE abap_bool.

    METHODS remove
      IMPORTING
        iv_key TYPE string.

    METHODS size
      RETURNING
        VALUE(rv_size) TYPE i.

    METHODS entries
      RETURNING
        VALUE(rt_entries) TYPE ty_entry_tt.

    METHODS visits
      RETURNING
        VALUE(rv_visits) TYPE i.

    METHODS reset.

  PRIVATE SECTION.
    DATA mt_entries TYPE ty_entry_tt.
    DATA mv_visits  TYPE i.

    METHODS bump
      IMPORTING
        iv_key   TYPE string
        iv_delta TYPE menge_d.

ENDCLASS.


CLASS zcl_alloc_key_map IMPLEMENTATION.

  METHOD put.
    DATA ls_entry TYPE ty_entry.

    " One hash lookup, then either an in-place value change or one hash insert,
    " so the cost per call does not grow with the number of keys.
    mv_visits = mv_visits + 1.

    READ TABLE mt_entries ASSIGNING FIELD-SYMBOL(<ls_entry>)
      WITH KEY entry_key = iv_key.
    IF sy-subrc = 0.
      <ls_entry>-value = iv_value.
      RETURN.
    ENDIF.

    ls_entry-entry_key = iv_key.
    ls_entry-value = iv_value.
    INSERT ls_entry INTO TABLE mt_entries.
  ENDMETHOD.

  METHOD bump.
    DATA ls_entry TYPE ty_entry.

    " Delete and re-insert on update, which is the move-to-the-end behaviour the
    " read/delete/append callers had, so the output order is unchanged.
    mv_visits = mv_visits + 1.

    READ TABLE mt_entries INTO ls_entry WITH KEY entry_key = iv_key.
    IF sy-subrc = 0.
      ls_entry-value = ls_entry-value + iv_delta.
      DELETE TABLE mt_entries FROM ls_entry.
      INSERT ls_entry INTO TABLE mt_entries.
      RETURN.
    ENDIF.

    ls_entry-entry_key = iv_key.
    ls_entry-value = iv_delta.
    INSERT ls_entry INTO TABLE mt_entries.
  ENDMETHOD.

  METHOD add.
    bump( iv_key   = iv_key
          iv_delta = iv_delta ).
  ENDMETHOD.

  METHOD get.
    DATA ls_entry TYPE ty_entry.

    mv_visits = mv_visits + 1.

    READ TABLE mt_entries INTO ls_entry WITH KEY entry_key = iv_key.
    IF sy-subrc = 0.
      rv_value = ls_entry-value.
    ENDIF.
  ENDMETHOD.

  METHOD has.
    DATA ls_entry TYPE ty_entry.

    mv_visits = mv_visits + 1.

    READ TABLE mt_entries INTO ls_entry WITH KEY entry_key = iv_key.
    rv_present = xsdbool( sy-subrc = 0 ).
  ENDMETHOD.

  METHOD remove.
    mv_visits = mv_visits + 1.

    READ TABLE mt_entries ASSIGNING FIELD-SYMBOL(<ls_entry>)
      WITH KEY entry_key = iv_key.
    IF sy-subrc = 0.
      DELETE TABLE mt_entries FROM <ls_entry>.
    ENDIF.
  ENDMETHOD.

  METHOD size.
    rv_size = lines( mt_entries ).
  ENDMETHOD.

  METHOD entries.
    rt_entries = mt_entries.
  ENDMETHOD.

  METHOD visits.
    rv_visits = mv_visits.
  ENDMETHOD.

  METHOD reset.
    CLEAR mt_entries.
    CLEAR mv_visits.
  ENDMETHOD.

ENDCLASS.
