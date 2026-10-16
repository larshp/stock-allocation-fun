CLASS zcl_alloc_bin_id_parse DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_result,
             valid TYPE abap_bool,
             parts TYPE zcl_alloc_bin_decompose=>ty_parts_tt,
           END OF ty_result.

    METHODS parse
      IMPORTING
        iv_bin_id         TYPE string
        iv_expected_parts TYPE i
      RETURNING
        VALUE(rs_result)  TYPE ty_result.

    METHODS is_valid
      IMPORTING
        iv_bin_id         TYPE string
        iv_expected_parts TYPE i
      RETURNING
        VALUE(rv_valid)   TYPE abap_bool.

    METHODS segment_count
      IMPORTING
        iv_bin_id       TYPE string
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_bin_id_parse IMPLEMENTATION.

  METHOD parse.
    rs_result-parts = zcl_alloc_bin_decompose=>split( iv_bin_id ).
    rs_result-valid = is_valid( iv_bin_id         = iv_bin_id
                                iv_expected_parts = iv_expected_parts ).
  ENDMETHOD.

  METHOD is_valid.
    DATA lt_parts TYPE zcl_alloc_bin_decompose=>ty_parts_tt.

    IF iv_expected_parts <= 0.
      RETURN.
    ENDIF.

    lt_parts = zcl_alloc_bin_decompose=>split( iv_bin_id ).
    rv_valid = xsdbool( lines( lt_parts ) = iv_expected_parts ).
  ENDMETHOD.

  METHOD segment_count.
    rv_count = zcl_alloc_bin_decompose=>part_count( iv_bin_id ).
  ENDMETHOD.

ENDCLASS.
