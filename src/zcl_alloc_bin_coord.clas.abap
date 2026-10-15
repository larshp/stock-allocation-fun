CLASS zcl_alloc_bin_coord DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_coord,
             aisle TYPE i,
             rack  TYPE i,
             level TYPE i,
           END OF ty_coord.

    METHODS same_aisle
      IMPORTING
        is_a           TYPE ty_coord
        is_b           TYPE ty_coord
      RETURNING
        VALUE(rv_same) TYPE abap_bool.

    METHODS compare
      IMPORTING
        is_a          TYPE ty_coord
        is_b          TYPE ty_coord
      RETURNING
        VALUE(rv_cmp) TYPE i.

ENDCLASS.


CLASS zcl_alloc_bin_coord IMPLEMENTATION.

  METHOD same_aisle.
    rv_same = xsdbool( is_a-aisle = is_b-aisle ).
  ENDMETHOD.

  METHOD compare.
    " Lexicographic order: aisle first, then rack, then level, so sorting by the
    " comparison walks the warehouse in a sensible order.
    IF is_a-aisle < is_b-aisle.
      rv_cmp = -1.
      RETURN.
    ELSEIF is_a-aisle > is_b-aisle.
      rv_cmp = 1.
      RETURN.
    ENDIF.

    IF is_a-rack < is_b-rack.
      rv_cmp = -1.
      RETURN.
    ELSEIF is_a-rack > is_b-rack.
      rv_cmp = 1.
      RETURN.
    ENDIF.

    IF is_a-level < is_b-level.
      rv_cmp = -1.
      RETURN.
    ELSEIF is_a-level > is_b-level.
      rv_cmp = 1.
      RETURN.
    ENDIF.

    rv_cmp = 0.
  ENDMETHOD.

ENDCLASS.
