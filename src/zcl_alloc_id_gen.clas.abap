CLASS zcl_alloc_id_gen DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES ty_id TYPE c LENGTH 20.

    TYPES: BEGIN OF ty_input,
             prefix TYPE c LENGTH 10,
             number TYPE i,
           END OF ty_input.

    METHODS generate
      IMPORTING
        is_input     TYPE ty_input
      RETURNING
        VALUE(rv_id) TYPE ty_id.

ENDCLASS.


CLASS zcl_alloc_id_gen IMPLEMENTATION.

  METHOD generate.
    DATA lv_text TYPE string.
    DATA lv_pad  TYPE i.
    DATA lv_id   TYPE string.

    lv_text = |{ is_input-number }|.

    lv_pad = 4 - strlen( lv_text ).
    WHILE lv_pad > 0.
      lv_text = '0' && lv_text.
      lv_pad = lv_pad - 1.
    ENDWHILE.

    lv_id = is_input-prefix.
    lv_id = lv_id && lv_text.

    rv_id = lv_id.
  ENDMETHOD.

ENDCLASS.
