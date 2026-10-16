CLASS zcl_alloc_scale_guard DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_measure,
             size TYPE i,
             work TYPE i,
           END OF ty_measure.
    TYPES ty_measure_tt TYPE STANDARD TABLE OF ty_measure WITH DEFAULT KEY.

    METHODS ratio_x100
      IMPORTING
        iv_small       TYPE i
        iv_large       TYPE i
      RETURNING
        VALUE(rv_x100) TYPE i.

    METHODS classify
      IMPORTING
        is_small         TYPE ty_measure
        is_large         TYPE ty_measure
      RETURNING
        VALUE(rv_growth) TYPE string.

  PRIVATE SECTION.
    CONSTANTS c_linear   TYPE string VALUE 'linear'.
    CONSTANTS c_near     TYPE string VALUE 'near_linear'.
    CONSTANTS c_quadric  TYPE string VALUE 'quadratic'.
    CONSTANTS c_unknown  TYPE string VALUE 'unknown'.
    CONSTANTS c_tolerance TYPE i VALUE 200.

ENDCLASS.


CLASS zcl_alloc_scale_guard IMPLEMENTATION.

  METHOD ratio_x100.
    IF iv_small <= 0.
      RETURN.
    ENDIF.

    rv_x100 = iv_large * 100 DIV iv_small.
  ENDMETHOD.

  METHOD classify.
    DATA lv_size_ratio TYPE i.
    DATA lv_work_ratio TYPE i.
    DATA lv_allowed    TYPE i.

    IF is_small-size <= 0 OR is_small-work <= 0 OR is_large-size <= 0.
      rv_growth = c_unknown.
      RETURN.
    ENDIF.

    lv_size_ratio = ratio_x100( iv_small = is_small-size
                                iv_large = is_large-size ).
    lv_work_ratio = ratio_x100( iv_small = is_small-work
                                iv_large = is_large-work ).

    " Work that grows no faster than the input is linear.
    IF lv_work_ratio <= lv_size_ratio.
      rv_growth = c_linear.
      RETURN.
    ENDIF.

    " Some slack, because a constant factor is not a complexity change.
    lv_allowed = lv_size_ratio * c_tolerance DIV 100.

    IF lv_work_ratio <= lv_allowed.
      rv_growth = c_near.
      RETURN.
    ENDIF.

    rv_growth = c_quadric.
  ENDMETHOD.

ENDCLASS.
