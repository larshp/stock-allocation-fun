CLASS zcl_alloc_material_list DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_matnr_tt TYPE STANDARD TABLE OF matnr WITH DEFAULT KEY.

    METHODS build
      IMPORTING
        it_overview     TYPE zcl_alloc_run_report=>ty_overview_tt
      RETURNING
        VALUE(rt_matnr) TYPE ty_matnr_tt.

ENDCLASS.


CLASS zcl_alloc_material_list IMPLEMENTATION.

  METHOD build.
    DATA lt_work TYPE zcl_alloc_run_report=>ty_overview_tt.
    DATA lv_last TYPE matnr.

    lt_work = it_overview.
    SORT lt_work BY matnr ASCENDING.

    LOOP AT lt_work INTO DATA(ls_row).
      IF lines( rt_matnr ) = 0 OR lv_last <> ls_row-matnr.
        APPEND ls_row-matnr TO rt_matnr.
        lv_last = ls_row-matnr.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
