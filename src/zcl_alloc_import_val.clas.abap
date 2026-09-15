CLASS zcl_alloc_import_val DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_name     TYPE c LENGTH 30.
    TYPES ty_value    TYPE c LENGTH 60.
    TYPES ty_name_tt  TYPE STANDARD TABLE OF ty_name WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_row,
             key   TYPE ty_name,
             value TYPE ty_value,
           END OF ty_row.
    TYPES ty_row_tt TYPE STANDARD TABLE OF ty_row WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_issue,
             row_no TYPE i,
             reason TYPE c LENGTH 40,
           END OF ty_issue.
    TYPES ty_issue_tt TYPE STANDARD TABLE OF ty_issue WITH DEFAULT KEY.

    METHODS validate
      IMPORTING
        it_rows          TYPE ty_row_tt
        it_required      TYPE ty_name_tt
      RETURNING
        VALUE(rt_issues) TYPE ty_issue_tt.

    METHODS is_valid
      IMPORTING
        it_rows         TYPE ty_row_tt
        it_required     TYPE ty_name_tt
      RETURNING
        VALUE(rv_valid) TYPE abap_bool.

ENDCLASS.


CLASS zcl_alloc_import_val IMPLEMENTATION.

  METHOD validate.
    DATA lv_row_no TYPE i.
    DATA lv_index  TYPE i.
    DATA ls_row    TYPE ty_row.
    DATA lv_field  TYPE ty_name.
    DATA lv_found  TYPE abap_bool.
    DATA ls_issue  TYPE ty_issue.

    LOOP AT it_rows INTO ls_row.
      lv_index = lv_index + 1.

      IF ls_row-value IS INITIAL.
        ls_issue-row_no = lv_index.
        ls_issue-reason = 'Empty value'.
        APPEND ls_issue TO rt_issues.
      ENDIF.
    ENDLOOP.

    LOOP AT it_required INTO lv_field.
      lv_found = abap_false.

      LOOP AT it_rows INTO ls_row.
        IF ls_row-key = lv_field.
          lv_found = abap_true.
        ENDIF.
      ENDLOOP.

      IF lv_found = abap_false.
        ls_issue-row_no = 0.
        ls_issue-reason = 'Missing field'.
        APPEND ls_issue TO rt_issues.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_valid.
    DATA lt_issues TYPE ty_issue_tt.

    lt_issues = validate( it_rows = it_rows it_required = it_required ).

    IF lines( lt_issues ) = 0.
      rv_valid = abap_true.
    ELSE.
      rv_valid = abap_false.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
