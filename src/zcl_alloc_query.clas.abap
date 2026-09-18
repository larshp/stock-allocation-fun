CLASS zcl_alloc_query DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_param,
             name  TYPE string,
             value TYPE string,
           END OF ty_param.
    TYPES ty_param_tt TYPE STANDARD TABLE OF ty_param WITH DEFAULT KEY.

    METHODS build
      IMPORTING
        it_params       TYPE ty_param_tt
      RETURNING
        VALUE(rv_query) TYPE string.

    METHODS encode
      IMPORTING
        iv_text        TYPE string
      RETURNING
        VALUE(rv_text) TYPE string.

  PRIVATE SECTION.
    CONSTANTS c_space TYPE string VALUE ` `.
    CONSTANTS c_amp   TYPE string VALUE '&'.
    CONSTANTS c_eq    TYPE string VALUE '='.
    CONSTANTS c_quest TYPE string VALUE '?'.
    CONSTANTS c_hash  TYPE string VALUE '#'.
    CONSTANTS c_plus  TYPE string VALUE '+'.
    CONSTANTS c_pct   TYPE string VALUE '%'.

    METHODS char_of
      IMPORTING
        iv_char        TYPE string
      RETURNING
        VALUE(rv_code) TYPE string.

ENDCLASS.


CLASS zcl_alloc_query IMPLEMENTATION.

  METHOD char_of.
    IF iv_char = c_space.
      rv_code = '%20'.
    ELSEIF iv_char = c_amp.
      rv_code = '%26'.
    ELSEIF iv_char = c_eq.
      rv_code = '%3D'.
    ELSEIF iv_char = c_quest.
      rv_code = '%3F'.
    ELSEIF iv_char = c_hash.
      rv_code = '%23'.
    ELSEIF iv_char = c_plus.
      rv_code = '%2B'.
    ELSEIF iv_char = c_pct.
      rv_code = '%25'.
    ELSE.
      rv_code = iv_char.
    ENDIF.
  ENDMETHOD.

  METHOD encode.
    DATA lv_len  TYPE i.
    DATA lv_pos  TYPE i.
    DATA lv_off  TYPE i.
    DATA lv_char TYPE string.

    lv_len = strlen( iv_text ).

    WHILE lv_pos < lv_len.
      lv_pos = lv_pos + 1.
      lv_off = lv_pos - 1.
      lv_char = substring( val = iv_text off = lv_off len = 1 ).

      rv_text = rv_text && char_of( iv_char = lv_char ).
    ENDWHILE.
  ENDMETHOD.

  METHOD build.
    DATA lv_first TYPE abap_bool.

    lv_first = abap_true.

    LOOP AT it_params INTO DATA(ls_param).
      IF lv_first = abap_true.
        lv_first = abap_false.
      ELSE.
        rv_query = rv_query && c_amp.
      ENDIF.

      rv_query = rv_query && encode( iv_text = ls_param-name ).
      rv_query = rv_query && c_eq.
      rv_query = rv_query && encode( iv_text = ls_param-value ).
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
