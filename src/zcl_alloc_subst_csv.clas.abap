CLASS zcl_alloc_subst_csv DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_lines_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    METHODS constructor.

    METHODS build
      IMPORTING
        is_result       TYPE zcl_alloc_subst_chain=>ty_result
      RETURNING
        VALUE(rt_lines) TYPE ty_lines_tt.

  PRIVATE SECTION.
    DATA mo_csv TYPE REF TO zcl_alloc_csv.

ENDCLASS.


CLASS zcl_alloc_subst_csv IMPLEMENTATION.

  METHOD constructor.
    mo_csv = NEW zcl_alloc_csv( ).
  ENDMETHOD.

  METHOD build.
    DATA lt_fields TYPE zcl_alloc_csv=>ty_field_tt.
    DATA lv_line   TYPE string.
    DATA lv_index  TYPE i.

    APPEND 'STEP' TO lt_fields.
    APPEND 'MATNR' TO lt_fields.
    lv_line = mo_csv->build_line( lt_fields ).
    APPEND lv_line TO rt_lines.

    LOOP AT is_result-path INTO DATA(lv_matnr).
      lv_index = lv_index + 1.

      CLEAR lt_fields.
      APPEND |{ lv_index }| TO lt_fields.
      APPEND |{ lv_matnr }| TO lt_fields.

      lv_line = mo_csv->build_line( lt_fields ).
      APPEND lv_line TO rt_lines.
    ENDLOOP.

    CLEAR lt_fields.
    APPEND 'FINAL' TO lt_fields.
    APPEND |{ is_result-final_matnr }| TO lt_fields.
    lv_line = mo_csv->build_line( lt_fields ).
    APPEND lv_line TO rt_lines.

    CLEAR lt_fields.
    APPEND 'STEPS' TO lt_fields.
    APPEND |{ is_result-steps }| TO lt_fields.
    lv_line = mo_csv->build_line( lt_fields ).
    APPEND lv_line TO rt_lines.
  ENDMETHOD.

ENDCLASS.
