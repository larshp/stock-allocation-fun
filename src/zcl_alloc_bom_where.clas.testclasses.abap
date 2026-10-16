CLASS ltcl_alloc_bom_where DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_bom_where.
    DATA mt_line TYPE zcl_alloc_bom_where=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_component TYPE string
        iv_parent    TYPE string.

    METHODS finds_parents FOR TESTING.
    METHODS used_rule     FOR TESTING.
    METHODS counts_parents FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_bom_where IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_bom_where( ).

    add( iv_component = 'C1' iv_parent = 'P1' ).
    add( iv_component = 'C1' iv_parent = 'P2' ).
    add( iv_component = 'C2' iv_parent = 'P1' ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_bom_where=>ty_line.

    ls_line-component = iv_component.
    ls_line-parent = iv_parent.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD finds_parents.
    DATA lt_used TYPE zcl_alloc_bom_where=>ty_line_tt.

    lt_used = mo_cut->used_in( it_lines = mt_line iv_component = 'C1' ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_used ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_used[ 1 ]-parent exp = 'P1' ).
  ENDMETHOD.

  METHOD used_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_used( it_lines = mt_line iv_component = 'C1' )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_used( it_lines = mt_line iv_component = 'C9' )
      exp = abap_false ).
  ENDMETHOD.

  METHOD counts_parents.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->count( it_lines = mt_line iv_component = 'C1' )
      exp = 2 ).
  ENDMETHOD.

ENDCLASS.
