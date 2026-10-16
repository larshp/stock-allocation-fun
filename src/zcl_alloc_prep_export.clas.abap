CLASS zcl_alloc_prep_export DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             order_id TYPE string,
             cost     TYPE i,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.
    TYPES ty_string_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    METHODS export_rows
      IMPORTING
        it_lines       TYPE ty_line_tt
      RETURNING
        VALUE(rt_rows) TYPE ty_string_tt.

    METHODS row_count
      IMPORTING
        it_rows         TYPE ty_string_tt
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS is_empty
      IMPORTING
        it_lines     TYPE ty_line_tt
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_prep_export IMPLEMENTATION.

  METHOD export_rows.
    " Every order is rendered as a row of the export.
    LOOP AT it_lines INTO DATA(ls_line).
      APPEND |{ ls_line-order_id };{ ls_line-cost }| TO rt_rows.
    ENDLOOP.
  ENDMETHOD.

  METHOD row_count.
    rv_count = lines( it_rows ).
  ENDMETHOD.

  METHOD is_empty.
    " The export is empty once there are no orders.
    rv_ok = xsdbool( lines( it_lines ) = 0 ).
  ENDMETHOD.

ENDCLASS.
