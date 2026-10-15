CLASS zcl_alloc_inspect_lot DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS set_lot_size
      IMPORTING
        iv_lot_size TYPE i.

    METHODS add_sample
      IMPORTING
        iv_inspected TYPE i
        iv_defects   TYPE i.

    METHODS lot_size
      RETURNING
        VALUE(rv_size) TYPE i.

    METHODS inspected
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS defects
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS remaining
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS clear.

  PRIVATE SECTION.
    DATA mv_lot_size  TYPE i.
    DATA mv_inspected TYPE i.
    DATA mv_defects   TYPE i.

ENDCLASS.


CLASS zcl_alloc_inspect_lot IMPLEMENTATION.

  METHOD set_lot_size.
    IF iv_lot_size > 0.
      mv_lot_size = iv_lot_size.
    ENDIF.
  ENDMETHOD.

  METHOD add_sample.
    IF iv_inspected > 0.
      mv_inspected = mv_inspected + iv_inspected.
    ENDIF.

    IF iv_defects > 0.
      mv_defects = mv_defects + iv_defects.
    ENDIF.
  ENDMETHOD.

  METHOD lot_size.
    rv_size = mv_lot_size.
  ENDMETHOD.

  METHOD inspected.
    rv_count = mv_inspected.
  ENDMETHOD.

  METHOD defects.
    rv_count = mv_defects.
  ENDMETHOD.

  METHOD remaining.
    IF mv_lot_size > mv_inspected.
      rv_count = mv_lot_size - mv_inspected.
    ENDIF.
  ENDMETHOD.

  METHOD clear.
    CLEAR mv_lot_size.
    CLEAR mv_inspected.
    CLEAR mv_defects.
  ENDMETHOD.

ENDCLASS.
