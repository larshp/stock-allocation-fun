CLASS zcl_alloc_dupc_csv DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_lines_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    METHODS constructor.

    METHODS build
      IMPORTING
        it_dups         TYPE zcl_alloc_duplicate_check=>ty_dup_tt
      RETURNING
        VALUE(rt_lines) TYPE ty_lines_tt.

  PRIVATE SECTION.
    DATA mo_csv TYPE REF TO zcl_alloc_csv.

ENDCLASS.


CLASS zcl_alloc_dupc_csv IMPLEMENTATION.

  METHOD constructor.
    mo_csv = NEW zcl_alloc_csv( ).
  ENDMETHOD.

  METHOD build.
    DATA lt_fields TYPE zcl_alloc_csv=>ty_field_tt.
    DATA lv_line   TYPE string.

    APPEND 'ID' TO lt_fields.
    APPEND 'COUNT' TO lt_fields.
    lv_line = mo_csv->build_line( lt_fields ).
    APPEND lv_line TO rt_lines.

    LOOP AT it_dups INTO DATA(ls_dup).
      CLEAR lt_fields.
      APPEND |{ ls_dup-id }| TO lt_fields.
      APPEND |{ ls_dup-count }| TO lt_fields.

      lv_line = mo_csv->build_line( lt_fields ).
      APPEND lv_line TO rt_lines.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
