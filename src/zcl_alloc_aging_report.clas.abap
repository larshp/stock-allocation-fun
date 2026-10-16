CLASS zcl_alloc_aging_report DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_item,
             material TYPE matnr,
             age_days TYPE i,
             value    TYPE i,
           END OF ty_item.
    TYPES ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_bucket,
             bucket      TYPE string,
             count       TYPE i,
             total_value TYPE i,
           END OF ty_bucket.
    TYPES ty_bucket_tt TYPE STANDARD TABLE OF ty_bucket WITH DEFAULT KEY.

    METHODS build
      IMPORTING
        it_items          TYPE ty_item_tt
      RETURNING
        VALUE(rt_buckets) TYPE ty_bucket_tt.

    METHODS count_in_bucket
      IMPORTING
        it_items        TYPE ty_item_tt
        iv_bucket       TYPE string
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS total_value
      IMPORTING
        it_items        TYPE ty_item_tt
      RETURNING
        VALUE(rv_value) TYPE i.

  PRIVATE SECTION.
    METHODS bucket_of
      IMPORTING
        iv_age_days      TYPE i
      RETURNING
        VALUE(rv_bucket) TYPE string.

ENDCLASS.


CLASS zcl_alloc_aging_report IMPLEMENTATION.

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

  METHOD build.
    DATA lt_buckets TYPE SORTED TABLE OF ty_bucket WITH UNIQUE KEY bucket.
    DATA ls_bucket  TYPE ty_bucket.
    DATA lv_bucket  TYPE string.

    " The items are summed per ageing bucket in a sorted table, so the buckets
    " come out in alphabetical order.
    LOOP AT it_items INTO DATA(ls_item).
      lv_bucket = bucket_of( ls_item-age_days ).

      READ TABLE lt_buckets ASSIGNING FIELD-SYMBOL(<ls_bucket>)
        WITH KEY bucket = lv_bucket.

      IF sy-subrc <> 0.
        CLEAR ls_bucket.
        ls_bucket-bucket = lv_bucket.
        INSERT ls_bucket INTO TABLE lt_buckets ASSIGNING <ls_bucket>.
      ENDIF.

      <ls_bucket>-count = <ls_bucket>-count + 1.
      <ls_bucket>-total_value = <ls_bucket>-total_value + ls_item-value.
    ENDLOOP.

    rt_buckets = lt_buckets.
  ENDMETHOD.

  METHOD count_in_bucket.
    DATA lv_bucket TYPE string.

    LOOP AT it_items INTO DATA(ls_item).
      lv_bucket = bucket_of( ls_item-age_days ).
      IF lv_bucket = iv_bucket.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD total_value.
    LOOP AT it_items INTO DATA(ls_item).
      rv_value = rv_value + ls_item-value.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
