CLASS zcl_alloc_bin_distance DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_coord_tt TYPE STANDARD TABLE OF zcl_alloc_bin_coord=>ty_coord
                      WITH DEFAULT KEY.

    METHODS manhattan
      IMPORTING
        is_a           TYPE zcl_alloc_bin_coord=>ty_coord
        is_b           TYPE zcl_alloc_bin_coord=>ty_coord
      RETURNING
        VALUE(rv_dist) TYPE i.

    METHODS chebyshev
      IMPORTING
        is_a           TYPE zcl_alloc_bin_coord=>ty_coord
        is_b           TYPE zcl_alloc_bin_coord=>ty_coord
      RETURNING
        VALUE(rv_dist) TYPE i.

    METHODS aisle_gap
      IMPORTING
        is_a           TYPE zcl_alloc_bin_coord=>ty_coord
        is_b           TYPE zcl_alloc_bin_coord=>ty_coord
      RETURNING
        VALUE(rv_dist) TYPE i.

  PRIVATE SECTION.
    METHODS absolute
      IMPORTING
        iv_value      TYPE i
      RETURNING
        VALUE(rv_abs) TYPE i.

ENDCLASS.


CLASS zcl_alloc_bin_distance IMPLEMENTATION.

  METHOD absolute.
    IF iv_value < 0.
      rv_abs = 0 - iv_value.
    ELSE.
      rv_abs = iv_value.
    ENDIF.
  ENDMETHOD.

  METHOD manhattan.
    rv_dist = absolute( iv_value = is_a-aisle - is_b-aisle )
              + absolute( iv_value = is_a-rack - is_b-rack )
              + absolute( iv_value = is_a-level - is_b-level ).
  ENDMETHOD.

  METHOD chebyshev.
    DATA lv_best TYPE i.
    DATA lv_gap  TYPE i.

    lv_best = absolute( iv_value = is_a-aisle - is_b-aisle ).

    lv_gap = absolute( iv_value = is_a-rack - is_b-rack ).
    IF lv_gap > lv_best.
      lv_best = lv_gap.
    ENDIF.

    lv_gap = absolute( iv_value = is_a-level - is_b-level ).
    IF lv_gap > lv_best.
      lv_best = lv_gap.
    ENDIF.

    rv_dist = lv_best.
  ENDMETHOD.

  METHOD aisle_gap.
    rv_dist = absolute( iv_value = is_a-aisle - is_b-aisle ).
  ENDMETHOD.

ENDCLASS.
