CLASS zcl_alloc_once DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_entry,
             entry_key TYPE string,
           END OF ty_entry.
    TYPES ty_entry_tt TYPE STANDARD TABLE OF ty_entry WITH DEFAULT KEY.

    METHODS run
      IMPORTING
        iv_key          TYPE string
      RETURNING
        VALUE(rv_first) TYPE abap_bool.

    METHODS has_run
      IMPORTING
        iv_key        TYPE string
      RETURNING
        VALUE(rv_ran) TYPE abap_bool.

    METHODS count
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS reset.

  PRIVATE SECTION.
    DATA mt_entries TYPE ty_entry_tt.

ENDCLASS.


CLASS zcl_alloc_once IMPLEMENTATION.

  METHOD run.
    DATA ls_entry TYPE ty_entry.

    READ TABLE mt_entries INTO ls_entry WITH KEY entry_key = iv_key.
    IF sy-subrc = 0.
      rv_first = abap_false.
      RETURN.
    ENDIF.

    ls_entry-entry_key = iv_key.
    APPEND ls_entry TO mt_entries.
    rv_first = abap_true.
  ENDMETHOD.

  METHOD has_run.
    DATA ls_entry TYPE ty_entry.

    READ TABLE mt_entries INTO ls_entry WITH KEY entry_key = iv_key.
    IF sy-subrc = 0.
      rv_ran = abap_true.
    ELSE.
      rv_ran = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD count.
    rv_count = lines( mt_entries ).
  ENDMETHOD.

  METHOD reset.
    CLEAR mt_entries.
  ENDMETHOD.

ENDCLASS.
