CLASS zcl_alloc_serial_trace DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_link,
             parent TYPE i,
             child  TYPE i,
           END OF ty_link.
    TYPES ty_link_tt TYPE STANDARD TABLE OF ty_link WITH DEFAULT KEY.

    TYPES ty_int_tt TYPE STANDARD TABLE OF i WITH DEFAULT KEY.

    METHODS children
      IMPORTING
        it_links           TYPE ty_link_tt
        iv_parent          TYPE i
      RETURNING
        VALUE(rt_children) TYPE ty_int_tt.

    METHODS descendants
      IMPORTING
        it_links      TYPE ty_link_tt
        iv_parent     TYPE i
      RETURNING
        VALUE(rt_all) TYPE ty_int_tt.

ENDCLASS.


CLASS zcl_alloc_serial_trace IMPLEMENTATION.

  METHOD children.
    LOOP AT it_links INTO DATA(ls_link).
      IF ls_link-parent = iv_parent.
        APPEND ls_link-child TO rt_children.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  METHOD descendants.
    DATA lt_queue   TYPE ty_int_tt.
    DATA lo_seen    TYPE REF TO zcl_alloc_key_map.
    DATA lv_key     TYPE string.
    DATA lv_current TYPE i.
    DATA lv_steps   TYPE i.

    " Breadth-first over the packing links. The root is marked as seen first, so
    " it is never reported as its own descendant and a cycle cannot loop.
    lo_seen = NEW zcl_alloc_key_map( ).
    lv_key = |{ iv_parent }|.
    lo_seen->put( iv_key   = lv_key
                  iv_value = 1 ).
    APPEND iv_parent TO lt_queue.

    WHILE lines( lt_queue ) > 0 AND lv_steps <= lines( it_links ) + 1.
      lv_steps = lv_steps + 1.

      READ TABLE lt_queue INTO lv_current INDEX 1.
      DELETE lt_queue INDEX 1.

      LOOP AT it_links INTO DATA(ls_link).
        IF ls_link-parent <> lv_current.
          CONTINUE.
        ENDIF.

        lv_key = |{ ls_link-child }|.
        IF lo_seen->has( iv_key = lv_key ) = abap_true.
          CONTINUE.
        ENDIF.

        lo_seen->put( iv_key   = lv_key
                      iv_value = 1 ).
        APPEND ls_link-child TO rt_all.
        APPEND ls_link-child TO lt_queue.
      ENDLOOP.
    ENDWHILE.
  ENDMETHOD.

ENDCLASS.
