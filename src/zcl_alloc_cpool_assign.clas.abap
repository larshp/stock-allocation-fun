CLASS zcl_alloc_cpool_assign DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_line,
             object TYPE string,
             pool   TYPE string,
           END OF ty_line.
    TYPES ty_line_tt TYPE STANDARD TABLE OF ty_line WITH DEFAULT KEY.

    TYPES ty_object_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    METHODS assign
      IMPORTING
        it_lines          TYPE ty_line_tt
        iv_pool           TYPE string
      RETURNING
        VALUE(rt_objects) TYPE ty_object_tt.

    METHODS is_assigned
      IMPORTING
        it_lines     TYPE ty_line_tt
        iv_object    TYPE string
      RETURNING
        VALUE(rv_ok) TYPE abap_bool.

    METHODS count
      IMPORTING
        it_lines        TYPE ty_line_tt
        iv_pool         TYPE string
      RETURNING
        VALUE(rv_count) TYPE i.

ENDCLASS.


CLASS zcl_alloc_cpool_assign IMPLEMENTATION.

  METHOD assign.
    " The objects that sit in one cost pool are gathered.
    LOOP AT it_lines INTO DATA(ls_line).
      IF ls_line-pool = iv_pool.
        APPEND ls_line-object TO rt_objects.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD is_assigned.
    " An object is assigned once it appears in any pool.
    LOOP AT it_lines INTO DATA(ls_line).
      IF ls_line-object = iv_object.
        rv_ok = abap_true.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD count.
    " The count is how many objects sit in the pool.
    LOOP AT it_lines INTO DATA(ls_line).
      IF ls_line-pool = iv_pool.
        rv_count = rv_count + 1.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
