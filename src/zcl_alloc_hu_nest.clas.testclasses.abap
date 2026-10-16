CLASS ltcl_alloc_hu_nest DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_hu_nest.
    DATA mt_edg TYPE zcl_alloc_hu_nest=>ty_edge_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_id     TYPE string
        iv_parent TYPE string.

    METHODS root_of_leaf   FOR TESTING.
    METHODS root_of_root   FOR TESTING.
    METHODS unknown_is_root FOR TESTING.
    METHODS depth_of_leaf  FOR TESTING.
    METHODS depth_of_root  FOR TESTING.
    METHODS children_listed FOR TESTING.
    METHODS no_children     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_hu_nest IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_hu_nest( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_edge TYPE zcl_alloc_hu_nest=>ty_edge.

    ls_edge-hu_id = iv_id.
    ls_edge-parent_id = iv_parent.
    APPEND ls_edge TO mt_edg.
  ENDMETHOD.

  METHOD root_of_leaf.
    add( iv_id = 'B' iv_parent = 'A' ).
    add( iv_id = 'C' iv_parent = 'B' ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->root_of( it_edges = mt_edg iv_id = 'C' ) exp = 'A' ).
  ENDMETHOD.

  METHOD root_of_root.
    add( iv_id = 'B' iv_parent = 'A' ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->root_of( it_edges = mt_edg iv_id = 'A' ) exp = 'A' ).
  ENDMETHOD.

  METHOD unknown_is_root.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->root_of( it_edges = mt_edg iv_id = 'Z' ) exp = 'Z' ).
  ENDMETHOD.

  METHOD depth_of_leaf.
    add( iv_id = 'B' iv_parent = 'A' ).
    add( iv_id = 'C' iv_parent = 'B' ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->depth_of( it_edges = mt_edg iv_id = 'C' ) exp = 2 ).
  ENDMETHOD.

  METHOD depth_of_root.
    add( iv_id = 'B' iv_parent = 'A' ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->depth_of( it_edges = mt_edg iv_id = 'A' ) exp = 0 ).
  ENDMETHOD.

  METHOD children_listed.
    DATA lt_ids TYPE zcl_alloc_hu_nest=>ty_ids_tt.

    add( iv_id = 'B' iv_parent = 'A' ).
    add( iv_id = 'C' iv_parent = 'A' ).
    add( iv_id = 'D' iv_parent = 'B' ).

    lt_ids = mo_cut->children_of( it_edges = mt_edg iv_id = 'A' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_ids ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_ids[ 1 ] exp = 'B' ).
    cl_abap_unit_assert=>assert_equals( act = lt_ids[ 2 ] exp = 'C' ).
  ENDMETHOD.

  METHOD no_children.
    DATA lt_ids TYPE zcl_alloc_hu_nest=>ty_ids_tt.

    add( iv_id = 'B' iv_parent = 'A' ).

    lt_ids = mo_cut->children_of( it_edges = mt_edg iv_id = 'B' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_ids ) exp = 0 ).
  ENDMETHOD.

ENDCLASS.
