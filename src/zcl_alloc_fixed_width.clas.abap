CLASS zcl_alloc_fixed_width DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_field_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.
    TYPES ty_width_tt TYPE STANDARD TABLE OF i WITH DEFAULT KEY.

    METHODS pad
      IMPORTING
        iv_value        TYPE string
        iv_width        TYPE i
      RETURNING
        VALUE(rv_value) TYPE string.

    METHODS build_line
      IMPORTING
        it_fields      TYPE ty_field_tt
        it_widths      TYPE ty_width_tt
      RETURNING
        VALUE(rv_line) TYPE string.

ENDCLASS.


CLASS zcl_alloc_fixed_width IMPLEMENTATION.

  METHOD pad.
    DATA lv_short TYPE string.

    rv_value = iv_value.
    IF iv_width <= 0.
      RETURN.
    ENDIF.

    IF strlen( rv_value ) > iv_width.
      lv_short = substring( val = rv_value
                            len = iv_width ).
      rv_value = lv_short.
    ENDIF.

    WHILE strlen( rv_value ) < iv_width.
      rv_value = rv_value && ` `.
    ENDWHILE.
  ENDMETHOD.

  METHOD build_line.
    DATA lv_field TYPE string.
    DATA lv_width TYPE i.
    DATA lv_index TYPE i.
    DATA lv_part  TYPE string.

    CLEAR rv_line.
    lv_index = 1.

    LOOP AT it_fields INTO lv_field.
      READ TABLE it_widths INTO lv_width INDEX lv_index.
      IF sy-subrc <> 0.
        lv_width = 0.
      ENDIF.
      lv_part = pad( iv_value = lv_field
                     iv_width = lv_width ).
      rv_line = rv_line && lv_part.
      lv_index = lv_index + 1.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
