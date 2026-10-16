CLASS zcl_alloc_qr_payload DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_field,
             field_key   TYPE string,
             field_value TYPE string,
           END OF ty_field.
    TYPES ty_field_tt TYPE STANDARD TABLE OF ty_field WITH DEFAULT KEY.

    METHODS build
      IMPORTING
        it_fields         TYPE ty_field_tt
        iv_separator      TYPE string
      RETURNING
        VALUE(rv_payload) TYPE string.

    METHODS count
      IMPORTING
        it_fields       TYPE ty_field_tt
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_qr_payload IMPLEMENTATION.

  METHOD build.
    DATA lv_first TYPE abap_bool VALUE abap_true.
    DATA lv_pair  TYPE string.

    " Each field becomes KEY=VALUE and the pairs are joined by the caller's
    " separator. A field without a key is skipped, so a half-built record cannot
    " produce a stray '='.
    LOOP AT it_fields INTO DATA(ls_field).
      IF ls_field-field_key IS INITIAL.
        CONTINUE.
      ENDIF.

      lv_pair = |{ ls_field-field_key }={ ls_field-field_value }|.

      IF lv_first = abap_true.
        rv_payload = lv_pair.
        lv_first = abap_false.
      ELSE.
        rv_payload = rv_payload && iv_separator && lv_pair.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD count.
    LOOP AT it_fields INTO DATA(ls_field).
      IF ls_field-field_key IS NOT INITIAL.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
