CLASS zcl_alloc_return_advice DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_field,
             name  TYPE string,
             value TYPE string,
           END OF ty_field.
    TYPES ty_field_tt TYPE STANDARD TABLE OF ty_field WITH DEFAULT KEY.

    METHODS build
      IMPORTING
        it_fields         TYPE ty_field_tt
      RETURNING
        VALUE(rv_message) TYPE string.

    METHODS field_count
      IMPORTING
        it_fields       TYPE ty_field_tt
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_return_advice IMPLEMENTATION.

  METHOD build.
    DATA lv_first TYPE abap_bool.

    " The advice joins the named fields into one "name=value; name=value" text.
    LOOP AT it_fields INTO DATA(ls_field).
      IF ls_field-name IS INITIAL.
        CONTINUE.
      ENDIF.

      IF lv_first = abap_false.
        lv_first = abap_true.
      ELSE.
        rv_message = |{ rv_message }; |.
      ENDIF.

      rv_message = |{ rv_message }{ ls_field-name }={ ls_field-value }|.
    ENDLOOP.
  ENDMETHOD.

  METHOD field_count.
    LOOP AT it_fields INTO DATA(ls_field).
      IF ls_field-name IS NOT INITIAL.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
