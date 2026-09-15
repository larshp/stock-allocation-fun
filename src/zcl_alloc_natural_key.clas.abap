CLASS zcl_alloc_natural_key DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    CONSTANTS c_width TYPE i VALUE 20.

    TYPES ty_fields_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    METHODS compose
      IMPORTING
        it_fields     TYPE ty_fields_tt
      RETURNING
        VALUE(rv_key) TYPE string.

    METHODS field_count
      IMPORTING
        iv_key          TYPE string
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS field_at
      IMPORTING
        iv_key          TYPE string
        iv_index        TYPE i
      RETURNING
        VALUE(rv_field) TYPE string.

  PRIVATE SECTION.
    METHODS pad
      IMPORTING
        iv_text        TYPE string
      RETURNING
        VALUE(rv_text) TYPE string.

    METHODS trim_right
      IMPORTING
        iv_text        TYPE string
      RETURNING
        VALUE(rv_text) TYPE string.

ENDCLASS.


CLASS zcl_alloc_natural_key IMPLEMENTATION.

  METHOD compose.
    DATA lv_field TYPE string.
    DATA lv_pad   TYPE string.

    LOOP AT it_fields INTO lv_field.
      lv_pad = me->pad( lv_field ).
      rv_key = rv_key && lv_pad.
    ENDLOOP.
  ENDMETHOD.

  METHOD field_count.
    rv_count = strlen( iv_key ) DIV c_width.
  ENDMETHOD.

  METHOD field_at.
    DATA lv_start TYPE i.
    DATA lv_rest  TYPE i.
    DATA lv_part  TYPE string.

    IF iv_index <= 0.
      RETURN.
    ENDIF.

    lv_start = ( iv_index - 1 ) * c_width.

    IF lv_start >= strlen( iv_key ).
      RETURN.
    ENDIF.

    lv_rest = strlen( iv_key ) - lv_start.

    IF lv_rest > c_width.
      lv_rest = c_width.
    ENDIF.

    lv_part = substring( val = iv_key off = lv_start len = lv_rest ).
    rv_field = me->trim_right( lv_part ).
  ENDMETHOD.

  METHOD pad.
    DATA lv_len   TYPE i.
    DATA lv_space TYPE string.

    lv_space = ` `.
    rv_text = iv_text.
    lv_len = c_width - strlen( iv_text ).

    WHILE lv_len > 0.
      rv_text = rv_text && lv_space.
      lv_len = lv_len - 1.
    ENDWHILE.

    IF strlen( rv_text ) > c_width.
      rv_text = substring( val = rv_text off = 0 len = c_width ).
    ENDIF.
  ENDMETHOD.

  METHOD trim_right.
    DATA lv_space TYPE string.
    DATA lv_end   TYPE i.
    DATA lv_off   TYPE i.
    DATA lv_char  TYPE string.

    lv_space = ` `.
    lv_end = strlen( iv_text ).

    WHILE lv_end > 0.
      lv_off = lv_end - 1.
      lv_char = substring( val = iv_text off = lv_off len = 1 ).

      IF lv_char <> lv_space.
        EXIT.
      ENDIF.

      lv_end = lv_end - 1.
    ENDWHILE.

    rv_text = substring( val = iv_text off = 0 len = lv_end ).
  ENDMETHOD.

ENDCLASS.
