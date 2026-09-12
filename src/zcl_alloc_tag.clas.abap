CLASS zcl_alloc_tag DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_tag,
             run_id TYPE zstock_run_id,
             tag    TYPE c LENGTH 20,
           END OF ty_tag.
    TYPES ty_tag_tt TYPE STANDARD TABLE OF ty_tag WITH DEFAULT KEY.

    TYPES: BEGIN OF ty_add_input,
             tags   TYPE ty_tag_tt,
             run_id TYPE zstock_run_id,
             tag    TYPE c LENGTH 20,
           END OF ty_add_input.

    TYPES: BEGIN OF ty_query,
             tags   TYPE ty_tag_tt,
             run_id TYPE zstock_run_id,
           END OF ty_query.

    METHODS add
      IMPORTING
        is_add         TYPE ty_add_input
      RETURNING
        VALUE(rt_tags) TYPE ty_tag_tt.

    METHODS of_run
      IMPORTING
        is_query       TYPE ty_query
      RETURNING
        VALUE(rt_tags) TYPE ty_tag_tt.

ENDCLASS.


CLASS zcl_alloc_tag IMPLEMENTATION.

  METHOD add.
    rt_tags = is_add-tags.

    READ TABLE rt_tags TRANSPORTING NO FIELDS
      WITH KEY run_id = is_add-run_id
               tag = is_add-tag.
    IF sy-subrc <> 0.
      APPEND VALUE #( run_id = is_add-run_id
                      tag    = is_add-tag ) TO rt_tags.
    ENDIF.
  ENDMETHOD.

  METHOD of_run.
    LOOP AT is_query-tags INTO DATA(ls_tag).
      IF ls_tag-run_id = is_query-run_id.
        APPEND ls_tag TO rt_tags.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
