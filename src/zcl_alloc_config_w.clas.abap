CLASS zcl_alloc_config_w DEFINITION
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

    METHODS put
      IMPORTING
        iv_key   TYPE ty_key
        iv_value TYPE ty_value.

    METHODS get
      IMPORTING
        iv_key          TYPE ty_key
      RETURNING
        VALUE(rv_value) TYPE ty_value.

    METHODS remove
      IMPORTING
        iv_key TYPE ty_key.

    METHODS entries
      RETURNING
        VALUE(rt_entries) TYPE ty_entry_tt.

    METHODS count
      RETURNING
        VALUE(rv_count) TYPE i.

  PRIVATE SECTION.
    DATA mt_entries TYPE ty_entry_tt.

ENDCLASS.


CLASS zcl_alloc_config_w IMPLEMENTATION.

  METHOD put.
    READ TABLE mt_entries ASSIGNING FIELD-SYMBOL(<ls_entry>) WITH KEY key = iv_key.

    IF sy-subrc = 0.
      <ls_entry>-value = iv_value.
    ELSE.
      APPEND VALUE #( key = iv_key value = iv_value ) TO mt_entries.
    ENDIF.
  ENDMETHOD.

  METHOD get.
    DATA ls_entry TYPE ty_entry.

    READ TABLE mt_entries INTO ls_entry WITH KEY key = iv_key.

    IF sy-subrc = 0.
      rv_value = ls_entry-value.
    ENDIF.
  ENDMETHOD.

  METHOD remove.
    DELETE mt_entries WHERE key = iv_key.
  ENDMETHOD.

  METHOD entries.
    rt_entries = mt_entries.
  ENDMETHOD.

  METHOD count.
    rv_count = lines( mt_entries ).
  ENDMETHOD.

ENDCLASS.
