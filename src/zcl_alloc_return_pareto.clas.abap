CLASS zcl_alloc_return_pareto DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_item,
             material TYPE matnr,
             quantity TYPE i,
           END OF ty_item.
    TYPES ty_item_tt TYPE STANDARD TABLE OF ty_item WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_bucket,
             material           TYPE matnr,
             quantity           TYPE i,
             cumulative_percent TYPE i,
           END OF ty_bucket.
    TYPES ty_bucket_tt TYPE STANDARD TABLE OF ty_bucket WITH DEFAULT KEY.

    METHODS pareto
      IMPORTING
        it_items          TYPE ty_item_tt
      RETURNING
        VALUE(rt_buckets) TYPE ty_bucket_tt.

    METHODS vital_few
      IMPORTING
        it_buckets      TYPE ty_bucket_tt
        iv_threshold    TYPE i
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS cumulative_percent
      IMPORTING
        it_buckets    TYPE ty_bucket_tt
      RETURNING
        VALUE(rv_pct) TYPE i.

  PRIVATE SECTION.
    TYPES: BEGIN OF ty_sum,
             material TYPE matnr,
             quantity TYPE i,
           END OF ty_sum.
    TYPES: BEGIN OF ty_work,
             material TYPE matnr,
             quantity TYPE i,
             seq      TYPE i,
           END OF ty_work.
    TYPES ty_work_tt TYPE STANDARD TABLE OF ty_work WITH DEFAULT KEY.

ENDCLASS.


CLASS zcl_alloc_return_pareto IMPLEMENTATION.

  METHOD pareto.
    DATA lt_sum   TYPE SORTED TABLE OF ty_sum WITH UNIQUE KEY material.
    DATA ls_sum   TYPE ty_sum.
    DATA lt_work  TYPE ty_work_tt.
    DATA ls_work  TYPE ty_work.
    DATA lv_seq   TYPE i.
    DATA lv_total TYPE i.
    DATA lv_cum   TYPE i.
    DATA ls_bucket TYPE ty_bucket.

    " Quantities are summed per material, ordered by size, and then walked once to
    " build a cumulative share. An empty or valueless input has no pareto.
    LOOP AT it_items INTO DATA(ls_item).
      IF ls_item-quantity <= 0.
        CONTINUE.
      ENDIF.

      READ TABLE lt_sum ASSIGNING FIELD-SYMBOL(<ls_sum>)
        WITH KEY material = ls_item-material.

      IF sy-subrc <> 0.
        CLEAR ls_sum.
        ls_sum-material = ls_item-material.
        INSERT ls_sum INTO TABLE lt_sum ASSIGNING <ls_sum>.
      ENDIF.

      <ls_sum>-quantity = <ls_sum>-quantity + ls_item-quantity.
      lv_total = lv_total + ls_item-quantity.
    ENDLOOP.

    IF lv_total <= 0.
      RETURN.
    ENDIF.

    LOOP AT lt_sum INTO ls_sum.
      lv_seq = lv_seq + 1.

      CLEAR ls_work.
      ls_work-material = ls_sum-material.
      ls_work-quantity = ls_sum-quantity.
      ls_work-seq = lv_seq.
      APPEND ls_work TO lt_work.
    ENDLOOP.

    SORT lt_work BY quantity DESCENDING
                    seq      ASCENDING.

    LOOP AT lt_work INTO ls_work.
      lv_cum = lv_cum + ls_work-quantity.

      CLEAR ls_bucket.
      ls_bucket-material = ls_work-material.
      ls_bucket-quantity = ls_work-quantity.
      ls_bucket-cumulative_percent = lv_cum * 100 DIV lv_total.
      APPEND ls_bucket TO rt_buckets.
    ENDLOOP.
  ENDMETHOD.

  METHOD vital_few.
    LOOP AT it_buckets INTO DATA(ls_bucket).
      IF ls_bucket-cumulative_percent <= iv_threshold.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD cumulative_percent.
    " The last bucket holds the whole cumulative share.
    LOOP AT it_buckets INTO DATA(ls_bucket).
      rv_pct = ls_bucket-cumulative_percent.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
