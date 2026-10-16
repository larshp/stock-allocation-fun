CLASS ltcl_alloc_val_rollup DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_val_rollup.
    DATA mt_line TYPE zcl_alloc_val_rollup=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_category TYPE string
        iv_value    TYPE i.

    METHODS rolls_up        FOR TESTING.
    METHODS counts_groups   FOR TESTING.
    METHODS picks_largest   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_val_rollup IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_val_rollup( ).

    add( iv_category = 'A' iv_value = 1000 ).
    add( iv_category = 'B' iv_value = 600 ).
    add( iv_category = 'A' iv_value = 200 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_val_rollup=>ty_line.

    ls_line-category = iv_category.
    ls_line-value = iv_value.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD rolls_up.
    DATA lt_groups TYPE zcl_alloc_val_rollup=>ty_group_tt.

    lt_groups = mo_cut->rollup( mt_line ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_groups ) exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_groups[ 1 ]-category exp = 'A' ).
    cl_abap_unit_assert=>assert_equals( act = lt_groups[ 1 ]-total exp = 1200 ).
    cl_abap_unit_assert=>assert_equals( act = lt_groups[ 2 ]-total exp = 600 ).
  ENDMETHOD.

  METHOD counts_groups.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->group_count( mt_line ) exp = 2 ).
  ENDMETHOD.

  METHOD picks_largest.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->largest_group( mt_line ) exp = 1200 ).
  ENDMETHOD.

ENDCLASS.
