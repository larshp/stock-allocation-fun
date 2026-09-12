CLASS zcl_alloc_plant_list DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_werks_tt TYPE STANDARD TABLE OF werks_d WITH DEFAULT KEY.

    METHODS build
      IMPORTING
        it_overview     TYPE zcl_alloc_run_report=>ty_overview_tt
      RETURNING
        VALUE(rt_werks) TYPE ty_werks_tt.

ENDCLASS.


CLASS zcl_alloc_plant_list IMPLEMENTATION.

  METHOD build.
    DATA lt_work TYPE zcl_alloc_run_report=>ty_overview_tt.
    DATA lv_last TYPE werks_d.

    lt_work = it_overview.
    SORT lt_work BY werks ASCENDING.

    LOOP AT lt_work INTO DATA(ls_row).
      IF lines( rt_werks ) = 0 OR lv_last <> ls_row-werks.
        APPEND ls_row-werks TO rt_werks.
        lv_last = ls_row-werks.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
