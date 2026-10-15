CLASS zcl_alloc_reorder_review DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS days_until
      IMPORTING
        iv_last_review_day TYPE d
        iv_today           TYPE d
        iv_cycle_days      TYPE i
      RETURNING
        VALUE(rv_days)     TYPE i.

    METHODS is_due
      IMPORTING
        iv_days_until TYPE i
      RETURNING
        VALUE(rv_ok)  TYPE abap_bool.

    METHODS review
      IMPORTING
        iv_last_review_day TYPE d
        iv_today           TYPE d
        iv_cycle_days      TYPE i
      RETURNING
        VALUE(rv_review)   TYPE string.

ENDCLASS.


CLASS zcl_alloc_reorder_review IMPLEMENTATION.

  METHOD days_until.
    DATA lv_elapsed TYPE i.

    " Without dates the next review cannot be placed.
    IF iv_last_review_day IS INITIAL OR iv_today IS INITIAL.
      RETURN.
    ENDIF.

    lv_elapsed = iv_today - iv_last_review_day.
    rv_days = iv_cycle_days - lv_elapsed.
  ENDMETHOD.

  METHOD is_due.
    " The review is due once its day has arrived or passed.
    rv_ok = xsdbool( iv_days_until <= 0 ).
  ENDMETHOD.

  METHOD review.
    DATA lv_days TYPE i.

    " The review is due when the cycle has elapsed.
    lv_days = days_until( iv_last_review_day = iv_last_review_day
                          iv_today           = iv_today
                          iv_cycle_days      = iv_cycle_days ).

    IF lv_days <= 0.
      rv_review = 'DUE'.
    ELSE.
      rv_review = 'SCHEDULED'.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
