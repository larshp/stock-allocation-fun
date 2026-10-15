CLASS zcl_alloc_recon_match DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             key    TYPE string,
             amount TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS matches
      IMPORTING
        it_left      TYPE ty_line_tt
        it_right     TYPE ty_line_tt
        iv_key       TYPE string
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS is_matched
      IMPORTING
        iv_amount_a  TYPE i
        iv_amount_b  TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS key_of
      IMPORTING
        iv_prefix     TYPE string
        iv_index      TYPE i
      RETURNING
        VALUE(rv_key) TYPE string.

ENDCLASS.


CLASS zcl_alloc_recon_match IMPLEMENTATION.

  METHOD matches.
    DATA lv_left TYPE i.
    DATA lv_right TYPE i.
    DATA lv_found_left TYPE abap_bool.
    DATA lv_found_right TYPE abap_bool.

    " The two sides match for a key when they carry the same amount.
    LOOP AT it_left INTO DATA(ls_left).
      IF ls_left-key = iv_key.
        lv_left = ls_left-amount.
        lv_found_left = abap_true.
      ENDIF.
    ENDLOOP.

    LOOP AT it_right INTO DATA(ls_right).
      IF ls_right-key = iv_key.
        lv_right = ls_right-amount.
        lv_found_right = abap_true.
      ENDIF.
    ENDLOOP.

    IF lv_found_left = abap_false OR lv_found_right = abap_false.
      RETURN.
    ENDIF.

    rv_ok = xsdbool( lv_left = lv_right ).
  ENDMETHOD.

  METHOD is_matched.
    " Two amounts match once they are equal.
    rv_ok = xsdbool( iv_amount_a = iv_amount_b ).
  ENDMETHOD.

  METHOD key_of.
    " A key is built from a prefix and a running index.
    rv_key = |{ iv_prefix }-{ iv_index }|.
  ENDMETHOD.

ENDCLASS.
