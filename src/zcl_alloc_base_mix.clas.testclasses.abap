CLASS ltcl_alloc_base_mix DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_base_mix.
    DATA mt_line TYPE zcl_alloc_base_mix=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_name     TYPE string
        iv_quantity TYPE i.

    METHODS sums_mix   FOR TESTING.
    METHODS mixed_rule FOR TESTING.
    METHODS picks_largest FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_base_mix IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_base_mix( ).

    add( iv_name = 'A' iv_quantity = 100 ).
    add( iv_name = 'B' iv_quantity = 200 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_base_mix=>ty_line.

    ls_line-name = iv_name.
    ls_line-quantity = iv_quantity.
    APPEND ls_line TO mt_line.
  ENDMETHOD.

  METHOD sums_mix.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->mix( mt_line ) exp = 300 ).
  ENDMETHOD.

  METHOD mixed_rule.
    DATA lt_same TYPE zcl_alloc_base_mix=>ty_line_tt.
    DATA ls_line TYPE zcl_alloc_base_mix=>ty_line.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_mixed( mt_line ) exp = abap_true ).

    ls_line-name = 'A'.
    ls_line-quantity = 100.
    APPEND ls_line TO lt_same.
    ls_line-name = 'B'.
    ls_line-quantity = 100.
    APPEND ls_line TO lt_same.

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->is_mixed( lt_same ) exp = abap_false ).
  ENDMETHOD.

  METHOD picks_largest.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->largest( mt_line ) exp = 200 ).
  ENDMETHOD.

ENDCLASS.
