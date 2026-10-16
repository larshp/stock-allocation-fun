CLASS zcl_alloc_wip_age DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    METHODS days_old
      IMPORTING
        iv_created     TYPE i
        iv_today       TYPE i
      RETURNING
        VALUE(rv_days) TYPE i.

    METHODS is_stale
      IMPORTING
        iv_days_old  TYPE i
        iv_limit     TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS bucket
      IMPORTING
        iv_days_old      TYPE i
      RETURNING
        VALUE(rv_bucket) TYPE string.

ENDCLASS.


CLASS zcl_alloc_wip_age IMPLEMENTATION.

  METHOD days_old.
    " The age is the days since the work in progress was opened.
    rv_days = iv_today - iv_created.
    IF rv_days < 0.
      rv_days = 0.
    ENDIF.
  ENDMETHOD.

  METHOD is_stale.
    " The work in progress is stale once it passes the limit.
    rv_ok = xsdbool( iv_days_old > iv_limit ).
  ENDMETHOD.

  METHOD bucket.
    " The age reads fresh, aging or stale.
    IF iv_days_old <= 30.
      rv_bucket = 'FRESH'.
    ELSEIF iv_days_old <= 90.
      rv_bucket = 'AGING'.
    ELSE.
      rv_bucket = 'STALE'.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
