CLASS zcl_alloc_stockchk_csv DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_lines_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    METHODS constructor.

    METHODS build
      IMPORTING
        it_issues       TYPE zcl_alloc_stock_check=>ty_issue_tt
      RETURNING
        VALUE(rt_lines) TYPE ty_lines_tt.

  PRIVATE SECTION.
    DATA mo_csv TYPE REF TO zcl_alloc_csv.

ENDCLASS.


CLASS zcl_alloc_stockchk_csv IMPLEMENTATION.

  METHOD constructor.
    mo_csv = NEW zcl_alloc_csv( ).
  ENDMETHOD.

  METHOD build.
    DATA lt_fields TYPE zcl_alloc_csv=>ty_field_tt.
    DATA lv_line   TYPE string.

    APPEND 'MATNR' TO lt_fields.
    APPEND 'LGORT' TO lt_fields.
    APPEND 'MESSAGE' TO lt_fields.
    lv_line = mo_csv->build_line( lt_fields ).
    APPEND lv_line TO rt_lines.

    LOOP AT it_issues INTO DATA(ls_issue).
      CLEAR lt_fields.
      APPEND |{ ls_issue-matnr }| TO lt_fields.
      APPEND |{ ls_issue-lgort }| TO lt_fields.
      APPEND |{ ls_issue-message }| TO lt_fields.

      lv_line = mo_csv->build_line( lt_fields ).
      APPEND lv_line TO rt_lines.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
