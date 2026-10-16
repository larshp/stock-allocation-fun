CLASS zcl_alloc_rtv_aging DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_ages_tt TYPE STANDARD TABLE OF i WITH DEFAULT KEY.

    METHODS bucket
      IMPORTING
        iv_age_days      TYPE i
      RETURNING
        VALUE(rv_bucket) TYPE string.

    METHODS oldest_days
      IMPORTING
        it_ages        TYPE ty_ages_tt
      RETURNING
        VALUE(rv_days) TYPE i.

    METHODS overdue
      IMPORTING
        it_ages         TYPE ty_ages_tt
        iv_limit        TYPE i
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_rtv_aging IMPLEMENTATION.

  METHOD bucket.
    " An open vendor claim is placed in the first aging band it fits.
    IF iv_age_days <= 30.
      rv_bucket = '0-30'.
    ELSEIF iv_age_days <= 60.
      rv_bucket = '31-60'.
    ELSEIF iv_age_days <= 90.
      rv_bucket = '61-90'.
    ELSE.
      rv_bucket = '90+'.
    ENDIF.
  ENDMETHOD.

  METHOD oldest_days.
    LOOP AT it_ages INTO DATA(lv_age).
      IF lv_age > rv_days.
        rv_days = lv_age.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD overdue.
    LOOP AT it_ages INTO DATA(lv_age).
      IF lv_age > iv_limit.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
