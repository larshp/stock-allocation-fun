CLASS ltcl_alloc_val_compare_rep DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_val_compare_rep.
    DATA mt_line TYPE zcl_alloc_val_compare_rep=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_material  TYPE matnr
        iv_old_value TYPE i
        iv_new_value TYPE i.

    METHODS compares_values FOR TESTING.
    METHODS counts_changed  FOR TESTING.
    METHODS same_rule       FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_val_compare_rep IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_val_compare_rep( ).

    add( iv_material = 'M1' iv_old_value = 1000 iv_new_value = 1100 ).
    add( iv_material = 'M2' iv_old_value = 600 iv_new_value = 600 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_val_compare_rep=>ty_line.

    ls_line-material = iv_material.
    ls_line-old_value = iv_old_value.
    ls_line-new_value = iv_new_value.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD compares_values.
    DATA lt_deltas TYPE zcl_alloc_val_compare_rep=>ty_delta_tt.

    lt_deltas = mo_cut->compare( mt_line ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_deltas ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_deltas[ 1 ]-material exp = 'M1' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_deltas[ 1 ]-delta exp = 100 ).
  ENDMETHOD.

  METHOD counts_changed.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->changed_count( mt_line ) exp = 1 ).
  ENDMETHOD.

  METHOD same_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_same( iv_old_value = 600 iv_new_value = 600 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_same( iv_old_value = 600 iv_new_value = 700 )
      exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
