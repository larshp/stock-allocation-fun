CLASS zcl_alloc_serial_gen DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_text_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    METHODS generate
      IMPORTING
        iv_number        TYPE i
        iv_width         TYPE i
        iv_prefix        TYPE string
      RETURNING
        VALUE(rv_serial) TYPE string.

    METHODS generate_range
      IMPORTING
        iv_from           TYPE i
        iv_count          TYPE i
        iv_width          TYPE i
        iv_prefix         TYPE string
      RETURNING
        VALUE(rt_serials) TYPE ty_text_tt.

    METHODS set_next
      IMPORTING
        iv_number TYPE i.

    METHODS next_serial
      IMPORTING
        iv_width         TYPE i
        iv_prefix        TYPE string
      RETURNING
        VALUE(rv_serial) TYPE string.

  PRIVATE SECTION.
    DATA mv_next TYPE i.

ENDCLASS.


CLASS zcl_alloc_serial_gen IMPLEMENTATION.

  METHOD generate.
    DATA lv_text TYPE string.
    DATA lv_pad  TYPE i.

    IF iv_number < 0.
      RETURN.
    ENDIF.

    " The string template formats the number (a plain assignment would keep it a
    " number, see ANOMALIES.md A31) and the zeros are then prepended to the width.
    lv_text = |{ iv_number }|.

    IF iv_width > 0.
      lv_pad = iv_width - strlen( lv_text ).
      WHILE lv_pad > 0.
        lv_text = '0' && lv_text.
        lv_pad = lv_pad - 1.
      ENDWHILE.
    ENDIF.

    rv_serial = iv_prefix && lv_text.
  ENDMETHOD.

  METHOD generate_range.
    DATA lv_number TYPE i.
    DATA lv_index  TYPE i.

    IF iv_count <= 0 OR iv_from < 0.
      RETURN.
    ENDIF.

    lv_number = iv_from.

    WHILE lv_index < iv_count.
      lv_index = lv_index + 1.
      APPEND generate( iv_number = lv_number
                       iv_width  = iv_width
                       iv_prefix = iv_prefix ) TO rt_serials.
      lv_number = lv_number + 1.
    ENDWHILE.
  ENDMETHOD.

  METHOD set_next.
    IF iv_number >= 0.
      mv_next = iv_number.
    ENDIF.
  ENDMETHOD.

  METHOD next_serial.
    rv_serial = generate( iv_number = mv_next
                          iv_width  = iv_width
                          iv_prefix = iv_prefix ).
    mv_next = mv_next + 1.
  ENDMETHOD.

ENDCLASS.
