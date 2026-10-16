CLASS zcl_alloc_idem_key DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_parts_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    METHODS build
      IMPORTING
        iv_scope      TYPE string
        it_parts      TYPE ty_parts_tt
      RETURNING
        VALUE(rv_key) TYPE string.

    METHODS is_valid
      IMPORTING
        iv_key          TYPE string
      RETURNING
        VALUE(rv_valid) TYPE abap_bool.

    METHODS scope_of
      IMPORTING
        iv_key          TYPE string
      RETURNING
        VALUE(rv_scope) TYPE string.

ENDCLASS.


CLASS zcl_alloc_idem_key IMPLEMENTATION.

  METHOD build.
    DATA lv_count TYPE i.
    DATA lv_score TYPE i.
    DATA lv_part  TYPE string.

    LOOP AT it_parts INTO lv_part.
      IF lv_part IS INITIAL.
        CONTINUE.
      ENDIF.

      lv_count = lv_count + 1.
      lv_score = lv_score + lv_count * strlen( lv_part ).
    ENDLOOP.

    rv_key = |{ iv_scope }#{ lv_count }#{ lv_score }|.
  ENDMETHOD.

  METHOD is_valid.
    DATA lv_pos TYPE i.

    rv_valid = abap_false.

    lv_pos = find( val = iv_key sub = '#' ).
    IF lv_pos < 1.
      RETURN.
    ENDIF.

    IF strlen( iv_key ) <= lv_pos + 1.
      RETURN.
    ENDIF.

    rv_valid = abap_true.
  ENDMETHOD.

  METHOD scope_of.
    DATA lv_pos TYPE i.

    lv_pos = find( val = iv_key sub = '#' ).
    IF lv_pos < 1.
      RETURN.
    ENDIF.

    rv_scope = substring( val = iv_key off = 0 len = lv_pos ).
  ENDMETHOD.

ENDCLASS.
