CLASS ltcl_alloc_cpool_assign DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_cpool_assign.
    DATA mt_line TYPE zcl_alloc_cpool_assign=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_object TYPE string
        iv_pool   TYPE string.

    METHODS assigns_objects FOR TESTING.
    METHODS assigned_rule   FOR TESTING.
    METHODS counts_pool     FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_cpool_assign IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_cpool_assign( ).

    add( iv_object = 'O1' iv_pool = 'P1' ).
    add( iv_object = 'O2' iv_pool = 'P2' ).
    add( iv_object = 'O3' iv_pool = 'P1' ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_cpool_assign=>ty_line.

    ls_line-object = iv_object.
    ls_line-pool = iv_pool.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD assigns_objects.
    DATA lt_object TYPE zcl_alloc_cpool_assign=>ty_object_tt.

    lt_object = mo_cut->assign( it_lines = mt_line iv_pool = 'P1' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_object ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_object[ 1 ] exp = 'O1' ).
    cl_abap_unit_assert=>assert_equals( act = lt_object[ 2 ] exp = 'O3' ).
  ENDMETHOD.

  METHOD assigned_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_assigned( it_lines = mt_line iv_object = 'O2' )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_assigned( it_lines = mt_line iv_object = 'O9' )
      exp = abap_false ).
  ENDMETHOD.

  METHOD counts_pool.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->count( it_lines = mt_line iv_pool = 'P1' )
      exp = 2 ).
  ENDMETHOD.

ENDCLASS.
