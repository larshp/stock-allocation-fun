CLASS zcl_alloc_seq_num DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS constructor
      IMPORTING
        iv_start TYPE i.

    METHODS next
      RETURNING
        VALUE(rv_value) TYPE i.

    METHODS current
      RETURNING
        VALUE(rv_value) TYPE i.

    METHODS reset.

  PRIVATE SECTION.
    DATA mv_start   TYPE i.
    DATA mv_current TYPE i.

ENDCLASS.


CLASS zcl_alloc_seq_num IMPLEMENTATION.

  METHOD constructor.
    mv_start = iv_start.
    mv_current = iv_start.
  ENDMETHOD.

  METHOD next.
    rv_value = mv_current.
    mv_current = mv_current + 1.
  ENDMETHOD.

  METHOD current.
    rv_value = mv_current.
  ENDMETHOD.

  METHOD reset.
    mv_current = mv_start.
  ENDMETHOD.

ENDCLASS.
