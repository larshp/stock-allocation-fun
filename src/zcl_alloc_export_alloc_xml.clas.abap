CLASS zcl_alloc_export_alloc_xml DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_lines_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    METHODS build
      IMPORTING
        it_result       TYPE zcl_stock_allocator=>ty_result_tt
      RETURNING
        VALUE(rt_lines) TYPE ty_lines_tt.

  PRIVATE SECTION.
    METHODS escape
      IMPORTING
        iv_value       TYPE c
      RETURNING
        VALUE(rv_text) TYPE string.

ENDCLASS.


CLASS zcl_alloc_export_alloc_xml IMPLEMENTATION.

  METHOD escape.
    DATA lv_text TYPE string.

    lv_text = iv_value.
    replace all occurrences of '&' in lv_text with '&amp;'.
    replace all occurrences of '<' in lv_text with '&lt;'.
    replace all occurrences of '>' in lv_text with '&gt;'.

    rv_text = lv_text.
  ENDMETHOD.

  METHOD build.
    DATA lv_value TYPE string.

    APPEND '<?xml version="1.0" encoding="UTF-8"?>' TO rt_lines.
    APPEND '<allocations>' TO rt_lines.

    LOOP AT it_result INTO DATA(ls_result).
      APPEND |  <allocation requirement_id="{ escape( ls_result-requirement_id ) }">|
        TO rt_lines.

      LOOP AT ls_result-allocations INTO DATA(ls_allocation).
        IF ls_allocation-quantity <= 0.
          CONTINUE.
        ENDIF.

        lv_value = escape( ls_allocation-matnr ).
        APPEND |    <matnr>{ lv_value }</matnr>| TO rt_lines.

        lv_value = escape( ls_allocation-lgort ).
        APPEND |    <lgort>{ lv_value }</lgort>| TO rt_lines.

        lv_value = escape( ls_allocation-charg ).
        APPEND |    <charg>{ lv_value }</charg>| TO rt_lines.

        APPEND |    <quantity>{ ls_allocation-quantity }</quantity>|
          TO rt_lines.
      ENDLOOP.

      APPEND '  </allocation>' TO rt_lines.
    ENDLOOP.

    APPEND '</allocations>' TO rt_lines.
  ENDMETHOD.

ENDCLASS.
