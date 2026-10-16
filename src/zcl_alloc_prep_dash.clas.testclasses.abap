CLASS ltcl_alloc_prep_dash DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_prep_dash.
    DATA mt_line TYPE zcl_alloc_prep_dash=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_tile  TYPE string
        iv_value TYPE i.

    METHODS builds_dash FOR TESTING.
    METHODS counts_tiles FOR TESTING.
    METHODS sums_total   FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_prep_dash IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_prep_dash( ).

    add( iv_tile = 'T1' iv_value = 100 ).
    add( iv_tile = 'T2' iv_value = 200 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_prep_dash=>ty_line.

    ls_line-tile = iv_tile.
    ls_line-value = iv_value.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD builds_dash.
    DATA ls_dash TYPE zcl_alloc_prep_dash=>ty_dash.

    ls_dash = mo_cut->build( mt_line ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_dash-tile_count exp = 2 ).
    cl_abap_unit_assert=>assert_equals( act = ls_dash-total exp = 300 ).
  ENDMETHOD.

  METHOD counts_tiles.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->tile_count( mt_line ) exp = 2 ).
  ENDMETHOD.

  METHOD sums_total.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( mt_line ) exp = 300 ).
  ENDMETHOD.

ENDCLASS.
