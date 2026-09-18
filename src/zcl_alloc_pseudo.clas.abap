CLASS zcl_alloc_pseudo DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_value TYPE c LENGTH 40.
    TYPES ty_id    TYPE string.

    TYPES: BEGIN OF ty_map,
             id    TYPE ty_id,
             value TYPE ty_value,
           END OF ty_map.
    TYPES ty_map_tt TYPE STANDARD TABLE OF ty_map WITH DEFAULT KEY.

    METHODS pseudonymize
      IMPORTING
        iv_value     TYPE ty_value
        iv_salt      TYPE ty_value
      RETURNING
        VALUE(rv_id) TYPE ty_id.

    METHODS resolve
      IMPORTING
        iv_id           TYPE ty_id
      RETURNING
        VALUE(rv_value) TYPE ty_value.

    METHODS is_pseudonym
      IMPORTING
        iv_id         TYPE ty_id
      RETURNING
        VALUE(rv_yes) TYPE abap_bool.

    METHODS count
      RETURNING
        VALUE(rv_count) TYPE i.

  PRIVATE SECTION.
    DATA mt_map TYPE ty_map_tt.

    METHODS checksum
      IMPORTING
        iv_text       TYPE ty_value
        iv_salt       TYPE ty_value
      RETURNING
        VALUE(rv_sum) TYPE i.

ENDCLASS.


CLASS zcl_alloc_pseudo IMPLEMENTATION.

  METHOD checksum.
    DATA lv_alphabet TYPE string.
    DATA lv_source   TYPE string.
    DATA lv_len      TYPE i.
    DATA lv_i        TYPE i.
    DATA lv_off      TYPE i.
    DATA lv_char     TYPE string.
    DATA lv_pos      TYPE i.

    lv_alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'.
    lv_source = iv_text && iv_salt.

    lv_len = strlen( lv_source ).

    DO lv_len TIMES.
      lv_i = lv_i + 1.
      lv_off = lv_i - 1.
      lv_char = substring( val = lv_source off = lv_off len = 1 ).
      lv_pos = find( val = lv_alphabet sub = lv_char ).

      IF lv_pos < 0.
        lv_pos = 0.
      ENDIF.

      rv_sum = rv_sum + lv_pos * lv_i.

      IF rv_sum > 100000.
        rv_sum = rv_sum - 100000.
      ENDIF.
    ENDDO.
  ENDMETHOD.

  METHOD pseudonymize.
    DATA lv_sum TYPE i.
    DATA ls_map TYPE ty_map.

    lv_sum = me->checksum( iv_text = iv_value iv_salt = iv_salt ).
    rv_id = |PSN-{ lv_sum }|.

    READ TABLE mt_map INTO ls_map WITH KEY id = rv_id.

    IF sy-subrc <> 0.
      ls_map-id = rv_id.
      ls_map-value = iv_value.
      APPEND ls_map TO mt_map.
    ENDIF.
  ENDMETHOD.

  METHOD resolve.
    DATA ls_map TYPE ty_map.

    READ TABLE mt_map INTO ls_map WITH KEY id = iv_id.

    IF sy-subrc = 0.
      rv_value = ls_map-value.
    ENDIF.
  ENDMETHOD.

  METHOD is_pseudonym.
    IF find( val = iv_id sub = 'PSN-' ) = 0.
      rv_yes = abap_true.
    ELSE.
      rv_yes = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD count.
    rv_count = lines( mt_map ).
  ENDMETHOD.

ENDCLASS.
