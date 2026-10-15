CLASS zcl_alloc_bom_where DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             component TYPE string,
             parent    TYPE string,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS used_in
      IMPORTING
        it_lines       TYPE ty_line_tt
        iv_component   TYPE string
      RETURNING
        VALUE(rt_used) TYPE ty_line_tt.

    METHODS is_used
      IMPORTING
        it_lines     TYPE ty_line_tt
        iv_component TYPE string
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS count
      IMPORTING
        it_lines        TYPE ty_line_tt
        iv_component    TYPE string
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_bom_where IMPLEMENTATION.

  METHOD used_in.
    " The parents that hold a component.
    LOOP AT it_lines INTO DATA(ls_line).
      IF ls_line-component = iv_component.
        APPEND ls_line TO rt_used.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_used.
    " A component is used once any parent holds it.
    LOOP AT it_lines INTO DATA(ls_line).
      IF ls_line-component = iv_component.
        rv_ok = abap_true.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD count.
    " The count is how many parents hold the component.
    LOOP AT it_lines INTO DATA(ls_line).
      IF ls_line-component = iv_component.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
