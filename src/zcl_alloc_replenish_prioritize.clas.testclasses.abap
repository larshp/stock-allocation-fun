CLASS ltcl_alloc_replen_prioritize DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_replenish_prioritize.
    DATA mt_line TYPE zcl_alloc_replenish_prioritize=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_material TYPE matnr
        iv_priority TYPE i.

    METHODS orders_lines   FOR TESTING.
    METHODS counts_lines   FOR TESTING.
    METHODS reads_first    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_replen_prioritize IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_replenish_prioritize( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_replenish_prioritize=>ty_line.

    ls_line-material = iv_material.
    ls_line-priority = iv_priority.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD orders_lines.
    DATA lt_sorted TYPE zcl_alloc_replenish_prioritize=>ty_line_tt.

    add( iv_material = 'M1' iv_priority = 1 ).
    add( iv_material = 'M2' iv_priority = 3 ).
    add( iv_material = 'M3' iv_priority = 2 ).

    lt_sorted = mo_cut->ordered( mt_line ).

    cl_abap_unit_assert=>assert_equals( act = lt_sorted[ 1 ]-material exp = 'M2' ).
    cl_abap_unit_assert=>assert_equals( act = lt_sorted[ 2 ]-material exp = 'M3' ).
    cl_abap_unit_assert=>assert_equals( act = lt_sorted[ 3 ]-material exp = 'M1' ).
  ENDMETHOD.

  METHOD counts_lines.
    add( iv_material = 'M1' iv_priority = 1 ).
    add( iv_material = 'M2' iv_priority = 3 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->line_count( mt_line ) exp = 2 ).
  ENDMETHOD.

  METHOD reads_first.
    add( iv_material = 'M1' iv_priority = 1 ).
    add( iv_material = 'M2' iv_priority = 3 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->first_material( mt_line ) exp = 'M2' ).
  ENDMETHOD.

ENDCLASS.
