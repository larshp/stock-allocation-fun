CLASS zcl_alloc_abc_rollup DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             group TYPE string,
             cost  TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_group,
             group TYPE string,
             total TYPE i,
           END OF ty_group.
    TYPES ty_group_tt TYPE STANDARD TABLE OF ty_group WITH DEFAULT KEY.

    METHODS rollup
      IMPORTING
        it_lines         TYPE ty_line_tt
      RETURNING
        VALUE(rt_groups) TYPE ty_group_tt.

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


CLASS zcl_alloc_abc_rollup IMPLEMENTATION.

  METHOD rollup.
    DATA lt_group TYPE SORTED TABLE OF ty_group WITH UNIQUE KEY group.
    DATA ls_group TYPE ty_group.

    " Every activity is rolled into the total of its group.
    LOOP AT it_lines INTO DATA(ls_line).
      READ TABLE lt_group ASSIGNING FIELD-SYMBOL(<ls_group>)
        WITH KEY group = ls_line-group.
      IF sy-subrc = 0.
        <ls_group>-total = <ls_group>-total + ls_line-cost.
      ELSE.
        CLEAR ls_group.
        ls_group-group = ls_line-group.
        ls_group-total = ls_line-cost.
        INSERT ls_group INTO TABLE lt_group.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_group INTO ls_group.
      APPEND ls_group TO rt_groups.
    ENDLOOP.
  ENDMETHOD.

  METHOD group_count.
    DATA lt_groups TYPE ty_group_tt.

    " The groups are the distinct activities behind the cost.
    lt_groups = rollup( it_lines ).
    rv_count = lines( lt_groups ).
  ENDMETHOD.

  METHOD largest.
    DATA lt_groups TYPE ty_group_tt.

    " The largest group carries the biggest cost.
    lt_groups = rollup( it_lines ).

    LOOP AT lt_groups INTO DATA(ls_group).
      IF ls_group-total > rv_largest.
        rv_largest = ls_group-total.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
