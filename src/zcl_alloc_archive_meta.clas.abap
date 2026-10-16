CLASS zcl_alloc_archive_meta DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_object TYPE c LENGTH 30.
    TYPES ty_run_id TYPE c LENGTH 20.

    TYPES: BEGIN OF ty_meta,
             object      TYPE ty_object,
             run_id      TYPE ty_run_id,
             archived_on TYPE d,
             item_count  TYPE i,
           END OF ty_meta.

    METHODS build
      IMPORTING
        iv_object      TYPE ty_object
        iv_run_id      TYPE ty_run_id
        iv_item_count  TYPE i
      RETURNING
        VALUE(rs_meta) TYPE ty_meta.

    METHODS is_complete
      IMPORTING
        is_meta      TYPE ty_meta
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS describe
      IMPORTING
        is_meta        TYPE ty_meta
      RETURNING
        VALUE(rv_text) TYPE string.

ENDCLASS.


CLASS zcl_alloc_archive_meta IMPLEMENTATION.

  METHOD build.
    rs_meta-object = iv_object.
    rs_meta-run_id = iv_run_id.
    rs_meta-item_count = iv_item_count.

    IF rs_meta-item_count < 0.
      rs_meta-item_count = 0.
    ENDIF.

    rs_meta-archived_on = sy-datum.
  ENDMETHOD.

  METHOD is_complete.
    IF is_meta-object IS INITIAL
      OR is_meta-run_id IS INITIAL
      OR is_meta-item_count <= 0.
      rv_ok = abap_false.
    ELSE.
      rv_ok = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD describe.
    rv_text = |{ is_meta-object }/{ is_meta-run_id }: { is_meta-item_count } items|.
  ENDMETHOD.

ENDCLASS.
