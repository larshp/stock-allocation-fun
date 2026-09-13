CLASS zcl_alloc_pickc_csv DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_lines_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    METHODS constructor.

    METHODS build
      IMPORTING
        it_lines        TYPE zcl_alloc_pick_confirm=>ty_line_tt
      RETURNING
        VALUE(rt_lines) TYPE ty_lines_tt.

  PRIVATE SECTION.
    DATA mo_csv TYPE REF TO zcl_alloc_csv.

ENDCLASS.


CLASS zcl_alloc_pickc_csv IMPLEMENTATION.

  METHOD constructor.
    mo_csv = NEW zcl_alloc_csv( ).
  ENDMETHOD.

  METHOD build.
    DATA lt_fields TYPE zcl_alloc_csv=>ty_field_tt.
    DATA lv_line   TYPE string.
    DATA lv_flag   TYPE string.

    APPEND 'INDEX' TO lt_fields.
    APPEND 'PLANNED' TO lt_fields.
    APPEND 'CONFIRMED' TO lt_fields.
    APPEND 'DIFFERENCE' TO lt_fields.
    APPEND 'COMPLETE' TO lt_fields.
    lv_line = mo_csv->build_line( lt_fields ).
    APPEND lv_line TO rt_lines.

    LOOP AT it_lines INTO DATA(ls_pick).
      lv_flag = 'N'.
      IF ls_pick-complete = abap_true.
        lv_flag = 'Y'.
      ENDIF.

      CLEAR lt_fields.
      APPEND |{ ls_pick-index }| TO lt_fields.
      APPEND |{ ls_pick-planned }| TO lt_fields.
      APPEND |{ ls_pick-confirmed }| TO lt_fields.
      APPEND |{ ls_pick-difference }| TO lt_fields.
      APPEND lv_flag TO lt_fields.

      lv_line = mo_csv->build_line( lt_fields ).
      APPEND lv_line TO rt_lines.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
