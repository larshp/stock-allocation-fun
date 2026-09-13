CLASS zcl_alloc_format_list DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_names_tt TYPE STANDARD TABLE OF zcl_alloc_format_registry=>ty_name
      WITH DEFAULT KEY.

    METHODS names
      IMPORTING
        it_entries      TYPE zcl_alloc_format_registry=>ty_entry_tt
      RETURNING
        VALUE(rt_names) TYPE ty_names_tt.

    METHODS count
      IMPORTING
        it_entries      TYPE zcl_alloc_format_registry=>ty_entry_tt
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_format_list IMPLEMENTATION.

  METHOD names.
    LOOP AT it_entries INTO DATA(ls_entry).
      APPEND ls_entry-name TO rt_names.
    ENDLOOP.

    SORT rt_names ASCENDING.

    " remove duplicates in place, keeping the sorted order
    DATA lt_unique TYPE ty_names_tt.
    DATA lv_last   TYPE zcl_alloc_format_registry=>ty_name.

    LOOP AT rt_names INTO DATA(lv_name).
      IF lines( lt_unique ) = 0 OR lv_last <> lv_name.
        APPEND lv_name TO lt_unique.
        lv_last = lv_name.
      ENDIF.
    ENDLOOP.

    rt_names = lt_unique.
  ENDMETHOD.

  METHOD count.
    rv_count = lines( names( it_entries ) ).
  ENDMETHOD.

ENDCLASS.
