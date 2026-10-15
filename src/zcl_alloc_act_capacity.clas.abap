CLASS zcl_alloc_act_capacity DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             name      TYPE string,
             used      TYPE i,
             available TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS available
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_total) TYPE i.

    METHODS used
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_total) TYPE i.

    METHODS is_full
      IMPORTING
        iv_used      TYPE i
        iv_available TYPE i
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_act_capacity IMPLEMENTATION.

  METHOD available.
    " The available capacity adds up over the activities.
    LOOP AT it_lines INTO DATA(ls_line).
      rv_total = rv_total + ls_line-available.
    ENDLOOP.
  ENDMETHOD.

  METHOD used.
    " The used capacity adds up over the activities.
    LOOP AT it_lines INTO DATA(ls_line).
      rv_total = rv_total + ls_line-used.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_full.
    " The capacity is full once the load reaches what is available.
    rv_ok = xsdbool( iv_used >= iv_available ).
  ENDMETHOD.

ENDCLASS.
