CLASS zcl_alloc_prep_dash DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             tile  TYPE string,
             value TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_dash,
             tile_count TYPE i,
             total      TYPE i,
           END OF ty_dash.

    METHODS build
      IMPORTING
        it_lines       TYPE ty_line_tt
      RETURNING
        VALUE(rs_dash) TYPE ty_dash.

    METHODS tile_count
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


CLASS zcl_alloc_prep_dash IMPLEMENTATION.

  METHOD tile_count.
    rv_count = lines( it_lines ).
  ENDMETHOD.

  METHOD total.
    " The dashboard adds the value of every tile.
    LOOP AT it_lines INTO DATA(ls_line).
      rv_total = rv_total + ls_line-value.
    ENDLOOP.
  ENDMETHOD.

  METHOD build.
    " The dashboard counts the tiles and totals their value.
    rs_dash-tile_count = tile_count( it_lines ).
    rs_dash-total = total( it_lines ).
  ENDMETHOD.

ENDCLASS.
