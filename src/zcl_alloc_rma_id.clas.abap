CLASS zcl_alloc_rma_id DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS next
      RETURNING
        VALUE(rv_id) TYPE string.

    METHODS reset.

    METHODS is_valid
      IMPORTING
        iv_id        TYPE string
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

  PRIVATE SECTION.
    CONSTANTS c_prefix TYPE string VALUE 'RMA'.
    CONSTANTS c_width  TYPE i VALUE 8.

    DATA mv_seq TYPE i.

    METHODS pad
      IMPORTING
        iv_value       TYPE i
      RETURNING
        VALUE(rv_text) TYPE string.

ENDCLASS.


CLASS zcl_alloc_rma_id IMPLEMENTATION.

  METHOD next.
    mv_seq = mv_seq + 1.
    rv_id = c_prefix && pad( mv_seq ).
  ENDMETHOD.

  METHOD reset.
    CLEAR mv_seq.
  ENDMETHOD.

  METHOD is_valid.
    DATA lv_len  TYPE i.
    DATA lv_off  TYPE i.
    DATA lv_char TYPE string.

    lv_len = strlen( iv_id ).
    IF lv_len <> strlen( c_prefix ) + c_width.
      RETURN.
    ENDIF.

    IF substring( val = iv_id off = 0 len = strlen( c_prefix ) ) <> c_prefix.
      RETURN.
    ENDIF.

    lv_off = strlen( c_prefix ).
    WHILE lv_off < lv_len.
      lv_char = substring( val = iv_id off = lv_off len = 1 ).

      IF lv_char < '0' OR lv_char > '9'.
        RETURN.
      ENDIF.

      lv_off = lv_off + 1.
    ENDWHILE.

    rv_ok = abap_true.
  ENDMETHOD.

  METHOD pad.
    DATA lv_text  TYPE string.
    DATA lv_zeros TYPE i.

    lv_text = |{ iv_value }|.

    IF strlen( lv_text ) < c_width.
      lv_zeros = c_width - strlen( lv_text ).
      WHILE lv_zeros > 0.
        lv_text = '0' && lv_text.
        lv_zeros = lv_zeros - 1.
      ENDWHILE.
    ENDIF.

    rv_text = lv_text.
  ENDMETHOD.

ENDCLASS.
