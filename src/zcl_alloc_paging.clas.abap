CLASS zcl_alloc_paging DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_input,
             total     TYPE i,
             page_size TYPE i,
             page      TYPE i,
           END OF ty_input.

    TYPES: BEGIN OF ty_page,
             from_index  TYPE i,
             to_index    TYPE i,
             total_pages TYPE i,
             count       TYPE i,
           END OF ty_page.

    METHODS page
      IMPORTING
        is_input       TYPE ty_input
      RETURNING
        VALUE(rs_page) TYPE ty_page.

ENDCLASS.


CLASS zcl_alloc_paging IMPLEMENTATION.

  METHOD page.
    DATA lv_pages TYPE i.

    IF is_input-page_size <= 0.
      rs_page-from_index = 1.
      rs_page-to_index = is_input-total.
      rs_page-total_pages = 1.
      rs_page-count = is_input-total.
      RETURN.
    ENDIF.

    lv_pages = is_input-total DIV is_input-page_size.
    IF is_input-total MOD is_input-page_size > 0.
      lv_pages = lv_pages + 1.
    ENDIF.
    IF lv_pages = 0.
      lv_pages = 1.
    ENDIF.

    rs_page-total_pages = lv_pages.

    IF is_input-page < 1 OR is_input-page > lv_pages.
      RETURN.
    ENDIF.

    rs_page-from_index = ( is_input-page - 1 ) * is_input-page_size + 1.
    rs_page-to_index = rs_page-from_index + is_input-page_size - 1.
    IF rs_page-to_index > is_input-total.
      rs_page-to_index = is_input-total.
    ENDIF.

    IF rs_page-to_index >= rs_page-from_index.
      rs_page-count = rs_page-to_index - rs_page-from_index + 1.
    ENDIF.
  ENDMETHOD.

ENDCLASS.
