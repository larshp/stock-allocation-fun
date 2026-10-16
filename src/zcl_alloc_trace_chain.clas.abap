CLASS zcl_alloc_trace_chain DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_link,
             from_node TYPE string,
             to_node   TYPE string,
           END OF ty_link.
    TYPES ty_link_tt TYPE STANDARD TABLE OF ty_link WITH DEFAULT KEY.

    TYPES ty_text_tt TYPE STANDARD TABLE OF string WITH DEFAULT KEY.

    METHODS chain
      IMPORTING
        it_links        TYPE ty_link_tt
        iv_node         TYPE string
      RETURNING
        VALUE(rt_nodes) TYPE ty_text_tt.

ENDCLASS.


CLASS zcl_alloc_trace_chain IMPLEMENTATION.

  METHOD chain.
    DATA lt_path    TYPE ty_text_tt.
    DATA lv_current TYPE string.
    DATA lv_steps   TYPE i.
    DATA lv_index   TYPE i.
    DATA lv_value   TYPE string.

    lv_current = iv_node.
    APPEND lv_current TO lt_path.

    " Walk from the node to its predecessor until no link leads further. At most
    " one step per link is taken, so a cycle terminates instead of looping.
    WHILE lv_steps < lines( it_links ).
      lv_steps = lv_steps + 1.

      READ TABLE it_links INTO DATA(ls_link)
        WITH KEY to_node = lv_current.
      IF sy-subrc <> 0.
        EXIT.
      ENDIF.

      lv_current = ls_link-from_node.
      APPEND lv_current TO lt_path.
    ENDWHILE.

    " The walk collected the node first and the root last, so it is emitted in
    " reverse to read root-to-node.
    lv_index = lines( lt_path ).
    WHILE lv_index >= 1.
      lv_value = lt_path[ lv_index ].
      APPEND lv_value TO rt_nodes.
      lv_index = lv_index - 1.
    ENDWHILE.
  ENDMETHOD.

ENDCLASS.
