CLASS zcl_alloc_cpool_merge DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             pool TYPE string,
             cost TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_pool,
             pool  TYPE string,
             total TYPE i,
           END OF ty_pool.
    TYPES ty_pool_tt TYPE STANDARD TABLE OF ty_pool WITH DEFAULT KEY.

    METHODS merge
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rt_pools) TYPE ty_pool_tt.

    METHODS group_count
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS largest
      IMPORTING
        it_lines          TYPE ty_line_tt
      RETURNING
        VALUE(rv_largest) TYPE i.

ENDCLASS.


CLASS zcl_alloc_cpool_merge IMPLEMENTATION.

  METHOD merge.
    DATA lt_pool TYPE SORTED TABLE OF ty_pool WITH UNIQUE KEY pool.
    DATA ls_pool TYPE ty_pool.

    " Duplicate pool lines are merged into one total each.
    LOOP AT it_lines INTO DATA(ls_line).
      READ TABLE lt_pool ASSIGNING FIELD-SYMBOL(<ls_pool>)
        WITH KEY pool = ls_line-pool.
      IF sy-subrc = 0.
        <ls_pool>-total = <ls_pool>-total + ls_line-cost.
      ELSE.
        CLEAR ls_pool.
        ls_pool-pool = ls_line-pool.
        ls_pool-total = ls_line-cost.
        INSERT ls_pool INTO TABLE lt_pool.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_pool INTO ls_pool.
      APPEND ls_pool TO rt_pools.
    ENDLOOP.

    " The merged pools are listed biggest first.
    SORT rt_pools BY total DESCENDING pool ASCENDING.
  ENDMETHOD.

  METHOD group_count.
    DATA lt_pools TYPE ty_pool_tt.

    " The count is the number of merged pools.
    lt_pools = merge( it_lines ).
    rv_count = lines( lt_pools ).
  ENDMETHOD.

  METHOD largest.
    DATA lt_pools TYPE ty_pool_tt.

    " The largest merged pool carries the most cost.
    lt_pools = merge( it_lines ).

    LOOP AT lt_pools INTO DATA(ls_pool).
      IF ls_pool-total > rv_largest.
        rv_largest = ls_pool-total.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
