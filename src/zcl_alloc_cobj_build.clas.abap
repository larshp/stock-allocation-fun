CLASS zcl_alloc_cobj_build DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             object TYPE string,
             cost   TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_object,
             object TYPE string,
             total  TYPE i,
           END OF ty_object.
    TYPES ty_object_tt TYPE STANDARD TABLE OF ty_object WITH DEFAULT KEY.

    METHODS build
      IMPORTING
        it_lines          TYPE ty_line_tt
      RETURNING
        VALUE(rt_objects) TYPE ty_object_tt.

    METHODS object_count
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


CLASS zcl_alloc_cobj_build IMPLEMENTATION.

  METHOD build.
    DATA lt_object TYPE SORTED TABLE OF ty_object WITH UNIQUE KEY object.
    DATA ls_object TYPE ty_object.

    " Every cost line is gathered into the total of its cost object.
    LOOP AT it_lines INTO DATA(ls_line).
      READ TABLE lt_object ASSIGNING FIELD-SYMBOL(<ls_object>)
        WITH KEY object = ls_line-object.
      IF sy-subrc = 0.
        <ls_object>-total = <ls_object>-total + ls_line-cost.
      ELSE.
        CLEAR ls_object.
        ls_object-object = ls_line-object.
        ls_object-total = ls_line-cost.
        INSERT ls_object INTO TABLE lt_object.
      ENDIF.
    ENDLOOP.

    LOOP AT lt_object INTO ls_object.
      APPEND ls_object TO rt_objects.
    ENDLOOP.
  ENDMETHOD.

  METHOD object_count.
    DATA lt_objects TYPE ty_object_tt.

    " The count is the number of distinct cost objects.
    lt_objects = build( it_lines ).
    rv_count = lines( lt_objects ).
  ENDMETHOD.

  METHOD total.
    " The total adds the cost of every line.
    LOOP AT it_lines INTO DATA(ls_line).
      rv_total = rv_total + ls_line-cost.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
