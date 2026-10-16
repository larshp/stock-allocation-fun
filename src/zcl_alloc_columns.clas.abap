CLASS zcl_alloc_columns DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_column,
             field_name TYPE string,
             title      TYPE string,
             width      TYPE i,
             numeric    TYPE abap_bool,
           END OF ty_column.
    TYPES ty_column_tt TYPE STANDARD TABLE OF ty_column WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_column_def,
             position      TYPE i,
             field_name    TYPE string,
             title         TYPE string,
             width         TYPE i,
             right_aligned TYPE abap_bool,
           END OF ty_column_def.
    TYPES ty_column_def_tt TYPE STANDARD TABLE OF ty_column_def
                           WITH DEFAULT KEY.

    METHODS build
      IMPORTING
        it_columns     TYPE ty_column_tt
      RETURNING
        VALUE(rt_defs) TYPE ty_column_def_tt.

    METHODS total_width
      IMPORTING
        it_defs         TYPE ty_column_def_tt
      RETURNING
        VALUE(rv_width) TYPE i.

  PRIVATE SECTION.
    CONSTANTS c_default_width TYPE i VALUE 10.
    CONSTANTS c_max_width     TYPE i VALUE 255.

ENDCLASS.


CLASS zcl_alloc_columns IMPLEMENTATION.

  METHOD build.
    DATA lv_pos TYPE i.
    DATA ls_def TYPE ty_column_def.

    LOOP AT it_columns INTO DATA(ls_column).
      lv_pos = lv_pos + 1.

      CLEAR ls_def.
      ls_def-position = lv_pos.
      ls_def-field_name = ls_column-field_name.
      ls_def-title = ls_column-title.
      ls_def-width = ls_column-width.

      IF ls_def-width <= 0.
        ls_def-width = c_default_width.
      ENDIF.
      IF ls_def-width > c_max_width.
        ls_def-width = c_max_width.
      ENDIF.

      " Numeric columns are shown right aligned, text columns left aligned.
      IF ls_column-numeric = abap_true.
        ls_def-right_aligned = abap_true.
      ENDIF.

      APPEND ls_def TO rt_defs.
    ENDLOOP.
  ENDMETHOD.

  METHOD total_width.
    LOOP AT it_defs INTO DATA(ls_def).
      rv_width = rv_width + ls_def-width.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
