CLASS zcl_alloc_cpool_build DEFINITION
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

    METHODS build
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rt_pools) TYPE ty_pool_tt.

    METHODS pool_count
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS total
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_total) TYPE i.

ENDCLASS.


CLASS zcl_alloc_cpool_build IMPLEMENTATION.

  METHOD build.
    DATA lt_pool TYPE SORTED TABLE OF ty_pool WITH UNIQUE KEY pool.
    DATA ls_pool TYPE ty_pool.

    " Every line is gathered into the total of its cost pool.
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
  ENDMETHOD.

  METHOD pool_count.
    DATA lt_pools TYPE ty_pool_tt.

    " The count is the number of distinct cost pools.
    lt_pools = build( it_lines ).
    rv_count = lines( lt_pools ).
  ENDMETHOD.

  METHOD total.
    " The total adds the cost of every line.
    LOOP AT it_lines INTO DATA(ls_line).
      rv_total = rv_total + ls_line-cost.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
