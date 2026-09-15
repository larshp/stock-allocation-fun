CLASS zcl_alloc_ref_cache DEFINITION
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

    METHODS put
      IMPORTING
        iv_key   TYPE ty_key
        iv_value TYPE ty_value.

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

    METHODS reset.

    METHODS count
      RETURNING
        VALUE(rv_count) TYPE i.

  PRIVATE SECTION.
    DATA mt_entries TYPE ty_entry_tt.

ENDCLASS.


CLASS zcl_alloc_ref_cache IMPLEMENTATION.

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

  METHOD has.
    DATA ls_entry TYPE ty_entry.

    READ TABLE mt_entries INTO ls_entry WITH KEY key = iv_key.

    IF sy-subrc = 0.
      rv_has = abap_true.
    ELSE.
      rv_has = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD reset.
    CLEAR mt_entries.
  ENDMETHOD.

  METHOD count.
    rv_count = lines( mt_entries ).
  ENDMETHOD.

ENDCLASS.
