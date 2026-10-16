CLASS zcl_alloc_val_rollup DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             category TYPE string,
             value    TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_group,
             category TYPE string,
             total    TYPE i,
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

    METHODS largest_group
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_total) TYPE i.

ENDCLASS.


CLASS zcl_alloc_val_rollup IMPLEMENTATION.

  METHOD rollup.
    DATA lt_group TYPE SORTED TABLE OF ty_group WITH UNIQUE KEY category.
    DATA ls_group TYPE ty_group.

    " Every line is rolled into the total of its category.
    LOOP AT it_lines INTO DATA(ls_line).
      READ TABLE lt_group ASSIGNING FIELD-SYMBOL(<ls_group>)
        WITH KEY category = ls_line-category.
      IF sy-subrc = 0.
        <ls_group>-total = <ls_group>-total + ls_line-value.
      ELSE.
        CLEAR ls_group.
        ls_group-category = ls_line-category.
        ls_group-total = ls_line-value.
        INSERT ls_group INTO TABLE lt_group.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_group INTO ls_group.
      APPEND ls_group TO rt_groups.
    ENDLOOP.
  ENDMETHOD.

  METHOD group_count.
    DATA lt_groups TYPE ty_group_tt.

    " The groups are the distinct categories that remain.
    lt_groups = rollup( it_lines ).
    rv_count = lines( lt_groups ).
  ENDMETHOD.

  METHOD largest_group.
    DATA lt_groups TYPE ty_group_tt.

    " The largest group carries the biggest total.
    lt_groups = rollup( it_lines ).

    LOOP AT lt_groups INTO DATA(ls_group).
      IF ls_group-total > rv_total.
        rv_total = ls_group-total.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
