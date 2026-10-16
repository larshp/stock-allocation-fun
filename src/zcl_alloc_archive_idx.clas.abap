CLASS zcl_alloc_archive_idx DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_run_id TYPE c LENGTH 20.

    TYPES: BEGIN OF ty_index,
             run_id      TYPE ty_run_id,
             archived_on TYPE d,
           END OF ty_index.
    TYPES ty_index_tt TYPE STANDARD TABLE OF ty_index WITH DEFAULT KEY.

    METHODS add
      IMPORTING
        iv_run_id TYPE ty_run_id.

    METHODS contains
      IMPORTING
        iv_run_id       TYPE ty_run_id
      RETURNING
        VALUE(rv_found) TYPE abap_bool.

    METHODS count
      RETURNING
        VALUE(rv_count) TYPE i.

    METHODS entries
      RETURNING
        VALUE(rt_index) TYPE ty_index_tt.

  PRIVATE SECTION.
    DATA mt_index TYPE ty_index_tt.

ENDCLASS.


CLASS zcl_alloc_archive_idx IMPLEMENTATION.

  METHOD add.
    DATA ls_index TYPE ty_index.

    READ TABLE mt_index INTO ls_index WITH KEY run_id = iv_run_id.

    IF sy-subrc <> 0.
      ls_index-run_id = iv_run_id.
      ls_index-archived_on = sy-datum.
      APPEND ls_index TO mt_index.
    ENDIF.
  ENDMETHOD.

  METHOD contains.
    DATA ls_index TYPE ty_index.

    READ TABLE mt_index INTO ls_index WITH KEY run_id = iv_run_id.

    IF sy-subrc = 0.
      rv_found = abap_true.
    ELSE.
      rv_found = abap_false.
    ENDIF.
  ENDMETHOD.

  METHOD count.
    rv_count = lines( mt_index ).
  ENDMETHOD.

  METHOD entries.
    rt_index = mt_index.
  ENDMETHOD.

ENDCLASS.
