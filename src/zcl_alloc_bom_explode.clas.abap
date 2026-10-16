CLASS zcl_alloc_bom_explode DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             component TYPE string,
             level     TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    METHODS explode
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rt_lines) TYPE ty_line_tt.

    METHODS level_of
      IMPORTING
        iv_level         TYPE i
      RETURNING
        VALUE(rv_parent) TYPE i.

    METHODS is_multi_level
      IMPORTING
        it_lines     TYPE ty_line_tt
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_bom_explode IMPLEMENTATION.

  METHOD explode.
    " The BOM is flattened with the top level first.
    rt_lines = it_lines.
    SORT rt_lines BY level ASCENDING.
  ENDMETHOD.

  METHOD level_of.
    " A child sits one level below its parent, with the top at zero.
    rv_parent = iv_level - 1.
    IF rv_parent < 0.
      rv_parent = 0.
    ENDIF.
  ENDMETHOD.

  METHOD is_multi_level.
    " The BOM is multi-level once any line sits below the top.
    LOOP AT it_lines INTO DATA(ls_line).
      IF ls_line-level > 1.
        rv_ok = abap_true.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
