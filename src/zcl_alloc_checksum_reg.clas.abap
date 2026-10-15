CLASS zcl_alloc_checksum_reg DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_entry,
             object_key TYPE string,
             checksum   TYPE i,
           END OF ty_entry.
    TYPES ty_entry_tt TYPE STANDARD TABLE OF ty_entry WITH DEFAULT KEY.

    METHODS register
      IMPORTING
        iv_key      TYPE string
        iv_checksum TYPE i.

    METHODS verify
      IMPORTING
        iv_key          TYPE string
        iv_checksum     TYPE i
      RETURNING
        VALUE(rv_match) TYPE abap_bool.

    METHODS checksum_of
      IMPORTING
        iv_key             TYPE string
      RETURNING
        VALUE(rv_checksum) TYPE i.

    METHODS count
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS reset.

  PRIVATE SECTION.
    " Object keys are looked up once per write and once per read, so a hashed
    " store keeps the register constant time per entry instead of scanning the
    " whole table.
    TYPES ty_store_tt TYPE HASHED TABLE OF ty_entry WITH UNIQUE KEY object_key.

    DATA mt_entries TYPE ty_store_tt.

ENDCLASS.


CLASS zcl_alloc_checksum_reg IMPLEMENTATION.

  METHOD register.
    DATA ls_entry TYPE ty_entry.

    READ TABLE mt_entries ASSIGNING FIELD-SYMBOL(<ls_entry>)
      WITH KEY object_key = iv_key.
    IF sy-subrc = 0.
      <ls_entry>-checksum = iv_checksum.
      RETURN.
    ENDIF.

    ls_entry-object_key = iv_key.
    ls_entry-checksum = iv_checksum.
    INSERT ls_entry INTO TABLE mt_entries.
  ENDMETHOD.

  METHOD verify.
    rv_match = abap_false.

    READ TABLE mt_entries INTO DATA(ls_entry) WITH KEY object_key = iv_key.
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    IF ls_entry-checksum = iv_checksum.
      rv_match = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD checksum_of.
    READ TABLE mt_entries INTO DATA(ls_entry) WITH KEY object_key = iv_key.
    IF sy-subrc = 0.
      rv_checksum = ls_entry-checksum.
    ENDIF.
  ENDMETHOD.

  METHOD count.
    rv_count = lines( mt_entries ).
  ENDMETHOD.

  METHOD reset.
    CLEAR mt_entries.
  ENDMETHOD.

ENDCLASS.
