CLASS zcl_alloc_bom_summary DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             component TYPE string,
             qty       TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_summary,
             component_count TYPE i,
             total_qty       TYPE i,
           END OF ty_summary.

    METHODS build
      IMPORTING
        it_lines          TYPE ty_line_tt
      RETURNING
        VALUE(rs_summary) TYPE ty_summary.

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


CLASS zcl_alloc_bom_summary IMPLEMENTATION.

  METHOD component_count.
    rv_count = lines( it_lines ).
  ENDMETHOD.

  METHOD total_qty.
    " The summary adds the quantity of every component line.
    LOOP AT it_lines INTO DATA(ls_line).
      rv_qty = rv_qty + ls_line-qty.
    ENDLOOP.
  ENDMETHOD.

  METHOD build.
    " The summary counts the components and totals their quantity.
    rs_summary-component_count = component_count( it_lines ).
    rs_summary-total_qty = total_qty( it_lines ).
  ENDMETHOD.

ENDCLASS.
