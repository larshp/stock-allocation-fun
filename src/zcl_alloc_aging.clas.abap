CLASS zcl_alloc_aging DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS bucket
      IMPORTING
        iv_days_overdue  TYPE i
      RETURNING
        VALUE(rv_bucket) TYPE i.

ENDCLASS.


CLASS zcl_alloc_aging IMPLEMENTATION.

  METHOD bucket.
    IF iv_days_overdue <= 0.
      rv_bucket = 0.
      RETURN.
    ENDIF.

    IF iv_days_overdue <= 30.
      rv_bucket = 1.
      RETURN.
    ENDIF.

    IF iv_days_overdue <= 60.
      rv_bucket = 2.
      RETURN.
    ENDIF.

    IF iv_days_overdue <= 90.
      rv_bucket = 3.
      RETURN.
    ENDIF.

    rv_bucket = 4.
  ENDMETHOD.

ENDCLASS.
