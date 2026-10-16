CLASS zcl_alloc_config DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_key   TYPE c LENGTH 30.
    TYPES ty_value TYPE c LENGTH 60.

    TYPES: BEGIN OF ty_entry,
             key   TYPE ty_key,
             value TYPE ty_value,
           END OF ty_entry.
    TYPES ty_entry_tt TYPE STANDARD TABLE OF ty_entry WITH DEFAULT KEY.
    TYPES ty_key_tt   TYPE STANDARD TABLE OF ty_key WITH DEFAULT KEY.

    METHODS constructor
      IMPORTING
        it_entries TYPE ty_entry_tt.

    METHODS get
      IMPORTING
        iv_key          TYPE ty_key
      RETURNING
        VALUE(rv_value) TYPE ty_value.

    METHODS has
      IMPORTING
        iv_key        TYPE ty_key
      RETURNING
        VALUE(rv_has) TYPE abap_bool.

    METHODS count
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS keys
      RETURNING
        VALUE(rt_keys) TYPE ty_key_tt.

  PRIVATE SECTION.
    DATA mt_entries TYPE ty_entry_tt.

ENDCLASS.


CLASS zcl_alloc_config IMPLEMENTATION.

  METHOD constructor.
    mt_entries = it_entries.
  ENDMETHOD.

  METHOD get.
    DATA ls_entry TYPE ty_entry.

    READ TABLE mt_entries INTO ls_entry WITH KEY key = iv_key.

    IF sy-subrc = 0.
      rv_value = ls_entry-value.
    ENDIF.
  ENDMETHOD.

  METHOD has.
    DATA ls_entry TYPE ty_entry.

    READ TABLE mt_entries INTO ls_entry WITH KEY key = iv_key.

    IF sy-subrc = 0.
      rv_has = abap_true.
    ELSE.
      rv_has = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD count.
    rv_count = lines( mt_entries ).
  ENDMETHOD.

  METHOD keys.
    DATA ls_entry TYPE ty_entry.

    LOOP AT mt_entries INTO ls_entry.
      APPEND ls_entry-key TO rt_keys.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
