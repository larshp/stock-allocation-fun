CLASS zcl_alloc_return_label DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_lines_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    METHODS build
      IMPORTING
        iv_rma          TYPE string
        iv_material     TYPE string
        iv_quantity     TYPE string
        iv_reason       TYPE string
      RETURNING
        VALUE(rt_lines) TYPE ty_lines_tt.

ENDCLASS.


CLASS zcl_alloc_return_label IMPLEMENTATION.

  METHOD build.
    DATA lv_line TYPE string.

    " Every value is rendered through a string template and a blank value simply
    " omits its line, so a return without a reason still labels cleanly.
    IF iv_rma IS NOT INITIAL.
      lv_line = |RMA: { iv_rma }|.
      APPEND lv_line TO rt_lines.
    ENDIF.

    IF iv_material IS NOT INITIAL.
      lv_line = |MATERIAL: { iv_material }|.
      APPEND lv_line TO rt_lines.
    ENDIF.

    IF iv_quantity IS NOT INITIAL.
      lv_line = |QUANTITY: { iv_quantity }|.
      APPEND lv_line TO rt_lines.
    ENDIF.

    IF iv_reason IS NOT INITIAL.
      lv_line = |REASON: { iv_reason }|.
      APPEND lv_line TO rt_lines.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
