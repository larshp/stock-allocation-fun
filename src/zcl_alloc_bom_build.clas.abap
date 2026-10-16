CLASS zcl_alloc_bom_build DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             component TYPE string,
             qty       TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_comp,
             component TYPE string,
             qty       TYPE i,
           END OF ty_comp.
    TYPES ty_comp_tt TYPE STANDARD TABLE OF ty_comp WITH DEFAULT KEY.

    METHODS build
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rt_comps) TYPE ty_comp_tt.

    METHODS component_count
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS total_qty
      IMPORTING
        it_lines      TYPE ty_line_tt
      RETURNING
        VALUE(rv_qty) TYPE i.

ENDCLASS.


CLASS zcl_alloc_bom_build IMPLEMENTATION.

  METHOD build.
    DATA lt_comp TYPE SORTED TABLE OF ty_comp WITH UNIQUE KEY component.
    DATA ls_comp TYPE ty_comp.

    " Every line is gathered into the quantity of its component.
    LOOP AT it_lines INTO DATA(ls_line).
      READ TABLE lt_comp ASSIGNING FIELD-SYMBOL(<ls_comp>)
        WITH KEY component = ls_line-component.
      IF sy-subrc = 0.
        <ls_comp>-qty = <ls_comp>-qty + ls_line-qty.
      ELSE.
        CLEAR ls_comp.
        ls_comp-component = ls_line-component.
        ls_comp-qty = ls_line-qty.
        INSERT ls_comp INTO TABLE lt_comp.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_comp INTO ls_comp.
      APPEND ls_comp TO rt_comps.
    ENDLOOP.
  ENDMETHOD.

  METHOD component_count.
    DATA lt_comps TYPE ty_comp_tt.

    " The count is the number of distinct components.
    lt_comps = build( it_lines ).
    rv_count = lines( lt_comps ).
  ENDMETHOD.

  METHOD total_qty.
    " The total adds the quantity of every line.
    LOOP AT it_lines INTO DATA(ls_line).
      rv_qty = rv_qty + ls_line-qty.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
