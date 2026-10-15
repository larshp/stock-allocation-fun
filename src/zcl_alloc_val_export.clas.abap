CLASS zcl_alloc_val_export DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             material TYPE matnr,
             value    TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    TYPES ty_values_tt TYPE STANDARD TABLE OF i WITH DEFAULT KEY.

    METHODS to_rows
      IMPORTING
        it_lines         TYPE ty_line_tt
      RETURNING
        VALUE(rt_values) TYPE ty_values_tt.

    METHODS to_text
      IMPORTING
        iv_value       TYPE i
      RETURNING
        VALUE(rv_text) TYPE string.

    METHODS row_count
      IMPORTING
        it_lines        TYPE ty_line_tt
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_val_export IMPLEMENTATION.

  METHOD to_rows.
    " The export takes the value of every line in order.
    LOOP AT it_lines INTO DATA(ls_line).
      APPEND ls_line-value TO rt_values.
    ENDLOOP.
  ENDMETHOD.

  METHOD to_text.
    " The value is written as text for the export file.
    rv_text = |{ iv_value }|.
  ENDMETHOD.

  METHOD row_count.
    rv_count = lines( it_lines ).
  ENDMETHOD.

ENDCLASS.
