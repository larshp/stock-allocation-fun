CLASS zcl_alloc_export_alloc_md DEFINITION
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

ENDCLASS.


CLASS zcl_alloc_export_alloc_md IMPLEMENTATION.

  METHOD build.
    APPEND '| Requirement | Material | Location | Batch | Quantity |'
      TO rt_lines.
    APPEND '| --- | --- | --- | --- | --- |' TO rt_lines.

    LOOP AT it_result INTO DATA(ls_result).
      LOOP AT ls_result-allocations INTO DATA(ls_allocation).
        IF ls_allocation-quantity <= 0.
          CONTINUE.
        ENDIF.

        APPEND |\| { ls_result-requirement_id } \| { ls_allocation-matnr } \| | &&
               |{ ls_allocation-lgort } \| { ls_allocation-charg } \| | &&
               |{ ls_allocation-quantity } \||
          TO rt_lines.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
