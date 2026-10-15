CLASS zcl_alloc_inv_age DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_names_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    METHODS buckets
      RETURNING
        VALUE(rt_buckets) TYPE ty_names_tt.

    METHODS bucket_of
      IMPORTING
        iv_age_days      TYPE i
      RETURNING
        VALUE(rv_bucket) TYPE string.

    METHODS is_aged
      IMPORTING
        iv_age_days  TYPE i
        iv_threshold TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_inv_age IMPLEMENTATION.

  METHOD buckets.
    " The four ageing buckets in order of age.
    APPEND 'FRESH' TO rt_buckets.
    APPEND 'RECENT' TO rt_buckets.
    APPEND 'AGING' TO rt_buckets.
    APPEND 'OBSOLETE' TO rt_buckets.
  ENDMETHOD.

  METHOD bucket_of.
    " The bucket widens as the material ages.
    IF iv_age_days <= 30.
      rv_bucket = 'FRESH'.
    ELSEIF iv_age_days <= 90.
      rv_bucket = 'RECENT'.
    ELSEIF iv_age_days <= 180.
      rv_bucket = 'AGING'.
    ELSE.
      rv_bucket = 'OBSOLETE'.
    ENDIF.
  ENDMETHOD.

  METHOD is_aged.
    " A material is aged once it reaches the threshold.
    rv_ok = xsdbool( iv_age_days >= iv_threshold ).
  ENDMETHOD.

ENDCLASS.
