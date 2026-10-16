CLASS zcl_alloc_area_model DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS add_bin
      IMPORTING
        iv_capacity TYPE i
        iv_used     TYPE i.

    METHODS total_capacity
      RETURNING
        VALUE(rv_capacity) TYPE i.

    METHODS total_used
      RETURNING
        VALUE(rv_used) TYPE i.

    METHODS free_space
      RETURNING
        VALUE(rv_free) TYPE i.

    METHODS bin_count
      RETURNING
        VALUE(rv_count) TYPE i.

  PRIVATE SECTION.
    DATA mv_capacity TYPE i.
    DATA mv_used     TYPE i.
    DATA mv_bins     TYPE i.

ENDCLASS.


CLASS zcl_alloc_area_model IMPLEMENTATION.

  METHOD add_bin.
    IF iv_capacity > 0.
      mv_capacity = mv_capacity + iv_capacity.
    ENDIF.

    IF iv_used > 0.
      mv_used = mv_used + iv_used.
    ENDIF.

    mv_bins = mv_bins + 1.
  ENDMETHOD.

  METHOD total_capacity.
    rv_capacity = mv_capacity.
  ENDMETHOD.

  METHOD total_used.
    rv_used = mv_used.
  ENDMETHOD.

  METHOD free_space.
    IF mv_capacity > mv_used.
      rv_free = mv_capacity - mv_used.
    ENDIF.
  ENDMETHOD.

  METHOD bin_count.
    rv_count = mv_bins.
  ENDMETHOD.

ENDCLASS.
