CLASS zcl_alloc_lgort_list DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_lgort_tt TYPE STANDARD TABLE OF lgort_d WITH DEFAULT KEY.

    METHODS build
      IMPORTING
        it_result       TYPE zcl_stock_allocator=>ty_result_tt
      RETURNING
        VALUE(rt_lgort) TYPE ty_lgort_tt.

ENDCLASS.


CLASS zcl_alloc_lgort_list IMPLEMENTATION.

  METHOD build.
    DATA lv_last TYPE lgort_d.

    LOOP AT it_result INTO DATA(ls_result).
      LOOP AT ls_result-allocations INTO DATA(ls_allocation).
        APPEND ls_allocation-lgort TO rt_lgort.
      ENDLOOP.
    ENDLOOP.

    SORT rt_lgort ASCENDING.

    " remove duplicates in place, keeping the sorted order
    DATA lt_unique TYPE ty_lgort_tt.
    LOOP AT rt_lgort INTO DATA(lv_lgort).
      IF lines( lt_unique ) = 0 OR lv_last <> lv_lgort.
        APPEND lv_lgort TO lt_unique.
        lv_last = lv_lgort.
      ENDIF.
    ENDLOOP.

    rt_lgort = lt_unique.
  ENDMETHOD.

ENDCLASS.
