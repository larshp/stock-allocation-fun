CLASS ltcl_alloc_trace_chain DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_trace_chain.
    DATA mt_lin TYPE zcl_alloc_trace_chain=>ty_link_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_from TYPE string
        iv_to   TYPE string.

    METHODS root_first   FOR TESTING.
    METHODS single_node  FOR TESTING.
    METHODS unknown_node FOR TESTING.
    METHODS cycle_ends   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_trace_chain IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_trace_chain( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_link TYPE zcl_alloc_trace_chain=>ty_link.

    ls_link-from_node = iv_from.
    ls_link-to_node = iv_to.
    APPEND ls_link TO mt_lin.
  ENDMETHOD.

  METHOD root_first.
    DATA lt_nodes TYPE zcl_alloc_trace_chain=>ty_text_tt.

    add( iv_from = 'RAW' iv_to = 'BATCH' ).
    add( iv_from = 'BATCH' iv_to = 'CARTON' ).

    lt_nodes = mo_cut->chain( it_links = mt_lin iv_node = 'CARTON' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_nodes ) exp = 3 ).
    cl_abap_unit_assert=>assert_equals( act = lt_nodes[ 1 ] exp = 'RAW' ).
    cl_abap_unit_assert=>assert_equals( act = lt_nodes[ 3 ] exp = 'CARTON' ).
  ENDMETHOD.

  METHOD single_node.
    DATA lt_nodes TYPE zcl_alloc_trace_chain=>ty_text_tt.

    lt_nodes = mo_cut->chain( it_links = mt_lin iv_node = 'ALONE' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_nodes ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_nodes[ 1 ] exp = 'ALONE' ).
  ENDMETHOD.

  METHOD unknown_node.
    DATA lt_nodes TYPE zcl_alloc_trace_chain=>ty_text_tt.

    add( iv_from = 'A' iv_to = 'B' ).

    lt_nodes = mo_cut->chain( it_links = mt_lin iv_node = 'Z' ).

    cl_abap_unit_assert=>assert_equals( act = lt_nodes[ 1 ] exp = 'Z' ).
  ENDMETHOD.

  METHOD cycle_ends.
    DATA lt_nodes TYPE zcl_alloc_trace_chain=>ty_text_tt.

    add( iv_from = 'A' iv_to = 'B' ).
    add( iv_from = 'B' iv_to = 'A' ).

    lt_nodes = mo_cut->chain( it_links = mt_lin iv_node = 'B' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_nodes ) exp = 3 ).
  ENDMETHOD.

ENDCLASS.
