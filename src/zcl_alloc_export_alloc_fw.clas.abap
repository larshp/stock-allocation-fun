CLASS zcl_alloc_export_alloc_fw DEFINITION
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
    DATA mo_fw TYPE REF TO zcl_alloc_fixed_width.

ENDCLASS.


CLASS zcl_alloc_export_alloc_fw IMPLEMENTATION.

  METHOD constructor.
    mo_fw = NEW zcl_alloc_fixed_width( ).
  ENDMETHOD.

  METHOD build.
    DATA lt_widths TYPE zcl_alloc_fixed_width=>ty_width_tt.
    DATA lt_header TYPE zcl_alloc_fixed_width=>ty_field_tt.
    DATA lt_fields TYPE zcl_alloc_fixed_width=>ty_field_tt.
    DATA lv_line   TYPE string.

    APPEND 20 TO lt_widths.
    APPEND 18 TO lt_widths.
    APPEND 6 TO lt_widths.
    APPEND 10 TO lt_widths.
    APPEND 12 TO lt_widths.

    APPEND 'REQUIREMENT' TO lt_header.
    APPEND 'MATERIAL' TO lt_header.
    APPEND 'LGORT' TO lt_header.
    APPEND 'BATCH' TO lt_header.
    APPEND 'QUANTITY' TO lt_header.

    lv_line = mo_fw->build_line( it_fields = lt_header
                                 it_widths = lt_widths ).
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

        lv_line = mo_fw->build_line( it_fields = lt_fields
                                     it_widths = lt_widths ).
        APPEND lv_line TO rt_lines.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
