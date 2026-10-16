CLASS zcl_alloc_sto_create DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             material   TYPE matnr,
             from_plant TYPE string,
             to_plant   TYPE string,
             quantity   TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_sto,
             line_count     TYPE i,
             total_quantity TYPE i,
           END OF ty_sto.

    METHODS build
      IMPORTING
        it_lines      TYPE ty_line_tt
      RETURNING
        VALUE(rs_sto) TYPE ty_sto.

    METHODS is_cross_plant
      IMPORTING
        it_lines     TYPE ty_line_tt
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS total_quantity
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_total) TYPE i.

ENDCLASS.


CLASS zcl_alloc_sto_create IMPLEMENTATION.

  METHOD total_quantity.
    " The transport quantity sums the order lines.
    LOOP AT it_lines INTO DATA(ls_line).
      rv_total = rv_total + ls_line-quantity.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_cross_plant.
    " A transport order is cross-plant once a line moves between two plants.
    LOOP AT it_lines INTO DATA(ls_line).
      IF ls_line-from_plant <> ls_line-to_plant.
        rv_ok = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD build.
    rs_sto-line_count = lines( it_lines ).
    rs_sto-total_quantity = total_quantity( it_lines ).
  ENDMETHOD.

ENDCLASS.
