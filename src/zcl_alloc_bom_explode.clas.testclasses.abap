CLASS ltcl_alloc_bom_explode DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_bom_explode.
    DATA mt_multi TYPE zcl_alloc_bom_explode=>ty_line_tt.
    DATA mt_flat TYPE zcl_alloc_bom_explode=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_component TYPE string
        iv_level     TYPE i
        iv_multi     TYPE abap_bool.

    METHODS flattens_bom FOR TESTING.
    METHODS reads_level  FOR TESTING.
    METHODS multi_rule   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_bom_explode IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_bom_explode( ).

    add( iv_component = 'C1' iv_level = 1 iv_multi = abap_true ).
    add( iv_component = 'C2' iv_level = 2 iv_multi = abap_true ).
    add( iv_component = 'C1' iv_level = 1 iv_multi = abap_false ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_bom_explode=>ty_line.

    ls_line-component = iv_component.
    ls_line-level = iv_level.

    IF iv_multi = abap_true.
      APPEND ls_line TO mt_multi.
    ELSE.
      APPEND ls_line TO mt_flat.
    ENDIF.
  ENDMETHOD.

  METHOD flattens_bom.
    DATA lt_out TYPE zcl_alloc_bom_explode=>ty_line_tt.

    lt_out = mo_cut->explode( mt_multi ).

    cl_abap_unit_assert=>assert_equals( act = lt_out[ 1 ]-component exp = 'C1' ).
    cl_abap_unit_assert=>assert_equals( act = lt_out[ 2 ]-component exp = 'C2' ).
  ENDMETHOD.

  METHOD reads_level.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->level_of( 2 ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->level_of( 1 ) exp = 0 ).
  ENDMETHOD.

  METHOD multi_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_multi_level( mt_multi ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_multi_level( mt_flat ) exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
