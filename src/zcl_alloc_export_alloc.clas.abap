CLASS zcl_alloc_export_alloc DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_lines_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    METHODS constructor.

    METHODS build
      IMPORTING
        it_result       TYPE zcl_stock_allocator=>ty_result_tt
      RETURNING
        VALUE(rt_lines) TYPE ty_lines_tt.

  PRIVATE SECTION.
    DATA mo_csv TYPE REF TO zcl_alloc_csv.

ENDCLASS.


CLASS zcl_alloc_export_alloc IMPLEMENTATION.

  METHOD constructor.
    mo_csv = NEW zcl_alloc_csv( ).
  ENDMETHOD.

  METHOD build.
    DATA lt_fields TYPE zcl_alloc_csv=>ty_field_tt.
    DATA lv_line   TYPE string.

    APPEND 'REQUIREMENT_ID' TO lt_fields.
    APPEND 'MATNR' TO lt_fields.
    APPEND 'LGORT' TO lt_fields.
    APPEND 'CHARG' TO lt_fields.
    APPEND 'QUANTITY' TO lt_fields.
    lv_line = mo_csv->build_line( lt_fields ).
    APPEND lv_line TO rt_lines.

    LOOP AT it_result INTO DATA(ls_result).
      LOOP AT ls_result-allocations INTO DATA(ls_allocation).
        IF ls_allocation-quantity <= 0.
          CONTINUE.
        ENDIF.

        CLEAR lt_fields.
        APPEND |{ ls_result-requirement_id }| TO lt_fields.
        APPEND |{ ls_allocation-matnr }| TO lt_fields.
        APPEND |{ ls_allocation-lgort }| TO lt_fields.
        APPEND |{ ls_allocation-charg }| TO lt_fields.
        APPEND |{ ls_allocation-quantity }| TO lt_fields.

        lv_line = mo_csv->build_line( lt_fields ).
        APPEND lv_line TO rt_lines.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
