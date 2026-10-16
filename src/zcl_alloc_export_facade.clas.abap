CLASS zcl_alloc_export_facade DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_lines_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    TYPES ty_kind TYPE c LENGTH 20.

    TYPES: BEGIN OF ty_request,
             kind   TYPE ty_kind,
             result TYPE zcl_stock_allocator=>ty_result_tt,
           END OF ty_request.

    METHODS constructor.

    METHODS as_csv
      IMPORTING
        is_request      TYPE ty_request
      RETURNING
        VALUE(rt_lines) TYPE ty_lines_tt.

    METHODS as_json
      IMPORTING
        is_request     TYPE ty_request
      RETURNING
        VALUE(rv_json) TYPE string.

  PRIVATE SECTION.
    DATA mo_alloc     TYPE REF TO zcl_alloc_export_alloc.
    DATA mo_alloc_mat TYPE REF TO zcl_alloc_export_alloc_mat.
    DATA mo_pick_list TYPE REF TO zcl_alloc_pickl_csv.
    DATA mo_json      TYPE REF TO zcl_alloc_export_alloc_json.
    DATA mo_json_mat  TYPE REF TO zcl_alloc_export_alloc_mjson.

ENDCLASS.


CLASS zcl_alloc_export_facade IMPLEMENTATION.

  METHOD constructor.
    mo_alloc = NEW zcl_alloc_export_alloc( ).
    mo_alloc_mat = NEW zcl_alloc_export_alloc_mat( ).
    mo_pick_list = NEW zcl_alloc_pickl_csv( ).
    mo_json = NEW zcl_alloc_export_alloc_json( ).
    mo_json_mat = NEW zcl_alloc_export_alloc_mjson( ).
  ENDMETHOD.

  METHOD as_csv.
    DATA lt_picks  TYPE zcl_alloc_pick_list=>ty_line_tt.
    DATA lo_picker TYPE REF TO zcl_alloc_pick_list.

    CASE is_request-kind.
      WHEN 'ALLOC'.
        rt_lines = mo_alloc->build( is_request-result ).
      WHEN 'MAT'.
        rt_lines = mo_alloc_mat->build( is_request-result ).
      WHEN 'PICK'.
        lo_picker = NEW zcl_alloc_pick_list( ).
        lt_picks = lo_picker->build( is_request-result ).
        rt_lines = mo_pick_list->build( lt_picks ).
    ENDCASE.
  ENDMETHOD.

  METHOD as_json.
    CASE is_request-kind.
      WHEN 'ALLOC'.
        rv_json = mo_json->build( is_request-result ).
      WHEN 'MAT'.
        rv_json = mo_json_mat->build( is_request-result ).
      WHEN OTHERS.
        rv_json = '[]'.
    ENDCASE.
  ENDMETHOD.

ENDCLASS.
