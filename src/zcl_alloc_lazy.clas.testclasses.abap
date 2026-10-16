CLASS ltcl_alloc_lazy DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_lazy.

    METHODS setup.

    METHODS loads_once        FOR TESTING.
    METHODS keeps_first_value FOR TESTING.
    METHODS resets_loader     FOR TESTING.
    METHODS unload_is_empty   FOR TESTING.
ENDCLASS.


CLASS ltcl_alloc_lazy IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_lazy( ).
  ENDMETHOD.

  METHOD loads_once.
    DATA lv_value TYPE string.

    lv_value = mo_cut->load( 'A' ).

    cl_abap_unit_assert=>assert_equals( act = lv_value exp = 'A' ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->is_loaded( ) exp = abap_true ).
  ENDMETHOD.

  METHOD keeps_first_value.
    DATA lv_value TYPE string.

    lv_value = mo_cut->load( 'A' ).
    lv_value = mo_cut->load( 'B' ).

    cl_abap_unit_assert=>assert_equals( act = lv_value exp = 'A' ).
  ENDMETHOD.

  METHOD resets_loader.
    DATA lv_value TYPE string.

    lv_value = mo_cut->load( 'A' ).

    mo_cut->reset( ).

    lv_value = mo_cut->load( 'B' ).

    cl_abap_unit_assert=>assert_equals( act = lv_value exp = 'B' ).
  ENDMETHOD.

  METHOD unload_is_empty.
    cl_abap_unit_assert=>assert_equals( act = mo_cut->is_loaded( ) exp = abap_false ).
    cl_abap_unit_assert=>assert_equals( act = mo_cut->get( ) exp = '' ).
  ENDMETHOD.

ENDCLASS.
