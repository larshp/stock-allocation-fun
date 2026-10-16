CLASS zcl_alloc_permission DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_role  TYPE c LENGTH 20.
    TYPES ty_actvt TYPE c LENGTH 20.

    TYPES: BEGIN OF ty_cell,
             role    TYPE ty_role,
             actvt   TYPE ty_actvt,
             allowed TYPE abap_bool,
           END OF ty_cell.
    TYPES ty_cell_tt TYPE STANDARD TABLE OF ty_cell WITH DEFAULT KEY.

    METHODS set
      IMPORTING
        iv_role    TYPE ty_role
        iv_actvt   TYPE ty_actvt
        iv_allowed TYPE abap_bool.

    METHODS allows
      IMPORTING
        iv_role           TYPE ty_role
        iv_actvt          TYPE ty_actvt
      RETURNING
        VALUE(rv_allowed) TYPE abap_bool.

    METHODS allowed_count
      RETURNING
        VALUE(rv_count) TYPE i.

  PRIVATE SECTION.
    DATA mt_cells TYPE ty_cell_tt.

ENDCLASS.


CLASS zcl_alloc_permission IMPLEMENTATION.

  METHOD set.
    READ TABLE mt_cells ASSIGNING FIELD-SYMBOL(<ls_cell>)
      WITH KEY role = iv_role actvt = iv_actvt.

    IF sy-subrc = 0.
      <ls_cell>-allowed = iv_allowed.
    ELSE.
      APPEND VALUE #( role = iv_role actvt = iv_actvt allowed = iv_allowed ) TO mt_cells.
    ENDIF.
  ENDMETHOD.

  METHOD allows.
    DATA ls_cell TYPE ty_cell.

    READ TABLE mt_cells INTO ls_cell WITH KEY role = iv_role actvt = iv_actvt.

    IF sy-subrc = 0.
      rv_allowed = ls_cell-allowed.
    ELSE.
      rv_allowed = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD allowed_count.
    DATA ls_cell TYPE ty_cell.

    LOOP AT mt_cells INTO ls_cell.
      IF ls_cell-allowed = abap_true.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
