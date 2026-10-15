CLASS ltcl_alloc_val_group DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_val_group.
    DATA mt_line TYPE zcl_alloc_val_group=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_group TYPE string
        iv_value TYPE i.

    METHODS totals_groups  FOR TESTING.
    METHODS empty_rule     FOR TESTING.
    METHODS counts_groups  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_val_group IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_val_group( ).

    add( iv_group = 'G1' iv_value = 1000 ).
    add( iv_group = 'G2' iv_value = 600 ).
    add( iv_group = 'G1' iv_value = 200 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_val_group=>ty_line.

    ls_line-group = iv_group.
    ls_line-value = iv_value.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD totals_groups.
    DATA lt_totals TYPE zcl_alloc_val_group=>ty_values_tt.

    lt_totals = mo_cut->group_totals( mt_line ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_totals ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = lt_totals[ 1 ] exp = 1200 ).
    cl_abap_unit_assert=>assert_equals( act = lt_totals[ 2 ] exp = 600 ).
  ENDMETHOD.

  METHOD empty_rule.
    DATA lt_empty TYPE zcl_alloc_val_group=>ty_line_tt.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_empty( lt_empty ) exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_empty( mt_line ) exp = abap_false ).
  ENDMETHOD.

  METHOD counts_groups.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->group_count( mt_line ) exp = 2 ).
  ENDMETHOD.

ENDCLASS.
