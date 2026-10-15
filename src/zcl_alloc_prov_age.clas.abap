CLASS zcl_alloc_prov_age DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_bucket,
             age_from TYPE i,
             percent  TYPE i,
           END OF ty_bucket.
    TYPES ty_bucket_tt TYPE STANDARD TABLE OF ty_bucket WITH DEFAULT KEY.

    TYPES ty_values_tt TYPE STANDARD TABLE OF i WITH DEFAULT KEY.

    METHODS provision
      IMPORTING
        it_buckets       TYPE ty_bucket_tt
        iv_value         TYPE i
        iv_age_days      TYPE i
      RETURNING
        VALUE(rv_amount) TYPE i.

    METHODS percent_of
      IMPORTING
        it_buckets        TYPE ty_bucket_tt
        iv_age_days       TYPE i
      RETURNING
        VALUE(rv_percent) TYPE i.

    METHODS total
      IMPORTING
        it_values       TYPE ty_values_tt
      RETURNING
        VALUE(rv_total) TYPE i.

ENDCLASS.


CLASS zcl_alloc_prov_age IMPLEMENTATION.

  METHOD percent_of.
    DATA lv_from TYPE i.

    " The older the stock, the higher the bucket it falls into.
    LOOP AT it_buckets INTO DATA(ls_bucket).
      IF ls_bucket-age_from <= iv_age_days AND ls_bucket-age_from >= lv_from.
        lv_from = ls_bucket-age_from.
        rv_percent = ls_bucket-percent.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD provision.
    DATA lv_percent TYPE i.

    " The provision follows the rate of the bucket the age falls into.
    lv_percent = percent_of( it_buckets = it_buckets iv_age_days = iv_age_days ).
    rv_amount = iv_value * lv_percent DIV 100.
  ENDMETHOD.

  METHOD total.
    LOOP AT it_values INTO DATA(lv_value).
      rv_total = rv_total + lv_value.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
