CLASS zcl_alloc_val_group DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             group TYPE string,
             value TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    TYPES ty_values_tt TYPE STANDARD TABLE OF i WITH DEFAULT KEY.

    METHODS group_totals
      IMPORTING
        it_lines         TYPE ty_line_tt
      RETURNING
        VALUE(rt_totals) TYPE ty_values_tt.

    METHODS is_empty
      IMPORTING
        it_lines     TYPE ty_line_tt
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS group_count
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_count) TYPE i.

  PRIVATE SECTION.
    TYPES: BEGIN OF ty_sum,
             group TYPE string,
             total TYPE i,
           END OF ty_sum.
    TYPES ty_sum_tt TYPE STANDARD TABLE OF ty_sum WITH DEFAULT KEY.

    METHODS sums
      IMPORTING
        it_lines       TYPE ty_line_tt
      RETURNING
        VALUE(rt_sums) TYPE ty_sum_tt.

ENDCLASS.


CLASS zcl_alloc_val_group IMPLEMENTATION.

  METHOD sums.
    DATA lt_group TYPE SORTED TABLE OF ty_sum WITH UNIQUE KEY group.
    DATA ls_group TYPE ty_sum.

    " Every line is added to the running total of its group.
    LOOP AT it_lines INTO DATA(ls_line).
      READ TABLE lt_group ASSIGNING FIELD-SYMBOL(<ls_group>)
        WITH KEY group = ls_line-group.
      IF sy-subrc = 0.
        <ls_group>-total = <ls_group>-total + ls_line-value.
      ELSE.
        CLEAR ls_group.
        ls_group-group = ls_line-group.
        ls_group-total = ls_line-value.
        INSERT ls_group INTO TABLE lt_group.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_group INTO ls_group.
      APPEND ls_group TO rt_sums.
    ENDLOOP.
  ENDMETHOD.

  METHOD group_totals.
    DATA lt_sums TYPE ty_sum_tt.

    " The totals are listed with the biggest group first.
    lt_sums = sums( it_lines ).

    LOOP AT lt_sums INTO DATA(ls_sum).
      APPEND ls_sum-total TO rt_totals.
    ENDLOOP.

    SORT rt_totals DESCENDING.
  ENDMETHOD.

  METHOD is_empty.
    " A valuation without lines groups nothing.
    rv_ok = xsdbool( lines( it_lines ) = 0 ).
  ENDMETHOD.

  METHOD group_count.
    DATA lt_sums TYPE ty_sum_tt.

    lt_sums = sums( it_lines ).
    rv_count = lines( lt_sums ).
  ENDMETHOD.

ENDCLASS.
