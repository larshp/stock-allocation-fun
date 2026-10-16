CLASS ltcl_alloc_replenish_release DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_replenish_release.
    DATA mt_line TYPE zcl_alloc_replenish_release=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_material TYPE matnr
        iv_released TYPE abap_bool
        iv_blocked  TYPE abap_bool.

    METHODS releases_lines FOR TESTING.
    METHODS reads_release  FOR TESTING.
    METHODS counts_blocked FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_replenish_release IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_replenish_release( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_replenish_release=>ty_line.

    ls_line-material = iv_material.
    ls_line-released = iv_released.
    ls_line-blocked = iv_blocked.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD releases_lines.
    DATA lt_line TYPE zcl_alloc_replenish_release=>ty_line_tt.

    add( iv_material = 'M1' iv_released = abap_false iv_blocked = abap_false ).
    add( iv_material = 'M2' iv_released = abap_false iv_blocked = abap_true ).

    lt_line = mo_cut->release( mt_line ).

    cl_abap_unit_assert=>assert_equals( act = lt_line[ 1 ]-released exp = abap_true ).
    cl_abap_unit_assert=>assert_equals( act = lt_line[ 2 ]-released exp = abap_false ).
  ENDMETHOD.

  METHOD reads_release.
    add( iv_material = 'M1' iv_released = abap_true iv_blocked = abap_false ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_released( it_lines = mt_line iv_material = 'M1' )
      exp = abap_true ).
  ENDMETHOD.

  METHOD counts_blocked.
    add( iv_material = 'M1' iv_released = abap_false iv_blocked = abap_false ).
    add( iv_material = 'M2' iv_released = abap_false iv_blocked = abap_true ).
    add( iv_material = 'M3' iv_released = abap_false iv_blocked = abap_true ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->blocked_count( mt_line ) exp = 2 ).
  ENDMETHOD.

ENDCLASS.
