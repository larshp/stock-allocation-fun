CLASS ltcl_alloc_landed_build DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_landed_build.
    DATA mt_component TYPE zcl_alloc_landed_build=>ty_component_tt.

    METHODS setup.

    METHODS add
      IMPORTING
        iv_name   TYPE string
        iv_amount TYPE i.

    METHODS builds_landed FOR TESTING.
    METHODS counts_parts  FOR TESTING.
    METHODS sums_total    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_landed_build IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_landed_build( ).
  ENDMETHOD.

  METHOD add.
    DATA ls_component TYPE zcl_alloc_landed_build=>ty_component.

    ls_component-name = iv_name.
    ls_component-amount = iv_amount.
    APPEND ls_component TO mt_component.
  ENDMETHOD.

  METHOD builds_landed.
    DATA ls_landed TYPE zcl_alloc_landed_build=>ty_landed.

    add( iv_name = 'BASE' iv_amount = 1000 ).
    add( iv_name = 'FREIGHT' iv_amount = 200 ).

    ls_landed = mo_cut->build( mt_component ).

    cl_abap_unit_assert=>assert_equals(
      act = ls_landed-component_count exp = 2 ).
    cl_abap_unit_assert=>assert_equals(
      act = ls_landed-total exp = 1200 ).
  ENDMETHOD.

  METHOD counts_parts.
    add( iv_name = 'BASE' iv_amount = 1000 ).
    add( iv_name = 'FREIGHT' iv_amount = 200 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->component_count( mt_component ) exp = 2 ).
  ENDMETHOD.

  METHOD sums_total.
    add( iv_name = 'BASE' iv_amount = 1000 ).
    add( iv_name = 'FREIGHT' iv_amount = 200 ).

    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->total( mt_component ) exp = 1200 ).
  ENDMETHOD.

ENDCLASS.
