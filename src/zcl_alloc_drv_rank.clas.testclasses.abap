CLASS ltcl_alloc_drv_rank DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_drv_rank.
    DATA mt_line TYPE zcl_alloc_drv_rank=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_name  TYPE string
        iv_value TYPE i.

    METHODS ranks_drivers FOR TESTING.
    METHODS picks_top     FOR TESTING.
    METHODS picks_bottom  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_drv_rank IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_drv_rank( ).

    add( iv_name = 'A' iv_value = 100 ).
    add( iv_name = 'B' iv_value = 300 ).
    add( iv_name = 'C' iv_value = 200 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_drv_rank=>ty_line.

    ls_line-name = iv_name.
    ls_line-value = iv_value.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD ranks_drivers.
    DATA lt_ranked TYPE zcl_alloc_drv_rank=>ty_line_tt.

    lt_ranked = mo_cut->rank( mt_line ).

    cl_abap_unit_assert=>assert_equals( act = lt_ranked[ 1 ]-value exp = 300 ).
    cl_abap_unit_assert=>assert_equals( act = lt_ranked[ 3 ]-value exp = 100 ).
  ENDMETHOD.

  METHOD picks_top.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->top( mt_line ) exp = 300 ).
  ENDMETHOD.

  METHOD picks_bottom.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->bottom( mt_line ) exp = 100 ).
  ENDMETHOD.

ENDCLASS.
