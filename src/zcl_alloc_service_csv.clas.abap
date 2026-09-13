CLASS zcl_alloc_service_csv DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_lines_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    METHODS constructor.

    METHODS build
      IMPORTING
        it_levels       TYPE zcl_alloc_service_level=>ty_level_tt
      RETURNING
        VALUE(rt_lines) TYPE ty_lines_tt.

  PRIVATE SECTION.
    DATA mo_csv TYPE REF TO zcl_alloc_csv.

ENDCLASS.


CLASS zcl_alloc_service_csv IMPLEMENTATION.

  METHOD constructor.
    mo_csv = NEW zcl_alloc_csv( ).
  ENDMETHOD.

  METHOD build.
    DATA lt_fields TYPE zcl_alloc_csv=>ty_field_tt.
    DATA lv_line   TYPE string.

    APPEND 'MATNR' TO lt_fields.
    APPEND 'REQUESTED_QTY' TO lt_fields.
    APPEND 'ALLOCATED_QTY' TO lt_fields.
    APPEND 'SHORTAGE_QTY' TO lt_fields.
    APPEND 'FILL_RATE_PCT' TO lt_fields.
    APPEND 'LINES' TO lt_fields.
    lv_line = mo_csv->build_line( lt_fields ).
    APPEND lv_line TO rt_lines.

    LOOP AT it_levels INTO DATA(ls_level).
      CLEAR lt_fields.
      APPEND |{ ls_level-matnr }| TO lt_fields.
      APPEND |{ ls_level-requested_qty }| TO lt_fields.
      APPEND |{ ls_level-allocated_qty }| TO lt_fields.
      APPEND |{ ls_level-shortage_qty }| TO lt_fields.
      APPEND |{ ls_level-fill_rate_pct }| TO lt_fields.
      APPEND |{ ls_level-lines }| TO lt_fields.

      lv_line = mo_csv->build_line( lt_fields ).
      APPEND lv_line TO rt_lines.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
