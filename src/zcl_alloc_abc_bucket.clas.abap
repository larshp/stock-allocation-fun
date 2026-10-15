CLASS zcl_alloc_abc_bucket DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_values_tt TYPE STANDARD TABLE OF i WITH DEFAULT KEY.

    METHODS bucket_of
      IMPORTING
        iv_cost          TYPE i
        iv_boundary      TYPE i
      RETURNING
        VALUE(rv_bucket) TYPE i.

    METHODS count_in
      IMPORTING
        it_values       TYPE ty_values_tt
        iv_boundary     TYPE i
        iv_bucket       TYPE i
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS is_par
      IMPORTING
        iv_count_a   TYPE i
        iv_count_b   TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_abc_bucket IMPLEMENTATION.

  METHOD bucket_of.
    " A cost sits in the first bucket up to the boundary, the second above it.
    IF iv_cost <= iv_boundary.
      rv_bucket = 1.
    ELSE.
      rv_bucket = 2.
    ENDIF.
  ENDMETHOD.

  METHOD count_in.
    DATA lv_bucket TYPE i.

    " The bucket count picks the values that fall into that bucket.
    LOOP AT it_values INTO DATA(lv_value).
      lv_bucket = bucket_of( iv_cost = lv_value iv_boundary = iv_boundary ).
      IF lv_bucket = iv_bucket.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_par.
    " Two buckets are on a par once they hold the same count.
    rv_ok = xsdbool( iv_count_a = iv_count_b ).
  ENDMETHOD.

ENDCLASS.
