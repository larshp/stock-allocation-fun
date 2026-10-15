CLASS zcl_alloc_return_aging DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_ages_tt TYPE STANDARD TABLE OF i WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_bucket,
             bucket TYPE string,
             count  TYPE i,
           END OF ty_bucket.
    TYPES ty_bucket_tt TYPE STANDARD TABLE OF ty_bucket WITH DEFAULT KEY.

    METHODS bucket
      IMPORTING
        iv_age_days      TYPE i
      RETURNING
        VALUE(rv_bucket) TYPE string.

    METHODS bucket_of
      IMPORTING
        it_ages           TYPE ty_ages_tt
      RETURNING
        VALUE(rt_buckets) TYPE ty_bucket_tt.

    METHODS count_in
      IMPORTING
        it_ages         TYPE ty_ages_tt
        iv_bucket       TYPE string
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_return_aging IMPLEMENTATION.

  METHOD bucket.
    " An age is placed in the first band it fits; anything past ninety days sits
    " in the open-ended last band.
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

  METHOD bucket_of.
    DATA lt_count TYPE SORTED TABLE OF ty_bucket WITH UNIQUE KEY bucket.
    DATA ls_count TYPE ty_bucket.
    DATA lv_bucket TYPE string.

    " One row per band that has at least one age, in band order.
    LOOP AT it_ages INTO DATA(lv_age).
      lv_bucket = bucket( lv_age ).

      READ TABLE lt_count ASSIGNING FIELD-SYMBOL(<ls_count>)
        WITH KEY bucket = lv_bucket.

      IF sy-subrc <> 0.
        CLEAR ls_count.
        ls_count-bucket = lv_bucket.
        INSERT ls_count INTO TABLE lt_count ASSIGNING <ls_count>.
      ENDIF.

      <ls_count>-count = <ls_count>-count + 1.
    ENDLOOP.

    rt_buckets = lt_count.
  ENDMETHOD.

  METHOD count_in.
    LOOP AT it_ages INTO DATA(lv_age).
      IF bucket( lv_age ) = iv_bucket.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
