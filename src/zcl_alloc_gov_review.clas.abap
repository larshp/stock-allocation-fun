CLASS zcl_alloc_gov_review DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS is_due
      IMPORTING
        iv_days_until TYPE i
      RETURNING
        VALUE(rv_ok)  TYPE abap_bool.

    METHODS days_until
      IMPORTING
        iv_last         TYPE i
        iv_interval     TYPE i
      RETURNING
        VALUE(rv_until) TYPE i.

    METHODS priority
      IMPORTING
        iv_days_until      TYPE i
      RETURNING
        VALUE(rv_priority) TYPE string.

ENDCLASS.


CLASS zcl_alloc_gov_review IMPLEMENTATION.

  METHOD is_due.
    " The review is due once there are no days left before it.
    rv_ok = xsdbool( iv_days_until <= 0 ).
  ENDMETHOD.

  METHOD days_until.
    " The days left before the next review is due.
    rv_until = iv_interval - iv_last.
  ENDMETHOD.

  METHOD priority.
    " The review reads high, medium or low on how soon it falls due.
    IF iv_days_until <= 0.
      rv_priority = 'HIGH'.
    ELSEIF iv_days_until <= 7.
      rv_priority = 'MEDIUM'.
    ELSE.
      rv_priority = 'LOW'.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
