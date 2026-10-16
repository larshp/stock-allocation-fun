CLASS ltcl_alloc_serial_trace DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_serial_trace.
    DATA mt_lin TYPE zcl_alloc_serial_trace=>ty_link_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_parent TYPE i
        iv_child  TYPE i.

    METHODS direct_children FOR TESTING.
    METHODS all_levels      FOR TESTING.
    METHODS no_children     FOR TESTING.
    METHODS cycle_safe      FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_serial_trace IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_serial_trace( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_link TYPE zcl_alloc_serial_trace=>ty_link.

    ls_link-parent = iv_parent.
    ls_link-child = iv_child.
    APPEND ls_link TO mt_lin.
  ENDMETHOD.

  METHOD direct_children.
    DATA lt_children TYPE zcl_alloc_serial_trace=>ty_int_tt.

    add( iv_parent = 1 iv_child = 2 ).
    add( iv_parent = 1 iv_child = 3 ).
    add( iv_parent = 2 iv_child = 4 ).

    lt_children = mo_cut->children( it_links = mt_lin iv_parent = 1 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_children ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_children[ 1 ] exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_children[ 2 ] exp = 3 ).
  ENDMETHOD.

  METHOD all_levels.
    DATA lt_all TYPE zcl_alloc_serial_trace=>ty_int_tt.

    add( iv_parent = 1 iv_child = 2 ).
    add( iv_parent = 2 iv_child = 4 ).
    add( iv_parent = 1 iv_child = 3 ).

    lt_all = mo_cut->descendants( it_links = mt_lin iv_parent = 1 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_all ) exp = 3 ).
  ENDMETHOD.

  METHOD no_children.
    DATA lt_all TYPE zcl_alloc_serial_trace=>ty_int_tt.

    add( iv_parent = 1 iv_child = 2 ).

    lt_all = mo_cut->descendants( it_links = mt_lin iv_parent = 9 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_all ) exp = 0 ).
  ENDMETHOD.

  METHOD cycle_safe.
    DATA lt_all TYPE zcl_alloc_serial_trace=>ty_int_tt.

    add( iv_parent = 1 iv_child = 2 ).
    add( iv_parent = 2 iv_child = 1 ).

    lt_all = mo_cut->descendants( it_links = mt_lin iv_parent = 1 ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_all ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals( act = lt_all[ 1 ] exp = 2 ).
  ENDMETHOD.

ENDCLASS.
