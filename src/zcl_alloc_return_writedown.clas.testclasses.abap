CLASS ltcl_alloc_return_writedown DEFINITION
  FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS
  FINAL.

  PRIVATE SECTION.
    DATA mo_cut TYPE REF TO zcl_alloc_return_writedown.

    METHODS setup.

    METHODS computes_write   FOR TESTING.
    METHODS clamps_percent   FOR TESTING.
    METHODS computes_new     FOR TESTING.
    METHODS computes_loss    FOR TESTING.

ENDCLASS.


CLASS ltcl_alloc_return_writedown IMPLEMENTATION.

  METHOD setup.
    mo_cut = NEW zcl_alloc_return_writedown( ).
  ENDMETHOD.

  METHOD computes_write.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->write_down( iv_value = 100 iv_percent = 20 )
      exp = 20 ).
  ENDMETHOD.

  METHOD clamps_percent.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->write_down( iv_value = 100 iv_percent = 150 )
      exp = 100 ).
  ENDMETHOD.

  METHOD computes_new.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->new_value( iv_value = 100 iv_percent = 20 )
      exp = 80 ).
  ENDMETHOD.

  METHOD computes_loss.
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->loss( iv_value = 100 iv_new_value = 80 )
      exp = 20 ).
    cl_abap_unit_assert=>assert_equals(
      act = mo_cut->loss( iv_value = 80 iv_new_value = 100 )
      exp = 0 ).
  ENDMETHOD.

ENDCLASS.
