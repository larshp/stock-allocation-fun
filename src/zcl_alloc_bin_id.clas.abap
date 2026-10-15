CLASS zcl_alloc_bin_id DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS build
      IMPORTING
        it_parts         TYPE zcl_alloc_bin_decompose=>ty_parts_tt
      RETURNING
        VALUE(rv_bin_id) TYPE string.

    METHODS normalize
      IMPORTING
        iv_bin_id        TYPE string
      RETURNING
        VALUE(rv_bin_id) TYPE string.

    METHODS is_empty
      IMPORTING
        iv_bin_id       TYPE string
      RETURNING
        VALUE(rv_empty) TYPE abap_bool.

  PRIVATE SECTION.
    CONSTANTS c_sep TYPE string VALUE '-'.

ENDCLASS.


CLASS zcl_alloc_bin_id IMPLEMENTATION.

  METHOD build.
    DATA lv_first TYPE abap_bool VALUE abap_true.

    " Empty parts are skipped so that callers can pass optional segments.
    LOOP AT it_parts INTO DATA(lv_part).
      IF lv_part IS INITIAL.
        CONTINUE.
      ENDIF.

      IF lv_first = abap_true.
        rv_bin_id = lv_part.
        lv_first = abap_false.
      ELSE.
        rv_bin_id = rv_bin_id && c_sep && lv_part.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD normalize.
    rv_bin_id = build( zcl_alloc_bin_decompose=>split( iv_bin_id ) ).
  ENDMETHOD.

  METHOD is_empty.
    rv_empty = xsdbool( normalize( iv_bin_id ) IS INITIAL ).
  ENDMETHOD.

ENDCLASS.
