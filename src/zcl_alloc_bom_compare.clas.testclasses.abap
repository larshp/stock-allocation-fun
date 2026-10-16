CLASS ltcl_alloc_bom_compare DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_bom_compare.
    DATA mt_before TYPE zcl_alloc_bom_compare=>ty_line_tt.
    DATA mt_after TYPE zcl_alloc_bom_compare=>ty_line_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_side      TYPE string
        iv_component TYPE string
        iv_qty       TYPE i.

    METHODS compares_bom FOR TESTING.
    METHODS counts_added FOR TESTING.
    METHODS counts_removed FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_bom_compare IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_bom_compare( ).

    add( iv_side = 'B' iv_component = 'C1' iv_qty = 1 ).
    add( iv_side = 'B' iv_component = 'C2' iv_qty = 1 ).
    add( iv_side = 'A' iv_component = 'C1' iv_qty = 1 ).
    add( iv_side = 'A' iv_component = 'C3' iv_qty = 1 ).
  ENDMETHOD.

  METHOD add.
    DATA ls_line TYPE zcl_alloc_bom_compare=>ty_line.

    ls_line-component = iv_component.
    ls_line-qty = iv_qty.

    IF iv_side = 'B'.
      APPEND ls_line TO mt_before.
    ELSE.
      APPEND ls_line TO mt_after.
    ENDIF.
  ENDMETHOD.

  METHOD compares_bom.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->compare( it_before = mt_before it_after = mt_after )
      exp = 'CHANGED' ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->compare( it_before = mt_before it_after = mt_before )
      exp = 'SAME' ).
  ENDMETHOD.

  METHOD counts_added.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->added( it_before = mt_before it_after = mt_after )
      exp = 1 ).
  ENDMETHOD.

  METHOD counts_removed.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->removed( it_before = mt_before it_after = mt_after )
      exp = 1 ).
  ENDMETHOD.

ENDCLASS.
