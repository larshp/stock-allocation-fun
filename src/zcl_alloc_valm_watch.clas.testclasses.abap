CLASS ltcl_alloc_valm_watch DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_valm_watch.
    DATA mt_line TYPE zcl_alloc_valm_watch=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_material  TYPE matnr
        iv_value     TYPE i
        iv_threshold TYPE i.

    METHODS watches_lines FOR TESTING.
    METHODS counts_watch  FOR TESTING.
    METHODS watched_rule  FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_valm_watch IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_valm_watch( ).

    add( iv_material = 'M1' iv_value = 1500 iv_threshold = 1000 ).
    add( iv_material = 'M2' iv_value = 800 iv_threshold = 1000 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_valm_watch=>ty_line.

    ls_line-material = iv_material.
    ls_line-value = iv_value.
    ls_line-threshold = iv_threshold.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD watches_lines.
    DATA lt_watch TYPE zcl_alloc_valm_watch=>ty_watch_tt.

    lt_watch = mo_cut->watch( mt_line ).

    cl_abap_unit_assert=>assert_equals( act = lines( lt_watch ) exp = 1 ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_watch[ 1 ]-material exp = 'M1' ).
    cl_abap_unit_assert=>assert_equals(
      act = lt_watch[ 1 ]-excess exp = 500 ).
  ENDMETHOD.

  METHOD counts_watch.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->watch_count( mt_line ) exp = 1 ).
  ENDMETHOD.

  METHOD watched_rule.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_watched( iv_value = 1500 iv_threshold = 1000 )
      exp = abap_true ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_watched( iv_value = 800 iv_threshold = 1000 )
      exp = abap_false ).
  ENDMETHOD.

ENDCLASS.
